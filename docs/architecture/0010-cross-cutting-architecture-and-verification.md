# Architecture specification: cross-cutting architecture and verification

Status: Accepted architecture decision; implementation,
evidence, and baseline acceptance remain incomplete

Approval: Project owner, 2026-09-03

Latest approved amendment: Autonomous Participant decomposition trace, project owner, 2026-09-04

Purpose: Define the remaining cross-cutting contracts, architecture-level
verification strategy, claim traceability, evidence-impact behavior, and
Software Architecture Description view set for the Development Baseline.

Owner: Project owner

Sacramento closes its Development Baseline architecture decisions without
claiming that the decided architecture is implemented, verified, production
secure, operationally available, or accepted as a product baseline.
Cross-cutting behavior remains behind the interface of the responsibility
module that owns its meaning. Runtime compositions coordinate whole-process
ordering and aggregate lifecycle outcomes but do not become a generic
configuration, error, resource, testing, or evidence module.

Architecture verification is cumulative: static closure, interface and adapter
contract tests, native executable closure, and a small set of representative
success and failure sequences each answer different questions. Architecture
claims and evidence dependencies are explicit so a future change cannot retain
evidence merely because no reviewer happened to notice an unstated coupling.

## Decision and baseline status

Architecture decision state is independent from realization and evidence.
Every normative Architecture Claim has four states:

| Dimension | Closed values | Meaning |
| --- | --- | --- |
| Decision | `Accepted`, `Deferred`, `Superseded` | Whether the architectural choice currently governs |
| Baseline applicability | `Included`, `Future`, `Not Applicable` | Whether the claim belongs to the candidate baseline |
| Realization | `Not Implemented`, `Partial`, `Implemented` | Whether a conforming product realization exists |
| Evidence | `Not Run`, `Blocked`, `Fail`, `Pass` | The accepted verification disposition |

Issue or ADR closure changes only the decision dimension. An `Accepted` claim
cannot imply implementation, evidence, dependency admission, production
security, platform availability, or baseline approval. A claim can support
baseline acceptance only when it is `Included`, `Implemented`, and supported by
every required obligation-level `Pass` disposition.

Each claim uses one stable `AC-*` key distinct from a requirement identifier or
verification-obligation key. Its record identifies the governing requirements,
canonical decision or view, owner, verification surface, evidence hooks, and
all four states. Changing the meaning creates a new claim key; editorial change
does not.

## Responsibility-owned cross-cutting seams

There is no cross-cutting manager. The deletion test for each proposed module
or seam remains whether its removal would force meaningful complexity back
into several callers. A seam exists for demonstrated variation, failure
injection, or independently governed ownership, not to wrap each mechanism.

### Immutable configuration

Every execution-affecting value belongs to an immutable, identified view
selected by the Runtime Launch Specification, Runtime Content Release, or
applicable Approved Profile. Each responsibility module validates its own
portion and publishes nothing until that portion is complete. Runtime
composition verifies the complete selection and compatibility before `ProcessReady`.

After readiness, a module cannot discover a newest version, consult mutable
defaults, reinterpret the process environment, or read another module's
private configuration. A configuration change applies only to a later process
execution. Configuration identities cross seams; native environment, file, and
vendor representations remain private to adapters.

### Stable outcomes and diagnostics

An interface failure crosses its seam as a stable Sacramento outcome that
identifies the responsible operation, failure category, affected scope, and
whether that contract permits retry. Expected denial, invalid input, capacity
rejection, dependency unavailability, invariant failure, and process-fatal
failure remain distinguishable.

Native exceptions, error codes, device messages, transport details, and
security-sensitive diagnostics remain inside the adapter and governed
Observability. Runtime composition maps stable outcomes to the established
readiness, lifecycle, Training Session, and exit classifications. It cannot
invent domain meaning, broaden failure scope, or expose a native mechanism.

### Resource lifetime and cleanup

The module that exclusively owns mutable state also owns the lifetime of its
associated resources and private adapters. Acquisition follows declared
dependency order. A resource or immutable view becomes visible only after its
complete validation and applicable capacity reservation. Shutdown releases in
reverse dependency order within the admitted bound.

Cross-owner movement uses an immutable handoff or an explicit ownership
transfer with one source and one recipient. Cleanup failure cannot resurrect
live state, extend a Training Session, roll back a committed Canonical Tick, or
turn an uncommitted outcome into a committed one. Forced process loss discards
live resources; retained candidates remain governed only by their proved
commit points and ADR-0008.

### Security applicability

`AUTH & Admission` retains one Sacramento interface with mode-applicable
lifecycles and stable outcomes. Every configuration, adapter, operation, and
evidence record declares its mode. The Development Baseline adapter accepts
only launch-declared Synthetic Identities, produces no Canonical Identity Key,
and emits only explicitly unauthenticated test evidence.

Production-only fields and effects are absent in permissive mode rather than
populated with invented values. No permissive result satisfies authentication,
authorization, protected exchange, durable AUTH audit, revocation,
authenticated evidence custody, operational trust, Formal Assessment,
Leaderboard, or another Production Security Baseline obligation.

## Test interfaces and contract surfaces

Test adapters occupy only real seams or points requiring controlled variation
or failure injection: clocks, deterministic randomness, capacity, devices,
transport, immutable-artifact access, persistence, external custody,
Observability emission, and mode-applicable identity behavior. Tests receive
explicit profiles, clock observations, input sequences, and seeds through the
same Sacramento interfaces used by ordinary callers.

Every production, development, and test adapter at one seam runs the same
interface contract suite. Adapter-specific qualification adds evidence but
cannot replace that suite. A public test-only bypass, test-only mutation of
another owner's state, or assertion against private vendor state violates the
seam. Internal seams may support a module's own tests without becoming part of
its external interface.

Contract tests cover, where applicable:

- accepted inputs, closed rejections, stable outcomes, and retry rules;
- immutable configuration and exact version binding;
- ownership, publication, capacity, commit, and release ordering;
- cancellation, timeout, process-loss, exhaustion, and cleanup behavior;
- idempotent identity, acknowledgement, retry, and duplicate handling;
- absence of native platform, vendor, orchestrator, or test-only types; and
- evidence-hook cardinality, correlation, minimization, and explicit loss.

## Architecture-level verification

The verification layers accumulate:

| Layer | Question answered | Minimum surface |
| --- | --- | --- |
| Static closure | Is every claim explicit, applicable, owned, traced, and structurally consistent? | Architecture Claim records, views, dependency rules, inventories, compatibility declarations, and prohibited-dependency checks |
| Interface contract | Does each adapter preserve the Sacramento seam under success and controlled failure? | Shared adapter contract suites and owner-interface tests |
| Native executable closure | Can each executable run from only its declared immutable closure on its admitted target? | Windows Trainee Client, Debian Session Authority, and admitted offline tools; Content Cooker native closure waits for platform admission |
| Representative sequences | Do independently valid seams compose into the required end-to-end outcomes? | Reference Personnel Recovery success and the smallest set of architecture-dominating failures |

Static inspection cannot prove executable closure. A contract suite cannot
prove native packaging or whole-runtime composition. A demonstration cannot
replace exhaustive contract negatives or obligation-level evidence.

Native executable closure runs each role on its applicable native platform
using only the exact Application Release, declared immutable artifacts, and
approved dependencies. It covers startup, readiness, representative contract
exercise, shutdown, and negative cases for missing, unexpected, incompatible,
or undeclared dependencies. Build-graph or directory inspection is supporting
evidence, never the execution result.

The required representative sequence set is:

1. complete launch, permissive development Admission, Preparation, active
   Reference Personnel Recovery behavior, completion, durable terminal
   evidence receipt, and clean exit;
2. startup rejection before `ProcessReady` for an invalid or incompatible launch,
   content, profile, capacity, adapter, or destination;
3. loss of one client connection causing only that Trainee's Technical Removal;
4. Session Authority loss followed by a new process and new Training Session
   without restoration or continuity;
5. external-handoff unavailability through finite buffering, retry, recovery,
   explicit loss, reconstruction-capacity exhaustion, and terminal-receipt
   failure; and
6. rejection of a candidate Canonical Tick before commitment and failure after
   commitment, preserving atomicity and the smallest safe termination scope.

Other failures are variations in contract suites unless they expose a distinct
cross-module ordering or ownership decision. The sequences do not establish
complete functional coverage.

## Evidence hooks and change impact

An applicable seam makes the following attributable when required by its
verification surface: stable operation identity; owning module and adapter;
process, Training Session, Admission, event, and Canonical Tick correlations;
exact Application Release, runtime content, configuration, profile, and
contract versions; start and terminal result; stable outcome and affected
scope; capacity or reservation; commit and publication points; causal
correlation; and loss or incompleteness.

These are semantic hooks, not a requirement to emit every field in every
production signal. The Observability Contract selects the continuously enabled
core subset. Test harnesses, retained records, and acceptance environments own
their other applicable evidence while preserving data minimization,
sensitivity, identity, cardinality, and loss rules. A runtime hook reports a
fact; it never calculates or assigns verification `Pass`.

Evidence impact follows `VERIFY-CHANGE-001`: inspect actual dependencies,
including transitive effects, and rerun affected or uncertain results. Retain a
result only with reproducible obligation-level invariance reasoning. The generated
reference index aids navigation but is not a complete semantic graph. ADR-0014
removes global graph approval and output pre-registration, not conservative impact.

## Architecture Claim register

The register below owns claim meaning and verification surfaces. Exact governing
source paths, expanded requirement relations and independent states live in the
[claim CSV](../project/training-simulation-architecture-claim-traces.csv).
No file listing, diagram or accepted decision implies product evidence.

Current states are recorded only in the linked claim CSV. Every row below is one independently governed architecture-level claim; examples,
rationale, and consequences in its canonical ADR do not create additional
normative claims.

| Claim and meaning | Canonical location | Primary requirement trace | Owner | Verification surface and evidence hooks |
| --- | --- | --- | --- | --- |
| `AC-TOOLCHAIN-001` — Clang is the sole C++ compiler | ADR-0001 | `CONSTRAINT-CPP-TOOLCHAIN-001` | Build composition | Toolchain identity and dual-target build |
| `AC-TOOLCHAIN-002` — Windows artefacts cross-build from the pinned Ubuntu root and execute natively for acceptance | ADR-0002 | `CONSTRAINT-CPP-TOOLCHAIN-001`, `CONSTRAINT-CLIENT-OS-001` | Build composition | Build-root identity, artefact provenance, native Windows result |
| `AC-FOUNDATION-001` — the selected narrow dependency composition is conditional on qualification | ARCHSPEC-0003 qualification | `CONSTRAINT-CPP-VERSION-001`, `CONSTRAINT-PLATFORM-MATRIX-001` | Runtime compositions | Qualified dependency graph and native builds |
| `AC-FOUNDATION-002` — product interfaces and persistent contracts expose only Sacramento types | ARCHSPEC-0003 interface rules | `SCOPE-PRODUCT-001`, `PREFERENCE-PLATFORM-PARITY-001` | Responsibility modules | Public-type and persistent-contract inspection |
| `AC-FOUNDATION-003` — the Debian Session Authority remains headless | ARCHSPEC-0003 interface rules | `CONSTRAINT-AUTHORITY-OS-001` | Session Authority composition | Native dependency and startup closure |
| `AC-FOUNDATION-004` — Falcor/Vulkan/Slang remain client rendering implementation details | ARCHSPEC-0003 interface rules | `CONSTRAINT-CLIENT-OS-001`, `PREFERENCE-PLATFORM-PARITY-001` | `Presentation` | Rendering adapter contracts and client dependency identity |
| `AC-FOUNDATION-005` — GameNetworkingSockets is transport only and Steam Audio owns no physical outcome | ARCHSPEC-0003 interface rules | `REQ-AUTHORITY-001`, `REQ-OVERPRESSURE-001` | `Protocol & Replication`, `Presentation` | Transport/acoustic adapter contracts and outcome traces |
| `AC-FOUNDATION-006` — diagnostic profiling cannot replace or alter core Observability | ARCHSPEC-0003 interface rules | `NFR-OBSERVABILITY-CORE-001`, `NFR-OBSERVABILITY-INTEGRITY-001` | `Observability` | CoreOnly/Diagnostic configuration and signal evidence |
| `AC-FOUNDATION-007` — Falcor's offline vendor capsule is the sole dependency-management exception | ARCHSPEC-0003 qualification | `CONSTRAINT-CPP-TOOLCHAIN-001`, `CONSTRAINT-NFR-TEAM-001` | Build composition | Capsule identity, offline-build, patch, and maintenance evidence |
| `AC-DECOMPOSITION-001` — deep modules follow canonical responsibility | ARCHSPEC-0004 responsibility modules | `SCOPE-PRODUCT-001`, `CONSTRAINT-NFR-TEAM-001` | Responsibility modules | Responsibility and interface inspection |
| `AC-DECOMPOSITION-002` — each runtime explicitly composes only its required modules | ARCHSPEC-0004 runtime compositions | `CONSTRAINT-CLIENT-OS-001`, `CONSTRAINT-AUTHORITY-OS-001` | Runtime compositions | Role-specific dependency closure |
| `AC-DECOMPOSITION-003` — module dependencies are acyclic and point toward canonical owners | ARCHSPEC-0004 dependency view | `REQ-AUTHORITY-001`, `REQ-STATE-CONSISTENCY-001` | Responsibility modules | Static dependency and mutation-path negatives |
| `AC-DECOMPOSITION-004` — vendor/platform integrations remain private adapters at real seams | ARCHSPEC-0004 adapter rules | `PREFERENCE-PLATFORM-PARITY-001` | Each interface owner | Common adapter contracts and public-type inspection |
| `AC-DECOMPOSITION-005` — Prediction and Presentation cannot author canonical outcomes | ARCHSPEC-0004 failure rules | `REQ-CLIENT-TRUST-001`, `REQ-STATE-CONSISTENCY-001` | `Prediction`, `Presentation` | Authority and client-failure sequences; state versions |
| `AC-DECOMPOSITION-006` — Autonomous Participants require a future named baseline | ARCHSPEC-0004 future baseline | `SCOPE-ROLE-001`, `REQ-AUTONOMOUS-SCOPE-001`, `REQ-AUTONOMOUS-SCOPE-002`, `REQ-AUTONOMOUS-CONTROL-BOUNDARY-001` | Future Autonomous Participant baseline | Scope and requirement inspection |
| `AC-RUNTIME-001` — authoritative Simulation advances in fixed Canonical Ticks | ARCHSPEC-0005 time profiles | `REQ-AUTHORITY-001`, `REQ-STATE-CONSISTENCY-001` | `Simulation` | Tick index, Simulated Time, state version |
| `AC-RUNTIME-002` — Operational Clock, Simulated Time, presentation time, and Trusted Identity Time remain distinct | ARCHSPEC-0005 time profiles | `REQ-OPERATIONAL-CLOCK-001`, `REQ-OPERATIONAL-CLOCK-002` | Owning responsibility modules | Clock-source and equal-boundary tests |
| `AC-RUNTIME-003` — one process owns one complete Training Session lifecycle | ARCHSPEC-0005 lifecycle | `REQ-SERVER-SESSION-001`, `REQ-AUTHORITY-SINGLE-SESSION-001` | `Session Lifecycle` | Lifecycle transitions and process/session identities |
| `AC-RUNTIME-004` — each Canonical Tick is an atomic candidate/commit/publication transaction | ARCHSPEC-0005 tick transaction | `REQ-STATE-CONSISTENCY-001`, `REQ-SESSION-EVIDENCE-001` | `Simulation` | Commit/publication points and rejection/failure sequences |
| `AC-RUNTIME-005` — Intention admission and ordering are authority-owned and deterministic | ARCHSPEC-0005 intention ordering | `REQ-AUTHORITY-001`, `NFR-ACTION-RESPONSE-001` | `Protocol & Replication`, `Simulation` | Ordered intention/result correlation |
| `AC-RUNTIME-006` — Prediction is correctable and Presentation consumes committed immutable views | ARCHSPEC-0005 replication | `REQ-CLIENT-TRUST-001`, `REQ-STATE-CONSISTENCY-001` | `Prediction`, `Presentation` | Composite state versions and correction cases |
| `AC-RUNTIME-007` — committed ticks produce deterministic reconstruction evidence | ARCHSPEC-0005 replay | `REQ-SESSION-EVIDENCE-001`, `REQ-SESSION-EVIDENCE-002` | `Simulation`, retained-evidence adapter | Tick inputs, outcome, profile and content identities |
| `AC-RUNTIME-008` — a disconnected active Trainee receives irreversible Technical Removal | ARCHSPEC-0005 client loss | `REQ-TECHNICAL-REMOVAL-001` through `REQ-TECHNICAL-REMOVAL-006` | `Session Lifecycle`, `Simulation` | Connection-loss and removal state-version sequence |
| `AC-CONCURRENCY-001` — runtime execution domains follow responsibility rather than arbitrary worker ownership | ARCHSPEC-0006 execution domains | `REQ-STATE-CONSISTENCY-001` | Runtime compositions | Domain allocation and callback negatives |
| `AC-CONCURRENCY-002` — each mutable state class has one exclusive owner | ARCHSPEC-0006 exclusive ownership | `REQ-AUTHORITY-001`, `REQ-STATE-CONSISTENCY-001` | Responsibility modules | Writer inventory and cross-owner mutation negatives |
| `AC-CONCURRENCY-003` — cross-owner handoffs are immutable and publication-fenced | ARCHSPEC-0006 handoffs | `REQ-STATE-CONSISTENCY-001` | Producing and consuming owners | Version, queue, fence, stale/mixed-view tests |
| `AC-CONCURRENCY-004` — waits and work are bounded outside the Canonical Tick unless explicitly admitted | ARCHSPEC-0006 scheduling | `NFR-ACTION-RESPONSE-001`, `NFR-DESKTOP-STALL-001` | Runtime compositions | Budget, blocked-owner, timeout, and overload evidence |
| `AC-CONCURRENCY-005` — cross-owner atomicity uses one coordinator and visible commit point | ARCHSPEC-0006 atomicity | `REQ-STATE-CONSISTENCY-001` | Semantic coordinator | Before/after-boundary failure injection and commit identity |
| `AC-CONCURRENCY-006` — capacity is reserved before admission and exhaustion has deterministic backpressure | ARCHSPEC-0006 capacity | `REQ-CAPACITY-001`, `REQ-CAPACITY-002`, `REQ-CAPACITY-003` | Resource-owning modules | Capacity, reservation, rejection and release evidence |
| `AC-CONCURRENCY-007` — failure is contained to the smallest safe semantic scope | ARCHSPEC-0006 failure containment | `REQ-SESSION-DISCONNECT-001`, `REQ-AUTH-AUDIT-WRITE-FAILURE-001` | Owning module and runtime composition | Owner failure matrix and affected-scope result |
| `AC-CONCURRENCY-008` — startup, shutdown, and process loss preserve ownership and commit boundaries | ARCHSPEC-0006 process lifecycle | `REQ-AUTHORITY-TERMINAL-SETTLEMENT-001`, `REQ-AUTHORITY-TERMINAL-SHUTDOWN-001` | Runtime composition | Acquire/release order and process-loss sequence |
| `AC-CONTENT-001` — each Scenario version has one immutable paired Runtime Content Release | ARCHSPEC-0007 release identity | `REQ-CONTENT-RELEASE-001`, `REQ-CONTENT-PAIR-001` | `Runtime Package` | Release, pair, role, hash and contract identities |
| `AC-CONTENT-002` — cooking is deterministic, all-or-nothing, and provenance-complete | ARCHSPEC-0007 cooking; amended by ARCHSPEC-0013 | `REQ-CONTENT-PROCESSING-001`, `REQ-CONTENT-PROCESSING-RECORD-001` | Content Cooker Tool | Gate-step failures and processing record |
| `AC-CONTENT-003` — signing trust is scoped by pack role and runtime contract | ARCHSPEC-0007 signing and trust | `REQ-CONTENT-SIGNING-001`, `REQ-CONTENT-TRUST-001` | Content Cooker and `Content Admission` | Trust-reference, signer-role and signature negatives |
| `AC-CONTENT-004` — runtime activation is eager, immutable, explicit, and fail-fast | ARCHSPEC-0007 startup | `REQ-CONTENT-STARTUP-001`, `REQ-CONTENT-ACTIVATION-001` | `Content Admission` | Materialization and immutable-view publication |
| `AC-CONTENT-005` — client and authority reject a mismatched role-pack pair before Admission | ARCHSPEC-0007 pair matching | `REQ-CONTENT-MISMATCH-001`, `REQ-CONTENT-PAIR-ATOMIC-001` | `Content Admission`, `AUTH & Admission` | Peer/release/pack correlation and rejection |
| `AC-CONTENT-006` — one Session Authority process serves one Scenario and Training Session | ARCHSPEC-0007 process boundary | `REQ-SERVER-SESSION-001`, `REQ-AUTHORITY-SINGLE-SESSION-001` | Session Authority composition | Launch, session, terminal and exit identities |
| `AC-CONTENT-007` — retention, update, rollback, and cleanup never mutate an active release | ARCHSPEC-0007 retention | `REQ-CONTENT-RETENTION-001`, `REQ-CONTENT-ROLLBACK-001` | `Runtime Package`, external provisioning | Activation history and later-process selection |
| `AC-RESOURCE-001` — each semantic Runtime Resource has one persistent UUIDv4 identity, role-specific projection, and explicit authoring metadata | ARCHSPEC-0012 identity | `REQ-CONTENT-TRACEABILITY-001`, `REQ-CONTENT-PROCESSING-001` | `Runtime Package`, authoring tools | Metadata, move, rename, duplication, collision, Unicode, and role-projection vectors |
| `AC-RESOURCE-002` — a closed type inventory and local typed references preserve one semantic owner and borrowed runtime access | ARCHSPEC-0012 type model | `REQ-CONTENT-PACK-ROLE-001`, `REQ-CONTENT-ACTIVATION-001` | Runtime-resource responsibility owners | Inventory closure, local reference, owner, handle, and prohibited-manager tests |
| `AC-RESOURCE-003` — role-pack version one has one exact deterministic header, envelope, restricted manifest, extent, and Pack Core representation | ARCHSPEC-0012 pack format | `REQ-CONTENT-PAIR-001`, `REQ-CONTENT-VERSION-002` | `Runtime Package` | Golden, malformed, ordering, range, version, and cross-platform byte vectors |
| `AC-RESOURCE-004` — version-one trust uses Ed25519, SHA-256, full key identity, scoped authorization, and no algorithm negotiation | ARCHSPEC-0012 signing | `REQ-CONTENT-SIGNING-001`, `REQ-CONTENT-TRUST-001`, `REQ-CONTENT-COMPATIBILITY-001` | `Runtime Package` and Content Cooker Tool | Signature, digest, key, role, contract, rotation, and algorithm-negative vectors |
| `AC-RESOURCE-005` — authenticated external limits and owner budgets reserve complete capacity before payload processing | ARCHSPEC-0012 bounds | `REQ-RUNTIME-LAUNCH-SPECIFICATION-002`, `REQ-RUNTIME-READINESS-001` | `Content Admission`, resource-owning modules | Overflow, capacity function, reservation, attribution, and failure-precedence evidence |
| `AC-RESOURCE-006` — one authenticated local DAG is completely materialized behind owner fences and published atomically | ARCHSPEC-0012 validation and publication | `REQ-CONTENT-ACTIVATION-001`, `REQ-CONTENT-VERSION-002` | `Content Admission`, resource-owning modules | Graph, materializer, GPU fence, failure cleanup, and zero-or-one publication tests |
| `AC-RESOURCE-007` — the published view has no pack, content-I/O, mapping, reload, generation-replacement, or eviction dependency | ARCHSPEC-0012 publication | `REQ-CONTENT-IMMUTABILITY-001` | `Content Admission`, resource-owning modules | Post-readiness open/read negatives, pack mutation, handle lifetime, and shutdown evidence |
| `AC-RESOURCE-008` — deterministic Pack Cores and one atomic pair-publication commit preserve reproducibility and all-or-nothing releases | ARCHSPEC-0012 cooking; amended by ARCHSPEC-0013 | `REQ-CONTENT-PROCESSING-001`, `REQ-CONTENT-PAIR-ATOMIC-001` | Content Cooker Tool | Repeat-cook core comparison and every before/after publication failure boundary |
| `AC-RESOURCE-009` — initial synchronous buffered I/O remains until an approved startup target and dual-platform evidence justify compression or async | ARCHSPEC-0012 I/O | `PREFERENCE-PLATFORM-PARITY-001`, `CONSTRAINT-NFR-TEAM-001` | `Runtime Package`, implementation team | Native cold/warm stage timings, memory peaks, common contract suite, and adoption disposition |
| `AC-RESOURCE-010` — normative vectors, bounded fuzzing, failure injection, native determinism, and accumulating gates govern implementation admission | ARCHSPEC-0012 verification | `PROCESS-ARCHITECTURE-CONTRACT-001`, `PROCESS-ARCHITECTURE-VERIFICATION-001` | Implementation team and interface owners | Fixture identities, fuzz results, sanitizer results, native closure, and representative sequences |
| `AC-TOOLING-001` — the Content Cooker is one finite offline Tool Release and never a product runtime | ARCHSPEC-0013 classification | `REQ-CONTENT-COOKER-TOOL-001`, `DEFERRED-CONTENT-COOKER-PLATFORM-001` | Content Cooker Tool | Interface and dependency inspection; runtime-lifecycle negatives |
| `AC-TOOLING-002` — one closed immutable Cooking Job Specification is the sole source of execution-affecting values | ARCHSPEC-0013 identities | `REQ-COOKING-JOB-SPECIFICATION-001` | Content Cooker Tool | Golden schema, malformed input, environment, cwd, discovery, and override negatives |
| `AC-TOOLING-003` — one exhaustive deterministic authoring snapshot isolates every cook from live-source mutation | ARCHSPEC-0013 snapshot | `REQ-CONTENT-PROCESSING-001` | Content Cooker Tool | Entry classification, collision, symlink, mutation, ordering, and digest evidence |
| `AC-TOOLING-004` — Release Publisher durably exposes both packs and the processing record through one idempotent atomic commit | ARCHSPEC-0013 publication | `REQ-CONTENT-PAIR-ATOMIC-001`, `REQ-CONTENT-RELEASE-001` | Content Cooker Tool | Every commit boundary, retry equality, IdentityConflict, and staging-recovery evidence |
| `AC-TOOLING-005` — cooking copies trusted job provenance and keeps signing secrets behind the private signing seam | ARCHSPEC-0013 signing and provenance | `REQ-COOKING-JOB-PROVENANCE-001`, `REQ-CONTENT-SIGNING-001` | Content Cooker Tool | Provenance-source, trust, key-identity, secret-absence, and signing-failure evidence |
| `AC-RETENTION-001` — live Training Session state is ephemeral and non-restorable | ARCHSPEC-0008 ownership | `NON-GOAL-SESSION-SAVE-001`, `REQ-RUNTIME-REPLACEMENT-001` | Session Authority composition | Process-loss and restart negatives |
| `AC-RETENTION-002` — each retained data class keeps its semantic owner and private persistence seam | ARCHSPEC-0008 ownership | `REQ-SESSION-EVIDENCE-001`, `PROCESS-EVIDENCE-RETENTION-001` | Semantic owner of each class | Owner, commit, custody and retention identities |
| `AC-RETENTION-003` — Technical Removal withdraws only the disconnected Trainee and associated live items | ARCHSPEC-0008 client loss | `REQ-TECHNICAL-REMOVAL-003`, `REQ-TECHNICAL-REMOVAL-004` | `Session Lifecycle`, `Simulation` | Atomic removal and unaffected-participant evidence |
| `AC-RETENTION-004` — content-signing, identity-package, identity-authority, and administrative-custody trust remain independently scoped | ARCHSPEC-0008 trust | `REQ-SESSION-EVIDENCE-TRUST-001`, `REQ-CONTENT-TRUST-001` | Each trust consumer | Trust-domain and cross-use negatives |
| `AC-RETENTION-005` — ordinary retained export is asynchronous while canonical reconstruction integrity and terminal receipt retain their special failure rules | ARCHSPEC-0008 commit/export | `REQ-SESSION-EVIDENCE-003`, `REQ-SESSION-EVIDENCE-004` | Retained-evidence adapter, `Session Lifecycle` | Commit, buffer, loss, receipt and exit evidence |
| `AC-RETENTION-006` — administrative recovery may finish idempotent export but never restore a Training Session | ARCHSPEC-0008 recovery | `REQ-RUNTIME-REPLACEMENT-001`, `NON-GOAL-SESSION-SAVE-001` | Administrative Tool Runtime | Candidate classification and duplicate/restart tests |
| `AC-DEPLOYMENT-001` — the initial topology has explicit client and authority runtime classes plus separate finite offline tools | ARCHSPEC-0009 allocation; amended by ARCHSPEC-0013 | `CONSTRAINT-CLIENT-OS-001`, `CONSTRAINT-AUTHORITY-OS-001`, `REQ-CONTENT-COOKER-TOOL-001` | Runtime and tool compositions | Role/process/tool/host allocation evidence |
| `AC-DEPLOYMENT-002` — platform capabilities are private responsibility-owned seams, not one Platform module | ARCHSPEC-0009 platform seams | `PREFERENCE-PLATFORM-PARITY-001`, `SCOPE-PRODUCT-001` | Each responsibility module | Adapter variation/failure contracts and public-type negatives |
| `AC-DEPLOYMENT-003` — one immutable Runtime Launch Specification governs complete startup and readiness for each product runtime | ARCHSPEC-0009 launch | `REQ-RUNTIME-LAUNCH-SPECIFICATION-001`, `REQ-RUNTIME-READINESS-001` | Runtime composition | Exact selection, validation, capacity, endpoint and ProcessReady order |
| `AC-DEPLOYMENT-004` — clients connect only to their assigned endpoint without discovery or fallback | ARCHSPEC-0009 connection | `REQ-SESSION-CONNECTION-001` | `Protocol & Replication` | Endpoint identity and discovery/fallback negatives |
| `AC-DEPLOYMENT-005` — exact Deployment Compatibility Matrix combinations gate startup and communication | ARCHSPEC-0009 compatibility | `REQ-DEPLOYMENT-COMPATIBILITY-001`, `REQ-DEPLOYMENT-COMPATIBILITY-002` | Runtime composition, `Protocol & Replication` | Combination admission/rejection evidence |
| `AC-DEPLOYMENT-006` — update and rollback select complete releases only for later processes | ARCHSPEC-0009 update/rollback | `REQ-APPLICATION-UPDATE-001`, `REQ-APPLICATION-ROLLBACK-001` | External provisioning | Candidate failure, activation and rollback history |
| `AC-DEPLOYMENT-007` — external handoffs retain independent capacity, acknowledgement, loss, and failure contracts | ARCHSPEC-0009 handoffs | `REQ-SESSION-EVIDENCE-003`, `NFR-OBSERVABILITY-INTEGRITY-001` | Semantic owner of each handoff | Buffer, retry, acknowledgement, loss and exhaustion evidence |
| `AC-DEPLOYMENT-008` — graceful shutdown and forced loss preserve terminal-settlement semantics | ARCHSPEC-0009 shutdown | `REQ-AUTHORITY-TERMINAL-SETTLEMENT-001`, `REQ-AUTHORITY-TERMINAL-SHUTDOWN-001` | Runtime composition, `Session Lifecycle` | Shutdown phase, receipt, cleanup and exit classification |
| `AC-DEPLOYMENT-009` — permissive development AUTH preserves the seam without producing security evidence | ARCHSPEC-0009 development AUTH | `REQ-AUTH-DEVELOPMENT-ADAPTER-001` through `REQ-AUTH-DEVELOPMENT-ADAPTER-003` | `AUTH & Admission` | Mode, ordering, failure and prohibited-effect tests |
| `AC-DEPLOYMENT-010` — production security and platform operations remain named future baselines | ARCHSPEC-0009 future boundaries | `DEFERRED-PRODUCTION-SECURITY-001`, `DEFERRED-PLATFORM-OPERATIONS-001` | Future baseline owners | Scope inspection; no Development evidence can pass them |
| `AC-CROSSCUTTING-001` — decision, applicability, realization, and evidence states remain independent | ARCHSPEC-0010 status | `PROCESS-ARCHITECTURE-CLAIM-003`, `PROCESS-ARCHITECTURE-CLAIM-004` | Architecture owner | Claim-state combinations and inference negatives |
| `AC-CROSSCUTTING-002` — execution configuration is immutable, explicit, responsibility-validated, and future-process-only | ARCHSPEC-0010 configuration | `REQ-RUNTIME-LAUNCH-SPECIFICATION-001`, `REQ-RUNTIME-LAUNCH-SPECIFICATION-002` | Each module; runtime composition aggregates | Selection identity, validation, publication and mutable-default negatives |
| `AC-CROSSCUTTING-003` — interface failures cross as stable Sacramento outcomes while native diagnostics remain private | ARCHSPEC-0010 outcomes | `REQ-RUNTIME-EXTERNAL-LIFECYCLE-001`, `REQ-ADMISSION-FAILURE-001` | Interface owner | Operation, category, affected scope, retry and diagnostic-containment evidence |
| `AC-CROSSCUTTING-004` — resource owners acquire, publish, transfer, and release in declared bounded order | ARCHSPEC-0010 resources | `REQ-RUNTIME-READINESS-001`, `REQ-AUTHORITY-TERMINAL-SHUTDOWN-001` | Resource-owning module | Acquire/publish/release and cleanup injection |
| `AC-CROSSCUTTING-005` — all adapters at a seam satisfy one contract suite without product-visible test bypasses | ARCHSPEC-0010 test interfaces | `PROCESS-ARCHITECTURE-CONTRACT-001` | Interface owner | Shared suite, adapter matrix, bypass and private-state negatives |
| `AC-CROSSCUTTING-006` — static, contract, native executable, and representative-sequence verification layers accumulate | ARCHSPEC-0010 verification | `PROCESS-ARCHITECTURE-VERIFICATION-001` | Implementation team | Layer-specific records and prohibited substitution cases |
| `AC-CROSSCUTTING-007` — executable closure requires native execution from only the declared immutable dependency closure | ARCHSPEC-0010 executable closure | `PROCESS-ARCHITECTURE-EXECUTABLE-001`, `REQ-APPLICATION-RELEASE-001` | Implementation team | Native role runs and dependency negatives |
| `AC-CROSSCUTTING-008` — the six representative sequences cover architecture-dominating composition outcomes | ARCHSPEC-0010 verification | `PROCESS-ARCHITECTURE-VERIFICATION-001` | Runtime compositions and implementation team | Sequence identities, outcomes, commit points and affected scopes |
| `AC-CROSSCUTTING-009` — evidence hooks report attributable facts and never assign verification Pass | ARCHSPEC-0010 evidence hooks | `PROCESS-EVIDENCE-DISPOSITION-001`, `NFR-OBSERVABILITY-INTEGRITY-001` | Seam owner; verification process disposes | Operation/version/correlation/loss facts and disposition-source negative |
| `AC-CROSSCUTTING-010` — historical: approved global dependency inventory; superseded by AC-CROSSCUTTING-013 | ADR-0014 migration | `PROCESS-EVIDENCE-DEPENDENCY-001` through `PROCESS-EVIDENCE-CHANGE-006` | Project owner | Historical record only |
| `AC-CROSSCUTTING-011` — historical: mandatory linked view-control set; superseded by AC-CROSSCUTTING-014 | ADR-0014 migration | `PROCESS-ARCHITECTURE-DESCRIPTION-001`, `PROCESS-ARCHITECTURE-UPDATE-001` | Project owner | Historical record only |
| `AC-CROSSCUTTING-012` — historical: ordered inventory approval blockers; superseded by AC-CROSSCUTTING-015 | ADR-0014 migration | `PROCESS-DOCUMENTATION-INVENTORY-001`, `PROCESS-TRACEABILITY-INVENTORY-001`, `PROCESS-EVIDENCE-DEPENDENCY-001` | Project owner | Historical record only |
| `AC-CROSSCUTTING-013` — impact uses actual dependencies and conservative reruns without global graph approval | ADR-0014 | `VERIFY-CHANGE-001` | Implementation team | Affected/uncertain reruns and reproducible invariant-result reasoning |
| `AC-CROSSCUTTING-014` — tailored arc42, C4/UML and linked ADRs explain architecture without fixed per-view controls | ADR-0014 | `DOC-MAINTENANCE-001` | Project owner | Source/preview provenance, links and behavior walkthroughs |
| `AC-CROSSCUTTING-015` — generated document/artifact/reference indexes replace mechanical inventory approval cycles | ADR-0014 | `DOC-MAINTENANCE-001` | Implementation team | Source-population, trace/state and broken-reference checks |
| `AC-MEMORY-001` — CPU requested, allocator capacity, process private commit, process resident memory, and GPU usage and budget remain distinct quantities | ARCHSPEC-0011 quantities | `REQ-RUNTIME-EXTERNAL-LIFECYCLE-001`, `NFR-DESKTOP-SMOOTHNESS-001` | Runtime compositions and resource-owning modules | Attributable counters, samples, provenance, and prohibited aggregate gauge |
| `AC-MEMORY-002` — memory accounting separates canonical owner, lifetime domain, and resource without creating a second product decomposition | ARCHSPEC-0011 accounting | `SCOPE-PRODUCT-001`, `REQ-STATE-CONSISTENCY-001` | Resource-owning modules | Exactly-one ownership, aggregation, transfer, Third Party, and Untracked cases |
| `AC-MEMORY-003` — a Sacramento seam and explicit Memory Resource Context preserve allocator identity and attribution across asynchronous execution | ARCHSPEC-0011 CPU seam and propagation | `REQ-STATE-CONSISTENCY-001`, `PREFERENCE-PLATFORM-PARITY-001` | Resource-owning modules and runtime compositions | Alignment, failure, deallocator, continuation, and work-stealing contracts |
| `AC-MEMORY-004` — each Memory Lifetime Domain has an explicit release fence consistent with session and evidence ownership | ARCHSPEC-0011 lifetimes | `REQ-SESSION-EVIDENCE-001`, `REQ-SESSION-EVIDENCE-002`, `REQ-AUTHORITY-TERMINAL-SHUTDOWN-001` | Resource-owning modules | Acquire, publish, transfer, fence, bulk-reset, and release sequences |
| `AC-MEMORY-005` — permanent memory accounting is bounded and non-recursive while allocation detail remains Diagnostic | ARCHSPEC-0011 accounting detail | `NFR-OBSERVABILITY-BUILD-PARITY-001`, `NFR-OBSERVABILITY-INTEGRITY-001`, `NFR-DESKTOP-STALL-001` | Resource-owning modules and `Observability` | Counter invariants, bounded buffers, explicit loss, CoreOnly negatives, and overhead evidence |
| `AC-MEMORY-006` — responsibility-owned immutable budgets and resource-class failure rules are validated before ProcessReady | ARCHSPEC-0011 budgets | `REQ-RUNTIME-LAUNCH-SPECIFICATION-001`, `REQ-RUNTIME-LAUNCH-SPECIFICATION-002`, `REQ-RUNTIME-READINESS-001`, `REQ-SESSION-EVIDENCE-002` | Resource-owning modules and runtime compositions | Budget identity, reservation, rejection, eviction negatives, and canonical failure boundaries |
| `AC-MEMORY-007` — Presentation owns a separate GPU allocation seam and reports logical, physical, deferred, usage, and budget quantities separately | ARCHSPEC-0011 GPU memory | `NFR-DESKTOP-SMOOTHNESS-001`, `CONSTRAINT-PLATFORM-MATRIX-001`, `PREFERENCE-PLATFORM-PARITY-001` | `Presentation` | GPU heap, suballocation, alias, fence, residency, and ownership evidence |
| `AC-MEMORY-008` — allocator specialization requires representative native end-to-end evidence and preserves existing quality and diagnostic obligations | ARCHSPEC-0011 adoption evidence | `NFR-DESKTOP-SMOOTHNESS-001`, `NFR-DESKTOP-STALL-001`, `NFR-ACTION-RESPONSE-001`, `CONSTRAINT-NFR-TEAM-001` | Implementation team and resource-owning modules | Native workloads, trace replay, soak, tails, footprint, determinism, and tool compatibility |
| `AC-MEMORY-009` — after ProcessReady, Measured Real-Time Hot Loops never reach the general-purpose heap or grow backing storage | ARCHSPEC-0011 adoption evidence | `NFR-DESKTOP-SMOOTHNESS-001`, `NFR-DESKTOP-STALL-001`, `NFR-ACTION-RESPONSE-001` | Resource-owning modules | Design inventory, profiling coverage, heap-call interception, capacity, fallback, and exhaustion evidence |

The claim CSV retains exact requirement relations; the Markdown ranges above
are explanatory shorthand. Retired process references resolve through the
[migration map](../project/documentation-migration.csv).


## Software Architecture Description view set

The [architecture entry point](software-architecture-description.md) uses tailored
arc42 sections, C4 context/container diagrams and selected UML sequences. Detailed
contracts remain linked. The [view migration](../project/architecture-view-migration.csv)
maps former EDI-VIEW identifiers to current section anchors for design traceability.
There is no fixed view count or repeated per-view control table.

## Inventory and closure boundary

ADR-0014 replaces the former three-inventory approval sequence with generated
navigation and direct checks. Applicability, claim states, Design Commitments and
requirement-specific acceptance criteria remain canonical semantic records.
Structural checks cannot approve a product baseline or prove dependency completeness.

Dependency qualification, reference workloads and deterministic replay artifacts,
unpopulated profiles/catalogues, product realization and native evidence remain
explicit blockers. Production security and platform operations remain future.

## Considered options and consequences

A generic cross-cutting framework would centralize unrelated meaning and weaken
responsibility ownership. Runtime hooks cannot assign Pass, and accepted decisions
cannot imply realization. Representative composition sequences complement local
contract variations; an exhaustive narrative catalogue adds duplication.

ADR-0014 changes the administrative trade-off: indexes are generated, and uncertain
impact requires conservative reruns instead of claiming a complete manually
approved graph. This preserves locality and traceability while reducing solo
maintenance. The original inventory rationale remains in Git history.

## Trace

Product contracts retain the Architecture Claim traces above. Current documentary
controls are `DOC-MAINTENANCE-001` and `VERIFY-CHANGE-001`; replaced process
identifiers have explicit dispositions in the migration map. Runtime, content,
persistence, deployment and Observability requirements are unchanged.
