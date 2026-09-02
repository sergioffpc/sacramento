# Use a fixed-step authoritative runtime with separate clock domains

Status: Accepted

Sacramento advances canonical Simulation through indivisible fixed steps at
240 Hz, keeps client Prediction at 240 Hz and Presentation at an independent
60 Hz cadence, and never substitutes Operational Clock or Trusted Identity Time
for Simulated Time. The Session Authority Runtime coordinates the owning
modules through an explicit lifecycle and atomic tick boundary so client
latency, frame rate, connection loss, recovery, or vendor scheduling cannot
change canonical outcomes. This favors deterministic authority and
reconstructable evidence over variable-step responsiveness or client-selected
simulation time.

## Time and runtime profiles

Simulated Time is represented as a simulation epoch plus an unsigned integer
Canonical Tick. Within one epoch it is exactly `tick_index × 1/240 s`; it has no
floating accumulated wall-clock value. A successful Canonical Tick increments
the index once, and Technical Pause does not increment it.

The three time domains have non-overlapping authority:

| Domain | Owner and permitted use |
| --- | --- |
| Simulated Time | Simulation; canonical state evolution, physics, Scenario timers, and simulated time-dependent effects only. |
| Operational Clock | Session Lifecycle on the Session Authority; lifecycle deadlines and countdowns, including while Simulated Time is frozen. |
| Trusted Identity Time | Each validating host; identity-evidence validity, AUTH policy validity, and applicable audit retention only. |

Client clocks and client-provided timestamps cannot select a Canonical Tick,
order an Intention, satisfy a deadline, or determine an authoritative result.
An event satisfies a lifecycle deadline only when Session Lifecycle accepts it
strictly before the deadline. At the exact boundary, an invalidating event
precedes countdown completion.

One versioned Runtime Timing Profile is an Approved Profile and binds the
structural 240 Hz Simulation cadence, 240 Hz Prediction cadence, and 60 Hz
Presentation cadence together with finite limits for authority catch-up,
Prediction lead, history and replay, replication-delta retention, and
heartbeat/loss detection. The three rates are accepted by this decision. Exact
values for the other limits require workload evidence and project-owner
approval; an implementation default is not an admitted value.

Simulation, Prediction, and Presentation use independent schedulers.
Presentation consumes the latest immutable Prediction view available at its
frame boundary and never blocks Prediction or authority Simulation. A missed
Presentation frame does not enlarge, merge, skip, or delay a Canonical Tick.

## Process and Training Session lifecycles

Every runtime process has the separate state sequence `Starting -> Running ->
Stopping -> Stopped`. External authority readiness is independently reported as
`Ready`, `NotReady`, or `Missing`; it is not a process state, a Training Session
state, or a Trainee's `Ready` state.

The Session Authority Runtime validates its build, configuration, Runtime
Timing Profile, exact content set, protocol version, identity inputs, module
closures, and required resources while `Starting`. It reports external
readiness only after all applicable validation succeeds. Shutdown first blocks
new work, ends current Admissions and any nonterminal Training Session, flushes
required AUTH audit and Observability effects where orderly shutdown remains
possible, releases module resources in reverse composition order, and reaches
`Stopped`.

Session Lifecycle owns this hierarchical Training Session state machine:

```text
Preparation
  -> Initial Countdown
  -> Active
       -> Technical Pause
            -> Reconnection Window
            -> Restoration Window
            -> Awaiting Ready
            -> Resume Countdown
            -> Active
  -> Completed

Any nonterminal state -> Terminating -> Terminated
```

`Technical Pause` is the parent of all recovery substates. `Awaiting Ready`
applies when continuity and State Restoration have succeeded but the complete
resume gate does not yet hold. Process lifecycle, external readiness, Training
Session lifecycle, and each Trainee's `Ready` state remain distinct even when
their transitions occur together.

Stopping or crashing the Session Authority ends its Admissions and nonterminal
Training Session. Restart may recover AUTH audit integrity and classify the
prior process loss, but cannot resume a live Training Session from persisted
simulation state.

## Canonical Tick transaction

Each active Canonical Tick executes the following stable Sacramento-owned
phases in this exact order:

1. lifecycle gate;
2. seal eligible Intentions;
3. advance authoritative Simulation;
4. commit the complete canonical result and version; and
5. publish each applicable authoritative change and result.

Sacramento owns the phase keys, order, entry and exit invariants, failure
classification, and verification evidence. Simulation's private Flecs adapter
materializes those phases as an exact Flecs pipeline and registers systems only
inside them. The adapter must prove its complete, order-preserving mapping;
Flecs phases, entities, components, callbacks, and scheduler types never enter
a Sacramento interface. PhysX and any other private adapter likewise cannot
mutate canonical state outside the executing Simulation phase.

The lifecycle gate establishes whether the tick may start. Once Intention
sealing begins, the tick either commits its complete result or exposes none of
it. A first connection loss accepted before the gate closes prevents that tick
from starting and enters Technical Pause. A loss accepted after the tick has
started allows that indivisible tick to commit, cancels accepted but unsealed
Intentions, and enters Technical Pause immediately after the commit. Those
cancelled Intentions are never queued across the pause.

The authority publishes every committed tick's applicable change or result
without batching it behind a later tick. Client acknowledgement is asynchronous
and cannot block commit or publication. Backpressure may eventually exceed an
admitted overload bound, but it cannot alter a committed result.

The authority may execute bounded catch-up when Simulated Time lags Operational
Clock. Catch-up still executes every full 1/240-second tick: it cannot skip,
merge, or enlarge steps. If the Runtime Timing Profile's catch-up bound is
exceeded, the authority deterministically terminates the Training Session as a
technical failure. Generic overload does not invent a Technical Pause or permit
unbounded lag.

## Intention admission and ordering

Each Admission has one contiguous, monotonically increasing Intention sequence.
Duplicates receive the prior disposition idempotently, stale sequence values
receive an explicit stale disposition, and a gap blocks later sequence values
until the missing value arrives or the Admission ends. Successful connection
continuity preserves the sequence; it does not create a new ordering epoch.

A valid Intention is assigned to the first Canonical Tick whose Intention phase
has not been sealed. The client cannot select a future tick. Sacramento defines
one versioned total-order rule over eligible Admissions and their sequence
values; network arrival order and client time are never canonical tie-breakers.
The precise comparator and wire encoding belong to Protocol & Replication
design, but every implementation and replay must produce the same order for the
same admitted inputs.

## State version, replication, Prediction, and Presentation

The identity of confirmed authority state is composite: Training Session
identity, exact admitted content set, simulation epoch and Canonical Tick,
Session Lifecycle revision, and canonical digest. Canonical Tick changes only
through Simulation commits. Session Lifecycle revision changes for non-
simulation lifecycle transitions, including transitions within Technical
Pause. A client-specific Replication View carries its own digest and discloses
only state that client is authorized and required to receive.

Protocol & Replication publishes a confirmed baseline followed by ordered
deltas and retains them within the Runtime Timing Profile bound. A per-client
ACK is only a high-water assertion that the identified view was received and
applied; it is neither Trainee `Ready` nor State Restoration evidence. An
irrecoverable delta gap or digest mismatch causes a new confirmed baseline.
Ordinary baseline resynchronization is not State Restoration.

Prediction derives only from a confirmed Replication View, locally submitted
Intentions, and the exact admitted Prediction part of the Runtime Timing
Profile. It may lead the confirmed Canonical Tick only within the finite lead
bound and freezes on reaching it. Authoritative correction triggers bounded
rollback and replay; a correction outside retained history discards speculative
state and resets Prediction to a new confirmed baseline. Prediction remains
replaceable and cannot author canonical state.

During Technical Pause, Prediction discards every state after the paused
confirmed version, explicitly cancels pending local Intentions, and freezes.
Gameplay input is rejected rather than queued. Presentation continues at its
independent cadence using the paused view and identifies the Technical Pause.
Prediction restarts only from the first confirmed tick after successful
recovery.

The State Restoration Coverage Catalogue governs deliberate omissions from a
Replication View and defines what complete restoration requires for each
access mode. It does not convert hidden or irrelevant canonical state into
client-visible state.

The initial protocol requires an exact version match. Version negotiation and
protocol-version coexistence inside one Training Session are not admitted.

## Connection loss, continuity, and State Restoration

Protocol & Replication converts its transport and heartbeat observations into
a Sacramento connection-loss outcome using the exact Runtime Timing Profile.
It does not mutate Session Lifecycle. Session Lifecycle accepts the outcome for
the current Admission using Operational Clock and applies these rules:

1. The first connection loss during `Active` completes the current tick rule
   above, enters `Technical Pause / Reconnection Window`, freezes Simulated
   Time, and starts the canonical 30-second Operational Clock deadline.
2. AUTH & Admission accepts composite continuity strictly before that deadline
   only when the same protected AUTH Attempt establishes the current Session
   Continuity Claim, Device Continuity Proof, exchange integrity and binding,
   current connection, absence of cancellation or supersession, and the
   complete durable AUTH Audit Commit Unit.
3. AUTH & Admission prepares the Admission rebind and claim rotation, commits
   the audit unit durably, and then publishes the in-memory rebind atomically.
   Failure or process loss before publication has zero continuity effect. On
   success the old connection is unusable, the claim is rotated, Session
   Lifecycle closes the reconnection window, and the same transition starts
   the canonical 30-second `Restoration Window`.
4. The reconnected client must establish one complete State Restoration proof
   bound to the Training Session, Technical Pause instance, exact paused
   composite state version, Replication View, access mode, exact content set,
   and every applicable State Restoration Coverage Catalogue item. A snapshot,
   ACK, claim, partial proof, or stale proof is insufficient.
5. Before the restoration deadline, the reconnected Trainee must explicitly
   re-enter `Ready`. Complete restoration without `Ready` enters `Awaiting
   Ready`; `Ready` without complete restoration remains in `Restoration
   Window`. When restoration and the complete roster-wide resume gate hold,
   Session Lifecycle closes the restoration window and starts one shared
   five-second `Resume Countdown`.
6. If all resume conditions still hold at countdown completion, the session
   returns atomically to `Active`; the following Canonical Tick is the first to
   advance Simulated Time.

Failure to complete continuity or restoration strictly before its deadline
terminates the Training Session. Any further connection loss after the first
reconnection window begins and before `Active` resumes—including another loss
of the recovering client—terminates immediately without opening or restarting
a window. Loss of any Trainee's `Ready` during Resume Countdown also terminates
immediately. Each such recovery termination returns connected Trainees to
Preparation for a later Training Session and clears every `Ready` state.
Equal-time invalidation wins. Only a later loss after successful resume begins
a new recovery cycle.

If a Scenario terminal result commits in the same Canonical Tick as the first
connection loss, the result remains canonical and publication is attempted for
each still-applicable view, but Session Lifecycle enters Technical Pause rather
than `Completed`. State Restoration binds the recovered client to that result.
After the successful Resume Countdown, Session Lifecycle confirms the result
and transitions immediately to `Completed` without advancing Simulated Time.

## Coordination, replay, and observability

The Session Authority Runtime coordinates cross-owner transitions but does not
take ownership of module state:

- Session Lifecycle gates ticks, owns lifecycle state and Operational Clock
  deadlines, and consumes connection-loss, continuity, restoration, and Ready
  outcomes.
- Simulation owns canonical simulated state, Canonical Tick commits, and
  authoritative outcomes.
- AUTH & Admission owns Admission continuity, durable-before-effect audit
  atomicity, rebind, claim rotation, and recovery after incomplete audit work.
- Content Admission supplies one immutable exact admitted content view.
- Protocol & Replication owns Intention protocol dispositions, versioned
  Replication Views, ACKs, gaps, resynchronization, and transport-loss mapping.
- Prediction and Presentation remain client-owned consumers under ADR-0004.
- Observability receives the required Sacramento meanings without becoming an
  owner or ordering source.

For deterministic reconstruction, the authority produces a Sacramento-owned
record for every Canonical Tick and Session Lifecycle revision. It identifies
the exact Runtime Timing Profile, content and protocol versions, accepted
Intentions and dispositions, canonical order, authoritative results, composite
versions, and digests. Network packets and implementation logs are auxiliary,
not replay truth. The retention and persistence architecture for these records
is deferred; this record never permits live-session resume after process loss.

The Runtime Timing Profile must make the approved 100 ms action-response target
structurally achievable: a valid Intention waits no longer than the first open
tick, sealing and commit occupy one 1/240-second step, result publication is
immediate and non-batched, ACK is nonblocking, and a client applies correction
in Prediction without waiting for Presentation. Catch-up cannot excuse a
violation of the applicable 99th-percentile target. Exact transport and
processing sub-budgets require measurement evidence rather than allocation by
this ADR.

The Observability Contract requires a governed successor that exposes the
minimum privacy-safe core signals for process and Training Session lifecycle,
Canonical Tick and composite version, pause trigger, continuity and restoration
outcomes, resume, Prediction correction/reset, ACK/gap/resynchronization,
overload, and deterministic termination. This ADR does not silently add fields
to the approved contract.

## Considered options

- Variable-step authoritative Simulation was rejected because wall-clock jitter
  would enter canonical evolution and weaken deterministic reconstruction.
- Coupling Simulation, Prediction, and Presentation to one scheduler was
  rejected because client presentation work must not stall authority or
  Prediction and non-presenting clients still require Prediction.
- Skipping, merging, or enlarging ticks under load was rejected because it
  changes canonical physical and time-dependent behavior.
- Client-selected ticks, timestamps, or arrival order were rejected as
  authority inputs because network conditions and untrusted clocks would alter
  outcomes.
- Using ACK or a new snapshot as State Restoration was rejected because neither
  proves the complete approved paused-state coverage.
- Resuming from persisted simulation state after authority restart was rejected
  because the baseline expressly admits only live in-memory recovery.

## Consequences

The model makes simulated evolution, lifecycle deadlines, identity validity,
and client presentation independently testable. It also makes every boundary
case explicit: pausing can occur only at a tick boundary, lifecycle changes can
version a frozen simulated state, and correction never promotes Prediction.

The cost is a stricter runtime: the authority needs bounded queues, catch-up,
replication retention, digesting, and deterministic records; clients need
bounded rollback and explicit reset. Exact non-rate bounds remain blocked on
representative workload evidence. Concurrency topology, persistence mechanism,
wire layout, and concrete APIs remain later decisions and must preserve the
ownership and atomicity established here.

This decision resolves issue #27 and traces principally to
`REQ-AUTHORITY-001`, `REQ-CLIENT-TRUST-001`,
`REQ-STATE-CONSISTENCY-001`, `REQ-OPERATIONAL-CLOCK-001` through
`REQ-DEADLINE-ORDER-002`, `REQ-SESSION-DISCONNECT-001` through
`REQ-SESSION-RESUME-READY-LOSS-001`, `REQ-AUTH-AUDIT-COMMIT-001`,
`REQ-AUTH-AUDIT-WRITE-FAILURE-001`, `NFR-ACTION-RESPONSE-001`,
`NFR-DESKTOP-SMOOTHNESS-001`, and `NON-GOAL-SESSION-SAVE-001`.
