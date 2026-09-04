# SDD-0002: Session Authority Runtime

Status: Approved design; realization and evidence remain incomplete

Approval: Project owner, 2026-09-04

Purpose: Define composition, startup, concurrency, readiness, and shutdown for
one Session Authority process and its single Training Session.

Scope: Role-specific Runtime Launch Specification view, owner preparation,
endpoint publication, Training Session preparation, execution domains, and
terminal settlement.

Intended readers: Session Authority designers, implementers, verification
authors, operators, and evidence custodians.

Prerequisites: SDB-001, SDD-0001, SAD-003, ARCHSPEC-0005, ARCHSPEC-0006,
ARCHSPEC-0008, ARCHSPEC-0009, and ARCHSPEC-0012.

Canonical information owner: Session Authority composition.

## Composition boundary

The runtime composition coordinates whole-process order but owns no
module-private state. Each module receives a role-specific typed view of the
Runtime Launch Specification and exposes the minimal lifecycle surface:
validate, prepare, return a move-only prepared result, infallible commit, stop,
settle where applicable, and release. Native adapters are injected at the thin
executable composition root.

The authority launch payload selects exact process/session/scenario identities,
Authority Pack, compatibility/profile identities, assigned endpoint, capacity
budgets, AUTH mode, Observability contract, external custody destinations,
shutdown bound, and required capability policies. Optional fields are not a
universal launch bag; absence and applicability are role-schema decisions.

## Startup and readiness

Preparation order is:

1. Process Control and Observability;
2. Runtime Package and Content Admission;
3. Simulation and Scenario;
4. AUTH & Admission;
5. Protocol & Replication;
6. a Session Lifecycle candidate;
7. commit prepared module owners;
8. bind the exact endpoint in a nonaccepting state;
9. create and commit the Training Session Preparation/Lifecycle Revision;
10. publish `ProcessReady` with the endpoint; and
11. enable accept.

The committed Preparation record is created immediately before readiness and
contains the identities needed to prove the exact prepared closure. If
`ProcessReady` publication fails after that commit, the authority commits the
applicable terminal record and settlement rather than erasing history.
Endpoint binding does not permit connection or Admission until readiness is
successfully published.

## Execution and ownership

Logical execution domains are Process Control I/O, canonical coordination,
transport I/O, retained-evidence export, and Observability. The canonical
coordination domain is the sole sequential caller of authority module state.
Development AUTH during Preparation executes there. Other domains communicate
through immutable bounded handoffs and cannot call back to mutate canonical
state.

The architecture does not depend on CPU affinity. Memory is attributed by
semantic owner and lifetime domain, not by worker. Control and terminal output
capacity remains reserved independently from evidence and diagnostics.

Shutdown stops admission and new intentions, fences the current Canonical Tick,
commits the appropriate terminal truth, obtains required settlement receipt,
then releases owners in reverse dependency order. Publication failure after a
canonical commit cannot roll back that commit. Process loss follows the
accepted ephemeral-session rules.

## Design commitments

- `DC-AUTHORITY-001`: the authority MUST commit exactly one Training Session
  Preparation/Lifecycle Revision before publishing `ProcessReady`.
- `DC-AUTHORITY-002`: the authority MUST prepare and commit role owners in the
  declared dependency order through typed launch views and move-only results.
- `DC-AUTHORITY-003`: the endpoint MUST remain nonaccepting until the complete
  `ProcessReady` frame has been published.
- `DC-AUTHORITY-004`: shutdown MUST fence canonical work and preserve terminal
  settlement before reverse-order release.
- `DC-AUTHORITY-005`: only the canonical coordination domain MUST invoke
  authority module state transitions.
- `DC-AUTHORITY-006`: control and terminal capacity MUST remain available
  independently of Observability and evidence-export pressure.

## Verification design

Composition tests inject each owner failure and each interruption before and
after every commit point. They verify exact order, reverse cleanup, zero
acceptance before readiness, one Preparation identity, post-commit terminal
settlement, tick fencing, bounded queues, reserved control delivery, native
type containment, and unchanged prior commits. Module doubles may return only
prepared values or failures at the actual lifecycle seam.
