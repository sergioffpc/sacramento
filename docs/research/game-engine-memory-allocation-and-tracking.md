# Game Engine Memory Allocation and Tracking Guidance

Research date: 2026-09-04

Status: Non-canonical research. This note proposes candidates and measurements;
it does not change an approved requirement, Architecture Claim, ADR, dependency,
or C++ baseline. Where it conflicts with a canonical project source, that source
is authoritative.

## Table of contents

- [Executive recommendation](#executive-recommendation)
- [Project boundary](#project-boundary)
- [What “memory used” means](#what-memory-used-means)
- [Measuring total and attributing it to subsystems](#measuring-total-and-attributing-it-to-subsystems)
- [Allocation strategies](#allocation-strategies)
- [Alignment](#alignment)
- [Fragmentation](#fragmentation)
- [CPU allocator and profiling library candidates](#cpu-allocator-and-profiling-library-candidates)
- [GPU memory](#gpu-memory)
- [Candidate Sacramento architecture](#candidate-sacramento-architecture)
- [Verification and adoption plan](#verification-and-adoption-plan)
- [Practical rules](#practical-rules)
- [Primary sources](#primary-sources)

## Executive recommendation

A game engine should not begin with one elaborate custom allocator. It should
begin with one **observable allocation boundary**, measure real workloads, and
then introduce a small number of allocators selected by lifetime and access
pattern:

1. Keep a capable general-purpose heap as the fallback and for cold/control
   paths.
2. Route first-party allocations through explicit, hierarchical subsystem
   resources so every live byte has a stable owner.
3. Use per-thread frame/scratch arenas for temporary data, reset in bulk only
   after all users have crossed the applicable fence.
4. Use fixed-block pools only for genuinely numerous, same-sized, similarly
   lived objects.
5. Reserve capacity before active simulation for bounded session data, queues,
   reconstruction records, and other paths where an allocation failure or page
   fault would disrupt a Canonical Tick or final-image interval.
6. Keep GPU allocation and accounting separate from the CPU heap. Suballocate
   large API memory blocks with Vulkan Memory Allocator (VMA) or D3D12 Memory
   Allocator (D3D12MA), depending on the renderer eventually selected.
7. Record both cheap always-on counters and opt-in allocation events with
   callstacks. Reconcile internal totals with operating-system and GPU-driver
   totals to expose untracked memory.
8. Select or replace the general allocator only after replaying representative
   `Typical` and `Stress` workloads and comparing latency tails, resident
   memory, fragmentation, and cross-thread behavior on both target platforms.

The key design unit is the **lifetime domain**, not the C++ type and not merely
the subsystem. A renderer may need persistent resource metadata, frame scratch,
streaming staging, and GPU upload-ring allocations; putting all four into one
“renderer pool” mixes incompatible lifetimes and preserves fragmentation.

## Project boundary

This guidance uses the repository's canonical terms but remains historical
input under [Domain Documentation](../agents/domain.md). The approved project
baseline fixes C++23, Clang, Windows 11 and Debian targets, and requires native
measurement on the exact target profiles; third-party dependencies must follow
the approved qualification and pinning process
([C++ Engineering Baseline](../standards/cpp-engineering.md)).

The current Desktop Mode smoothness requirement admits only 1% of final-image
intervals above 16.67 ms during the measured run
([`NFR-DESKTOP-SMOOTHNESS-001`](../requirements/training-simulation-non-functional-requirements.md)).
Loading and Preparation may warm the system, but active-simulation measurement
has no excluded warm-up. Consequently, allocator locks, heap growth, demand
faults, synchronous compaction, and unbounded tracing are frame-time risks even
when their mean cost is small.

The accepted runtime architecture isolates responsibility domains and forbids
observability or evidence export from blocking a Canonical Tick
([runtime ownership and bounded failure](../architecture/0006-runtime-ownership-and-failure.md)).
It also requires Canonical Tick reconstruction records to be created in
reserved memory and handed off asynchronously
([evidence and ephemeral state](../architecture/0008-evidence-and-ephemeral-state.md)).
Memory telemetry therefore needs bounded, non-recursive buffers and explicit
loss accounting; it cannot allocate arbitrarily while reporting an allocation.

There is currently no approved process-memory or GPU-memory ceiling. The 128 GB
Desktop and 256 GB Session Authority hardware capacities are environment facts,
not permission to consume them and not acceptance budgets. Exact memory budgets
and workload-specific headroom remain a visible requirements/design gap.

## What “memory used” means

At least five quantities must remain distinct:

| Quantity | Meaning | Why it matters |
| --- | --- | --- |
| Requested live bytes | Sum of sizes requested by allocations not yet freed | Best ownership total by tag; excludes allocator rounding and metadata |
| Allocator capacity/reserved bytes | Address ranges or backing blocks retained by an allocator | Reveals caches, empty pages, arenas, and potential external fragmentation |
| Committed/private bytes | Memory for which the OS has accepted commit/private backing | Approximates process pressure better than virtual-address size |
| Resident bytes | Pages currently present in physical RAM | Changes with paging, sharing, and file mappings; is not an ownership ledger |
| GPU heap usage and budget | Driver estimate of process usage and usable budget per device heap/segment | Predicts residency pressure; is not the CPU heap total |

On Windows, `GetProcessMemoryInfo` exposes working-set and private commit
counters; Microsoft's mapping identifies
`PROCESS_MEMORY_COUNTERS_EX::PrivateUsage` with process commit and
`WorkingSetSize` with resident working set
([Memory Performance Information](https://learn.microsoft.com/en-us/windows/win32/memory/memory-performance-information),
[process example](https://learn.microsoft.com/en-us/windows/win32/psapi/collecting-memory-usage-information-for-a-process)).
On Linux, `/proc/<pid>/status` exposes `VmSize` and `VmRSS`, while
`/proc/<pid>/smaps_rollup` aggregates the more precise mapping-level data;
the kernel documentation warns that the quick resident values are less precise
than walking page tables for `smaps`
([Linux `/proc` documentation](https://www.kernel.org/doc/html/latest/filesystems/proc.html)).

These numbers legitimately differ. An engine's allocation tracker normally
misses executable images, stacks, third-party heaps, driver allocations,
allocator metadata, guard pages, memory-mapped files, and telemetry's own
storage. Conversely, a large reserved virtual range need not occupy physical
RAM. Windows explicitly distinguishes `MEM_RESERVE`, which reserves address
space without physical storage, from `MEM_COMMIT`, whose physical pages are
normally supplied on first access
([`VirtualAlloc2`](https://learn.microsoft.com/en-us/windows/win32/api/memoryapi/nf-memoryapi-virtualalloc2)).

Do not present a single “RAM used” gauge. Present the four CPU rows above plus
GPU heaps, with definitions and units in the UI and telemetry schema.

## Measuring total and attributing it to subsystems

### Hierarchical ownership tags

Give every explicit allocation resource a stable tag from a bounded hierarchy.
A candidate initial hierarchy is:

```text
Process
├── Simulation Engine
│   ├── Session Lifecycle
│   ├── Simulation
│   ├── Scenario
│   ├── Protocol & Replication
│   └── AUTH & Admission
├── Trainee Client
│   ├── Presentation
│   │   ├── Render CPU
│   │   ├── Render GPU
│   │   └── Audio
│   └── Input & Interaction
├── Runtime Package / Content Admission
├── Observability
├── Third Party
└── Untracked
```

This is an accounting view, not a new runtime decomposition. Tags should be
stable numeric identifiers with display names supplied separately. Child totals
roll up to parents, but one allocation has exactly one accounting owner. Shared
objects need an explicit owner; charging the same allocation to every consumer
double-counts it.

Unreal's Low-Level Memory Tracker validates this pattern at engine scale: it
uses scoped hierarchical tags, maintains a high-level engine-allocation tracker
and a lower-level platform tracker, and treats their difference as meaningful
instead of assuming both totals are equal
([Epic LLM documentation](https://dev.epicgames.com/documentation/en-us/unreal-engine/using-the-low-level-memory-tracker-in-unreal-engine)).
Unity likewise associates native allocations with labels, areas, and roots and
can report the allocator/region behind them
([Unity native memory documentation](https://docs.unity3d.com/Manual/performance-unmanaged-memory.html)).

### Counters and events

For every tag, allocator instance, and lifetime domain, collect:

- current and peak requested bytes;
- current and peak allocation count;
- cumulative allocated and freed bytes/counts;
- allocation failures and requested size/alignment;
- reserved/backing-block bytes and committed bytes, where known;
- bytes in free blocks, largest free block, and free-block count;
- padding/size-class waste and allocator metadata, where measurable;
- allocations and bytes per frame or Canonical Tick;
- allocation/deallocation latency histograms, especially p99 and maximum; and
- cross-thread frees or remote-free queue depth for a thread-caching heap.

Use per-thread counter shards and publish bounded deltas at a safe point. A
global atomic update on every small allocation can itself create contention.
The tracker must use preallocated metadata or a separate bounded arena so that
tracking an allocation cannot recursively invoke the tracked allocator.

Cheap counters should be always available in development and production.
Detailed events—address, size, alignment, tag, allocator, thread, timestamp,
source location and optionally callstack—should have an opt-in diagnostic mode,
bounded buffering, explicit dropped-event counts, and offline aggregation.
Epic's Memory Insights demonstrates the useful resulting queries: live
allocations at a point, growth between two points, short- versus long-lived
allocations, leaks, LLM tag, and callstack
([Memory Insights](https://dev.epicgames.com/documentation/en-us/unreal-engine/memory-insights-in-unreal-engine)).

### Reconciliation

Sample and graph these together at process start, phase transitions, periodic
intervals, and shutdown:

```text
tracked live requested
≤ allocator retained/reserved capacity
≈ known private CPU mappings
≤/≈ OS private commit

OS private commit - known private mappings = unattributed private memory
OS resident set is reported separately, not forced into the equation
GPU usage/budget is reported per heap or segment, not added blindly to CPU RAM
```

The relations are diagnostic expectations, not universal identities. For
example, host-visible graphics memory can interact with system memory, mappings
may be shared, and driver accounting is implementation-dependent. Alert on an
unexpectedly growing discrepancy rather than demanding exact equality.

At shutdown and at stable checkpoints, emit a snapshot with build,
configuration, Runtime Content Release, workload/profile identity, process
phase, and tag tree. Snapshot diffs are more useful than isolated totals:
“after 30 minutes minus after 5 minutes” exposes retained growth even where all
pointers remain technically reachable.

## Allocation strategies

No strategy dominates every workload:

| Pattern | Candidate allocator | Benefit | Principal risk |
| --- | --- | --- | --- |
| Unknown/mixed, cold path | General-purpose heap | Flexibility and mature concurrency behavior | Variable latency, retention, weak lifetime information |
| Many temporary values with one end-of-phase lifetime | Linear/bump arena | Very cheap allocation and one bulk reset; no per-object free | Any surviving pointer becomes invalid; high-water capacity remains until release |
| Strict LIFO temporary work | Stack allocator | Cheap rewind to marker | Incorrect non-LIFO lifetime corrupts ownership model |
| Many identical small objects | Fixed-block/slab pool | Constant-size freelist, locality, little external fragmentation | Wastes a whole slot for smaller values; capacity can become stranded |
| Small mixed objects from known size classes | Segregated-fit/bucket allocator | Fast bounded lookup, amortized backing allocations | Internal fragmentation from rounding; tuning is workload-specific |
| Bounded long-lived region | Arena over reserved/committed pages | Early capacity check and bulk ownership | Over-reservation, demand faults if not warmed, no independent frees |
| Very large or exceptional object | Direct page allocation | Isolates large blocks from small-object heap | Page/granularity waste and higher OS-call cost |
| Streaming/upload data | Fence-aware ring buffer | Reuse in order without general free-list work | Overwrite unless producer observes consumer/GPU fence |
| Movable GPU/asset data | Handle-based suballocator | Permits compaction and relocation | Indirection and synchronization complexity |

The standard C++ polymorphic memory resource interface is a useful project seam:
`std::pmr::memory_resource::allocate` carries both byte size and alignment, and
PMR containers accept a resource without templating the container type on a
concrete allocator
([C++ draft, memory resources](https://eel.is/c++draft/mem.res)).
`std::pmr::monotonic_buffer_resource` ignores individual deallocation and grows
through an upstream resource until `release()` or destruction, matching a phase
arena; pool resources group allocations into pools and reduce calls to their
upstream resource
([monotonic resource](https://eel.is/c++draft/mem.res.monotonic.buffer),
[pool resources](https://eel.is/c++draft/mem.res.pool)).

PMR is an interface and a useful standard implementation set, not a complete
engine memory policy. It does not attach subsystem tags, enforce budgets,
reserve operating-system pages, capture callstacks, or manage GPU memory. Wrap
or derive resources to add those behaviors, and ensure the wrapper's lifetime
outlives every container using it.

### Pools of equal-size objects

A fixed-block pool should divide backing slabs into equally sized, properly
aligned slots and keep a free list in unused slots. This makes allocate/free
small and predictable and removes external fragmentation inside that pool.
Boost.Pool documents this simple segregated-storage arrangement and its
same-size restriction
([Boost.Pool concepts](https://www.boost.org/doc/libs/latest/libs/pool/doc/html/boost_pool/pool/pooling.html),
[`boost::pool`](https://www.boost.org/doc/libs/latest/libs/pool/doc/html/boost/pool.html)).

Use a pool when measurements show high counts and stable slot size/lifetime,
for example command nodes or component chunks. Prefer contiguous component
pages/chunks and handles when iteration is dominant; one allocation per entity
can still have poor cache locality even if allocation itself is fast. Keep a
maximum slab count, report occupancy/high-water mark, and return wholly empty
slabs where the lifetime policy allows it.

### Preallocation and arenas

Preallocation should mean **measured capacity planning**, not “commit all RAM at
startup”. During Loading and Preparation:

- derive capacities from admitted content and bounded runtime profiles;
- reserve address space and backing blocks;
- commit and touch pages whose first-use fault would fall in active simulation;
- populate freelists and establish thread ownership;
- fail admission/loading clearly if a hard required capacity is unavailable;
- retain headroom based on measured high-water marks and a documented budget;
  and
- distinguish elastic caches, which can be evicted, from correctness-critical
  capacity, which cannot.

Use one scratch arena per worker or execution context rather than a locked
global arena. Reset only after every task, immutable-view consumer, asynchronous
I/O operation, and GPU command using that generation has completed. Two or
three generations often simplify frame overlap; the number must follow actual
in-flight work, not folklore.

## Alignment

C++ object storage must satisfy the type's alignment; constructing an object in
misaligned storage is undefined behavior. Valid alignments are powers of two,
and over-aligned types require the corresponding aligned allocation path
([C++ draft, alignment](https://eel.is/c++draft/basic.align),
[dynamic allocation](https://eel.is/c++draft/basic.stc.dynamic.allocation)).

Recommended allocator contract:

```cpp
void* allocate(std::size_t bytes, std::size_t alignment,
               MemoryTag tag, Lifetime lifetime);
void deallocate(void* pointer, std::size_t bytes,
                std::size_t alignment, MemoryTag tag);
```

Validate that alignment is a supported non-zero power of two, round offsets
with overflow-checked arithmetic, preserve the original base pointer/size when
overallocating, and pair allocation/deallocation APIs exactly. On Windows,
memory from `_aligned_malloc` must be returned with `_aligned_free`, not `free`
([Microsoft `_aligned_malloc`](https://learn.microsoft.com/en-us/cpp/c-runtime-library/reference/aligned-malloc)).
Standard aligned `operator new(size, std::align_val_t)` and PMR should be the
portable first-party surface; isolate platform calls below it.

Alignment is a correctness constraint and sometimes a measured optimization.
Do not cache-line-align every object: padding can increase footprint and cache
misses. Apply cache-line separation to demonstrated false-sharing hot spots,
SIMD alignment where the selected load/store contract requires it, and page or
GPU alignment where the platform/API requires it. Vulkan reports the exact
`size`, `alignment`, and compatible memory types for each resource in
`VkMemoryRequirements`; do not guess these values
([Khronos `VkMemoryRequirements`](https://registry.khronos.org/vulkan/specs/latest/man/html/VkMemoryRequirements.html)).

## Fragmentation

Track two different losses:

- **internal fragmentation**: allocator capacity occupied by a live allocation
  minus its requested bytes, including size-class rounding and alignment
  padding;
- **external fragmentation**: free capacity split into ranges that cannot
  satisfy a request despite sufficient aggregate free bytes.

Useful per-region values are `free_bytes`, `largest_free_block`,
`free_block_count`, `requested_live_bytes`, `allocated_slot_bytes`, and
`reserved_bytes`. A simple warning indicator is
`1 - largest_free_block / free_bytes` when `free_bytes > 0`, but it is not a
universal score: the relevant question is whether the observed request-size
distribution can be served.

Prevent fragmentation before compacting:

1. segregate short-, medium-, and long-lived allocations;
2. segregate small size classes from large direct allocations;
3. bulk-reset phase/frame memory;
4. use stable chunk sizes for repeated objects;
5. bound caches and release wholly empty pages/slabs;
6. avoid resizing long-lived buffers repeatedly—measure and reserve sensible
   capacity, or rebuild them at a controlled phase boundary; and
7. do not create a physically separate heap for every accounting tag, because
   lightly used private heaps can strand capacity. Tracking and allocation
   policy are separate axes.

Compaction is appropriate only when references are relocatable—handles,
offsets, or an owner-controlled pointer-update protocol—and when copying can be
budgeted outside latency-critical work. VMA describes the concrete failure
mode (enough total free bytes but no contiguous range), and its defragmentation
requires application cooperation to recreate/copy resources; it supports
incremental byte/allocation limits per pass
([VMA defragmentation](https://gpuopen-librariesandsdks.github.io/VulkanMemoryAllocator/html/defragmentation.html)).
Raw C++ pointers to arbitrary objects make general heap compaction impractical.

## CPU allocator and profiling library candidates

These are candidates for proof builds, not dependency selections:

| Candidate | What the primary source establishes | Appropriate evaluation |
| --- | --- | --- |
| Standard `std::pmr` | Standard resource seam, aligned byte allocation, monotonic and pooled resources | First-party API and simple lifetime allocators; availability must be proven in both pinned standard libraries |
| mimalloc | General-purpose allocator, explicit heaps, aligned APIs, detailed size-class statistics in debug, guarded/debug modes, and override options | General fallback candidate; compare retention, remote frees, release behavior, binary integration, and sanitizer compatibility ([official repository](https://github.com/microsoft/mimalloc)) |
| rpmalloc | Per-thread heaps, fixed size classes, page/span organization, direct mapping for huge blocks, 16-byte default alignment, configurable virtual-memory mapping | General fallback candidate for allocation-heavy threaded workloads; test thread lifecycle and cross-thread frees ([official repository](https://github.com/mjansson/rpmalloc)) |
| jemalloc | Arenas, thread caches, size-class and resident/retained statistics exposed through `mallctl` | Particularly strong diagnostic/control reference; prove target/build support and compare footprint before selection ([official manual](https://jemalloc.net/jemalloc.3.html)) |
| TLSF | The maintained implementation advertises constant-time allocate/free/realloc/memalign, pool regions and low overhead, but is not thread-safe by itself | Bounded single-owner arena where worst-case operation cost matters; do not make it the process heap without concurrency design ([official implementation](https://github.com/mattconte/tlsf)) |
| Boost.Pool | Fixed-size segregated storage with portable alignment | Repeated equal-sized nodes if Boost is otherwise admissible; a small project-owned pool may be narrower ([official docs](https://www.boost.org/doc/libs/latest/libs/pool/doc/html/boost/pool.html)) |
| Tracy | Cross-platform frame profiler supporting CPU/GPU zones and memory allocation events | Correlate allocation bursts with frames/ticks and named pools; quantify capture overhead and bound telemetry ([official repository](https://github.com/wolfpld/tracy), [manual source](https://github.com/wolfpld/tracy/blob/master/manual/tracy.tex)) |

Do not select by a vendor microbenchmark. Replay the engine's size/lifetime/thread
trace, include idle retention and phase transitions, and measure both time and
space. A replacement process heap does not remove the need for tags, specialized
lifetime resources, or OS reconciliation.

For correctness diagnostics, keep AddressSanitizer and LeakSanitizer lanes.
ASan detects heap/stack/global out-of-bounds, use-after-free, invalid/double
free and other memory errors, at substantial runtime cost; LSan performs leak
detection and is not a production runtime
([Clang ASan](https://clang.llvm.org/docs/AddressSanitizer.html),
[Clang LSan](https://clang.llvm.org/docs/LeakSanitizer.html)).
Custom pools should expose poison/unpoison hooks where supported or provide
redzones/quarantine in diagnostic builds; otherwise a fast pool can hide the
very lifetime errors the diagnostics are intended to find.

Valgrind Massif is a useful Debian-side independent check because it separates
requested heap bytes from allocator overhead/alignment and can optionally
profile page mappings. Its documentation explicitly notes that default heap
measurement can be much smaller than total process memory
([Massif manual](https://valgrind.org/docs/manual/ms-manual.html)).

## GPU memory

GPU memory is an explicit resource system with API-specific heaps, memory
types, residency and alignment. Track at least:

- API memory blocks/heaps reserved;
- bytes suballocated and free within them;
- resources by tag (`textures`, `render targets`, `geometry`, `upload`,
  `readback`, `transient`);
- dedicated versus suballocated resources;
- internal alignment/granularity waste;
- current driver-reported usage and budget per heap/segment;
- evictions/residency failures and allocation latency; and
- deferred-destruction bytes waiting for a GPU fence.

Vulkan's `VK_EXT_memory_budget` supplies `heapUsage` and `heapBudget` estimates
per memory heap. The budget is a changing guideline based on OS/system load,
not the physical heap size and not a guarantee
([Khronos extension](https://registry.khronos.org/vulkan/specs/latest/man/html/VkPhysicalDeviceMemoryBudgetPropertiesEXT.html),
[extension rationale](https://registry.khronos.org/vulkan/specs/latest/man/html/VK_EXT_memory_budget.html)).
On Windows/DXGI, `DXGI_QUERY_VIDEO_MEMORY_INFO` supplies `CurrentUsage`,
`Budget`, reservation and available-for-reservation; Microsoft warns that
exceeding the budget can cause stutter or performance penalties
([Microsoft DXGI structure](https://learn.microsoft.com/en-us/windows/win32/api/dxgi1_4/ns-dxgi1_4-dxgi_query_video_memory_info)).

Prefer a mature suballocator rather than one `vkAllocateMemory`/D3D12 committed
resource per small resource:

- **VMA** supports Vulkan memory requirements, custom and linear pools,
  `VK_EXT_memory_budget`, statistics, allocation names, JSON maps, and
  cooperative defragmentation
  ([official repository](https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator),
  [statistics](https://gpuopen-librariesandsdks.github.io/VulkanMemoryAllocator/html/statistics.html),
  [budget guidance](https://gpuopen-librariesandsdks.github.io/VulkanMemoryAllocator/html/staying_within_budget.html)).
- **D3D12MA** offers custom pools, linear/ring patterns, defragmentation,
  statistics, names, JSON maps, and custom CPU allocation callbacks for D3D12
  heaps/resources
  ([AMD GPUOpen overview](https://gpuopen.com/d3d12-memory-allocator/),
  [official documentation](https://gpuopen-librariesandsdks.github.io/D3D12MemoryAllocator/html/)).

Keep large persistent textures/buffers separate from transient render-graph
resources and upload/readback rings. Alias transient GPU memory only after the
render graph has proven non-overlapping lifetimes, and report both logical
resource bytes and physical heap bytes so aliasing does not look like an
accounting error. Destroy resources only after the last GPU fence that can
reference them; “logically freed” and “physically reusable” are distinct states.

## Candidate Sacramento architecture

The following architecture is deliberately narrow and compatible with the
current ownership model:

```text
Subsystem / task receives an explicit MemoryResource handle
                         │
                         ▼
             Budget + tag tracking wrapper
             ├── cheap sharded counters
             └── optional bounded event stream
                         │
                         ▼
             Lifetime-specific resource
             ├── frame/task scratch arena
             ├── session/phase arena
             ├── fixed-block/component pool
             ├── streaming ring
             └── general heap fallback
                         │
                         ▼
              OS virtual-memory adapter

Renderer resource owner ──► VMA or D3D12MA ──► GPU API heaps
OS sampler ────────────────► reconciliation snapshots
```

### Interfaces and ownership

- Define a small Sacramento `MemoryResource`/`MemoryResourceRef` interface or a
  strict PMR-based equivalent carrying byte size and alignment. Keep platform
  and third-party allocator types out of subsystem interfaces.
- Construct one tracking/budget wrapper per stable tag and lifetime domain;
  wrappers may share the same upstream heap. This attributes memory without
  stranding a large physical heap per subsystem.
- Pass resource handles explicitly through construction and job/task payloads.
  A thread-local “current subsystem” scope may be a convenience for synchronous
  code, but must not be the only mechanism: work stealing and asynchronous
  continuation otherwise charge memory to whichever thread executes it.
- The owner that allocates owns deallocation or transfers an explicit handle
  with allocator identity. Never free through a different allocator/module/CRT.
- Give third-party libraries their own tag and their allocation callbacks where
  available. The OS reconciliation difference covers libraries and drivers
  that cannot use those callbacks.

### Suggested lifetime domains

- **Bootstrap/permanent:** small engine registries and immutable configuration;
  destruction only at process shutdown.
- **Loading/Preparation:** staging and content validation arenas, reset after a
  successful immutable handoff or failed admission.
- **Training Session:** bounded live state owned by the canonical responsibility
  modules; released at terminal transition/process end, consistent with the
  accepted ephemeral-state architecture.
- **Canonical Tick scratch:** owner-local double/triple-buffered arenas with a
  precise commit/publication fence; no external evidence exporter retains
  pointers into them.
- **Presentation frame scratch:** one generation per actual CPU/GPU frame in
  flight, fence-controlled.
- **Streaming:** bounded upload/readback rings and elastic decoded-asset caches.
- **Evidence/Observability handoff:** fixed-capacity queues and reserved record
  buffers, with the architecture's required acknowledgement/backpressure/loss
  semantics; never an unbounded heap-backed queue.

### Budgets and failure policy

Assign a soft and, where correctness permits, hard budget to each lifetime/tag
pair. A budget record needs owner, scope, units, workload/profile, headroom
rationale, exceed action, and evidence source. Candidate actions are:

- warn and capture a diagnostic snapshot;
- evict an explicitly elastic cache;
- degrade only an approved quality tier;
- reject Loading/Admission before active simulation; or
- enter the already-defined bounded failure path.

Do not improvise domain behavior on out-of-memory. In particular, silently
dropping canonical state or required reconstruction evidence is not a memory
optimization. The failure response must be chosen by a later approved design.

## Verification and adoption plan

### Phase 1 — visibility before optimization

1. Add tag IDs and tracking wrappers around the current allocator.
2. Add Windows/Linux process samplers and renderer-independent GPU metric
   slots; leave GPU slots unavailable until a graphics API exists.
3. Record phase-transition and periodic snapshots plus optional Tracy events.
4. Establish the untracked delta and tracker overhead.

Exit evidence: totals reconcile within explained categories, every first-party
allocation path is tagged or visibly `Untracked`, and tracking never recurses or
blocks a Canonical Tick.

### Phase 2 — capture representative traces

Run exact native `Typical` and `Stress` profiles and collect distributions by
size, alignment, lifetime, thread, tag, and phase. Include startup, Loading,
Preparation, five-minute active simulation, terminal settling, and shutdown.
Measure long-soak growth separately; a five-minute run does not establish
steady-state retention.

### Phase 3 — specialize only proven patterns

Add frame/tick arenas first if traces show transient churn. Add a pool only for
a dominant stable size/lifetime class. Add bounded preallocation where capacity
can be derived. Compare every change against the fallback for peak private
commit/RSS, p99/max allocation latency, final-image intervals, Canonical Tick
behavior, and fragmentation indicators.

### Phase 4 — allocator bake-off

Replay a captured allocation trace and the real engine workload against the
platform baseline, mimalloc, and rpmalloc; include jemalloc if its target proof
is acceptable. Test:

- single- and multi-thread throughput plus p50/p95/p99/max latency;
- remote frees and thread creation/destruction;
- requested, reserved/retained, committed/private, and resident peaks;
- return of memory after phase reset and a high-water burst;
- large and over-aligned allocations;
- deterministic functional results (allocator address differences must not
  affect canonical ordering);
- ASan/LSan and profiler compatibility; and
- Windows clang-cl cross-build, native Windows runtime, and native Debian
  runtime under the pinned baseline.

Any selected library then needs the repository's normal dependency,
licence/security, pinning, build, inventory, and acceptance treatment. This
research does not perform that selection.

## Practical rules

- Optimize allocation **frequency, lifetime grouping, and data layout** before
  replacing `malloc` globally.
- No general-purpose heap allocation in a measured hot loop unless a trace and
  benchmark show it is harmless and bounded.
- Pre-size containers from admitted content/profile bounds; do not guess an
  enormous universal reserve.
- Store bulk homogeneous data contiguously; prefer indices/handles where
  relocation or compaction is valuable.
- Keep allocator choice out of domain semantics and serialized state.
- Make ownership and deallocator identity explicit across DLL/library seams.
- Measure tracker/profiler overhead with the same rigor as the allocator.
- Keep diagnostic guard/quarantine/callstack modes separate from acceptance
  measurements while preserving the same counter meanings.
- Treat allocation failure as a designed outcome, not an assertion that can
  occur at an arbitrary point in active simulation.
- Report CPU requested/reserved/commit/resident and GPU usage/budget separately.
- Set budgets from evidence on approved profiles, then retain deliberate
  headroom; hardware capacity itself is not a budget.

## Primary sources

### Standards and operating systems

- [C++ working draft: memory resources](https://eel.is/c++draft/mem.res)
- [C++ working draft: alignment](https://eel.is/c++draft/basic.align)
- [Microsoft: Memory Performance Information](https://learn.microsoft.com/en-us/windows/win32/memory/memory-performance-information)
- [Microsoft: `VirtualAlloc2`](https://learn.microsoft.com/en-us/windows/win32/api/memoryapi/nf-memoryapi-virtualalloc2)
- [Linux kernel: `/proc` filesystem](https://www.kernel.org/doc/html/latest/filesystems/proc.html)
- [Khronos: Vulkan memory allocation](https://registry.khronos.org/vulkan/specs/latest/html/vkspec.html#memory)
- [Khronos: `VK_EXT_memory_budget`](https://registry.khronos.org/vulkan/specs/latest/man/html/VK_EXT_memory_budget.html)
- [Microsoft: DXGI video-memory information](https://learn.microsoft.com/en-us/windows/win32/api/dxgi1_4/ns-dxgi1_4-dxgi_query_video_memory_info)

### Allocators and tools

- [mimalloc repository and documentation](https://github.com/microsoft/mimalloc)
- [rpmalloc repository and implementation notes](https://github.com/mjansson/rpmalloc)
- [jemalloc manual](https://jemalloc.net/jemalloc.3.html)
- [TLSF implementation](https://github.com/mattconte/tlsf)
- [Boost.Pool documentation](https://www.boost.org/doc/libs/latest/libs/pool/doc/html/index.html)
- [Vulkan Memory Allocator repository](https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator)
- [D3D12 Memory Allocator documentation](https://gpuopen-librariesandsdks.github.io/D3D12MemoryAllocator/html/)
- [Tracy repository](https://github.com/wolfpld/tracy)
- [Clang AddressSanitizer](https://clang.llvm.org/docs/AddressSanitizer.html)
- [Clang LeakSanitizer](https://clang.llvm.org/docs/LeakSanitizer.html)
- [Valgrind Massif manual](https://valgrind.org/docs/manual/ms-manual.html)

### Engine precedents

- [Epic: Low-Level Memory Tracker](https://dev.epicgames.com/documentation/en-us/unreal-engine/using-the-low-level-memory-tracker-in-unreal-engine)
- [Epic: Memory Insights](https://dev.epicgames.com/documentation/en-us/unreal-engine/memory-insights-in-unreal-engine)
- [Unity: unmanaged/native memory](https://docs.unity3d.com/Manual/performance-unmanaged-memory.html)
- [Unity: native memory allocator reference](https://docs.unity3d.com/Manual/performance-native-memory-allocator-reference.html)
