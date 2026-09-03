# Training Simulation Initial Requirements

Status: Approved Functional Baseline

Approval: Project owner, 2026-08-28

Latest approved amendment: Technical Removal and retained-evidence architecture, project owner, 2026-09-03

Canonical language: English

Canonical information owner: Project owner

Interview coverage: Accepted answers through Q267 and AUTH-Q31, followed by project-owner authorization to accept every remaining recommended AUTH closure decision, plus the project-owner-confirmed issue #33 and #35 architecture grillings. No AUTH, runtime-content, Technical Removal, or retained-evidence interview question remains open.

Priority convention: `MUST` and `MUST NOT` are required for the accepted initial baseline; `SHOULD` records an approved preference; `MAY` records permitted behavior. Deferred capabilities and non-goals are outside that baseline.

Acceptance convention: Unless a separate acceptance condition is stated, the normative sentence attached to an identifier is its pass/fail criterion. The verification plan assigns the procedure, evidence, evidence owner, and final approver for every identifier.

Canonical-ordering convention: In a functional requirement, `immediately` means within the same canonical state transition that accepts the triggering event and before any subsequent event or simulation advancement is processed. It does not define a wall-clock latency target; latency belongs to the separate NFR baseline.

Glossary: [CONTEXT.md](../../CONTEXT.md)

Research rubric: [initial-goals-requirements-and-constraints-guidance.md](../research/initial-goals-requirements-and-constraints-guidance.md)

Non-functional requirements: [training-simulation-non-functional-requirements.md](training-simulation-non-functional-requirements.md)

Reference hardware profiles: [training-simulation-reference-hardware-profiles.md](training-simulation-reference-hardware-profiles.md)

Observability contract: [training-simulation-observability-contract.md](training-simulation-observability-contract.md)

Trainee Performance Assessment requirements: [training-simulation-performance-assessment-requirements.md](training-simulation-performance-assessment-requirements.md)

Verification plan: [training-simulation-verification-plan.md](training-simulation-verification-plan.md)

## Table of contents

- [Purpose](#purpose)
- [Goals](#goals)
- [Goal traceability](#goal-traceability)
- [Product boundary](#product-boundary)
- [Assumptions](#assumptions)
- [Teams, identity, and preparation](#teams-identity-and-preparation)
- [Loadouts and starting state](#loadouts-and-starting-state)
- [Ready and initial start](#ready-and-initial-start)
- [Connection and admission](#connection-and-admission)
- [Disconnection and Technical Removal](#disconnection-and-technical-removal)
- [Voluntary departure and process completion](#voluntary-departure-and-process-completion)
- [Scenario and Map model](#scenario-and-map-model)
- [Scenario selection and hosting](#scenario-selection-and-hosting)
- [Briefing, navigation, and identification](#briefing-navigation-and-identification)
- [Diegetic Presentation](#diegetic-presentation)
- [Access modes and input](#access-modes-and-input)
- [Action execution](#action-execution)
- [Session Authority and canonical state](#session-authority-and-canonical-state)
- [Communication](#communication)
- [Locomotion, load, fatigue, and Stress Load](#locomotion-load-fatigue-and-stress-load)
- [Items and carrying](#items-and-carrying)
- [Weapons, aiming, and recoil](#weapons-aiming-and-recoil)
- [Ammunition and reload](#ammunition-and-reload)
- [Weapon Malfunctions](#weapon-malfunctions)
- [Ballistics and physical effects](#ballistics-and-physical-effects)
- [Acoustic Propagation](#acoustic-propagation)
- [Injury and Trainee Functional State](#injury-and-trainee-functional-state)
- [Melee](#melee)
- [Trainee collision and friendly fire](#trainee-collision-and-friendly-fire)
- [Environment damage](#environment-damage)
- [Reference Personnel Recovery Scenario](#reference-personnel-recovery-scenario)
- [Content authoring and admission](#content-authoring-and-admission)
- [Platform and deployment constraints](#platform-and-deployment-constraints)
- [Project and documentation constraints](#project-and-documentation-constraints)
- [Non-goals](#non-goals)
- [Deferred capabilities](#deferred-capabilities)

## Purpose

This document captures the accepted goals, functional requirements, product constraints, scope decisions, deferred capabilities, and non-goals for the Training Simulation. It is an input to architecture; it does not select the internal architecture of the Simulation Engine.

Definitions live only in `CONTEXT.md`. Terms capitalized as glossary entries have their canonical meaning there.

Intended readers are the project owner, requirements reviewers, architects, designers, implementers, and verification authors. Prerequisites are the canonical glossary and the research rubric linked above; the separate NFR document owns quality requirements and is not required to interpret functional behavior.

## Goals

**GOAL-TRAINING-001** — Enable armed-forces Teams to rehearse shooting Scenarios that are impractical to reproduce at full physical scale through a multiplayer Training Simulation accessible from conventional PCs and, later, optional virtual-reality equipment.

**GOAL-TEAM-TACTICS-001** — Enable Teams to practise coordination and team tactics, with communication, movement, use of cover, and response to threats as supporting training outcomes.

## Goal traceability

| Goal or boundary | Requirement coverage | Concrete validation anchor |
| --- | --- | --- |
| `GOAL-TRAINING-001` | Session lifecycle; Scenario and Map model; access modes and input; canonical state; weapons, ballistics, physical effects, injury, and environment behavior | The Reference Personnel Recovery Scenario and its versioned approved content profiles |
| `GOAL-TEAM-TACTICS-001` | Teams and preparation; briefing and identification; communication; locomotion and load; carrying; friendly fire; recovery objective and results | The two opposing Teams completing or preventing the reference recovery objective without non-diegetic assistance |
| `CONSTRAINT-ACTION-SCOPE-001` | Every included Trainee action, especially shooting, explosive use, breaching, Melee, and physical interaction | Each action must support an identified military training activity rather than entertainment or cinematic presentation alone |
| Initial product boundary | Product, role, document, financial, platform, deployment, project, and documentation constraints | Non-goals and deferred capabilities identify behavior that must not be inferred as part of the accepted baseline |

**PROCESS-TRACEABILITY-001** — Every architecture, design, implementation, and verification artifact registered in the Baseline Artifact Inventory MUST cite the stable identifiers it satisfies or intentionally defers; section names alone are not sufficient traceability.

**PROCESS-TRACEABILITY-INVENTORY-001** — The Baseline Artifact Inventory MUST record a stable artifact identifier, artifact class, exact version, canonical location, baseline status, and responsible owner for every governed architecture, design, implementation, and verification artifact.

**PROCESS-TRACEABILITY-INVENTORY-002** — Before a candidate baseline is approved, the implementation team MUST reconcile the Baseline Artifact Inventory against the complete current authoritative repositories or registries for all four artifact classes, and the project owner MUST approve the exact inventory version.

**PROCESS-TRACEABILITY-INVENTORY-003** — Every registered artifact MUST have complete stable-identifier traces or an explicit non-applicability or intentional-deferral record; a missing artifact, missing trace, stale inventory entry, or unclassified artifact MUST block baseline approval.

## Product boundary

**SCOPE-PRODUCT-001** — The product is the Training Simulation. The Simulation Engine is an internal means of satisfying validated Training Simulation needs, not an independently reusable or general-purpose product.

**SCOPE-ROLE-001** — The initial accepted baseline includes Trainees as the only active Training Session role.

**SCOPE-REQUIREMENTS-DOCUMENT-001** — This document owns goals, functional requirements, functional constraints, assumptions, deferred capabilities, and non-goals.

**SCOPE-REQUIREMENTS-DOCUMENT-002** — Before approval of an overall product baseline, non-functional requirements MUST be defined in the separately identified canonical [Training Simulation Non-Functional Requirements](training-simulation-non-functional-requirements.md); interview notes and other transient elicitation material MUST NOT be treated as requirements.

**SCOPE-FINANCE-001** — Financial limits, expenditure analysis, licensing cost, and budget planning are outside this requirements effort.

**CONSTRAINT-ACTION-SCOPE-001** — A Trainee action MUST be admitted to the baseline only when the Action Inventory traces it to an approved Training Need Record; entertainment or cinematic value alone MUST NOT justify admission.

**PROCESS-ACTION-INVENTORY-001** — The Action Inventory MUST enumerate every Trainee action admitted to the candidate baseline with a stable action identifier, action name, behavior scope, applicable requirement identifiers, and Training Need Record trace.

**PROCESS-ACTION-INVENTORY-002** — Each Training Need Record MUST state a stable identifier and version, the military training activity, intended training outcome, applicability scope, rationale, and project-owner approval recorded before the traced action is admitted.

**PROCESS-ACTION-INVENTORY-003** — Before baseline approval, the implementation team MUST reconcile the Action Inventory against every Trainee action exposed by the candidate product and reject any missing, untraced, unapproved, or entertainment-only action.

**SCOPE-AUTH-001** — The initial functional baseline includes mutual Session Authority and client authentication, authorization, initial Admission, offline validation, and AUTH auditing under the requirements in this document; these capabilities MUST NOT be treated as deferred.

**SCOPE-MELEE-001** — The initial Melee baseline MUST support last-resort close physical combat and MUST NOT treat custody, restraint, or control of a person as a Melee objective.

## Assumptions

**ASSUMPTION-AUTH-AUDIT-CHECKPOINT-001** — The external host environment collects and retains AUTH Audit Checkpoints outside the storage of their AUTH Audit Sequence; without a surviving externally retained checkpoint, the Training Simulation cannot guarantee detection of terminal-record or complete-sequence deletion by an actor controlling the host.

**ASSUMPTION-AUTH-HUMAN-CONTROL-001** — After the initial Trainee Authentication Act, the Training Simulation does not continuously verify the physical human operating an Admitted Client and cannot distinguish the authenticated Trainee from another person who takes control of that admitted computer.

**ASSUMPTION-AUTH-IDENTITY-AUTHORITY-001** — The Training Simulation relies on the Identity Authority to issue correct identity bindings, Authentication Assurance Profiles, Authorization Assertions, Offline Revocation Status values, issuer records, and validity intervals; evidence that is valid under the approved catalogue cannot reveal an Identity Authority mis-issuance by itself.

## Teams, identity, and preparation

**REQ-TEAM-001** — A Training Session MUST contain exactly two opposing Teams.

**REQ-CAPACITY-001** — A Training Session with eight Trainees assigned to each Team MUST be a supported configuration.

**REQ-CAPACITY-002** — Each Team MUST contain between one and eight Trainees, inclusive.

**REQ-CAPACITY-003** — The required size of each Team MUST be configurable independently; numerical balance between Teams is not required.

**REQ-IDENTITY-001** — A Trainee MUST be able to join without a persistent user account.

**REQ-CALL-SIGN-001** — Before entering `Ready`, each Trainee MUST choose a Call Sign unique within the current Training Session.

**REQ-TEAM-JOIN-001** — During preparation, a Trainee MUST be able to select an available Team Position in either Team.

**REQ-TEAM-CHANGE-001** — During preparation, a Trainee MUST be able to change Team by selecting an available Team Position in the destination Team.

**REQ-TEAM-LOCK-001** — Team assignments MUST become locked in the canonical transition that starts the initial countdown and MUST remain locked until a canonical transition enters Preparation.

**REQ-TEAM-RESET-001** — After a canonical transition enters Preparation, Team assignments MUST be changeable again through the ordinary availability and concurrency rules.

**REQ-TEAM-POSITION-CONCURRENCY-001** — When concurrent requests target the same final available Team Position, the Session Authority MUST accept no more than one request and MUST reject every request that cannot be satisfied without assigning that Team Position more than once.

## Loadouts and starting state

**REQ-LOADOUT-001** — Each Scenario MUST define the Loadouts available to each Team.

**REQ-LOADOUT-CAPACITY-001** — Each Scenario MUST define the available quantity of each Loadout in each Team.

**REQ-LOADOUT-CAPACITY-002** — Selected Loadouts MUST NOT exceed their configured quantities.

**REQ-LOADOUT-SELECTION-001** — During preparation, each Trainee MUST select an available Loadout permitted for that Trainee's Team.

**REQ-LOADOUT-CONCURRENCY-001** — When concurrent requests target the final available quantity of one Loadout, the Session Authority MUST accept no more requests than the remaining quantity and MUST reject every request that would exceed that quantity.

**REQ-PREPARATION-REJECTION-001** — Rejection of a Team Position or Loadout request MUST leave the requesting Trainee in preparation, preserve that Trainee's preceding selection if it remains valid, expose the updated availability state, and MUST NOT select an alternative automatically.

**REQ-READY-LOADOUT-001** — A Trainee MUST NOT enter `Ready` without a valid Loadout selection.

**REQ-LOADOUT-LOCK-001** — The selected Loadout MUST become locked in the canonical transition that starts the initial countdown and MUST remain locked until a canonical transition enters Preparation.

**REQ-SPAWN-001** — Each Scenario MUST associate every configured Team Position with exactly one Map-owned spatial-anchor identifier and version whose canonical transform is that position's Spawn Transform.

**REQ-SPAWN-LOADOUT-INDEPENDENCE-001** — Selecting or changing a Loadout MUST NOT change the Spawn Transform assigned to a Team Position.

**REQ-SPAWN-002** — When the initial countdown completes, the Session Authority MUST place every Trainee at the Spawn Transform of the assigned Team Position and activate all Trainees in one canonical state transition; no authoritative state in which any Trainee is active before every placement is committed MAY be observable.

**REQ-SPAWN-VALIDATION-001** — A Scenario MUST NOT reach a startable state when placing each currently assigned Trainee's approved collision and occupancy volume at the applicable Spawn Transform would intersect another placed Trainee volume or would not be fully contained by the exact Map-owned initial-placement region referenced by the Scenario.

**REQ-SPAWN-GEOMETRY-001** — For every configured Team Position, the Scenario MUST identify the exact Approved Profile version that defines the applicable Trainee collision and occupancy volume and the stable identifier and version of the applicable initial-placement region in the selected Map.

**REQ-SPAWN-GEOMETRY-002** — Each initial-placement region MUST be canonical Map content traced to its exact Blender source version, and its deployment-ready version MUST satisfy the current content identity, integrity, and format requirements before spawn validation.

**REQ-SPAWN-GEOMETRY-003** — Spawn-validation evidence MUST bind its placed volumes, region geometry, Spawn Transforms, current Team Position assignments, selected Loadouts, Map content, Scenario content, and Approved Profiles to their exact identifiers and versions.

## Ready and initial start

**REQ-OPERATIONAL-CLOCK-001** — The Session Authority MUST be the sole authority for the Operational Clock used by initial countdowns and runtime lifecycle deadlines.

**REQ-OPERATIONAL-CLOCK-002** — The Operational Clock MUST advance monotonically and MUST remain independent from simulated time and Scenario timers.

**REQ-OPERATIONAL-CLOCK-003** — A client clock or client-provided timestamp MUST NOT determine countdown completion, deadline expiry, or authoritative event ordering.

**REQ-DEADLINE-ORDER-001** — An event that satisfies a deadline condition MUST be accepted by the Session Authority at an Operational Clock time strictly earlier than that deadline.

**REQ-DEADLINE-ORDER-002** — A condition-invalidating event assigned an authoritative Operational Clock time equal to a countdown-completion deadline MUST be applied before the completion transition and MUST prevent that countdown from completing.

**REQ-SESSION-ROSTER-001** — Before a Training Session can start, its configuration MUST specify the required number of Trainees for each Team.

**REQ-INITIAL-START-CONDITIONS-001** — The initial Initial Start Condition Set MUST contain exactly: a configured two-Team roster satisfying `REQ-TEAM-001`, `REQ-CAPACITY-002`, and `REQ-CAPACITY-003`; each Team filled to its independently configured required size; every assigned Trainee in `Ready`; the Session Authority's exact Authority Pack and immutable Runtime Content Release view loaded with verified identity, signature, role, content contract, pair binding, integrity, and completeness; and successful validation of `REQ-LOADOUT-001`, `REQ-LOADOUT-CAPACITY-001`, `REQ-SPAWN-001`, `REQ-SPAWN-VALIDATION-001`, `REQ-SCENARIO-MAP-001`, `REQ-SCENARIO-END-001`, and `REQ-SCENARIO-DURATION-001`.

**REQ-INITIAL-START-CONDITIONS-002** — The Initial Start Condition Set MUST be versioned and MUST trace every condition to its governing stable identifiers and exact configuration evidence.

**REQ-INITIAL-START-CONDITIONS-003** — Before use, the implementation team MUST reconcile the Initial Start Condition Set against the current requirements baseline and the project owner MUST approve its exact version.

**REQ-INITIAL-START-CONDITIONS-004** — The initial baseline MUST NOT prevent countdown or start because of a condition absent from the approved Initial Start Condition Set.

**REQ-READINESS-001** — A Trainee MUST satisfy every applicable requirement from `REQ-READINESS-PRECONDITION-001` through `REQ-READINESS-PRECONDITION-006` and explicitly declare readiness before entering `Ready`.

**REQ-READINESS-PRECONDITION-001** — The Trainee's client MUST have an admitted active connection to the Session Authority.

**REQ-READINESS-PRECONDITION-002** — The Trainee MUST have a Call Sign unique within the current Training Session and an assigned Team Position.

**REQ-READINESS-PRECONDITION-003** — The Trainee MUST have a valid selected Loadout permitted for the assigned Team and available within its configured quantity.

**REQ-READINESS-PRECONDITION-004** — Before connection, the client MUST validate and completely materialize the exact Client Pack selected for the process; before Admission, it MUST confirm that pack's Runtime Content Release identity, Scenario, role, content contract, pair binding, and integrity against the Session Authority.

**REQ-READINESS-PRECONDITION-005** — The client MUST have the required input, visual-output, and audio-input-and-output devices for the selected access mode available to the Training Simulation.

**REQ-READINESS-PRECONDITION-006** — The client MUST have one current Admission whose retained Trainee Identity and Client Device Identity bindings match that client connection and whose Session Authority Identity matches the current Session Authority.

**REQ-READINESS-CLOSED-001** — The initial baseline MUST NOT prevent a Trainee from entering `Ready` because of a condition not stated by `REQ-READINESS-001` or `REQ-READINESS-PRECONDITION-001` through `REQ-READINESS-PRECONDITION-006`.

**REQ-READINESS-002** — The system MUST revoke `Ready` if any readiness precondition stops being true before start.

**REQ-SESSION-START-001** — A Training Session MUST NOT start unless every condition in the approved Initial Start Condition Set holds.

**REQ-SESSION-COUNTDOWN-001** — When every condition in the approved Initial Start Condition Set holds, the system MUST automatically start a shared five-second countdown measured by the Operational Clock.

**REQ-SESSION-COUNTDOWN-002** — Active simulation MUST start when that countdown completes while every condition in the approved Initial Start Condition Set still holds.

**REQ-SESSION-COUNTDOWN-003** — If any condition in the approved Initial Start Condition Set becomes false during the countdown, including a Trainee losing `Ready` or disconnecting, the system MUST cancel the countdown immediately and enter Preparation in that canonical transition.

**REQ-SESSION-COUNTDOWN-004** — A cancelled countdown MUST restart from five seconds only after every condition in the approved Initial Start Condition Set holds again.

## Connection and admission

**REQ-SESSION-CONNECTION-001** — A Trainee MUST join by manually entering the Session Authority network address.

**REQ-SESSION-ACCESS-001** — Any LAN device that knows the address MUST be allowed to initiate Session Authority validation, but knowledge of the address MUST NOT authenticate an identity, authorize use, create an Admission, or reserve Training Session capacity.

**REQ-AUTH-SUBJECT-001** — Before admitting a client to Preparation, the Session Authority MUST successfully authenticate exactly one Trainee Identity and exactly one Client Device Identity and MUST bind both authenticated identities to that admitted client connection.

**REQ-AUTH-IDENTITY-AUTHORITY-001** — The authoritative creation, change, suspension, revocation, and retirement of every Trainee Identity, Client Device Identity, and Session Authority Identity MUST be owned by an Identity Authority outside the Training Simulation.

**REQ-AUTH-IDENTITY-OWNERSHIP-001** — The Training Simulation MUST NOT create, change, suspend, revoke, retire, or act as the authoritative registry for a Trainee Identity, Client Device Identity, or Session Authority Identity.

**REQ-AUTHORITY-AUTHENTICATION-001** — Before presenting Trainee Identity or Client Device Identity authentication evidence, a Trainee client MUST successfully authenticate exactly one Session Authority Identity for the endpoint to which it is connecting.

**REQ-AUTHORITY-AUTHORIZATION-001** — Before presenting Trainee Identity or Client Device Identity authentication evidence, a Trainee client MUST establish from an applicable Authorization Assertion that the authenticated Session Authority Identity is authorized to operate the Training Simulation authority role.

**REQ-AUTHORITY-FAILURE-001** — If Session Authority Identity authentication or authorization fails, the client MUST stop the admission attempt and MUST NOT present Trainee Identity or Client Device Identity authentication evidence to that endpoint.

**REQ-AUTH-TRAINEE-PRESENCE-001** — Every initial admission attempt MUST require a new Trainee Authentication Act before the Session Authority may authenticate and bind the Trainee Identity to the client connection.

**REQ-AUTH-TRAINEE-REUSE-001** — Successful Trainee Identity authentication for one initial admission attempt MUST NOT by itself authenticate a later initial admission attempt, including one made from the same client computer or client process.

**REQ-AUTH-OFFLINE-001** — Initial admission MUST remain possible without live communication with the Identity Authority when the client and Session Authority can present all applicable Offline-Verifiable Identity Evidence required to authenticate and authorize the Session Authority Identity, Trainee Identity, and Client Device Identity.

**REQ-AUTH-OFFLINE-VALIDATION-001** — Each party performing offline validation MUST establish the evidence issuer, exact subject identity, integrity, applicability, and current validity before treating that evidence as successful authentication or positive authorization.

**REQ-AUTH-OFFLINE-CACHE-001** — A previously recorded authentication, authorization, or admission decision MUST NOT substitute for current Offline-Verifiable Identity Evidence in a later initial admission attempt.

**REQ-AUTH-EVIDENCE-VALIDITY-001** — Every item of Offline-Verifiable Identity Evidence MUST contain an exact validity-start instant and validity-end instant established by its Identity Authority, with the end strictly later than the start.

**REQ-AUTH-EVIDENCE-VALIDITY-002** — Offline-Verifiable Identity Evidence MUST be treated as temporally valid exactly when the validation instant is equal to or later than its validity-start instant and strictly earlier than its validity-end instant.

**REQ-AUTH-EVIDENCE-VALIDITY-003** — Missing, malformed, unordered, not-yet-valid, or expired validity data MUST cause that evidence item to be rejected, and the Training Simulation MUST NOT extend or replace the Identity Authority's declared interval.

**REQ-AUTH-TIME-001** — A Trainee client MUST use its own Trusted Identity Time to validate Session Authority Identity evidence, and the Session Authority MUST use its own Trusted Identity Time to validate Trainee Identity and Client Device Identity evidence.

**REQ-AUTH-TIME-002** — A validating host MUST NOT use the Operational Clock, simulated time, or time supplied by the identity or endpoint being validated as the validation instant for Offline-Verifiable Identity Evidence.

**REQ-AUTH-TIME-003** — If a validating host cannot establish its Trusted Identity Time, it MUST reject the affected authentication or authorization validation and MUST NOT continue admission on the basis of that evidence.

**REQ-AUTH-REVOCATION-001** — Every identity-authentication evidence item and Authorization Assertion used for admission MUST have an applicable Offline Revocation Status issued by its Identity Authority and bound to that exact evidence item or assertion.

**REQ-AUTH-REVOCATION-002** — Each Offline Revocation Status MUST identify its issuer, bound evidence identity, `Current` or `Revoked` state, validity-start instant, and validity-end instant, and MUST satisfy the integrity and half-open temporal-validation rules applicable to Offline-Verifiable Identity Evidence.

**REQ-AUTH-REVOCATION-003** — Missing, malformed, mismatched, not-yet-valid, expired, unverifiable, or `Revoked` Offline Revocation Status MUST cause the bound evidence item or Authorization Assertion to be rejected.

**REQ-AUTH-REVOCATION-004** — A previously recorded revocation check or admission decision MUST NOT substitute for an applicable current Offline Revocation Status during a later initial admission attempt.

**REQ-AUTH-REVOCATION-CARDINALITY-001** — At one validation instant, exactly one temporally applicable Offline Revocation Status MUST exist for each evidence item or Authorization Assertion that requires one; zero or more than one applicable status, including overlapping `Current` values or any `Current` and `Revoked` conflict, MUST cause the bound item to be rejected.

**REQ-AUTH-CONTROL-PROOF-001** — Successful authentication of a Trainee Identity, Client Device Identity, or Session Authority Identity MUST require Authenticator Control Proof for the authenticator bound by the Identity Authority to that exact identity.

**REQ-AUTH-CONTROL-PROOF-002** — Possession of copied identity evidence, an Authorization Assertion, or an Offline Revocation Status without valid Authenticator Control Proof MUST NOT authenticate an identity or permit admission.

**REQ-AUTHORIZATION-BINDING-001** — Each Authorization Assertion MUST identify and apply only to the exact authenticated identity for which it was issued and MUST NOT be transferred to or combined with Authenticator Control Proof for another identity.

**REQ-AUTH-CONTROL-NONDISCLOSURE-001** — Producing Authenticator Control Proof MUST NOT require disclosure or transfer of the controlled authenticator to the validating peer.

**REQ-AUTH-CHALLENGE-001** — Every Authenticator Control Proof MUST respond to a new Authentication Challenge created by the validator for that exact AUTH Operation and AUTH Attempt.

**REQ-AUTH-CHALLENGE-BINDING-001** — An Authentication Challenge and its accepted proof MUST be bound to the exact presenter identity, validator identity, validation purpose, AUTH Operation class key and instance identifier, and AUTH Attempt class key and instance identifier for which the challenge was created.

**REQ-AUTH-CHALLENGE-USE-001** — An Authentication Challenge MUST be accepted at most once and MUST become invalid when its owning AUTH Operation reaches any terminal result; cancellation or supersession of the enclosing AUTH Attempt MUST propagate that invalidation under `REQ-AUTH-ATTEMPT-SUPERSESSION-001`.

**REQ-AUTH-REPLAY-001** — A proof created for a different, preceding, completed, failed, cancelled, superseded, or already accepted Authentication Challenge MUST be rejected and MUST NOT authenticate an identity or permit Admission.

**REQ-AUTH-TRAINEE-ASSURANCE-PROFILE-001** — Every Trainee Identity authentication-evidence item MUST identify the exact Authentication Assurance Profile version assigned by the Identity Authority to that identity.

**REQ-AUTH-TRAINEE-ASSURANCE-PROFILE-002** — The referenced Authentication Assurance Profile MUST enumerate the required authenticator classes, factor count, Trainee Authentication Act or other human-presence conditions, proof requirements, applicability conditions, and objective acceptance criteria.

**REQ-AUTH-TRAINEE-ASSURANCE-001** — The Session Authority MUST authenticate a Trainee Identity only when the complete presented Authenticator Control Proof satisfies every applicable criterion in the exact referenced Authentication Assurance Profile version.

**REQ-AUTH-TRAINEE-ASSURANCE-REJECTION-001** — A missing, unknown, unapproved, incomplete, mismatched, or partially satisfied Authentication Assurance Profile or proof set MUST cause Trainee Identity authentication and initial admission to be rejected.

**REQ-AUTH-MACHINE-ASSURANCE-PROFILE-001** — Every Client Device Identity and Session Authority Identity authentication-evidence item MUST identify the exact Authentication Assurance Profile version assigned by the Identity Authority to that identity.

**REQ-AUTH-MACHINE-ASSURANCE-PROFILE-002** — Client-device and Session Authority Authentication Assurance Profiles MAY differ from each other and from Trainee Identity profiles but MUST each provide the complete machine-applicable fields and objective acceptance criteria required by `REQ-AUTH-TRAINEE-ASSURANCE-PROFILE-002`, with human-presence fields explicitly classified as `Not Applicable` where appropriate.

**REQ-AUTH-MACHINE-ASSURANCE-001** — The Session Authority MUST authenticate a Client Device Identity, and a Trainee client MUST authenticate a Session Authority Identity, only when the complete presented Authenticator Control Proof satisfies every applicable criterion in the exact profile assigned to that identity.

**REQ-AUTH-MACHINE-ASSURANCE-REJECTION-001** — A missing, unknown, unapproved, incomplete, mismatched, or partially satisfied machine Authentication Assurance Profile or proof set MUST cause the affected authentication and admission attempt to be rejected.

**REQ-AUTH-ASSURANCE-INDEPENDENCE-001** — Satisfying the Authentication Assurance Profile for one identity MUST NOT satisfy or replace any criterion for another required identity.

**REQ-AUTH-EVIDENCE-CATALOGUE-001** — The Identity Evidence Catalogue MUST enumerate every supported Trainee Identity, Client Device Identity, and Session Authority Identity evidence type and version; Authorization Assertion and Offline Revocation Status type and version; required field and issuer; Authentication Assurance Profile; validation purpose and applicability condition; validation dependency; and objective validation rule.

**REQ-AUTH-EVIDENCE-CATALOGUE-002** — The Identity Evidence Catalogue MUST be closed and versioned, and every admitted row MUST identify the exact Identity Authority, evidence or assertion schema version, applicable identity class, proof and profile requirements, validation outputs, rejection conditions, and dependencies required for offline validation.

**REQ-AUTH-EVIDENCE-CATALOGUE-003** — Before use, the implementation team MUST reconcile the Identity Evidence Catalogue against every Authentication and authorization requirement and supported evidence dependency, and the project owner MUST approve its exact version.

**REQ-AUTH-EVIDENCE-CATALOGUE-004** — A missing, unknown, unsupported, unapproved, incomplete, or version-mismatched catalogue row, evidence item, assertion, status, profile, issuer, validation rule, or dependency MUST cause the affected validation and admission attempt to be rejected.

**REQ-AUTH-EVIDENCE-CATALOGUE-005** — A Trainee client and Session Authority participating in one admission attempt MUST use the same exact approved Identity Evidence Catalogue version for every mutual validation in that attempt.

**REQ-AUTH-IDENTITY-KEY-001** — Every successful Trainee Identity, Client Device Identity, and Session Authority Identity validation MUST output exactly one Canonical Identity Key containing the exact Identity Authority, identity class, and stable subject identifier.

**REQ-AUTH-IDENTITY-KEY-002** — The Identity Evidence Catalogue MUST define the complete normalization and equality rules that derive one Canonical Identity Key from every supported evidence type and schema version, and a missing, ambiguous, or non-canonical result MUST cause validation to fail.

**REQ-AUTH-IDENTITY-KEY-003** — Every identity binding, Authorization Assertion match, duplicate-Admission check, retained identity reference, and identity comparison MUST use Canonical Identity Key equality and MUST NOT compare display text, serialized evidence, network addresses, or implementation object identity.

**REQ-AUTH-VALIDATION-PACKAGE-001** — Before an admission attempt, every Trainee client and Session Authority host MUST have its applicable Identity Validation Package role manifest and the release's shared non-sensitive artifacts provisioned by an external process independent of the Training Simulation.

**REQ-AUTH-VALIDATION-PACKAGE-002** — An Identity Validation Package release MUST define exactly one closed `Trainee Client` manifest and one closed `Session Authority` manifest; both MUST identify the same exact release, Identity Evidence Catalogue, Admission Authorization Rule Set, AUTH Operation Inventory, AUTH Data Inventory, AUTH Audit Policy, and AUTH Audit Integrity Profile versions, while each manifest contains only the profiles, issuer records, validation dependencies, offline status inputs, and internal fields declared applicable to that host role.

**REQ-AUTH-VALIDATION-PACKAGE-003** — Before using an Identity Validation Package role manifest, the host MUST verify its canonical release and manifest identities, release and manifest versions, role, integrity, complete declared contents, shared artifact versions, and applicability against the exact launch-selected Package Trust Reference provisioned independently under `REQ-AUTH-VALIDATION-PACKAGE-TRUST-001`.

**REQ-AUTH-VALIDATION-PACKAGE-004** — The Training Simulation MUST NOT obtain or update an Identity Validation Package, catalogue, profile, issuer record, validation dependency, or offline status input from the Session Authority during client connection or from live Identity Authority communication during admission.

**REQ-AUTH-VALIDATION-PACKAGE-005** — A missing, invalid, incomplete, corrupted, role-inapplicable, or catalogue-mismatched Identity Validation Package MUST cause the affected host to reject the admission attempt before accepting identity evidence.

**REQ-AUTH-VALIDATION-PACKAGE-006** — A Trainee client host MUST NOT receive or retain the `Session Authority` role manifest, and a Session Authority host MUST NOT receive or retain the `Trainee Client` role manifest; shared artifacts MUST be explicitly classified as non-sensitive and applicable to both roles by the package and AUTH Data inventories.

**REQ-AUTH-VALIDATION-PACKAGE-CURRENT-001** — Each Trainee Client and Session Authority process MUST receive exactly one approved Identity Validation Package role manifest and Package Trust Reference as immutable launch inputs and MUST retain one validated immutable package view for its lifetime.

**REQ-AUTH-VALIDATION-PACKAGE-TRUST-001** — Each candidate activation pair MUST identify one exact project-owner-approved Package Trust Reference for its Identity Validation Package, provisioned to each host independently of the package contents, Session Authority, and live Identity Authority communication; missing, invalid, mismatched, or unapproved bootstrap evidence MUST reject the pair.

**REQ-AUTH-VALIDATION-PACKAGE-ADMISSION-001** — Before approval for process activation, a candidate package MUST be reconciled against every required component, supported host role, Identity Evidence Catalogue dependency, rule, policy, profile, issuer, offline input, AUTH requirement, retained historical dependency, and Package Trust Reference, with every applicable check receiving `Pass` and exact project-owner approval.

**REQ-AUTH-VALIDATION-PACKAGE-ADMISSION-002** — `Fail`, `Blocked`, `Not Evaluated`, an incomplete applicability decision, or missing project-owner approval for any candidate-package check MUST prevent approval and activation.

**REQ-AUTH-VALIDATION-PACKAGE-CURRENT-002** — A new admission attempt MUST proceed only when the Trainee client and Session Authority use approved immutable role manifests identifying the same exact release and shared artifact versions activated at their respective process starts.

**REQ-AUTH-VALIDATION-PACKAGE-MISMATCH-001** — An older, newer, unknown, unapproved, wrong-role, release-mismatched, or shared-artifact-mismatched manifest on either host MUST cause the admission attempt to be rejected before the client presents Trainee Identity or Client Device Identity authentication evidence.

**REQ-AUTH-VALIDATION-PACKAGE-COMPATIBILITY-001** — The initial baseline MUST NOT negotiate, migrate, translate, or provide backward or forward compatibility between Identity Validation Package releases or role-manifest versions; cross-role compatibility exists only for the exact pair admitted and approved within one release.

**REQ-AUTH-VALIDATION-PACKAGE-UPDATE-001** — Identity Validation Package or Package Trust Reference rotation MUST affect only later process starts and MUST NOT replace, patch, or revalidate the immutable package view of a running process.

**REQ-AUTH-VALIDATION-PACKAGE-UPDATE-002** — Rotation MUST atomically change the exact package and Package Trust Reference pair admitted for later process starts and MUST NOT expose a new process to a mixed pair.

**REQ-AUTH-VALIDATION-PACKAGE-UPDATE-003** — If complete validation and activation of a replacement package fail, the preceding approved launch pair MUST remain unchanged and the incomplete replacement MUST NOT be used by a new process.

**REQ-AUTH-VALIDATION-PACKAGE-HISTORY-001** — The implementation team MUST retain a stable version and activation-history record for every package designated current, including its Package Trust Reference, approval evidence, activation and supersession instants, predecessor, and candidate validation result, as project verification evidence governed by `PROCESS-EVIDENCE-RETENTION-001`; that project evidence is outside the runtime Training Simulation and AUTH Data Inventory and MUST NOT be used as a current AUTH decision input.

**REQ-AUTH-VALIDATION-DEPENDENCY-RETENTION-001** — Every non-secret package, catalogue, issuer, profile, rule, policy, integrity-reference validation input, and other dependency needed to interpret or validate a retained AUTH Audit Record or AUTH Audit Checkpoint MUST remain versioned and available until that record and checkpoint complete their approved expiry disposition.

**REQ-AUTH-VALIDATION-PACKAGE-IMPACT-001** — Candidate-package admission MUST prove that replacement preserves every dependency required by retained records and checkpoints or supplies an approved exact successor mapping without changing their historical interpretation or validation result.


**REQ-AUTH-REVALIDATION-001** — Identity-evidence validity, authorization, and Offline Revocation Status MUST be evaluated as conditions of initial admission and MUST NOT be re-evaluated as conditions for retaining that admission, entering `Ready`, starting active simulation, or continuing active simulation.

**REQ-AUTH-POST-ADMISSION-001** — Expiry of previously accepted evidence or receipt of a later `Revoked` status after successful initial admission MUST NOT by itself remove the admitted client, revoke `Ready`, release its Team Position, interrupt participation, or terminate the Training Session.

**REQ-AUTHORIZATION-SUBJECT-001** — Before admitting a client to Preparation, the Session Authority MUST establish that both the authenticated Trainee Identity and the authenticated Client Device Identity are individually authorized to use the Training Simulation.

**REQ-AUTHORIZATION-DENIAL-001** — If either required identity is not successfully authenticated or is not positively authorized, the Session Authority MUST reject admission and MUST NOT assign a Team Position or allow the client to enter Preparation.

**REQ-AUTHORIZATION-ASSERTION-001** — The Identity Authority MUST be the authoritative source of every Authorization Assertion used to decide whether a Trainee Identity may use the Training Simulation, a Client Device Identity may operate a Trainee client, or a Session Authority Identity may operate the authority role.

**REQ-AUTHORIZATION-ENFORCEMENT-001** — The Session Authority MUST apply the exact approved Admission Authorization Rule Set to the authenticated identities and their Authorization Assertions and MUST be the sole authority that records the resulting admission or denial decision.

**REQ-AUTHORIZATION-CLIENT-ENFORCEMENT-001** — The Trainee client MUST apply every client-validator row in the exact same Admission Authorization Rule Set to the authenticated Session Authority Identity and its Authorization Assertion before disclosing Trainee or Client Device evidence; this authorization result is a client-side precondition and does not itself create an Admission.

**REQ-AUTHORIZATION-RULE-001** — The initial Admission Authorization Rule Set MUST require an applicable positive Authorization Assertion for the authenticated Trainee Identity, Client Device Identity, and Session Authority Identity, using the exact identity-class permission mappings defined by `REQ-AUTHORIZATION-PERMISSION-002`.

**REQ-AUTHORIZATION-LOCAL-LIST-001** — The Training Simulation MUST NOT maintain a locally administered per-identity allowlist or denylist for Trainee Identities or Client Device Identities.

**REQ-AUTHORIZATION-TRAINEE-SCOPE-001** — In the initial baseline, a Trainee Identity Authorization Assertion MUST determine only whether that identity may use the Training Simulation and MUST NOT assign or restrict a Scenario, Team, Team Position, Loadout, or Call Sign.

**REQ-AUTHORIZATION-TRAINING-SELECTION-001** — After admission, Scenario access, Team Position selection, Loadout selection, and Call Sign selection MUST be governed only by their existing functional requirements and MUST NOT depend on identity-based roles or permissions.

**REQ-AUTHORIZATION-DEVICE-SCOPE-001** — In the initial baseline, a Client Device Identity Authorization Assertion MUST determine only whether that computer may operate a Trainee client for the Training Simulation.

**REQ-AUTHORIZATION-DEVICE-PAIRING-001** — Client Device Identity authorization MUST NOT restrict which authorized Trainee Identity may use that computer and MUST NOT assign or restrict a Scenario, Team, Team Position, Loadout, Call Sign, or access mode.

**REQ-AUTH-IDENTITY-RETENTION-001** — After successful admission, the Session Authority MUST retain the exact authenticated Trainee Identity and Client Device Identity binding as internal AUTH state for that admitted client until the admission ends.

**REQ-AUTH-IDENTITY-DISCLOSURE-001** — The Session Authority MUST NOT disclose a Trainee Identity or Client Device Identity to another Trainee client, use either as active-simulation presentation, or expose either through Team, roster, communication, or Scenario information.

**REQ-AUTH-CALL-SIGN-001** — The Call Sign MUST remain the only identity label for one Trainee disclosed to other Trainees during Preparation and active simulation and MUST NOT be replaced or supplemented by the authenticated Trainee Identity.

**REQ-AUTH-INTERNAL-USE-001** — Retained authenticated identities MAY be used only for AUTH decisions, AUTH evidence traceability, and AUTH audit records and MUST NOT change gameplay, training selection, or Scenario outcomes.

**REQ-AUTH-AUDIT-COVERAGE-001** — The producer assigned by the AUTH Operation Inventory MUST create exactly the classified AUTH Audit Record for every terminal `Audited` AUTH Operation, including every covered authentication, authorization, admission, lifecycle, and audit-recovery operation; a `Not Audited` row MUST create none.

**REQ-AUTH-AUDIT-DISPOSITION-001** — Before its AUTH Audit Commit Unit is attempted, each AUTH Audit Record MUST contain the settled terminal result of `Success`, `Failure`, or `Cancelled` assigned to its exact AUTH Operation and MUST identify the exact acceptance, rejection, or cancellation rule that produced it.

**REQ-AUTH-AUDIT-CONTENT-001** — Each AUTH Audit Record MUST contain a stable record identifier, its AUTH Attempt and AUTH Operation class keys and instance identifiers, Trusted Identity Time instant, producing host role and identity, final result, reason, and governing AUTH Audit Policy and Integrity Profile versions; the schema matrix MUST classify the applicability and exact source of validation purpose, Canonical Identity Key, package, catalogue, assurance profile, rule set, operation inventory, non-secret evidence, revocation-status, Admission, Training Session, Team Position, and Technical Removal references for each record class.

**REQ-AUTH-AUDIT-SCHEMA-001** — The AUTH Audit Policy MUST contain a closed schema matrix for every AUTH Audit Record class and assign every candidate field exactly one disposition of `Required Current Input`, `Required Retained Reference`, or `Not Applicable`, with the exact source and meaning for each required field.

**REQ-AUTH-AUDIT-SCHEMA-002** — A record MUST contain every field applicable to its class, MUST omit each `Not Applicable` field, and MUST NOT cause evidence, assurance, authorization, validity, or revocation to be re-evaluated merely to populate a retained reference for a lifecycle record.

**REQ-AUTH-AUDIT-SECRET-001** — An AUTH Audit Record MUST NOT contain an authenticator, Authenticator Control Proof, reusable Authentication Challenge value, or other material sufficient to authenticate, authorize, or reproduce an accepted proof.

**REQ-AUTH-AUDIT-SEPARATION-001** — AUTH Audit Records MUST remain separate from gameplay state, Scenario outcomes, and After-Action Review data and MUST NOT be disclosed to Trainee clients as training information.

**REQ-AUTH-AUDIT-POLICY-001** — One exact approved AUTH Audit Policy version MUST govern every AUTH Audit Record created by Trainee clients and the Session Authority.

**REQ-AUTH-AUDIT-POLICY-002** — The AUTH Audit Policy MUST enumerate every record class and host-role combination and assign an exact strictly positive finite retention period, retention-start event, expiry transition, expiry disposition, and access boundary to each row.

**REQ-AUTH-AUDIT-POLICY-003** — The AUTH Audit Policy MUST NOT use an indefinite, unstated, discretionary, or Scenario-dependent retention period or expiry disposition.

**REQ-AUTH-AUDIT-POLICY-004** — Every AUTH Audit Record MUST identify the exact AUTH Audit Policy version governing it and MUST be retained until the expiry instant calculated from its applicable policy row and Trusted Identity Time, then complete that row's exact authorized expiry transition without permitting expiry to appear as unauthorized mutation.

**REQ-AUTH-AUDIT-POLICY-EXPIRY-001** — Each policy row MUST define deterministic logical-expiry, physical-disposition, restart, catch-up, and failure behavior when Trusted Identity Time is unavailable or its NFR uncertainty criterion cannot be established; time uncertainty MUST NOT permit early physical disposition, indefinite silent retention, or use of host uptime as a substitute.

**REQ-AUTH-AUDIT-POLICY-005** — Before use, the implementation team MUST reconcile the AUTH Audit Policy against every AUTH Audit Record producer and class, and the project owner MUST approve its exact version.

**REQ-AUTH-AUDIT-POLICY-CHANGE-001** — Replacing the AUTH Audit Policy for later process starts MUST occur only through activation of a replacement Identity Validation Package pair under `REQ-AUTH-VALIDATION-PACKAGE-UPDATE-001` through `REQ-AUTH-VALIDATION-PACKAGE-UPDATE-003`; a running process retains its launch-bound policy.

**REQ-AUTH-AUDIT-POLICY-CHANGE-002** — A record MUST remain governed by the exact AUTH Audit Policy version identified when it was created; superseded policy versions MUST remain available until every governed record has reached its expiry disposition and MUST NOT govern a new record after replacement.

**REQ-AUTH-AUDIT-POLICY-CHANGE-003** — Replacing an AUTH Audit Policy or Integrity Profile MUST preserve every version and non-secret validation dependency needed to interpret retained records, validate their integrity references, and complete their authorized expiry transitions until no retained artifact depends on it.

**REQ-AUTH-AUDIT-ACCESS-001** — The Training Simulation MUST NOT provide a Trainee, gameplay role, or other in-product role with a capability to read, search, query, modify, delete, or export AUTH Audit Records.

**REQ-AUTH-AUDIT-ACCESS-002** — AUTH Audit Records MUST NOT be transmitted through Trainee client connections, gameplay communication channels, Scenario data, or After-Action Review data.

**SCOPE-AUTH-AUDIT-ACCESS-001** — Authorization, collection, consultation, export, archival, and analysis of AUTH Audit Records through the host operating environment are outside the Training Simulation product boundary.

**REQ-AUTH-AUDIT-INTEGRITY-001** — Each host MUST maintain retained AUTH Audit Records and their integrity references under one exact approved AUTH Audit Integrity Profile whose admitted grouping and continuity domains have stable identities and unambiguous beginning, rollover, discontinuity, and authorized-expiry boundaries.

**REQ-AUTH-AUDIT-INTEGRITY-002** — The AUTH Audit Integrity Profile MUST bind each retained record's exact contents, stable identity, ordering position, group and continuity context to sufficient non-secret integrity references to satisfy every detection outcome in `REQ-AUTH-AUDIT-INTEGRITY-003`, without prescribing storage format or cryptographic mechanism in this document.

**REQ-AUTH-AUDIT-INTEGRITY-003** — Validation against the applicable retained AUTH Audit Checkpoints MUST distinguish and detect unauthorized modification, insertion, removal, duplication, reordering, truncation, missing local scope, and undeclared discontinuity within each checkpointed extent while accepting only the exact authorized expiry and rollover transitions declared by the governing profiles.

**REQ-AUTH-AUDIT-INTEGRITY-004** — AUTH Audit integrity behavior MUST be tamper-evident and MUST NOT claim to prevent deletion or modification by an actor that controls the host operating environment or every retained checkpoint.

**REQ-AUTH-AUDIT-EPOCH-001** — Each host MUST have exactly one current append target and MAY retain zero or more superseded AUTH Audit Sequence epochs only as one closed ordered chain whose predecessor, successor, rollover or discontinuity reason, retained extent, expiry state, and applicable checkpoints are explicit and verifiable.

**REQ-AUTH-AUDIT-EPOCH-002** — Rollover, recovery, and authorized prefix expiry MUST preserve validation across every boundary while affected records or checkpoints remain retained; an unlinked epoch, multiple current append targets, or a missing retained boundary MUST fail integrity validation.

**REQ-AUTH-AUDIT-CHECKPOINT-001** — The AUTH Audit Integrity Profile MUST define the exact checkpoint granularity, scope, producing host identity binding, covered record identities and ordering boundary, creation instant, validation inputs, and objective acceptance criteria required to achieve the specified detection outcomes.

**REQ-AUTH-AUDIT-CHECKPOINT-002** — Each AUTH Audit Checkpoint MUST be a separately collectable host-environment artifact and MUST NOT contain an authenticator, reusable proof, or other authentication secret.

**REQ-AUTH-AUDIT-CHECKPOINT-003** — An externally retained AUTH Audit Checkpoint MUST permit detection of a missing or changed boundary record, truncated or completely missing local checkpointed extent, unauthorized expiry, or undeclared discontinuity for its exact scope.

**REQ-AUTH-AUDIT-CHECKPOINT-004** — Collection, external transfer, and retention of AUTH Audit Checkpoints MUST remain outside the Training Simulation product boundary and are governed by `ASSUMPTION-AUTH-AUDIT-CHECKPOINT-001`.

**REQ-AUTH-AUDIT-WRITE-GATE-001** — Before beginning any AUTH Operation classified `Audited`, the assigned producer MUST establish and reserve the ability to persist its complete AUTH Audit Commit Unit; inability to reserve it MUST prevent the operation from accepting input or producing an AUTH effect.

**REQ-AUTH-AUDIT-COMMIT-001** — An `Audited` AUTH Operation MUST NOT produce an access-, privilege-, or Admission-granting AUTH effect until its complete AUTH Audit Commit Unit, containing the settled final record and every integrity reference required by the current profile, has been persistently committed as one externally verifiable success outcome.

**REQ-AUTH-AUDIT-WRITE-FAILURE-001** — If an AUTH Audit Commit Unit cannot be committed completely, the governed AUTH Operation MUST produce no access-, privilege-, or Admission-granting AUTH effect; it MUST still reach its inventory-defined failure or cancellation result, invalidate its challenges and partial results, perform the applicable transient cleanup, and disclose the applicable generic denial only when a protected response channel remains; the host MUST classify every partial artifact as an incomplete commit rather than a final AUTH Audit Record or valid checkpoint and MUST reject new AUTH Operations until audit-write capability is restored and validated.

**REQ-AUTH-AUDIT-WRITE-FAILURE-002** — Loss of audit-write capability MUST NOT by itself remove an admitted client, revoke `Ready`, interrupt an active Trainee, or terminate a Training Session, but any new Admission requiring an AUTH Operation while that capability is unavailable MUST be rejected under `REQ-AUTH-AUDIT-WRITE-FAILURE-001`.

**REQ-AUTH-AUDIT-WRITE-RECOVERY-001** — Before accepting AUTH Operations again, the host MUST validate retained integrity continuity, disposition incomplete commit artifacts, and successfully commit the inventory-required recovery AUTH Audit Commit Unit bound to the last valid retained state or to an explicitly authenticated new continuity scope that identifies the preceding scope, unavoidable gap, and discontinuity without claiming that a missing artifact existed.

**REQ-AUTH-DENIAL-CATEGORY-001** — The closed AUTH Denial Category set disclosed to a requesting client MUST contain exactly `Session Authority Validation Failed`, `Admission Denied`, and `AUTH Temporarily Unavailable`; `No Denial Disclosure` is the only non-disclosure disposition and is not an AUTH Denial Category.

**REQ-AUTH-DENIAL-MAPPING-001** — Each terminal AUTH Attempt or refusal to begin MUST map to exactly one disclosure disposition using this ordered precedence: `Success` maps to `No Denial Disclosure`; client-requested cancellation before an independent failure or any terminal outcome for which no protected response channel remains maps to `No Denial Disclosure`; otherwise audit-write unavailability or audit-commit failure maps to `AUTH Temporarily Unavailable`; otherwise initial-admission failure, cancellation, or refusal before successful Session Authority Identity validation maps to `Session Authority Validation Failed`; otherwise initial-admission failure, cancellation, or refusal maps to `Admission Denied`; otherwise lifecycle or audit-recovery failure, cancellation, or refusal maps to `No Denial Disclosure`.

**REQ-AUTH-DENIAL-MAPPING-002** — The AUTH Operation Inventory MUST classify every terminal AUTH Attempt result and pre-processing refusal under exactly one row of `REQ-AUTH-DENIAL-MAPPING-001`; overlapping, absent, or multiple disclosure dispositions MUST prevent approval of that inventory.

**REQ-AUTH-DENIAL-DELIVERY-001** — An AUTH Denial Category MUST be disclosed only through the same AUTH Protected Exchange and attempt to which it applies; when no protected response channel remains, the host MUST retain the local audit disposition but MUST NOT queue, defer, or disclose a reason-bearing result through a later attempt or another channel.

**REQ-AUTH-DENIAL-DETAIL-001** — The requesting peer MUST NOT receive the exact failed identity, evidence item, permission, issuer, package, catalogue, profile, validity, revocation, challenge, proof, policy rule, or audit condition; when the final AUTH Audit Record commits, the exact reason MUST remain attributable only in that local record, and when its commit fails the exact reason MAY remain only in the incomplete-commit and recovery metadata required by the AUTH Audit Integrity Profile.

**REQ-AUTH-DENIAL-EQUIVALENCE-001** — All failures mapped to one AUTH Denial Category MUST expose the same category and MUST NOT expose a more specific result through another Training Simulation message or state transition; timing-equivalence limits remain a separate NFR input.

**REQ-AUTH-IDENTITY-AUTHORITY-002** — One exact Identity Authority identity and its complete admitted issuer set MUST be declared by the process-bound Identity Validation Package, and evidence from another authority or undeclared issuer MUST be rejected.

**REQ-AUTHORIZATION-PERMISSION-001** — The initial AUTH Permission set MUST contain exactly `Use Training Simulation`, `Operate Trainee Client`, and `Operate Session Authority`.

**REQ-AUTHORIZATION-PERMISSION-002** — A Trainee Identity Authorization Assertion MUST contain `Use Training Simulation`; a Client Device Identity assertion MUST contain `Operate Trainee Client`; and a Session Authority Identity assertion MUST contain `Operate Session Authority` before the corresponding authorization can succeed.

**REQ-AUTHORIZATION-PERMISSION-003** — A missing, unknown, malformed, identity-class-inapplicable, or differently named permission MUST NOT satisfy an AUTH Permission requirement, and additional permissions MUST NOT change Training Simulation behavior.

**REQ-AUTHORIZATION-RULE-SET-001** — The Admission Authorization Rule Set MUST be closed and versioned and MUST enumerate every admitted identity-class, AUTH Permission, Authorization Assertion, applicability, combination, positive decision, denial decision, and precedence rule.

**REQ-AUTHORIZATION-RULE-SET-APPLICABILITY-001** — Every Admission Authorization Rule Set row MUST identify exactly one validator role of `Trainee Client` or `Session Authority`: client rows MUST cover Session Authority Identity and `Operate Session Authority`, while authority rows MUST cover Trainee Identity with `Use Training Simulation` and Client Device Identity with `Operate Trainee Client`.

**REQ-AUTHORIZATION-RULE-SET-002** — The exact process-bound Admission Authorization Rule Set version MUST be included in the launch-activated Identity Validation Package, reconciled against every AUTH Permission and admission requirement, and approved by the project owner before use.

**REQ-AUTH-OPERATION-INVENTORY-001** — The AUTH Operation Inventory MUST enumerate every initial-admission, lifecycle, and audit-recovery AUTH Attempt and AUTH Operation class using stable class keys and MUST define exact nesting, validator, presenter, validation purpose, start event, terminal results, supersession event, cancellation propagation, permitted AUTH effect, exact cleanup disposition for every terminal result, and audit classification for each row; an `Audited` row MUST identify its required AUTH Audit Record class and producer, while a `Not Audited` row MUST NOT identify or produce an AUTH Audit Record.

**REQ-AUTH-OPERATION-INVENTORY-002** — At runtime, every AUTH Attempt and AUTH Operation MUST have exactly one unique instance identifier in addition to its stable inventory class key; each AUTH Operation, including audit recovery, MUST belong to exactly one current AUTH Attempt, and each challenge, proof, evidence input, decision, audit record, and AUTH effect MUST identify its exact operation and attempt class keys and instance identifiers.

**REQ-AUTH-OPERATION-INVENTORY-003** — The inventory MUST classify every Admission creation and end event, including Technical Removal, as either `Audited` with exact producer and record correlation or `Not Audited` with exact project-owner-approved rationale; an absent or unclassified lifecycle event MUST NOT execute.

**REQ-AUTH-OPERATION-INVENTORY-004** — Before use, the implementation team MUST reconcile the AUTH Operation Inventory against every AUTH producer, consumer, lifecycle transition, challenge, proof, cancellation, retry, concurrency, audit, and denial-category requirement, and the project owner MUST approve its exact version.

**REQ-AUTH-OPERATION-INSTANCE-001** — An AUTH Attempt or AUTH Operation instance identifier MUST NOT be reused while any challenge, proof, evidence input, decision, effect, audit artifact, incomplete-commit artifact, or retained reference bound to that identifier remains valid or retained.

**REQ-AUTH-ATTEMPT-LIFECYCLE-001** — An AUTH Attempt MUST begin at its inventory-defined start event and reach exactly one terminal result of `Success`, `Failure`, or `Cancelled`; after a terminal result it MUST accept no input, produce no new AUTH effect, and become eligible only for the exact audit and cleanup disposition assigned to that result.

**REQ-AUTH-ATTEMPT-SUPERSESSION-001** — Superseding an AUTH Attempt or AUTH Operation MUST atomically assign its inventory-defined terminal result, propagate cancellation to every still-nonterminal nested operation, invalidate their challenges and partial results, perform its inventory-defined audit and cleanup dispositions, and prevent any later access-, privilege-, or Admission-granting effect from that superseded scope.

**REQ-AUTH-EXCHANGE-001** — Every initial-admission AUTH Attempt MUST use one AUTH Protected Exchange bound to the exact AUTH Attempt class key and instance identifier, client endpoint, Session Authority endpoint, Session Authority Identity, Identity Validation Package release and role-manifest versions, and every nested AUTH Operation class key, instance identifier, and validation purpose carried by that exchange.

**REQ-AUTH-EXCHANGE-002** — The AUTH Protected Exchange MUST protect every AUTH message against unauthorized disclosure, modification, injection, replay, reordering, truncation, and use with another peer, identity, attempt, purpose, or package version.

**REQ-AUTH-EXCHANGE-003** — The client MUST NOT disclose Trainee Identity or Client Device Identity evidence, Authorization Assertions, Offline Revocation Status values, Authenticator Control Proofs, or Trainee Authentication Act results until Session Authority Identity authentication and authorization have succeeded within that exchange.

**REQ-AUTH-EXCHANGE-004** — After Session Authority validation succeeds, every Trainee Identity and Client Device Identity input and result MUST remain confidential and integrity-protected between that Trainee client and Session Authority and MUST NOT be transmitted to another client.

**REQ-AUTH-EXCHANGE-005** — Loss of exchange protection, peer-identity change, endpoint change, package-release or manifest change, connection loss, cancellation, or transcript-integrity failure before initial Admission commit MUST cancel the applicable AUTH Attempt, invalidate every outstanding Authentication Challenge, and prevent reuse of its partial results.

**REQ-AUTH-EXCHANGE-006** — The Training Simulation MUST NOT fall back to an unprotected exchange, weaker validation rule, different package version, cached decision, or reduced identity population after an AUTH Protected Exchange fails.

**REQ-ADMISSION-PRECONDITION-001** — Admission MUST require successful Session Authority authentication and authorization by the client; exact matching of the client and authority Runtime Content Release and role-pack pair; successful Trainee Identity and Client Device Identity authentication and authorization by the Session Authority; the exact launch-activated Identity Validation Package, catalogue, assurance profiles, rule set, evidence validity and revocation results; and persistent commitment of every required AUTH Audit Record and checkpoint.

**REQ-ADMISSION-ATOMIC-001** — After every admission precondition succeeds, the Session Authority MUST atomically create exactly one stable Admission identifier and bind it to its three Canonical Identity Keys, current client connection, AUTH Attempt class key and instance identifier, package release and role manifests, Identity Evidence Catalogue, rule-set, operation-inventory, data-inventory, audit-policy, audit-integrity-profile, and Trusted Identity Time references; no partial Admission MAY be observable.

**REQ-ADMISSION-IDENTIFIER-001** — An Admission identifier MUST be unique within its Session Authority Identity domain and MUST NOT be reused while any Admission, challenge, decision, AUTH Audit Record, checkpoint, incomplete-commit artifact, Session Evidence Set, or other retained reference bound to it remains valid or retained.

**REQ-ADMISSION-FAILURE-001** — A failed, cancelled, interrupted, or incomplete admission attempt MUST create no Admission, Team Position, roster entry, Ready state, or Loadout selection and MUST release every transient reservation created only for that attempt.

**REQ-ADMISSION-UNIQUENESS-001** — One Session Authority MUST have at most one current Admission for one Trainee Identity and at most one current Admission for one Client Device Identity.

**REQ-ADMISSION-DUPLICATE-001** — If a new attempt would duplicate either identity of a current Admission, the Session Authority MUST reject the new attempt, MUST preserve the existing Admission unchanged, and MUST NOT transfer, replace, or disconnect it.

**SCOPE-AUTH-CROSS-AUTHORITY-001** — Detecting or preventing simultaneous use of one Trainee Identity or Client Device Identity across different Session Authorities is outside the initial product boundary.

**REQ-ADMISSION-END-001** — An Admission MUST end exactly when its client explicitly leaves or its connection is confirmed lost before active simulation, when its Technical Removal commits during active simulation, or when its Session Authority process stops or restarts.

**REQ-ADMISSION-PERSISTENCE-001** — Normal Training Session completion or non-voluntary Training Session termination MUST NOT by itself end a connected client's Admission before the Session Authority completes its terminal result and required settling; the following orderly process stop MUST end every remaining Admission under `REQ-ADMISSION-END-001`.

**REQ-ADMISSION-END-EFFECT-001** — Ending an Admission MUST atomically clear its Ready state, release its Team Position and Loadout selection, invalidate outstanding challenges, remove its retained AUTH identity binding from live state, and preserve only the required AUTH Audit Records, Session Evidence Set references, and non-secret references.

**REQ-ADMISSION-PREPARATION-DISCONNECT-001** — Confirmed connection loss or explicit departure during Preparation or initial countdown MUST end that client's Admission immediately and MUST apply ordinary countdown cancellation when a countdown is active.

**REQ-ADMISSION-OPERATOR-CHANGE-001** — Changing the Trainee Identity bound to an Admitted Client MUST require the current Admission to end and a new initial admission with a new Trainee Authentication Act; changing the physical operator without that flow MUST NOT change the retained identity binding.

**REQ-ADMISSION-DEVICE-CHANGE-001** — Changing the Client Device Identity MUST require a new initial Admission; another device MUST NOT inherit or transfer the current Admission, Team Position, or live state.

**REQ-AUTH-LATE-JOIN-001** — After the client authenticates the Session Authority, an authority with active simulation running MUST reject a new initial admission before requesting or accepting Trainee Identity or Client Device Identity evidence and MUST disclose only `Admission Denied` when the same AUTH Protected Exchange retains a protected response channel; otherwise it MUST apply `No Denial Disclosure` under `REQ-AUTH-DENIAL-MAPPING-001` and `REQ-AUTH-DENIAL-DELIVERY-001`.

**REQ-AUTH-ATTEMPT-CANCEL-001** — Client cancellation or connection loss before initial Admission commit MUST cancel the complete applicable AUTH Attempt, invalidate its challenges and proofs, apply the outcome-specific cleanup rules in `REQ-AUTH-TRANSIENT-DATA-001` through `REQ-AUTH-TRANSIENT-DATA-003`, and require any retry to begin as a new attempt.

**REQ-AUTH-RETRY-001** — A retry after failure or cancellation MUST use a new AUTH Protected Exchange, new Authentication Challenges, a new Trainee Authentication Act, current evidence and revocation status, and a new audit reservation and MUST NOT reuse a preceding success or partial result.

**REQ-AUTH-ATTEMPT-CONCURRENCY-001** — Concurrent attempts involving the same Trainee Identity or Client Device Identity MUST be resolved against one canonical Admission commit order, and no more than the single Admission permitted by `REQ-ADMISSION-UNIQUENESS-001` MAY succeed.

**REQ-AUTH-IDENTITY-LOCKOUT-001** — Failed or repeated attempts MUST NOT cause the Training Simulation to suspend, revoke, disable, or lock a Trainee Identity, Client Device Identity, Session Authority Identity, authenticator, or Authorization Assertion; identity lifecycle changes remain solely with the Identity Authority.

**REQ-AUTH-DATA-MINIMIZATION-001** — An AUTH validator MUST request or process externally presented identity, evidence, assertion, status, profile, and proof fields only when required by the exact applicable Identity Evidence Catalogue row and MUST reject an unclassified external field that would influence an AUTH result.

**REQ-AUTH-DATA-INVENTORY-001** — The Identity Validation Package MUST contain a closed AUTH Data Inventory that assigns every externally provisioned package payload and every internally produced live, transient, audit, attempt, package, policy, Admission, Training Session, Team Position, proof-reference, and integrity-reference field an exact purpose, source or producer, permitted host-role recipient, consumer, persistence class, retention or cleanup event, and governing requirement.

**REQ-AUTH-DATA-INVENTORY-002** — The Training Simulation MUST NOT receive, create, retain, disclose, or use an AUTH package payload or internal field absent from the approved AUTH Data Inventory or on a host role not admitted by its row, and the inventory MUST NOT admit a field without a current requirement and finite purpose and lifetime.

**REQ-AUTH-DATA-INVENTORY-003** — Before use, the implementation team MUST reconcile the AUTH Data Inventory against every current identity, Admission, audit, lifecycle, cleanup, and disclosure requirement and every role manifest, and the project owner MUST approve its exact version.

**REQ-AUTH-TRANSIENT-DATA-001** — In the exact terminal transition of a successful initial-admission attempt, each host MUST clear every transient field after the required AUTH Audit Commit Units and live non-secret binding commit; after a successful lifecycle or audit-recovery attempt, it MUST clear them after the required audit commits and permitted effect commit, with an inventory row that uses no transient fields explicitly declaring that disposition; in any failed or cancelled attempt, it MUST clear them after the required failure or cancellation audit commit without requiring a live binding.

**REQ-AUTH-TRANSIENT-DATA-002** — If audit commit fails, each host MUST clear all evidence, proofs, challenges, exchange material, and other transient inputs at the inventory-defined failed-commit recovery boundary; only incomplete-commit metadata explicitly required by the AUTH Audit Integrity Profile MAY remain until recovery.

**REQ-AUTH-TRANSIENT-DATA-003** — After terminal cleanup, only the exact live, audit, or incomplete-commit fields enumerated by the AUTH Data Inventory for that outcome MAY remain; every undeclared transient field MUST be absent before another AUTH Attempt begins.

**SCOPE-AUTH-CREDENTIAL-RECOVERY-001** — Issuance, replacement, recovery, reset, or administrative unlocking of an identity or authenticator is owned by the Identity Authority and MUST NOT be performed by the Training Simulation.

**REQ-SESSION-ACCESS-002** — Initial admission MUST satisfy every applicable `REQ-AUTH-*`, `REQ-AUTHORITY-*`, `REQ-AUTHORIZATION-*`, and `REQ-ADMISSION-*` requirement but MUST NOT require a persistent user account managed by the Training Simulation.

**REQ-LATE-JOIN-001** — A new Trainee MUST NOT join after active simulation begins, including after Technical Removal.

## Disconnection and Technical Removal

**REQ-SESSION-DISCONNECT-001** — Protocol & Replication MUST report a Trainee connection as lost only after applying the exact connection-loss detection rule and bound in the current Runtime Timing Profile.

**REQ-SESSION-DISCONNECT-002** — A confirmed technical disconnection MUST NOT be represented as Fatal, injury, incapacity, casualty, voluntary tactical action, or task error.

**REQ-TECHNICAL-REMOVAL-001** — If a Trainee connection is lost while active simulation is running, the Session Authority MUST execute exactly one irreversible Technical Removal for that Trainee and MUST continue the Training Session with the remaining Trainees.

**REQ-TECHNICAL-REMOVAL-002** — Technical Removal MUST atomically end the Trainee's Admission; clear Ready; release the Team Position and Loadout; remove the Trainee from participation, collision, communication, action and presentation; and assign `Withdrawn` to every physical item associated with that Trainee before any later Canonical Tick or externally visible state.

**REQ-TECHNICAL-REMOVAL-003** — Technical Removal MUST record cause `Disconnected`, the removed Admission and Team Position, the exact last preceding canonical state version, and the resulting canonical state version in the deterministic reconstruction record and Session Evidence Set without disclosing authenticated identity to other Trainee clients.

**REQ-TECHNICAL-REMOVAL-004** — Technical Removal of one Trainee MUST NOT pause simulated time, create a client-recovery state, restore the removed Admission, or by itself terminate the Training Session.

**REQ-TECHNICAL-REMOVAL-005** — Every Scenario MUST define the result when a Team has no participating Trainee after Technical Removal; the Reference Personnel Recovery Scenario MUST assign defeat to that Team.

**REQ-TECHNICAL-REMOVAL-006** — After Technical Removal, the removed Trainee MUST NOT rejoin that Training Session; another client process or connection MUST require a new initial Admission and MAY join only before active simulation begins.

## Voluntary departure and process completion

**REQ-VOLUNTARY-LEAVE-001** — A Trainee MUST be able to leave an active Training Session explicitly.

**REQ-VOLUNTARY-LEAVE-002** — Explicit departure during active simulation MUST produce the same atomic Technical Removal and `Disconnected` cause as confirmed connection loss and MUST NOT by itself terminate the Training Session.

**REQ-VOLUNTARY-LEAVE-003** — Explicit departure MUST NOT be represented as Fatal, injury, incapacity, casualty, or task error; any resulting last-participant Scenario outcome MUST follow `REQ-TECHNICAL-REMOVAL-005`.

**REQ-AUTHORITY-SINGLE-SESSION-001** — One Session Authority process MUST be bound at launch to exactly one Scenario and MUST own exactly one Training Session over its complete process lifetime.

**REQ-AUTHORITY-TERMINAL-SETTLEMENT-001** — After normal completion or termination, the Session Authority MUST fix the terminal result, close every Admission, finalize the Session Evidence Set, complete its required durable handoff, settle required AUTH audit and bounded Observability work, and accept no second Training Session.

**REQ-AUTHORITY-TERMINAL-SHUTDOWN-001** — After the terminal settlement succeeds or reaches its applicable terminal failure, the Session Authority process MUST release its resources and terminate with the applicable process result.

**REQ-SESSION-EVIDENCE-001** — Simulation and Session Lifecycle MUST create one immutable deterministic reconstruction record with every canonical or lifecycle commit they own, and a committed result without its complete reconstruction record MUST NOT become externally visible.

**REQ-SESSION-EVIDENCE-002** — Reconstruction-record persistence and export MUST execute asynchronously outside Canonical Tick, Prediction, Presentation, transport-publication, and Observability barriers; inability to preserve the reserved record before commit MUST prevent visibility and terminate the Training Session as a canonical-path integrity failure rather than wait for storage.

**REQ-SESSION-EVIDENCE-003** — One immutable Session Evidence Set MUST bind the exact Training Session, Scenario, Runtime Content Release, build, configuration, ordered Canonical Tick and lifecycle record ranges, terminal result, provenance, and either complete coverage or every explicit loss and authority-loss boundary under one verifiable identity.

**REQ-SESSION-EVIDENCE-004** — A clean Session Authority exit MUST require a durable verifiable handoff receipt for the final Session Evidence Set manifest and terminal result; failure to obtain it within the admitted terminal-settling bound MUST produce a non-clean process result without restoring or extending the Training Session.

**REQ-SESSION-EVIDENCE-005** — Every Session Evidence Set candidate and export MUST use a stable identity, non-visible preparation, atomic commit, and idempotent retry; startup or administrative recovery MUST classify each retained artifact as committed, incomplete, or corrupt and MUST NOT infer success from an absent or ambiguous commit point.

**REQ-SESSION-EVIDENCE-006** — A Session Evidence Set and its exact runtime, content, profile, interpretation, and replay dependencies MUST remain immutable and retained indefinitely; this baseline authorizes no deletion, overwrite, or use as persisted live-session state.

**REQ-SESSION-EVIDENCE-TRUST-001** — Trust used to validate a Session Evidence Set destination and durable handoff receipt MUST be provisioned independently of that set, destination response, Runtime Content Release, Identity Validation Package, and Identity Authority and MUST grant no authority to sign or validate those other domains.

**REQ-SESSION-EVIDENCE-CONFIDENTIALITY-001** — Before process launch, the project owner MUST approve one exact closed recipient-and-field matrix for Session Evidence Set creation, handoff, retention, and retrieval; every operation MUST authenticate its destination or requester, disclose only the fields authorized for that recipient role, protect confidentiality and integrity, and reject an unauthorized recipient without disclosing record contents or existence. A Session Evidence Set MUST contain no credential, authentication evidence, Trainee Identity, or identity-bound performance field.

**REQ-CLIENT-SINGLE-SESSION-001** — One Trainee client process MUST be bound to exactly one Client Pack and one Training Session; participation in another Training Session or Scenario MUST require a new process.

**REQ-SESSION-FRESH-START-001** — Every new Training Session MUST execute in a new Session Authority process and begin from the initial state defined by its exact Scenario without canonical, Admission, Ready, Team Position, Loadout, or simulated state from a preceding Training Session.

**REQ-SESSION-TERMINATION-STATE-001** — No live canonical or client state from a completed or terminated Training Session MAY become input to another Training Session.

## Scenario and Map model

**REQ-SCENARIO-MAP-001** — Each Scenario MUST select exactly one Map.

**REQ-SCENARIO-MAP-002** — Multiple Scenarios MAY reuse one Map while defining different Team sizes, starting conditions, equipment, objectives, rules, durations, or results.

**REQ-SESSION-SCENARIO-001** — Each Training Session MUST execute exactly one Scenario.

**REQ-SCENARIO-END-001** — Each Scenario MUST define objective completion conditions, a maximum active-simulation duration, and the result of each completion condition.

**REQ-SCENARIO-DURATION-001** — Each Scenario MUST define its own maximum active-simulation duration.

**REQ-SESSION-TIMER-001** — Active simulation MUST end when the configured duration expires.

**REQ-SESSION-TIMER-002** — Initial countdowns MUST NOT consume active-simulation duration.

**REQ-SESSION-END-001** — A Training Session MUST end normally when its first objective completion condition occurs or its duration expires.

**REQ-SCENARIO-END-PRECEDENCE-001** — Each Scenario MUST define a deterministic resolution for every combination of objective completion conditions and duration expiry accepted in the same canonical state transition, using either a total priority order or an explicit combined result.

**REQ-SCENARIO-END-PRECEDENCE-002** — Before ending the Training Session, the Session Authority MUST apply the Scenario-defined resolution to all completion conditions and duration expiry accepted in that canonical transition and MUST record the resulting normal-completion result.

**REQ-SESSION-END-002** — Technical process termination MUST NOT be classified as normal Scenario completion; a last-participant Technical Removal uses the Scenario-defined result and classification required by `REQ-TECHNICAL-REMOVAL-005`.

## Scenario selection and hosting

**REQ-SERVER-SESSION-001** — A Session Authority process MUST contain exactly one Training Session over its lifetime, including Preparation, initial countdown, active simulation, completion processing, terminal settling, and shutdown.

**REQ-AUTHORITY-SCENARIO-BINDING-001** — The immutable launch configuration MUST identify exactly one Authority Pack whose signed Runtime Content Release selects exactly one Scenario before the Session Authority process begins content validation.

**REQ-SCENARIO-SELECTION-001** — The Session Authority MUST validate and activate its exact Scenario through the Authority Pack selected by launch configuration before publishing readiness or accepting Trainee connections.

**REQ-SCENARIO-SELECTION-002** — Connected Trainees MUST be able to identify the selected Scenario but MUST NOT change it.

**REQ-SCENARIO-CHANGE-001** — The selected Scenario and Runtime Content Release MUST remain unchanged through the complete Session Authority process lifetime.

**REQ-SCENARIO-RECONFIGURE-001** — Selecting another Scenario or Runtime Content Release MUST require a new Session Authority process with new immutable launch configuration and a new Training Session.

## Briefing, navigation, and identification

**REQ-BRIEFING-001** — Before entering `Ready`, every Trainee MUST be able to review the mission, Map, Team role, provided Recovery Proxy location information, extraction area, completion conditions, and maximum duration.

**REQ-RECOVERY-INTELLIGENCE-001** — The recovering Team's briefing MUST present a stable, versioned search area formed by the exact union of Map-owned region identities referenced by the Scenario; that geometry MUST contain the selected Recovery Proxy position and leave at least two distinct Scenario-valid initial positions consistent with all briefing information, and MUST NOT present or make the selected exact position deductively unique.

**REQ-RECOVERY-INTELLIGENCE-003** — Each Personnel Recovery Scenario MUST define versioned quantitative acceptance bounds for search-area extent and presentation granularity, and at least two qualified Representative Evaluators MUST independently confirm before use that a search area within those bounds provides tactically useful but non-exact intelligence; the project owner MUST approve the exact bounds and findings before that Scenario version may be selected for a Training Session.

**REQ-RECOVERY-INTELLIGENCE-002** — The opposing Team's briefing MUST reveal the exact initial position of the Recovery Proxy.

**REQ-BRIEFING-ACTIVE-001** — During active simulation, objective guidance MUST be limited to Diegetic Presentation, remembered briefing information, physical Map cues, represented equipment, and Trainee communication.

**REQ-NAVIGATION-EQUIPMENT-001** — A Scenario MUST be able to assign a diegetic static map and compass.

**REQ-NAVIGATION-MAP-001** — The diegetic map MUST NOT display live positions, trails, automatic markers, or objective tracking.

**REQ-NAVIGATION-PARITY-001** — Required navigation equipment MUST satisfy Mode Equivalence for Scenario information.

**REQ-TEAM-IDENTIFICATION-001** — Each Scenario MUST assign visually distinguishable and plausible uniforms or equipment to the Teams.

**REQ-TEAM-IDENTIFICATION-ERROR-001** — During active simulation, the Training Simulation MUST NOT provide automatic friend-or-foe identification, correct a Trainee's interpreted Team identity, or use hidden Team identity to reject an otherwise permitted action; controlled evidence-insufficiency cases and their acceptance criteria MUST be defined in an approved Representative Evaluation procedure.

## Diegetic Presentation

**CONSTRAINT-DIEGETIC-001** — Desktop Mode and Virtual-Reality Mode MUST use Diegetic Presentation during active simulation.

**CONSTRAINT-DIEGETIC-002** — Active simulation MUST NOT display a crosshair, state bars, ammunition counters, hit markers, objective markers, minimap, floating names, threat indicators, or gameplay messages.

**REQ-OPERATIONAL-UI-001** — Non-diegetic interface MAY be used during connection, preparation, Team selection, `Ready`, and initial countdowns.

**REQ-OPERATIONAL-UI-002** — Non-diegetic operational interface MUST NOT remain visible after active simulation starts or resumes.

## Access modes and input

**REQ-DESKTOP-INPUT-001** — A Desktop Mode Trainee MUST be able to perform every required Scenario action using only keyboard and mouse.

**REQ-DESKTOP-DISPLAY-001** — A Desktop Mode Trainee MUST receive every required visual output through a conventional monitor.

**REQ-PC-ONLY-SESSION-001** — A complete Training Session MUST be operable using only Desktop Mode Trainees and no virtual-reality equipment.

**REQ-VR-CAPABILITY-001** — Virtual-Reality Mode MUST be excluded from the acceptance scope and capability claims of the first Desktop Mode baseline and MUST be included as mandatory scope in an explicitly identified later Virtual-Reality Mode baseline.

**REQ-ACCESS-BASELINE-SCOPE-001** — Before verification begins, each candidate product baseline MUST have a Baseline Applicability Inventory with a stable baseline identifier and version that classifies every current requirement identifier exactly once as `Included`, `Future` with one named applicability milestone, or `Not Applicable` with a recorded justification.

**REQ-ACCESS-BASELINE-SCOPE-002** — A `Future` or `Not Applicable` requirement MUST receive no `Pass` claim in that baseline; a `Future` requirement MUST become `Included` and mandatory when its named applicability milestone is submitted for approval.

**REQ-ACCESS-BASELINE-SCOPE-003** — The implementation team MUST reconcile the Baseline Applicability Inventory against the complete current requirement-identifier registry, and the project owner MUST approve the exact inventory version and every `Not Applicable` justification before verification begins.

**REQ-ACCESS-BASELINE-SCOPE-004** — Adding, removing, or changing a requirement identifier, dependency, classification, or named milestone MUST create a new Baseline Applicability Inventory version and trigger assignment and evidence impact analysis.

**REQ-VR-BASELINE-SCOPE-001** — In the first Desktop Mode baseline, every requirement identifier reachable from the Virtual-Reality Mode or Mode Equivalence nodes in the current approved Evidence Dependency Inventory MUST be classified `Future` with the first Virtual-Reality Mode baseline as its named milestone.

**REQ-VR-BASELINE-SCOPE-002** — The first Virtual-Reality Mode baseline MUST classify every identifier in that complete dependency-derived set as `Included` and mandatory; no member of the set MAY remain omitted, `Future`, or `Not Applicable` at that milestone.

**REQ-VR-OPTIONAL-001** — No Trainee MUST be required to use Virtual-Reality Mode.

**REQ-VR-INPUT-001** — Virtual-Reality Mode MUST permit all required Scenario actions using head tracking and motion controllers.

**REQ-VR-INPUT-002** — Virtual-Reality Mode MUST NOT require keyboard or mouse during active simulation.

**REQ-MIXED-MODE-001** — When Virtual-Reality Mode is available, both access modes MUST coexist in one Training Session.

**REQ-MODE-PARITY-001** — Every required Scenario capability and authoritative outcome MUST satisfy Mode Equivalence.

**REQ-MODE-PARITY-002** — A Scenario MUST NOT require a tactical action available only in one access mode.

## Action execution

**REQ-ACTION-INTERRUPTION-001** — A Trainee MUST be able to interrupt a multi-step military action immediately by beginning another action permitted by the current physical state and available body or equipment resources.

**REQ-ACTION-STATE-PERSISTENCE-001** — Interrupting an action MUST preserve every completed and current physical, mechanical, equipment, and environment state change and MUST NOT roll affected state back automatically.

**REQ-ACTION-AUTONOMOUS-001** — A timer, combustion process, activated device, moving object, or other autonomous process started before interruption MUST continue according to its current state and approved profile.

**REQ-ACTION-RESTART-001** — Reissuing an interrupted action MUST derive a valid sequence from the current canonical state and MUST NOT resume a stored step whose physical prerequisites no longer hold.

**REQ-ACTION-RESOURCE-001** — Each Trainee action MUST define the represented body parts, hands, posture, equipment controls, and other exclusive physical resources required while that action executes.

**REQ-ACTION-PHYSICAL-CONDITIONS-001** — The Action Physical Condition Inventory MUST enumerate every canonical physical-state field and finite condition class that can change an action-pair compatibility disposition and trace each class to the canonical-state schema and applicable Approved Profiles.

**REQ-ACTION-PHYSICAL-CONDITIONS-002** — Before the Action Compatibility Matrix is approved, the implementation team MUST reconcile the Action Physical Condition Inventory against the complete current canonical-state schema, Action Inventory, resource declarations, and applicable profiles, and the project owner MUST approve its exact version.

**REQ-ACTION-PHYSICAL-CONDITIONS-003** — For each action pair, the applicable physical-condition classes MUST be mutually exclusive and collectively exhaustive across every reachable canonical physical state relevant to that pair, and the current state MUST map deterministically to exactly one complete class.

**REQ-ACTION-COMPATIBILITY-001** — The Action Compatibility Matrix MUST enumerate every unordered pair of actions in the approved Action Inventory and every class in the approved Action Physical Condition Inventory and assign exactly one `Compatible` or `Conflict` disposition.

**REQ-ACTION-COMPATIBILITY-002** — Every compatibility disposition MUST trace reproducibly to the actions' declared exclusive resources, physical conditions, and exact applicable body, equipment, action, and Locomotion Profile versions.

**REQ-ACTION-COMPATIBILITY-003** — A missing, stale, uncertain, or unclassified action pair or physical-condition class MUST block baseline approval and MUST NOT be treated as evidence that either concurrency or conflict behavior is correct.

**REQ-ACTION-COMPATIBILITY-APPROVAL-001** — Before use as normative behavior or verification evidence, the project owner MUST approve the exact Action Compatibility Matrix version after its coverage and derivations have been reconciled against the approved Action Inventory and Action Physical Condition Inventory.

**REQ-ACTION-COMPATIBILITY-004** — When more than two actions are requested or executing, the Training Simulation MUST evaluate the aggregate declared resources and physical conditions of the complete action set and MUST reject concurrency if any exclusive resource is multiply required or any applicable matrix disposition is `Conflict`.

**REQ-ACTION-COMPATIBILITY-005** — A change to the Action Inventory, declared resources, physical-condition classes, or an applicable profile MUST create a new Action Compatibility Matrix version and trigger impact analysis of its dispositions, verification procedures, and retained evidence.

**REQ-ACTION-CONCURRENCY-001** — A Trainee MUST be able to execute an action pair concurrently when the current approved Action Compatibility Matrix assigns `Compatible` for that pair and current physical-condition class and the aggregate resource rule in `REQ-ACTION-COMPATIBILITY-004` remains satisfied.

**REQ-ACTION-CONFLICT-001** — An action pair for which the current approved Action Compatibility Matrix assigns `Conflict`, or whose aggregate execution would multiply require an exclusive resource, MUST NOT execute concurrently.

**REQ-ACTION-CONCURRENCY-002** — The Training Simulation MUST NOT impose a global one-action-at-a-time restriction when the current approved Action Compatibility Matrix assigns `Compatible` to the requested pair's deterministically mapped physical-condition class and the aggregate resource rule remains satisfied.

**REQ-WEAPON-MANIPULATION-MOVEMENT-001** — A Trainee MUST be able to reload or execute a Weapon Malfunction corrective sequence while moving when current posture, movement rate, required hands, weapon profile, and Trainee state remain compatible with that action.

**REQ-WEAPON-MANIPULATION-MOVEMENT-002** — Concurrent weapon manipulation MAY reduce permitted movement or posture transitions according to the applicable action and Locomotion Profiles but MUST NOT prohibit all movement by default.

**REQ-WEAPON-MANIPULATION-MOVEMENT-003** — Beginning an incompatible movement or posture transition MUST interrupt the weapon action under the action-state persistence requirements.

## Session Authority and canonical state

**REQ-AUTHORITY-001** — Each non-completed and non-terminated Training Session MUST have exactly one Session Authority throughout Preparation, initial countdown, active simulation, and completion processing, and that same authority MUST determine canonical simulated state and outcomes.

**REQ-CLIENT-TRUST-001** — Trainee clients MUST submit inputs and intentions but MUST NOT determine authoritative positions, impacts, injury, Scenario progression, or results.

**REQ-STATE-CONSISTENCY-001** — Every Trainee MUST receive outcomes derived from the same canonical state.

## Communication

**REQ-VOICE-CHANNEL-001** — `Capable` and `Impaired` Trainees MUST be able to communicate through Proximity Voice and Team Radio when permitted by the Scenario.

**REQ-VOICE-DISTINCTION-001** — A receiver MUST be able to distinguish Proximity Voice from Team Radio.

**REQ-PROXIMITY-VOICE-001** — Proximity Voice MUST be audible to either Team when Acoustic Propagation makes the speaker perceptible.

**REQ-PROXIMITY-VOICE-002** — Proximity Voice MUST originate spatially from the speaking Trainee's Scenario position.

**REQ-PROXIMITY-VOICE-003** — Distance, barriers, openings, and environmental acoustics MUST affect Proximity Voice consistently with other acoustic sources.

**REQ-RADIO-EQUIPMENT-001** — Team Radio availability MUST depend on Scenario-assigned communication equipment.

**REQ-RADIO-CHANNEL-001** — Team Radio MUST deliver transmissions to every functioning radio configured for the transmitting radio's Team channel, regardless of the current carrier's Team.

**REQ-RADIO-CAPTURE-001** — An opposing Trainee who retrieves a functioning Team Radio MUST be able to receive transmissions from and transmit to the channel for which that radio is configured.

**REQ-RADIO-CAPTURE-IDENTITY-001** — A transmission made through a captured Team Radio MUST NOT provide recipients with a non-diegetic warning, label, or other indication that the current carrier belongs to the opposing Team.

**REQ-RADIO-EQUIPMENT-002** — A Trainee without functioning radio equipment configured for a channel MUST NOT receive or transmit Team Radio on that channel.

**REQ-RADIO-MULTIPLE-001** — A Trainee MUST be able to carry more than one Team Radio when free compatible Carry Positions exist.

**REQ-RADIO-MULTIPLE-002** — A `Capable` or `Impaired` Trainee MUST receive transmissions from every functioning carried radio on its configured channel.

**REQ-RADIO-MULTIPLE-003** — A Trainee carrying more than one functioning Team Radio MUST explicitly select which radio is used for transmission, and the transmission MUST be delivered only through that radio's configured channel.

**REQ-RADIO-PTT-001** — Team Radio voice MUST use half-duplex Push-to-Talk operation.

**REQ-RADIO-PTT-002** — A Trainee MUST continuously hold an explicit Push-to-Talk input to transmit through the selected functioning powered-on Team Radio.

**REQ-RADIO-PTT-003** — Releasing Push-to-Talk MUST stop transmission and return the selected radio to reception.

**REQ-RADIO-PTT-004** — A Team Radio MUST NOT receive its configured channel while that radio is transmitting.

**REQ-RADIO-PROXIMITY-001** — Speech transmitted through any Team Radio MUST simultaneously remain Proximity Voice originating from the speaking Trainee, whether the radio is carried or operated while dropped.

**REQ-RADIO-SIMULTANEOUS-001** — Simultaneous transmissions received through different carried radios MUST be reproduced concurrently and MAY overlap in a way that reduces intelligibility.

**REQ-RADIO-SIMULTANEOUS-002** — The Training Simulation MUST NOT queue, serialize, or automatically suppress one received channel solely because another carried radio is receiving at the same time.

**REQ-RADIO-COLLISION-001** — Transmissions that overlap in time on the same Team Radio channel MUST be reproduced concurrently to receivers and MAY become partially or completely unintelligible.

**REQ-RADIO-COLLISION-002** — The initial baseline MUST NOT queue same-channel transmissions, assign automatic priority, or select an automatic winning transmission.

**REQ-RADIO-CONTROL-001** — A Trainee MUST be able to switch each carried Team Radio on or off independently.

**REQ-RADIO-CONTROL-002** — A powered-off Team Radio MUST NOT receive or transmit Team Radio.

**REQ-RADIO-CONTROL-003** — A Trainee MUST be able to adjust the received-audio volume of each carried Team Radio independently.

**REQ-RADIO-CONTROL-004** — The initial baseline MUST NOT allow a Trainee to change a Team Radio's configured channel during active simulation.

**REQ-RADIO-ENERGY-001** — A functioning Team Radio MUST have sufficient simulated energy for the entire Training Session and MUST NOT become unavailable solely because of elapsed powered-on time, received traffic, or transmitted traffic.

**REQ-RADIO-AUDIO-OUTPUT-001** — Each Team Radio configuration MUST identify its represented received-audio output, including any earpiece, headset, or loudspeaker.

**REQ-RADIO-AUDIO-OUTPUT-002** — Received audio routed to a represented worn earpiece or headset MUST be audible only to its wearer.

**REQ-RADIO-AUDIO-OUTPUT-003** — Received audio routed to a represented loudspeaker MUST originate spatially from that loudspeaker and undergo Acoustic Propagation before reaching nearby Trainees.

**REQ-RADIO-AUDIO-OUTPUT-004** — A Trainee MUST be able to switch explicitly between represented earpiece and loudspeaker outputs during active simulation when the Team Radio model supports both.

**REQ-RADIO-AUDIO-OUTPUT-005** — A Team Radio model that does not support output switching MUST retain its configured fixed output.

**REQ-RADIO-DROPPED-001** — A functioning powered-on Team Radio dropped in the Scenario MUST remain configured for its channel and continue receiving transmissions.

**REQ-RADIO-DROPPED-002** — A dropped Team Radio MUST emit received audio into the Scenario only when its active represented output is a loudspeaker; output through that loudspeaker MUST satisfy `REQ-RADIO-AUDIO-OUTPUT-003`.

**REQ-RADIO-DROPPED-003** — A `Capable` or `Impaired` Trainee MUST be able to transmit through a functioning powered-on Team Radio without picking it up when the radio is within represented physical reach, the interaction path is unobstructed, and the Trainee explicitly operates that radio.

**REQ-RADIO-DROPPED-004** — Speech transmitted through a dropped Team Radio MUST simultaneously remain Proximity Voice originating from the speaking Trainee.

**REQ-RADIO-DROPPED-CONTROL-001** — A `Capable` or `Impaired` Trainee MUST be able to operate a dropped Team Radio's represented power, received-volume, and audio-output controls without picking it up when the control is within represented physical reach, the interaction path is unobstructed, and the Trainee issues the corresponding explicit command.

**REQ-RADIO-DROPPED-CONTROL-002** — Operating a dropped Team Radio MUST NOT expose a channel-changing control prohibited by `REQ-RADIO-CONTROL-004`.

**REQ-RADIO-DAMAGE-001** — Projectiles, Blast Overpressure, and other applicable physical effects MUST be able to damage a Team Radio.

**REQ-RADIO-DAMAGE-002** — Team Radio damage outcomes MUST depend on the exact admitted Approved Profile version applicable to the represented equipment, exposure type and magnitude, impact location, and intervening protection rather than on a visible generic durability value; outcome evidence MUST remain bound to that profile version.

**REQ-RADIO-DAMAGE-003** — Loss of radio function MUST be communicated through the radio's behavior, visible state, and sound without a non-diegetic durability meter or failure message.

**REQ-RADIO-DAMAGE-004** — A damaged Team Radio MUST lose all receive, transmit, audio, and control functionality immediately; partial functional failures MUST NOT be represented.

**REQ-RADIO-DAMAGE-005** — A damaged Team Radio MUST remain inoperable for the rest of the Training Session and MUST NOT be repairable during active simulation.

**REQ-RADIO-COVERAGE-001** — An isolated Team Radio transmission MUST satisfy the approved Radio Coverage Profile's intelligibility criterion and tolerance for every transmitter and receiver position in its declared reference-Map spatial domain when both radios are functioning, powered on, correctly configured, and operated under the profile's transmission and listening conditions.

**REQ-RADIO-COVERAGE-002** — The Radio Coverage Profile MUST define the exact reference Map and version, complete valid transmitter and receiver position domain, radio and audio-output configuration, received-volume setting, speech corpus and level, environmental and background-noise conditions, absence of simultaneous or same-channel overlapping traffic, intelligibility metric, tolerance, and limits of applicability.

**REQ-RADIO-COVERAGE-003** — Coverage verification MUST combine reproducible analysis over the complete declared spatial domain with a versioned finite test-point inventory reconciled to Map geometry, materials, connected regions, boundary conditions, and worst-case propagation paths.

**REQ-RADIO-COVERAGE-004** — Before coverage results are observed, at least two qualified Representative Evaluators MUST independently confirm that the proposed intelligibility criterion, tolerance, speech corpus, listening conditions, and spatial test coverage are adequate for the represented training use, and the project owner MUST approve the exact Radio Coverage Profile and procedure versions.

**REQ-RADIO-COVERAGE-005** — Simultaneous transmissions and same-channel collisions MUST be excluded from `REQ-RADIO-COVERAGE-001` acceptance and MUST remain governed by `REQ-RADIO-SIMULTANEOUS-001`, `REQ-RADIO-SIMULTANEOUS-002`, `REQ-RADIO-COLLISION-001`, and `REQ-RADIO-COLLISION-002`.

**REQ-HAND-SIGNAL-001** — A `Capable` or applicable `Impaired` Trainee MUST be able to perform an approved Hand Signal through an explicit action during active simulation.

**REQ-HAND-SIGNAL-PRESENTATION-001** — A Hand Signal MUST be represented by the signaling Trainee's physical body animation and MUST be perceivable only through direct visual observation of that representation.

**REQ-HAND-SIGNAL-VISIBILITY-001** — Geometry, distance, lighting, viewpoint, and Obscurants MUST affect whether another Trainee can see and interpret a Hand Signal.

**REQ-HAND-SIGNAL-INTERPRETATION-001** — The Training Simulation MUST NOT display a label, icon, subtitle, notification, or automatic interpretation of a Hand Signal.

**REQ-HAND-SIGNAL-PARITY-001** — Desktop Mode and Virtual-Reality Mode MUST provide the same approved Hand Signal meanings and authoritative represented outcomes.

**REQ-HAND-SIGNAL-STOP-001** — The initial Hand Signal set MUST include an approved signal meaning `Stop`.

**REQ-HAND-SIGNAL-MOVE-001** — The initial Hand Signal set MUST include an approved signal meaning `Advance or move`.

**REQ-HAND-SIGNAL-FOLLOW-001** — The initial Hand Signal set MUST include an approved signal meaning `Follow or rally`.

**REQ-HAND-SIGNAL-DIRECTION-001** — The initial Hand Signal set MUST include an approved signal meaning `Direction or contact indication` and MUST represent the Trainee-selected direction physically.

**REQ-HAND-SIGNAL-HOLD-001** — The initial Hand Signal set MUST include an approved signal meaning `Take cover or hold position`.

**REQ-HAND-SIGNAL-ACKNOWLEDGE-001** — The initial Hand Signal set MUST include an approved signal meaning `Acknowledge or ready`.

**REQ-HAND-SIGNAL-APPROVAL-001** — The physical gesture assigned to every supported meaning MUST be an enumerated item in an exact admitted Approved Profile version and MUST receive item-level `Pass` validation from a Qualified Specialist whose approved technical scope covers the represented military Hand Signal before use as validated behavior.

**REQ-HAND-SIGNAL-INPUT-VR-001** — In Virtual-Reality Mode, the Trainee MUST perform the selected Hand Signal through tracked-controller motion that drives the represented gesture.

**REQ-HAND-SIGNAL-INPUT-DESKTOP-001** — In Desktop Mode, the Trainee MUST explicitly select a Hand Signal meaning, after which the represented body MUST perform the corresponding approved gesture.

**REQ-HAND-SIGNAL-INPUT-DIRECTION-001** — A Hand Signal whose meaning includes direction MUST require the Trainee to provide that direction, and the represented gesture MUST indicate it physically in both access modes.

**REQ-HAND-SIGNAL-OBSERVER-001** — Selection, recognition, or input state used to produce a Hand Signal MUST NOT be exposed to observers; observers MUST receive only the represented body motion and its ordinary visual consequences.

**REQ-HAND-SIGNAL-PHYSICAL-001** — The exact admitted Approved Profile version for each Hand Signal MUST define the required arms, hands, range of motion, and execution duration as item-level validated behavior.

**REQ-HAND-SIGNAL-AVAILABILITY-001** — A Hand Signal MUST remain unavailable when required arms or hands are occupied or when applicable injury prevents its required motion.

**REQ-HAND-SIGNAL-INTERRUPTION-001** — A Trainee MUST be able to interrupt a Hand Signal immediately by beginning another permitted action.

**REQ-HAND-SIGNAL-INTERRUPTION-002** — An interrupted Hand Signal MUST leave only the motion actually performed visible and MUST NOT emit an automatic meaning, completion event, notification, or acknowledgement.

**REQ-HAND-SIGNAL-TEAM-001** — Team membership MUST NOT alter whether or how a represented Hand Signal is made available to visual presentation; Trainees with the same authoritative relative viewpoint and the same environmental and visual conditions MUST receive the same represented gesture state regardless of Team membership.

**REFERENCE-HAND-SIGNAL-OPTIONAL-001** — Performing or correctly interpreting a Hand Signal MUST NOT directly satisfy an objective, alter a result, or trigger a Scenario-state transition in the reference Scenario.

**REQ-POST-INCAPACITY-VOICE-001** — An `Incapacitated` or `Fatal` Trainee MUST NOT transmit voice to any Trainee through Proximity Voice or Team Radio, regardless of either Trainee's Team, functional state, radio possession, or radio channel.

## Locomotion, load, fatigue, and Stress Load

**REQ-LOCOMOTION-001** — Every `Capable` Trainee MUST be able to walk, run, crouch, lie prone, lean from cover, traverse low obstacles, and use stairs whenever the current complete input tuple is inside the applicable action's admitted Locomotion Profile domain; that profile MUST contain at least one non-empty applicable condition class for every listed action.

**REQ-LOCOMOTION-MODE-PARITY-001** — Every required locomotion action MUST exist in both access modes.

**REQ-LOCOMOTION-PROFILE-001** — Movement capabilities and limits MUST be defined by the exact admitted Locomotion Profile version applicable to the represented Trainee and environment.

**REQ-LOCOMOTION-PROFILE-COVERAGE-001** — The Locomotion Profile MUST enumerate every required locomotion action, the complete input domain, applicable environmental and support geometry, output capabilities and limits, reference conditions, tolerances, and limits of applicability.

**REQ-LOCOMOTION-FACTORS-001** — The Locomotion Profile's complete input tuple MUST include posture, Carried Load, Fatigue, Recovery Carrier status, Trainee Functional State, and every additional profile-declared factor that can change a movement capability or limit.

**REQ-LOCOMOTION-EQUALITY-001** — Two cases with the same exact Locomotion Profile version and equal values for every member of its complete input tuple MUST produce the same profile output values.

**REQ-FATIGUE-STATE-001** — Every Trainee MUST have an authoritative Fatigue state distinct from Stress Load and from the human Trainee's actual physical condition.

**REQ-FATIGUE-PROFILE-001** — Fatigue MUST be governed by the exact admitted Fatigue Profile version applicable to the represented Trainee, activity, load, environment, and Trainee Functional State.

**REQ-FATIGUE-PROFILE-COVERAGE-001** — The Fatigue Profile MUST define a closed input domain, state bounds and reference state, accumulation and recovery behavior, applicable history windows, tolerances, and limits of applicability, and MUST enumerate every permitted downstream effect as `Enabled` or `Disabled` for the candidate baseline.

**REQ-FATIGUE-EFFECT-INVENTORY-001** — Every enabled Fatigue effect MUST define its affected requirement or Action Inventory entries, exact input domain, outcome rule, bounds, tolerances, and feedback; no unenumerated effect is permitted.

**REQ-FATIGUE-EVOLUTION-001** — Fatigue accumulation and recovery MUST be calculated from the Fatigue Profile using Session Authority simulated elapsed time.

**REQ-FATIGUE-LOAD-001** — Fatigue evolution MUST account for the Trainee's Carried Load wherever the admitted Fatigue Profile declares that load applicable.

**REQ-FATIGUE-EFFECT-001** — Every enabled Fatigue effect MUST be applied exactly when and as its admitted rule requires; a disabled or unenumerated Fatigue effect MUST NOT change any outcome.

**REQ-STRESS-LOAD-001** — Every Trainee MUST have a simulated Stress Load distinct from physical fatigue and actual human psychological stress.

**REQ-STRESS-PROFILE-001** — Stress Load MUST be governed by the exact admitted Stress Profile version applicable to the represented Trainee, Scenario conditions, and Trainee Functional State.

**REQ-STRESS-INVENTORY-001** — The Stress Profile MUST contain a closed inventory of stressor classes that includes intense nearby combat, incoming fire, explosions, and injury, and MUST define the observable input variables, boundaries, accumulation behavior, tolerances, and applicability of every class.

**REQ-STRESS-EFFECT-INVENTORY-001** — The Stress Profile MUST enumerate every permitted Stress Load effect and classify it as `Enabled` or `Disabled` for the candidate baseline; every enabled effect MUST define its affected Action Inventory entries, input domain, exact outcome rule, bounds, tolerances, and feedback, and no unenumerated effect is permitted.

**REQ-STRESS-TIME-001** — Stress Load accumulation and recovery MUST use Session Authority simulated elapsed time.

**REQ-STRESS-STIMULUS-001** — Stress Load MUST respond to every applicable stressor according to the exact admitted Stress Profile and MUST NOT respond to an input absent from its closed stressor inventory.

**REQ-STRESS-RECOVERY-001** — While no applicable stressor occurs, Stress Load MUST recover toward the Stress Profile's reference state at the profile-defined rate and MUST remain within its profile-defined bounds.

**REQ-STRESS-RECOVERY-002** — Recovery MUST account for current Stress Load, stressor intensity within the profile-defined history window, simulated elapsed time without an applicable stressor, Trainee Functional State, and every other input declared by the exact admitted Stress Profile.

**REQ-STRESS-RECOVERY-003** — Entering cover MUST NOT reset Stress Load immediately.

**REQ-STRESS-DETERMINISM-001** — Stress Load MUST NOT randomly fail a non-aim task when the Trainee satisfies its required interaction conditions.

**REQ-STRESS-INTERACTION-001** — Stress Load MUST alter timing tolerance, required precision, or execution duration for a non-aim motor task exactly when and as an applicable Stress Profile effect is `Enabled`, and MUST NOT make such an alteration when the effect is `Disabled` or unenumerated.

**REQ-STRESS-FEEDBACK-001** — Every enabled Stress Load effect on an interaction MUST provide the exact profile-defined perceptible feedback and MUST satisfy its approved distinction criterion and tolerance against an otherwise equivalent unaffected interaction and against an unexplained failure.

**REQ-STATE-PRESENTATION-001** — Active simulation MUST NOT present numeric fatigue or Stress Load values.

**REQ-STATE-FEEDBACK-001** — Each non-reference Fatigue or Stress Load class that changes a Trainee capability or action MUST produce at least one corresponding cue through breathing, sound, movement, animation, or action duration, as enumerated with its perception criterion and tolerance in the applicable admitted profile.

**REQ-AIM-CONTROL-001** — Fatigue and Stress Load MUST NOT introduce artificial aim offset, random aim error, or involuntary authoritative weapon sway.

## Items and carrying

**REQ-CARRYING-SOURCE-INVENTORY-001** — Before a Carrying Catalogue can be admitted, a versioned source inventory MUST enumerate every Scenario, Loadout, equipment profile, carryable item type, and Carry Position type admitted to the candidate baseline, MUST be reconciled to their complete authoritative content and profile registries, and MUST receive project-owner approval for that exact reconciled version.

**REQ-CARRYING-CATALOGUE-001** — The candidate baseline MUST use one exact Carrying Catalogue version reconciled to the complete approved source inventory and admitted through project-owner approval before any affected content is used or verified.

**REQ-CARRYING-CATALOGUE-002** — The Carrying Catalogue MUST define each item type's interfaces and exact Carried Load contribution; each Carry Position type's interfaces and capacity; one deterministic `Compatible` or `Conflict` result for every item-type and Carry-Position-type pair; and ordering keys that produce stable total orders over displaced item identities and all Carry Position instances available to one Trainee.

**REQ-CARRYING-CATALOGUE-003** — A missing, stale, uncertain, or unclassified item type, Carry Position type, pair result, capacity, load contribution, or automatic-stow order MUST block admission or verification of the affected content and MUST NOT default to compatibility or incompatibility.

**REQ-CARRYING-CATALOGUE-004** — A change to any Carrying Catalogue item or input dependency MUST create a new catalogue version and trigger evidence-impact analysis.

**REQ-CARRYING-CATALOGUE-HISTORY-001** — Every candidate, admitted, superseded, and rejected Carrying Catalogue version, its source-inventory version, reconciliation result, decision, and approval record MUST remain retained and traceable.

**REQ-ITEM-IDENTITY-001** — Every physical item instance MUST have one stable identity for its lifetime in a Training Session and MUST have exactly one Item Disposition admitted for its type and current state.

**REQ-ITEM-TRANSFER-001** — Pickup, drop, stowage, removal, insertion, attachment, detachment, and every other item transfer MUST move each affected existing item identity atomically from exactly one preceding Item Disposition to exactly one succeeding Item Disposition and MUST NOT copy or multiply any item identity or contents.

**REQ-ITEM-CONSUMPTION-001** — A completed permitted consumption action MAY transition only the exact item identities declared as consumed by that action to `Consumed`; every other item identity and its contents MUST remain conserved unless another represented operation in the same canonical transition explicitly transfers or consumes them.

**REQ-ITEM-TRANSFORMATION-001** — A completed permitted physical transformation MAY replace declared input item identities only with the exact output identities and component trace defined by an admitted Approved Profile; every output identity MUST be new and unique, every replaced input MUST terminate exactly once, and no undeclared identity or contents may be created, copied, multiplied, or removed.

**REQ-ITEM-CONTAINMENT-001** — The graph of admitted Item Disposition containment relations MUST be acyclic: an item MUST NOT directly or transitively contain itself, and every contained item MUST have exactly one immediate parent item or equipment position identified by its applicable Carrying Catalogue or Weapon Behavior Catalogue row.

**REQ-ITEM-PICKUP-001** — During active simulation, a Trainee MUST be able to pick up physically accessible compatible weapons, ammunition, and equipment.

**REQ-ITEM-PICKUP-002** — Picking up an item MUST require an explicit Trainee command while the item is within represented physical reach and an unobstructed path exists between the required hand or hands and the item.

**REQ-ITEM-PICKUP-003** — A Trainee MUST NOT pick up an item remotely or through intervening collision geometry.

**REQ-ITEM-TEAM-ORIGIN-001** — Team origin or previous possession MUST NOT, by itself, prevent a Trainee from picking up or using a physically and functionally compatible weapon, ammunition item, or equipment item.

**REQ-CASUALTY-EQUIPMENT-001** — Weapons, magazines, and equipment carried by an `Incapacitated` or `Fatal` Trainee MUST remain physically represented and accessible from their Carry Positions.

**REQ-CASUALTY-EQUIPMENT-002** — Another Trainee MUST be able to remove an accessible item using the same explicit-command, physical-reach, obstruction, compatibility, and capacity rules as other item pickup.

**REQ-CASUALTY-EQUIPMENT-003** — Removing an item MUST transfer that existing item from the body's Carry Position and MUST NOT duplicate it or its contents.

**REQ-CASUALTY-WORN-EQUIPMENT-001** — Uniforms, helmets, body armour, and worn equipment that provides Carry Positions MUST remain attached to an `Incapacitated` or `Fatal` Trainee and MUST NOT be available for pickup in the initial baseline.

**REQ-CASUALTY-WORN-EQUIPMENT-002** — Items stored in the attached pouches, holster, sling, or other Carry Positions MUST remain removable under the casualty-equipment rules.

**REQ-ITEM-DROP-001** — A Trainee MUST be able to drop carried items unless the Scenario requires the item to remain fixed.

**REQ-LOADOUT-INITIAL-001** — A Loadout defines initial equipment but MUST NOT permanently restrict compatible items carried later.

**REQ-CARRY-CAPACITY-001** — Equipment MUST occupy available Carry Positions defined by the Trainee's represented hands, worn equipment, or carried containers.

**REQ-CARRY-LOAD-001** — The Session Authority MUST calculate Carried Load from the exact contributions in the current Carrying Catalogue and MUST count every directly or transitively carried item exactly once, including its contents, without counting the same item through more than one containment path.

**REQ-CARRY-HANDS-001** — A Trainee MUST be able to retain an item in the represented hands when the item can be held with the currently available hands; an item held in the hands MUST NOT also occupy a stowed Carry Position.

**REQ-CARRY-SLING-001** — A sling Carry Position MUST hold no more than one compatible primary weapon.

**REQ-CARRY-HOLSTER-001** — A holster Carry Position MUST hold no more than one compatible secondary weapon.

**REQ-CARRY-MAGAZINE-POUCH-001** — A magazine-pouch Carry Position MUST accept only compatible magazine types and MUST enforce its defined capacity.

**REQ-CARRY-EQUIPMENT-POUCH-001** — An equipment-pouch Carry Position MUST accept only explicitly compatible equipment and MUST enforce its defined capacity.

**REQ-CARRY-CONTAINER-001** — A represented container MUST expose and enforce only Carry Positions, capacities, and item compatibilities admitted by the current Carrying Catalogue.

**REQ-CARRY-COMPATIBILITY-001** — Each carryable item and Carry Position MUST expose the exact type and interface identity required to select its current Carrying Catalogue pair result, and compatibility MUST equal that result without relying on initial Loadout membership.

**REQ-CARRY-OVERFLOW-001** — When an item cannot occupy a free compatible Carry Position, the Trainee MUST keep it in compatible available hands, free a compatible Carry Position by moving or dropping another item, or leave the item in the Scenario.

**REQ-ITEM-PICKUP-HANDS-001** — Before changing state for a pickup that requires hands holding other items, the Session Authority MUST enumerate complete allocations that stow every displaced held item in a distinct free compatible Carry Position and MUST select the lexicographically first complete allocation under the Carrying Catalogue's stable total displaced-item and Carry-Position orders.

**REQ-ITEM-PICKUP-HANDS-002** — When no complete allocation exists, the pickup MUST remain unavailable until the Trainee explicitly moves or drops a held item; the Training Simulation MUST NOT stow or drop any item, change any item location, or otherwise partially apply the failed pickup.

**REQ-ITEM-PICKUP-HANDS-003** — When a complete allocation exists and every pickup precondition remains true, all required automatic stows and the pickup MUST commit in one canonical transition; if any precondition or destination changes before commit, the complete allocation MUST be recalculated or the command rejected without state change.

## Weapons, aiming, and recoil

**REQ-WEAPON-BEHAVIOR-SOURCE-INVENTORY-001** — A versioned source inventory MUST enumerate every weapon, ammunition, magazine, and Weapon Accessory type admitted to the candidate baseline and every requirement in the weapon, aiming, recoil, ammunition, reload, and Weapon Malfunction sections; it MUST be reconciled to the complete authoritative content, profile, Action Inventory, and requirement registries and approved by the project owner for that exact version.

**REQ-WEAPON-BEHAVIOR-CATALOGUE-001** — Before affected content is used or verified, the project owner MUST approve and admit one exact Weapon Behavior Catalogue version reconciled to the approved source inventory.

**REQ-WEAPON-BEHAVIOR-CATALOGUE-002** — For every admitted equipment type and required behavior, the Weapon Behavior Catalogue MUST contain one item-level `Applicable` row with complete condition and output domains, exact admitted Approved Profile versions, tolerances, and evidence, or one justified `Not Applicable` row; every required capability MUST have at least one non-empty applicable condition class for every equipment type to which it is declared applicable.

**REQ-WEAPON-BEHAVIOR-CATALOGUE-003** — A missing, stale, uncertain, unclassified, unsupported, or non-admitted catalogue row or profile version MUST block admission and verification of the affected equipment or behavior and MUST NOT default to either applicability or non-applicability.

**REQ-WEAPON-BEHAVIOR-CATALOGUE-004** — A change to the Weapon Behavior Catalogue, its source inventory, any row, or any input dependency MUST create a new version, retain the preceding version and decision history, and trigger evidence-impact analysis.

**REQ-WEAPON-CONTROL-001** — A weapon MUST expose exactly the safety and fire-selector states defined by the exact admitted Approved Profile version referenced by its applicable Weapon Behavior Catalogue row.

**REQ-WEAPON-SAFE-001** — A weapon in `Safe` MUST NOT discharge.

**REQ-WEAPON-FIRE-MODE-001** — `Semi`, `Burst`, and `Automatic` behavior MUST match the complete state and transition rules in the exact admitted Approved Profile version when the applicable Weapon Behavior Catalogue row classifies those modes as present.

**REQ-WEAPON-INSPECTION-001** — A Trainee MUST be able to perform every inspection action classified `Applicable` for the held weapon, its chamber, and its inserted magazine by the Weapon Behavior Catalogue through an explicit command under that row's complete condition domain.

**REQ-WEAPON-INSPECTION-002** — Each inspection action MUST use the represented motion, required hands, duration, and observable-state mapping defined by its exact admitted Approved Profile version.

**REQ-WEAPON-INSPECTION-003** — For every supported inspection, its exact admitted Approved Profile MUST enumerate the complete relevant physical-state × inspection-action × viewpoint × lighting domain, the state cues physically exposed by the represented action, and perception and distinction criteria and tolerances; the inspection MUST expose only those cues and MUST NOT reveal unenumerated ammunition or mechanical state.

**REQ-WEAPON-INSPECTION-PRESENTATION-001** — Active simulation MUST NOT display an ammunition count, chamber-state label, inspection result message, or other non-diegetic interpretation of weapon state.

**REQ-WEAPON-ACTION-001** — A Trainee MUST be able to operate explicitly every bolt, slide, charging handle, or other firearm mechanism classified `Applicable` by the Weapon Behavior Catalogue under its complete declared condition domain.

**REQ-WEAPON-ACTION-002** — Operating the action MUST feed, chamber, extract, or eject ammunition exactly as required by the current mechanical and ammunition state in the applicable exact admitted Approved Profile and MUST NOT produce an unenumerated transition.

**REQ-WEAPON-EJECTION-001** — A live cartridge or spent case expelled from a weapon MUST become a physical object at the represented ejection location with its identity and condition preserved.

**REQ-WEAPON-EJECTION-002** — An expelled object MUST follow an authoritative physical trajectory and remain in the Scenario for the remainder of the Training Session unless subsequently moved or consumed by a permitted action.

**REQ-WEAPON-DISCHARGE-TRANSFORMATION-001** — Every discharge and ammunition reaction MUST apply an exact admitted transformation row that identifies each input cartridge or component identity, every succeeding represented product identity and condition including any spent case, Ballistic Projectile, or fragment, every terminally `Consumed` input, and every non-item physical output; the item transition MUST satisfy `REQ-ITEM-TRANSFORMATION-001`.

**REQ-WEAPON-SINGLE-CARTRIDGE-LOAD-001** — A Trainee MUST be able to load a compatible individual cartridge manually exactly when the applicable Weapon Behavior Catalogue row classifies that operation as `Applicable` to the weapon's current mechanical state.

**REQ-WEAPON-SINGLE-CARTRIDGE-LOAD-002** — Manual single-cartridge loading MUST require a physically accessible compatible cartridge, the hands and weapon access defined by the exact admitted Approved Profile version, and an explicit action.

**REQ-WEAPON-SINGLE-CARTRIDGE-LOAD-003** — A successfully loaded cartridge MUST be the existing physical cartridge used by the action and MUST NOT create, copy, or transfer a cartridge into a magazine.

**CONSTRAINT-AIMING-001** — Active simulation MUST NOT provide a crosshair, hidden centre-screen aiming aid, or non-diegetic impact indicator.

**REQ-AIMING-001** — A Trainee MUST aim through physical sighting devices represented on the selected weapon.

**REQ-AIMING-BALLISTICS-001** — Authoritative projectile trajectory MUST originate from the exact emission transform and bore relationship defined by the applicable admitted weapon and ammunition Approved Profile versions, within their stated tolerance and independently of camera or screen-centre projection.

**REQ-AIMING-DEVICE-001** — Every Loadout containing a firearm MUST define at least one physically represented sighting configuration classified `Applicable` to that firearm by the Weapon Behavior Catalogue.

**REQ-SIGHT-SETUP-001** — Each Loadout MUST define initial zero and elevation for assigned sighting devices using the units, valid domains, reference conditions, and tolerances in their exact admitted Approved Profile versions.

**REQ-SIGHT-MAGNIFICATION-001** — A Trainee MUST be able to change magnification through an explicit action exactly across the states and ranges classified `Applicable` by the sight's Weapon Behavior Catalogue row and exact admitted Approved Profile, and MUST NOT change it when that capability is `Not Applicable`.

**REQ-WEAPON-RECOIL-001** — Every weapon discharge MUST apply physical weapon movement according to the applicable Physical Profile.

**REQ-WEAPON-RECOIL-002** — Recoil MUST change authoritative weapon orientation by the applicable Physical Profile result and MUST retain the resulting orientation subject only to subsequent represented physical forces and explicit Trainee control.

**REQ-WEAPON-RECOIL-003** — Completion of a discharge MUST NOT directly set authoritative weapon orientation back to its pre-discharge value or to an aiming target; any later return MUST result from represented profile-defined physical forces and explicit Trainee control.

**REQ-WEAPON-RECOIL-004** — Recoil MUST NOT be represented solely as camera shake or a non-authoritative visual offset.

**REQ-WEAPON-FIRE-MOVEMENT-001** — A Trainee MUST be able to discharge a weapon while walking, running, crouching, prone, or leaning exactly when the applicable Weapon Behavior Catalogue row's complete posture, held-weapon, clearance, contact, and Trainee-state predicate permits discharge.

**REQ-WEAPON-FIRE-MOVEMENT-002** — Movement and posture MUST affect represented weapon position, orientation, velocity, contact, and recoil response exactly according to the applicable admitted profile outputs and tolerances and MUST NOT add an artificial random projectile-dispersion penalty.

**REQ-WEAPON-BRACING-001** — A Trainee MUST be able to place a held weapon in physical contact with walls, window structures, environment objects, and the ground when their exact contact geometry and material class are classified compatible by the applicable Weapon Behavior Catalogue row.

**REQ-WEAPON-BRACING-002** — Surface contact MUST constrain weapon movement and alter recoil response according to the deterministic or bounded output and tolerance defined for the complete weapon, contact geometry, surface material, applied-force, posture, and Trainee-state domain in the exact admitted Approved Profiles.

**REQ-WEAPON-BRACING-003** — Weapon bracing MUST NOT apply an abstract accuracy, spread, or recoil modifier independent of represented physical contact.

**REQ-WEAPON-COLLISION-001** — The exact admitted collision geometry of a held weapon MUST collide, within its profile tolerance, with every applicable owner-body, other-Trainee, Map, door, window, and environment-object collision class enumerated by the Weapon Behavior Catalogue and MUST NOT pass through a class defined as solid.

**REQ-WEAPON-COLLISION-002** — Every contact in the complete admitted collision domain, including owner-body and confined-space contacts, MUST produce the deterministic or bounded constraint, displacement, and rotation output defined for its contact geometry and applied forces, while no-contact controls MUST produce no collision response.

**REQ-WEAPON-OBSTRUCTION-001** — A represented obstruction affecting the muzzle or weapon mechanism MUST alter discharge or operation exactly when and as the applicable Weapon Behavior Catalogue row and exact admitted weapon, ammunition, and obstruction Approved Profile versions require under the current complete physical-condition tuple, and MUST NOT otherwise alter it.

**REQ-WEAPON-CONDITION-CAUSES-001** — The Weapon Behavior Catalogue MUST define collectively exhaustive preliminary predicates for `Prohibited external damage`, `Approved use or accumulated operation`, `Internal heat`, `Ammunition interaction`, `Environmental contamination`, and `Mechanical obstruction`; those predicates MAY overlap, but a declared deterministic precedence rule MUST assign every complete input tuple to exactly one final class.

**CONSTRAINT-WEAPON-EXTERNAL-DAMAGE-001** — In the initial baseline, an input classified `Prohibited external damage` by `REQ-WEAPON-CONDITION-CAUSES-001` MUST NOT damage or alter the structural, mechanical, optical, or functional condition of a firearm or Weapon Accessory, whether mounted, carried, or dropped.

**CONSTRAINT-WEAPON-EXTERNAL-DAMAGE-002** — This exclusion MUST NOT suppress a condition transition required by an applicable exact admitted Approved Profile for `Approved use or accumulated operation`, `Internal heat`, `Ammunition interaction`, `Environmental contamination`, or `Mechanical obstruction`, and MUST NOT override damage requirements for magazines, cartridges, or handheld portable lights that are not Weapon Accessories.

**CONSTRAINT-WEAPON-ACCESSORY-DETACHMENT-001** — Collision, projectile impact, Blast Overpressure, Fire, heat, and other external effects MUST NOT detach a mounted Weapon Accessory in the initial baseline.

**REQ-WEAPON-ACCESSORY-REMOVAL-001** — A mounted Weapon Accessory MUST remain attached until a Trainee completes an explicit removal action permitted by the weapon, accessory, required tools, hands, and current physical state.

**REQ-WEAPON-ACCESSORY-FIELD-001** — Each Weapon Accessory row MUST classify field mounting and removal as `Applicable` or `Not Applicable`; every applicable row MUST reference exact admitted Approved Profile versions defining compatible weapon interfaces, required tools, hands, duration, and the complete physical-condition domain.

**REQ-WEAPON-ACCESSORY-FIELD-002** — During active simulation, a Trainee MUST be able to mount or remove a compatible bayonet, suppressor, light, or other Weapon Accessory exactly when its applicable Weapon Behavior Catalogue row permits field configuration under the current conditions.

**REQ-WEAPON-ACCESSORY-FIXED-001** — A Weapon Accessory that requires unavailable tools, calibration, or sight zeroing MUST remain fixed in the state assigned by the Loadout for the entire Training Session.

**REQ-WEAPON-ACCESSORY-CARRY-001** — A removed Weapon Accessory MUST occupy the required hands until it is mounted, stowed in a free compatible Carry Position, or dropped.

**REQ-WEAPON-ACCESSORY-EFFECT-001** — Completing the mounting or removal of a Weapon Accessory MUST update the shared authoritative weapon state immediately.

**REQ-WEAPON-ACCESSORY-EFFECT-002** — The resulting weapon state MUST apply every change to mass, centre of mass, geometry, collision, recoil response, Ballistic Projectile behavior, Acoustic Propagation, Blast Overpressure, emitted light, equipment compatibility, and Melee behavior required by the exact admitted accessory and weapon Approved Profile versions.

**REQ-WEAPON-ACCESSORY-EFFECT-003** — Mounting or removing an accessory MUST NOT alter a physical or functional property absent from its applicable exact admitted Approved Profile change set.

**REQ-SUPPRESSOR-EFFECT-001** — A mounted suppressor MUST modify the weapon discharge's Acoustic Propagation and Blast Overpressure according to the exact admitted suppressor, weapon, and ammunition Approved Profile versions under the current physical conditions.

**REQ-SUPPRESSOR-EFFECT-002** — Across the closed condition, source, propagation-path, and receiver domain in the applicable profiles, a mounted suppressor MUST retain Acoustic Propagation and Blast Overpressure outputs that satisfy the exact admitted non-elimination criteria and tolerances, and its audible signature MUST satisfy the approved representative-perception criterion; it MUST NOT be represented as silent.

**REQ-SUPPRESSOR-EFFECT-003** — A suppressor MUST alter Ballistic Projectile behavior, recoil response, or weapon heat exactly when and as the applicable exact admitted combined Approved Profiles require, and MUST NOT otherwise alter those outcomes.

## Ammunition and reload

**REQ-AMMUNITION-STATE-SCHEMA-001** — The Weapon Behavior Catalogue MUST reference an exact admitted closed ammunition-state schema that enumerates cartridge identity, type, condition and Item Disposition; magazine identity, body condition, feed and retention capabilities, capacity, and ordered contained cartridge identities; and chamber contents and mechanical condition for every admitted type.

**REQ-AMMUNITION-STATE-SCHEMA-002** — A missing, stale, uncertain, unclassified, or non-admitted ammunition-state field or transition MUST block the affected equipment and MUST NOT receive an implementation-defined default.

**REQ-AMMUNITION-001** — The Session Authority MUST track every field in the applicable exact admitted ammunition-state schema separately for each cartridge, magazine, and weapon chamber.

**REQ-MAGAZINE-STATE-001** — Each magazine MUST retain its cartridge count while inserted, removed, carried, or dropped.

**REQ-CHAMBER-STATE-001** — A weapon chamber MUST retain state independently from the inserted magazine.

**REQ-MAGAZINE-REMOVE-001** — A Trainee MUST be able to remove the inserted magazine through an explicit action that does not initiate automatic reload or select a replacement magazine.

**REQ-MAGAZINE-REMOVE-002** — Removing a magazine MUST preserve the chamber state and the identity, condition, and cartridge contents of the removed magazine.

**REQ-MAGAZINE-REMOVE-003** — A removed magazine MUST occupy the required hand or hands until the Trainee explicitly stows it in a free compatible Carry Position or drops it.

**REQ-MAGAZINE-INSERT-001** — A Trainee holding a compatible magazine MUST be able to insert that magazine through an explicit action without initiating automatic reload.

**REQ-MAGAZINE-INSERT-002** — Manual insertion MUST insert only the magazine currently held by the Trainee and MUST NOT select or move another magazine automatically.

**REQ-MAGAZINE-INSERT-003** — Manual magazine insertion MUST preserve the weapon's current chamber state.

**REQ-RELOAD-001** — A Trainee MUST initiate reload through one explicit input command.

**REQ-RELOAD-002** — At command acceptance, the Training Simulation MUST evaluate the complete exact precondition defined by the applicable Weapon Behavior Catalogue row and, only when it passes, bind the reload to the current canonical weapon, chamber, magazine, cartridge, hand, and Carry Position state and execute its derived sequence automatically.

**REQ-RELOAD-PROFILE-001** — Automatic reload MUST execute the ordered magazine, action, chamber, hand, and Carry Position operations required by the exact admitted Approved Profile version referenced by the applicable Weapon Behavior Catalogue row and the bound physical state.

**REQ-RELOAD-RESULT-001** — Completion of automatic reload MUST leave the weapon, chamber, inserted magazine, removed magazine, cartridges, hands, and Carry Positions in the same physical state produced by the represented sequence.

**REQ-RELOAD-INTERRUPTION-001** — A Trainee MUST be able to interrupt automatic reload immediately by beginning another action permitted by the current physical state.

**REQ-RELOAD-INTERRUPTION-002** — Interruption MUST preserve every completed and current physical change to the weapon, chamber, magazines, cartridges, hands, and Carry Positions and MUST NOT roll the reload back to its starting state.

**REQ-RELOAD-INTERRUPTION-003** — Interruption MUST NOT create, delete, insert, stow, or return an item except through a represented operation completed before interruption.

**REQ-RELOAD-RESTART-001** — A reload command issued after interruption MUST derive and execute a valid sequence from the weapon, chamber, magazine, cartridge, hand, and Carry Position state that exists when the new command is accepted.

**REQ-RELOAD-RESTART-002** — The Training Simulation MUST NOT resume a stored animation step or assume that a previously planned reload operation has occurred when the current physical state does not contain its result.

**REQ-RELOAD-SELECTION-001** — At reload-command acceptance, the candidate population MUST be every accessible compatible magazine occupying one of the Trainee's Carry Positions, excluding the magazine then inserted in the weapon; automatic reload MUST select the candidate with the greatest cartridge count and break ties by the Carrying Catalogue's stable total item order.

**REQ-RELOAD-MAGAZINE-001** — Reload MUST remove the inserted magazine while preserving its cartridge count.

**REQ-RELOAD-MAGAZINE-002** — During an uninterrupted reload, the represented drop operation for an empty removed magazine MUST transition that magazine to the Scenario; interruption before that operation completes MUST leave it in the Item Disposition reached at interruption.

**REQ-RELOAD-MAGAZINE-003** — During an uninterrupted reload, the represented stow operation for a non-empty removed magazine MUST select the first free compatible Carry Position in the Carrying Catalogue's stable total order or, when none exists, the represented drop operation MUST transition it to the Scenario; interruption before either operation completes MUST leave it in the Item Disposition reached at interruption.

**REQ-RELOAD-CONSERVATION-001** — Reload MUST NOT create, merge, refill, or discard cartridges except through represented consumption or expulsion.

**REQ-AMMUNITION-DAMAGE-001** — Exact admitted ammunition and magazine Approved Profiles MUST define a closed exposure-type × magnitude × component-state × geometry × protection domain with mutually exclusive and collectively exhaustive outcomes, tolerances, and deterministic rules or explicitly approved stochastic distributions; every carried or dropped cartridge and magazine exposure MUST resolve to exactly one required outcome.

**REQ-AMMUNITION-DAMAGE-002** — Damage to a magazine MUST map exposure separately to the magazine body and every contained cartridge using their exact geometry, protection, exposure, and admitted profile versions and MUST apply each component's resolved outcome rather than one automatic shared outcome.

**REQ-AMMUNITION-DAMAGE-003** — Every admitted damaged-state class MUST define remaining discharge, feed, and retention capabilities; a cartridge or magazine MUST behave exactly according to its resolved class and MUST NOT use a capability absent from that class.

**REQ-AMMUNITION-REACTION-001** — A physical ammunition reaction MUST produce exactly the pressure, Ballistic Projectile, fragment, heat, transformation products, and other outcomes defined for the resolved condition by the exact admitted ammunition Approved Profile and MUST NOT produce an unenumerated effect or detonate solely because an impact occurred.

**REQ-STRESS-RELOAD-001** — Stress Load MUST change reload duration and animation exactly when and as the applicable Stress Profile effect is `Enabled`, and MUST NOT change them when that effect is `Disabled` or unenumerated.

**REQ-STRESS-RELOAD-002** — Stress Load MUST NOT cause an otherwise valid automatic reload to fail.

## Weapon Malfunctions

**REQ-WEAPON-MALFUNCTION-001** — Weapon Malfunction occurrence MUST be resolved by the exact admitted weapon-and-ammunition Approved Profile versions referenced by the applicable Weapon Behavior Catalogue row.

**REQ-WEAPON-MALFUNCTION-002** — The malfunction profile domain MUST include weapon condition, exact ammunition state, accumulated use, heat, and every applicable environmental-condition class and MUST define an exact deterministic occurrence rule or an explicitly approved stochastic distribution and tolerance for every complete input tuple.

**REQ-WEAPON-MALFUNCTION-003** — Every stochastic malfunction distribution used as validated behavior MUST be an item in an exact admitted Approved Profile version with supporting evidence, reference conditions, tolerance, Qualified Specialist validation, and project-owner approval.

**REQ-WEAPON-MALFUNCTION-INVENTORY-001** — The Weapon Behavior Catalogue MUST enumerate every supported Weapon Malfunction for every admitted weapon × ammunition combination, classify it `Applicable` or `Not Applicable` with exact conditions and evidence, and define its occurrence rule, blocked weapon-operation set, cue set, and corrective-sequence profile.

**REQ-WEAPON-MALFUNCTION-INVENTORY-002** — A missing, uncertain, unsupported, or non-admitted malfunction applicability, occurrence, blocked-operation, cue, or corrective-sequence row MUST block the affected weapon × ammunition combination and MUST NOT default to no malfunction.

**REQ-WEAPON-MALFUNCTION-TYPE-001** — The initial baseline MUST support failure to fire for every weapon × ammunition combination whose exact Weapon Behavior Catalogue row classifies that malfunction as `Applicable`.

**REQ-WEAPON-MALFUNCTION-TYPE-002** — The initial baseline MUST support failure to feed for every weapon × ammunition combination whose exact Weapon Behavior Catalogue row classifies that malfunction as `Applicable`.

**REQ-WEAPON-MALFUNCTION-TYPE-003** — The initial baseline MUST support failure to extract or eject for every weapon × ammunition combination whose exact Weapon Behavior Catalogue row classifies that malfunction as `Applicable`.

**REQ-WEAPON-MALFUNCTION-STRESS-001** — Stress Load MUST NOT directly cause a mechanical Weapon Malfunction.

**REQ-WEAPON-MALFUNCTION-PRESENTATION-001** — During active simulation, every supported Weapon Malfunction MUST expose the complete cue set defined by its exact admitted Approved Profile through only the represented weapon's behavior, animation, visible state, and sound, and MUST satisfy the profile's perception and distinction criteria and tolerances against applicable ordinary and other malfunction states.

**REQ-WEAPON-MALFUNCTION-PRESENTATION-002** — The Training Simulation MUST NOT identify the existence or type of a Weapon Malfunction through a message, icon, label, or other non-diegetic indication.

**REQ-MALFUNCTION-CLEAR-001** — A Trainee MUST use an explicit command distinct from reload to begin clearing a Weapon Malfunction.

**REQ-MALFUNCTION-CLEAR-002** — The Training Simulation MUST execute the corrective sequence defined by the exact admitted Approved Profile version referenced by the current malfunction row for the current complete physical and mechanical state.

**REQ-MALFUNCTION-CLEAR-003** — Every operation in the malfunction row's exact blocked-operation set MUST remain unavailable until the corrective sequence reaches its profile-defined successful terminal state; operations outside that set remain governed by their ordinary conditions.

**REQ-MALFUNCTION-CLEAR-PROFILE-001** — For every supported Weapon Malfunction and complete admitted starting-state class, the exact admitted Approved Profile MUST define a complete ordered corrective sequence, represented operations, intermediate Item Dispositions and mechanical states, observable cues, duration, interruption boundaries, and successful terminal state.

**REQ-MALFUNCTION-CLEAR-PROFILE-002** — Every corrective-sequence item MUST receive `Pass` validation from a Qualified Specialist whose approved scope covers the represented weapon and MUST receive project-owner approval as part of the exact profile version before admission.

**REQ-MALFUNCTION-CLEAR-INTERRUPTION-001** — A Trainee MUST be able to interrupt an automatic Weapon Malfunction corrective sequence immediately by beginning another action permitted by the current physical state.

**REQ-MALFUNCTION-CLEAR-INTERRUPTION-002** — Interruption MUST preserve every completed and current physical change and MUST NOT roll the weapon, ammunition, hands, or carried items back to their state before correction began.

**REQ-MALFUNCTION-CLEAR-RESTART-001** — A subsequent malfunction-correction command MUST derive a valid corrective sequence from the current physical and mechanical state and MUST NOT resume a stored animation step whose prerequisites no longer hold.

**REQ-STRESS-MALFUNCTION-CLEAR-001** — Stress Load MUST change correction duration and animation exactly when and as the applicable Stress Profile effect is `Enabled`, MUST NOT change them when that effect is `Disabled` or unenumerated, and MUST NOT randomly make a valid correction fail.

## Ballistics and physical effects

**REQ-PHYSICAL-EFFECTS-SOURCE-INVENTORY-001** — A versioned source inventory MUST enumerate every admitted physical-effect source, projectile, atmosphere, material, propagation medium and path, impact geometry, target, protection class, transformation, and required physical behavior; it MUST be reconciled to complete authoritative content, profile, and requirement registries and approved by the project owner for that exact version.

**REQ-PHYSICAL-EFFECTS-CATALOGUE-001** — Before affected behavior is used or verified, the project owner MUST approve and admit one exact Physical Effects Catalogue version reconciled to the approved source inventory.

**REQ-PHYSICAL-EFFECTS-CATALOGUE-002** — Every source-inventory cross-product row MUST be classified `Applicable` with its complete input domain, exact admitted Physical Profile versions, deterministic rule or approved stochastic distribution, outputs, transformations, durations, and tolerances, or justified `Not Applicable` with evidence.

**REQ-PHYSICAL-EFFECTS-CATALOGUE-003** — A missing, stale, uncertain, unclassified, unsupported, or non-admitted catalogue row or profile version MUST block admission and verification of the affected physical behavior and MUST NOT receive a default outcome.

**REQ-PHYSICAL-EFFECTS-CATALOGUE-004** — A change to the catalogue, source inventory, row, profile, or dependency MUST create a new version, retain preceding decisions and evidence, and trigger evidence-impact analysis.

**REQ-BALLISTICS-001** — Firearms MUST produce Ballistic Projectiles with simulated trajectories and non-zero time of flight.

**REQ-BALLISTICS-002** — Ballistic Projectile motion MUST apply gravity, aerodynamic drag, and energy loss exactly according to the applicable complete projectile × atmosphere × flight-state domain and exact admitted Physical Profile versions.

**REQ-BALLISTICS-HITSCAN-001** — Instantaneous-hit behavior MUST NOT be the authoritative firearm result.

**REQ-BALLISTICS-MATERIAL-001** — Every impact MUST resolve to exactly one mutually exclusive and collectively exhaustive primary outcome of `Stopped`, `Penetrated`, or `Ricocheted` according to the applicable Physical Effects Catalogue row for projectile state, target material, residual energy, and impact geometry.

**REQ-BALLISTICS-RESIDUAL-001** — A `Penetrated` or `Ricocheted` projectile MUST continue with the exact residual state, energy, direction, deformation, and tolerance required by its applicable exact admitted Physical Profiles.

**REQ-BALLISTICS-DEFORMATION-001** — Deformation or fragmentation MUST execute exactly when and as the applicable Physical Effects Catalogue row requires, MUST NOT execute for a `Not Applicable` row, and MUST use an admitted transformation row satisfying `REQ-ITEM-TRANSFORMATION-001` for every terminated or created represented identity.

**REQ-OVERPRESSURE-001** — Every weapon discharge and explosion MUST resolve Blast Overpressure independently from Acoustic Propagation across the closed admitted source × propagation-medium/path × geometry × target/protection/state domain, including an explicit `No effect` outcome below applicable thresholds.

**REQ-OVERPRESSURE-EFFECT-001** — Every applicable Blast Overpressure exposure MUST select exactly one result from a mutually exclusive and collectively exhaustive combined-outcome-tuple inventory; injury, Functional State, physical-impulse, and sensory-disruption fields MAY coexist within one tuple, while `No effect` MUST be true exactly when every other effect field is empty, and every temporary output MUST define its exact duration, recovery rule, and tolerance.

**REQ-OVERPRESSURE-EXPOSURE-001** — Blast Overpressure resolution MUST use the exact pressure-time history, arrival, propagation path and distance, intervening geometry and materials, target geometry and state, and protection inputs required by the applicable complete catalogue row and MUST NOT substitute a fixed-radius outcome.

**REQ-OVERPRESSURE-PROFILE-001** — Each represented weapon discharge and explosive type MUST reference the exact admitted Physical Profile versions covering every applicable overpressure source, path, target, and outcome row.

**CONSTRAINT-PHYSICAL-APPROVAL-001** — Every Physical Profile item used for weapon, ammunition, injury, impact, or blast fidelity MUST receive `Pass` validation from a Qualified Specialist whose approved scope covers that item and project-owner approval of the exact profile version before admission.

**CONSTRAINT-PHYSICAL-APPROVAL-002** — The software team MUST NOT invent, self-certify, or use a physical value or behavior as normative without its item-level supporting evidence and ordinary Approved Profile validation and admission record.

**REQ-PHYSICAL-TRACEABILITY-001** — Each Physical Profile MUST satisfy the complete Approved Profile record, item-level traceability, validation, approval, admission, and change-history requirements.

## Acoustic Propagation

**REQ-ACOUSTIC-SOURCE-INVENTORY-001** — A versioned source inventory MUST enumerate every admitted represented sound-source class, material, opening, environment, propagation path, receiver and output class; it MUST be reconciled to complete authoritative content, geometry, material, profile, and requirement registries and approved by the project owner for that exact version.

**REQ-ACOUSTIC-CATALOGUE-001** — Before affected behavior is used or verified, the project owner MUST approve and admit one exact Acoustic Propagation Catalogue version reconciled to the approved source inventory.

**REQ-ACOUSTIC-CATALOGUE-002** — Every applicable source × path/opening × material × geometry × environment × receiver/output row MUST reference exact admitted Acoustic Profile versions and define emission, travel time, arrival direction, intensity, spectral content, occlusion, transmission, reflection, reverberation, echo, receiver output, perception criteria, and tolerances, or contain a justified `Not Applicable` result with evidence.

**REQ-ACOUSTIC-CATALOGUE-003** — A missing, stale, uncertain, unclassified, unsupported, or non-admitted catalogue row or Acoustic Profile version MUST block admission and verification of the affected sound behavior and MUST NOT receive a default output.

**REQ-ACOUSTIC-CATALOGUE-004** — A change to the catalogue, source inventory, row, Acoustic Profile, geometry, material, environment, or dependency MUST create a new version, retain preceding decisions and evidence, and trigger evidence-impact analysis.

**REQ-ACOUSTIC-001** — Weapon discharges and explosions MUST produce Acoustic Propagation with direction, arrival time, intensity, spectral content, obstruction, and environmental response exactly as required by their applicable Acoustic Propagation Catalogue rows and exact admitted Acoustic Profile versions.

**REQ-WAVE-SEPARATION-001** — Audible sound MUST NOT be the authoritative representation of physical Blast Overpressure.

**REQ-ACOUSTIC-DELAY-001** — The reference Scenario MUST use 343 metres per second as acoustic propagation speed.

**REQ-ACOUSTIC-DELAY-002** — An acoustic receiver output MUST NOT be rendered before its authoritative profile-derived arrival time and MUST be rendered at that arrival time when its applicable receiver-output and perception conditions are satisfied.

**REQ-ACOUSTIC-ORDER-001** — When a corresponding authoritative visual or physical effect reaches a Trainee before the profile-derived acoustic arrival time, that effect MUST remain observable before the sound; the Training Simulation MUST NOT delay it solely to synchronize with audio.

**REQ-ACOUSTIC-OCCLUSION-001** — Every admitted barrier class MUST alter Acoustic Propagation exactly according to its applicable material, geometry, path, and Acoustic Profile row, within the declared tolerance.

**REQ-ACOUSTIC-PATH-001** — Propagation MUST evaluate every path class and opening admitted by the applicable catalogue domain and MUST use the profile-resolved path outputs rather than direct straight-line distance alone.

**REQ-ACOUSTIC-FILTER-001** — An obstruction MUST change receiver intensity and spectral content exactly when and as required by its applicable exact admitted Acoustic Profile, and MUST NOT apply an unenumerated change.

**REQ-ACOUSTIC-REFLECTION-001** — Acoustic Propagation MUST produce the direction, arrival, intensity, spectrum, decay and spatial receiver output of every applicable reflection and reverberation path according to exact environment geometry, volume, material properties, Acoustic Profiles, and tolerances.

**REQ-ACOUSTIC-ECHO-001** — A reflected path whose direct-to-reflected arrival difference satisfies the exact admitted echo-distinction criterion and tolerance MUST be rendered as a distinct spatial receiver output at its profile-derived direction and arrival time; a path below that criterion MUST NOT be accepted as a distinct echo.

**REQ-ACOUSTIC-ENVIRONMENT-001** — Open-area, small-room, and corridor receiver outputs MUST satisfy the exact pre-approved pairwise distinction criteria and tolerances across the catalogue's controlled source, receiver, geometry, material, and background conditions.

## Injury and Trainee Functional State

**REQ-INJURY-SOURCE-INVENTORY-001** — A versioned source inventory MUST enumerate every admitted body region, exposure type, magnitude/energy/pressure class, protection class, prior-injury class, Trainee Functional State, injury outcome, limitation, and external or sensory cue; it MUST be reconciled to complete authoritative physical, equipment, action, profile, and requirement registries and approved by the project owner for that exact version.

**REQ-INJURY-CATALOGUE-001** — Before injury behavior is used or verified, the project owner MUST approve and admit one exact Injury Outcome Catalogue version reconciled to the approved source inventory.

**REQ-INJURY-CATALOGUE-002** — Every body-region × exposure × magnitude × protection × prior-injury × current-state row MUST reference exact admitted Injury Profile versions and define one required injury outcome, resulting limitations, Functional State input, downstream profile and matrix effects, cue outputs, durations, temporary-effect recovery if any, and tolerances, or contain a justified `Not Applicable` result with evidence; recovery MUST NOT remove an injury or injury-derived limitation during the Training Session.

**REQ-INJURY-CATALOGUE-003** — Every effect category, requirement, and potential downstream effect enumerated by the approved source inventory and Injury Outcome Catalogue schema MUST be classified `Enabled` with an exact complete rule or `Disabled` with justification for every applicable catalogue row; a missing, stale, uncertain, unsupported, unclassified, or non-admitted row or profile MUST block admission and verification and MUST NOT receive a default outcome.

**REQ-INJURY-CATALOGUE-004** — A change to the catalogue, source inventory, Injury Profile, downstream profile or matrix dependency, row, or evidence MUST create a new version, retain preceding decisions and evidence, and trigger evidence-impact analysis.

**REQ-FUNCTIONAL-TRANSITION-CATALOGUE-001** — The project owner MUST approve one exact Functional State Transition Catalogue version that covers every current Trainee Functional State × single, simultaneous, and accumulated injury-outcome class admitted by the Injury Outcome Catalogue.

**REQ-FUNCTIONAL-TRANSITION-CATALOGUE-002** — Every transition row MUST define exactly one succeeding Trainee Functional State, complete retained and added limitation set, same-transition aggregation rule and total ordering for simultaneously accepted exposures, and the exact Injury Outcome Catalogue version; no transition absent from that matrix is permitted.

**REQ-FUNCTIONAL-TRANSITION-CATALOGUE-003** — A missing, stale, uncertain, or unclassified transition or injury-aggregation result MUST block admission and verification; catalogue changes MUST retain history and trigger evidence-impact analysis.

**REQ-INJURY-MODEL-001** — Every injury-producing exposure MUST resolve exactly once through the applicable Injury Outcome Catalogue row using body region, exposure type, transferred energy or pressure, protection, prior injuries, and current Trainee Functional State and MUST apply that row's exact admitted Injury Profile outcome.

**REQ-INJURY-MODEL-002** — Injury MUST NOT be determined solely by a global hit-point value.

**REQ-INJURY-EVIDENCE-001** — Every injury threshold, combination rule, protection effect, limitation, cue, and transition used as validated behavior MUST be an item in an exact admitted Injury Profile version with supporting evidence, in-scope Qualified Specialist `Pass` validation, and project-owner approval.

**REQ-FUNCTIONAL-STATE-001** — Every Trainee MUST have exactly one authoritative state: `Capable`, `Impaired`, `Incapacitated`, or `Fatal`.

**REQ-FUNCTIONAL-STATE-002** — Every `Impaired` outcome MUST retain at least one permitted Action Inventory entry after all injury-derived limitations and Action Compatibility rules are applied; an outcome retaining none MUST be classified `Incapacitated` or `Fatal` instead.

**REQ-FUNCTIONAL-STATE-003** — An `Incapacitated` Trainee MUST remain represented but MUST NOT perform training actions.

**REQ-FUNCTIONAL-STATE-004** — `Fatal` MUST be terminal for the remainder of the Training Session.

**REQ-FUNCTIONAL-STATE-005** — During the same Training Session, an `Impaired` Trainee MUST NOT return to `Capable`, remove an existing injury, or remove an existing injury-derived limitation; each accepted injury transition MUST preserve or add limitations and MUST follow the exact Functional State Transition Catalogue row.

**REQ-FUNCTIONAL-STATE-006** — A single injury event from `Capable` MUST transition directly to the exact `Capable`, `Impaired`, `Incapacitated`, or `Fatal` result required by its admitted catalogue row; the Training Simulation MUST NOT insert an intermediate state absent from that row.

**REQ-FUNCTIONAL-STATE-007** — An `Incapacitated` Trainee MUST remain subject to injury-producing exposures and every subsequent exposure MUST apply the exact transition row, including transition to `Fatal` whenever that row requires it.

**REQ-IMPAIRMENT-REGION-001** — The functional limitations of an `Impaired` Trainee MUST equal the retained and added limitation set in the exact applicable region-specific Injury Outcome and Functional State Transition Catalogue rows and MUST NOT use one generic impairment penalty.

**REQ-IMPAIRMENT-REGION-002** — Lower-limb and upper-limb impairment MUST apply their exact enabled locomotion and weapon/equipment-manipulation effects respectively, and MUST NOT apply a disabled or unenumerated effect.

**REQ-IMPAIRMENT-COMBINATION-001** — Concurrent and accumulated injuries MUST retain and combine limitations exactly according to the applicable transition row's aggregation rule in one atomic canonical update.

**REQ-IMPAIRMENT-COMBINATION-002** — A combination of injuries MUST transition an `Impaired` Trainee to `Incapacitated` or `Fatal` exactly when the applicable Functional State Transition Catalogue row requires it, including when no individual injury alone has that result.

**REQ-IMPAIRMENT-LOWER-LIMB-001** — Every enabled lower-limb effect MUST change maximum movement speed, acceleration, posture transitions, or obstacle traversal exactly according to the applicable Injury and Locomotion Profile fields, domains, precedence, and tolerances.

**REQ-IMPAIRMENT-LOWER-LIMB-002** — An enabled lower-limb effect MUST prevent running or obstacle traversal exactly when its admitted row requires it; that prevention alone MUST NOT imply `Incapacitated` unless the transition row also requires that state.

**REQ-IMPAIRMENT-UPPER-LIMB-001** — Every enabled upper-limb effect MUST change duration or availability of reloads, equipment manipulation, and other affected Action Inventory entries exactly through the cited Action Physical Condition Inventory, Action Compatibility Matrix, and admitted profile fields, domains, precedence, and tolerances.

**REQ-IMPAIRMENT-UPPER-LIMB-002** — An enabled upper-limb effect MUST prevent two-handed weapon use exactly when its admitted row requires it and MUST preserve one-handed weapon use whenever the complete current-state Action Compatibility Matrix row permits it.

**REQ-IMPAIRMENT-AIM-001** — Upper-limb impairment MUST NOT apply artificial random deviation to the authoritative weapon orientation controlled by the Trainee.

**REQ-IMPAIRMENT-SENSORY-001** — Every enabled head or sensory-organ impairment effect MUST change vision or hearing through only the exact Diegetic Presentation cue/effect inventory, input domain, bounds, duration, perception criteria, and tolerances in its admitted Injury Profile.

**REQ-IMPAIRMENT-SENSORY-002** — Sensory impairment MUST NOT be communicated through a status message, meter, icon, or other non-diegetic active-simulation display.

**REQ-IMPAIRMENT-TORSO-001** — Every enabled torso impairment effect MUST change sustainable physical exertion, Fatigue accumulation, Fatigue recovery, or audible breathing exactly through the cited Injury, Fatigue, Locomotion, and Acoustic Profile fields, domains, precedence, and tolerances.

**REQ-INJURY-DOWNSTREAM-TRACE-001** — Every enabled injury effect MUST identify every affected Locomotion Profile, Fatigue Profile, Stress Profile, Acoustic Profile, Action Physical Condition Inventory, Action Compatibility Matrix, and other downstream field; every affected artifact MUST include the exact injury class and precedence and MUST undergo evidence-impact analysis after an injury-row change.

**REQ-INJURY-STRESS-ORDER-001** — For one or more injury-producing exposures accepted in the same canonical transition, the Session Authority MUST first derive every Injury Outcome and their combined Functional State Transition result using the catalogue's aggregation rule and total order, then supply the exact ordered exposure set, combined injury class, and resulting Functional State as one Stress Profile input, and commit all injuries, limitations, Functional State, Fatigue-input effects, and Stress Load atomically in that transition.

**REQ-IMPAIRMENT-EXTERNAL-001** — Every injury limitation with an enabled external cue MUST emit the exact admitted animation and sound cue set and satisfy its perception and distinction criteria and tolerances across the closed observer viewpoint, lighting, acoustic-path, environment, and comparison-state domain.

**REQ-IMPAIRMENT-EXTERNAL-002** — The Training Simulation MUST NOT directly disclose another Trainee's functional state through labels, icons, or other non-diegetic active-simulation information.

**REQ-RESPAWN-001** — `Incapacitated` and `Fatal` Trainees MUST NOT respawn or return to a more capable state during the same Training Session.

**REQ-BODY-PERSISTENCE-001** — `Incapacitated` and `Fatal` Trainees MUST remain physically represented until session end.

**REQ-INCAPACITATED-BODY-001** — `Incapacitated` and `Fatal` bodies MUST use exact admitted Physical Profile versions covering the complete body pose × contact geometry × force × surface × Trainee-clearance domain, MUST produce the defined deterministic or bounded response within tolerance, and MUST permit or reject navigation around or over them according to the profile's exact clearance and traversal criteria; no-contact controls MUST produce no collision response.

**REQ-POST-INCAPACITY-VIEW-001** — `Incapacitated` and `Fatal` Trainees MUST NOT access free camera, another Trainee's perspective, or spectator view.

**REQ-POST-INCAPACITY-VIEW-002** — Their perspective origin MUST remain at the exact profile-defined own-body transform and expose only the admitted current visual and acoustic perception outputs after applicable geometry, environment, injury, and equipment effects, with no information from another position or source.

## Melee

**REQ-MELEE-SOURCE-INVENTORY-001** — A versioned source inventory MUST enumerate every admitted body and Functional State class, Melee action, implement, equipment interface, required hand and action resource, access mode, physical-condition class, contact phase, target, defense, and Melee requirement; it MUST be reconciled to complete Action, Carrying, Weapon Behavior, Physical Effects, Injury Outcome, mode, content, and requirement registries and approved by the project owner for that exact version.

**REQ-MELEE-CATALOGUE-001** — Before Melee behavior is used or verified, the project owner MUST approve and admit one exact Melee Coverage Catalogue version reconciled to the approved source inventory.

**REQ-MELEE-CATALOGUE-002** — Every applicable body/state × action × implement/interface × resource × access-mode × physical-condition row MUST define a nonempty action domain, exact admitted Approved Profile and downstream catalogue versions, input behavior, active-contact phase, physical limits, interruption boundaries, and output tolerances, or contain a justified `Not Applicable` result with evidence.

**REQ-MELEE-CATALOGUE-003** — A missing, stale, uncertain, unsupported, unclassified, or non-admitted row, profile, interface, or dependency MUST block admission and verification of the affected Melee behavior and MUST NOT receive a default capability or outcome.

**REQ-MELEE-CATALOGUE-004** — A change to the catalogue, source inventory, row, profile, equipment, action, mode, physical condition, or dependency MUST create a new version, retain preceding decisions and evidence, and trigger evidence-impact analysis.

**REQ-MELEE-UNARMED-001** — A `Capable` or `Impaired` Trainee MUST be able to perform every unarmed strike classified `Applicable` by the exact Melee Coverage Catalogue under its complete declared current-state domain through an explicit action.

**REQ-MELEE-FIREARM-001** — A `Capable` or `Impaired` Trainee MUST be able to strike using a currently held firearm exactly when the applicable Melee and Weapon Behavior Catalogue rows classify that action as `Applicable` under the complete current-state domain.

**REQ-MELEE-BLADE-001** — A Loadout MUST be able to assign a represented combat knife or bayonet exactly when its Carrying, Weapon Behavior, Melee, Physical Effects, and Injury Outcome Catalogue rows and exact admitted Approved Profile versions classify that Melee use as `Applicable`.

**REQ-MELEE-BLADE-002** — A blade strike MUST produce an effect only when the exact admitted blade collision geometry contacts the target during the catalogue-defined active-contact phase of a Trainee-controlled strike and the contact satisfies its profile tolerance.

**REQ-MELEE-KNIFE-CARRY-001** — A combat knife MUST occupy a compatible Carry Position while stowed and MUST be explicitly drawn into the required hand before use.

**REQ-MELEE-BAYONET-001** — A bayonet MUST be physically mounted on a compatible firearm before the bayonet can produce a Melee effect.

**REQ-MELEE-BLADE-AUTOMATION-001** — Issuing a Melee command MUST NOT automatically draw, create, or mount a blade.

**REQ-MELEE-ITEM-STATE-001** — Every Melee draw, hand, Carry Position, mount, removal, and attachment transition MUST use exact admitted Item Dispositions and satisfy the atomic item-transfer and identity-conservation requirements.

**REQ-MELEE-ITEM-DAMAGE-001** — A non-transforming Melee equipment-damage outcome MUST preserve the item's stable identity and one Item Disposition; every identity-changing deformation or fragmentation MUST use an admitted transformation row satisfying `REQ-ITEM-TRANSFORMATION-001`.

**REQ-MELEE-CONTACT-001** — A Melee strike MUST produce an impact only when admitted striking geometry physically contacts an admitted target geometry within tolerance during the catalogue-defined active-contact phase; every no-contact and out-of-phase case MUST produce `No impact`.

**REQ-MELEE-OUTCOME-001** — Every Melee contact MUST select exactly one combined outcome tuple from the applicable complete action-phase × implement/body × contact-geometry/material × relative-state × target/body-region/protection row, using exact admitted Physical and Injury Profile versions; each tuple MUST define impulse, injury, equipment damage, transformation, and `No effect` fields, rule or approved stochastic distribution, and tolerances, with `No effect` true exactly when every other effect field is empty.

**REQ-MELEE-TARGETING-001** — Melee MUST NOT snap to a target, select a target automatically, or execute a cinematic takedown animation.

**REQ-MELEE-INPUT-VR-001** — In Virtual-Reality Mode, tracked-controller motion MUST determine the represented strike motion within the exact limits produced by the applicable Melee Coverage Catalogue and admitted profile row for the current complete state.

**REQ-MELEE-INPUT-DESKTOP-001** — In Desktop Mode, holding an explicit Melee command and moving the mouse MUST control the represented striking body part or held equipment continuously within the exact limits produced by the applicable Melee Coverage Catalogue and admitted profile row for the current complete state.

**REQ-MELEE-INPUT-DESKTOP-002** — Releasing the Desktop Mode Melee command MUST end direct strike control and MUST NOT complete an automatic target-oriented attack animation.

**REQ-MELEE-INPUT-PARITY-001** — Desktop Mode and Virtual-Reality Mode MUST resolve Melee contact and outcomes through the same authoritative physical and injury rules.

**REQ-MELEE-PHYSICAL-LIMIT-001** — Melee strike speed, achievable impact energy, sustainable repetition, and recovery duration MUST equal the exact bounded outputs and tolerances derived from cited body/action, Locomotion, Fatigue, Injury, Physical, and equipment profile fields over the complete posture × Carried Load × Fatigue × injury/Functional State × implement × action × access-mode domain, using declared precedence.

**REQ-MELEE-STRESS-001** — Stress Load MUST change Melee preparation or recovery duration exactly when and as the applicable Stress Profile effect is `Enabled`, MUST NOT change it when that effect is `Disabled` or unenumerated, and MUST NOT introduce artificial directional error or randomly fail an otherwise valid Melee action.

**REQ-MELEE-BLOCK-001** — A Trainee MUST be able to interpose an arm, held weapon, or held equipment item exactly when the applicable Melee Coverage Catalogue row permits it; admitted physical geometry MUST then be able to contact the incoming strike under the same contact rules without an automatic defense outcome.

**REQ-MELEE-BLOCK-002** — Melee defense MUST NOT use an abstract parry window, automatic block state, or temporary invulnerability.

**REQ-MELEE-BLOCK-003** — Contact during Melee defense MUST resolve motion, injury, equipment damage, and any identity transformation through the applicable exact Melee, Physical Effects, Injury Outcome, Weapon Behavior, and Carrying Catalogue rows and exact admitted Approved Profile versions.

**REFERENCE-MELEE-BLADE-001** — Each Team in the reference Scenario MUST have at least one available Loadout containing a represented combat knife or bayonet whose exact Carrying, Melee, Physical Effects, Injury Outcome, and applicable Weapon Behavior Catalogue rows and Approved Profile versions are admitted.

**REFERENCE-MELEE-OPTIONAL-001** — Performing Melee MUST NOT be required to complete or prevent the Personnel Recovery objective in the reference Scenario.

## Trainee collision and friendly fire

**REQ-TRAINEE-COLLISION-PROFILE-001** — Exact admitted Physical Profile versions MUST cover every Trainee Functional State/pose × body-pair × geometry/contact/force/surface class, penetration tolerance, deterministic or bounded response, multi-contact aggregation and order, and ordinary-displacement classification and threshold.

**REQ-TRAINEE-COLLISION-001** — Trainees MUST physically block one another regardless of Team according to the exact applicable body-collision Physical Profile and penetration tolerance.

**REQ-TRAINEE-COLLISION-002** — Two Trainee collision bodies MUST NOT overlap beyond the exact admitted penetration tolerance or pass through one another; no-contact controls MUST produce no collision response.

**REQ-TRAINEE-CONTACT-001** — Each body-contact profile row MUST classify ordinary displacement `Enabled` or `Disabled`; when enabled, contact MUST produce only the row's bounded direction, magnitude, duration, and multi-contact result, and when disabled it MUST produce none; no contact may exceed the exact prohibited-force or movement threshold or provide an artificial attack or movement mechanism.

**REQ-HARMFUL-EFFECT-INVENTORY-001** — An approved, versioned, and closed Harmful Effect Inventory MUST enumerate every admitted source capable of injury, impairment, equipment damage, or another adverse authoritative outcome and reconcile each item to exact Physical Effects, Injury Outcome, Melee, Fire, environment, equipment, and other applicable catalogue and profile rows.

**REQ-HARMFUL-EFFECT-INVENTORY-002** — The project owner MUST approve the exact reconciled Harmful Effect Inventory version before friendly-fire verification; a missing, stale, uncertain, unclassified, or non-admitted harmful effect MUST block acceptance and MUST NOT default to Team-dependent or Team-independent behavior.

**REQ-HARMFUL-EFFECT-INVENTORY-003** — An inventory or dependency change MUST create a new version, retain preceding decisions and evidence, and trigger evidence-impact analysis.

**REQ-FRIENDLY-FIRE-001** — Every Harmful Effect Inventory item, including Ballistic Projectiles and Blast Overpressure, MUST use identical applicability, physical-resolution, equipment-effect, and injury rules in paired cases differing only in target Team identity.

**REQ-FRIENDLY-FIRE-002** — Team identity MUST NOT reduce, cancel, or alter an authoritative outcome; outcome differences caused by represented equipment, protection, geometry, state, or another non-Team input remain permitted and MUST trace to that changed input.

## Environment damage

**REQ-ENVIRONMENT-SOURCE-INVENTORY-001** — A versioned source inventory MUST enumerate the finite members of every admitted object/effect, interaction/exposure, current-state, physical-condition, door, window, circuit, light, Obscurant, thrown or explosive device, Fire source/material/state, movable-object, destructible-surface, outcome, and requirement dimension; it MUST be reconciled to complete content, Action, Carrying, Weapon Behavior, Physical Effects, Acoustic Propagation, Injury Outcome, Harmful Effect, profile, and requirement registries and approved by the project owner for that exact version.

**REQ-ENVIRONMENT-CATALOGUE-001** — Before affected environment behavior is used or verified, the project owner MUST approve and admit one exact Environment Coverage Catalogue version reconciled to the approved source inventory.

**REQ-ENVIRONMENT-CATALOGUE-002** — Every source-inventory object/effect × interaction/exposure × current-state × physical-condition row MUST be classified `Applicable` with exact admitted profile and downstream catalogue versions, preconditions, state transition, physical and perceptual outputs, transformations, duration, rule or approved stochastic distribution, and tolerances, or `Not Applicable` with justification and evidence.

**REQ-ENVIRONMENT-CATALOGUE-003** — A missing, stale, uncertain, unsupported, unclassified, or non-admitted row, profile, state, or dependency MUST block admission and verification of affected environment content and MUST NOT receive a default capability or outcome.

**REQ-ENVIRONMENT-CATALOGUE-004** — A change to the catalogue, source inventory, row, profile, state schema, content, or dependency MUST create a new version, retain preceding decisions and evidence, and trigger evidence-impact analysis.

**REQ-ENVIRONMENT-STATE-CATALOGUE-001** — The project owner MUST approve one exact Environment State Catalogue version covering every admitted environment object/effect state and transition, including door lock/breach/damage/manipulation, window operation/damage, light power/damage, device preparation/activation/initiation/lifecycle, Obscurant, Fire, movable-object, and localized-damage states.

**REQ-ENVIRONMENT-STATE-CATALOGUE-002** — Every transition row MUST define complete triggering inputs, preconditions, one succeeding state and output tuple, same-event aggregation and total precedence, atomic Item Disposition and transformation outputs, terminal states, persistence, and reset state; no unenumerated transition is permitted.

**REQ-ENVIRONMENT-STATE-CATALOGUE-003** — A missing, stale, uncertain, unclassified, or conflicting state or same-event transition MUST block affected content; catalogue changes MUST retain history and trigger evidence-impact analysis.

**REFERENCE-TACTICAL-SPACE-INVENTORY-001** — The reference Map MUST have a versioned inventory of spaces and door/window connections with stable identifiers, geometry, access paths, training use, and objective connection evidence; before Map admission, at least two independent in-scope Representative Evaluators MUST confirm each connection classified tactically relevant under a pre-approved criterion, and the project owner MUST approve that exact inventory and procedure version.

**REFERENCE-MAP-DOOR-001** — The reference Map MUST contain physically represented operable doors for every door connection admitted as tactically relevant by the approved reference-space inventory.

**REFERENCE-MAP-LOCKED-DOOR-001** — The reference Personnel Recovery Scenario MUST configure at least one operable door as initially locked and MUST provide at least one represented breach method with an `Applicable` row for that exact door, tool or effect, and condition in the admitted Environment Coverage Catalogue.

**REFERENCE-DOOR-BREACH-TOOL-001** — At least one recovering-Team Loadout in the reference Scenario MUST include a dedicated mechanical breaching tool whose exact tool × initially locked door × condition row is admitted and classified `Applicable` in the Environment Coverage Catalogue.

**REQ-DOOR-INTERACTION-001** — A `Capable` or `Impaired` Trainee MUST be able to open or close an operable door through an explicit interaction exactly when the applicable Environment Coverage Catalogue row permits it for the current Functional State, action resources, control-point reach, obstruction, and door state.

**REQ-DOOR-STATE-001** — An operable door's exact authoritative position and state MUST produce the movement-collision, visibility, Ballistic Projectile, and Acoustic Propagation outputs required by its admitted geometry, material, Environment State, Physical Effects, Lighting, and Acoustic rows.

**REQ-DOOR-MOTION-001** — An operable door MUST move through the exact continuous physical range, path, limits, intermediate stable-state domain, and tolerance in its admitted profile.

**REQ-DOOR-MOTION-002** — Door movement MUST apply the exact admitted profile response and tolerance for every applicable Trainee interaction, collision, obstruction, and physical-force tuple.

**REQ-DOOR-MOTION-003** — An obstruction MUST prevent the door from moving through the obstructing body or object.

**REQ-DOOR-INPUT-VR-001** — In Virtual-Reality Mode, a Trainee MUST be able to grasp and move an operable door through tracked-controller motion.

**REQ-DOOR-INPUT-DESKTOP-001** — In Desktop Mode, a Trainee MUST be able to hold an explicit interaction command and use mouse motion to control the door continuously.

**REQ-DOOR-INPUT-RELEASE-001** — Releasing the active door interaction MUST stop the Trainee's direct manipulation and leave the door at the resulting physical position, subject to subsequent collisions and forces.

**REQ-DOOR-INPUT-PARITY-001** — Both input methods MUST operate on the same authoritative door state and satisfy Mode Equivalence for tactically relevant door placement.

**REQ-DOOR-LOCK-001** — A Scenario MUST be able to define each operable door's initial lock state.

**REQ-DOOR-LOCK-002** — A locked door MUST NOT open through the normal open interaction while its lock remains effective.

**REQ-DOOR-LOCK-003** — During active simulation, a Trainee MUST NOT lock, relock, or conventionally unlock a door, and keys MUST NOT be represented in the initial baseline.

**REQ-DOOR-LOCK-004** — Once the canonical state transition accepts a successful breach, the lock MUST become ineffective atomically and remain ineffective for the remainder of the Training Session according to the Environment State Catalogue.

**REQ-DOOR-BREACH-001** — A locked door MUST transition exactly according to the represented breaching interaction or physical effect outcome selected by its applicable exact admitted Environment and Physical Profile rows and MUST yield only when that outcome declares a successful breach.

**REQ-DOOR-BREACH-002** — A breached or damaged door state MUST persist for the remainder of the Training Session and affect subsequent simulation according to `REQ-DOOR-STATE-001`.

**REQ-DOOR-MECHANICAL-BREACH-001** — Mechanical breaching MUST require explicit use of a tool classified compatible by the exact admitted tool/door row within its complete physical-condition domain and MUST resolve to that row's required state and physical outcome.

**REQ-DOOR-BALLISTIC-EXPLOSIVE-BREACH-001** — Ballistic or explosive breaching MUST be available exactly for weapon, charge, door and physical-condition combinations classified `Applicable` by exact admitted Environment and Physical Effects Catalogue rows and MUST apply their required outcome.

**REFERENCE-MAP-WINDOW-001** — The reference Map MUST contain physically represented windows for every window connection admitted as tactically relevant by the approved reference-space inventory.

**REFERENCE-MAP-WINDOW-OPERABLE-001** — The reference Map MUST contain at least one operable window.

**REQ-WINDOW-CLASSIFICATION-001** — A Scenario MUST be able to classify a window as fixed or operable independently of whether that window is classified as breakable.

**REQ-WINDOW-INTERACTION-001** — A `Capable` or `Impaired` Trainee MUST be able to open or close an operable window through an explicit interaction exactly when the applicable Environment Coverage Catalogue row permits it for the current Functional State, action resources, control-point reach, obstruction, and window state.

**REQ-WINDOW-MOTION-001** — An operable window MUST move continuously within the exact admitted mechanism path, limits, intermediate stable-state domain, and tolerance.

**REQ-WINDOW-MOTION-002** — Collision or obstruction MUST prevent an operable window from moving through the obstructing body or object.

**REQ-WINDOW-INPUT-VR-001** — In Virtual-Reality Mode, a Trainee MUST manipulate an operable window through tracked-controller motion consistent with its represented mechanism.

**REQ-WINDOW-INPUT-DESKTOP-001** — In Desktop Mode, a Trainee MUST manipulate an operable window continuously by holding an explicit interaction command and using mouse motion.

**REQ-WINDOW-INPUT-PARITY-001** — Both input methods MUST operate on the same authoritative window state and satisfy Mode Equivalence for tactically relevant window placement.

**REQ-WINDOW-DAMAGE-001** — Every exposure of a breakable window MUST select and apply exactly one exhaustive outcome, including explicit `No effect`, from its exact admitted material, structural, Environment State, and Physical Effects rows; a successful break outcome MUST perform its atomic geometry and transformation changes.

**REQ-WINDOW-DAMAGE-002** — A window's exact intact, damaged, or broken state MUST produce the movement, visibility, Ballistic Projectile, Acoustic Propagation, geometry, material, and fragment outputs required by its admitted Environment State and downstream catalogue rows.

**REQ-WINDOW-TRAVERSAL-001** — A `Capable` or `Impaired` Trainee MUST be able to traverse an open or broken window through the required obstacle-traversal action exactly when the applicable Locomotion and Environment rows' opening, approach, collision, state and clearance predicate passes within tolerance.

**REQ-WINDOW-TRAVERSAL-002** — Window traversal MUST respect the collision geometry of the frame, intact glazing, and remaining fragments and MUST NOT move the Trainee through solid represented geometry.

**REQ-WINDOW-FRAGMENT-001** — Window fragment generation and injury MUST execute exactly when and as the applicable exact admitted Environment, Physical Effects, Injury Outcome, and transformation rows require and MUST NOT execute for `No effect`, `Disabled`, or `Not Applicable` rows.

**REFERENCE-MAP-LIGHTING-CONTROL-001** — The reference Map MUST contain at least one interior lighting circuit controlled by a represented physical switch.

**REQ-LIGHT-SWITCH-001** — A `Capable` or `Impaired` Trainee MUST be able to operate a represented light switch through an explicit interaction exactly when the applicable Environment row's Functional State, resource, reach, obstruction, switch, circuit, and current-state predicate passes.

**REQ-LIGHT-CIRCUIT-001** — Operating a light switch MUST change the powered state of every functioning light source connected to its represented circuit.

**REQ-LIGHT-DAMAGE-001** — Every light-source exposure MUST select and apply exactly one exhaustive outcome, including `No effect`, from its exact admitted equipment, Environment State, and Physical Effects rows.

**REQ-LIGHT-DAMAGE-002** — A damaged light source MUST cease producing light and remain inoperable for the remainder of the Training Session.

**REQ-LIGHT-VISIBILITY-001** — Every functioning-light state change MUST produce the exact spatial illumination, shadow, and visibility outputs, domains, comparison metrics, and tolerances required by its admitted Lighting Profile and environment geometry.

**REQ-LIGHTING-TACTICAL-PERCEPTION-001** — Before Lighting or Obscurant Profile outputs are accepted for the reference Scenario, at least two independent in-scope Representative Evaluators MUST confirm under a pre-approved protocol that the admitted illumination, shadow, occlusion, and Obscurant visibility differences preserve tactically relevant perception across the declared spaces, paths, and viewpoints, and the project owner MUST approve the exact protocol and profile versions before observation.

**REQ-PORTABLE-LIGHT-001** — A Loadout MUST be able to include a represented handheld or weapon-mounted light compatible with its assigned equipment.

**REQ-PORTABLE-LIGHT-CONTROL-001** — A Trainee MUST be able to switch each accessible assigned portable light on or off independently through an explicit control.

**REQ-PORTABLE-LIGHT-PHYSICAL-001** — A powered-on portable light MUST emit from its authoritative physical transform and produce the exact admitted Lighting Profile spatial output; intervening geometry MUST occlude it according to the complete geometry/material/path domain and tolerance.

**REQ-PORTABLE-LIGHT-SHADOW-001** — Portable-light illumination MUST produce the exact spatial lighting and shadow outputs, comparison metrics, and tolerances required by its admitted Lighting Profile.

**REQ-PORTABLE-LIGHT-SHARED-001** — Every Trainee MUST observe outcomes derived from the same authoritative portable-light state; the light MUST NOT illuminate only for the operating Trainee.

**REQ-PORTABLE-LIGHT-DAMAGE-001** — Every portable-light exposure MUST select and apply exactly one exhaustive outcome, including `No effect`, from its exact admitted equipment, Environment State, and Physical Effects rows.

**REQ-PORTABLE-LIGHT-DAMAGE-002** — A damaged portable light MUST lose all lighting and control functionality immediately, MUST NOT exhibit partial functional failure, and MUST remain inoperable for the remainder of the Training Session.

**REQ-PORTABLE-LIGHT-DAMAGE-003** — Portable-light failure MUST be communicated through the represented equipment and absence of emitted light without a non-diegetic durability meter or failure message.

**REQ-PORTABLE-LIGHT-ENERGY-001** — A functioning portable light MUST have sufficient simulated energy for the entire Training Session and MUST NOT become unavailable solely because of elapsed powered-on time.

**REQ-OBSCURANT-SOURCE-001** — Every explosion, impact, and dedicated smoke-producing-device exposure MUST select and apply exactly one exhaustive Obscurant outcome, including `No effect`, from its exact admitted Environment, Physical Effects, device, and Obscurant Profile rows.

**REQ-OBSCURANT-SHARED-001** — An Obscurant MUST occupy one authoritative shared spatial volume and produce the exact transmitted-light and visibility outputs, path/viewpoint domains, comparison metrics, and tolerances required by its admitted Obscurant and Lighting Profile rows for every Trainee.

**REQ-OBSCURANT-EVOLUTION-001** — Obscurant formation, volume, movement, geometry/opening interaction, and dissipation MUST evolve using Session Authority simulated time and the exact source, environment, geometry, state, bounds, outputs, and tolerances in the applicable admitted Obscurant Profile.

**REQ-OBSCURANT-PRESENTATION-001** — An Obscurant MUST NOT be represented solely as a client-local screen overlay or cosmetic particle effect.

**REQ-OBSCURANT-PHYSIOLOGY-001** — Toxic, respiratory, and injury effects from an Obscurant MUST execute exactly when and as `Enabled` by the Scenario's exact admitted Obscurant, Physical Effects, and Injury Outcome rows and MUST NOT execute when `Disabled`, `No effect`, or unenumerated.

**REFERENCE-SMOKE-GRENADE-001** — Each Team in the reference Scenario MUST have at least one available Loadout containing a represented smoke grenade whose exact admitted device and Obscurant Profile rows select an Obscurant-generating outcome.

**REFERENCE-SMOKE-GRENADE-EFFECT-001** — The Obscurant emitted by the reference smoke grenade MUST NOT produce toxicity, respiratory injury, or a change to Trainee Functional State.

**REFERENCE-FRAGMENTATION-GRENADE-001** — Each Team in the reference Scenario MUST have at least one available Loadout containing a represented fragmentation grenade.

**REQ-FRAGMENTATION-GRENADE-EFFECT-001** — A fragmentation grenade MUST produce Blast Overpressure, physical fragments, and injury outcomes exactly according to its exact admitted device, Physical Effects, transformation, and Injury Outcome rows and profile versions.

**REQ-FRAGMENTATION-GRENADE-EFFECT-002** — Fragmentation-grenade effects MUST NOT be approximated solely by a fixed-radius damage rule.

**REQ-THROWN-DEVICE-OPERATION-001** — Operating a represented thrown device, including a smoke or fragmentation grenade, MUST require explicit preparation, activation, and release or throw actions in the exact order, state transitions, and complete condition domain defined by its admitted Environment Coverage and State rows and device profile.

**REQ-THROWN-DEVICE-ACTIVATION-001** — Once activated, a thrown device MUST continue the exact timing, state transitions, outputs, and terminal Item Disposition in its admitted Environment State and device-profile rows after being dropped or thrown.

**REQ-THROWN-DEVICE-DELAY-001** — Deliberately retaining an activated thrown device before release MUST be permitted exactly when the applicable device row classifies retention `Enabled` under the current state and conditions and MUST be unavailable when `Disabled` or unenumerated.

**REQ-THROWN-DEVICE-RETRIEVAL-001** — Once an activated thrown device has been released or dropped, its Environment State and Carrying Catalogue rows MUST classify it ineligible for pickup, stowing, or another throw by every Trainee until its lifecycle reaches a terminal Item Disposition.

**REQ-THROWN-DEVICE-PHYSICAL-001** — An activated thrown device MUST remain one physical item identity subject to gravity, rolling, falling, collision, and every applicable external force, including Blast Overpressure, according to exact admitted Physical and Environment rows until its lifecycle reaches the declared terminal Item Disposition.

**REQ-EXPLOSIVE-EXTERNAL-INITIATION-001** — Every exposure of an unactivated explosive device in any Item Disposition MUST select and apply exactly one mutually exclusive and exhaustive `Unaffected`, `Damaged`, or `Initiated` outcome from its exact admitted device, Environment State, and Physical Effects rows.

**REQ-EXPLOSIVE-EXTERNAL-INITIATION-002** — An externally initiated explosive device MUST enter the same canonical initiated state and produce the same exact profile-defined physical outputs as any other valid initiation under an equal complete state tuple; those outputs MUST resolve against every exposed represented object or device through their applicable rows.

**REQ-EXPLOSIVE-EXTERNAL-INITIATION-003** — External initiation MUST NOT use a generic or invented probability that is independent of the device profile and applied exposure.

**REQ-THROWN-DEVICE-TRAJECTORY-001** — A released or thrown device MUST follow an authoritative physical trajectory derived from its represented release position, orientation, and velocity and from applicable gravity, aerodynamic, collision, and device-profile effects.

**REQ-THROWN-DEVICE-AID-001** — Active simulation MUST NOT display a predicted trajectory, impact marker, target indicator, or other non-diegetic throwing aid.

**REQ-THROWN-DEVICE-PARITY-001** — Desktop Mode and Virtual-Reality Mode MUST satisfy Mode Equivalence for achievable thrown-device outcomes through their respective input methods.

**REQ-THROWN-DEVICE-INPUT-VR-001** — In Virtual-Reality Mode, tracked-controller position and velocity at release MUST determine the represented release position, direction, and requested velocity.

**REQ-THROWN-DEVICE-INPUT-DESKTOP-001** — In Desktop Mode, holding the throw command MUST prepare the throw, mouse input MUST determine direction, command duration MUST determine requested intensity within the Trainee's current physical limits, and releasing the command MUST release the device.

**REQ-THROWN-DEVICE-INPUT-FEEDBACK-001** — Desktop Mode MUST NOT display a numeric, bar, arc, or other non-diegetic throw-intensity indicator.

**REQ-THROWN-DEVICE-LIMIT-001** — Final maximum release intensity and preparation duration MUST equal the exact bounded outputs and tolerances derived from the admitted device, Physical, Fatigue, Stress, Injury, Locomotion, and action rows over the complete current Fatigue × Stress Load/effect-state × Carried Load × upper-limb injury/state × posture × device × access-mode tuple, with declared precedence; Fatigue, Stress, and injury effects apply only when their exact rows are `Enabled`.

**REQ-THROWN-DEVICE-STRESS-001** — Stress Load MUST change throw-preparation duration exactly when and as the applicable Stress Profile effect is `Enabled`, MUST NOT change it when `Disabled` or unenumerated, and MUST NOT introduce artificial random error into the release direction selected by the Trainee.

**REQ-FIRE-IGNITION-001** — Every exposure of an explicitly combustible object or material to an admitted heat, flame, projectile, explosion, or device source MUST select and apply exactly one exhaustive ignition outcome, including `No ignition`, from its exact admitted Fire, Environment State, and Physical Effects rows.

**REQ-FIRE-SHARED-001** — Fire position, extent, and state MUST be part of the shared canonical simulation state.

**REQ-FIRE-EFFECT-001** — Each Fire state MUST emit exactly the light, heat, Obscurant, Acoustic, and `No output` fields required by its admitted Fire Profile outcome tuple and downstream Lighting, Obscurant, Acoustic, and Physical Effects rows; effect fields MAY coexist, while `No output` MUST be true exactly when every other output field is empty.

**REQ-FIRE-SPREAD-001** — Fire MUST propagate between explicitly profiled combustible objects or materials exactly when the applicable closed source × material/object × heat-transfer × geometry × environment × Fire-state/fuel row selects `Ignited`, and MUST NOT propagate for `No ignition` or unprofiled material.

**REQ-FIRE-EXPOSURE-001** — Every Fire exposure of a Trainee, equipment item, ammunition, explosive, or environment object MUST apply exactly the combined output tuple selected by its exact admitted Fire, Physical Effects, Injury Outcome, equipment, ammunition, explosive, and Environment rows and MUST NOT apply an unenumerated effect.

**REQ-FIRE-LIFECYCLE-001** — Fire intensity, extent, state, and remaining fuel MUST evolve using Session Authority simulated time and the exact admitted fuel-conservation, heat-transfer, geometry, environment, aggregation, same-event precedence, output, and tolerance rules in the Fire Profile and Environment State Catalogue.

**REQ-FIRE-EXTINCTION-001** — Fire MUST transition through the exact diminishing and terminal extinguished states when its admitted fuel and environmental sustain predicate becomes false and MUST NOT remain active after the terminal transition.

**CONSTRAINT-FIRE-SUPPRESSION-001** — The initial baseline MUST NOT provide firefighting equipment or an explicit Trainee fire-suppression action.

**CONSTRAINT-FIRE-SCOPE-001** — The initial baseline MUST NOT infer unrestricted building-scale fire propagation through materials that lack explicit combustible and ignition profiles.

**REFERENCE-FIRE-001** — The reference Scenario MUST contain a profiled combustible setup and a valid represented ignition source through which ignition, localized propagation, and eventual extinction can be exercised.

**REFERENCE-FIRE-002** — Starting or interacting with that Fire MUST NOT be required to complete or prevent the Personnel Recovery objective.

**REFERENCE-PORTABLE-LIGHT-001** — Each Team in the reference Scenario MUST have at least one available Loadout that includes a portable light.

**REFERENCE-PORTABLE-LIGHT-002** — The reference Scenario MAY assign different portable-light quantities to the two Teams.

**REQ-ENVIRONMENT-MOVABLE-001** — An environment object classified as movable MUST respond to every applicable Trainee contact, Ballistic Projectile impact, Blast Overpressure, gravity, collision, and other force exactly according to its admitted mass, material, structure, Physical Profile, and Environment row.

**REQ-ENVIRONMENT-MOVABLE-002** — A movable object's position, orientation, velocity, and damage state MUST be part of the shared canonical simulation state and persist for the remainder of the Training Session.

**REQ-ENVIRONMENT-MOVABLE-003** — A moved object's current represented geometry and material state MUST affect movement, visibility, Ballistic Projectile interaction, Acoustic Propagation, and cover where applicable.

**REQ-ENVIRONMENT-MANIPULATION-001** — For every movable object × manipulation mode × object/current-Trainee-state tuple, the Environment Coverage Catalogue MUST classify push, pull, lift, carry, and drag `Enabled` with complete resource, geometry, grasp, mass, dimension, posture, Carried Load, Fatigue, injury, Functional State, and output conditions or `Disabled` with justification.

**REQ-ENVIRONMENT-MANIPULATION-002** — Deliberate manipulation MUST require an explicit interaction at a physically reachable, unobstructed grasp or contact point and MUST reserve the number of represented hands required by the object's profile.

**REQ-ENVIRONMENT-MANIPULATION-003** — Enabled manipulation modes, final movement rate, sustainable duration, and physical limits MUST equal the exact bounded outputs and tolerances from admitted object, Physical, Locomotion, Fatigue, Stress, Injury, Action Physical Condition, and Action Compatibility rows over the complete mass × dimensions × Carried Load × Fatigue × Stress Load/effect-state × injury/state × posture × hand/resource tuple with declared precedence; Fatigue, Stress, and injury effects apply only when `Enabled`.

**REQ-ENVIRONMENT-MANIPULATION-IDENTITY-001** — Acquiring, holding, carrying, dragging, or releasing a movable object MUST preserve its stable identity and exact one Item Disposition, use atomic transitions, reserve the required hand Carry Positions, and include the object and its contents exactly once in Carried Load when carried.

**REQ-ENVIRONMENT-MANIPULATION-CONTENTION-001** — When concurrent deliberate manipulation requests target the same object, the Session Authority MUST evaluate them using the exact applicable Environment State Catalogue total order, accept at most the first complete eligible request, reject every conflicting request without state change, and preserve the single-manipulator constraint.

**REQ-ENVIRONMENT-MANIPULATION-004** — An object held in the hands MUST NOT occupy a stowed Carry Position unless it is explicitly compatible with that position and has been stowed there.

**REQ-ENVIRONMENT-MANIPULATION-005** — Deliberate cooperative manipulation of one environment object by multiple Trainees MUST NOT be supported in the initial baseline.

**REQ-ENVIRONMENT-MANIPULATION-006** — When an object's profile and current conditions place it beyond the manipulation capacity of one otherwise eligible Trainee, deliberate push, pull, lift, carry, and drag interactions MUST remain unavailable regardless of how many Trainees are nearby.

**REQ-ENVIRONMENT-MANIPULATION-007** — Prohibiting deliberate manipulation MUST NOT make a heavy movable object immune to valid external physical forces.

**REFERENCE-MOVABLE-OBJECT-001** — The reference Map MUST include at least one environment object whose exact admitted Environment and Physical Profile rows classify push, pull, lift, and carry `Enabled` for one `Capable` Trainee under their declared reference conditions.

**REQ-ENVIRONMENT-MANIPULATION-VR-001** — In Virtual-Reality Mode, a Trainee MUST grasp and manipulate an eligible environment object through tracked-controller motion at a valid represented grasp point.

**REQ-ENVIRONMENT-MANIPULATION-DESKTOP-001** — In Desktop Mode, a Trainee MUST manipulate an eligible environment object by holding an explicit interaction command and using mouse and locomotion input to orient and displace it.

**REQ-ENVIRONMENT-MANIPULATION-RELEASE-001** — Releasing the active manipulation input MUST release the environment object at its current authoritative position and orientation and clamp inherited linear and angular velocity to the exact admitted ordinary-drop envelope before free physical motion continues.

**REQ-ENVIRONMENT-THROW-BOUNDARY-001** — Every environment-object row MUST classify deliberate `Throw` as `Disabled`, define a finite ordinary-drop linear/angular velocity envelope, and prohibit release from producing velocity outside that envelope or adding a commanded impulse; external forces applied after release remain governed by ordinary physical rules.

**REQ-ENVIRONMENT-MANIPULATION-PARITY-001** — Both modes MUST operate on the same authoritative object state and enforce the same profile, mass, hand, fatigue, load, posture, and injury limitations.

**REQ-ENVIRONMENT-MANIPULATION-TACTICAL-ADEQUACY-001** — Before manipulation behavior is accepted, at least two independent in-scope Representative Evaluators MUST confirm under a pre-approved protocol that VR and Desktop manipulation preserve credible and operationally adequate handling for every applicable reference-object and manipulation class, and the project owner MUST approve the exact protocol, catalogue, and profile versions before observation.

**REQ-ENVIRONMENT-DESTRUCTIBLE-INVENTORY-001** — The Environment Coverage Catalogue MUST contain a closed inventory of every destructible Scenario object and surface, its localization granularity, exact geometry/material/collision representation, applicable projectile/explosion exposures, transformation rows, and downstream visibility, cover, projectile, movement, Acoustic and Lighting outputs.

**REQ-ENVIRONMENT-DAMAGE-001** — Every projectile or explosion exposure of a destructible object or surface MUST select and atomically apply exactly one exhaustive localized outcome, including `No effect`, `Perforated`, `Broken`, or `Removed`, from its exact admitted Environment State, Physical Effects, and transformation rows within declared geometry and material tolerances.

**REQ-ENVIRONMENT-DAMAGE-002** — Each localized-damage state MUST produce exactly the subsequent geometry, material, collision, visibility, cover, Ballistic Projectile, Acoustic Propagation, Lighting, and movement outputs classified applicable by its admitted row and MUST NOT rely on an unstated relevance decision.

**REQ-MAP-DAMAGE-LIFETIME-001** — Localized Map damage MUST remain for the rest of the current Training Session.

**REQ-MAP-RESET-001** — A new Session Authority process MUST initialize its Map to the initial state defined by its Scenario before its Training Session can start.

## Reference Personnel Recovery Scenario

**REFERENCE-MAP-ACCEPTANCE-PROFILE-001** — Before reference Map admission, the project owner MUST approve one exact versioned acceptance profile defining the playable horizontal boundary, dimensional tolerance, urban-content inventory, vertical-level and route-accessibility predicates, Lighting Profile class thresholds, and required evidence; at least two independent in-scope Representative Evaluators MUST confirm under a pre-approved protocol that the admitted content is recognizably urban and adequate for the reference training use.

**REFERENCE-MAP-001** — The reference Scenario MUST use a Map satisfying the exact admitted reference Map acceptance profile, including its urban-content and connected indoor/outdoor-space criteria.

**REFERENCE-MAP-SCALE-001** — The complete playable area MUST fit within a Map-local horizontal bounding rectangle no greater than 250 metres on either axis, within the acceptance profile's measurement tolerance.

**REFERENCE-MAP-VERTICALITY-001** — The Map MUST provide exactly identified ground, first-upper, and second-upper accessible level classes, including one building containing all three; each level MUST have at least one continuous route that a `Capable` Trainee under the acceptance profile's reference Locomotion tuple can traverse without a deferred locomotion action.

**REFERENCE-SCENARIO-LIGHTING-001** — The reference Scenario MUST use fixed daytime exterior lighting.

**REFERENCE-MAP-LIGHTING-001** — The reference Map MUST contain at least one admitted region in each `Outdoor`, `Illuminated interior`, `Dark interior`, and pairwise transition class, satisfying the exact Lighting Profile measurement domain, metric, threshold, and tolerance in the reference Map acceptance profile.

**REFERENCE-SCENARIO-MISSION-001** — The reference Scenario MUST be a Personnel Recovery mission.

**REFERENCE-SCENARIO-MISSION-002** — One Team MUST locate and recover a Recovery Proxy and escort it to extraction while the other Team attempts to prevent recovery.

**REFERENCE-RECOVERY-PLACEMENT-001** — The reference Scenario MUST reference at least two stable Map-owned Recovery Proxy spatial-anchor identifiers and versions whose canonical transforms and proxy collision volumes are contained in referenced Map-owned placement regions, do not intersect solid geometry at initialization within tolerance, and are classified valid by the Environment Coverage Catalogue.

**REQ-RECOVERY-PLACEMENT-001** — Exactly one of the positions defined by the Scenario MUST be selected for each Training Session before either Team receives its briefing.

**REQ-RECOVERY-PLACEMENT-DISTRIBUTION-001** — Before Scenario admission, the project owner MUST approve an exact versioned uniform-selection distribution and random-generator/configuration record over the complete current valid-position set, including analytic and finite statistical acceptance procedures and tolerances.

**REQ-RECOVERY-PLACEMENT-002** — The position MUST be selected automatically by the admitted distribution, with each of the `N` current valid positions having exact declared probability `1/N` within the approved acceptance tolerance.

**REQ-RECOVERY-PLACEMENT-003** — Each Training Session selection MUST be sampled with replacement independently of preceding position selections, so the immediately preceding position has the same declared `1/N` probability as every other current valid position; a deterministic position rotation based on session history MUST NOT be used.

**REQ-RECOVERY-PROXY-001** — The initial Scenario MUST represent the Recovery Subject with an inanimate Recovery Proxy.

**REQ-RECOVERY-PROXY-DAMAGE-001** — The Recovery Proxy MUST NOT be damaged, destroyed, or made unrecoverable by Scenario effects.

**REQ-RECOVERY-PROXY-STATE-001** — The Recovery Proxy MUST have one stable item identity and exact admitted Scenario, Carrying, Action, Locomotion, Environment State and Item Disposition rows defining its hands/resources, compatibility, load contribution, position, uncarried/carried state, pickup, carry and drop transitions.

**REQ-RECOVERY-PROXY-ELIGIBILITY-001** — A recovering-Team `Capable` or `Impaired` Trainee, including a former Recovery Carrier, is eligible to pick up the Proxy exactly when the current Action Compatibility, Functional State, hand/resource, reach, obstruction, Carrying and Proxy-state predicates pass; no other Trainee is eligible.

**REQ-RECOVERY-PROXY-CONTENTION-001** — Concurrent eligible pickup requests for the uncarried Recovery Proxy MUST be evaluated using the exact applicable Environment State Catalogue total order, accept at most the first complete eligible request, and reject every later or ineligible request without changing Proxy or Trainee state.

**REQ-RECOVERY-PROXY-DROP-COVERAGE-001** — The exact admitted Proxy placement-search profile MUST define a finite ordered search domain for every reachable carrier transform and body/environment state and MUST prove at least one collision-valid result within its distance and orientation limits for every such input; a missing valid result MUST block Scenario admission.

**REQ-RECOVERY-CARRY-001** — No more than one Trainee MUST carry the Recovery Proxy at a time.

**REQ-RECOVERY-CARRY-002** — The Recovery Carrier MUST be able to drop it voluntarily through its exact admitted action and Proxy state-transition row when current action-resource conditions permit.

**REQ-RECOVERY-CARRY-003** — Any Trainee satisfying `REQ-RECOVERY-PROXY-ELIGIBILITY-001` MUST be able to pick up a dropped Recovery Proxy through the atomic pickup transition.

**REQ-RECOVERY-CARRIER-001** — A Recovery Carrier MUST NOT use a weapon classified `Primary` by the exact admitted Loadout, Weapon Behavior, and Action rows while carrying the Recovery Proxy.

**REQ-RECOVERY-CARRIER-002** — Recovery Carrier status alone MUST NOT disable an assigned item classified as a one-handed `Secondary` weapon, Team Radio, or navigation equipment; actual action availability MUST remain exactly governed by current equipment function and accessibility, limb, hand/resource, action compatibility, profile, and state prerequisites.

**REQ-RECOVERY-CARRIER-003** — While carrying the Recovery Proxy, a Recovery Carrier MUST NOT use grenades, explosives, or another action whose exact admitted Action row requires both represented hands.

**REQ-RECOVERY-CARRIER-004** — The admitted Locomotion Profile MUST define Recovery Carrier maximum movement speed as exactly 70% of the reference output for an otherwise identical posture, Fatigue, injury/Functional State, environment and non-Proxy carried-equipment tuple with Recovery Carrier status false and Proxy load excluded; the resulting 70% value is the final carrier-speed output and MUST NOT receive a second Proxy-load or carrier reduction.

**REQ-RECOVERY-DROP-001** — In the same canonical transition that makes the Recovery Carrier `Incapacitated` or `Fatal`, the Proxy MUST leave the carrier atomically and enter the Scenario at the first collision-valid transform selected by the Proxy profile's deterministic ordered placement search around the carrier's current authoritative transform, within its declared distance and orientation tolerance.

**REQ-RECOVERY-DROP-002** — A dropped Recovery Proxy MUST retain its authoritative Scenario Item Disposition and exact transform until an eligible atomic pickup transition; no other interaction or physical effect may reposition it.

**REQ-RECOVERY-DEFENCE-001** — The opposing Team MUST NOT pick up, carry, or deliberately reposition the Recovery Proxy.

**REQ-RECOVERY-EXTRACTION-GEOMETRY-001** — The Scenario MUST reference one exact Map-owned extraction-region identifier and version and define mission containment semantics and boundary tolerance requiring the Proxy's complete admitted collision volume to be inside that canonical geometry; Scenario data MUST NOT redefine the region geometry.

**REQ-RECOVERY-EXTRACTION-001** — The recovering Team MUST NOT complete its objective unless the complete Recovery Proxy volume satisfies the exact extraction containment predicate.

**REQ-RECOVERY-EXTRACTION-002** — The Session Authority MUST accumulate exactly five seconds of continuous simulated time while the containment predicate remains true before accepting success.

**REQ-RECOVERY-EXTRACTION-003** — A false containment predicate before five seconds MUST reset extraction progress atomically to zero in the same canonical transition.

**REQ-RECOVERY-EXTRACTION-ORDER-001** — When containment becomes false at the same simulated time that progress reaches five seconds, exit and reset MUST take precedence and success MUST NOT be accepted.

**REQ-RECOVERY-EXTRACTION-004** — Opposing-Team presence MUST NOT, by itself, suspend extraction progress.

**REFERENCE-SCENARIO-DURATION-001** — The reference Scenario MUST define 20 minutes of active simulation.

**REQ-SCENARIO-TIMEOUT-001** — Timeout before extraction MUST end the Scenario normally with `Personnel Recovery failed` and `Personnel Recovery prevented` results.

**REQ-SCENARIO-RECOVERY-FAILURE-001** — If every recovering-Team Trainee is `Incapacitated` or `Fatal` in one canonical transition, the Scenario MUST end normally with the same failure and prevention results, subject to the Scenario's admitted same-transition completion precedence.

**REQ-SCENARIO-OPPOSITION-LOSS-001** — Incapacitating the entire opposing Team MUST NOT complete Personnel Recovery; extraction remains required.

## Content authoring and admission

**REQ-PROFILE-RECORD-001** — Every candidate Approved Profile MUST record a stable identifier, version, scope, reference conditions, data values, units, tolerances, and limits of applicability.

**REQ-PROFILE-TRACEABILITY-001** — Every candidate Approved Profile MUST retain traceability from each normative value or behavior to the evidence supporting it.

**REQ-PROFILE-VALIDATION-001** — Before a profile can become an Approved Profile, every normative value and represented behavior, its derivation from supporting evidence, its reference conditions, tolerances, and stated applicability MUST be validated by at least one Qualified Specialist whose approved technical scope covers that item.

**REQ-PROFILE-VALIDATION-COVERAGE-001** — A candidate profile MUST retain an item-level validation record that enumerates every normative value and represented behavior and traces each item to its supporting evidence, derivation, applicable Qualified Specialist, qualification version, validation result, and date.

**REQ-PROFILE-VALIDATION-COVERAGE-002** — Multiple Qualified Specialists MAY contribute to one candidate profile, but the candidate MUST NOT be admitted until every enumerated item has an in-scope specialist-validation result of `Pass`; any `Fail`, `Blocked`, missing, or non-affirmative result MUST prevent admission.

**REQ-PROFILE-APPROVAL-001** — The project owner MUST grant final approval to the exact validated profile version before it becomes an Approved Profile.

**REQ-PROFILE-ADMISSION-001** — The Training Simulation and its verification procedures MUST use only the exact admitted version of an Approved Profile as normative represented behavior or profile-based acceptance evidence.

**REQ-PROFILE-PROVISIONAL-001** — Draft, provisional, unvalidated, or unapproved profile data MUST NOT be treated as normative behavior or acceptance evidence.

**REQ-PROFILE-CHANGE-001** — A change to Approved Profile values, represented behavior, supporting evidence, reference conditions, tolerances, scope, or limits of applicability MUST create a new candidate profile version.

**REQ-PROFILE-CHANGE-002** — A changed candidate profile version MUST complete Qualified Specialist validation and project-owner approval before admission as an Approved Profile.

**REQ-PROFILE-CHANGE-003** — A newly admitted profile version MUST NOT overwrite or destroy a preceding version or its approval and evidence history.

**REQ-PROFILE-ADMIN-CORRECTION-001** — A correction MAY retain the existing profile version only when recorded impact analysis demonstrates that it changes no normative value, behavior, evidence, reference condition, tolerance, scope, applicability limit, or interpretation and the project owner approves the correction as administrative.

**REQ-PROFILE-CHANGE-HISTORY-001** — Every profile correction and version transition MUST remain in a versioned change history that identifies the change, reason, author, date, impact disposition, and approval.

**REQ-SPECIALIST-QUALIFICATION-001** — Before validating an Approved Profile candidate, each Qualified Specialist MUST have a recorded qualification identifying the person, explicit technical scope, supporting evidence of relevant education, professional or operational experience, or technical work, and project-owner approval.

**REQ-SPECIALIST-QUALIFICATION-002** — Qualification as a Qualified Specialist MUST NOT require one universal credential applicable to every equipment type or physical phenomenon.

**REQ-SPECIALIST-SCOPE-001** — A Qualified Specialist MUST validate only profile content that falls within that specialist's recorded and approved technical scope.

**REQ-SPECIALIST-EVIDENCE-001** — The qualification record and supporting competence evidence applicable at validation time MUST remain traceable from every profile validation performed by that Qualified Specialist.

**REQ-SPECIALIST-CRITERIA-001** — Before candidates are considered or receive profile content for validation, a scope-specific qualification procedure MUST define the required competence evidence, minimum depth, any applicable recency conditions or an explicit determination that recency is not applicable, and deterministic acceptance criteria.

**REQ-SPECIALIST-CRITERIA-002** — The project owner MUST approve the exact qualification-procedure version before it is used to assess a candidate.

**REQ-SPECIALIST-ASSESSMENT-001** — Each specialist qualification MUST record the candidate's evidence against every criterion, the resulting decision, the approved technical scope and validity conditions, the procedure version, and project-owner approval before that specialist performs validation.

**CONSTRAINT-MAP-AUTHORING-001** — Blender MUST be the canonical graphical authoring environment for Map geometry, materials, lighting, collision definitions, and versioned spatial anchor and region identities with their transforms and geometry.

**CONSTRAINT-SCENARIO-SEPARATION-001** — Team configuration, mission rules, objectives, equipment, duration, completion conditions, results, and mission semantics MUST remain Scenario data rather than Map behavior; Scenario data MUST reference Map-owned spatial anchor or region identifiers and MAY add Scenario parameters but MUST NOT duplicate or redefine their canonical geometry.

**REQ-MAP-SCENARIO-REUSE-001** — One Blender-authored Map MUST be reusable by multiple Scenarios without duplicating canonical Map content.

**CONSTRAINT-RUNTIME-BLENDER-001** — Clients and Session Authority MUST operate without Blender installed or running.

**REQ-CONTENT-PROCESSING-GATE-001** — Before execution, the project owner MUST approve an exact versioned content-processing gate defining every validation criterion, procedure, input and output schema, tool/configuration constraint, disposition rule, and admission effect.

**REQ-CONTENT-PROCESSING-RECORD-001** — Every content-processing execution MUST produce a versioned record identifying the exact approved gate version; Scenario and every canonical source, Approved Profile, catalogue, dependency and version; processing pipeline, tool and configuration versions; Runtime Content Release and role-pack identities, roles, runtime content contracts, integrity hashes, pair binding and signatures; source-to-output mappings; criterion-level validation results; executor; and date.

**REQ-CONTENT-PROCESSING-001** — One exact Scenario and its complete canonical-source closure MUST complete the approved processing pipeline and every identity, dependency, integrity, traceability and validation gate before the Content Cooker can sign or publish its Runtime Content Release.

**REQ-CONTENT-TRACEABILITY-001** — Every deployment-ready runtime output item in either role pack MUST retain an exact mapping through the processing record to its canonical source item and version; every Map-derived output MUST retain the exact mapping to its canonical Blender source item and version.

**REQ-CONTENT-PROCESSING-ADMISSION-001** — The Content Cooker MUST sign a Runtime Content Release only after the exact pre-approved gate produces `Pass` for every required criterion and the complete processing record and role-pack pair are available; any missing, failed, blocked, stale, uncertain, wrong-gate, incompatible or corrupt input, dependency, mapping, output, integrity result or criterion MUST fail the complete job and prevent publication of either pack.

**REQ-CONTENT-RELEASE-001** — Every Runtime Content Release MUST identify exactly one Scenario version and contain exactly one immutable signed Authority Pack and one immutable signed Client Pack under one common release identity.

**REQ-CONTENT-PACK-ROLE-001** — The Authority Pack MUST contain the complete closed runtime content required by the Session Authority for that Scenario, the Client Pack MUST contain the complete closed runtime content required by Prediction and Presentation, and neither runtime MUST require the other role's pack or source-format data.

**REQ-CONTENT-PAIR-001** — Each role pack MUST bind the exact common Runtime Content Release identity, Scenario, role, runtime content contract, its own identity and integrity hash, and the identity and integrity hash of its counterpart.

**REQ-CONTENT-PAIR-ATOMIC-001** — The Content Cooker MUST publish a Runtime Content Release only after both complete role packs, their reciprocal bindings, processing record and signatures succeed; interruption, resource failure or process loss before that point MUST expose no usable successor release and MUST leave every preceding release unchanged.

**REQ-CONTENT-SIGNING-001** — The Content Cooker MUST sign both role packs using its configured content-signing private key after the complete job passes, and no unsigned or partially signed pair MAY become a usable Runtime Content Release.

**REQ-CONTENT-TRUST-001** — Each runtime MUST receive a versioned Content Signing Trust Reference independently of its pack, MUST accept no pack-contained or network-provided trust root, and MUST validate that the signer is authorized for the pack's exact role and runtime content contract.

**REQ-CONTENT-COMPATIBILITY-001** — A valid signature under the exact Content Signing Trust Reference MUST be the sole admitted compatibility assertion for a role pack; runtime content-contract ranges, migration, translation, version negotiation and inferred compatibility MUST NOT be used.

**CONSTRAINT-CONTENT-DISTRIBUTION-001** — The exact Authority Pack or Client Pack and applicable Content Signing Trust Reference MUST be present in the corresponding host filesystem before its process starts; the Session Authority MUST NOT distribute, download, patch or stream content to a client.

**REQ-CONTENT-MISSING-001** — A missing Authority Pack, Client Pack or Content Signing Trust Reference MUST fail the corresponding process startup before readiness, connection or Admission.

**REQ-CONTENT-IDENTITY-001** — After authenticating the Session Authority and before presenting client identity evidence or creating an Admission, the client and authority MUST confirm an exact match of Runtime Content Release, Scenario, role-pack identities and integrity hashes.

**REQ-CONTENT-MISMATCH-001** — A content mismatch MUST terminate the connection attempt before Admission, identify the incompatible role pack and release using non-sensitive identifiers, and MUST NOT create Preparation, Ready, roster, Team Position or Loadout state.

**REQ-CONTENT-VERSION-001** — A runtime MUST load only a role pack whose signature is valid under a Content Signing Trust Reference entry authorizing its exact role and runtime content contract.

**REQ-CONTENT-VERSION-002** — Rejection MUST distinguish missing content, invalid signature, unauthorized signer for the role or runtime content contract, broken pair binding, malformed structure, integrity failure and materialization failure and MUST report the applicable non-sensitive pack, release, Scenario and trust-reference identities.

**REQ-CONTENT-STARTUP-001** — Each Session Authority and Trainee client process MUST receive exactly one explicit role-pack path through immutable launch configuration and MUST NOT scan for, select, negotiate or fall back to another pack.

**REQ-CONTENT-ACTIVATION-001** — Before the Session Authority publishes readiness or accepts a connection, and before a Trainee client initiates a connection, the process MUST validate and completely materialize its exact role pack and atomically publish one immutable identified content view or terminate startup with a non-zero process result.

**REQ-CONTENT-IMMUTABILITY-001** — After activation, a process MUST use only its immutable materialized content view and MUST NOT reread, poll, patch, stream, replace or derive runtime behavior from later filesystem or Content Signing Trust Reference changes.

**REQ-CONTENT-OVERRIDE-001** — Runtime launch configuration and live state MUST NOT override a normative Scenario, Map, Approved Profile, catalogue or other content value in the activated Runtime Content Release.

**REQ-CONTENT-ROLLBACK-001** — A preceding Runtime Content Release MAY be selected explicitly for a new process only while it remains approved and its signature remains authorized for the exact role and runtime content contract; automatic rollback or fallback MUST NOT occur.

**REQ-CONTENT-RETENTION-001** — Runtime processes MUST NOT create, mutate or delete published role packs; external deployment policy MUST own their filesystem availability, retention and removal, and this baseline MUST NOT infer a retention duration or cache bound.

## Platform and deployment constraints

**REQ-PLATFORM-ACCEPTANCE-PROFILE-001** — Accepted Desktop, PC-connected Virtual-Reality, and Session Authority configurations MUST each reference one exact approved Reference Hardware Profile version defining the fixed hardware and platform fields required for reproducible acceptance and the variable configuration fields that each acceptance execution must record as evidence.

**REQ-PLATFORM-ACCEPTANCE-PROFILE-002** — Each role/mode MUST execute its complete applicable acceptance procedure on its exact Reference Hardware Profile and deployment configuration before that profile is admitted; inspection alone MUST NOT establish execution acceptance.

**CONSTRAINT-CLIENT-OS-001** — Desktop Mode and PC-connected Virtual-Reality Mode clients MUST execute on the exact 64-bit Windows 11 edition, build, and driver set defined by their admitted Reference Hardware Profiles; variable operating-system configuration MUST be recorded as acceptance-run evidence.

**CONSTRAINT-AUTHORITY-HOST-001** — The Session Authority MUST execute on a dedicated machine in the same LAN as clients.

**CONSTRAINT-AUTHORITY-HOST-002** — That machine MUST NOT host a local Trainee or gameplay client.

**CONSTRAINT-AUTHORITY-OS-001** — The dedicated machine MUST execute the exact Debian 13 amd64 release and kernel defined by its admitted Reference Hardware Profile; variable operating-system configuration and driver state MUST be recorded as acceptance-run evidence.

**CONSTRAINT-PLATFORM-MATRIX-001** — The supported initial matrix is Windows clients and Linux Session Authority.

**PREFERENCE-PLATFORM-PARITY-001** — Shared Simulation Engine code and technologies SHOULD preserve Platform Parity.

**EXCEPTION-PLATFORM-PARITY-001** — A platform-specific technology MAY be admitted only through a prospective versioned exception record identifying the exact validated requirement, decision scope, finite considered-alternative inventory, objective adequacy criteria, evidence and result for every alternative, selected technology, date, and project-owner approval before use.

**CONSTRAINT-NETWORK-MEDIUM-001** — Accepted deployment MUST connect all stations and the Session Authority through wired 1 Gbit/s Ethernet on a LAN.

**CONSTRAINT-AUDIO-DEVICE-001** — Every accepted Trainee station MUST use stereo headphones with a microphone, or integrated VR hardware whose admitted Reference Hardware Profile demonstrates the same required two-channel spatial output, microphone input, simultaneous input/output routing, level domain, channel isolation, and applicable acoustic-test tolerances.

## Project and documentation constraints

**CONSTRAINT-LANGUAGE-001** — English MUST be canonical for persistent requirements, design, architecture, ADRs, glossary terms, code identifiers, and code comments.

**CONSTRAINT-CPP-VERSION-001** — All first-party production Training Simulation and Simulation Engine source code and libraries MUST target standard C++23 and MUST NOT require a later language version or non-standard compiler extension; repository automation, build, content-pipeline, verification, and maintenance scripts MAY use another language.

**CONSTRAINT-CPP-STYLE-001** — Before first-party C++ source is admitted, the project owner MUST approve one exact Project C++ Style Profile based substantially on the [Google C++ Style Guide](https://google.github.io/styleguide/cppguide.html) and maintained as a self-contained repository artifact; it MUST enumerate every adopted rule, explicit deviation, applicability boundary, automatic check, and non-automatable review obligation without requiring the live external document to determine compliance.

**CONSTRAINT-CPP-FORMAT-001** — One repository-owned, versioned `clang-format` configuration MUST be authoritative for every formatting rule it can express, and the automated acceptance gate MUST reject any covered C++ file for which applying the pinned formatter would produce a change.

**CONSTRAINT-CPP-LINT-001** — One repository-owned, versioned `clang-tidy` configuration and pinned compiler-warning profiles for every supported development compiler MUST map all automatically enforceable Project C++ Style Profile rules and MUST cause the automated acceptance gate to fail on any admitted lint or compiler diagnostic.

**CONSTRAINT-CPP-TOOLCHAIN-001** — The candidate baseline MUST pin the exact formatter, linter, compiler, configuration, and invocation versions used by local checks and automated acceptance, and the same input and configuration MUST produce the same pass/fail result in both environments.

**PROCESS-CPP-STYLE-EXCEPTION-001** — A style or automatic-check exception MUST identify the exact rule, smallest affected source scope, technical rationale, alternative considered, owner, approval, creation date, and mandatory review or expiry condition; an inline suppression without such a current exception record MUST fail acceptance.

**PROCESS-CPP-STYLE-GATE-001** — Every change containing covered C++ source MUST pass the pinned formatting, lint, compiler-warning, and exception-validity checks before integration, with zero waived or ignored diagnostic unless matched to a current approved exception record.

**CONSTRAINT-PYTHON-STYLE-001** — Every first-party Python script and module MUST comply with one exact project-owner-approved Project Python Style Profile based substantially on the [Google Python Style Guide](https://google.github.io/styleguide/pyguide.html) and maintained as a self-contained repository artifact; it MUST enumerate every adopted language and style rule, explicit deviation, applicability boundary, automatic check, and non-automatable review obligation without requiring the live external document to determine compliance.

**CONSTRAINT-PYTHON-LINT-001** — One repository-owned, versioned `pylint` configuration MUST map every automatically enforceable Project Python Style Profile rule and MUST cause the automated acceptance gate to fail on any admitted diagnostic.

**CONSTRAINT-PYTHON-TOOLCHAIN-001** — The candidate baseline MUST pin the exact Python interpreter, linter, any formatter or type checker, every configuration, and each invocation used by local checks and automated acceptance, and the same input and configuration MUST produce the same pass/fail result in both environments.

**PROCESS-PYTHON-STYLE-EXCEPTION-001** — A Python style, lint, formatting, or type-check exception MUST identify the exact rule, smallest affected source scope, technical rationale, alternative considered, owner, approval, creation date, and mandatory review or expiry condition; an inline suppression without such a current record and local explanatory comment MUST fail acceptance.

**PROCESS-PYTHON-STYLE-GATE-001** — Every change containing covered Python source MUST pass syntax validation, the pinned linter, every admitted formatter or type checker, and exception-validity checks before integration, with zero waived or ignored diagnostic unless matched to a current approved exception record.

**CONSTRAINT-COMMIT-MESSAGE-001** — Every commit integrated into the repository MUST comply with one exact project-owner-approved Conventional Commit Profile based on [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/); the profile MUST be self-contained and MUST NOT require the live external specification to determine compliance.

**CONSTRAINT-COMMIT-TYPE-001** — The initial allowed commit-type set MUST contain exactly `build`, `chore`, `ci`, `docs`, `feat`, `fix`, `perf`, `refactor`, `revert`, `style`, and `test`; types and optional scopes MUST be lowercase, and a scope MUST use only lowercase ASCII letters, digits, and internal hyphens.

**CONSTRAINT-COMMIT-STRUCTURE-001** — The first line MUST have exactly `<type>[optional scope][optional !]: <description>`; the description MUST be non-empty, a body or footer MUST begin after one blank line, and a breaking change MUST be marked by `!` immediately before `:` or an exact `BREAKING CHANGE: <description>` footer.

**PROCESS-COMMIT-MESSAGE-GATE-001** — Local commit creation and remote integration MUST reject a commit whose complete message fails the current Conventional Commit Profile; bypassing a local hook MUST NOT bypass the remote gate.

**PROCESS-COMMIT-HISTORY-001** — The protected `main` branch MUST use an integration mode that does not introduce an automatically generated non-conforming merge message; every resulting commit, including the initial commit and a squash or rebase result, MUST pass the message gate independently.

**CONSTRAINT-DOCUMENTATION-001** — Each persistent document MUST have one stated purpose and one canonical owner for its information.

**CONSTRAINT-DOCUMENTATION-002** — Documents MUST reference canonical terms, requirements, and decisions rather than duplicate them.

**PROCESS-DOCUMENTATION-INVENTORY-001** — A versioned Documentation Inventory MUST enumerate every retained project document from the complete authoritative document repositories and classify it as `Persistent` or `Non-persistent`, Markdown or another format, generated or manually maintained, and canonical or non-canonical for each mapped information item.

**PROCESS-DOCUMENTATION-INVENTORY-002** — The project owner MUST approve the exact reconciled Documentation Inventory version; a missing, stale, uncertain, multiply owned, or unclassified persistent document or canonical information item MUST block documentation acceptance.

**PROCESS-DOCUMENTATION-INVENTORY-003** — Every persistent document MUST state title, purpose, scope, intended readers, status, prerequisites, and exactly one canonical information owner and MUST map each normative information item to one canonical stable identifier and owning document.

**PROCESS-DOCUMENTATION-INVENTORY-004** — A non-canonical document MAY quote canonical information only when the quotation is explicitly marked non-authoritative and links to the exact canonical stable identifier and document version; an unmarked restatement that can independently change normative meaning is prohibited duplication.

**PROCESS-DOCUMENTATION-INVENTORY-005** — For every generated Markdown document, each second-level heading other than `Table of contents` is a principal section and MUST have exactly one working Table-of-Contents link; headings below second level MAY be included but are not required by this rule.

**PROCESS-DOCUMENTATION-INVENTORY-006** — Adding, removing, renaming, reclassifying, or changing ownership of a document or canonical information item MUST create a new Documentation Inventory version and trigger documentation and evidence-impact analysis.

**CONSTRAINT-DOCUMENTATION-TOC-001** — Every generated Markdown document MUST contain a Table of Contents with links to its principal sections.

**CONSTRAINT-DOCUMENT-CONTROL-001** — Each document MUST state purpose, scope, intended readers, status, and prerequisites.

Ambiguity review, verification responsibility, and acceptance are governed by the canonical [Training Simulation Verification Plan](training-simulation-verification-plan.md).

## Non-goals

- **NON-GOAL-ACCOUNT-001** — Training-Simulation-owned persistent accounts or authoritative Trainee Identity or Client Device Identity lifecycle administration.
- **NON-GOAL-AUTH-AUDIT-INTERFACE-001** — An in-product AUTH audit administration, consultation, search, or export interface.
- **NON-GOAL-AUTH-CREDENTIAL-ADMINISTRATION-001** — In-product identity or authenticator issuance, enrollment, replacement, recovery, reset, revocation, suspension, or unlocking.
- **NON-GOAL-AUTH-RISK-ENGINE-001** — Adaptive, behavioral, location-based, reputation-based, or risk-scored authentication and authorization.
- **NON-GOAL-AUTH-CROSS-AUTHORITY-SESSION-001** — Detection or prevention of concurrent use of one identity across different Session Authorities.
- **NON-GOAL-MEDICAL-001** — First aid, stabilization, treatment, or medical recovery.
- **NON-GOAL-SESSION-SAVE-001** — Durable save or checkpoint of active simulation state, resumption from persisted simulation state, or restoration of an Admission after client or Session Authority process loss; retained Session Evidence Sets are replay evidence and never live-session input.
- **NON-GOAL-CUSTOM-EDITOR-001** — A custom graphical Map or Scenario editor.
- **NON-GOAL-CONTENT-DOWNLOAD-001** — Distribution, download, patching, or streaming of content from Session Authority to clients.
- **NON-GOAL-CONTENT-MIGRATION-001** — Content migration and backward or forward compatibility.
- **NON-GOAL-AMMUNITION-POOL-001** — Shared abstract ammunition pools.
- **NON-GOAL-AMMUNITION-REPACKING-001** — Manual transfer or repacking of cartridges between magazines.
- **NON-GOAL-ABSTRACT-INVENTORY-001** — Unlimited, weightless, or invisible inventory.
- **NON-GOAL-CHARACTER-ATTRIBUTES-001** — User-selected movement attributes or artificial character classes.
- **NON-GOAL-SIGHT-ZEROING-001** — Manual sight zero and elevation adjustment during a Training Session.
- **NON-GOAL-CASUALTY-MOVEMENT-001** — Dedicated dragging, carrying, evacuation, or recovery of incapacitated or fatal Trainees.
- **NON-GOAL-ENVIRONMENT-OBJECT-THROW-001** — Deliberately throwing movable environment objects; ordinary release/drop is limited to the admitted velocity envelope, while motion caused by external physical forces after release remains governed by `REQ-ENVIRONMENT-THROW-BOUNDARY-001`.
- **NON-GOAL-WEAPON-EXTERNAL-DAMAGE-001** — External physical damage to firearms or Weapon Accessories in the initial baseline.
- **NON-GOAL-ACCESSORY-THERMAL-HANDLING-001** — Accessory-specific contact burns, protective-handling rules, or removal restrictions caused by accessory temperature in the initial baseline.

## Deferred capabilities

- **DEFERRED-INSTRUCTOR-001** — Instructor control of Training Sessions.
- **DEFERRED-AAR-001** — Full After-Action Review, including Training Session reconstruction, tactical timeline, and detailed post-action analysis. Session performance metrics, Formal Assessment, and Leaderboards are governed separately and are not deferred by this entry.
- **DEFERRED-RECOVERY-SUBJECT-001** — Replacing the Recovery Proxy with an autonomously controlled Recovery Subject.
- **DEFERRED-SCENARIO-001** — Sabotage missions.
- **DEFERRED-VR-DEVICE-001** — Standalone virtual-reality devices.
- **DEFERRED-LIGHTING-001** — Dynamic time of day, dynamic weather, and night operations.
- **DEFERRED-RADIO-ADVANCED-001** — Frequency management, jamming, and cryptographic simulation.
- **DEFERRED-LOCOMOTION-001** — Free-form jumping and arbitrary surface climbing.
- **DEFERRED-STRUCTURAL-COLLAPSE-001** — Full structural collapse of buildings.
- **DEFERRED-MELEE-RESTRAINT-001** — Grappling, restraint, immobilization, arrest, and detention actions.
