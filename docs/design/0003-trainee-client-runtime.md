# SDD-0003: Trainee Client Runtime

Status: Candidate successor design; project-owner approval pending

Last meaningful change: 2026-09-04

Purpose: Define the exact composition, startup, connection, Admission,
departure, shutdown, ownership, and acceptance design for one Trainee Client.

Scope: Role launch view, owner interface, ProcessReady semantics, finite retry,
voluntary leave, execution domains, cleanup, and termination.

Intended readers: Client designers, implementers, verification authors,
operators, and device-adapter owners.

Required reviewers: Runtime-design reviewer and verification-design reviewer.

Prerequisites: SDB-002, SDD-0001, SAD-003, ARCHSPEC-0006, ARCHSPEC-0009,
ARCHSPEC-0012, and the requirements traced by `DC-CLIENT-*` in `SDB-002-DC`.

Canonical information owner: Trainee Client composition.

## Goals, boundary, and ownership

The composition prepares one exact local client closure and keeps process
readiness, connection, Admission, assignment, `TraineeReady`, and active
simulation distinct. It owns whole-process order but no module-private state or
Authority truth. Each owner implements the `validate`, `prepare`, `commit`,
`stop`, and destruction semantics in SDD-0002's lifecycle table; `settle` is
not applicable to client owners. Native adapters enter at the thin executable
root and no device or transport callback obtains cross-owner mutation authority.

The exact Client launch map is defined by SDD-0001. It selects one target
Training Session, expected Authority identity and endpoint, Client Pack,
profiles, devices, outputs, capacities, AUTH mode, Observability, retry policy,
departure-confirmation bound, and external destinations.

## Startup and state distinctions

Preparation dependency order is:

1. Process Control and Observability;
2. Runtime Package and Content Admission;
3. Prediction;
4. Presentation and required outputs;
5. Input & Interaction and required devices;
6. Protocol & Replication;
7. AUTH & Admission adapter.

The composition then materializes reversible resources, commits owners in the
same order, publishes Ready, and only then starts its first connection attempt.
Ready asserts only a complete local process closure. It does not assert
connection, authenticated Authority, Admission, assignment, `TraineeReady`, or
active simulation. Admission rejection remains an observable client state from
which launch-permitted user action or shutdown can proceed.

## Connection, departure, and failure

Before active simulation, each attempt uses only the selected endpoint and
expected Authority identity. A failed attempt can begin another Admission only
while both maximum-attempt and total retry bounds remain. Delay is computed
from SDD-0001's rational backoff with integer milliseconds rounded upward and
clamped to remaining total time. Discovery, fallback, endpoint change, and an
unbounded attempt are absent. Active simulation or Technical Removal permanently
closes retry and new Admission for this process.

Voluntary leave stops new Intentions, submits one correlation identity, and
reuses that identity for any transport duplicate until the selected confirmation
bound. Authority acknowledgement proves the authoritative commit. Timeout or
connection loss permits local shutdown but produces `DepartureUnconfirmed` and
does not claim Authority commit.

Logical domains are Process Control I/O, client coordination, transport I/O,
Prediction, Presentation/output, Input, and Observability. Immutable bounded
handoffs connect them. Post-ready control loss begins bounded non-normal
shutdown. Required capability loss follows the exact launch policy. Cleanup
stops owners then releases them in reverse dependency order; it never creates
or implies Authority-side state.

## Design commitments

- `DC-CLIENT-001`: Client MUST prepare and commit owners in the declared order
  before Ready and connection.
- `DC-CLIENT-002`: Client MUST keep process readiness, connection, Admission,
  assignment, `TraineeReady`, and active simulation as distinct states.
- `DC-CLIENT-003`: connection retry MUST be finite, launch-selected, and limited
  to the same endpoint before active simulation.
- `DC-CLIENT-004`: Admission rejection MUST NOT force process termination by
  itself.
- `DC-CLIENT-005`: voluntary leave MUST use one idempotent departure identity
  and distinguish confirmed commit from local expiry.
- `DC-CLIENT-006`: post-ready control loss MUST start bounded non-normal
  termination without channel replacement.
- `DC-CLIENT-007`: every Client owner MUST implement the applicable exact
  lifecycle interface semantics declared by SDD-0002.
- `DC-CLIENT-008`: Client MUST accept only the exact closed launch view and
  single endpoint/Authority identity closure declared by SDD-0001.
- `DC-CLIENT-009`: callbacks outside client coordination MUST NOT directly
  mutate another owner's state.
- `DC-CLIENT-010`: Client cleanup MUST stop and release owners in exact reverse
  dependency order without implying Authority state.

## Rationale and trade-offs

Ready precedes connection so the executor can distinguish a sound local process
from network and Admission outcomes. Admission rejection remains nonterminal so
the stable result can be presented without restarting a valid process. Finite
same-endpoint retry tolerates transient availability without turning the client
into a discovery or failover system. Authority confirmation is the only proof
of departure because local timeout cannot establish remote commit. Immutable
handoffs were selected over direct callbacks to keep owner state local and
ordering testable.

| Commitments | Rationale allocation |
| --- | --- |
| `DC-CLIENT-001`, `DC-CLIENT-007`, `DC-CLIENT-010` | Make resource ownership, readiness, and cleanup follow one reversible lifecycle. |
| `DC-CLIENT-002` | Prevent local process health from being mistaken for Authority or Trainee readiness. |
| `DC-CLIENT-003` | Tolerate bounded transient failure without introducing discovery or continuity claims. |
| `DC-CLIENT-004` | Preserve a valid local process and make a stable rejection visible to the user. |
| `DC-CLIENT-005` | Reserve Authority confirmation as the only proof of remote departure commit. |
| `DC-CLIENT-006` | Contain loss of the required lifecycle channel without inventing a replacement. |
| `DC-CLIENT-008` | Bind the client to one exact deployment-selected peer closure. |
| `DC-CLIENT-009` | Keep state ownership local and cross-domain ordering explicit. |

## Acceptance criteria

Evidence retains launch bytes, owner trace, state frames, connection/Admission
trace, departure correlation, monotonic retry timestamps, queue high-water
marks, presented stable outcome, process exit, and executable identity.

| Criterion | Preconditions and stimulus | Required and prohibited observation |
| --- | --- | --- |
| `DAC-CLIENT-001` | Fail each prepare/materialization and interrupt around each commit. | Exact forward prepare/commit and reverse cleanup; zero connection before complete Ready. |
| `DAC-CLIENT-002` | Stop after each state and independently vary connection, Admission, assignment, readiness. | Each state is separately observable; no transition implies another. |
| `DAC-CLIENT-003` | Exercise attempts 1..maximum, total-time edge, changed endpoint/identity, active state, and Technical Removal. | Only bounded same-target pre-active attempts occur; every prohibited retry is absent. |
| `DAC-CLIENT-004` | Return each stable Admission rejection. | Rejection is presented and process remains controllable; no automatic termination or partial Admission state. |
| `DAC-CLIENT-005` | Duplicate leave, confirm just before/at/after bound, lose connection. | One identity is used; only timely Authority confirmation reports committed; other exits report unconfirmed. |
| `DAC-CLIENT-006` | Inject every control failure after Ready at minimum shutdown bound. | Stopping and Terminated occur within the bound; channel is not reopened or replaced. |
| `DAC-CLIENT-007` | Run lifecycle suite for every real Client owner and double at min/max capacity. | All operations satisfy SDD-0002; commit blocks/allocates/throws zero times; doubles expose no extra behavior. |
| `DAC-CLIENT-008` | Omit/mutate every launch key and attempt discovery or fallback. | Invalid input rejects before prepare; valid client contacts exactly one selected endpoint and identity. |
| `DAC-CLIENT-009` | Invoke mutation from every device, transport, presentation, prediction, and Observability callback. | Callback can enqueue immutable bounded data only; direct mutation is rejected with unchanged owner state. |
| `DAC-CLIENT-010` | Terminate from every post-ready state and fail each stop operation. | Stop/release trace is exact reverse order; no client record claims remote commit without Authority confirmation. |
