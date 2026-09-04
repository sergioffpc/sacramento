# SDD-0003: Trainee Client Runtime

Status: Approved design; realization and evidence remain incomplete

Approval: Project owner, 2026-09-04

Purpose: Define composition, startup, connection, Admission, departure, and
shutdown for one Trainee Client process.

Scope: Role-specific launch view, owner preparation, ProcessReady semantics,
connection retry, voluntary leave, execution domains, and termination.

Intended readers: Trainee Client designers, implementers, verification authors,
operators, and device-adapter owners.

Prerequisites: SDB-001, SDD-0001, SAD-003, ARCHSPEC-0006, ARCHSPEC-0009,
and ARCHSPEC-0012.

Canonical information owner: Trainee Client composition.

## Composition and launch view

The client follows SDD-0001's startup transaction. Its closed launch payload
selects exact Process Execution and target Training Session identities, Client
Pack, expected Authority identity and endpoint, compatibility/profile
identities, device and output requirements, capacity budgets, AUTH mode and
Synthetic Identities when applicable, Observability contract, retry policy,
shutdown bound, and external destinations. Native adapters are injected by a
thin executable composition root.

Preparation order is:

1. Process Control and Observability;
2. Runtime Package and Content Admission;
3. Prediction;
4. Presentation and required outputs;
5. Input & Interaction and required devices;
6. Protocol & Replication;
7. AUTH & Admission adapter;
8. commit prepared owners;
9. publish `ProcessReady`; and
10. connect only to the selected Session Authority endpoint.

`ProcessReady` means only that the local process closure is committed. It does
not mean connected, admitted, assigned, `TraineeReady`, or active. Failure of a
later Admission does not by itself terminate the process; the client may show
the stable rejection and await a permitted user or shutdown action.

## Connection and departure

Before active simulation, the client may perform only the finite retry policy
selected by its launch specification, always against the same endpoint and
expected authority identity. Each retry begins a new Admission. It never uses
discovery, fallback, a second endpoint, or an unbounded policy. After active
simulation begins or Technical Removal occurs, reconnection and new Admission
are prohibited for that process.

A voluntary leave submits one idempotent departure command and waits for a
bounded authority confirmation. Confirmation proves the authoritative commit.
Expiry permits local shutdown but the client must report the confirmation as
unresolved and must not claim that the authority committed departure.

## Execution and failure

Logical domains are Process Control I/O, client coordination, transport I/O,
prediction, presentation/output, input, and Observability. Exact thread and
scheduler mapping belongs to later subsystem SDDs. Immutable bounded handoffs
separate domains; device callbacks and transport callbacks cannot directly
mutate another owner's state. Test device adapters satisfy the same contracts
but cannot constitute product acceptance evidence.

Control loss after readiness initiates bounded non-normal shutdown. Required
device/capability loss follows its stable role policy. Cleanup releases owners
in reverse dependency order and cannot imply an authority-side domain commit.

## Design commitments

- `DC-CLIENT-001`: the client MUST prepare and commit its owners in the declared
  order before `ProcessReady` and connection.
- `DC-CLIENT-002`: the client MUST keep process readiness, connection,
  Admission, and `TraineeReady` as distinct states.
- `DC-CLIENT-003`: connection retry MUST be finite, launch-selected, and limited
  to the same endpoint before active simulation.
- `DC-CLIENT-004`: an Admission rejection MUST NOT by itself force process
  termination.
- `DC-CLIENT-005`: voluntary leave MUST use one idempotent departure request and
  distinguish confirmed authority commit from local wait expiry.
- `DC-CLIENT-006`: post-ready control loss MUST initiate bounded non-normal
  termination without channel replacement.

## Verification design

Tests cover every preparation failure, cleanup order, premature connection,
each distinction after `ProcessReady`, retry exhaustion, changed endpoint and
identity rejection, no retry after active state or Technical Removal,
Admission rejection, duplicate departure, confirmation at the time boundary,
unconfirmed exit, control loss, queue exhaustion, native-type containment, and
contract-equivalent test adapters.
