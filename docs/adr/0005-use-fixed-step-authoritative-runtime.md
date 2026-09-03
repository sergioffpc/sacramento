# ADR-0005: Use a fixed-step authoritative runtime

Status: Accepted

Amendment: ADR-0008 replaces the former client-disconnection recovery behavior.

## Context

Sacramento needs one deterministic authority for lifecycle, simulation, action,
Scenario, and item outcomes while Desktop and Virtual-Reality clients present
the same canonical result. Network arrival order, rendering cadence, wall-clock
speed, and client prediction must not decide authoritative outcomes.

ADR-0008 simplifies connection loss: an active disconnected Trainee receives an
irreversible Technical Removal and the Simulation continues. No live session
state is restored.

## Decision

### Time and runtime profiles

The Session Authority advances Simulation through numbered fixed-duration
Canonical Ticks. Simulated Time advances exactly once for each committed tick.
The separate monotonic Operational Clock governs lifecycle deadlines and the
initial countdown.

A versioned Runtime Execution Profile fixes tick duration, ordering phases,
budget policy, deterministic calculation rules, seeded-randomness policy, and
overload thresholds before a Training Session starts. The process binds one
immutable profile view for its lifetime.

### Process and Training Session lifecycle

One Session Authority process owns one launch-selected Scenario and exactly one
Training Session:

```text
Process Start
  -> Validate and activate launch inputs
  -> Preparation
       -> Initial Countdown
       -> Preparation                 (countdown cancelled)
       -> Active
            -> Active                 (ordinary committed ticks)
            -> Active                 (Technical Removal of one Trainee)
            -> Completed              (normal Scenario result)
            -> Terminating            (non-normal session failure)
       -> Terminating                 (pre-active failure or explicit end)
  -> Terminal Settling
  -> Process Exit
```

Preparation connection loss or explicit departure ends that Admission,
releases its preparation state, clears its readiness, and cancels an applicable
countdown. During Active, Session Lifecycle applies ADR-0008 Technical Removal;
it does not introduce a pause, recovery, or re-entry state.

### Canonical Tick transaction

Each tick is one authoritative transaction:

1. seal the eligible intention set at the deterministic admission boundary;
2. order intentions using the approved ordering key;
3. resolve actions, Simulation, Scenario, item, and lifecycle effects against
   the preceding committed state;
4. resolve same-tick conflicts and terminal conditions using approved
   precedence rules;
5. atomically commit the next canonical state, tick index, Simulated Time,
   authoritative events, and reconstruction record;
6. publish immutable version-matched views after the commit.

A tick is never partially authoritative. A confirmed connection-loss event is
ordered like any other accepted lifecycle input. If it is accepted before the
tick admission boundary, Technical Removal participates in that tick; if it is
accepted after sealing, it participates in the next tick. Once accepted, all
removal effects commit atomically before later simulation advancement.

Overload policy is explicit. Before the commitment point the authority may
reject a whole candidate tick without advancing Simulated Time. After the
commitment point it must finish that tick or terminate the Training Session as
a technical failure; it may not publish a partial tick.

### Intention admission and ordering

Clients submit intentions, never authoritative outcomes. Each intention binds
the active Admission, client connection, target Training Session, base state
version, client-local monotonic sequence, and intended action payload.

Admission accepts each sequence once, rejects duplicates and stale or future
bindings outside the Runtime Execution Profile, and admits only intentions
received before the tick boundary. The final ordering key contains no network
arrival timestamp and ends with a stable tie-breaker.

After Technical Removal, the ended Admission and removed connection cannot
submit eligible intentions. A newly launched client must start a new Admission
in a later Training Session; it cannot reclaim the removed participant.

### State version, replication, prediction, and presentation

Every committed tick produces a monotonically increasing canonical state
version. Replication publishes only immutable versions and ordered deltas bound
to an explicit base version. Missing deltas request a confirmed baseline for
presentation synchronization, but that synchronization is not authoritative
session recovery.

Prediction is presentation-only. Clients may predict their own eligible local
actions, must reconcile to authoritative versions, and may never create
Scenario results, injuries, item dispositions, or lifecycle outcomes.
Presentation consumes only published committed views and may interpolate or
omit rendered frames without changing Simulation.

When a Trainee receives Technical Removal, the client discards prediction newer
than the last committed view and receives no further playable state. Other
clients continue to receive ordinary committed views.

### Coordination, replay, and observability

Session Lifecycle owns lifecycle transitions and Operational Clock decisions;
Simulation owns canonical world evolution; Scenario owns objective and result
rules; Protocol & Replication owns intention ingress and immutable view
delivery; AUTH & Admission owns identity bindings and durable-before-effect
audit semantics.

Every committed tick emits enough ordered, versioned reconstruction evidence to
reproduce its authoritative inputs and outcome under the exact Runtime
Execution Profile and content versions. ADR-0008 governs asynchronous export,
the immutable terminal Session Evidence Set, retention, and durable terminal
handoff. Observability is asynchronous and never an input to canonical logic.

## Considered options

- Variable-delta authoritative updates were rejected because machine speed and
  scheduling would influence accepted outcomes.
- Client-authored movement or combat outcomes were rejected because they break
  the single-authority boundary.
- Network-arrival ordering was rejected because transport jitter would become a
  gameplay rule.
- Live checkpoint and process restoration were rejected because the initial
  baseline treats live state as ephemeral and evidence as non-resumable.
- Pausing for a disconnected Trainee was superseded by ADR-0008 because the
  simpler Technical Removal rule contains one participant failure without
  halting the exercise.

## Consequences

The runtime requires explicit profiles, deterministic ordering, atomic commit
fences, immutable published views, and reconstruction evidence. Clients remain
responsive through prediction but accept correction. A disconnected Trainee
cannot return, while remaining participants continue without a recovery pause.

## Trace

This decision supports `REQ-AUTHORITY-001`, `REQ-OPERATIONAL-CLOCK-001`,
`REQ-SESSION-COUNTDOWN-001`, `REQ-SESSION-DISCONNECT-001`,
`REQ-TECHNICAL-REMOVAL-001` through `REQ-TECHNICAL-REMOVAL-006`,
`REQ-AUTH-AUDIT-COMMIT-001`, `REQ-STATE-CONSISTENCY-001`,
`REQ-SESSION-EVIDENCE-001` through `REQ-SESSION-EVIDENCE-006`,
`NFR-ACTION-RESPONSE-001`, and `NFR-OBSERVABILITY-INTEGRITY-001`.
