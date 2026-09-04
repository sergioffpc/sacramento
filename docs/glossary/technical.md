# Training Simulation Technical Glossary

Status: Approved

Approval: Project owner, 2026-09-04

Latest approved amendment: Composite Confirmed-State Identity and Lifecycle Revision, project owner, 2026-09-04

Purpose: Define canonical runtime, identity, packaging, timing, and deployment terminology.

Scope: Technical concepts used by requirements, architecture, design, implementation, and verification.

Intended readers: Architects, designers, implementers, security reviewers, operators, and verification authors.

Prerequisites: `CONTEXT.md`.

Canonical information owner: Project owner.

Use the [domain glossary](../../CONTEXT.md) for product and represented-world language and the [governance glossary](governance.md) for controlled artefacts and baselines.

## Language

**Application Release**:
An immutable, identified release containing one complete executable runtime and its dependency closure for one exact product role and platform.
_Avoid_: Runtime Content Release, mutable installation, source tree, latest build

**AUTH Attempt**:
One finite runtime initial-admission, lifecycle, or audit-recovery attempt with one unique instance identifier and one stable class key whose exact nested AUTH Operations, validator roles, start, terminal result, cancellation propagation, and supersession behavior are declared by the AUTH Operation Inventory.
_Avoid_: Network connection, retry, individual proof check, unbounded login process

**AUTH Audit Checkpoint**:
A separately collectable, non-secret integrity reference whose exact scope and relationship to retained AUTH Audit Records are defined by the approved AUTH Audit Integrity Profile so unauthorized mutation, deletion, or discontinuity within that scope can be detected.
_Avoid_: Audit record copy, mutable sequence pointer, unauthenticated file offset

**AUTH Audit Commit Unit**:
The atomic persistence outcome covering one final AUTH Audit Record and every integrity reference required for it by the current AUTH Audit Integrity Profile, committed before the governed operation may produce an access-, privilege-, or Admission-granting AUTH effect.
_Avoid_: Record written before its result is known, best-effort log write, gameplay transaction

**AUTH Audit Record**:
A persistent record of one inventory-classified authentication, authorization, admission, lifecycle, or audit-recovery operation and its exact applicable non-secret inputs and result, retained for security traceability rather than gameplay or After-Action Review.
_Avoid_: AAR event, gameplay telemetry, authentication secret, reusable proof

**AUTH Audit Sequence**:
One ordered retained continuity epoch within a host's closed chain of current and historical AUTH Audit epochs, with explicit beginning, rollover, discontinuity, authorized-expiry, and checkpoint boundaries.
_Avoid_: Unordered log files, mutable event list, gameplay timeline

**AUTH Denial Category**:
One of the closed generic outcomes disclosed to a requesting client when AUTH cannot continue, without revealing the exact failed identity, evidence, policy, profile, revocation, or validation rule.
_Avoid_: Exact rejection reason, diagnostic trace, silent disconnect

**AUTH Operation**:
One independently resolved runtime authentication, authorization, admission, lifecycle, or audit-recovery action with one unique instance identifier and one stable class key, nested in exactly one AUTH Attempt.
_Avoid_: Entire network connection, implicit validation step, gameplay action

**AUTH Permission**:
One closed authorization value issued in an Authorization Assertion: `Use Training Simulation`, `Operate Trainee Client`, `Operate Autonomous Participant`, or `Operate Session Authority`.
_Avoid_: Role, Team permission, Scenario permission, free-form entitlement

**AUTH Protected Exchange**:
The mutually bound AUTH Attempt context that protects AUTH messages against unauthorized disclosure, modification, injection, replay, reordering, or use with another peer or purpose.
_Avoid_: Plain connection, gameplay channel, architecture-specific protocol name

**Authentication Challenge**:
A single-use request created by a validator for one exact AUTH Operation and Attempt, presenter identity, validator identity, and authentication purpose.
_Avoid_: Reusable nonce, timestamp alone, session identifier, Authorization Assertion

**Authenticator Control Proof**:
Evidence that the presenter controls the authenticator bound by the Identity Authority to one exact identity, without exposing or transferring that authenticator.
_Avoid_: Copied identity record, Authorization Assertion, Call Sign, possession of public evidence

**Authorization Assertion**:
A verifiable statement from the Identity Authority that assigns one or more AUTH Permissions to one identified Trainee Identity, Autonomous Controller Identity, Client Device Identity, or Session Authority Identity.
_Avoid_: Authentication evidence, local account, Team assignment

**Autonomous Controller Identity**:
The externally governed identity of the software subject controlling one Autonomous Participant, distinct from the controlled role, its Client Device Identity, and every human Trainee Identity.
_Avoid_: Autonomous Participant, Trainee Identity, Client Device Identity, controller process identifier

**Authority Pack**:
The signed, immutable, role-specific half of one Runtime Content Release containing the complete runtime content required by one Session Authority for its exact Scenario and Training Session.
_Avoid_: Client Pack, source assets, mutable server data

**Canonical Identity Key**:
The normalized tuple of exact Identity Authority, identity class, and stable subject identifier produced by successful identity validation and used for every identity comparison, binding, and uniqueness decision.
_Avoid_: Display name, evidence document identity, network address, implementation-specific object identity

**Canonical Tick**:
One indivisible authoritative advancement of simulated time and canonical simulated state within a Training Session, identified by a monotonically increasing integer in one simulation epoch.
_Avoid_: Render frame, network update, Operational Clock interval, variable time step

**Composite Confirmed-State Identity**:
The exact tuple of canonical state version, Canonical Tick index, Simulation revision, Scenario revision, and Lifecycle Revision fixed by the authoritative owners for one committed state; equality requires equality of every member.
_Avoid_: Observability sequence, replication acknowledgement, client prediction version, timestamp

**Client Pack**:
The signed, immutable, role-specific half of one Runtime Content Release containing the complete Prediction and Presentation content required by one Trainee client for its exact Scenario and Training Session.
_Avoid_: Authority Pack, source assets, downloadable content

**Content Signing Trust Reference**:
An independently provisioned, versioned statement that assigns authorized content-signing keys to the exact pack roles and runtime content contracts they may sign.
_Avoid_: Pack-contained trust root, unrestricted signing key, runtime version negotiation

**Content Signing Key Identity**:
The complete SHA-256 fingerprint derived from the content-signing scheme identity and raw public key under the Sacramento content-signing domain, used only for exact trust-reference lookup and evidence correlation.
_Avoid_: Trust root, authorization credential, truncated key hint, signer-selected trust

**Controlled LAN**:
The private, dedicated wired local network whose participants, local services, permitted traffic, and measurement conditions are closed by an exact deployment profile, with no route to an external network during a Training Session.
_Avoid_: Wide-area network, shared office network, unspecified LAN

**Identity Authority**:
The system outside the Training Simulation that owns the authoritative lifecycle of Trainee Identities, Autonomous Controller Identities, Client Device Identities, and Session Authority Identities.
_Avoid_: Training Simulation account store, Call Sign registry

**Identity Validation Package**:
The externally provisioned, versioned release defining one closed manifest for each admitted client and authority role plus shared approved non-sensitive artifacts, from which each host receives and retains only its applicable role manifest and those shared artifacts.
_Avoid_: Server-downloaded trust data, dynamic validation dependency, local identity database

**Intention**:
A client request proposing a Trainee or Autonomous Participant action for authoritative evaluation; it cannot prescribe its Canonical Tick, canonical ordering, result, or resulting state.
_Avoid_: Client command, authoritative action, client-authored outcome, timestamped event

**Lifecycle Revision**:
The monotonically increasing Session Lifecycle owner revision fixed by one committed Training Session lifecycle transition; it is distinct from the Canonical Tick index and every observability sequence or timestamp.
_Avoid_: Canonical Tick, process lifecycle signal, Operational Clock instant, observability sequence

**Measured Real-Time Hot Loop**:
One design-identified and profiling-confirmed repeated runtime path after `ProcessReady` whose general-purpose heap access could affect a Canonical Tick, Presentation Frame, real-time audio processing, or another approved temporal obligation.
_Avoid_: Every syntactic loop, unmeasured code path, startup materialization

**Memory Accounting Owner**:
The one canonical responsibility module, or runtime composition for a resource it genuinely owns, to which one Sacramento memory allocation is charged independently of its lifetime or allocation mechanism.
_Avoid_: Consumer list, executing thread, allocator name, Third Party, Untracked

**Memory Budget Configuration**:
The immutable, identified launch-selected set of measured soft and hard memory limits, headroom rationales, owners, scopes, and exact exceed actions for one runtime execution.
_Avoid_: Reference Hardware Profile capacity, current driver budget, mutable default, allocator capacity

**Memory Lifetime Domain**:
The explicit Sacramento boundary that groups memory sharing one release condition and fence without changing its Memory Accounting Owner.
_Avoid_: C++ type, subsystem tag, executing thread, implicit scope

**Memory Resource Context**:
The immutable allocation context carrying the exact Memory Accounting Owner, Memory Lifetime Domain, memory resource, and applicable budget identity across synchronous and asynchronous work.
_Avoid_: Thread-local owner, worker identity, global current subsystem

**Memory Snapshot**:
An identified point-in-time record of Sacramento allocation counters and applicable process or GPU samples with their exact runtime, phase, configuration, profile, provenance, and loss state.
_Avoid_: Heap dump, single RAM-used value, unversioned profiler capture

**Offline Revocation Status**:
A time-bounded statement from the Identity Authority that identifies an exact identity-evidence item or Authorization Assertion and classifies it as `Current` or `Revoked` for offline validation.
_Avoid_: Cached admission decision, unbounded revocation list, inferred validity

**Offline-Verifiable Identity Evidence**:
Identity authentication evidence or an Authorization Assertion issued under the Identity Authority whose issuer, subject, integrity, applicability, validity, and Offline Revocation Status can be established without contacting that authority during admission.
_Avoid_: Cached admission decision, local account, unverifiable identity claim

**Operational Clock**:
The Session Authority's monotonic time source for Training Session lifecycle deadlines and countdowns, independent from simulated time.
_Avoid_: Simulated time, Scenario timer, client clock, calendar clock

**Process Control Contract**:
The versioned, orchestration-neutral contract through which a Session Authority or Trainee Client process publishes its Process Lifecycle State and accepts a bounded graceful-shutdown request without exposing platform or orchestrator types.
_Avoid_: Observability, supervisor API, runtime log, Content Cooker interface

**Process Execution Identity**:
The immutable identity assigned to one operating-system process execution before it interprets its Runtime Launch Specification; a replacement process always receives a new identity.
_Avoid_: Application Release identity, Training Session identity, endpoint identity

**Process Lifecycle State**:
The external lifecycle classification of one Session Authority or Trainee Client process: `ProcessStarting`, `ProcessReady`, `ProcessNotReady`, `ProcessStopping`, or `ProcessTerminated`.
_Avoid_: TraineeReady, Training Session lifecycle state, Observability event

**Package Trust Reference**:
The externally provisioned, project-owner-approved bootstrap reference by which a host verifies the identity, version, role, and integrity of the current Identity Validation Package manifest without trusting that package to validate itself.
_Avoid_: Self-declared package integrity, Session Authority download, live identity lookup

**Pack Core Digest**:
The SHA-256 digest of the exact deterministic Pack Manifest and complete stored payload region of one role pack, excluding its Pack Envelope and detached signature so reciprocal role-pack binding is non-circular.
_Avoid_: Runtime Content Release identity, complete-file distribution hash, signature, Resource Identity

**Pack Envelope**:
The signed role-pack structure that binds the exact release, Scenario, role, runtime content contract, signing scheme and key identity, and the identities and Pack Core Digests of both reciprocal role packs.
_Avoid_: Pack Manifest, unsigned header, trust root, recursive complete-file hash

**Pack Manifest**:
The deterministic authenticated package representation that declares the bounded Runtime Resource entries, stored extents, type and schema identities, dependencies, integrity digests, and physical locations admitted by one role pack.
_Avoid_: Catalogue, source directory, dynamic registry, mutable index

**Platform Parity**:
The preference that shared Simulation Engine capabilities and technologies remain functionally portable between Windows and Linux. It does not imply that every product executable is supported or accepted on both operating systems.
_Avoid_: Full platform matrix, identical deployment support

**Resource Identity**:
The stable opaque UUIDv4 identity of one independently referenced Runtime Resource, stored as 16 bytes in a role pack and preserved through moves, renames, and compatible edits but replaced when that resource is duplicated or semantically replaced.
_Avoid_: Source path, content digest, manifest location, runtime handle

**Resource Identity Metadata**:
The versioned authoring-side record that preserves canonical-source identity and maps stable semantic product and subresource keys to their Resource and Subresource Identities across compatible edits.
_Avoid_: Pack Manifest, cooker-generated identity, source path as identity, silent duplicate repair

**Resource Reference**:
A persistent Sacramento value naming one Resource Identity, an optional Subresource Identity, and the expected Runtime Resource type for validation and resolution during materialization.
_Avoid_: Runtime Resource Handle, source path, pointer, untyped identifier

**Runtime Content Release**:
One immutable, signed release for an exact Scenario version, comprising exactly one Authority Pack and one Client Pack under a common identity that binds their roles, runtime content contracts, integrity hashes, dependencies, and processing provenance.
_Avoid_: Loose asset directory, independently selected packs, live content set

**Runtime Launch Specification**:
The immutable, versioned, role-specific selection that completely binds one Session Authority or Trainee Client process execution to its exact Application Release, runtime content, profiles, endpoint, capacities, operating mode, and applicable external integrations.
_Avoid_: Cooking Job Specification, mutable environment defaults, directory discovery, newest version, runtime download

**Runtime Resource**:
An immutable unit of Sacramento semantic content identified independently of its source location and package representation and completely materialized from an admitted role pack for use by one or more runtime responsibility modules. Its meaning and lifetime remain owned by the applicable responsibility module.
_Avoid_: Source asset, manifest entry, encoded payload, memory allocation, runtime handle

**Runtime Resource Handle**:
A typed, execution-local, borrowed reference to one completely materialized Runtime Resource in the process's single immutable published view.
_Avoid_: Resource Reference, persistent identity, owning pointer, reload generation

**Session Authority**:
The trusted part of the Training Simulation that determines the canonical state and outcomes of one active Training Session.
_Avoid_: Client, host player, source of truth

**Session Authority Identity**:
The externally governed identity presented by a Session Authority endpoint so a Trainee client can authenticate and authorize that authority before disclosing Trainee or client-device authentication evidence.
_Avoid_: Network address, Training Session identity

**Session Evidence Set**:
The immutable retained record set for one Training Session, binding its deterministic reconstruction records, terminal result, completeness or explicit loss classification, Runtime Content Release, build, configuration, and provenance under one verifiable identity.
_Avoid_: Operational log, save game, mutable replay, After-Action Review

**Simulation Engine**:
The internal software foundation built only to support the Training Simulation's validated needs. It is not an independently reusable or general-purpose product.
_Avoid_: Product, general-purpose engine

**Cooking Job Specification**:
The immutable, versioned input selecting one Content Cooker Tool execution, its exact authoring-source closure, processing gate, tools and configuration, output identities, signing-key reference, publication destination, capacities, and provenance.
_Avoid_: Runtime Launch Specification, command-line options, implicit directory scan

**Cooking Job Result**:
The immutable terminal result of one Content Cooker Tool execution, classifying success or failure and identifying a Runtime Content Release only after its complete atomic publication.
_Avoid_: Process Lifecycle State, progress log, partially written pack

**Tool Release**:
An immutable, identified release containing one complete offline tool executable and its dependency closure for one exact tool role and platform.
_Avoid_: Application Release, Runtime Content Release, source tree

**Simulated Time**:
The authoritative Training Session time derived exactly from its simulation epoch and Canonical Tick; it advances only through committed Canonical Ticks.
_Avoid_: Operational Clock, Trusted Identity Time, render time, client clock

**Synthetic Identity**:
An explicitly non-production, launch-declared stand-in for exactly one Trainee, Client Device, or Session Authority identity class, used only to exercise runtime Admission interfaces without claiming authentication, authorization, or a Canonical Identity Key.
_Avoid_: Trainee Identity, Client Device Identity, Session Authority Identity, authenticated identity, production account

**Subresource Identity**:
The stable opaque UUIDv4 identity of one independently addressable part within a Runtime Resource, stored as 16 bytes in a role pack and preserved independently of storage order but replaced when that part is semantically replaced.
_Avoid_: Array index, byte offset, source path, execution-local object identity

**Stored Extent**:
One bounded contiguous region of exact bytes stored in a role pack and covered by one authenticated digest before decompression or decoding.
_Avoid_: Unauthenticated gap, decoded object, filesystem extent, runtime allocation

**Trusted Identity Time**:
The independently established time used by a validating host to evaluate identity-evidence validity without accepting time from the identity or endpoint being validated; it is distinct from the Operational Clock and simulated time.
_Avoid_: Operational Clock, simulated time, peer-provided time, unqualified local clock
