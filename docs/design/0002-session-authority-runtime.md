# SDD-0002: Session Authority Runtime

Status: Candidate successor design; project-owner approval pending

Last meaningful change: 2026-09-05

Purpose: Define the exact composition, startup, concurrency, readiness,
shutdown, ownership, and acceptance design for one Session Authority process
and its single Training Session.

Scope: Role launch view, owner interfaces, preparation, endpoint publication,
Training Session preparation, execution domains, and terminal settlement.

Intended readers: Authority designers, implementers, verification authors,
operators, and evidence custodians.

Required reviewers: Runtime-design reviewer and verification-design reviewer.

Prerequisites: SDB-002, SDD-0001, SAD-003, ARCHSPEC-0005, ARCHSPEC-0006,
ARCHSPEC-0008, ARCHSPEC-0009, ARCHSPEC-0012, and the requirements traced by
`DC-AUTHORITY-*` in `SDB-002-DC`.

Canonical information owner: Session Authority composition.

## Goals, boundary, and ownership

The composition makes one complete Authority closure ready without acquiring
module-private state. It does not own simulation, scenario, AUTH, admission,
replication, content, Observability, or settlement truth; it owns only whole-
process ordering and handoff between their semantic owners.

Each owner implements one deep lifecycle interface:

| Operation | Caller / provider | Ownership, lifetime, blocking, and failure |
| --- | --- | --- |
| `validate(view)` | composition / semantic owner | Borrows immutable typed view for the call; no effect; bounded; returns one closed failure or success. |
| `prepare(view, capacity, adapters)` | composition / owner | Borrows inputs; returns failure or one move-only `PreparedOwner`; cancellable only at the adapter boundaries it declares. |
| `commit(PreparedOwner&&)` | composition / owner | Consumes the handle; non-blocking, non-throwing, allocation-free, and infallible after successful prepare; returns `CommittedOwner`. |
| `stop(reason)` | canonical coordination / committed owner | Non-blocking and non-throwing; enqueues only into pre-reserved owner capacity; returns closed `Accepted` or `AlreadyStopping`; every later call returns `AlreadyStopping`. It has no failure result. |
| `settle()` | canonical coordination / applicable owner | Bounded by the launch-selected settlement policy; returns a closed receipt or failure without undoing a canonical commit. |
| destruction | composition / either handle | Prepared destruction reverses its effects; committed destruction releases resources only after stop/settle, in reverse dependency order. |

Native adapters enter only through the executable composition root. The role
view is SDD-0001's exact Authority launch map; absence and applicability are
schema decisions rather than a universal option bag.

## Startup and readiness

The exact preparation dependency order is:

1. Process Control and Observability;
2. Runtime Package and Content Admission;
3. Simulation and Scenario;
4. AUTH & Admission;
5. Protocol & Replication;
6. Session Lifecycle candidate.

After all six prepare successfully, the composition performs SDD-0001 phase 4:
it materializes private resources and binds the selected endpoint in a
nonaccepting state. Bind failure is still reversible and occurs before any
semantic-owner commit. It then commits the six owners in the same order,
creates and commits exactly one Training Session Preparation/Lifecycle Revision,
publishes the complete Ready frame, and only then enables accept.

The Preparation record binds Process Execution, launch, Application Release,
Runtime Content Release, Authority Pack, compatibility/profile/configuration,
endpoint, Scenario, Training Session, AUTH mode, Observability Contract, owner-
closure, and capacity identities. Ready publication failure after that canonical
commit creates the applicable terminal revision and settlement; it never erases
Preparation. Endpoint bind never permits connection or Admission before Ready.

## Execution, data, and failure

Logical domains are Process Control I/O, canonical coordination, transport I/O,
retained-evidence export, and Observability. Canonical coordination is the sole
sequential caller of Authority state. Other domains exchange immutable bounded
messages and cannot callback into canonical mutation. Memory is attributed by
semantic owner and lifetime, not worker or CPU affinity. Terminal control
capacity is independent of evidence and diagnostics.

Shutdown stops Admission and new Intentions, fences the current Canonical Tick,
commits terminal truth, obtains the required settlement receipt or terminal
settlement failure, then releases owners in reverse order and finally releases
the endpoint. Publication failure cannot roll back a canonical commit. Process
loss follows the accepted ephemeral-session rules.

## Design commitments

- `DC-AUTHORITY-001`: Authority MUST commit exactly one Training Session
  Preparation/Lifecycle Revision before Ready.
- `DC-AUTHORITY-002`: Authority MUST prepare and commit semantic owners in the
  declared dependency order through typed views and move-only handles.
- `DC-AUTHORITY-003`: Authority MUST complete nonaccepting endpoint bind before
  owner commit and keep it nonaccepting until Ready publication completes.
- `DC-AUTHORITY-004`: shutdown MUST fence canonical work and preserve terminal
  settlement before reverse release.
- `DC-AUTHORITY-005`: only canonical coordination MUST invoke Authority state
  transitions.
- `DC-AUTHORITY-006`: terminal control capacity MUST remain available
  independently of Observability and evidence-export pressure.
- `DC-AUTHORITY-007`: every Authority owner MUST implement the exact lifecycle
  interface semantics declared by this SDD.
- `DC-AUTHORITY-008`: Authority MUST accept only the exact closed launch view
  and single-session identity closure declared by SDD-0001.
- `DC-AUTHORITY-009`: a failure after canonical Preparation commit MUST preserve
  that commit and produce the applicable terminal revision and settlement.

## Rationale and trade-offs

Binding before commit removes the previously ambiguous failure window: an
unavailable endpoint now fails while rollback remains possible. Keeping the
socket nonaccepting until Ready prevents a peer from observing a process that
the executor still considers unready. A compensating rollback after canonical
commit was rejected because it would rewrite retained truth. One canonical
coordination domain was selected instead of locks around every owner because it
gives one deterministic transition order; I/O remains concurrent through
bounded handoffs without acquiring mutation authority.

| Commitments | Rationale allocation |
| --- | --- |
| `DC-AUTHORITY-001`, `DC-AUTHORITY-009` | Preserve the exact canonical preparation and terminal history even when later publication fails. |
| `DC-AUTHORITY-002`, `DC-AUTHORITY-007` | Concentrate resource lifetime and rollback behind one testable owner interface. |
| `DC-AUTHORITY-003` | Eliminate post-commit bind failure and pre-ready peer observation. |
| `DC-AUTHORITY-004` | Preserve terminal truth and durable settlement before destroying its producers. |
| `DC-AUTHORITY-005` | Establish one deterministic writer for canonical state. |
| `DC-AUTHORITY-006` | Prevent diagnostic or evidence backpressure from suppressing termination. |
| `DC-AUTHORITY-008` | Prevent ambient selection and a second session from entering the process closure. |

## Acceptance criteria

Evidence retains the exact Authority launch bytes, ordered owner/effect trace,
state frames, endpoint observations, canonical revisions, settlement receipt or
failure, queue high-water marks, process exit, and executable identity.

| Criterion | Preconditions and stimulus | Required and prohibited observation |
| --- | --- | --- |
| `DAC-AUTHORITY-001` | Valid closure; observe every startup boundary. | Exactly one Preparation precedes Ready and binds the complete listed identity closure. |
| `DAC-AUTHORITY-002` | Fail each owner prepare; request cancellation at every permitted boundary; observe immediately before/after each commit; inject a conformance-violating commit throw separately. | Prepare/commit order is exact; pre-commit cleanup is reverse; cancellation is not sampled during the commit sequence; a throwing commit produces InternalFailure without rollback of preceding commits; no skipped or duplicate owner. |
| `DAC-AUTHORITY-003` | Inject bind failure, connection attempts before/during Ready publication, partial positive-progress writes, and terminal write error after a strict Ready prefix. | Bind precedes commit; bind failure rolls back; partial writes assemble the complete frame; a terminal publication error preserves Preparation and starts terminal handling; zero accepts occur until the complete Ready frame is published. |
| `DAC-AUTHORITY-004` | Request shutdown at each Canonical Tick boundary and inject settlement success/failure. | New work stops, one Tick fence occurs, terminal truth and settlement precede reverse release. |
| `DAC-AUTHORITY-005` | Invoke every transition from each execution domain. | Canonical caller succeeds in order; every callback or foreign-domain mutation is rejected without state change. |
| `DAC-AUTHORITY-006` | Fill evidence and Observability queues, then request shutdown and force terminal output. | Control and terminal records complete within selected bounds; no ordinary queue consumes reserved slots. |
| `DAC-AUTHORITY-007` | Run the shared lifecycle suite for every real owner and test double at min/max capacities. | Operations satisfy the table, commit allocates/blocks/throws zero times, and doubles expose no extra behavior. |
| `DAC-AUTHORITY-008` | Mutate each Authority launch key, omit it, add unknown key, or provide a second session. | Each invalid closure rejects before bind/Preparation; exactly one valid session closure reaches Ready. |
| `DAC-AUTHORITY-009` | Fail Ready publication and later export after Preparation commit. | Preparation remains unchanged; exactly one terminal revision and settlement outcome follow; no rollback or second session. |
