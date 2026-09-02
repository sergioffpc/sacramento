# Training Simulation

Status: Approved

Approval: Project owner, 2026-09-02

Baseline: Initial Domain Context

Purpose: Define the canonical domain language for the Training Simulation.

Scope: Terms and distinctions used by persistent requirements, verification, architecture, design, implementation, and decision records.

Intended readers: Project owner, requirements reviewers, architects, designers, implementers, verification authors, Qualified Specialists, and Representative Evaluators.

Prerequisites: None.

Canonical information owner: Project owner.

This context defines a multiplayer virtual training product for armed-forces teams to rehearse shooting scenarios that are impractical to reproduce at full physical scale, using desktop PCs or virtual-reality equipment.

## Table of contents

- [Language](#language)

## Language

**Acoustic Profile**:
An exact admitted Approved Profile version defining a represented sound source, propagation inputs and paths, material and environment behavior, receiver outputs, perception criteria, tolerances, and applicability.
_Avoid_: Audio preset, unvalidated mix, source-only sound effect

**Acoustic Propagation**:
The simulated travel of sound from any represented source, including perceived direction, delay, intensity, obstruction, and environmental response without creating physical force.
_Avoid_: Blast Overpressure, non-spatial audio, source-independent sound effect

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

**Admission**:
The authoritative acceptance with one stable Admission identifier that atomically binds one authenticated and authorized Trainee Identity and Client Device Identity to the validating Session Authority Identity and exactly one current client connection, permitting an atomic rebind to one recovered connection only after successful continuity validation, until an exact admission-ending event occurs.
_Avoid_: Network connection, authentication result, Team Position assignment, Ready

**Admission Authorization Rule Set**:
The approved, versioned product rules whose client-applicable rows authorize the Session Authority Identity and whose authority-applicable rows convert authenticated Trainee and Client Device Identities and external Authorization Assertions into the final admission or denial decision.
_Avoid_: Local user allowlist, identity lifecycle policy, implicit access check

**Admitted Client**:
A Trainee client whose current connection or permitted reconnection continuity is governed by one successful Admission.
_Avoid_: Connected socket, authenticated identity, roster entry, Ready Trainee

**After-Action Review (AAR)**:
A structured reconstruction and examination of a completed Training Session used to understand its event sequence, decisions, and outcomes. Session performance metrics, Formal Assessment, and Leaderboards are not by themselves an AAR.
_Avoid_: ARR, debrief, performance summary, Leaderboard

**Approved Profile**:
A versioned record of represented behavior or data whose scope, reference conditions, evidence, tolerances, specialist validation, and project-owner approval satisfy the profile-admission requirements.
_Avoid_: Tuning preset, provisional values, undocumented configuration

**AUTH Attempt**:
One finite runtime initial-admission, continuity, lifecycle, or audit-recovery attempt with one unique instance identifier and one stable class key whose exact nested AUTH Operations, validator roles, start, terminal result, cancellation propagation, and supersession behavior are declared by the AUTH Operation Inventory.
_Avoid_: Network connection, retry, individual proof check, unbounded login process

**AUTH Audit Checkpoint**:
A separately collectable, non-secret integrity reference whose exact scope and relationship to retained AUTH Audit Records are defined by the approved AUTH Audit Integrity Profile so unauthorized mutation, deletion, or discontinuity within that scope can be detected.
_Avoid_: Audit record copy, mutable sequence pointer, unauthenticated file offset

**AUTH Audit Commit Unit**:
The atomic persistence outcome covering one final AUTH Audit Record and every integrity reference required for it by the current AUTH Audit Integrity Profile, committed before the governed operation may produce an access-, privilege-, Admission-, or continuity-granting AUTH effect.
_Avoid_: Record written before its result is known, best-effort log write, gameplay transaction

**AUTH Audit Integrity Profile**:
The approved, versioned outcome specification for grouping, ordering, continuity, integrity references, authorized expiry transitions, discontinuities, validation evidence, and acceptance criteria for retained AUTH Audit Records.
_Avoid_: Mandated storage format, named algorithm, implementation default, tamper-proof claim

**AUTH Audit Policy**:
The approved, versioned policy that defines AUTH Audit Record classes, host-role applicability, finite retention periods, expiry disposition, and access boundary independently of any Scenario.
_Avoid_: Scenario setting, indefinite retention, implementation default

**AUTH Audit Record**:
A persistent record of one inventory-classified authentication, authorization, admission, continuity, lifecycle, or audit-recovery operation and its exact applicable non-secret inputs and result, retained for security traceability rather than gameplay or After-Action Review.
_Avoid_: AAR event, gameplay telemetry, authentication secret, reusable proof

**AUTH Audit Sequence**:
One ordered retained continuity epoch within a host's closed chain of current and historical AUTH Audit epochs, with explicit beginning, rollover, discontinuity, authorized-expiry, and checkpoint boundaries.
_Avoid_: Unordered log files, mutable event list, gameplay timeline

**AUTH Data Inventory**:
The approved, versioned, and closed classification of every externally provisioned AUTH package payload and internally produced AUTH field by purpose, source or producer, permitted host-role recipient, consumer, persistence, lifetime, cleanup event, and governing requirement.
_Avoid_: Evidence-format catalogue, runtime schema, undeclared telemetry, open metadata bag

**AUTH Denial Category**:
One of the closed generic outcomes disclosed to a requesting client when AUTH cannot continue, without revealing the exact failed identity, evidence, policy, profile, revocation, or validation rule.
_Avoid_: Exact rejection reason, diagnostic trace, silent disconnect

**AUTH Operation**:
One independently resolved runtime authentication, authorization, admission, claim-validation, device-continuity-validation, lifecycle, or audit-recovery action with one unique instance identifier and one stable class key, nested in exactly one AUTH Attempt.
_Avoid_: Entire network connection, implicit validation step, gameplay action

**AUTH Operation Inventory**:
The approved, versioned, and closed inventory of AUTH Attempt and AUTH Operation classes, including stable class keys, nesting, validators, purposes, start and terminal events, supersession, cancellation propagation, audit classification, required audit classes for audited rows, and permitted effects.
_Avoid_: Runtime call graph, protocol specification, incomplete list of authentication steps

**AUTH Permission**:
One closed authorization value issued in an Authorization Assertion: `Use Training Simulation`, `Operate Trainee Client`, or `Operate Session Authority`.
_Avoid_: Role, Team permission, Scenario permission, free-form entitlement

**AUTH Protected Exchange**:
The mutually bound AUTH Attempt context that protects AUTH messages against unauthorized disclosure, modification, injection, replay, reordering, or use with another peer or purpose.
_Avoid_: Plain connection, gameplay channel, architecture-specific protocol name

**Authentication Assurance Profile**:
An exact versioned Identity Authority policy defining the authenticator classes, factor count, human-presence conditions, proof requirements, applicability, and acceptance criteria for one identity class.
_Avoid_: Product-owned account policy, implicit assurance, universal password rule

**Authentication Challenge**:
A single-use request created by a validator for one exact AUTH Operation and Attempt, presenter identity, validator identity, and authentication or continuity purpose.
_Avoid_: Reusable nonce, timestamp alone, session identifier, Authorization Assertion

**Authenticator Control Proof**:
Evidence that the presenter controls the authenticator bound by the Identity Authority to one exact identity, without exposing or transferring that authenticator.
_Avoid_: Copied identity record, Authorization Assertion, Call Sign, possession of public evidence

**Authorization Assertion**:
A verifiable statement from the Identity Authority that assigns one or more AUTH Permissions to one identified Trainee Identity, Client Device Identity, or Session Authority Identity.
_Avoid_: Authentication evidence, local account, Team assignment, Session Continuity Claim

**Autonomous Participant**:
A future Training Session participant controlled by software rather than a human Trainee and assigned to exactly one controlling client connection under the Autonomous Participant baseline. It is subject to the same represented action, physical, capacity, Team Position, and perceptible-information rules as a Trainee unless an approved future requirement states otherwise.
_Avoid_: AI Trainee, bot, headless client, Synthetic Trainee Client

**Ballistic Projectile**:
A physically simulated projectile whose trajectory, time of flight, energy, and material interactions are governed by its approved Physical Profile.
_Avoid_: Hitscan, instant hit, raycast weapon

**Baseline Applicability Inventory**:
The approved, versioned classification of every current requirement identifier as Included, Future at one named milestone, or Not Applicable with justification for one candidate product baseline.
_Avoid_: Implicit scope, omitted requirement, future promise without milestone

**Baseline Artifact Inventory**:
The approved, versioned list of architecture, design, implementation, and verification artifacts governed by one candidate baseline.
_Avoid_: Repository file listing, informal document list, section index

**Blast Overpressure**:
The simulated transient pressure produced by a weapon discharge or explosion that can physically affect Trainees or Scenario objects independently of its audible sound.
_Avoid_: Acoustic Propagation, explosion sound

**Call Sign**:
A Trainee-chosen, Training Session-local name that uniquely identifies that Trainee without creating a persistent account.
_Avoid_: Username, account, real name

**Canonical Identity Key**:
The normalized tuple of exact Identity Authority, identity class, and stable subject identifier produced by successful identity validation and used for every identity comparison, binding, and uniqueness decision.
_Avoid_: Display name, evidence document identity, network address, implementation-specific object identity

**Canonical Tick**:
One indivisible authoritative advancement of simulated time and canonical simulated state within a Training Session, identified by a monotonically increasing integer in one simulation epoch.
_Avoid_: Render frame, network update, Operational Clock interval, variable time step

**Carried Load**:
The authoritative physical load attributed to a Trainee from every directly or transitively carried item, with each item's approved contribution counted exactly once.
_Avoid_: Stress Load, item count, duplicated nested mass, cosmetic weight

**Carry Position**:
A represented place in the Trainee's hands, worn equipment, or a carried container that has explicit item compatibility and capacity.
_Avoid_: Inventory slot, unlimited storage, abstract inventory

**Carrying Catalogue**:
The approved, versioned, and closed inventory of carryable item types, Carry Position types, capacities, interfaces, compatibility results, load contributions, and deterministic automatic-stow ordering admitted to one product baseline.
_Avoid_: Initial Loadout, runtime guess, incomplete compatibility table, abstract inventory

**Client Device Identity**:
The identity of the computer operating a Trainee client, distinct from the identity of the human Trainee using it.
_Avoid_: Trainee Identity, connection, network address, Session Continuity Claim

**Continuity Validation Outcome Catalogue**:
The approved, versioned, and closed shared Identity Validation Package artifact assigning one exact terminal result and lifecycle disposition to every combination of Session Continuity Claim, Device Continuity Proof, protected-exchange integrity and binding, audit commit, cancellation, connection, supersession, and deadline outcomes.
_Avoid_: Claim-only acceptance, implicit retry behavior, partial reconnection success

**Controlled LAN**:
The private, dedicated wired local network whose participants, local services, permitted traffic, and measurement conditions are closed by an exact deployment profile, with no route to an external network during a Training Session.
_Avoid_: Wide-area network, shared office network, unspecified LAN

**Conventional Commit Profile**:
The repository-owned, versioned commit-message grammar, admitted types and scopes, breaking-change notation, validation rules, and integration policy based on one exact Conventional Commits specification version.
_Avoid_: Free-form commit title, implicit type list, unvalidated merge message

**Desktop Mode**:
The mandatory Trainee access mode that provides every required Training Session capability through a conventional monitor, keyboard, and mouse without virtual-reality equipment.
_Avoid_: Basic mode, non-VR fallback

**Device Continuity Proof**:
Evidence that a reconnecting client controls the same Client Device Identity bound at initial admission, without repeating identity-validity, authorization, or revocation evaluation.
_Avoid_: Session Continuity Claim, new device authentication, human identity proof

**Diegetic Presentation**:
The active-simulation rule that a Trainee receives only information the represented person could perceive in an equivalent physical exercise.
_Avoid_: HUD, overlay, gameplay message

**Documentation Inventory**:
The approved, versioned, and closed inventory of persistent project documents, their canonical information owner, metadata, prerequisite links, Markdown and Table-of-Contents applicability, and stable mappings to the information for which each document is authoritative.
_Avoid_: Repository file listing, implicit document population, duplicate canonical owner

**Environment Coverage Catalogue**:
The approved, versioned, and closed coverage of admitted doors, windows, lights, circuits, Obscurants, devices, Fire, movable objects, destructible surfaces, interactions, states, and environmental outcomes, with exact profile and downstream catalogue versions.
_Avoid_: Scene object list, engine component registry, implicit environment behavior

**Environment State Catalogue**:
The approved, versioned, and closed state schemas and transition tables for environment objects and effects, including same-event precedence, atomic outputs, terminal dispositions, reset state, and transformation traces.
_Avoid_: Runtime state as specification, unspecified event order, save-game schema

**Fatigue**:
The authoritative simulated physical-exertion state accumulated and recovered according to an admitted Fatigue Profile; it is distinct from Stress Load and from the human Trainee's actual condition.
_Avoid_: Stress Load, player tiredness, stamina bar, actual physiological measurement

**Fatigue Profile**:
An exact admitted Approved Profile version defining Fatigue inputs, authoritative simulated-time evolution, bounds, recovery, applicability, and permitted downstream effects.
_Avoid_: Stamina constant, undocumented recovery, actual human health model

**Fire**:
A localized, spatially represented combustion state that can emit light, heat, and Obscurant and can propagate only through explicitly profiled combustible material.
_Avoid_: Cosmetic flame, generic damage volume, unrestricted structural-fire simulation

**Fire Profile**:
An exact admitted Approved Profile version defining ignition, fuel, heat transfer, combustion states, propagation, outputs, exposure, time evolution, and extinction for a closed source, material, environment, and target domain.
_Avoid_: Particle preset, generic burn damage, unrestricted building-fire model

**Functional State Transition Catalogue**:
The approved, versioned, and closed matrix mapping every current Trainee Functional State and admitted single, simultaneous, or accumulated injury outcome to exactly one succeeding state and limitation set.
_Avoid_: Health threshold, implicit severity order, implementation-defined injury aggregation

**Hand Signal**:
An approved military communication gesture physically performed by a Trainee and understood only through direct visual observation.
_Avoid_: Emote, gesture menu output, HUD command, automatic translation

**Harmful Effect Inventory**:
The approved, versioned, and closed inventory of every admitted effect source capable of producing injury, impairment, equipment damage, or another adverse authoritative outcome, traced to its exact physical and injury rules.
_Avoid_: Damage types, open other-harm list, Team-specific damage table

**Identity Authority**:
The system outside the Training Simulation that owns the authoritative lifecycle of Trainee Identities, Client Device Identities, and Session Authority Identities.
_Avoid_: Training Simulation account store, Call Sign registry, Session Continuity Claim issuer

**Identity Evidence Catalogue**:
The approved, versioned, and closed inventory of supported identity classes, evidence and assertion types and versions, required fields, issuers, Authentication Assurance Profiles, Offline Revocation Status forms, validation purposes, dependencies, and objective validation rules.
_Avoid_: Dynamic format discovery, open evidence parser, implementation behavior as specification

**Identity Validation Package**:
The externally provisioned, versioned release defining one closed Trainee Client manifest and one closed Session Authority manifest plus shared approved non-sensitive artifacts, from which each host receives and retains only its applicable role manifest and those shared artifacts.
_Avoid_: Server-downloaded trust data, dynamic validation dependency, local identity database

**Initial Start Condition Set**:
The approved, versioned, and closed inventory of individual and Training Session-wide conditions that permit the initial countdown and transition into active simulation.
_Avoid_: Hidden start gate, readiness preconditions only, implementation-defined start conditions

**Intention**:
A client request proposing a Trainee action for authoritative evaluation; it cannot prescribe its Canonical Tick, canonical ordering, result, or resulting state.
_Avoid_: Client command, authoritative action, client-authored outcome, timestamped event

**Injury Outcome Catalogue**:
The approved, versioned, and closed coverage of every admitted body region, exposure, protection, prior-injury and Trainee Functional State tuple, with exact Injury Profile versions, resulting injuries, limitations, cues, and downstream profile effects.
_Avoid_: Damage table, hit points, generic body-region penalty, optional injury effect

**Injury Profile**:
An exact admitted Approved Profile version defining injury thresholds, protection, outcome, combination, limitation, cue, duration, downstream effects, reference conditions, and tolerances for a closed exposure and prior-state domain.
_Avoid_: Damage value, health table, unvalidated medical rule

**Item Disposition**:
The single authoritative placement or terminal status of one stable physical item identity, including the Scenario, a Carry Position, a weapon chamber, magazine body, weapon interface, `Consumed`, or replacement by explicitly traced transformation products.
_Avoid_: Duplicate inventory entry, implicit attachment, untracked deletion, copied item

**Lighting Profile**:
An exact admitted Approved Profile version defining emitted light, spatial distribution, occlusion, illumination, shadow, visibility outputs, comparison criteria, and tolerances for a represented light source and environment domain.
_Avoid_: Cosmetic light, client-only illumination, arbitrary brightness

**Loadout**:
A Scenario-defined set of weapons, ammunition, communication equipment, protective equipment, and other items assigned to one Trainee for a Training Session.
_Avoid_: Character class, inventory preset

**Locomotion Profile**:
An exact admitted Approved Profile version defining movement capabilities, environmental applicability, and limits from the complete declared input tuple, including posture, Carried Load, Fatigue, Recovery Carrier status, and Trainee Functional State.
_Avoid_: Player stats, movement-speed constant, character class

**Map**:
The spatial environment and physical content in which a Scenario takes place. It does not define Team rosters, objectives, rules, or duration.
_Avoid_: Scenario, level

**Melee**:
Close-range physical combat actions performed by a Trainee with the represented body or eligible equipment for an explicit military training purpose.
_Avoid_: Combo system, arcade attack, cinematic takedown

**Melee Coverage Catalogue**:
The approved, versioned, and closed coverage of admitted Melee bodies, actions, implements, interfaces, resources, access modes, physical conditions, contact phases, targets, defenses, and outcomes, with exact catalogue rows and Approved Profile versions.
_Avoid_: Combo list, animation set, optional move table

**Mode Equivalence**:
The property that Desktop Mode and Virtual-Reality Mode expose the same Scenario-relevant information and permit the same tactically relevant outcome set from the same canonical state within approved tolerances, despite different controls, physical motions, animations, or presentation.
_Avoid_: Identical interface, identical motion, identical presentation, Platform Parity

**Obscurant**:
A spatially represented airborne volume, such as smoke or dust, that modifies transmitted light and visibility for every Trainee sharing the simulated environment.
_Avoid_: Screen overlay, client-only fog, cosmetic particle effect

**Obscurant Profile**:
An exact admitted Approved Profile version defining formation, spatial volume, movement, geometry/opening interaction, dissipation, transmitted-light and visibility outputs, physiology, simulated-time evolution, and tolerances.
_Avoid_: Particle preset, screen fog, implicit smoke lifetime

**Offline Revocation Status**:
A time-bounded statement from the Identity Authority that identifies an exact identity-evidence item or Authorization Assertion and classifies it as `Current` or `Revoked` for offline validation.
_Avoid_: Cached admission decision, unbounded revocation list, inferred validity

**Offline-Verifiable Identity Evidence**:
Identity authentication evidence or an Authorization Assertion issued under the Identity Authority whose issuer, subject, integrity, applicability, validity, and Offline Revocation Status can be established without contacting that authority during admission.
_Avoid_: Cached admission decision, local account, unverifiable identity claim

**Operational Clock**:
The Session Authority's monotonic time source for Training Session lifecycle deadlines and countdowns, which advances independently from simulated time, including during Technical Pause.
_Avoid_: Simulated time, Scenario timer, client clock, calendar clock

**Observability Contract**:
The approved, versioned definition of core metric and event identifiers, fields, units, timestamp semantics, correlation semantics, and availability needed to verify automated quality requirements and operational targets consistently in test and production builds.
_Avoid_: Implementation-specific logging library, unrestricted diagnostic dump, AUTH Audit Record

**Package Trust Reference**:
The externally provisioned, project-owner-approved bootstrap reference by which a host verifies the identity, version, role, and integrity of the current Identity Validation Package manifest without trusting that package to validate itself.
_Avoid_: Self-declared package integrity, Session Authority download, live identity lookup

**Personnel Recovery**:
A Scenario mission in which one Team locates and recovers a Recovery Subject, or its initial Recovery Proxy, then escorts it to a designated extraction area while the opposing Team attempts to prevent recovery.
_Avoid_: Capture the Flag, hostage rescue

**Physical Effects Catalogue**:
The approved, versioned, and closed coverage of admitted physical-effect sources, projectiles, atmospheres, materials, propagation paths, impact geometries, targets, protection, transformations, and outputs, with exact Physical Profile versions and complete applicability domains.
_Avoid_: Damage lookup, physics tuning table, incomplete material matrix

**Physical Profile**:
An exact admitted Approved Profile version containing evidence-backed physical data and behavior for one represented source, projectile, material, target, weapon, explosive, or interaction class under defined reference conditions.
_Avoid_: Power level, generic damage value

**Platform Parity**:
The preference that shared Simulation Engine capabilities and technologies remain functionally portable between Windows and Linux. It does not imply that every product executable is supported or accepted on both operating systems.
_Avoid_: Full platform matrix, identical deployment support

**Preparation**:
The pre-active Training Session lifecycle state in which no initial countdown is running and admitted Trainees may make or change selections and declare `Ready`, including after a cancelled initial countdown.
_Avoid_: Active simulation, Technical Pause, resume countdown

**Project C++ Style Profile**:
The repository-owned, versioned, and closed C++ coding rules, automatic-tool mappings, explicitly admitted deviations, scope, and acceptance gates used as the sole project style authority.
_Avoid_: Live external guide, developer preference, formatter defaults, unwritten exception

**Project Python Style Profile**:
The repository-owned, versioned, and closed Python language and style rules, automatic-tool mappings, explicitly admitted deviations, scope, and acceptance gates used as the sole project style authority.
_Avoid_: Live external guide, developer preference, linter defaults, unexplained suppression

**Proximity Voice**:
Live Trainee speech emitted from the speaker's physical Scenario position and perceived by any nearby Trainee through Acoustic Propagation, regardless of Team.
_Avoid_: Voice chat, Team Radio, global voice

**Qualified Specialist**:
A person with demonstrable expertise in the specific equipment or physical phenomenon covered by an Approved Profile who evaluates the validity and applicability of its supporting evidence.
_Avoid_: Developer by default, generic reviewer, Representative Evaluator by default

**Radio Coverage Profile**:
The approved, versioned acceptance conditions, spatial domain, transmission and listening inputs, intelligibility metric, tolerance, and coverage evidence required for Team Radio across one Map.
_Avoid_: Informal walk test, overlapping-traffic test, unspecified audibility

**Ready**:
A Training Session state indicating that a Trainee satisfies the complete approved readiness-precondition set and has explicitly declared readiness to begin.
_Avoid_: Connected, loaded, waiting

**Recovery Carrier**:
The Trainee currently transporting the Recovery Proxy during a Personnel Recovery mission.
_Avoid_: Carrier player, flag carrier

**Recovery Proxy**:
An inanimate carryable Scenario object that represents the Recovery Subject during the initial baseline while preserving the mission's recovery and extraction objectives.
_Avoid_: Flag, loot, capture point

**Recovery Subject**:
The isolated simulated person whom a Personnel Recovery mission ultimately requires a Team to locate, secure, and escort to extraction.
_Avoid_: Flag, hostage, objective item

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

**Scenario**:
A configured training exercise that selects a Map and defines Team sizes, starting conditions, equipment, objectives, rules, maximum duration, and completion results.
_Avoid_: Map, match, level

**Session Authority**:
The trusted part of the Training Simulation that determines the canonical state and outcomes of one active Training Session.
_Avoid_: Client, host player, source of truth

**Session Authority Identity**:
The externally governed identity presented by a Session Authority endpoint so a Trainee client can authenticate and authorize that authority before disclosing Trainee or client-device authentication evidence.
_Avoid_: Network address, Training Session identity, Session Continuity Claim

**Session Continuity Claim**:
Session-local evidence scoped to one Training Session and reserved Team Position that, together with Device Continuity Proof, permits a reconnecting client to reclaim that position without reauthenticating the human Trainee or re-evaluating identity authorization or revocation.
_Avoid_: User identity, account, login, persistent credential

**Session Reset Catalogue**:
The approved, versioned, and closed inventory that classifies each canonical state field as reset or eligible for retention when one Training Session transitions to Preparation for another.
_Avoid_: Implicit reset, live-state guess, save game, checkpoint

**Simulation Engine**:
The internal software foundation built only to support the Training Simulation's validated needs. It is not an independently reusable or general-purpose product.
_Avoid_: Product, general-purpose engine

**Simulated Time**:
The authoritative Training Session time derived exactly from its simulation epoch and Canonical Tick; it advances only through committed Canonical Ticks and remains frozen throughout Technical Pause.
_Avoid_: Operational Clock, Trusted Identity Time, render time, client clock

**Spawn Transform**:
The position and orientation owned by one versioned Map spatial anchor that a Scenario references and associates with one Team Position for initial entry into active simulation.
_Avoid_: Loadout position, roster position, generic spawn point

**State Restoration**:
The reconnection state in which the Session Authority has established from current-state-bound evidence that a client satisfies the complete approved coverage of authoritative data needed to present and act from the paused canonical state.
_Avoid_: Reconnection, content loading, Ready, client acknowledgement, snapshot protocol

**State Restoration Coverage Catalogue**:
The versioned and approved verification inventory of authoritative-state classes that a reconnecting client must satisfy for required presentation, available actions, and authoritative outcomes in each access mode.
_Avoid_: Representative sample, synchronization protocol, state snapshot

**Stress Load**:
A simulated Trainee state derived from exposure to Scenario stressors such as intense combat, incoming fire, explosions, and injury. It may affect non-aim motor tasks but does not claim to measure the human Trainee's actual psychological stress.
_Avoid_: Player stress, fear meter, aim penalty

**Stress Profile**:
An exact admitted Approved Profile version defining the closed stressor and optional-effect inventories, Stress Load bounds, authoritative simulated-time accumulation and recovery, history windows, applicability, and permitted downstream effects.
_Avoid_: Mood system, undocumented stress penalty, actual psychological measurement

**Team**:
A configured group of Trainees that cooperates against another Team during a Training Session.
_Avoid_: Side, faction, squad

**Team Position**:
A configured place in one Team's Training Session roster that can be occupied by at most one Trainee and has its own Spawn Transform independently of the selected Loadout.
_Avoid_: Spawn Transform, Loadout position, Carry Position

**Team Radio**:
Live Trainee voice transmitted through Scenario-assigned radio equipment to every functioning radio configured for the same Team channel, including a radio captured and used by an opposing Trainee.
_Avoid_: Proximity Voice, global voice, voice chat

**Technical Pause**:
A Training Session-wide suspension caused by a technical failure, during which simulated time and all gameplay effects stop while connection recovery remains active.
_Avoid_: Timeout, tactical pause, game pause

**Trainee**:
An armed-forces participant who takes part in a Training Session as a member of a Team.
_Avoid_: Player, participant, user

**Trainee Performance Assessment**:
A structured set of evidence-derived results about one Trainee's performance under defined Training Session, task, role, and profile conditions, with separate outputs for Training Feedback, Formal Assessment, and Leaderboard.
_Avoid_: Gameplay telemetry, universal score, personnel record

**Training Feedback**:
Detailed, session-scoped information returned to a Trainee or instructor to support learning and improvement; it is not a formal competence decision.
_Avoid_: Formal Assessment, ranking, raw telemetry

**Formal Assessment**:
An evidence-based evaluation of a Trainee against fixed, pre-approved performance criteria under defined conditions, independent of relative position among other Trainees.
_Avoid_: Leaderboard position, popularity score, informal feedback

**Leaderboard**:
A relative ordering of eligible Trainees within one explicitly defined scope, period, role, and comparison population; it is not by itself a Formal Assessment.
_Avoid_: Competence decision, universal ranking, hidden score

**Trainee Authentication Act**:
A deliberate act performed by the human Trainee to authenticate that Trainee Identity for one initial admission attempt, without prescribing the authentication mechanism.
_Avoid_: Automatic sign-in, Call Sign entry, Session Continuity Claim presentation

**Trainee Functional State**:
The authoritative classification of a Trainee's ability to act after simulated exposure: Capable, Impaired, Incapacitated, or Fatal.
_Avoid_: Health, hit points, alive/dead flag

**Trainee Identity**:
The identity of the human Trainee operating a client, distinct from the client computer and the Training Session-local Call Sign.
_Avoid_: Call Sign, Client Device Identity, Session Continuity Claim, persistent application account

**Training Need Record**:
An approved, versioned statement of a military training activity and intended training outcome that justifies admitting one or more Trainee actions.
_Avoid_: Feature request, entertainment rationale, informal use case

**Training Session**:
A single coordinated execution of one Scenario by two Teams, including preparation, active simulation, Technical Pauses, and completion or termination.
_Avoid_: Match, game, server

**Training Simulation**:
The complete multiplayer training product through which Trainees execute Scenarios in Training Sessions.
_Avoid_: Game, generic game engine

**Trusted Identity Time**:
The independently established time used by a validating host to evaluate identity-evidence validity without accepting time from the identity or endpoint being validated; it is distinct from the Operational Clock and simulated time.
_Avoid_: Operational Clock, simulated time, peer-provided time, unqualified local clock

**Virtual-Reality Mode**:
An additional Trainee access mode using PC-connected virtual-reality equipment that may coexist with Desktop Mode but is never required to operate a Training Session.
_Avoid_: Mandatory mode, standalone VR

**Weapon Accessory**:
A represented item designed to attach to a weapon, such as an optic, suppressor, weapon-mounted light, or bayonet. It does not include a magazine or cartridge.
_Avoid_: Weapon, magazine, ammunition, generic equipment

**Weapon Behavior Catalogue**:
The approved, versioned, and closed inventory that reconciles every admitted weapon, ammunition, magazine, and Weapon Accessory type with every required capability, state, action, physical interaction, damage-cause class, malfunction, and transformation; each row declares applicability, exact admitted Approved Profile versions, complete condition and output domains, tolerances, and evidence.
_Avoid_: Weapon feature list, optional profile row, implementation behavior as specification

**Weapon Malfunction**:
A mechanically caused weapon state that prevents normal operation until the required corrective action is completed. It is distinct from a Stress Load effect or Trainee input error.
_Avoid_: Reload error, stress failure, generic random failure
