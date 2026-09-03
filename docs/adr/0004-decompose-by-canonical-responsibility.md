# Decompose Sacramento by canonical responsibility

Status: Accepted

Purpose: Define Sacramento's responsibility modules, runtime compositions, and
dependency direction.

Scope: Architecture-level module ownership, interfaces, adapters, and
composition; detailed APIs and source layout remain outside this decision.

Intended readers: Architects, designers, implementers, and verification
authors.

Prerequisites: ADR-0003 and the approved functional, non-functional,
observability, and verification baselines.

Canonical information owner: Project owner.

Amendment: ADR-0008 adds the Trainee Performance Assessment Module and retained-evidence seams.

Amendment: ADR-0009 preserves the `AUTH & Admission` interface while moving its production-security adapters to the future Production Security Baseline.

Sacramento is decomposed into deep modules that own canonical product
responsibilities, not into process layers or public wrappers around selected
vendors. Process-specific runtimes compose those modules and coordinate
multi-owner workflows, while every module retains exclusive ownership of its
state, resources, adapters, and observable behavior. This shape keeps the
Session Authority authoritative, makes its headless dependency closure
auditable, and concentrates change within interfaces that remain Sacramento
owned.

## Responsibility modules

| Module | Architecture-level ownership |
| --- | --- |
| `Simulation` | Canonical simulated state, simulated-time transitions, and authoritative simulation results. |
| `Session Lifecycle` | Training Session lifecycle state, Operational Clock decisions, Technical Removal coordination, completion, termination, and terminal results. |
| `AUTH & Admission` | Authentication, authorization, Admission lifecycle, host-scoped AUTH audit state, and the invariant that applicable AUTH Audit Commit Units become durable before granting effects. |
| `Runtime Package` | Persistent runtime-package schema, deterministic codec, identity, integrity, version, and compatibility. |
| `Content Admission` | Validation and atomic activation of exact Maps, Scenarios, Approved Profiles, catalogues, and other admitted runtime content. |
| `Protocol & Replication` | Versioned Sacramento wire schemas, replication semantics, ordering, and compatibility, independently of transport and internal simulation structures. |
| `Observability` | Required signal meanings, identity, correlation, loss semantics, and Sacramento-owned emission interface. |
| `Trainee Performance Assessment Module` | Identity-bound performance events, metrics, Training Feedback, Formal Assessments, Leaderboards, access decisions, corrections, and retained history without ownership of canonical Simulation state. |
| `Prediction` | Non-authoritative client state derived from confirmed replication updates and local intentions, always replaceable by authoritative correction. |
| `Presentation` | Trainee-facing visual and acoustic presentation and interaction, consuming Prediction rather than wire or vendor structures. |
| `Input & Interaction` | Raw platform-device input, access-mode interpretation, and construction of client-local Intentions without authority over their canonical outcome. |

`Prediction` and `Presentation` are deliberately separate. This permits
portable non-presenting consumers without making prediction authoritative or
making Falcor, Steam Audio, devices, or platform presentation dependencies of
client state derivation.

## Runtime compositions

| Runtime | Composed modules |
| --- | --- |
| `Session Authority Runtime` | Simulation, Session Lifecycle, AUTH & Admission, Runtime Package, Content Admission, Protocol & Replication, and Observability. |
| `Trainee Client Runtime` | AUTH & Admission, Runtime Package, Content Admission, Protocol & Replication, Prediction, Presentation, Input & Interaction, and Observability. |
| `Content Cooker Runtime` | Runtime Package and Observability, with private source-import adapters. |
| Administrative Tool Runtimes | Offline content, Approved Profile, catalogue, trust-package, and provisioning operations; later data and deployment decisions select the concrete executables. |
| `Synthetic Client Runtime` | Test-only protocol, deterministic action replay, authoritative-result receipt, and Observability; neither Presentation nor Prediction is mandatory. |

Only the Session Authority Runtime composes the owners of canonical Simulation
and Session Lifecycle state. A Trainee Client never determines authoritative
positions, impacts, injury, Scenario progression, or results.

ADR-0008 leaves the deployment location of `Trainee Performance Assessment Module`
open. Runtimes exchange only immutable Sacramento event inputs and result
references with it; no runtime shares its persistent state or makes it a
Canonical Tick dependency.

## Module dependency view

Scope: stable dependencies among responsibility modules. An arrow `A -> B`
means module A depends on the Sacramento interface owned by module B; it does
not mean ownership transfer or direct access to B's state.

```text
Content Cooker ----------------> Runtime Package
Content Admission -------------> Runtime Package
Simulation --------------------> Content Admission
Prediction --------------------> Protocol & Replication
Presentation ------------------> Prediction
Input & Interaction -----------> Protocol & Replication

Behavior-owning modules -------> Observability
Executable runtimes -----------> modules they compose
```

The graph is acyclic. Session Lifecycle does not depend directly on Simulation,
Protocol & Replication does not depend on Simulation internals, and AUTH &
Admission does not depend on Session Lifecycle. A runtime coordinates only
lifecycle, failure handling, and workflows spanning multiple owners; it never
reads or mutates module-private state. Each participating module validates and
changes only its own state and returns a Sacramento result. Later runtime and
persistence decisions define atomicity, compensation, and crash recovery across
owners.

Content Admission uses Runtime Package to validate and expose one immutable,
identified Sacramento content view. The Session Authority Runtime coordinates
activation of an exact version, and Simulation consults only that immutable
view during the Training Session. Source formats, importers, and vendor types
never enter the runtime package interface.

There is no generic `Common` module. Stable types belong to the module whose
interface defines their meaning and are imported explicitly. Shared technical
primitives remain minimal and never become a store for domain state, wire
messages, configuration, or errors.

## Adapter and failure rules

- Flecs and PhysX remain private to Simulation implementations.
- Falcor and Steam Audio remain private to Presentation implementations.
- Slang is private to shader adapters in the cooker and Presentation.
- GameNetworkingSockets and its platform crypto backends remain private to
  Protocol & Replication implementations and do not supply AUTH Protected
  Exchange.
- Assimp remains private to Content Cooker implementations.
- Tracy and structured logging remain private to Observability implementations.
- Identity validation, AUTH cryptography, persistence, and checkpoints use
  internal AUTH & Admission seams.
- Filesystem, device, and platform adapters live only inside the module that
  benefits from them.

No vendor callback may alter canonical state directly. Each module owns the
lifetime of its adapters, threads, and resources and converts failures into
Sacramento outcomes at its interface. The applicable runtime decides retry,
degradation, recovery, or termination without interpreting vendor-specific
errors. An operation produces its complete visible module effect or no visible
effect.

Every behavior-owning module emits required semantics through the Observability
interface; the runtime establishes process lifecycle and correlation roots and
supplies the adapter. Collection, storage, transport, and optional Tracy
signals remain replaceable implementation details.

The module interface is also its test surface. Contract fixtures exercise
Sacramento commands, results, invariants, ordering, and failures. Private
adapters receive focused integration tests, and executable closure audits prove
that client-only or source-import dependencies are absent from the Session
Authority and other inapplicable runtimes. Test adapters exist only for real
variation or controlled failure injection.

## Future Autonomous Participant baseline

An Autonomous Participant is a future role, not a Trainee and not a synthetic
acceptance client. It is outside the initial Desktop Mode and Session Authority
baseline and belongs to the separately named `Autonomous Participant baseline`.
That future baseline must define its requirements, identity, AUTH Permission,
Admission behavior, observability, verification, and applicability before the
role is admitted.

The future composition assigns one Autonomous Participant to one controlling
client connection, applies the same represented actions, physical rules,
capacity, Team Position, and perceptible-information restrictions as for a
Trainee, and never grants direct access to canonical state. `Autonomous Control`
will own world modeling, planning, and intention submission when that baseline
is defined. It is not an initial-baseline module or speculative interface.
Separating Prediction from Presentation preserves the difficult-to-reverse
extension seam without admitting the future capability now.

## Considered options

- Process-first modules were rejected because client, authority, and cooker
  layers would duplicate canonical rules and obscure ownership.
- One universal canonical module was rejected because Simulation, session
  lifecycle, trust, audit, content, protocol, and observability have different
  state, clock, durability, and failure invariants.
- Public modules matching ECS, physics, rendering, audio, networking, logging,
  or profiling mechanisms were rejected as shallow vendor-shaped interfaces.
- A runtime that mediates every module interaction was rejected because it
  would become a pass-through module coupled to every interface.

## Consequences

Cross-owner workflows require explicit orchestration and later decisions for
transactional recovery; this complexity is visible rather than hidden in a
shared mutable store. Separate internal model and wire schemas add mapping but
permit independent compatibility and evidence impact. The module set is small
enough for the two-generalist ceiling to remain credible, while any future
split must pass the deletion test and demonstrate additional leverage or
locality rather than mirror an implementation mechanism.

This decision resolves issue #24 and traces principally to
`REQ-AUTHORITY-001`, `REQ-CLIENT-TRUST-001`,
`REQ-STATE-CONSISTENCY-001`, `SCOPE-AUTH-001`,
`REQ-CONTENT-PROCESSING-GATE-001`, `NFR-OBSERVABILITY-CORE-001`, and
`CONSTRAINT-NFR-TEAM-001`. The Autonomous Participant baseline has no approved
requirement identifiers yet; its terminology and applicability decision do not
admit the capability until a separately approved requirements change supplies
them.
