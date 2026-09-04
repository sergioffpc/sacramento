# Training Simulation Autonomous Participant Requirements

Status: Approved future requirements; implementation and acceptance remain future

Baseline: Autonomous Participant baseline

Baseline version: `AUTONOMOUS-PARTICIPANT-BASELINE-001`

Approval: Project owner, 2026-09-04

Purpose: Define the role, trust boundary, participation rules, quality
obligations, and acceptance boundary for future software-controlled Training
Session participants.

Scope: Requirements for the Autonomous Participant baseline. The Development
Baseline and first Virtual-Reality Mode baseline remain unchanged, and this
document admits no implementation, architecture module, dependency, or
speculative interface.

Intended readers: Project owner, requirements reviewers, architects,
designers, implementers, security reviewers, verification authors, Qualified
Specialists, and Representative Evaluators.

Prerequisites: [Training Simulation context](../../CONTEXT.md), [technical
glossary](../glossary/technical.md), [initial
requirements](training-simulation-initial-requirements.md), [non-functional
requirements](training-simulation-non-functional-requirements.md),
[observability contract](training-simulation-observability-contract.md),
[verification plan](training-simulation-verification-plan.md), and
[ADR-0004](../adr/0004-decompose-by-canonical-responsibility.md).

Canonical information owner and approver: Project owner.

Normative convention: `MUST` and `MUST NOT` are required for approval of the
Autonomous Participant baseline. `MAY` states permitted behavior. Unless a
separate criterion is stated, each normative sentence is its pass/fail
criterion.

## Table of contents

- [Scope and role](#scope-and-role)
- [Identity, authorization, and Admission](#identity-authorization-and-admission)
- [Continuity, revocation, audit, and recovery](#continuity-revocation-audit-and-recovery)
- [Actions and authority](#actions-and-authority)
- [Team, capacity, and Scenario participation](#team-capacity-and-scenario-participation)
- [Perception and prohibited inputs](#perception-and-prohibited-inputs)
- [Observability and deterministic replay](#observability-and-deterministic-replay)
- [Workload, performance, and failure](#workload-performance-and-failure)
- [Security and retained outputs](#security-and-retained-outputs)
- [Applicability decisions](#applicability-decisions)
- [Acceptance and change control](#acceptance-and-change-control)

## Scope and role

**REQ-AUTONOMOUS-SCOPE-001** — The `Autonomous Participant baseline` MUST remain a separately approved future baseline and MUST NOT expand the Development Baseline or the first Virtual-Reality Mode baseline.

**REQ-AUTONOMOUS-SCOPE-002** — Approval of these requirements MUST NOT by itself admit an Autonomous Participant, an `Autonomous Control` module or interface, a controller implementation, a dependency, or product verification evidence.

**REQ-AUTONOMOUS-ROLE-001** — An Autonomous Participant MUST be a software-controlled Training Session role distinct from a human Trainee and from a synthetic client used only for test or workload generation.

**REQ-AUTONOMOUS-CONTROL-001** — Every Autonomous Participant MUST be controlled by exactly one current controlling client connection.

**REQ-AUTONOMOUS-CONTROL-BOUNDARY-001** — Future `Autonomous Control` responsibility MUST be limited to world modeling from permitted inputs, planning, and Intention submission; Prediction and Presentation MUST remain distinct responsibilities and no interface shape is approved by this requirement.

## Identity, authorization, and Admission

**REQ-AUTONOMOUS-IDENTITY-001** — Every Autonomous Participant Admission MUST bind exactly one validated Autonomous Controller Identity that identifies the controlling software subject and MUST NOT be a Trainee Identity.

**REQ-AUTONOMOUS-DEVICE-IDENTITY-001** — The Admission MUST separately bind the Client Device Identity of the computer operating the controlling client; an Autonomous Controller Identity and a Client Device Identity MUST NOT substitute for one another.

**REQ-AUTONOMOUS-IDENTITY-EQUALITY-001** — Autonomous Controller Identity, Client Device Identity, and Session Authority Identity equality and uniqueness decisions MUST use their Canonical Identity Keys under the approved identity catalogues and normalization rules.

**REQ-AUTONOMOUS-PERMISSION-001** — The closed AUTH Permission set used by the Autonomous Participant baseline MUST include `Operate Autonomous Participant`, and that permission MUST be assignable only to a Client Device Identity.

**REQ-AUTONOMOUS-AUTHORIZATION-001** — A production Autonomous Participant Admission MUST require a current Authorization Assertion granting `Use Training Simulation` to the bound Autonomous Controller Identity and `Operate Autonomous Participant` to the bound Client Device Identity.

**REQ-AUTONOMOUS-ADMISSION-001** — One successful Autonomous Participant Admission MUST atomically bind one stable Admission identifier, the current controlling connection, Autonomous Controller Identity, Client Device Identity, Session Authority Identity, and the exact controller release and configuration identities before any Autonomous Participant effect becomes visible.

**REQ-AUTONOMOUS-ADMISSION-UNIQUENESS-001** — At most one current Admission MAY exist for the same Autonomous Controller Identity and at most one for the same Client Device Identity; the Session Authority MUST reject a duplicate or inconsistent identity, connection, or Admission-identifier binding while preserving the existing current Admission.

**REQ-AUTONOMOUS-HUMAN-AUTH-NOT-APPLICABLE-001** — Trainee Identity and the Trainee Authentication Act MUST NOT be required for an Autonomous Participant and MUST NOT be inferred from its controller or device identity.

**REQ-AUTONOMOUS-PRODUCTION-SECURITY-001** — Production Admission of an Autonomous Participant MUST remain blocked until the Production Security Baseline supplies and approves the applicable identity evidence, authenticator-control proof, authorization, protected exchange, revocation, trusted-time, audit, and trust-package rules for Autonomous Controller Identity.

## Continuity, revocation, audit, and recovery

**REQ-AUTONOMOUS-CONTINUITY-001** — Autonomous Participant continuity MUST exist only while its current Admission, exact controlling connection, identity and permission bindings, controller release, configuration, applicable content, and separate Team Position participation binding remain valid.

**REQ-AUTONOMOUS-CONTINUITY-002** — A different or restarted connection MUST obtain a new Admission and MUST NOT inherit an Admission identifier, unacknowledged Intention, controller sequence, or live Autonomous Participant state from the preceding connection.

**REQ-AUTONOMOUS-REVOCATION-001** — Revocation or expiry of the bound Autonomous Controller Identity, Client Device Identity, required AUTH Permission, Authorization Assertion, or applicable trust input MUST end the Admission and prevent every later Intention or effect from that connection.

**REQ-AUTONOMOUS-AUDIT-001** — Every Autonomous Participant authentication, authorization, Admission, continuity, revocation, and audit-recovery operation MUST use the applicable AUTH Attempt, AUTH Operation, AUTH Audit Record, atomic commit, retention, integrity, denial, and data-minimization rules of the Production Security Baseline.

**REQ-AUTONOMOUS-AUDIT-ATTRIBUTION-001** — Retained action-source evidence MUST bind each submitted Intention and its authoritative disposition to the Training Session, Admission identifier, Autonomous Participant's Team Position, controller sequence, exact controller release and configuration, and applicable content versions without placing gameplay payloads in AUTH Audit Records.

**REQ-AUTONOMOUS-RECOVERY-001** — Before active simulation, controller-process recovery MAY create a new connection and Admission and repeat ordinary readiness; during active simulation, loss of the controlling connection MUST irreversibly remove that Autonomous Participant from live canonical state under the same ordering and atomicity boundary as Technical Removal.

**REQ-AUTONOMOUS-RECOVERY-002** — Recovery MUST NOT restore or infer canonical state from controller-local state, bypass ordinary Admission, reclaim an occupied Team Position, or resume a completed, terminated, or technically removed participant.

## Actions and authority

**REQ-AUTONOMOUS-ACTION-SOURCE-001** — Every Intention submitted for an Autonomous Participant MUST carry an unambiguous source binding to its current Admission and monotonically increasing controller sequence, and the Session Authority MUST reject a missing, stale, duplicate, future, or mismatched source binding.

**REQ-AUTONOMOUS-INTENTION-001** — A controlling client MAY submit only Intentions for represented actions admitted by the current Action Inventory and Scenario; it MUST NOT submit a Canonical Tick, authoritative ordering, outcome, impact, injury, Scenario progression, or result.

**REQ-AUTONOMOUS-AUTHORITY-001** — The Session Authority MUST remain the sole owner of authoritative positions, physical interactions, impacts, injury, action acceptance and ordering, Scenario progression, completion, and results for Autonomous Participants.

**REQ-AUTONOMOUS-ACTION-EQUIVALENCE-001** — For the same admitted action, canonical initial state, content, and Approved Profiles, an Autonomous Participant Intention MUST be validated and resolved by the same represented-action rules and outcome boundaries as a Trainee Intention.

**REQ-AUTONOMOUS-PHYSICAL-EQUIVALENCE-001** — Autonomous Participants MUST obey the same applicable collision, movement, load, Fatigue, Stress Load, equipment, weapon, projectile, injury, Functional State, environment, and harmful-effect rules as Trainees.

**REQ-AUTONOMOUS-ACTION-ORDER-001** — Concurrent Autonomous Participant and Trainee Intentions MUST enter the same authoritative ordering and conflict rules; software control MUST confer no ordering priority or reserved execution capacity.

## Team, capacity, and Scenario participation

**REQ-AUTONOMOUS-TEAM-POSITION-001** — An Autonomous Participant MUST occupy exactly one otherwise ordinary Team Position, and that position MUST be occupiable by at most one Trainee or Autonomous Participant.

**REQ-AUTONOMOUS-CAPACITY-001** — Each Autonomous Participant MUST count as one participant toward the existing configured Team size and eight-position Team maximum; replacing a Trainee with an Autonomous Participant MUST NOT increase either Team or Training Session capacity.

**REQ-AUTONOMOUS-MIXED-ROSTER-001** — The Autonomous Participant baseline MUST support every Trainee and Autonomous Participant mixture permitted by the Scenario across the configured Team Positions, including all-human, mixed, and all-autonomous Teams, without changing the two-Team rule.

**REQ-AUTONOMOUS-PREPARATION-001** — Team Position selection, concurrency, Loadout selection, readiness, countdown, Spawn Transform placement, start, departure, and end-condition rules MUST apply to an Autonomous Participant except where this baseline states an explicit role-specific replacement for a human-only precondition.

**REQ-AUTONOMOUS-READINESS-001** — An Autonomous Participant MUST NOT enter `Ready` until its current Admission, Team Position, Loadout, content, controller release, controller configuration, required client capabilities, and Scenario authorization are valid and the controlling client explicitly declares readiness.

**REQ-AUTONOMOUS-SCENARIO-APPLICABILITY-001** — Every Scenario version admitting an Autonomous Participant MUST identify each eligible Team Position, permitted Loadouts and represented actions, exact controller release and configuration constraints, and every role-specific completion or failure rule.

**REQ-AUTONOMOUS-SCENARIO-CLOSED-001** — A Scenario with no approved Autonomous Participant applicability record MUST reject Autonomous Participant selection and Admission; silence MUST NOT mean applicability.

## Perception and prohibited inputs

**REQ-AUTONOMOUS-PERCEPTION-001** — An Autonomous Participant MUST receive only Scenario-relevant information that a Trainee at the same canonical state, pose, equipment state, viewpoint, acoustic receiver, and environmental conditions could perceive under Diegetic Presentation.

**REQ-AUTONOMOUS-PERCEPTION-EQUIVALENCE-001** — Machine-readable perception MAY differ in representation from human Presentation only when an approved mapping proves that it exposes neither more information nor a more precise tactically relevant outcome than the corresponding Trainee perception within approved tolerances.

**REQ-AUTONOMOUS-PRIVILEGED-INPUT-001** — A controlling client MUST NOT receive direct canonical state, hidden entity state, opposing-Team identity, unobstructed geometry, exact future state, privileged Scenario state, authoritative random state, or any other input unavailable through the equivalent Trainee perception boundary.

**REQ-AUTONOMOUS-PERCEPTION-FAILURE-001** — Missing, stale, duplicated, reordered, or invalid perception input MUST be explicit to the controller and MUST NOT be repaired with direct or privileged canonical-state access.

## Observability and deterministic replay

**REQ-AUTONOMOUS-OBSERVABILITY-001** — The approved Observability Contract successor for this baseline MUST identify controller-process lifecycle, exact runtime and controller identities, Admission correlation, perception delivery, Intention submission, authoritative disposition, connection loss, revocation, and removal with finite cardinality, ordering, loss, privacy, and correlation rules.

**REQ-AUTONOMOUS-OBSERVABILITY-002** — Autonomous Participant signals MUST distinguish the Autonomous Participant's Team Position, controlling connection, Admission, and controller sequence through opaque non-personal identifiers and MUST NOT expose identity evidence, authenticators, reusable proofs, or prohibited gameplay payloads.

**REQ-AUTONOMOUS-OBSERVABILITY-003** — Signal loss, ambiguity, or correlation failure affecting an Autonomous Participant acceptance measurement MUST block that measurement under the Observability Contract rather than permit estimation or reconstruction from privileged state.

**REQ-AUTONOMOUS-REPLAY-001** — Deterministic controller replay evidence MUST bind the exact controller release, configuration, initial controller state, random-seed material, ordered permitted perception inputs, Operational Clock inputs visible to the controller, and expected Intention sequence.

**REQ-AUTONOMOUS-REPLAY-002** — Replaying those exact inputs in the approved replay environment MUST reproduce the same Intention payloads, source sequence, and submission decisions; each mismatch MUST identify the first divergent input or output and fail the replay.

**REQ-AUTONOMOUS-REPLAY-003** — Deterministic controller replay MUST NOT be presented as proof of Session Authority determinism, tactical validity, human-equivalent behavior, or access to canonical state.

## Workload, performance, and failure

**NFR-AUTONOMOUS-WORKLOAD-001** — Approved workload profiles MUST count every Autonomous Participant as one ordinary client connection and MUST declare the exact Trainee, Autonomous Participant, rendered-client, and synthetic-client populations and action rates without double-counting one connection in multiple roles.

**NFR-AUTONOMOUS-WORKLOAD-002** — Performance acceptance for the Autonomous Participant baseline MUST include the maximum 16-participant configuration with every occupied Team Position autonomous and at least one mixed-roster configuration, while retaining every applicable existing Session Authority and network threshold.

**NFR-AUTONOMOUS-ACTION-RESPONSE-001** — The interval from an Autonomous Participant's valid Intention submission to its receipt of the authoritative result MUST satisfy the same `NFR-ACTION-RESPONSE-001` threshold and evidence rules as a synthetic or rendered client under the exact approved workload and hardware profiles.

**NFR-AUTONOMOUS-RESOURCE-ISOLATION-001** — Controller computation MUST execute outside the Session Authority process, and its resource consumption or failure MUST NOT weaken a Session Authority timing, capacity, observability, or deterministic-simulation acceptance criterion.

**NFR-AUTONOMOUS-CONTROL-TIMING-001** — Any claim about controller decision speed, tactical response time, or action cadence MUST use an exact pre-approved Scenario and controller-performance profile with objective thresholds, workload, hardware, timing boundaries, and evidence; this baseline establishes no unstated universal decision-time target.

**REQ-AUTONOMOUS-FAILURE-001** — A controller stall or failure to submit an Intention MUST produce no inferred, repeated, or default represented action and MUST NOT pause authoritative simulation.

**REQ-AUTONOMOUS-FAILURE-002** — Malformed, unauthorized, excessive, or out-of-sequence controller input MUST be rejected within the ordinary client trust boundary without altering canonical state except for an explicitly authorized lifecycle response.

**REQ-AUTONOMOUS-FAILURE-003** — Loss or failure of one Autonomous Participant controller MUST NOT terminate another participant's Admission or grant another controller its identity, Team Position, sequence, or pending action.

**REQ-AUTONOMOUS-FAILURE-004** — A failure that makes the controller's identity, Admission, input provenance, perception boundary, or deterministic replay evidence uncertain MUST block acceptance of the affected Autonomous Participant result.

## Security and retained outputs

**REQ-AUTONOMOUS-SECURITY-001** — An Autonomous Participant controlling client and every submitted Intention MUST be treated as untrusted input; software control MUST confer no direct memory, module-private state, protocol, observability, administrative, or content-admission privilege.

**REQ-AUTONOMOUS-SECURITY-002** — The controller release, configuration, model or policy data, and random-seed material used for acceptance MUST have immutable exact identities, integrity evidence, approved provenance, and retained availability for audit and replay without being admitted as authoritative runtime content by this requirement alone.

**REQ-AUTONOMOUS-SECURITY-003** — Secrets, identity evidence, authenticator-control proofs, and AUTH Protected Exchange material MUST NOT enter controller perception, gameplay state, Scenario results, Training Feedback, or future AAR data.

## Applicability decisions

**REQ-AUTONOMOUS-ASSESSMENT-001** — Trainee Performance Assessment, Training Feedback, Formal Assessment, qualification status, and Leaderboard eligibility MUST NOT be produced for or attributed to an Autonomous Participant.

**REQ-AUTONOMOUS-ASSESSMENT-IDENTITY-001** — An Autonomous Controller Identity, Client Device Identity, Admission identifier, or Autonomous Participant's Team Position MUST NOT be represented as a Trainee Identity or presentation name in a Formal Assessment or Leaderboard.

**REQ-AUTONOMOUS-AAR-001** — The future After-Action Review baseline MAY include attributable Autonomous Participant perceptions, Intentions, authoritative dispositions, and outcomes, but this baseline MUST NOT claim AAR capability or place AUTH Audit Record contents in AAR data.

**REQ-AUTONOMOUS-RECOVERY-SUBJECT-001** — Replacing the Recovery Proxy with an autonomously controlled Recovery Subject MUST remain a distinct future `Autonomous Recovery Subject Baseline`; it MAY depend on this baseline but MUST NOT count as coverage or acceptance of the general Autonomous Participant role.

## Acceptance and change control

**PROCESS-AUTONOMOUS-APPLICABILITY-001** — Before architecture or implementation planning, the Baseline Applicability Inventory MUST classify every identifier in this document under the `Autonomous Participant baseline` milestone, preserve every existing Development Baseline disposition, and retain the distinct `Autonomous Recovery Subject Baseline` milestone while recording its dependency on this baseline.

**PROCESS-AUTONOMOUS-SCENARIO-INVENTORY-001** — Before a Scenario admits an Autonomous Participant, the implementation team MUST reconcile its complete role-applicability population against every Team Position, Loadout, represented action, perception source, objective, end condition, and failure rule, and the project owner MUST approve the exact inventory version.

**PROCESS-AUTONOMOUS-PERCEPTION-COVERAGE-001** — Before acceptance, a versioned perception-equivalence inventory MUST map every controller-visible field and precision to the corresponding Trainee-perceptible source and tolerance and MUST reject every missing, unmatched, more precise, hidden, or privileged input.

**PROCESS-AUTONOMOUS-VERIFICATION-001** — Every requirement in this baseline MUST receive stable obligation keys, Required verification methods, pre-registered evidence records and dependencies, exact input and environment identities, attributable results, and project-owner approval under the Verification Plan and current Evidence Dependency Inventory.

**PROCESS-AUTONOMOUS-EVALUATION-001** — Representative Evaluation MUST be Required only for an obligation whose acceptance claims tactical adequacy, credible military behavior, or perception equivalence beyond reproducible objective criteria; technical role, authority, identity, and prohibited-access obligations remain objectively verifiable.

**PROCESS-AUTONOMOUS-ACCEPTANCE-001** — The Autonomous Participant baseline MUST NOT be accepted until its exact requirement set, applicability and artifact inventories, identity and permission catalogues, Scenario applicability records, controller and perception profiles, Observability Contract, verification procedures, evidence dependencies, and required evidence are approved with no missing, stale, uncertain, failed, or blocked included obligation.

**PROCESS-AUTONOMOUS-CHANGE-001** — A change to an Autonomous Participant definition, identifier, identity or permission rule, Admission binding, controller input or output, Scenario applicability, perception mapping, workload, profile, assignment range, dependency, or acceptance criterion MUST create the applicable governed successor and trigger conservative evidence-impact analysis under the current approved Evidence Dependency Inventory.

## Completion rule

This requirement set is ready for approval when every issue #26 decision and
obligation is represented by a stable identifier, every Development Baseline
disposition remains unchanged except the explicitly traced Recovery Subject
reconciliation, the governed successor inventories and generated assignment
view reconcile, both independent review axes pass, and the project owner
approves the exact candidate versions and package digests. Approval makes the
requirements eligible for later architecture, design, implementation, and
verification planning; it does not admit the capability.
