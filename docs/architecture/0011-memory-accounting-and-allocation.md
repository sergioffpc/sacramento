# Architecture specification: memory accounting and allocation

Status: Accepted architecture decision; implementation, numeric budgets, and
evidence remain incomplete

Approval: Project owner, 2026-09-04

Purpose: Define how Sacramento measures, attributes, budgets, allocates, and
releases CPU and GPU memory without selecting a concrete allocator library.

Scope: The real-time `Trainee Client Runtime` and `Session Authority Runtime`.
The Content Cooker Runtime, Administrative Tool Runtimes, concrete APIs,
source layout, libraries, numeric limits, and operational dashboards remain
outside this decision.

Canonical information owner: Project owner.

Intended readers: Architects, designers, implementers, performance engineers,
verification authors, and reviewers.

Prerequisites: `CONTEXT.md`, the technical and governance glossaries, ADR-0003
through ADR-0011, `CPP-ENGINEERING-BASELINE-004`, `NFR-BASELINE-001`,
`OBS-CONTRACT-003`, `RHP-SET-001`, and the Verification Plan.

Sacramento begins with observable memory ownership rather than an elaborate
allocator hierarchy. Accounting follows the existing responsibility model;
allocation policy follows measured lifetime and access patterns. The design
preserves the fixed-step authority, reserved reconstruction evidence,
nonblocking Observability, immutable launch configuration, bounded failure,
and native-platform acceptance decisions already in force.

## Quantities and accounting model

The following quantities are distinct and retain their units and provenance:

| Quantity | Meaning | Attribution |
| --- | --- | --- |
| Requested live bytes | Bytes requested by successful allocations not yet released | Exact Memory Accounting Owner, Memory Lifetime Domain, and memory resource |
| Allocator capacity | Address ranges or backing blocks retained by one allocator, including free and metadata capacity | Memory resource and, where the resource can report it without ambiguity, its bounded owner/lifetime partitions |
| Process private commit | Private backing accepted for the process by the operating system | Process-level sample plus known private-mapping categories |
| Process resident memory | Process pages currently resident in physical memory | Separate process-level sample; never treated as the ownership ledger |
| GPU usage and budget | Driver-reported current usage and usable budget for one heap or segment | Device heap or segment and sampling identity |

No canonical gauge called `memory used` collapses these meanings. CPU and GPU
totals are not added into one exact value. Reserved virtual address space,
committed backing, residency, and requested bytes may legitimately differ.

Each wrapped CPU allocation has exactly one Memory Accounting Owner. The owner
is the canonical responsibility module that owns the associated state or
resource, or a runtime composition only for a resource it genuinely owns.
`Third Party` and `Untracked` are technical attribution classifications, not
semantic owners or new Sacramento modules. Shared consumption does not create
multiple charges; cross-owner movement is an immutable handoff or explicit
one-source-to-one-recipient ownership transfer.

Owner, Memory Lifetime Domain, memory resource, and optional budget identity
are orthogonal dimensions. They may be aggregated for a query but never fused
into a second product decomposition or into one physical heap per accounting
tag. Stable numeric identities are separate from display names.

## CPU memory-resource seam

Responsibility modules consume a small Sacramento-owned allocation seam.
Requests carry byte count and alignment; the Memory Resource Context supplies
owner, lifetime domain, resource identity, and applicable budget identity. The
seam states ownership, thread-safety, blocking, and failure behavior and
provides a stable Sacramento outcome when it cannot satisfy a request.

The seam validates supported nonzero power-of-two alignment and overflow-safe
size arithmetic. It returns suitably aligned storage or no storage. The
resource that created an allocation remains its deallocator; an ownership
transfer carries that identity. Memory never crosses a module, heap, dynamic
library, or CRT boundary and then gets released by a different mechanism.
Tracking metadata determines attribution on release without trusting the
caller to repeat a tag.

PMR, operating-system virtual memory, a general heap, and specialized
allocators remain private adapters. A PMR adapter may implement or consume the
Sacramento seam, but `std::pmr` and concrete allocator types do not become
responsibility-module interfaces. Zero-byte semantics, concrete handle types,
metadata layout, sharding, and synchronization remain reversible design.

## Asynchronous propagation

When asynchronous work, continuations, or execution on another thread exist,
the submitting owner captures an immutable Memory Resource Context in the work
payload. A continuation inherits that context unless an explicit ownership
transfer names one source and one recipient. Execution on another worker,
including work stealing, never changes attribution.

Thread-local state may cache a context for synchronous convenience but is
derived state and never attribution authority. This contract does not require
or select a job system, thread topology, or scheduling library.

## Memory Lifetime Domains and release fences

The initial domains are:

| Domain | Boundary and release rule |
| --- | --- |
| `Process Lifetime` | Immutable process configuration, registries, and adapters released in reverse dependency order during shutdown |
| `Startup Validation` | Materialization and validation state released after the complete runtime view is published or startup is rejected and cleaned up |
| `Admission` | Per-Admission state released at the exact Admission-ending event, including pre-active departure or Technical Removal |
| `Training Session` | Live session state released during terminal settling under the accepted shutdown order and discarded on forced process loss; never restored |
| `Canonical Tick Candidate` | Owner-private scratch reusable only after commit or rejection and release by every bounded consumer of that generation |
| `Presentation Frame` | Presentation scratch reusable only after every applicable CPU consumer and GPU fence has completed |
| `External Handoff` | Separately reserved bounded records and queues released after acknowledgement, explicit loss disposition, or expiry of the admitted retry bound |

A bulk reset requires a fence proving that no pointer, immutable view,
asynchronous I/O operation, or GPU command can still use that generation.
Canonical Tick reconstruction records move into separately reserved External
Handoff capacity before the corresponding result becomes visible; no exporter
retains a pointer into Canonical Tick Candidate storage.

`Loading` is not introduced as a lifecycle state or domain synonym. A generic
streaming lifetime is not part of this initial set. A later measured upload,
readback, or immutable-content transfer pattern may justify a bounded
fence-aware domain without changing the lifecycle language.

## Permanent accounting and Diagnostic detail

The following bounded counters remain enabled in test and production builds:

- current and peak requested bytes;
- current and peak live allocation count;
- cumulative allocated and freed bytes and counts;
- allocation-failure count by stable category;
- current and peak reserved capacity and committed backing where the resource
  can report them;
- discarded Diagnostic-event count by producer; and
- the owner, lifetime, and resource aggregates drawn from closed identity sets.

Their update path does not allocate recursively through the observed resource
and has no one globally contended mutex. Metadata and buffers have explicit
capacity and ownership. The exact sharding and synchronization mechanism is a
reversible design choice; lock-free code still requires measured benefit and
the C++ baseline's correctness review.

Detailed allocation events are Diagnostic: address, size, alignment, execution
context or thread, timestamp, source location, optional callstack, latency
distribution, remote-free behavior, fragmentation maps, and per-Canonical-Tick
or per-Presentation-Frame activity. Buffers are finite and never block a
Canonical Tick or Presentation Frame. Exhaustion discards Diagnostic events
and increments the applicable counter without corrupting permanent accounting.
A wrapped allocation never silently loses its owner because tracking failed;
overflow or mandatory-metadata inconsistency returns a stable outcome.

These counters do not amend the approved `OBS-CONTRACT-003` core catalogue.
`CoreOnly` carries their fixed measured runtime cost but emits no optional
memory signal. Snapshots, events, callstacks, and detailed profiling are
Diagnostic or verification-harness data. Their loss cannot change the meaning
of a core signal or create an acceptance `Pass`.

## Sampling, snapshots, and reconciliation

Process samples and Memory Snapshots occur at process start, after `Ready`, at
relevant Training Session transitions, during terminal settling, and during
shutdown. Configurable periodic sampling is Diagnostic only.

Reconciliation relates tracked requested bytes, allocator capacity and known
private mappings to process private commit. It reports process resident memory
separately. A signed discrepancy and explained categories are retained instead
of forcing equality. `Untracked` identifies an allocation path or residual for
which Sacramento has no reliable attribution; it never invents a semantic
owner. The first increment establishes its baseline and trend without an
acceptance threshold.

Every snapshot identifies the process execution, Application Release, Runtime
Launch Specification, configuration, active workload and profile versions,
phase or transition, owner/lifetime/resource dimensions, sampling source, and
loss or unavailable fields. An unavailable quantity is absent with a stable
reason, not recorded as zero.

## Memory budgets and failure

Each responsibility module owns the meaning and proposed limits for its
resources. Runtime composition aggregates and validates them but cannot
reinterpret them. The Runtime Launch Specification selects one immutable,
identified Memory Budget Configuration before startup validation. A record
declares owner, runtime, platform, tag, lifetime, controlled quantity,
supporting workload and phases, observed distribution or peak, headroom rule,
soft and optional hard limits, exceed actions, evidence version, and approval.

Numeric limits, headroom values, Untracked thresholds, and tracker-overhead
thresholds remain explicit evidence gaps. Reference Hardware Profile capacity
and a driver's changing GPU budget are observations, not Sacramento budgets.

Failure follows the resource class:

| Condition | Required outcome |
| --- | --- |
| Soft budget exceeded | Diagnostic and Memory Snapshot; an owner may begin eviction only for a resource already classified as elastic |
| Hard budget exceeded | Reject the new operation with a stable Sacramento outcome |
| Required startup capacity unavailable | `Not Ready`, complete cleanup, and non-zero exit |
| Admission capacity exhausted | Reject the new Admission without changing existing Admissions |
| Candidate canonical work cannot reserve its required capacity before commit | Reject the candidate without exposing a partial result |
| Complete reconstruction record cannot be preserved | Prevent result visibility and terminate the Training Session as the existing canonical-path integrity failure requires |
| Failure after canonical commitment prevents correctness | Apply the smallest accepted failure boundary that preserves canonical integrity |
| Diagnostic event capacity exhausted | Discard detail and increment explicit loss accounting |

Canonical state, mandatory reconstruction records, and required evidence are
never elastic. A cache is evictable only when its owner declares it
reconstructible and non-canonical with a bounded eviction contract. Memory
pressure cannot silently degrade visual or acoustic quality without a
separately approved quality tier.

## GPU memory

GPU allocation uses a separate seam private to `Presentation`; the CPU seam
does not allocate API resources. Presentation remains the Memory Accounting
Owner even when Simulation or content supplied an immutable source. A separate
purpose or origin dimension may preserve that relationship without splitting
ownership.

Accounting distinguishes logical resource bytes, physical API blocks or heaps,
free suballocated capacity, alignment and granularity waste, dedicated versus
suballocated resources, and bytes logically released but unavailable until the
last GPU fence. Driver usage and budget remain per heap or segment. Aliased
resources report logical and physical quantities separately.

The accepted Vulkan/Falcor direction remains authoritative. This decision does
not admit VMA, D3D12MA, another suballocator, a residency mechanism, or a
graphics dependency.

## Adoption evidence and benchmark hypotheses

The first increment adds visibility only to the Trainee Client Runtime and
Session Authority Runtime. It introduces no new budget enforcement or
specialized allocator beyond capacity behavior already required by accepted
architecture. Content Cooker and Administrative Tool Runtimes are outside this
increment.

That increment is a characterization step, not admission of a runtime that
violates the rules below. If visibility finds a general-purpose heap access in
a Measured Real-Time Hot Loop, the affected runtime remains nonconforming. The
trace then supplies the measured problem required to design and evaluate
pre-sizing, a bounded resource, or another subsequent remedy.

After `Ready`, no Measured Real-Time Hot Loop may allocate from the
general-purpose heap, grow allocator backing storage, or reach an upstream
fallback that does either. This includes the design-identified and
profiling-confirmed inner processing paths for Canonical Ticks, Presentation
Frames, real-time audio, and any other path that can affect an approved
temporal obligation. Required capacity is reserved before the loop. A bounded
scratch arena or pool may serve the loop only when it is already provisioned
and cannot grow or fall back to the general-purpose heap.

Outside those loops, general-purpose heap count and volume remain measured and
unjustified churn is removed. The architecture does not turn every syntactic
loop or all dynamic allocation into a zero-allocation requirement.

Specialization requires the following evidence:

- an arena requires measured temporary churn, one proved release fence, and a
  bounded high-water mark;
- a pool requires a dominant stable size, alignment, and lifetime class;
- size classes require a repeated distribution whose total benefit includes
  internal waste;
- preallocation requires a capacity derived from admitted content or immutable
  configuration and a measured real-time allocation or first-touch risk;
- a general-heap replacement requires reproducible end-to-end benefit without
  material retention, portability, diagnostic, or maintenance regression; and
- a GPU suballocator requires measured API-allocation, fragmentation,
  residency, or deferred-destruction pressure.

Evaluation runs the rendered Trainee Client natively on Windows and the Session
Authority natively on Debian. It covers exact five-minute `Typical` and
`Stress` runs, separate startup-through-shutdown phases, controlled burst and
release, over-alignment, remote frees, and exhaustion. Trace replay complements
but never replaces the real runtimes. Measurements include allocation latency
p50, p95, p99 and maximum; requested, capacity, private commit, resident and
fragmentation values; return after a burst; failures; deterministic outcomes;
and sanitizer and profiler compatibility.

An initial two-hour Diagnostic soak takes snapshots at 5, 30, 60, and 120
minutes. It is a benchmark hypothesis, not a Reference Workload Profile or
product requirement. Unexplained growth or failure to reach a stable plateau
blocks candidate selection pending investigation. Repetitions, fixed
environments, and alternated candidate order quantify measurement noise.

Always-on tracking is compared with an equivalent experimental control build,
while the product build must still pass the existing CoreOnly smoothness,
stall, and action-response obligations. The first evidence establishes whether
a separate overhead threshold is needed; this decision invents no percentage.
A platform-specific benefit requires the existing Platform Parity exception
process before divergent adoption.

## Stability and open evidence

Stable architecture comprises the quantity meanings, accounting dimensions,
Sacramento seam, explicit context propagation, lifetime domains and fences,
bounded tracking, permanent/Diagnostic split, immutable budget ownership,
failure matrix, separate GPU seam, evidence gate for specialization, and the
general-purpose-heap prohibition in Measured Real-Time Hot Loops.

Concrete signatures and types, metadata layout, sharding, synchronization,
sampling frequency, buffer capacity, arena generation count, snapshot encoding,
and visualization are reversible design. Numeric budgets and headroom,
Untracked and overhead thresholds, the need for each specialization, concrete
allocator and profiler choices, GPU suballocator choice, and soak duration
beyond the initial experiment remain hypotheses requiring execution evidence.

## Considered options and consequences

Direct PMR module interfaces were rejected because PMR does not carry
Sacramento ownership, budgets, GPU semantics, or stable failure outcomes. One
generic memory manager and a heap per accounting tag were rejected because
they would duplicate canonical ownership and strand capacity. Thread-local-only
attribution was rejected because scheduling and work stealing would change the
reported owner. Immediate allocator specialization was rejected because the
C++ baseline requires measured need.

Adding memory detail to the Observability core was rejected for the first
increment because formal acceptance requires the existing closed CoreOnly
signal set and stable costs. Treating hardware capacity or driver budget as an
approved limit was rejected because neither records workload evidence,
headroom, owner, nor failure action.

The architecture adds explicit context, accounting, snapshots, failure
contracts, and benchmark work. In exchange it keeps allocator mechanisms
replaceable, makes unattributed pressure visible, and prevents memory policy
from changing canonical ownership or evidence semantics.

## Trace

This decision supports `SCOPE-PRODUCT-001`, `REQ-STATE-CONSISTENCY-001`,
`REQ-SESSION-EVIDENCE-001`, `REQ-SESSION-EVIDENCE-002`,
`REQ-RUNTIME-LAUNCH-SPECIFICATION-001`,
`REQ-RUNTIME-LAUNCH-SPECIFICATION-002`, `REQ-RUNTIME-READINESS-001`,
`REQ-RUNTIME-EXTERNAL-LIFECYCLE-001`,
`REQ-AUTHORITY-TERMINAL-SHUTDOWN-001`,
`NFR-OBSERVABILITY-BUILD-PARITY-001`, `NFR-OBSERVABILITY-INTEGRITY-001`,
`NFR-DESKTOP-SMOOTHNESS-001`, `NFR-DESKTOP-STALL-001`,
`NFR-ACTION-RESPONSE-001`, `CONSTRAINT-NFR-TEAM-001`,
`CONSTRAINT-PLATFORM-MATRIX-001`, and `PREFERENCE-PLATFORM-PARITY-001`.
