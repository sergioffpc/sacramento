# Sacramento overview

Purpose: Introduce the project's goals, intended experience, architecture and
current state, and guide readers to the authoritative documentation.
Owner: Project owner.
Status: Non-normative summary; the linked requirements, contracts and decisions
own their respective information and acceptance criteria.

## Purpose and audience

Sacramento is a multiplayer Training Simulation for armed-forces Teams to
rehearse shooting Scenarios that are impractical to reproduce at full physical
scale. It aims to support coordination and team tactics through communication,
movement, use of cover and response to threats. These objectives are defined by
`GOAL-TRAINING-001` and `GOAL-TEAM-TACTICS-001` in the
[initial requirements](docs/requirements/training-simulation-initial-requirements.md#goals).

The intended experience prioritizes credible represented actions and shared
physical outcomes. Desktop Mode provides access through a monitor, keyboard and
mouse; optional PC-connected Virtual-Reality Mode follows the applicable scope
and Mode Equivalence requirements. Virtual-reality equipment is never required
to operate a Training Session. [CONTEXT.md](CONTEXT.md) defines these product
terms, while the [access requirements](docs/requirements/training-simulation-initial-requirements.md#access-modes-and-input)
own the supported behavior.

## The training experience

A Training Session brings two Teams into one configured Scenario. The Scenario
selects a Map and specifies equipment, starting conditions, objectives, rules,
duration and completion results. Preparation includes the applicable Admission,
Team Position, Loadout and TraineeReady steps before active simulation begins.
The [initial requirements](docs/requirements/training-simulation-initial-requirements.md)
define the lifecycle and capabilities, including:

- Diegetic Presentation, limiting active-simulation information to what the
  represented person could perceive.
- Proximity Voice, Team Radio and visually observed Hand Signals.
- Movement, physical carrying limits, Fatigue and Stress Load.
- Weapon operation, ammunition, Ballistic Projectiles, Acoustic Propagation,
  injury and profiled environment effects.

The [reference Personnel Recovery Scenario](docs/requirements/training-simulation-initial-requirements.md#reference-personnel-recovery-scenario)
provides a concrete exercise: one Team recovers and extracts an inanimate
Recovery Proxy while the opposing Team attempts to prevent recovery. The proxy
represents a future Recovery Subject; it does not imply an implemented
autonomous person.

[Trainee Performance Assessment](docs/requirements/training-simulation-performance-assessment-requirements.md)
separately specifies Training Feedback, Formal Assessment and Leaderboards
(`PERF-BASELINE-001`). These outputs are distinct from a full After-Action Review.
Production assessment requires the future Production Security Baseline;
development-adapter events are unauthenticated test evidence
(`PERF-AUTHENTICITY-001`).

## Architecture and deployment

The accepted [architecture](docs/architecture/software-architecture-description.md)
centres on one Session Authority that owns canonical Simulation outcomes.
Clients submit Intentions and present committed state, with Prediction for
presentation. Fixed-duration Canonical Ticks make authoritative advancement
independent of rendering cadence; [ADR-0005](docs/adr/0005-use-fixed-step-authoritative-runtime.md)
records this decision.

| Application | Intended responsibility and deployment |
| --- | --- |
| Session Authority Runtime | Owns one Scenario and one Training Session on a dedicated, headless Debian machine. |
| Trainee Client Runtime | Provides Trainee input and presentation on Windows client stations. |
| Content Cooker Tool | Processes content offline and publishes paired Authority and Client packs; its execution platform remains unselected. |

The [deployment requirements](docs/requirements/training-simulation-initial-requirements.md#platform-and-deployment-constraints)
specify Windows 11 clients, a Debian 13 authority and wired 1 Gbit/s Ethernet on
the same LAN, with exact configurations governed by Reference Hardware Profiles.
Content is provisioned before startup and remains immutable during the runtime
process. The [offline cooking decision](docs/adr/0013-separate-offline-content-cooking-from-runtime-lifecycle.md)
separates content preparation from live Training Sessions.

Live session state is ephemeral. Client loss during active simulation causes
Technical Removal; authority process loss ends the live session. Retained
evidence supports reconstruction and assessment, never restoration of that
session. The [evidence contract](docs/architecture/0008-evidence-and-ephemeral-state.md)
owns these boundaries.

Production source targets standard C++23. The conditional
[technology foundation](docs/adr/0003-adopt-nvidia-oriented-foundation.md)
selects Flecs, Falcor over Vulkan, Slang, PhysX, GameNetworkingSockets and Steam
Audio behind Sacramento-owned interfaces. Dependency and adapter qualification
remain prerequisites to production admission. The [README](README.md#c-build-baseline)
describes the existing Clang/CMake engineering setup.

## Current state and remaining scope

The repository contains approved requirements, an accepted Development Baseline
architecture, build and repository tooling, and detailed design documents.
There is no production engine executable or passing architecture acceptance
evidence. The [detailed design](docs/design/training-simulation-software-design-baseline.md)
is candidate `SDB-002`, with approval pending; `SDB-001` remains its approved
predecessor. Documented capabilities describe intended behavior, not delivered
features.

Open work includes production implementation, dependency qualification,
concrete content profiles and resource contracts, reference workloads and native
execution evidence. The architecture's [risks and open work](docs/architecture/software-architecture-description.md#11-risks-and-open-work)
and the individual requirements own these details; this overview introduces no
implementation schedule.

[Deferred capabilities](docs/requirements/training-simulation-initial-requirements.md#deferred-capabilities)
include production security, platform operations, instructor control, full
After-Action Review and several environment and device extensions.
[Autonomous Participants](docs/requirements/training-simulation-autonomous-participant-requirements.md)
also belong to a future baseline. Explicit
[non-goals](docs/requirements/training-simulation-initial-requirements.md#non-goals)
include live-session save/resume, medical treatment, a custom graphical editor
and runtime content downloads.

## Reading and verification

Start with the [requirements guide](docs/requirements/README.md) for product
behavior or the [architecture overview](docs/architecture/software-architecture-description.md)
for system structure. Follow the relevant contract and
[ADR](docs/adr/README.md) for exact decisions. Product terminology belongs to
[CONTEXT.md](CONTEXT.md); implementation and governance language belong to the
[technical](docs/glossary/technical.md) and
[governance](docs/glossary/governance.md) glossaries.

The [acceptance workflow](docs/requirements/training-simulation-verification-plan.md)
combines observable examples, applicable automated and native-target checks,
performance measurements and qualified domain evaluation. The
[non-functional requirements](docs/requirements/training-simulation-non-functional-requirements.md)
own quality targets. Accepted requirements and diagrams do not establish that
an implementation meets them.

See the [README](README.md) for development setup and contribution entry points,
and the [documentation policy](docs/project/documentation-policy.md) for how to
maintain the canonical sources.
