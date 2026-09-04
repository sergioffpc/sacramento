# Cache Coherence and Multicore Programming: Quick Reference Guide

Research date: 2026-09-04

Review: Project owner confirmed the non-canonical scope and editorial posture,
2026-09-04

Status: Non-canonical historical research. This note reviews general educational
material and proposes measurement practices; it does not create or change a
requirement, Architecture Claim, ADR, dependency, verification obligation, or
the C++ baseline. Where it conflicts with a canonical project source, that
source is authoritative.

## Summary of corrections

| Original simplification | More precise formulation |
| --- | --- |
| Every core has its own cache. | Topology depends on the processor. Private L1/L2 caches and a shared or distributed last-level cache are common; hardware threads on one physical core may share caches. |
| Coherence makes every core see current data. | Coherence keeps copies of one location consistent. By itself, it does not define the observable order of different locations. |
| MESI controls cache lines. | MESI is a useful base model. Real implementations use variants such as MESIF and MOESDIF. |
| Loads pass stores and read old values. | An architecture may allow a later load from a **different address** to be observed before an earlier store. Address, forwarding, memory type, and architecture rules matter. |
| An invalidate queue leaves stale data visible. | It is one possible microarchitectural model, not a portable abstraction or a C++ contract. |
| Release drains stores before continuing. | In C++, release publishes preceding evaluations to an acquire that observes the relevant release sequence; it does not mean “flush the cache” or necessarily block the producer. |
| Acquire processes invalidations before reading. | In C++, acquire orders subsequent evaluations and can establish a `synchronizes-with` relation; the hardware implementation varies. |
| CAS operates in the cache and needs barriers. | A successful CAS is an atomic read-modify-write operation. Ordering is a parameter and may even be `relaxed`. |
| Shared data should be aligned to 128 bytes. | Separate only hot, independently written objects, using the implementation or hardware interference size and confirming the result through measurement. |

## Project boundary

This note is explanatory input, not a Sacramento engineering baseline. The
[C++ Engineering Baseline](../standards/cpp-engineering.md) owns concurrency and
performance rules. The
[Reference Hardware Profiles](../requirements/training-simulation-reference-hardware-profiles.md)
own the accepted processor and platform identities, while the
[Non-Functional Requirements](../requirements/training-simulation-non-functional-requirements.md)
own user-visible temporal acceptance. The
[runtime ownership architecture](../architecture/0006-runtime-ownership-and-failure.md)
owns exclusive mutation, immutable publication, handoff, and failure boundaries.

Cache and memory metrics in this note are diagnostic. They do not determine
`Pass` or `Fail` unless a separately approved requirement or profile defines
the exact workload, target, events, threshold, tolerance, method, and evidence.

## Two distinct layers

### Architecture and microarchitecture

The instruction-set architecture defines observable ordering and atomicity
behavior. An implementation may use out-of-order execution, caches, write/store
buffers, coherence messages, queues, and speculation. Arm explicitly
distinguishes instruction execution order from the order in which accesses
appear to the memory system, and identifies write buffers and caches as
mechanisms that can make them differ
([Armv8-A Memory Model, sections 2 and 4](https://developer.arm.com/-/media/Arm%20Developer%20Community/PDF/Learn%20the%20Architecture/Armv8-A%20memory%20model%20guide.pdf?revision=58b1dd0a-3800-4218-b21a-f95a0332034c)).

### The C++ abstract machine

C++ defines atomicity, modification order, `happens-before`, and data races; it
does not promise a cache protocol or a concrete queue. Two concurrent,
conflicting accesses, at least one of which is non-atomic, form a data race when
there is no `happens-before` relation; the result is undefined behavior. This
remains true even if a test appears to work on one CPU
([ISO/IEC 14882:2024](https://www.iso.org/standard/83626.html),
[final C++23 working draft N4950, `[intro.races]`](https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2023/n4950.pdf)).

Demonstrate correctness first in the language memory model. Microarchitecture
explains costs and instruction mappings; it does not replace that proof.

## Topology, coherence, and MESI

“One cache per core” is only an introductory picture. Intel documents Xeon
processors with private L1/L2 caches per physical core and an LLC accessible to
all cores within the illustrated processor package, but also Atom processors
with private L1, an L2 shared by a four-core module, and a shared L3. With
simultaneous multithreading, logical processors on the same core share cache
resources
([Xeon topology](https://www.intel.com/content/dam/www/public/us/en/documents/white-papers/cache-allocation-technology-white-paper.pdf),
[Atom topology](https://cdrdv2-public.intel.com/795247/357930-Hardware-Prefetch-Controls-for-Intel-Atom-Cores.pdf)).

Coherence primarily answers a per-location question: which copy of a line is
valid, and who may read or modify it? Memory consistency and ordering answer a
different question: which combinations of observations are permitted across
multiple accesses and locations? Intel and Arm specify ordering rules
separately from cache details
([Intel 64 and IA-32 manuals](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html),
[Armv8-A Memory Model, sections 4 and 9](https://developer.arm.com/-/media/Arm%20Developer%20Community/PDF/Learn%20the%20Architecture/Armv8-A%20memory%20model%20guide.pdf?revision=58b1dd0a-3800-4218-b21a-f95a0332034c)).

In the MESI model:

- **Modified:** this cache has the current, modified copy; memory is stale;
- **Exclusive:** only this cache has a clean, current copy; memory is current;
- **Shared:** multiple caches may have current copies; and
- **Invalid:** the line does not contain a valid copy.

MESI is not universal. Current AMD64 documentation specifies **MOESDIF**
(Modified, Owned, Exclusive, Shared, Dirty, Invalid, Forward), while Intel
describes **MESIF** systems. In states such as Modified and Owned, the newest
copy may be in a cache rather than RAM; the protocol supplies the correct data
to other coherent agents
([AMD64 APM, volume 2, section 7.3](https://docs.amd.com/api/khub/documents/sD1_QL~h4Afq2_tvzxqqSQ/content),
[Intel QuickPath Interconnect introduction](https://www.intel.com/content/dam/doc/white-paper/quick-path-interconnect-introduction-paper.pdf)).

### NUMA and multi-socket systems

A coherent multi-socket system is not uniform. A core can usually reach local
memory and its package's last-level cache more cheaply than remote memory or a
line owned by another socket. First-touch placement, thread migration, remote
access, and cross-socket ownership transfers can therefore change latency and
bandwidth even though software observes coherent memory.

This distinction matters to the dual-socket `RHP-AUTHORITY-001` target. A
candidate investigation can record NUMA node, local and remote traffic, thread
migration, and cache-to-cache transfers. Affinity and page-placement policy
remain workload-specific hypotheses: retain them only when measurement shows a
benefit without harming load balance or platform parity. GPU and other device
memory-coherence models are outside this CPU-focused guide.

## Store buffers and invalidations

A store buffer may retain a write before it becomes globally visible, allowing
the core to continue. AMD documents that write results may remain in a private
buffer before commit, and Intel documents store buffers as implementation
resources
([AMD64 APM, volume 1, sections 3.9.1.2 and 3.9.2](https://docs.amd.com/api/khub/documents/sfvvekC9mDflu6vd3R0NXA/content),
[Intel buffer description](https://www.intel.com/content/www/us/en/developer/articles/technical/software-security-guidance/technical-documentation/intel-analysis-microarchitectural-data-sampling.html)).

“Loads pass stores” needs qualification. In the Intel model, a load may be
reordered with an earlier store to a **different location**. This does not imply
that a load from the same address simply ignores the preceding store: forwarding
and the architecture's observation rules apply
([Intel SDM, volume 3A, chapter 9, Processor Ordering](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html)).

An “invalidate queue” can help illustrate an implementation, but it is not a
portable proof. C++ software cannot infer that acquire “drains” a universal
queue. Arm specifies observations and barrier effects; C++ specifies
`synchronizes-with` and `happens-before`
([Armv8-A Memory Model, section 4](https://developer.arm.com/-/media/Arm%20Developer%20Community/PDF/Learn%20the%20Architecture/Armv8-A%20memory%20model%20guide.pdf?revision=58b1dd0a-3800-4218-b21a-f95a0332034c),
[C++23 working draft N4950,
`[atomics.order]`](https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2023/n4950.pdf)).

Hardware barriers are architecture-specific: AMD64 exposes `LFENCE`, `SFENCE`,
and `MFENCE` with different effects; Arm has its own barriers and
load-acquire/store-release instructions. In C++, code should normally request
C++ ordering and let the compiler select the necessary instructions
([AMD64 APM, volume 1, section 3.9.2](https://docs.amd.com/api/khub/documents/sfvvekC9mDflu6vd3R0NXA/content),
[Arm A64 ISA](https://developer.arm.com/documentation/ddi0602/latest/)).

## Acquire, release, and CAS in C++

A release operation `A` on an atomic object synchronizes with an acquire
operation `B` only when `B` obtains its value from the release sequence headed
by `A`. Evaluations before `A` then happen before evaluations after `B`. That is
the publication C++ defines—not “flush every store” or “process every
invalidation”
([C++23 working draft N4950, `[atomics.order]` and
`[intro.races]`](https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2023/n4950.pdf)).

```cpp
std::string payload;
std::atomic<bool> ready{false};

// Producer
payload = "complete";
ready.store(true, std::memory_order_release);

// Consumer
if (ready.load(std::memory_order_acquire)) {
  use(payload);  // Well-defined read through the observed publication.
}
```

If the acquire reads the earlier `false`, it does not synchronize with the
producer. Furthermore, `relaxed` atomics remain indivisible for that atomic
object but do not order surrounding memory
([C++23 working draft N4950,
`[atomics.order]`](https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2023/n4950.pdf)).

`compare_exchange_weak` and `compare_exchange_strong` are CAS operations. On
success, CAS is an atomic read-modify-write operation; on failure, it only reads
and updates `expected`. C++ allows separate orders for success and failure. The
overload without an explicit order uses `seq_cst`; with a single `acq_rel`,
failure is `acquire`, and with a single `release`, failure is `relaxed`
([C++23 working draft N4950,
`[atomics.types.operations]`](https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2023/n4950.pdf)).

Consequently, “CAS + barriers” is not a general recipe. A `relaxed` CAS modifies
the object atomically but does not publish surrounding non-atomic data. A lock
commonly uses acquire on successful acquisition and release on unlock, but a
complete algorithm includes an argument for failure ordering, retry behavior,
lifetime, and progress. C++ also does not guarantee that every
`std::atomic<T>` is lock-free;
`is_lock_free` and `is_always_lock_free` expose that property
([C++23 working draft N4950, atomics and the lock-free
property](https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2023/n4950.pdf)).

## False sharing and 128 bytes

False sharing occurs when threads modify distinct objects that occupy the same
coherence unit, causing ownership and invalidation traffic despite there being
no logical sharing. Multiple readers without writes do not produce the same
ping-pong. Intel defines the problem as one thread's data occupying the same
cache line as different data used by another thread
([Intel Optimization Reference Manual, section 8.4.5](https://cdrdv2-public.intel.com/821612/248966-Optimization-Reference-Manual-V1-050.pdf)).

128 bytes is not a universal rule. Older Intel guidance mentions 64-byte lines
and 128-byte sectors on specific Pentium 4 and Xeon processors. A documented
Cortex-X1 reports its smallest data-cache line as 16 words, or 64 bytes. Identify
the concrete target
([Intel Optimization Reference Manual, section 8.4.5](https://cdrdv2-public.intel.com/821612/248966-Optimization-Reference-Manual-V1-050.pdf),
[Arm Cortex-X1 Technical Reference Manual](https://developer.arm.com/documentation/101433/latest/)).

C++ provides `std::hardware_destructive_interference_size`: the
implementation-defined minimum separation recommended between concurrently
accessed objects to avoid additional contention. It expresses intent better
than the magic number 128, but can affect layout and ABI. Padding increases
footprint and may worsen cache and TLB behavior; apply it to hot writers only
after measurement
([C++23 working draft N4950,
`[hardware.interference]`](https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2023/n4950.pdf),
[WG21 P1119R0, ABI implications](https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2018/p1119r0.html)).

Treat the interference size as an implementation-defined expression of intent,
not as a portable ABI constant. Prefer ownership partitioning, write batching,
and layout separation before padding. Do not make a public ABI or persistent
format depend on the value without separately fixing and governing that layout.

## Candidate measurement practice

Everything in this section is advisory. A future governed contract would need
to select exact identities, thresholds, methods, owners, and evidence rather
than inheriting them from this research note.

### What can and cannot be guaranteed

No coding rule can guarantee a universally acceptable number of cache misses.
Compulsory misses are unavoidable, cache capacity and topology differ by CPU,
hardware prefetchers change the observed cost, and the same miss rate can be
cheap or disastrous depending on memory-level parallelism and where the data is
served from. The enforceable guarantee is narrower:

> On an exact Reference Hardware Profile, with an identified Application
> Release and exact Reference Workload Profile, named cache and memory-cost
> metrics remain inside separately approved budgets and do not regress beyond
> a separately approved tolerance.

A future contract should therefore budget **cost and user-visible outcome**,
not only a raw miss count. A useful diagnostic set for each measured phase or
Measured Real-Time Hot Loop includes:

- instructions, cycles, and IPC;
- L1 data-cache misses and last-level-cache misses, normalized as misses per
  thousand instructions (MPKI);
- miss rate alongside MPKI, because either metric alone can mislead;
- memory-bound or stalled-cycle measures supported by the target PMU;
- local/remote memory traffic and cache-to-cache transfers where NUMA or
  contention is relevant;
- memory bandwidth; and
- the corresponding frame, Canonical Tick, or task latency distribution,
  especially tail latency.

Generic events such as `cache-misses` are useful for trends but do not map to
identical hardware events on every processor. A future governed metric would
need to name the CPU model, event names or raw encodings, profiler version,
multiplexing state, and collection method. Vendor manuals own the event semantics
([Intel Performance Monitoring Events](https://perfmon-events.intel.com/),
[AMD uProf performance-monitoring counters](https://docs.amd.com/r/en-US/57368-uProf-user-guide/4.2.-Performance-Monitoring-Counters-PMC)).

### Candidate engineering heuristics

1. **Optimize only measured hot paths.** Start with a regression, insufficient
   margin to a temporal NFR, or a specific optimization hypothesis. Confirm by
   profiling that cache or memory behavior contributes materially before
   changing layout, padding, prefetching, affinity, or page policy.
2. **Keep hot working sets small.** Separate hot fields from cold metadata;
   avoid pulling debug, ownership, strings, or rarely used state into every hot
   cache line.
3. **Prefer predictable contiguous traversal.** Use compact storage and stable
   iteration order where ownership and lifetime permit. Treat AoS versus SoA as
   a measured choice based on which fields each loop consumes.
4. **Avoid pointer-chasing in measured loops.** Indirection can defeat spatial
   locality and hardware prefetching. Replace it only when the alternative
   preserves correctness, ownership, and update costs.
5. **Block work to fit the target cache.** Tile large transforms so reused data
   stays near the executing core. Derive tile sizes from element size and the
   target cache rather than a universal constant.
6. **Partition writes by owner.** Give each worker disjoint writable regions,
   batch publication, and merge at an explicit boundary. Avoid shared counters
   and queues in inner loops.
7. **Treat false sharing separately from capacity misses.** Use cache-to-cache
   analysis to identify line ping-pong. Pad or realign only independently hot
   writers after considering ownership partitioning, write batching, and layout
   separation. Treat `std::hardware_destructive_interference_size` as an
   implementation-defined intent signal and validate the footprint, ABI, and
   measured result.
8. **Preserve stable execution locality.** Excessive migration can cold-start
   private caches and make NUMA access remote. Consider affinity, scheduler
   partitioning, or page placement only after measuring migrations and locality
   and showing that the change improves target workloads without harming load
   balance or platform parity.
9. **Prefetch last.** Hardware prefetchers already handle many regular patterns.
   Software prefetch can waste bandwidth, evict useful lines, or fetch too early
   or late; retain it only with a benchmarked benefit on every supported target.
10. **Do not trade correctness for locality.** Data races, invalid lifetimes,
    weakened atomics without a `happens-before` proof, and unowned shared state
    are unacceptable even when a microbenchmark becomes faster.

These candidate practices do not restate or amend the project C++ baseline.
That baseline remains authoritative for the Measured Real-Time Hot Loop,
shared mutable state, atomic ordering, and lock-free review.

### Candidate measurement process

1. **Define the experiment.** Pin the build, compiler options, hardware/firmware,
   OS, power policy, workload data, thread count, affinity policy, warm-up, and
   measured interval. Separate loading from steady-state execution.
2. **Establish a repeatable baseline.** Use an optimized build with symbols.
   Run enough independent samples to expose variance; retain raw results rather
   than only an average.
3. **Start broad.** Measure cycles, instructions, cache references/misses,
   context switches, CPU migrations, page faults, bandwidth, and application
   latency. Verify whether counters were multiplexed or unavailable.
4. **Localize the cost.** Attribute samples to functions, source lines, call
   stacks, threads, and NUMA nodes. Distinguish demand misses, bandwidth
   saturation, TLB pressure, and cache-line contention before choosing a fix.
5. **Change one hypothesis at a time.** Examples include hot/cold splitting,
   tiling, a layout change, write partitioning, or removing an indirection.
6. **Compare both performance and invariants.** Re-run correctness tests,
   sanitizers, the exact Reference Workload Profile, and PMU collection. Reject wins
   that merely move cost to another phase or worsen tail latency, memory use,
   or another Reference Hardware Profile.
7. **Gate regressions at the right tier.** Microbenchmarks can provide rapid
   trend detection but are not acceptance evidence. A future gate would need
   exact target hardware, controlled workloads, and statistically reviewed
   tolerances.
8. **Retain reproducibility inputs.** A candidate investigation can retain raw
   counter output, profiler capture, build and workload identity, environment
   metadata, summary statistics, and the decision that accepted or rejected the
   change. Formal evidence content, ownership, acceptance, and retention remain
   governed elsewhere.

### Tooling

This table is illustrative and non-exclusive. The official sources were
reviewed on the research date; the table does not admit any tool as Sacramento
acceptance infrastructure. Where a source exposes a version, the reviewed
material is VTune 2024.0 documentation and AMD uProf 5.3 documentation.

| Platform or purpose | Tool | Recommended use | Important limitation |
| --- | --- | --- | --- |
| Debian/Linux baseline and regression | `perf stat` | Repeatable event counts and derived ratios for a complete workload or selected interval | Generic events vary by PMU; inspect unsupported and multiplexed counters. |
| Linux hotspot attribution | `perf record` / `perf report` / `perf annotate` | Attribute sampled events to functions, call paths, and instructions | Control the sampling period and symbols. |
| Linux false sharing and NUMA | `perf c2c` and `perf mem` | Find cache-line contention, HITM-style transfers, and memory-access locality where supported | Event support is CPU-specific and may require privileges. |
| Intel target analysis | Intel VTune Profiler, Memory Access analysis | Identify memory-bound hotspots, cache behavior, bandwidth, NUMA placement, and data sharing | Conclusions and event availability are target-specific. |
| AMD target analysis | AMD uProf | Collect AMD PMU events and analyze cache, memory, bandwidth, and NUMA behavior | Use the guide and event definitions for the exact processor family. |
| Windows target collection | Windows Performance Recorder/Analyzer with hardware-counter profiles | Correlate PMCs with ETW scheduling, CPU sampling, and application intervals | Available counters and sampling configuration depend on the CPU and Windows configuration. |
| Reproducible instruction profiling and basic cache simulation | Valgrind Cachegrind | Compare instruction counts and, with cache simulation enabled, explore algorithm or layout hypotheses | Its cache model is basic, is not the target CPU, and does not model all prefetch or coherence behavior; multithread scheduling can still vary. |
| Debian/Linux race detection | Clang ThreadSanitizer | Detect many data races while exercising instrumented concurrent tests | It neither measures cache misses nor proves that all schedules are race-free; Clang does not list Windows as a supported target. |

The Linux kernel `perf` documentation defines `perf stat` counting and the
`perf c2c` shared-data analysis workflow
([perf stat](https://man7.org/linux/man-pages/man1/perf-stat.1.html),
[perf c2c](https://man7.org/linux/man-pages/man1/perf-c2c.1.html),
[perf mem](https://man7.org/linux/man-pages/man1/perf-mem.1.html)).
Intel's Memory Access analysis and AMD uProf provide vendor-specific PMU
interpretation
([Intel VTune Memory Access](https://www.intel.com/content/www/us/en/docs/vtune-profiler/user-guide/2024-0/memory-access-analysis.html),
[AMD uProf](https://www.amd.com/en/developer/uprof.html)). Microsoft documents
hardware-counter profiles for Windows Performance Recorder
([WPR PMU event recording](https://learn.microsoft.com/en-us/windows-hardware/test/wpt/recording-pmu-events)).
Cachegrind's own manual describes its cache simulation and branch-prediction
model, and Clang documents ThreadSanitizer's supported platforms and limitations
([Valgrind Cachegrind](https://valgrind.org/docs/manual/cg-manual.html),
[Clang ThreadSanitizer](https://clang.llvm.org/docs/ThreadSanitizer.html)).

A useful Linux exploratory command is:

```sh
perf stat -r 10 \
  -e cycles,instructions,cache-references,cache-misses,context-switches,cpu-migrations,page-faults \
  -- ./target-workload --fixed-input
```

This is a starting point, not a portable acceptance command. A future approved
gate would need to replace generic events with a reviewed target-specific event
set and bind the exact workload and measurement interval.

### Review checklist

- Is the user-visible or runtime budget that motivates the change named?
- Are the exact workload, phase, build, CPU, event set, and profiler version
  recorded?
- Are MPKI, miss rate, stall/cost metrics, and application tail latency shown
  together?
- Was false sharing distinguished from capacity, conflict, compulsory, TLB, and
  NUMA effects?
- Does the profile identify the responsible code and data layout?
- Does the change preserve ownership, lifetime, synchronization, and ABI?
- Was it tested on every affected Reference Hardware Profile?
- Are the raw results and a repeatable command or capture configuration retained?

## Primary sources

- [ISO/IEC 14882:2024, Programming languages — C++](https://www.iso.org/standard/83626.html).
- [Final C++23 Working Draft N4950, 2023-05-10](https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2023/n4950.pdf).
- [Intel 64 and IA-32 Software Developer's Manuals](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html).
- [Intel Optimization Reference Manual, volume 1, revision 050](https://cdrdv2-public.intel.com/821612/248966-Optimization-Reference-Manual-V1-050.pdf).
- [AMD64 Architecture Programmer's Manual, volume 1](https://docs.amd.com/api/khub/documents/sfvvekC9mDflu6vd3R0NXA/content)
  and [volume 2](https://docs.amd.com/api/khub/documents/sD1_QL~h4Afq2_tvzxqqSQ/content).
- [Armv8-A Memory Model](https://developer.arm.com/-/media/Arm%20Developer%20Community/PDF/Learn%20the%20Architecture/Armv8-A%20memory%20model%20guide.pdf?revision=58b1dd0a-3800-4218-b21a-f95a0332034c).
- [Arm A-profile A64 ISA](https://developer.arm.com/documentation/ddi0602/latest/).
- [WG21 P1119R0](https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2018/p1119r0.html).
