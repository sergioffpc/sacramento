# SDD-0003: Trainee Client Runtime

Status: Candidate successor design; project-owner approval pending

Last meaningful change: 2026-09-05

Purpose: Define the exact composition, startup, connection, Admission,
departure, shutdown, ownership, and acceptance design for one Trainee Client.

Review focus: Changed runtime semantics and verification criteria under ADR-0014;
no fixed reviewer count or full-package reread is required for a routine edit.

Owner: Trainee Client composition.

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
same order, commits exactly one immutable Local Client Preparation, publishes
Ready, and only then starts its first connection attempt. The preparation binds
Process Execution, launch, Application Release, Runtime Content Release, Client
Pack, compatibility/profile/configuration, target Training Session, expected
Session Authority, endpoint, AUTH mode, Observability Contract, selected
device/output lists, owner-closure, and capacity identities. It is local process
truth and never claims Authority state. Ready asserts only a complete local
process closure. It does not assert
connection, authenticated Authority, Admission, assignment, `TraineeReady`, or
active simulation. Admission rejection remains an observable client state from
which launch-permitted user action or shutdown can proceed.

`DC-CLIENT-002` incorporates this closed participation state. Client
coordination owns it and exposes an immutable `snapshot()` through the same
coordination interface used by Presentation and verification. Each accepted
event commits exactly one next state before the snapshot changes:

| State | Exact meaning and permitted successor |
| --- | --- |
| `Disconnected` | No live connection; `Connecting` or `Stopping`. |
| `Connecting` | One bounded attempt in progress; `Connected`, `Disconnected`, or `Stopping`. |
| `Connected` | Expected peer identity validated; `AdmissionPending`, `Disconnected`, or `Stopping`. |
| `AdmissionPending` | One Admission request outstanding; `AdmissionRejected`, `AdmittedUnassigned`, `Disconnected`, or `Stopping`. |
| `AdmissionRejected` | Stable rejection retained with no Admission; `AdmissionPending` only by a launch-permitted user action, otherwise `Stopping`. |
| `AdmittedUnassigned` | Admission exists without assignment; `AssignedNotReady`, `Disconnected`, `TechnicallyRemoved`, or `Stopping`. |
| `AssignedNotReady` | Assignment exists but TraineeReady is false; `TraineeReady`, `Disconnected`, `TechnicallyRemoved`, or `Stopping`. |
| `TraineeReady` | Readiness is committed but active simulation has not begun; `ActiveSimulation`, `AssignedNotReady`, `Disconnected`, `TechnicallyRemoved`, or `Stopping`. |
| `ActiveSimulation` | Active participation; `DeparturePending`, `DepartureUnconfirmed`, `TechnicallyRemoved`, or `Stopping`; confirmed connection loss cannot return to retryable Disconnected. |
| `DeparturePending` | One voluntary-departure identity is outstanding; `DepartureConfirmed`, `DepartureUnconfirmed`, or `Stopping`. |
| `DepartureConfirmed` | Authority confirmation was validated by its deadline; `Stopping`. |
| `DepartureUnconfirmed` | Local deadline or connection loss occurred without timely confirmation; `Stopping`. |
| `TechnicallyRemoved` | Irreversible Technical Removal observed; `Stopping`. |
| `Stopping` | No new connection, Admission, assignment, readiness, retry, or intention; terminal cleanup only. |

Process readiness is the Process Control state and is not a second value in
this participation enum. `snapshot()` returns both values explicitly. A
ProcessReady observation never proves any participation state after
`Disconnected`; a participation state never proves ProcessReady unless the
separate Process Control field says so.

## Connection, departure, and failure

`DC-CLIENT-003` incorporates the following retry algorithm. Before active
simulation, each attempt uses only the selected endpoint and
expected Authority identity. Attempts are numbered from one; maximum attempts
includes the first. Let `t0` be the monotonic instant immediately before attempt
1 and `deadline = t0 + total_bound_ms`. Every connect operation receives that
deadline, is cancellable, and returns no later than it. After failed attempt
`i`, where `i < maximum_attempts`, the raw delay is
`ceil(initial_delay_ms * numerator^(i-1) / denominator^(i-1))`, evaluated with
exact nonnegative integer arithmetic. The coordinator sleeps until
`min(now + raw_delay, deadline)`. Attempt `i+1` starts only when the wake instant
is strictly before `deadline`; equality ends retry. No delay or attempt extends
the deadline. Discovery, fallback, endpoint change, and an unbounded attempt are
absent. Active simulation or Technical Removal permanently closes retry and new
Admission for this process.

`DC-CLIENT-005` incorporates the following deadline rule. Voluntary leave stops
new Intentions, submits one correlation identity, and
reuses that identity for any transport duplicate until the selected confirmation
bound. The deadline is the monotonic submission instant plus the bound. At each
client-coordination fence, the coordinator stamps a completely decoded and
validated Authority acknowledgement with the local monotonic instant at which
it dequeues that acknowledgement. No remote timestamp participates. A local
receipt stamp at or before the deadline takes precedence over an expiry sampled
at the same instant and proves the authoritative commit. A receipt stamp after
the deadline, timeout without acknowledgement, or connection loss permits
local shutdown but produces `DepartureUnconfirmed` and does not claim Authority
commit.

Logical domains are Process Control I/O, client coordination, transport I/O,
Prediction, Presentation/output, Input, and Observability. Immutable bounded
handoffs connect them. Post-ready control loss begins bounded non-normal
shutdown. Required capability loss follows the exact launch policy. Cleanup
stops owners then releases them in reverse dependency order; it never creates
or implies Authority-side state.

## Design commitments

- `DC-CLIENT-001`: Client MUST prepare and commit owners and exactly one Local
  Client Preparation in the declared order before Ready and connection.
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
| `DAC-CLIENT-001` | Fail each prepare/materialization, observe around each owner commit and Local Client Preparation, and fail Ready publication. | Exact forward prepare/commit and reverse pre-commit cleanup; exactly one complete Local Client Preparation precedes Ready; zero connection before complete Ready; a post-preparation failure preserves the local record without claiming Authority state. |
| `DAC-CLIENT-002` | Traverse every enumerated edge; attempt every non-enumerated edge; snapshot Process Control and participation after each event. | Every permitted edge commits one separately observable state; every other edge is rejected unchanged; ProcessReady and participation are separate fields and neither is inferred from the other. |
| `DAC-CLIENT-003` | Exercise initial delays 0 and 60000, numerator/denominator extrema, attempts 1..maximum, wake immediately before/at/after deadline, changed endpoint/identity, active state, and Technical Removal with a fake monotonic clock. | Timestamps equal the exact formula; no attempt starts at or after deadline; only bounded same-target pre-active attempts occur; every prohibited retry is absent. |
| `DAC-CLIENT-004` | Return each stable Admission rejection. | Rejection is presented and process remains controllable; no automatic termination or partial Admission state. |
| `DAC-CLIENT-005` | Duplicate leave; dequeue a validated confirmation just before, exactly at, and just after the deadline on the fake local monotonic clock; enqueue confirmation and expiry for the same fence; vary remote timestamps; lose connection. | One identity is used; only the local dequeue stamp participates; confirmation at or before the deadline wins including an equal-time expiry; every later or absent confirmation reports unconfirmed. |
| `DAC-CLIENT-006` | Inject every control failure after Ready at minimum shutdown bound. | Stopping and Terminated occur within the bound; channel is not reopened or replaced. |
| `DAC-CLIENT-007` | Run lifecycle suite for every real Client owner and double at min/max capacity. | All operations satisfy SDD-0002; commit blocks/allocates/throws zero times; doubles expose no extra behavior. |
| `DAC-CLIENT-008` | Omit/mutate every launch key and attempt discovery or fallback. | Invalid input rejects before prepare; valid client contacts exactly one selected endpoint and identity. |
| `DAC-CLIENT-009` | Invoke mutation from every device, transport, presentation, prediction, and Observability callback. | Callback can enqueue immutable bounded data only; direct mutation is rejected with unchanged owner state. |
| `DAC-CLIENT-010` | Terminate from every post-ready state, fill every ordinary owner queue before stop, and repeat every stop call. | Each reserved stop returns Accepted then AlreadyStopping; stop/release trace is exact reverse order; no client record claims remote commit without Authority confirmation. |
