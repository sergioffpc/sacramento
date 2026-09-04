# SDD-0001: Process Control Contract

Status: Approved design; realization and evidence remain incomplete

Approval: Project owner, 2026-09-04

Purpose: Define the external process-control protocol and the common startup
transaction used by Session Authority and Trainee Client executables.

Scope: Bootstrap, framing, states, commands, failure classifications, startup
ordering, ownership, cancellation, shutdown, and exit projection. It excludes
Training Session behavior, Observability payloads, and offline tools.

Intended readers: Runtime designers, implementers, verification authors,
operators, and infrastructure owners.

Prerequisites: SDB-001, SAD-003, ARCHSPEC-0006, ARCHSPEC-0009, and
ARCHSPEC-0010.

Canonical information owner: Runtime composition.

## Boundary

The Process Control Contract is a small Sacramento-owned framed binary protocol
over inherited standard input and standard output. Standard output is reserved
for control frames; logs and Observability use separately configured surfaces.
There is no JSON, Protobuf, generic CBOR data model, version negotiation,
fallback channel, reconnection, or runtime supervisor in the product.

The bootstrap supplies only Process Execution Identity, Runtime Launch
Specification path, and the expected specification identity and digest. The
runtime opens and validates the referenced immutable specification. A bootstrap
field or frame unknown to the exact protocol version is rejected.

## Wire and capacity contract

Each frame has a fixed-width header containing magic, exact protocol version,
message kind, payload length, and correlation identity, followed by one bounded
message-specific payload. Integer representation and maximum sizes are fixed by
normative golden vectors before implementation admission. A checksum is not an
integrity or recovery mechanism for this local inherited channel.

The implementation reserves bounded inbound, outbound, and terminal-control
capacity before startup. It accepts a publication only when the complete frame
has entered that bounded channel. It never blocks a canonical owner on an
unbounded write. Reserved terminal capacity cannot be consumed by diagnostics.

The only inbound message is `ShutdownRequest`. The outbound messages are
`ProcessState` and `CommandAcknowledgement`. There is no acknowledgement of
`ProcessReady`; successful publication of the complete frame is its external
commit point. Each command acknowledgement repeats the command identity and
reports one closed disposition.

## State model

The closed states are `ProcessStarting`, `ProcessReady`, `ProcessNotReady`,
`ProcessStopping`, and `ProcessTerminated`.

Valid paths are:

```text
ProcessStarting -> ProcessReady -> ProcessStopping -> ProcessTerminated
ProcessStarting -> ProcessNotReady -> ProcessTerminated
ProcessStarting -> ProcessStopping -> ProcessTerminated
```

`ProcessReady` is emitted once and atomically carries Process Execution
Identity, role identity, Runtime Launch Specification identity/digest,
role-applicable endpoint, reserved-capacity disposition, and applicable
Training Session identity. It is not Trainee readiness, Admission, peer
connection, or active simulation.

## Startup transaction

Both runtimes perform these phases in order:

1. validate bootstrap and create Process Control and Observability adapters;
2. parse the exact Runtime Launch Specification and compatibility selections;
3. ask each semantic owner to validate and prepare its role-specific immutable
   view and reserved capacity;
4. materialize private resources and perform final reversible external effects;
5. commit prepared owners in declared dependency order; and
6. publish `ProcessReady` and begin role work.

Each owner returns either a closed Sacramento failure or a move-only prepared
handle. Preparation may fail and must be reversible. Commit is non-throwing and
infallible by construction. The composition owns a staging transaction and
releases prepared handles in reverse dependency order on failure. Expected
failures use an `std::expected`-style result; exceptions are contained and
classified at the composition boundary.

Cancellation is observed only at explicit phase and adapter boundaries.
Monotonic clocks govern process timeouts. Only the Session Authority may use
the Operational Clock for Training Session deadlines. The executable `main`
is a thin composition root with explicit adapters; no service locator or
global runtime behavior is permitted.

## Failures and termination

Readiness classifications are `LaunchSpecificationRejected`,
`CompatibilityRejected`, `InputClosureRejected`, `CapacityRejected`,
`AdapterRejected`, `MaterializationRejected`, `EndpointRejected`,
`ControlChannelRejected`, `StartupInterrupted`, and `InternalFailure`.
Deterministic precedence selects one primary failure; bounded diagnostics may
retain secondary facts without changing it.

Terminal reasons are `WorkCompleted`, `ShutdownRequested`, `RequiredPeerLost`,
`ControlChannelLost`, `RequiredCapabilityLost`, `CanonicalIntegrityLost`,
`SettlementFailed`, and `InternalFailure`. Exit disposition is separate and
maps this richer reason to a small documented process exit-code set.

A `ShutdownRequest` contains a command identity and reason. Handling is
idempotent; duplicate identities receive the same acknowledgement. Its bounded
grace interval comes from the immutable role specification/profile. Loss,
corruption, incompatible framing, or bounded-write failure before
`ProcessReady` rejects startup and cleans up; after `ProcessReady` it starts
non-normal role-specific termination. The channel is never reopened or
replaced, and control loss cannot revise an already committed terminal
Training Session result.

## Design commitments

- `DC-PROCESS-001`: the two product runtimes MUST expose only this bounded,
  exact-version Process Control Contract for external lifecycle control.
- `DC-PROCESS-002`: bootstrap MUST identify exactly one immutable Runtime
  Launch Specification and its expected identity and digest.
- `DC-PROCESS-003`: a runtime MUST follow one of the closed state sequences and
  publish each state at most once.
- `DC-PROCESS-004`: a required control-channel failure MUST follow the
  pre-ready or post-ready containment rule above without reconnection.
- `DC-PROCESS-005`: each accepted command MUST receive one correlated,
  idempotent `CommandAcknowledgement` from reserved capacity.
- `DC-PROCESS-006`: startup MUST use reversible move-only prepared handles and
  an infallible ordered commit before `ProcessReady`.
- `DC-PROCESS-007`: terminal reason MUST remain distinct from its stable small
  exit-code projection.

## Verification design

Golden byte vectors cover every message and limit. Contract tests exercise
valid and prohibited state transitions, partial frames, wrong versions, length
overflow, queue exhaustion, short writes, duplicate shutdown, interruption at
every boundary, deterministic primary failure, reverse cleanup, exception
containment, and absence of native platform or orchestrator types. Composition
tests prove that no partial executable can emit `ProcessReady`.
