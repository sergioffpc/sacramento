# Training Simulation Governance Glossary

Status: Candidate; project-owner approval pending

Purpose: Define canonical terminology for baselines, profiles, catalogues, inventories, evidence roles, and project controls.

Scope: Governance concepts used by requirements, architecture, verification, and repository processes.

Intended readers: Project owners, reviewers, architects, implementers, Qualified Specialists, Representative Evaluators, and verification authors.

Prerequisites: `CONTEXT.md` and `docs/glossary/technical.md`.

Canonical information owner: Project owner.

Use the [domain glossary](../../CONTEXT.md) for product language and the [technical glossary](technical.md) for runtime and identity mechanisms.

## Language

**Acoustic Profile**:
An exact admitted Approved Profile version defining a represented sound source, propagation inputs and paths, material and environment behavior, receiver outputs, perception criteria, tolerances, and applicability.
_Avoid_: Audio preset, unvalidated mix, source-only sound effect

**Acoustic Propagation Catalogue**:
The approved, versioned, and closed coverage of every admitted sound source, material, opening, environment, path, receiver, and output class, with exact Acoustic Profile versions and Applicable or Not-Applicable behavior rows.
_Avoid_: Sound bank, scene audio settings, incomplete material table

**Action Compatibility Matrix**:
The approved, versioned coverage of action-pair and canonical physical-condition classes that derives Compatible or Conflict dispositions from declared resources and applicable profiles.
_Avoid_: Runtime behavior as specification, global action lock, implicit compatibility

**Action Inventory**:
The approved, versioned list of every Trainee action admitted to the baseline and its trace to an approved Training Need Record.
_Avoid_: Feature list, animation list, implicit action set

**Action Physical Condition Inventory**:
The approved, versioned, and closed inventory of canonical physical-condition classes that can change whether Trainee actions may execute concurrently.
_Avoid_: Ad hoc state check, implementation-defined condition, matrix row chosen at runtime

**Admission Authorization Rule Set**:
The approved, versioned product rules whose client-applicable rows authorize the Session Authority Identity and whose authority-applicable rows convert authenticated Trainee and Client Device Identities and external Authorization Assertions into the final admission or denial decision.
_Avoid_: Local user allowlist, identity lifecycle policy, implicit access check

**Approved Profile**:
A versioned record of represented behavior or data whose scope, reference conditions, evidence, tolerances, specialist validation, and project-owner approval satisfy the profile-admission requirements.
_Avoid_: Tuning preset, provisional values, undocumented configuration

**AUTH Audit Integrity Profile**:
The approved, versioned outcome specification for grouping, ordering, continuity, integrity references, authorized expiry transitions, discontinuities, validation evidence, and acceptance criteria for retained AUTH Audit Records.
_Avoid_: Mandated storage format, named algorithm, implementation default, tamper-proof claim

**AUTH Audit Policy**:
The approved, versioned policy that defines AUTH Audit Record classes, host-role applicability, finite retention periods, expiry disposition, and access boundary independently of any Scenario.
_Avoid_: Scenario setting, indefinite retention, implementation default

**AUTH Data Inventory**:
The approved, versioned, and closed classification of every externally provisioned AUTH package payload and internally produced AUTH field by purpose, source or producer, permitted host-role recipient, consumer, persistence, lifetime, cleanup event, and governing requirement.
_Avoid_: Evidence-format catalogue, runtime schema, undeclared telemetry, open metadata bag

**AUTH Operation Inventory**:
The approved, versioned, and closed inventory of AUTH Attempt and AUTH Operation classes, including stable class keys, nesting, validators, purposes, start and terminal events, supersession, cancellation propagation, audit classification, required audit classes for audited rows, and permitted effects.
_Avoid_: Runtime call graph, protocol specification, incomplete list of authentication steps

**Authentication Assurance Profile**:
An exact versioned Identity Authority policy defining the authenticator classes, factor count, human-presence conditions, proof requirements, applicability, and acceptance criteria for one identity class.
_Avoid_: Product-owned account policy, implicit assurance, universal password rule

**Baseline Applicability Inventory**:
The approved, versioned classification of every current requirement identifier as Included, Future at one named milestone, or Not Applicable with justification for one candidate product baseline.
_Avoid_: Implicit scope, omitted requirement, future promise without milestone

**Baseline Artifact Inventory**:
The approved, versioned list of architecture, design, implementation, and verification artifacts governed by one candidate baseline.
_Avoid_: Repository file listing, informal document list, section index

**Carrying Catalogue**:
The approved, versioned, and closed inventory of carryable item types, Carry Position types, capacities, interfaces, compatibility results, load contributions, and deterministic automatic-stow ordering admitted to one product baseline.
_Avoid_: Initial Loadout, runtime guess, incomplete compatibility table, abstract inventory

**Conventional Commit Profile**:
The repository-owned, versioned commit-message grammar, admitted types and scopes, breaking-change notation, validation rules, and integration policy based on one exact Conventional Commits specification version.
_Avoid_: Free-form commit title, implicit type list, unvalidated merge message

**Development Baseline**:
The explicitly non-production baseline used to implement and verify Training Simulation behavior and stable integration seams before production security and platform-operations capabilities are admitted.
_Avoid_: Production deployment, security acceptance, operational availability claim, throwaway architecture

**Deployment Compatibility Matrix**:
The approved, versioned, and closed coverage of exact Application Release, Runtime Content Release, protocol, launch, observability, and external-integration contract combinations permitted to start or communicate.
_Avoid_: Runtime version negotiation, semantic-version range, automatic fallback, implicit compatibility

**Documentation Inventory**:
The approved, versioned, and closed inventory of persistent project documents, their canonical information owner, metadata, prerequisite links, Markdown and Table-of-Contents applicability, and stable mappings to the information for which each document is authoritative.
_Avoid_: Repository file listing, implicit document population, duplicate canonical owner

**Environment Coverage Catalogue**:
The approved, versioned, and closed coverage of admitted doors, windows, lights, circuits, Obscurants, devices, Fire, movable objects, destructible surfaces, interactions, states, and environmental outcomes, with exact profile and downstream catalogue versions.
_Avoid_: Scene object list, engine component registry, implicit environment behavior

**Environment State Catalogue**:
The approved, versioned, and closed state schemas and transition tables for environment objects and effects, including same-event precedence, atomic outputs, terminal dispositions, reset state, and transformation traces.
_Avoid_: Runtime state as specification, unspecified event order, save-game schema

**Fatigue Profile**:
An exact admitted Approved Profile version defining Fatigue inputs, authoritative simulated-time evolution, bounds, recovery, applicability, and permitted downstream effects.
_Avoid_: Stamina constant, undocumented recovery, actual human health model

**Fire Profile**:
An exact admitted Approved Profile version defining ignition, fuel, heat transfer, combustion states, propagation, outputs, exposure, time evolution, and extinction for a closed source, material, environment, and target domain.
_Avoid_: Particle preset, generic burn damage, unrestricted building-fire model

**Functional State Transition Catalogue**:
The approved, versioned, and closed matrix mapping every current Trainee Functional State and admitted single, simultaneous, or accumulated injury outcome to exactly one succeeding state and limitation set.
_Avoid_: Health threshold, implicit severity order, implementation-defined injury aggregation

**Harmful Effect Inventory**:
The approved, versioned, and closed inventory of every admitted effect source capable of producing injury, impairment, equipment damage, or another adverse authoritative outcome, traced to its exact physical and injury rules.
_Avoid_: Damage types, open other-harm list, Team-specific damage table

**Identity Evidence Catalogue**:
The approved, versioned, and closed inventory of supported identity classes, evidence and assertion types and versions, required fields, issuers, Authentication Assurance Profiles, Offline Revocation Status forms, validation purposes, dependencies, and objective validation rules.
_Avoid_: Dynamic format discovery, open evidence parser, implementation behavior as specification

**Initial Start Condition Set**:
The approved, versioned, and closed inventory of individual and Training Session-wide conditions that permit the initial countdown and transition into active simulation.
_Avoid_: Hidden start gate, readiness preconditions only, implementation-defined start conditions

**Injury Outcome Catalogue**:
The approved, versioned, and closed coverage of every admitted body region, exposure, protection, prior-injury and Trainee Functional State tuple, with exact Injury Profile versions, resulting injuries, limitations, cues, and downstream profile effects.
_Avoid_: Damage table, hit points, generic body-region penalty, optional injury effect

**Injury Profile**:
An exact admitted Approved Profile version defining injury thresholds, protection, outcome, combination, limitation, cue, duration, downstream effects, reference conditions, and tolerances for a closed exposure and prior-state domain.
_Avoid_: Damage value, health table, unvalidated medical rule

**Lighting Profile**:
An exact admitted Approved Profile version defining emitted light, spatial distribution, occlusion, illumination, shadow, visibility outputs, comparison criteria, and tolerances for a represented light source and environment domain.
_Avoid_: Cosmetic light, client-only illumination, arbitrary brightness

**Locomotion Profile**:
An exact admitted Approved Profile version defining movement capabilities, environmental applicability, and limits from the complete declared input tuple, including posture, Carried Load, Fatigue, Recovery Carrier status, and Trainee Functional State.
_Avoid_: Player stats, movement-speed constant, character class

**Melee Coverage Catalogue**:
The approved, versioned, and closed coverage of admitted Melee bodies, actions, implements, interfaces, resources, access modes, physical conditions, contact phases, targets, defenses, and outcomes, with exact catalogue rows and Approved Profile versions.
_Avoid_: Combo list, animation set, optional move table

**Obscurant Profile**:
An exact admitted Approved Profile version defining formation, spatial volume, movement, geometry/opening interaction, dissipation, transmitted-light and visibility outputs, physiology, simulated-time evolution, and tolerances.
_Avoid_: Particle preset, screen fog, implicit smoke lifetime

**Observability Contract**:
The approved, versioned definition of core metric and event identifiers, fields, units, timestamp semantics, correlation semantics, and availability needed to verify automated quality requirements and operational targets consistently in test and production builds.
_Avoid_: Implementation-specific logging library, unrestricted diagnostic dump, AUTH Audit Record

**Physical Effects Catalogue**:
The approved, versioned, and closed coverage of admitted physical-effect sources, projectiles, atmospheres, materials, propagation paths, impact geometries, targets, protection, transformations, and outputs, with exact Physical Profile versions and complete applicability domains.
_Avoid_: Damage lookup, physics tuning table, incomplete material matrix

**Physical Profile**:
An exact admitted Approved Profile version containing evidence-backed physical data and behavior for one represented source, projectile, material, target, weapon, explosive, or interaction class under defined reference conditions.
_Avoid_: Power level, generic damage value

**Platform Operations Baseline**:
The future named baseline that will govern runtime orchestration, infrastructure scheduling and supervision, capability availability, redundancy, failover, cluster and network topology, power resilience, hardening, secrets, operational credentials, and alert routing.
_Avoid_: Training Session restoration, canonical runtime behavior, current Development Baseline

**Project C++ Style Profile**:
The repository-owned, versioned, and closed C++ coding rules, automatic-tool mappings, explicitly admitted deviations, scope, and acceptance gates used as the sole project style authority.
_Avoid_: Live external guide, developer preference, formatter defaults, unwritten exception

**Project Python Style Profile**:
The repository-owned, versioned, and closed Python language and style rules, automatic-tool mappings, explicitly admitted deviations, scope, and acceptance gates used as the sole project style authority.
_Avoid_: Live external guide, developer preference, linter defaults, unexplained suppression

**Production Security Baseline**:
The future named baseline that will govern production identity authentication, authorization, protected exchange, revocation, durable AUTH audit and recovery, operational trust, authenticated evidence custody, and qualification of their adapters.
_Avoid_: Permissive development AUTH, Synthetic Identity, infrastructure availability, security claim without acceptance

**Qualified Specialist**:
A person with demonstrable expertise in the specific equipment or physical phenomenon covered by an Approved Profile who evaluates the validity and applicability of its supporting evidence.
_Avoid_: Developer by default, generic reviewer, Representative Evaluator by default

**Radio Coverage Profile**:
The approved, versioned acceptance conditions, spatial domain, transmission and listening inputs, intelligibility metric, tolerance, and coverage evidence required for Team Radio across one Map.
_Avoid_: Informal walk test, overlapping-traffic test, unspecified audibility

**Reference Hardware Profile**:
A versioned acceptance configuration that fixes the hardware, drivers, display conditions, and relevant settings used to verify one product role or access mode.
_Avoid_: Minimum requirements, recommended PC, hardware class

**Reference Workload Profile**:
A versioned acceptance definition that fixes one reproducible `Typical`, `Stress`, or `Rejection Boundary` load used to verify applicable Training Simulation quality requirements.
_Avoid_: Ad hoc benchmark, unspecified worst case, duplicated per-requirement workload

**Runtime Timing Profile**:
An Approved Profile that fixes the runtime cadence and finite operating bounds for authoritative Simulation, client Prediction, Presentation, catch-up, replication retention, and connection-loss detection.
_Avoid_: Frame-rate setting, vendor scheduler configuration, implicit timeout defaults

**Representative Evaluator**:
An armed-forces member with recent experience of the environments, equipment, and decisions represented by the Scenario who evaluates whether the Training Simulation preserves relevant training perception and outcomes.
_Avoid_: Developer, artist, generic tester

**Stress Profile**:
An exact admitted Approved Profile version defining the closed stressor and optional-effect inventories, Stress Load bounds, authoritative simulated-time accumulation and recovery, history windows, applicability, and permitted downstream effects.
_Avoid_: Mood system, undocumented stress penalty, actual psychological measurement

**Training Need Record**:
An approved, versioned statement of a military training activity and intended training outcome that justifies admitting one or more Trainee actions.
_Avoid_: Feature request, entertainment rationale, informal use case

**Weapon Behavior Catalogue**:
The approved, versioned, and closed inventory that reconciles every admitted weapon, ammunition, magazine, and Weapon Accessory type with every required capability, state, action, physical interaction, damage-cause class, malfunction, and transformation; each row declares applicability, exact admitted Approved Profile versions, complete condition and output domains, tolerances, and evidence.
_Avoid_: Weapon feature list, optional profile row, implementation behavior as specification
