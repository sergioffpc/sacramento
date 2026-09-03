# Architecture specification: runtime ownership and bounded failure

Status: Accepted

Purpose: Define runtime execution domains, exclusive ownership, scheduling,
atomicity, capacity, and bounded failure containment.

Scope: Session Authority and Trainee Client concurrency and failure semantics;
detailed threading and queue APIs remain outside this decision.

Intended readers: Architects, designers, implementers, and verification
authors.

Prerequisites: ADR-0004, ADR-0005, and the approved functional,
non-functional, observability, and verification baselines.

Canonical information owner: Project owner.

Amendment: ADR-0008 replaces client recovery and defines retained-evidence seams.

Amendment: ADR-0009 makes production AUTH durability and recovery future-baseline obligations while retaining their seams and failure invariants.

## Context

ADR-0004 assigns canonical responsibility and ADR-0005 defines the fixed-step
authority. Those decisions still need execution boundaries that prevent slow
clients, audit storage, observability, assessment, or presentation from
blocking canonical simulation work or creating split ownership.

ADR-0008 makes live state ephemeral, gives retained evidence explicit owners,
and replaces client recovery with irreversible Technical Removal.

## Decision

### Execution-domain view

The Session Authority process contains isolated execution domains for Session
Lifecycle, Simulation, Scenario, Protocol & Replication, and AUTH & Admission.
The Trainee Client process contains Presentation, Input & Interaction, and
client-side Protocol & Replication domains. Durable audit, evidence export,
observability, and the Trainee Performance Assessment Module operate outside the Canonical
Tick through bounded adapters.

These are responsibility and scheduling boundaries, not prescribed operating
system processes, threads, services, databases, queues, or deployment products.

### Exclusive ownership

| Owner | Exclusively mutable state |
| --- | --- |
| Session Lifecycle | Training Session phase, Operational Clock deadlines, Ready state, Technical Removal, and lifecycle reconstruction events |
| Simulation | Canonical world state, Simulated Time, canonical tick index, physical outcomes, injuries, and item state |
| Scenario | Objective progression, configured duration, empty-Team and other Scenario result rules, and resolved terminal result |
| Protocol & Replication | Connection state, ingress validation, intention envelopes, acknowledgement state, replication baselines, and delivery cursors |
| AUTH & Admission | AUTH Attempt and Operation state, identity bindings, Admission lifecycle, and AUTH Audit Commit Units |
| Presentation | Rendered and audio state derived from immutable published views |
| Input & Interaction | Raw device input and client-local intention construction |
| Trainee Performance Assessment Module | Identity-bound assessment events, measures, results, approvals, corrections, and retained history |

No owner mutates another owner's state directly. Cross-owner requests are
validated messages carrying stable identity, source revision, target session,
and idempotency key where retry is possible.

### Handoffs and immutable views

An owner publishes an immutable view only after committing its revision. A
consumer either accepts a complete compatible view or retains its preceding
view; it never observes a partially populated replacement. References are
revision-bound and cannot silently resolve to newer content.

Mutable staging remains private to its owner. Published views may be retained
only for an explicit bounded consumer need, except for durable records governed
by ADR-0008. Consumers acknowledge or release obsolete views so process memory
does not grow without bound.

### Scheduling and permitted waits

The Canonical Tick may wait only at declared in-process commit fences needed to
produce one atomic authoritative result. It never waits for:

- client rendering, audio, prediction, or acknowledgement;
- network delivery to a slow or disconnected client;
- observability export;
- Trainee Performance Assessment Module persistence;
- ordinary reconstruction-record export; or
- external evidence indexing or reporting.

AUTH & Admission may wait for durable completion of the exact AUTH Audit Commit
Unit before publishing a granting AUTH effect. Terminal Settling may wait for
the bounded durable final Session Evidence Set handoff required by ADR-0008.
Neither exception occurs inside a Canonical Tick.

### Cross-owner atomicity

Multi-owner outcomes use prepare, owner-local commit, and publication fences:

- Admission becomes visible only after required identity checks and its audit
  commit complete;
- initial activation publishes roster placement and active state as one
  canonical transition;
- a Technical Removal atomically ends the Admission, removes play authority,
  withdraws associated items, records cause `Disconnected`, updates affected
  Scenario state, and publishes one resulting canonical revision;
- Scenario completion resolves its terminal result before Session Lifecycle
  enters terminal settlement; and
- the final Session Evidence Set manifest binds the exact terminal result and
  reconstruction boundary before the durable handoff receipt is accepted.

Retryable external writes use candidate identity, content hash, idempotency key,
and atomic commit identity. A retry can complete the same candidate but cannot
create a second accepted record. On startup, each adapter deterministically
classifies incomplete or corrupt candidates and never exposes them as committed
truth.

### Capacity and backpressure

Each ingress path has an explicit capacity and overflow policy:

| Path | Overflow behavior |
| --- | --- |
| Raw pre-Admission traffic | Reject or discard before it creates canonical work |
| Admitted intentions | Reject excess or late intentions under the Runtime Execution Profile; never reorder accepted work by arrival time |
| Replication to a slow client | Coalesce obsolete unsent views or require a new baseline; confirmed connection loss invokes the phase-appropriate departure or Technical Removal rule |
| Presentation | Drop obsolete unpublished frames; never mutate canonical state |
| Observability | Buffer within bounds, then emit explicit loss accounting; never block the tick |
| Assessment and ordinary evidence export | Buffer within bounds, retry idempotently, and expose lag or incomplete evidence without feeding back into Simulation |
| AUTH audit | Fail closed for granting effects until durable capability is restored and validated |

### Failure containment

An isolated client failure affects only that client. Before Active it ends the
Admission and releases preparation state. During Active it creates one
Technical Removal and the remaining simulation continues. The removed Trainee
cannot reconnect or rejoin that Training Session.

A failure inside Simulation, Scenario, Session Lifecycle, or authoritative
commit integrity terminates the Training Session because canonical correctness
can no longer be established. Protocol ambiguity affecting the identity of the
authority or the ability to classify connections also terminates rather than
guessing.

Observability, assessment, and ordinary evidence-export failure do not alter
canonical outcomes. They surface explicit degraded, lagging, incomplete, or
failed states with loss accounting. Terminal handoff failure produces a
non-clean process result after the admitted bound; it does not extend or restore
the Training Session.

### Startup, shutdown, and process loss

Startup validates and activates all launch-bound profiles, content, trust
references, capacities, and durable adapters before readiness. No partial
activation is externally visible.

Shutdown stops new ingress, settles owner work in dependency order, resolves the
terminal result, seals the Session Evidence Set, obtains its durable handoff
receipt or records a bounded non-clean result, releases live state, and exits.
Process loss discards all live Training Session state. Recovery applies only to
durable audit, evidence, observability, and assessment candidates; it never
recreates an Admission or canonical live session.

## Considered options

- Shared mutable state across responsibilities was rejected because it obscures
  authority and makes partial failure non-deterministic.
- One unbounded queue per subsystem was rejected because a slow consumer could
  exhaust memory or feed back into authoritative timing.
- Blocking the Canonical Tick on every durable consumer was rejected because it
  couples gameplay progress to unrelated storage and reporting systems.
- Restarting or restoring a live Training Session was rejected because retained
  evidence is not a checkpoint.
- Treating client loss as whole-session failure was rejected because Technical
  Removal can safely contain the loss while preserving the exercise.

## Consequences

Implementations must expose owner revisions, immutable handoff contracts,
capacity limits, loss accounting, idempotent durable candidates, and deterministic
recovery classifications. The architecture permits later topology choices
without changing semantic ownership.

## Trace

This decision supports `REQ-AUTHORITY-001`, `REQ-STATE-CONSISTENCY-001`,
`REQ-SESSION-DISCONNECT-001`, `REQ-TECHNICAL-REMOVAL-001` through
`REQ-TECHNICAL-REMOVAL-006`, `REQ-AUTH-AUDIT-COMMIT-001`,
`REQ-AUTH-AUDIT-WRITE-FAILURE-001`, `REQ-SESSION-EVIDENCE-001` through
`REQ-SESSION-EVIDENCE-006`, `PERF-PERSISTENCE-001`,
`PERF-TECHNICAL-REMOVAL-001`, `NFR-OBSERVABILITY-CORE-001`, and
`NFR-OBSERVABILITY-INTEGRITY-001`.
