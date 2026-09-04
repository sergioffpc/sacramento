# Training Simulation Software Architecture Description

Status: Approved

Approval: Project owner, 2026-09-04

Approved predecessor: `SAD-002`, project owner, 2026-09-04

Description version: `SAD-003`

Version basis: The exact file version registered in the successor Baseline
Artifact Inventory; a governing input or view-content change creates a successor
description version.

Purpose: Present the accepted Development Baseline architecture of the
Training Simulation as one lean, linked set of stakeholder views.

Scope: The initial Desktop Mode and Session Authority architecture, including
runtime and offline-tooling boundaries, module dependencies, runtime behavior,
concurrency, content and retained-data paths, deployment allocation,
cross-cutting policies, verification, and known open work. Detailed software
design, source layout, concrete internal interfaces, product realization,
Production Security, and Platform Operations are outside this description.

Intended readers: Project owner, architects, designers, implementers,
verification authors, operators, security reviewers, Qualified Specialists,
and Representative Evaluators.

Prerequisites: `CONTEXT.md`, ADR-0001 through ADR-0013, ARCHSPEC-0003 through
ARCHSPEC-0013, and the approved requirements, Verification Plan,
Documentation Inventory, Baseline Applicability Inventory, Baseline Artifact
Inventory, and Evidence Dependency Inventory.

Canonical information owner: Project owner.

Maintenance owner: Implementation team.

## Table of contents

- [Description boundary and use](#description-boundary-and-use)
- [`EDI-VIEW-001`: Document control and reading guide](#edi-view-001-document-control-and-reading-guide)
- [`EDI-VIEW-002`: System context and allocation](#edi-view-002-system-context-and-allocation)
- [`EDI-VIEW-003`: Module and dependency structure](#edi-view-003-module-and-dependency-structure)
- [`EDI-VIEW-004`: Runtime lifecycle and sequences](#edi-view-004-runtime-lifecycle-and-sequences)
- [`EDI-VIEW-005`: Concurrency and ownership](#edi-view-005-concurrency-and-ownership)
- [`EDI-VIEW-006`: Content, trust, and retained-evidence paths](#edi-view-006-content-trust-and-retained-evidence-paths)
- [`EDI-VIEW-007`: Cross-cutting policies](#edi-view-007-cross-cutting-policies)
- [`EDI-VIEW-008`: Verification and traceability](#edi-view-008-verification-and-traceability)
- [`EDI-VIEW-009`: Risks, debt, assumptions, and open work](#edi-view-009-risks-debt-assumptions-and-open-work)
- [Description change control](#description-change-control)

## Description boundary and use

This description realizes the nine-view set selected by
[ARCHSPEC-0010](0010-cross-cutting-architecture-and-verification.md#software-architecture-description-view-set).
It is a navigation and reasoning surface over accepted decisions, not a new
decision record. Where its summaries differ from a linked requirement, ADR,
architecture specification, glossary, profile, or inventory, that canonical
source governs.

The architecture is decided but not thereby realized or verified. Unless a
later approved Architecture Claim register says otherwise, the four-dimensional
claim state recorded by the current
[Architecture Claim trace register](../project/training-simulation-architecture-claim-traces.csv)
continues to govern. In particular, an accepted and included decision is not
evidence that conforming product software exists.

Text diagrams use these conventions:

- `[Name]` is a person, neighboring system, deployable unit, runtime
  composition, or responsibility module, as identified by each diagram title;
- `A --> B : label` is a directed relationship from A to B with the stated
  meaning;
- `A ==> B : immutable handoff` moves an immutable value or ownership without
  shared mutable state; and
- vertical order in a sequence is time order, while horizontal placement has no
  unstated meaning.

## `EDI-VIEW-001`: Document control and reading guide

| Control | Value |
| --- | --- |
| Purpose | Establish the description identity, status boundary, audience routes, notation, ownership, and view map. |
| Scope | This `SAD-003` description, its architectural drivers and solution strategy, and navigation among its nine views. |
| Stakeholders | All intended readers; especially the project owner, architecture maintainers, and reviewers. |
| Notation | Markdown links and tables; the global text-diagram conventions above; `EDI-VIEW-*`, `AC-*`, `ADR-*`, `ARCHSPEC-*`, and requirement identifiers are stable references. |
| Prerequisites | The document-level prerequisites and [ARCHSPEC-0010 view set](0010-cross-cutting-architecture-and-verification.md#software-architecture-description-view-set). |
| Authoritative inputs | [Documentation Inventory](../project/training-simulation-documentation-inventory.md) and [Domain Documentation](../agents/domain.md). The [architecture-description guidance](../research/software-architecture-document-guidance.md) is non-authoritative historical research used only as drafting guidance. |
| Architecture Claim mappings | [`AC-CROSSCUTTING-001`](0010-cross-cutting-architecture-and-verification.md#architecture-claim-register), `AC-CROSSCUTTING-011`, and `AC-CROSSCUTTING-012`; exact requirement relations are in the [claim trace register](../project/training-simulation-architecture-claim-traces.csv). |
| Relationships to other views | Routes each stakeholder to views 2–9 and supplies their shared notation and status boundary. |
| Owner | Project owner; the implementation team maintains the file. |
| Update triggers | Description identity, control metadata, stakeholder concerns, notation, canonical ownership, document population, or selected-view changes. |

### Stakeholder routes

| Stakeholder concern | Primary view | Supporting view |
| --- | --- | --- |
| Product boundary, neighboring systems, hosts, and processes | [System context and allocation](#edi-view-002-system-context-and-allocation) | [Runtime lifecycle](#edi-view-004-runtime-lifecycle-and-sequences) |
| Responsibility, dependencies, interfaces, and adapter seams | [Module and dependency structure](#edi-view-003-module-and-dependency-structure) | [Cross-cutting policies](#edi-view-007-cross-cutting-policies) |
| Lifecycle, timing, interaction, failure, and shutdown | [Runtime lifecycle and sequences](#edi-view-004-runtime-lifecycle-and-sequences) | [Concurrency and ownership](#edi-view-005-concurrency-and-ownership) |
| Mutable-state ownership, handoffs, waits, and capacity | [Concurrency and ownership](#edi-view-005-concurrency-and-ownership) | [Runtime lifecycle](#edi-view-004-runtime-lifecycle-and-sequences) |
| Content, trust, persistence, custody, and cleanup | [Content, trust, and retained-evidence paths](#edi-view-006-content-trust-and-retained-evidence-paths) | [Cross-cutting policies](#edi-view-007-cross-cutting-policies) |
| Configuration, outcomes, resources, security applicability, and Observability | [Cross-cutting policies](#edi-view-007-cross-cutting-policies) | [Verification and traceability](#edi-view-008-verification-and-traceability) |
| Claims, evidence, acceptance, and change impact | [Verification and traceability](#edi-view-008-verification-and-traceability) | [Risks and open work](#edi-view-009-risks-debt-assumptions-and-open-work) |
| Limitations, replacement triggers, and future baselines | [Risks, debt, assumptions, and open work](#edi-view-009-risks-debt-assumptions-and-open-work) | The view owning the affected concern |

### System purpose and architectural drivers

Sacramento is a multiplayer Training Simulation through which armed-forces
Teams rehearse shooting Scenarios that are impractical to reproduce at full
physical scale. The Development Baseline must support a complete Training
Session in Desktop Mode while preserving the later Virtual-Reality Mode seam;
the Simulation Engine is an internal means to that product outcome rather than
an independently general-purpose product.

The following small driver set explains the architecture. It is a navigation
summary only; the linked requirement remains the normative criterion and owns
its exact workload, threshold, evidence, and applicability.

| Driver, precedence, and observable scenario | Architectural response | Canonical criterion |
| --- | --- | --- |
| Training validity and human safety outrank every other quality. Teams must rehearse coordination and tactics without non-diegetic assistance changing the represented outcome. | The Session Authority owns canonical Simulation and Scenario truth; Presentation consumes non-authoritative Prediction; the Reference Personnel Recovery Scenario anchors representative closure. | [`GOAL-TRAINING-001` and `GOAL-TEAM-TACTICS-001`](../requirements/training-simulation-initial-requirements.md#goals), plus the [NFR quality precedence](../requirements/training-simulation-non-functional-requirements.md#quality-precedence) |
| Canonical consistency and retained-evidence completeness outrank latency. A candidate Canonical Tick must either commit with its reconstruction record or publish nothing. | Fixed-step authority, one exclusive mutable owner per state class, immutable revision-bound handoffs, and explicit commit/publication fences. | [`AC-RUNTIME-001` through `AC-RUNTIME-008`, `AC-CONCURRENCY-001` through `AC-CONCURRENCY-008`, and `AC-RETENTION-001` through `AC-RETENTION-006`](0010-cross-cutting-architecture-and-verification.md#architecture-claim-register) |
| Desktop Mode must remain temporally stable and responsive for one five-minute `Typical` and `Stress` workload on exact reference hardware. | Authority and client cadences remain independent; Observability exposes final-image intervals and correlated action submission, receipt, and presentation without making measurement authoritative. | [`NFR-DESKTOP-SMOOTHNESS-001`, `NFR-DESKTOP-STALL-001`, and `NFR-ACTION-RESPONSE-001`](../requirements/training-simulation-non-functional-requirements.md#requirements), using [`RHP-DESKTOP-001` and `RHP-AUTHORITY-001`](../requirements/training-simulation-reference-hardware-profiles.md) |
| Tactical visual and acoustic information must remain evaluable under fixed task, content, hardware, and workload versions. | Presentation keeps rendering and acoustic adapters private; Representative Evaluation and peak-load evidence verify the Sacramento-facing outcome rather than a vendor technique. | [`NFR-VISUAL-VALIDITY-001`, `NFR-VISUAL-COVER-INVERSION-001`, `NFR-ACOUSTIC-LOCALIZATION-001`, and `NFR-ACOUSTIC-PEAK-001`](../requirements/training-simulation-non-functional-requirements.md#requirements) |
| The initial product must run on the accepted Windows client, headless Debian authority, and Controlled LAN while infrastructure remains external. | Role-specific Application Releases and immutable launch inputs cross orchestration-neutral seams; native executable closure is proved independently on each target. | [`CONSTRAINT-CLIENT-OS-001`, `CONSTRAINT-AUTHORITY-OS-001`, `CONSTRAINT-PLATFORM-MATRIX-001`, and `CONSTRAINT-NETWORK-MEDIUM-001`](../requirements/training-simulation-initial-requirements.md#platform-and-deployment-constraints) |
| Ongoing first-party engineering and maintenance must fit no more than two concurrently assigned human generalists. | Deep Sacramento modules contain vendor coupling behind small interfaces; dependency admission and replacement triggers prevent the selected foundation from becoming an irreversible maintenance burden. | [`CONSTRAINT-NFR-TEAM-001`](../requirements/training-simulation-non-functional-requirements.md#requirements) and [ARCHSPEC-0003 consequences](0003-nvidia-oriented-foundation.md#consequences) |

Numeric memory budgets and accepted Memory Snapshots remain unresolved current
work rather than an implied quality claim. Production authentication,
infrastructure availability, and Virtual-Reality Mode quality belong to their
named future baselines and do not alter the Development Baseline driver set.

### Solution strategy

| Fundamental approach | Connection to the drivers | Deliberate trade-off |
| --- | --- | --- |
| Canonical responsibility decomposition | Each state, policy meaning, failure rule, and retained-data class has one semantic owner behind a small Sacramento interface. | More explicit contracts and coordination in exchange for locality, testability, and bounded vendor coupling. |
| Fixed-step Session Authority | One authority orders Intentions, commits canonical state, and publishes immutable confirmed views independently of client presentation cadence. | Latency and availability cannot override canonical integrity; authority loss ends the Training Session rather than resuming ambiguous live state. |
| Immutable, exact-version closure | Application Releases, Runtime Content Releases, Runtime Launch Specifications, profiles, and role packs are validated as complete exact combinations before readiness or Admission. | No dynamic discovery, compatible ranges, hot replacement, migration, or automatic fallback in the initial baseline. |
| Exclusive ownership and immutable handoff | Mutable state never crosses an owner boundary; revision-bound values and visible fences carry results between execution domains. | Explicit handoffs, bounded queues, and backpressure are accepted to prevent shared-state races and hidden lifetime coupling. |
| Private foundation adapters | C++23 product modules expose Sacramento types while selected rendering, physics, audio, transport, ECS, import, and profiling mechanisms remain private. | The NVIDIA-oriented foundation gains focused capability but stays conditionally admitted and replaceable at demonstrated seams. |
| Cumulative verification and explicit evidence impact | Static closure, interface contracts, native executables, and representative sequences answer different questions; registered dependency paths govern re-verification. | Additional inventory and evidence maintenance prevents architecture approval from being mistaken for realization or product acceptance. |

## `EDI-VIEW-002`: System context and allocation

| Control | Value |
| --- | --- |
| Purpose | Show the Training Simulation boundary, people and neighboring systems, deployable-unit classes, target platforms, and external seams. |
| Scope | Initial Desktop Mode operation, offline content and administrative work, and the external systems that host or receive Sacramento contracts. |
| Stakeholders | Project owner, architects, operators, infrastructure owners, security reviewers, implementers, and verification authors. |
| Notation | Context/allocation text diagram. Boxes are typed in the legend; arrows are connections, invocations, or immutable handoffs and never shared ownership. Cardinalities apply to one accepted deployment. |
| Prerequisites | Canonical domain and technical glossaries; ADR-0008 and ADR-0009. |
| Authoritative inputs | [Initial requirements](../requirements/training-simulation-initial-requirements.md), [ARCHSPEC-0008](0008-evidence-and-ephemeral-state.md), and [ARCHSPEC-0009](0009-runtime-deployment-contracts.md). |
| Architecture Claim mappings | `AC-DEPLOYMENT-001` through `AC-DEPLOYMENT-010`, plus `AC-RETENTION-001`, `AC-RETENTION-002`, and `AC-RETENTION-004`; exact requirement relations are in the [claim trace register](../project/training-simulation-architecture-claim-traces.csv). |
| Relationships to other views | Allocates the runtime compositions from view 3, the processes and sequences from view 4, and the external handoffs from view 6. |
| Owner | Project owner; runtime-composition and seam owners maintain their source specifications. |
| Update triggers | Product-boundary, role, neighboring-system, deployable-unit, platform, endpoint, host-allocation, external-handoff, security-baseline, or operations-baseline changes. |

### Initial context and allocation

```text
Context/allocation view — initial accepted architecture

[Trainee: person, 0..16]
    --> [Trainee Client Runtime: Windows process, one Training Session]
            --> [Session Authority Runtime: headless Debian process, 0..1 per host]
                : assigned endpoint over the Controlled LAN

[Content author/operator: person]
    --> [Content Cooker Tool: one finite offline job]
            ==> [External provisioning: neighboring system]
                : immutable Runtime Content Release

[Operator/test harness: person or neighboring system]
    --> [Administrative Tools: offline, on demand]
    --> [External provisioning: neighboring system]
        ==> [Client and Authority Runtimes] : immutable launch inputs

[Session Authority Runtime]
    ==> [External custody and Trainee Performance Assessment: neighboring systems]
        : contract-specific asynchronous records
```

The Training Simulation product includes its Sacramento runtime and offline
tooling behavior. The Simulation Engine is an internal, need-specific
foundation rather than another product. External infrastructure owns placement,
process launch, supervision, and immutable provisioning; Sacramento owns the
orchestration-neutral launch, readiness, endpoint, shutdown, and exit
contracts. The accepted allocation is one active Session Authority Runtime per
`RHP-AUTHORITY-001` host and no co-located Trainee Client.

The neighboring custody and assessment systems remain behind independent
contract seams. Their products, topology, availability, storage, and
replication are not selected here. Production authentication and infrastructure
availability likewise remain in the named future baselines identified in view
9.

### Build, packaging, and platform variants

The build architecture requires C++23 role-specific artifacts to be produced
from one pinned Ubuntu build root. Debian artifacts use Clang and the Debian
target profile; Windows artifacts use Linux-hosted `clang-cl`, `llvm-lib`, and
`lld-link` with immutable MSVC STL/CRT and Windows SDK sysroot inputs. Windows
runtime, performance, signing, and formal acceptance still execute on native
Windows, while Debian runtime closure is proved independently on Debian.

An Application Release contains exactly one executable runtime and dependency
closure for one role and platform. Initial variants are the Windows Trainee
Client Runtime, headless Debian Session Authority Runtime, offline Content
Cooker Tool, and applicable Administrative Tools. Their exact
compatible combination with protocol, content, launch, Observability, and
external-integration contracts must be admitted by the Deployment
Compatibility Matrix before launch. Concrete installers, Debian archives,
container images, filesystem layouts, and distribution mechanisms remain
design or infrastructure choices.

C++ dependencies enter product builds through vcpkg, except for Falcor's
bounded offline vendor capsule. Vulkan is the sole initial graphics interface;
Falcor and Steam Audio remain private client/cooker adapters, and source import
remains offline behind the cooker. A custom graphical editor is a non-goal,
Falcor Python scripting does not define a runtime seam, and Virtual-Reality
Mode is a future variant. New optional modules or vendor features require a
concrete requirement, qualification, and an admitted role-specific closure;
build-time presence alone never creates product capability.

## `EDI-VIEW-003`: Module and dependency structure

| Control | Value |
| --- | --- |
| Purpose | Show responsibility modules, runtime compositions, dependency direction, interfaces, adapters, and demonstrated variation seams. |
| Scope | Architecture-level module ownership and dependencies, not source directories, classes, or detailed interfaces. |
| Stakeholders | Architects, designers, implementers, verification authors, and dependency reviewers. |
| Notation | Module/dependency text diagram. `A --> B` means A depends on the Sacramento interface owned by B; it never permits access to B's private mutable state. Runtime composition is listed separately from module dependency. |
| Prerequisites | ADR-0001 through ADR-0004 and the cross-cutting seam rules of ADR-0010. |
| Authoritative inputs | [ARCHSPEC-0003](0003-nvidia-oriented-foundation.md), [ARCHSPEC-0004](0004-canonical-responsibility.md), and [ARCHSPEC-0010](0010-cross-cutting-architecture-and-verification.md). |
| Architecture Claim mappings | `AC-TOOLCHAIN-001` through `AC-TOOLCHAIN-002`, `AC-FOUNDATION-001` through `AC-FOUNDATION-007`, `AC-DECOMPOSITION-001` through `AC-DECOMPOSITION-006`, and `AC-CROSSCUTTING-003` through `AC-CROSSCUTTING-005`; exact requirement relations are in the [claim trace register](../project/training-simulation-architecture-claim-traces.csv). |
| Relationships to other views | Supplies module and runtime-composition elements to views 2, 4, 5, 6, and 7; view 8 verifies its dependency and interface rules. |
| Owner | Project owner; each named responsibility owns its module interface and private adapters. |
| Update triggers | Module responsibility, interface invariant, runtime composition, dependency direction, adapter ownership, selected foundation, or future-role seam changes. |

### Responsibility shape

Sacramento uses deep modules: each presents a small Sacramento-owned interface
while concentrating substantial canonical behavior, state, and failure rules
behind it. The interface is also the test surface. A seam exists only where
behavior actually varies, controlled failure must be injected, or ownership is
independently governed. Vendor and platform mechanisms are private adapters,
not public modules.

The complete responsibilities and runtime membership are canonical in
[ARCHSPEC-0004](0004-canonical-responsibility.md#responsibility-modules). The
architecture-level dependency subset is:

```text
Module/dependency view — arrows point from caller to interface owner

[Content Cooker Tool] ----> [Runtime Package]
[Content Admission] ------> [Runtime Package]
[Simulation] -------------> [Content Admission]
[Scenario] ---------------> [Content Admission]
[Prediction] -------------> [Protocol & Replication]
[Presentation] -----------> [Prediction]
[Input & Interaction] ----> [Protocol & Replication]

[Behavior-owning modules] -> [Observability]
[Runtime compositions] ----> [Modules they compose]
```

The diagram's named elements have these responsibilities; the canonical full
population and runtime membership remain in ARCHSPEC-0004.

| Diagram element | Responsibility at this seam |
| --- | --- |
| `Content Cooker Tool` | Coordinates one finite offline validation and production job through `Runtime Package`; it exposes no runtime lifecycle. |
| `Runtime Package` | Owns persistent runtime-package schema, deterministic codec, identity, integrity, version, and compatibility. |
| `Content Admission` | Validates and atomically activates one exact immutable content view. |
| `Simulation` | Owns canonical simulated state, Simulated Time transitions, and authoritative simulation results. |
| `Scenario` | Owns configured objectives, progression, duration, and resolved terminal result. |
| `Protocol & Replication` | Owns Sacramento wire schemas, ordering, replication, and compatibility independently of transport and Simulation internals. |
| `Prediction` | Derives replaceable non-authoritative client state from confirmed updates and local Intentions. |
| `Presentation` | Produces Trainee-facing visual and acoustic output from Prediction without owning canonical state. |
| `Input & Interaction` | Interprets platform-device input and constructs local Intentions without deciding their canonical outcome. |
| Behavior-owning modules | Denotes every module that emits its own stable signals through the `Observability` interface without transferring ownership of their meaning. |
| `Observability` | Owns stable signal meaning, identity, correlation, loss semantics, and the emission interface. |
| Runtime compositions | Coordinate process lifecycle, ordering, failure, and multi-owner workflows without acquiring module-private state. |

The graph is acyclic and points toward the owner of meaning. Runtime
compositions coordinate only whole-process lifecycle, ordering, and
multi-owner workflows; they do not become owners of module-private state.
There is no generic Common, Platform, persistence, configuration, error,
resource, testing, or evidence module.

The Session Authority Runtime alone composes `Simulation`, `Scenario`, and
`Session Lifecycle`. The Trainee Client Runtime composes non-authoritative `Prediction`,
`Presentation`, and `Input & Interaction`. The Content Cooker Tool composes
`Runtime Package` with private import adapters. Administrative Tools
perform approved offline work, and the Synthetic Client Runtime exercises the
protocol without becoming a product role.

Flecs and PhysX remain private to `Simulation`; Falcor, Vulkan, Slang, and Steam
Audio remain private to applicable client/cooker adapters;
GameNetworkingSockets is transport behind `Protocol & Replication`; Assimp is
confined to the offline cooker; and Tracy is diagnostic behind `Observability`.
All are conditionally selected and remain subject to the exact qualification
and replacement rules in [ARCHSPEC-0003](0003-nvidia-oriented-foundation.md).

## `EDI-VIEW-004`: Runtime lifecycle and sequences

| Control | Value |
| --- | --- |
| Purpose | Explain startup, Admission, Preparation, fixed-step canonical execution, completion, client and authority failure, shutdown, and replacement. |
| Scope | One Training Session across its Session Authority and Trainee Client processes; offline cooking appears in view 6. |
| Stakeholders | Architects, designers, implementers, verification authors, operators, and Representative Evaluators. |
| Notation | Ordered lifecycle and sequence text diagrams. `->` advances after the preceding condition or commit; `||` denotes independently paced client work. |
| Prerequisites | ADR-0005 through ADR-0010 and the canonical time, identity, Admission, and Training Session terms. |
| Authoritative inputs | [ARCHSPEC-0005](0005-fixed-step-authoritative-runtime.md), [ARCHSPEC-0006](0006-runtime-ownership-and-failure.md), [ARCHSPEC-0007](0007-runtime-content-releases.md), [ARCHSPEC-0008](0008-evidence-and-ephemeral-state.md), [ARCHSPEC-0009](0009-runtime-deployment-contracts.md), and [ARCHSPEC-0010](0010-cross-cutting-architecture-and-verification.md). |
| Architecture Claim mappings | `AC-RUNTIME-001` through `AC-RUNTIME-008`, `AC-CONTENT-004` through `AC-CONTENT-006`, `AC-RETENTION-001`, `AC-RETENTION-003`, `AC-DEPLOYMENT-003` through `AC-DEPLOYMENT-005`, and `AC-DEPLOYMENT-008`; exact requirement relations are in the [claim trace register](../project/training-simulation-architecture-claim-traces.csv). |
| Relationships to other views | Uses allocation and module elements from views 2–3, crosses ownership fences in view 5, consumes content from view 6, and supplies executable sequences to view 8. |
| Owner | Project owner; `Session Lifecycle`, `Simulation`, and the applicable runtime compositions own their canonical behavior. |
| Update triggers | Lifecycle state, clock, tick phase, Intention ordering, publication, Admission, correction, completion, Technical Removal, shutdown, replacement, or representative-sequence changes. |

### Process and Training Session lifecycle

```text
Lifecycle view — one Session Authority process owns one Training Session

Process start
  -> validate one immutable Runtime Launch Specification and complete closure
  -> reserve capacity, bind endpoint, publish ProcessReady
  -> accept connections and perform mode-applicable Admission
  -> Preparation and explicit Trainee readiness
  -> Active fixed-step Simulation
  -> completion or non-normal termination fixes terminal truth
  -> seal retained evidence and attempt required durable receipt
  -> release resources, publish ProcessTerminated and exit classification
```

A process that fails before `ProcessReady` accepts no connection or Admission. The
Development Baseline exercises the same AUTH and Admission interface using only
launch-declared Synthetic Identities and explicitly unauthenticated evidence.
It does not perform or prove production authentication or authorization.

### Canonical Tick and client pacing

```text
Runtime sequence — authority and client cadences are independent

Authority at 240 Hz:
  seal eligible ordered Intentions
  -> derive candidate state and effects
  -> preserve complete reconstruction record
  -> atomically commit one Canonical Tick and composite state version
  -> publish immutable replication and evidence views

Client Prediction at 240 Hz || Presentation at 60 Hz:
  local Intention -> predicted view -> present
  confirmed immutable update -> correct/replace prediction -> present
```

Operational Clock, Simulated Time, presentation time, and Trusted Identity Time
remain distinct. Rendering cadence, transport jitter, and machine speed cannot
change canonical order or physical results. A rejected candidate tick publishes
nothing; failure after commitment cannot roll that tick back.

Loss of one active client connection ends its Admission and causes one atomic,
irreversible Technical Removal with cause `Disconnected`, while other Trainees
continue. Loss of the Session Authority terminates that Training Session and
discards live state. Any replacement is a new process, new endpoint identity,
and new Training Session from initial Scenario state; no retained record is a
session checkpoint.

The complete six architecture-dominating success and failure sequences are
selected in [ARCHSPEC-0010](0010-cross-cutting-architecture-and-verification.md#architecture-level-verification);
they are verification scenarios, not additional runtime decisions.

## `EDI-VIEW-005`: Concurrency and ownership

| Control | Value |
| --- | --- |
| Purpose | Make execution domains, exclusive mutable owners, immutable handoffs, publication fences, permitted waits, capacity, and failure scopes visible. |
| Scope | Session Authority and Trainee Client concurrency at architecture level; exact threads, queues, and schedulers remain design choices. |
| Stakeholders | Architects, designers, implementers, verification authors, and performance reviewers. |
| Notation | Ownership/handoff text diagram. A box is an exclusive mutable owner; `==>` crosses ownership with an immutable revision-bound value; `|fence|` is a visible commit or publication point. |
| Prerequisites | ADR-0005, ADR-0006, and ADR-0008. |
| Authoritative inputs | [ARCHSPEC-0005](0005-fixed-step-authoritative-runtime.md), [ARCHSPEC-0006](0006-runtime-ownership-and-failure.md), and [ARCHSPEC-0008](0008-evidence-and-ephemeral-state.md). |
| Architecture Claim mappings | `AC-CONCURRENCY-001` through `AC-CONCURRENCY-008`, `AC-RUNTIME-004` through `AC-RUNTIME-006`, and `AC-RETENTION-003` through `AC-RETENTION-005`; exact requirement relations are in the [claim trace register](../project/training-simulation-architecture-claim-traces.csv). |
| Relationships to other views | Applies ownership and scheduling rules to modules in view 3 and sequences in view 4; identifies commit and handoff points followed by views 6–8. |
| Owner | Project owner; each responsibility module exclusively owns its mutable state and resources. |
| Update triggers | Mutable-state ownership, execution-domain, handoff, fence, permitted-wait, capacity, backpressure, failure-containment, or cleanup-order changes. |

### Ownership and handoff model

```text
Concurrency view — values crossing boxes are immutable and revision-bound

[Input & Interaction owner]
    ==> [Protocol & Replication owner]
        ==> [Simulation owner] |Canonical Tick commit fence|
            ==> [Protocol & Replication owner]
                ==> [Prediction owner] |correction/publication fence|
                    ==> [Presentation owner]

[Responsibility owners] ==> [Observability owner] : non-authoritative facts
[Simulation owner] ==> [retained-evidence adapter] : committed records only
```

Each mutable state class has exactly one exclusive owner. Cross-owner work uses
revision-bound immutable values or explicit one-source/one-recipient ownership
transfer. Callback threads, vendor workers, transport delivery, devices, and
collectors cannot mutate canonical state directly.

Execution domains follow responsibility rather than arbitrary worker
ownership. The Canonical Tick waits only at its declared commit fences; all
other waits and asynchronous work are bounded outside it. Capacity is reserved
before Admission, every ingress has deterministic backpressure, and exhaustion
produces the owner-specific stable outcome. Cross-owner atomic work has one
semantic coordinator and one visible commit point.

Failure is contained to the smallest scope consistent with canonical
integrity: a client loss removes one Trainee, an asynchronous assessment or
ordinary export failure cannot change Simulation, and a canonical-integrity
failure terminates the Training Session. Acquisition follows dependency order;
shutdown releases in reverse order within the admitted bound.

## `EDI-VIEW-006`: Content, trust, and retained-evidence paths

| Control | Value |
| --- | --- |
| Purpose | Show cook-to-runtime content flow, immutable selection, distinct trust domains, retained-data commit and custody, and cleanup. |
| Scope | Runtime Content Releases and every architecture-level retained data class; concrete formats, databases, credentials, and storage products remain outside scope. |
| Stakeholders | Content-pipeline designers, architects, implementers, security reviewers, evidence custodians, operators, and verification authors. |
| Notation | Data-flow text diagrams. `==>` carries an immutable identified artifact or record; `|commit|` is the owner-defined point after which a retained candidate may survive process loss. |
| Prerequisites | ADR-0007 through ADR-0010 and ADR-0012, with their named content, identity, evidence, deployment, and Runtime Resource terms. |
| Authoritative inputs | [ARCHSPEC-0007](0007-runtime-content-releases.md), [ARCHSPEC-0008](0008-evidence-and-ephemeral-state.md), [ARCHSPEC-0009](0009-runtime-deployment-contracts.md), [ARCHSPEC-0010](0010-cross-cutting-architecture-and-verification.md), and [ARCHSPEC-0012](0012-runtime-resource-and-role-pack-architecture.md). |
| Architecture Claim mappings | `AC-CONTENT-001` through `AC-CONTENT-007`, `AC-RETENTION-001` through `AC-RETENTION-006`, `AC-DEPLOYMENT-006` through `AC-DEPLOYMENT-008`, `AC-RESOURCE-*`, and `AC-TOOLING-001` through `AC-TOOLING-005`; exact requirement relations are in the [claim trace register](../project/training-simulation-architecture-claim-traces.csv). |
| Relationships to other views | Supplies immutable runtime inputs to views 2 and 4, follows the ownership rules in view 5, applies policies from view 7, and exposes evidence dependencies to view 8. |
| Owner | Project owner; `Runtime Package`, `Content Admission`, and each retained data class's semantic owner maintain their source contracts. |
| Update triggers | Runtime-content identity, cook gate, pairing, signing, compatibility, activation, trust-domain, retained-data owner, commit, custody, retention, recovery, export, or cleanup changes. |

### Content path

```text
Content/data-flow view — one all-or-nothing pair for one exact Scenario

[Versioned authoring inputs]
  ==> [Content Cooker Tool: finite deterministic validate/cook/package/sign job]
      ==> [Authority Pack] + [Client Pack]
          : reciprocal identities, role contracts, hashes, provenance, trust
      ==> [Runtime Content Release]
          ==> [External provisioning]
              ==> [Runtime Launch Specification selects exactly one role pack]
                  ==> [Content Admission validates and eagerly materializes]
                      ==> [immutable runtime content view]
```

Any cooking-gate failure produces no usable successor. Each runtime validates
one explicit role pack completely before `ProcessReady`; peers prove the expected pack
pair before Admission. There is no directory discovery, newest-version lookup,
runtime import, download, hot replacement, fallback, migration, compatible
range, or automatic downgrade. Update and rollback select complete releases
only for later processes.

Role packs use the persistent identities, bounded acyclic dependency graph,
stored extents, typed borrowed handles, and owner materialization contracts in
[ARCHSPEC-0012](0012-runtime-resource-and-role-pack-architecture.md). The
Runtime Resource Type Inventory remains closed at zero admitted types until
its schema, representative resources, and evidence gates are approved.

### Trust and retained evidence

Content signing, Application Release trust, identity/AUTH trust,
administrative authority, and retained-evidence custody are separate trust
domains with independent provisioning, rotation, and compromise scopes. A
credential or result from one domain cannot authorize another.

```text
Retained-data view — semantic owners keep private persistence seams

[AUTH & Admission] |mode-applicable commit| ==> [AUTH audit custody]
[Simulation] |Canonical Tick commit| =======> [reconstruction records]
[Session Lifecycle] |terminal seal| =========> [Session Evidence Set custody]
[Observability] |signal acceptance| =========> [collector/custody]
[Performance Assessment] |assessment commit| => [assessment history]
```

Ordinary export is asynchronous, finite, acknowledged, retried idempotently,
and explicitly loss-accounted. Inability to preserve complete reconstruction
data rejects the candidate Canonical Tick; inability to obtain the required
terminal Session Evidence Set receipt changes clean exit to non-clean. An
administrative recovery may finish or classify an idempotent retained export,
but it never restores a Training Session. Live session state and uncommitted
candidates disappear with their owner process.

## `EDI-VIEW-007`: Cross-cutting policies

| Control | Value |
| --- | --- |
| Purpose | Gather the architecture-wide rules for configuration, outcomes, resources, testing, security applicability, Observability, and evidence hooks without creating a generic manager. |
| Scope | Stable conventions shared across responsibility-owned implementations and adapters. |
| Stakeholders | Architects, designers, implementers, verification authors, operators, security reviewers, and evidence custodians. |
| Notation | Policy matrix; each row names the semantic owner and points to its governing specification. |
| Prerequisites | ADR-0006 through ADR-0012. |
| Authoritative inputs | [ARCHSPEC-0006](0006-runtime-ownership-and-failure.md), [ARCHSPEC-0007](0007-runtime-content-releases.md), [ARCHSPEC-0008](0008-evidence-and-ephemeral-state.md), [ARCHSPEC-0009](0009-runtime-deployment-contracts.md), [ARCHSPEC-0010](0010-cross-cutting-architecture-and-verification.md), [ARCHSPEC-0011](0011-memory-accounting-and-allocation.md), and [ARCHSPEC-0012](0012-runtime-resource-and-role-pack-architecture.md). |
| Architecture Claim mappings | `AC-CROSSCUTTING-001` through `AC-CROSSCUTTING-012`, with supporting `AC-CONCURRENCY-*`, `AC-RETENTION-*`, `AC-DEPLOYMENT-*`, and `AC-MEMORY-*` claims; exact requirement relations are in the [claim trace register](../project/training-simulation-architecture-claim-traces.csv). |
| Relationships to other views | Constrains every runtime and data path in views 2–6; view 8 verifies the policies and traces their changes. |
| Owner | Project owner; each responsibility module owns policy meaning inside its interface. |
| Update triggers | Configuration, stable-outcome, retry, diagnostic, resource-lifetime, adapter-contract, test-seam, security-applicability, Observability, or evidence-hook changes. |

| Policy | Architecture rule and semantic owner | Governing detail |
| --- | --- | --- |
| Immutable configuration | The Runtime Launch Specification, Runtime Content Release, or applicable Approved Profile selects each execution-affecting value; each responsibility validates its own portion and runtime composition aggregates readiness. | [ARCHSPEC-0010 configuration](0010-cross-cutting-architecture-and-verification.md#immutable-configuration) |
| Stable outcomes | Interface failures cross as Sacramento outcomes identifying operation, category, affected scope, and permitted retry; native errors and sensitive diagnostics remain private. | [ARCHSPEC-0010 outcomes](0010-cross-cutting-architecture-and-verification.md#stable-outcomes-and-diagnostics) |
| Resource lifetime | The exclusive state owner also owns its resources and adapters, publishes only after complete validation, and releases in reverse dependency order. | [ARCHSPEC-0010 resources](0010-cross-cutting-architecture-and-verification.md#resource-lifetime-and-cleanup) |
| Memory accounting | Each allocation and API resource has one accounting owner and lifetime domain; budget and snapshot evidence remains blocked until approved configurations and representative measurements exist. | [ARCHSPEC-0011](0011-memory-accounting-and-allocation.md) |
| Runtime Resources | Persistent identities resolve through bounded role-pack graphs into typed borrowed handles owned and released by the applicable responsibility module. | [ARCHSPEC-0012](0012-runtime-resource-and-role-pack-architecture.md) |
| Test seams | Production, development, and test adapters at a real seam satisfy one Sacramento interface contract suite; test controls cannot bypass product interfaces or inspect private vendor state. | [ARCHSPEC-0010 tests](0010-cross-cutting-architecture-and-verification.md#test-interfaces-and-contract-surfaces) |
| Security applicability | The Development adapter admits only declared Synthetic Identities and unauthenticated test evidence; production-only fields and effects are absent, not invented. | [ARCHSPEC-0009 development AUTH](0009-runtime-deployment-contracts.md#non-production-auth-adapter-and-future-security) |
| Observability | `Observability` owns required signal meaning, identity, correlation, minimization, cardinality, and loss; behavior owners emit facts without ceding their decisions. | [Observability Contract](../requirements/training-simulation-observability-contract.md) |
| Evidence hooks | Applicable seams expose attributable operation, owner, version, correlation, outcome, capacity, commit/publication, causality, and loss facts; runtime hooks never assign `Pass`. | [ARCHSPEC-0010 evidence hooks](0010-cross-cutting-architecture-and-verification.md#evidence-hooks-and-change-impact) |

These policies are intentionally responsibility-owned. A runtime composition
may coordinate ordering and aggregate lifecycle outcomes, but it cannot become
a generic configuration, error, resource, persistence, testing, security, or
evidence module.

## `EDI-VIEW-008`: Verification and traceability

| Control | Value |
| --- | --- |
| Purpose | Connect Architecture Claims to requirements, artifacts, contract surfaces, native executable closure, representative sequences, evidence records, and conservative change impact. |
| Scope | Architecture-level verification and traceability; it does not claim product realization or substitute structural validation for substantive approval. |
| Stakeholders | Project owner, architects, implementers, verification authors, reviewers, Qualified Specialists, Representative Evaluators, and evidence custodians. |
| Notation | Traceability chain and verification-layer table. Arrows point from a changeable source toward dependent artifacts, procedures, views, or evidence. |
| Prerequisites | Verification Plan, ADR-0010, all three approved inventories, and views 2–7. |
| Authoritative inputs | [Verification Plan](../requirements/training-simulation-verification-plan.md), [Baseline Applicability Inventory](../requirements/training-simulation-baseline-applicability.md), [Baseline Artifact Inventory](../project/training-simulation-baseline-artifact-inventory.md), [Evidence Dependency Inventory](../project/training-simulation-evidence-dependency-inventory.md), and [ARCHSPEC-0010](0010-cross-cutting-architecture-and-verification.md). |
| Architecture Claim mappings | Every `AC-*` row in the [Architecture Claim register](0010-cross-cutting-architecture-and-verification.md#architecture-claim-register), especially `AC-CROSSCUTTING-001`, `AC-CROSSCUTTING-005` through `AC-CROSSCUTTING-012`; exact artifact and requirement relations are in the [claim trace register](../project/training-simulation-architecture-claim-traces.csv). |
| Relationships to other views | Verifies the elements, relationships, policies, sequences, and risks in views 2–7 and routes changes back to every reachable view, including view 9. |
| Owner | Project owner approves; implementation team maintains inventories and executes applicable verification. |
| Update triggers | Requirement, applicability, artifact, Architecture Claim, view, module interface, verification assignment, procedure, environment, input, output, relation, evidence, or approval changes. |

### Trace and status model

```text
Traceability view — arrows mean “change can affect”

[Requirement identifier]
  --> [Governed artifact]
  --> [Architecture Claim]
  --> [SAD view]
  --> [Verification procedure + exact inputs/environment]
  --> [Pre-registered evidence record]
  --> [Project-owner exact-version approval]
```

The authoritative exact mappings live in the
[Baseline Artifact registers](../project/training-simulation-baseline-artifact-inventory.md#inventory-package)
and [Evidence Dependency registers](../project/training-simulation-evidence-dependency-inventory.md#inventory-package).
This diagram expresses the navigation shape only. Decision, baseline
applicability, realization, and evidence are independent states; issue, ADR,
SAD, or inventory approval changes none of the others by implication.

| Verification layer | Question | Minimum architecture surface |
| --- | --- | --- |
| Static closure | Is each claim explicit, applicable, owned, traced, and structurally consistent? | Claims, SAD views, dependency rules, inventories, compatibility declarations, and prohibited-dependency inspection |
| Interface contract | Does every adapter preserve its Sacramento seam under success and controlled failure? | Shared adapter contract suites and owner-interface tests |
| Native executable closure | Does each executable run on its admitted native target using only its declared immutable closure? | Windows Trainee Client, Debian Session Authority, the Content Cooker Tool after platform admission, and applicable administrative tools |
| Representative sequences | Do independently valid seams compose into the required end-to-end outcomes? | Reference Personnel Recovery success and the six architecture-dominating success/failure sequences selected by ARCHSPEC-0010 |

No layer substitutes for another. Structural validators establish population,
identity, link, digest, and graph facts but cannot prove semantic completeness,
runtime behavior, canonicality, or approval. A product evidence result cannot
receive `Pass` while its obligation key, input, environment, relation, or output
is absent or stale.

After a governed change, impact analysis starts at every changed registered
node and follows every outgoing path. Missing, stale, unclassified, or
ambiguous information is `Uncertain` and requires reverification. An accepted
result may remain `Unaffected` only under the approved no-path or reproducible
obligation-level invariance rules, with the required exact record and
project-owner approval.

## `EDI-VIEW-009`: Risks, debt, assumptions, and open work

| Control | Value |
| --- | --- |
| Purpose | Make known limitations, blockers, assumptions, future baselines, issues, and replacement triggers visible without presenting them as current architecture. |
| Scope | Architecture-significant unresolved realization, qualification, evidence, and future-baseline work. |
| Stakeholders | Project owner, architects, planners, implementers, dependency reviewers, operators, security reviewers, and verification authors. |
| Notation | Status table. `Current blocker` prevents the named current claim; `Future baseline` is intentionally outside Development Baseline applicability; `Assumption/trigger` must be re-evaluated when its condition changes. |
| Prerequisites | ADR-0001 through ADR-0012, approved requirements and inventories, retained evidence, and current issue state. |
| Authoritative inputs | [ADRs](../adr/), [requirements](../requirements/training-simulation-initial-requirements.md), [foundation qualification](0003-nvidia-oriented-foundation.md#qualification-and-admission), [memory accounting](0011-memory-accounting-and-allocation.md), [Runtime Resource architecture](0012-runtime-resource-and-role-pack-architecture.md), [Runtime Resource Type Inventory](training-simulation-runtime-resource-type-inventory.md), [Evidence Dependency Inventory](../project/training-simulation-evidence-dependency-inventory.md), and the [architecture map issue](https://github.com/sergioffpc/sacramento/issues/8). |
| Architecture Claim mappings | Deferred `AC-DECOMPOSITION-006` and `AC-DEPLOYMENT-010`, conditional `AC-FOUNDATION-001` through `AC-FOUNDATION-007`, the status/impact claims `AC-CROSSCUTTING-001`, `AC-CROSSCUTTING-006` through `AC-CROSSCUTTING-010`, and all `AC-MEMORY-*` and `AC-RESOURCE-*` claims; exact states and requirements are in the [claim trace register](../project/training-simulation-architecture-claim-traces.csv). |
| Relationships to other views | Qualifies claims made by views 2–8 and routes each open item to the view that must change if its governing decision changes. |
| Owner | Project owner; the named artifact, module, dependency, verification, or future-baseline owner resolves each item. |
| Update triggers | Risk disposition, accepted debt, assumption, evidence, issue state, dependency qualification, maintenance measurement, replacement trigger, baseline applicability, or future-baseline change. |

| Status | Open item and consequence | Owner / trigger / canonical source |
| --- | --- | --- |
| Current blocker | Every selected direct and transitive dependency remains subject to production admission. The five named exception classes and unproved obligations prevent the conditional foundation decision from being represented as qualified product closure. | Dependency owners; exact gates and replacement conditions in [ARCHSPEC-0003](0003-nvidia-oriented-foundation.md#qualification-and-admission). |
| Current blocker | Product realization, obligation keys, approved product profiles and content, native executable evidence, and product acceptance remain absent. Architecture and inventory approval cannot create them. | Implementation team and project owner; [current EDI acceptance boundary](../project/training-simulation-evidence-dependency-inventory.md#current-acceptance-boundary). |
| Current blocker | Numeric memory budgets, representative CPU/GPU measurements, enforcement coverage, and accepted Memory Snapshots remain absent; memory claims stay `Not Implemented` with blocked evidence. | Memory Accounting Owners and verification authors; [ARCHSPEC-0011 evidence gaps](0011-memory-accounting-and-allocation.md#verification-obligations-and-evidence-gaps). |
| Current blocker | The Runtime Resource Type Inventory admits zero types, so exact schemas, structural limits, representative Authority/Client resources, materialization evidence, and compatibility evidence remain absent. | Resource semantic owners and project owner; [ARCHSPEC-0012 verification](0012-runtime-resource-and-role-pack-architecture.md#verification-and-acceptance) and [RRTI-001](training-simulation-runtime-resource-type-inventory.md). |
| Assumption/trigger | Ongoing first-party engineering and maintenance must fit no more than two concurrently assigned human generalists. A mechanism whose measured integration, qualification, upgrade, or operational burden exceeds that ceiling must be simplified or replaced behind its Sacramento interface; Falcor is first in line. | Project owner and implementation team; `CONSTRAINT-NFR-TEAM-001` and [ARCHSPEC-0003 consequences](0003-nvidia-oriented-foundation.md#consequences). |
| Assumption/trigger | Initial acceptance admits one active Session Authority per `RHP-AUTHORITY-001` host. Greater density requires a later Deployment Profile and independent proof of reservations, isolation, endpoints, artifacts, and workloads. | Platform profile owner; [ARCHSPEC-0009 allocation](0009-runtime-deployment-contracts.md#deployment-context-and-allocation). |
| Future baseline | Autonomous Participants are not initial Trainees or Synthetic Client Runtimes. Their approved future requirements do not admit a product role, module, interface, implementation, or evidence. | Future Autonomous Participant baseline; [requirements](../requirements/training-simulation-autonomous-participant-requirements.md) and issue [#26](https://github.com/sergioffpc/sacramento/issues/26). |
| Future baseline | Production authentication and authorization, protected exchange, durable AUTH audit and recovery, revocation, authenticated evidence custody, operational trust, and production adapter qualification are not supplied by permissive Development AUTH. | Production Security Baseline; `DEFERRED-PRODUCTION-SECURITY-001` and [ARCHSPEC-0009 security boundary](0009-runtime-deployment-contracts.md#non-production-auth-adapter-and-future-security). |
| Future baseline | Kubernetes resources, scheduling, supervision, capability availability, redundancy, failover, topology, hardening, secrets, operational credentials, and alert routing remain outside Sacramento's orchestration-neutral runtime contract. | Platform Operations Baseline; `DEFERRED-PLATFORM-OPERATIONS-001` and [ARCHSPEC-0009 deployment boundary](0009-runtime-deployment-contracts.md). |

An open item changes this architecture only through its governed successor.
Detailed design must not close an architecture risk by choosing a new
system-structural rule inside an implementation plan.

## Description change control

Under `PROCESS-ARCHITECTURE-UPDATE-001`, any governing requirement, ADR,
Architecture Claim, module interface, inventory disposition, or evidence
dependency change starts at its registered node in the current approved
Evidence Dependency Inventory. The implementation team reviews every reachable
`EDI-VIEW-*` section and retained architecture-verification result, records all
affected or uncertain results, and creates the applicable SAD and inventory
successors. Editorial changes that preserve meaning still update the exact
artifact version and therefore require inventory reconciliation.

The project owner approves only the exact reconciled description and inventory
versions after applicable validation and independent Standards and Spec review.
