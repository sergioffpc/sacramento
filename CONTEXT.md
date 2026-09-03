# Training Simulation Domain Glossary

Status: Candidate successor; project-owner approval pending

Purpose: Define the canonical language of the Training Simulation product and represented training world.

Scope: Product roles, sessions, scenarios, actions, represented entities, and outcomes; technical mechanisms and project governance use the linked glossaries.

Intended readers: Project stakeholders, requirements reviewers, designers, implementers, and verification authors.

Prerequisites: None.

Canonical information owner: Project owner.

Sacramento is a multiplayer virtual training product for armed-forces teams to rehearse shooting scenarios that are impractical to reproduce at full physical scale. Runtime and identity mechanisms are defined in the [technical glossary](docs/glossary/technical.md); baselines, profiles, catalogues, and project controls are defined in the [governance glossary](docs/glossary/governance.md).

## Language

**Acoustic Propagation**:
The simulated travel of sound from any represented source, including perceived direction, delay, intensity, obstruction, and environmental response without creating physical force.
_Avoid_: Blast Overpressure, non-spatial audio, source-independent sound effect

**Admission**:
The authoritative runtime acceptance with one stable Admission identifier that atomically binds exactly one current client connection to either authenticated and authorized Trainee, Client Device, and Session Authority Identities or, only under the explicitly non-production permissive development mode, their declared Synthetic Identities until an exact admission-ending event occurs.
_Avoid_: Network connection, authentication result, production acceptance of Synthetic Identity, Team Position assignment, Ready

**Admitted Client**:
A Trainee client whose current connection is governed by one successful Admission.
_Avoid_: Connected socket, authenticated identity, roster entry, Ready Trainee

**After-Action Review (AAR)**:
A structured reconstruction and examination of a completed Training Session used to understand its event sequence, decisions, and outcomes. Session performance metrics, Formal Assessment, and Leaderboards are not by themselves an AAR.
_Avoid_: ARR, debrief, performance summary, Leaderboard

**Autonomous Participant**:
A future Training Session participant controlled by software rather than a human Trainee and assigned to exactly one controlling client connection under the Autonomous Participant baseline. It is subject to the same represented action, physical, capacity, Team Position, and perceptible-information rules as a Trainee unless an approved future requirement states otherwise.
_Avoid_: AI Trainee, bot, headless client, Synthetic Trainee Client

**Ballistic Projectile**:
A physically simulated projectile whose trajectory, time of flight, energy, and material interactions are governed by its approved Physical Profile.
_Avoid_: Hitscan, instant hit, raycast weapon

**Blast Overpressure**:
The simulated transient pressure produced by a weapon discharge or explosion that can physically affect Trainees or Scenario objects independently of its audible sound.
_Avoid_: Acoustic Propagation, explosion sound

**Call Sign**:
A Trainee-chosen, Training Session-local name that uniquely identifies that Trainee without creating a persistent account.
_Avoid_: Username, account, real name

**Carried Load**:
The authoritative physical load attributed to a Trainee from every directly or transitively carried item, with each item's approved contribution counted exactly once.
_Avoid_: Stress Load, item count, duplicated nested mass, cosmetic weight

**Carry Position**:
A represented place in the Trainee's hands, worn equipment, or a carried container that has explicit item compatibility and capacity.
_Avoid_: Inventory slot, unlimited storage, abstract inventory

**Client Device Identity**:
The identity of the computer operating a Trainee client, distinct from the identity of the human Trainee using it.
_Avoid_: Trainee Identity, connection, network address

**Desktop Mode**:
The mandatory Trainee access mode that provides every required Training Session capability through a conventional monitor, keyboard, and mouse without virtual-reality equipment.
_Avoid_: Basic mode, non-VR fallback

**Diegetic Presentation**:
The active-simulation rule that a Trainee receives only information the represented person could perceive in an equivalent physical exercise.
_Avoid_: HUD, overlay, gameplay message

**Fatigue**:
The authoritative simulated physical-exertion state accumulated and recovered according to an admitted Fatigue Profile; it is distinct from Stress Load and from the human Trainee's actual condition.
_Avoid_: Stress Load, player tiredness, stamina bar, actual physiological measurement

**Fire**:
A localized, spatially represented combustion state that can emit light, heat, and Obscurant and can propagate only through explicitly profiled combustible material.
_Avoid_: Cosmetic flame, generic damage volume, unrestricted structural-fire simulation

**Hand Signal**:
An approved military communication gesture physically performed by a Trainee and understood only through direct visual observation.
_Avoid_: Emote, gesture menu output, HUD command, automatic translation

**Item Disposition**:
The single authoritative placement or terminal status of one stable physical item identity, including the Scenario, a Carry Position, a weapon chamber, magazine body, weapon interface, `Consumed`, `Withdrawn`, or replacement by explicitly traced transformation products.
_Avoid_: Duplicate inventory entry, implicit attachment, untracked deletion, copied item

**Loadout**:
A Scenario-defined set of weapons, ammunition, communication equipment, protective equipment, and other items assigned to one Trainee for a Training Session.
_Avoid_: Character class, inventory preset

**Map**:
The spatial environment and physical content in which a Scenario takes place. It does not define Team rosters, objectives, rules, or duration.
_Avoid_: Scenario, level

**Melee**:
Close-range physical combat actions performed by a Trainee with the represented body or eligible equipment for an explicit military training purpose.
_Avoid_: Combo system, arcade attack, cinematic takedown

**Mode Equivalence**:
The property that Desktop Mode and Virtual-Reality Mode expose the same Scenario-relevant information and permit the same tactically relevant outcome set from the same canonical state within approved tolerances, despite different controls, physical motions, animations, or presentation.
_Avoid_: Identical interface, identical motion, identical presentation, Platform Parity

**Obscurant**:
A spatially represented airborne volume, such as smoke or dust, that modifies transmitted light and visibility for every Trainee sharing the simulated environment.
_Avoid_: Screen overlay, client-only fog, cosmetic particle effect

**Personnel Recovery**:
A Scenario mission in which one Team locates and recovers a Recovery Subject, or its initial Recovery Proxy, then escorts it to a designated extraction area while the opposing Team attempts to prevent recovery.
_Avoid_: Capture the Flag, hostage rescue

**Preparation**:
The pre-active Training Session lifecycle state in which no initial countdown is running and admitted Trainees may make or change selections and declare `Ready`, including after a cancelled initial countdown.
_Avoid_: Active simulation, initial countdown

**Proximity Voice**:
Live Trainee speech emitted from the speaker's physical Scenario position and perceived by any nearby Trainee through Acoustic Propagation, regardless of Team.
_Avoid_: Voice chat, Team Radio, global voice

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

**Scenario**:
A configured training exercise that selects a Map and defines Team sizes, starting conditions, equipment, objectives, rules, maximum duration, and completion results.
_Avoid_: Map, match, level

**Spawn Transform**:
The position and orientation owned by one versioned Map spatial anchor that a Scenario references and associates with one Team Position for initial entry into active simulation.
_Avoid_: Loadout position, roster position, generic spawn point

**Stress Load**:
A simulated Trainee state derived from exposure to Scenario stressors such as intense combat, incoming fire, explosions, and injury. It may affect non-aim motor tasks but does not claim to measure the human Trainee's actual psychological stress.
_Avoid_: Player stress, fear meter, aim penalty

**Team**:
A configured group of Trainees that cooperates against another Team during a Training Session.
_Avoid_: Side, faction, squad

**Team Position**:
A configured place in one Team's Training Session roster that can be occupied by at most one Trainee and has its own Spawn Transform independently of the selected Loadout.
_Avoid_: Spawn Transform, Loadout position, Carry Position

**Team Radio**:
Live Trainee voice transmitted through Scenario-assigned radio equipment to every functioning radio configured for the same Team channel, including a radio captured and used by an opposing Trainee.
_Avoid_: Proximity Voice, global voice, voice chat

**Technical Removal**:
The irreversible canonical withdrawal of a Trainee and every associated live and physical item state after the Session Authority confirms loss of that Trainee's client connection or accepts that Trainee's explicit departure during active simulation, recorded with cause `Disconnected` and kept distinct from simulated injury or Fatal state.
_Avoid_: Fatal, casualty, Technical Pause, reconnection

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
_Avoid_: Automatic sign-in, Call Sign entry

**Trainee Functional State**:
The authoritative classification of a Trainee's ability to act after simulated exposure: Capable, Impaired, Incapacitated, or Fatal.
_Avoid_: Health, hit points, alive/dead flag

**Trainee Identity**:
The identity of the human Trainee operating a client, distinct from the client computer and the Training Session-local Call Sign.
_Avoid_: Call Sign, Client Device Identity, persistent application account

**Training Session**:
A single coordinated execution of one Scenario by two Teams, including preparation, active simulation, completion, and termination.
_Avoid_: Match, game, server

**Training Simulation**:
The complete multiplayer training product through which Trainees execute Scenarios in Training Sessions.
_Avoid_: Game, generic game engine

**Virtual-Reality Mode**:
An additional Trainee access mode using PC-connected virtual-reality equipment that may coexist with Desktop Mode but is never required to operate a Training Session.
_Avoid_: Mandatory mode, standalone VR

**Weapon Accessory**:
A represented item designed to attach to a weapon, such as an optic, suppressor, weapon-mounted light, or bayonet. It does not include a magazine or cartridge.
_Avoid_: Weapon, magazine, ammunition, generic equipment

**Weapon Malfunction**:
A mechanically caused weapon state that prevents normal operation until the required corrective action is completed. It is distinct from a Stress Load effect or Trainee input error.
_Avoid_: Reload error, stress failure, generic random failure
