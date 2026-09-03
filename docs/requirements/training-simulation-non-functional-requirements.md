# Training Simulation Non-Functional Requirements

Status: Approved

Approval: Project owner, 2026-09-01

Latest approved amendment: Platform deployment and production-security deferral, project owner, 2026-09-03

Baseline identifier: `NFR-BASELINE-001`

Applicability: Development Baseline; explicitly identified production-security and platform-operations requirements remain future.

Purpose: Define the measurable non-functional requirements that the initial Training Simulation baseline must satisfy before it can guide architecture and receive product-baseline approval.

Scope: Quality requirements and their essential acceptance conditions for Desktop Mode and the Session Authority. Virtual-Reality Mode belongs to a later named baseline.

Intended readers: Project owner, requirements reviewers, architects, designers, implementers, and verification authors.

Prerequisites: [Training Simulation context](../../CONTEXT.md), [Training Simulation Initial Requirements](training-simulation-initial-requirements.md), [Training Simulation Reference Hardware Profiles](training-simulation-reference-hardware-profiles.md), [Training Simulation Verification Plan](training-simulation-verification-plan.md), and [Initial Goals, Requirements, and Constraints Document Guidance](../research/initial-goals-requirements-and-constraints-guidance.md).

Canonical information owner and approver: Project owner.

Normative effect: This approved document is the canonical NFR baseline for initial Desktop Mode and Session Authority scope.

## Table of contents

- [Quality precedence](#quality-precedence)
- [Acceptance environment](#acceptance-environment)
- [Acceptance and operational observability](#acceptance-and-operational-observability)
- [Requirements](#requirements)
- [Requirement catalogue](#requirement-catalogue)
- [Ambiguity review](#ambiguity-review)
- [Completion rule](#completion-rule)

## Quality precedence

When accepted requirements conflict, the higher-ranked quality governs:

1. training validity and human safety;
2. information security and AUTH audit integrity, when the Production Security Baseline applies;
3. canonical-state consistency;
4. retained-evidence completeness and bounded failure containment;
5. latency and temporal stability;
6. visual and acoustic fidelity beyond the approved minimum;
7. maintainability; and
8. operational convenience.

## Acceptance environment

Runtime measurements use exact approved Reference Hardware Profile and Reference Workload Profile versions. Workload values live in the profiles and are not duplicated in individual requirements.

Desktop Mode uses `RHP-DESKTOP-001`, based on a Lenovo ThinkStation P620 with 128 GB of memory and an NVIDIA GeForce RTX 5070 Ti. The Session Authority uses `RHP-AUTHORITY-001`, based on a Dell PowerEdge R630 with 256 GB of memory. Their exact configurations are canonical in [Training Simulation Reference Hardware Profiles](training-simulation-reference-hardware-profiles.md).

| Profile | Fixed runtime envelope | Functional trace |
| --- | --- | --- |
| `Typical` | One Session Authority on `RHP-AUTHORITY-001`, seven synthetic Trainee clients on a separate load generator satisfying `CONSTRAINT-NFR-LOAD-GENERATOR-001`, one non-completed and non-terminated Training Session, one complete rendered Desktop Mode client on `RHP-DESKTOP-001`, and two Teams of four Trainees each | `REQ-TEAM-001`, `REQ-CAPACITY-002`, `REQ-SERVER-SESSION-001`, `CONSTRAINT-AUTHORITY-HOST-002` |
| `Stress` | One Session Authority on `RHP-AUTHORITY-001`, 15 synthetic Trainee clients on a separate load generator satisfying `CONSTRAINT-NFR-LOAD-GENERATOR-001`, one non-completed and non-terminated Training Session, one complete rendered Desktop Mode client on `RHP-DESKTOP-001`, two Teams of eight Trainees each, and a Map whose Map-local horizontal bounding rectangle is 250 metres on each axis within the admitted tolerance | `REQ-TEAM-001`, `REQ-CAPACITY-001`, `REQ-CAPACITY-002`, `REQ-SERVER-SESSION-001`, `REFERENCE-MAP-SCALE-001`, `CONSTRAINT-AUTHORITY-HOST-002` |

Additional workload values are added to a profile only when an accepted NFR needs them for reproducible measurement.

Synthetic Trainee clients contribute the same applicable session, networking, and action workload as Trainees but are not visual- or acoustic-evaluation targets. For end-to-end action-response evidence, the rendered client records presentation of the authoritative result and each synthetic client records receipt of it. Representative visual and acoustic evaluations remain human-driven and separate from automated replay.

The accepted network environment is a Controlled LAN. WAN operation and recovery from workloads outside the approved profiles are outside this baseline.

Loading and Preparation may warm the system before presentation-performance measurement. Measurement begins with active simulation, and no interval after that boundary is excluded as warm-up.

## Acceptance and operational observability

The [Training Simulation Observability Contract](training-simulation-observability-contract.md) defines the stable signals required to verify automated quality requirements and operational targets. It is a product obligation in this document because verification cannot manufacture missing runtime facts. Collection procedures, calculations, and evidence disposition remain owned by the verification plan; instrumentation technology, transport, and storage remain architecture decisions.

## Requirements

**CONSTRAINT-NFR-LAN-001** — Every wired Ethernet link connecting a Trainee station or the Session Authority to the Controlled LAN MUST negotiate at least 1 gigabit per second throughout the applicable acceptance procedure.

**CONSTRAINT-NFR-LOAD-GENERATOR-001** — Synthetic Trainee clients MUST execute on a machine separate from the Session Authority. Its total CPU utilization MUST be sampled once per second throughout the automated acceptance run, no sample MUST exceed 80 percent, and its wired Ethernet link to the Controlled LAN MUST negotiate at least 1 gigabit per second. The machine model and operating system are not fixed.

**CONSTRAINT-NFR-REPLAY-001** — Throughout the single five-minute automated acceptance run required for each Reference Workload Profile, the rendered Desktop Mode client and every synthetic client MUST replay their assigned part of the exact deterministic action script version named by that profile. The script version and every client replay outcome MUST be included in the acceptance evidence.

**NFR-OBSERVABILITY-BUILD-PARITY-001** — Test and production builds MUST implement the same versioned Observability Contract, with the same core signal identifiers, field meanings, units, timestamp semantics, and correlation semantics. Every core signal MUST remain enabled continuously from process start through process termination in both build types. Configurable detail levels MAY add signals or increase their volume without recompilation but MUST NOT disable, rename, or change the meaning of a core signal.

**CONSTRAINT-NFR-OBSERVABILITY-ACCEPTANCE-001** — Every formal NFR acceptance run MUST use the Observability Contract's `CoreOnly` detail level. Optional diagnostic signals, including per-final-image detail, MUST remain disabled throughout that run.

**NFR-OBSERVABILITY-CORE-001** — The Observability Contract core inventory MUST contain process lifecycle; final-image intervals; correlated action submission, authoritative-result receipt, and rendered presentation; acoustic-event initiation and presentation; Admission start and terminal result; AUTH Audit Commit Unit reference when the Production Security Baseline applies; Technical Removal; Session Evidence Set terminal handoff; exact Application Release, Runtime Launch Specification, build, configuration, AUTH mode, applicable profile versions and Runtime Content Release; and counts of lost or discarded observability signals. Core signals MUST NOT contain gameplay payloads, credentials, authentication evidence, or personal data.

**NFR-OBSERVABILITY-RETENTION-001** — In production, core operational signals MUST remain retrievable for at least 30 days after collection. Formal acceptance evidence remains governed by the verification plan rather than this operational retention period. A future Session Authority capability-availability target MUST define its own evidence and retention window.

**NFR-OBSERVABILITY-INTEGRITY-001** — During acceptance, loss or discard of any core signal required by a measured obligation MUST make that obligation's result `Blocked` and MUST NOT produce `Pass`.

**NFR-OBSERVABILITY-ALERTING-001** — In production, each increase in a core lost-or-discarded-signal counter MUST produce an operational alert no later than 60 seconds after the triggering observation. A future Session Authority capability-availability target MUST define any readiness or launch-failure alerting obligation.

**NFR-OBSERVABILITY-TIME-001** — Throughout an acceptance run, timestamps used to calculate an interval between different machines MUST use clocks whose measured absolute offset remains no greater than 1 millisecond. If that bound cannot be established for any part of the applicable measurement window, every affected obligation MUST receive `Blocked` and MUST NOT receive `Pass`.

**NFR-DESKTOP-SMOOTHNESS-001** — Given the exact approved Desktop Mode Reference Hardware Profile, in the single five-minute automated acceptance run for each of the `Typical` and `Stress` runtime Reference Workload Profiles, the Desktop Mode client MUST present its final output in a window whose client presentation area is exactly 2048 × 1080 pixels, with at least 99 percent of intervals between consecutive final images no greater than 16.67 milliseconds.

**NFR-DESKTOP-STALL-001** — Under the same conditions and measurement window as `NFR-DESKTOP-SMOOTHNESS-001`, no interval between consecutive final images presented by the Desktop Mode client MUST exceed 100 milliseconds.

**NFR-ACTION-RESPONSE-001** — In the single five-minute automated acceptance run for each of the `Typical` and `Stress` runtime Reference Workload Profiles, at least 99 percent of valid Trainee actions MUST produce their first corresponding authoritative result at every connected client no later than 100 milliseconds after the originating client submits the action, excluding only delay explicitly required by the applicable physical or Acoustic Profile.

**NFR-VISUAL-VALIDITY-001** — In a pre-approved closed set of Desktop Mode tasks covering people, posture, equipment, materials, cover, occlusion, distance, and lighting at 10, 25, 50, 100, and 150 metres across the reference Map's indoor, outdoor, and lighting-transition contexts, at least five Representative Evaluators MUST collectively achieve at least 90 percent correct scored responses overall and at least 80 percent in every scored category.

**NFR-VISUAL-COVER-INVERSION-001** — The visual-validity result MUST be `Fail` when the same safe-cover or exposure condition is inverted in the independently scored responses of at least two Representative Evaluators.

**NFR-ACOUSTIC-LOCALIZATION-001** — In a pre-approved closed blind test set covering eight horizontal sectors of 45 degrees, source positions above, level with, and below the receiver, and applicable indoor and outdoor contexts, at least five Representative Evaluators using the exact approved Desktop Mode Reference Hardware Profile MUST collectively localize at least 90 percent of scored sources correctly.

**NFR-ACOUSTIC-PEAK-001** — Under the `Stress` runtime Reference Workload Profile, when 16 active weapon sources and four explosions are initiated within one second, every tactically relevant acoustic event required by the applicable exact Acoustic Profile versions MUST be presented to every applicable connected Desktop Mode client without omission.

**NFR-AUTH-ADMISSION-001** — Under the future Production Security Baseline, after completion of the Trainee Authentication Act, when up to 16 initial Admission attempts execute concurrently on the exact approved Session Authority Reference Hardware Profile, at least 99 percent of those attempts MUST reach a terminal success or denial result, including the required AUTH Audit Commit Unit, within five seconds. This target does not apply to or become satisfied by the permissive development adapter.

**DEFERRED-NFR-AUTHORITY-CAPABILITY-AVAILABILITY-001** — Availability of the capability to start and operate an assigned ephemeral Session Authority belongs to a separately approved Platform Operations Baseline defining its subject, stimulus, measurement window, exclusions, evidence and threshold. No process-lifetime, fleet, scheduler, Kubernetes, or cluster availability target applies to the Development Baseline.

**CONSTRAINT-NFR-TEAM-001** — Ongoing first-party engineering and maintenance MUST require no more than two concurrently assigned human generalists; AI agents MAY support them and specialists MAY perform bounded reviews.

No separate maintainability performance target applies to the initial baseline.

The NFR baseline does not prescribe how the renderer produces the final output.

Security strength, Trusted Identity Time behavior, internal AUTH stage limits, retry policy, resource ceilings, and audit retention are owned by the applicable AUTH specification. They do not add acceptance conditions to `NFR-AUTH-ADMISSION-001` beyond its observable terminal result and committed audit evidence.

## Requirement catalogue

| Identifier | Type | Status and priority | Parent trace and rationale | Applicability | Verification and evidence | Open dependency |
| --- | --- | --- | --- | --- | --- | --- |
| `CONSTRAINT-NFR-LAN-001` | Deployment constraint | Approved; mandatory for the initial baseline | `CONSTRAINT-NETWORK-MEDIUM-001`; bounds the controlled acceptance network while permitting links faster than 1 gigabit per second | Desktop Mode and Session Authority acceptance | Inspection of the deployment profile and recorded negotiated link rate | None |
| `CONSTRAINT-NFR-LOAD-GENERATOR-001` | Test-environment constraint | Approved; mandatory for automated performance acceptance | `CONSTRAINT-AUTHORITY-HOST-002`; preserves the dedicated Session Authority while preventing the load generator from becoming the measured bottleneck | Synthetic clients under `Typical` and `Stress` runtime profiles | Automated CPU-utilization record and Inspection of machine identity and negotiated wired-link rate | None |
| `CONSTRAINT-NFR-REPLAY-001` | Test-environment constraint | Approved; mandatory for automated performance acceptance | `NFR-DESKTOP-SMOOTHNESS-001`, `NFR-ACTION-RESPONSE-001`; makes the five-minute workload repeatable | Rendered and synthetic clients under `Typical` and `Stress` runtime profiles | Inspection of the named script version and Automated Test of every client replay outcome | None |
| `NFR-OBSERVABILITY-BUILD-PARITY-001` | Quality-support requirement | Approved; mandatory for the initial baseline | Every automatically verified NFR and operational target; prevents test-only instrumentation from producing evidence unavailable in the deployed product | Test and production Desktop Mode and Session Authority builds | Inspection of the versioned Observability Contract plus Automated Test confirming continuous core-signal availability and unchanged semantics under every supported detail level | None |
| `CONSTRAINT-NFR-OBSERVABILITY-ACCEPTANCE-001` | Test-environment constraint | Approved; mandatory for formal NFR acceptance | Makes instrumentation cost constant and reproducible across acceptance runs | Every formal NFR acceptance run | Inspection of `OBS-RUNTIME-IDENTITY-001` from every participating product process and rejection of any non-core signal during the measurement window | None |
| `NFR-OBSERVABILITY-CORE-001` | Quality-support and data-minimization requirement | Approved; mandatory for the initial baseline | Automated NFR evidence needs a closed minimum signal set, while information security outranks operational convenience | Test and production Desktop Mode and Session Authority builds | Inspection of the closed core inventory and Automated Test exercising every signal class plus negative payload and sensitive-data checks | None |
| `NFR-OBSERVABILITY-RETENTION-001` | Operational support requirement | Approved; mandatory after deployment | Core signals need a bounded diagnostic window without pre-empting the evidence window of a future capability-availability target | Production observability records; formal acceptance evidence excluded | Inspection of retention configuration and Automated Test of records immediately before and at each expiry boundary | None |
| `NFR-OBSERVABILITY-INTEGRITY-001` | Quality-support requirement | Approved; mandatory for acceptance | `PROCESS-EVIDENCE-DISPOSITION-002`, `PROCESS-EVIDENCE-OBLIGATION-004`; prevents missing measurements from becoming false evidence | Core signals required by automated NFRs and operational targets | Automated fault-injection test proving affected acceptance becomes `Blocked` and no `Pass` is emitted | None |
| `NFR-OBSERVABILITY-ALERTING-001` | Operational support requirement | Approved; mandatory after deployment | `NFR-OBSERVABILITY-INTEGRITY-001`; makes measurement loss visible within a bounded time | Production collectors | Automated Test injecting each trigger and measuring alert creation within 60 seconds | None |
| `NFR-OBSERVABILITY-TIME-001` | Measurement-integrity requirement | Approved; mandatory for distributed acceptance measurements | `NFR-ACTION-RESPONSE-001`; bounds timestamp error relative to the 100-millisecond response threshold | Acceptance calculations comparing signals emitted by different machines | Automated clock-offset record covering the complete measurement window plus boundary tests at and above 1 millisecond | None |
| `NFR-DESKTOP-SMOOTHNESS-001` | Quality requirement | Approved; mandatory for the initial baseline | `GOAL-TRAINING-001`; makes the accepted 2048 × 1080 windowed presentation at 60 frames per second objectively measurable | Desktop Mode under `Typical` and `Stress` runtime profiles | Automated Test using final-output interval records attributable to the exact hardware, workload, build, and configuration versions | None |
| `NFR-DESKTOP-STALL-001` | Quality requirement | Approved; mandatory for the initial baseline | `NFR-DESKTOP-SMOOTHNESS-001`; prevents a visible freeze from being hidden inside the permitted 1 percent of slower intervals | Desktop Mode under `Typical` and `Stress` runtime profiles | Automated Test using the same final-output interval record as `NFR-DESKTOP-SMOOTHNESS-001` | None |
| `NFR-ACTION-RESPONSE-001` | Quality requirement | Approved; mandatory for the initial baseline | `GOAL-TEAM-TACTICS-001`; bounds end-to-end authoritative feedback rather than internal Session Authority processing alone | Valid Trainee actions under `Typical` and `Stress` runtime profiles | Automated Test using correlated submission records, authoritative-result presentation records from the rendered client, and receipt records from every synthetic client | None |
| `NFR-VISUAL-VALIDITY-001` | Quality requirement | Approved; mandatory for the initial baseline | `GOAL-TRAINING-001`, `REQ-LIGHTING-TACTICAL-PERCEPTION-001`; verifies tactical recognition and interpretation instead of subjective photorealism | Desktop Mode on the exact reference Map, lighting, hardware, and task-set versions | Representative Evaluation with separately attributable scored responses and category totals from at least five Representative Evaluators | None |
| `NFR-VISUAL-COVER-INVERSION-001` | Quality requirement | Approved; mandatory for the initial baseline | `NFR-VISUAL-VALIDITY-001`; prevents aggregate scores from hiding a repeated tactically unsafe perception error | Safe-cover and exposure tasks in the visual-validity set | Representative Evaluation using independently attributable task-condition responses | None |
| `NFR-ACOUSTIC-LOCALIZATION-001` | Quality requirement | Approved; mandatory for the initial baseline | `GOAL-TRAINING-001`, `REQ-ACOUSTIC-001`, `REQ-ACOUSTIC-ENVIRONMENT-001`; verifies tactically useful spatial perception rather than an implementation technique | Desktop Mode on the exact reference hardware, audio-routing, Map, Acoustic Profile, and blind-task-set versions | Representative Evaluation with separately attributable source conditions and scored responses from at least five Representative Evaluators | None |
| `NFR-ACOUSTIC-PEAK-001` | Quality requirement | Approved; mandatory for the initial baseline | `GOAL-TRAINING-001`, `REQ-ACOUSTIC-001`, `REQ-ACOUSTIC-CATALOGUE-002`; prevents peak combat audio from suppressing required tactical cues | Desktop Mode under the `Stress` runtime profile and exact applicable Acoustic Profile versions | Automated Test correlating every initiated required acoustic event with its presentation at every applicable connected client | None |
| `NFR-AUTH-ADMISSION-001` | Future security quality requirement | Approved for the Production Security Baseline; not satisfied by permissive development AUTH | `SCOPE-AUTH-001`; bounds Admission delay at the maximum Training Session capacity | Up to 16 concurrent production-security initial Admission attempts on the exact Session Authority hardware and AUTH profile versions | Automated Test correlating attempt start, terminal result, and AUTH Audit Commit Unit evidence | Production Security Baseline |
| `DEFERRED-NFR-AUTHORITY-CAPABILITY-AVAILABILITY-001` | Deferred deployment-quality requirement | Deferred to the Platform Operations Baseline | `GOAL-TRAINING-001`, `REQ-AUTHORITY-SINGLE-SESSION-001`; the previous continuous-process target is incompatible with intentionally ephemeral authorities | Future infrastructure capability to launch and operate assigned authorities | Not defined; the future baseline must establish complete measurable acceptance conditions before approval | Platform Operations Baseline and operational evidence |
| `CONSTRAINT-NFR-TEAM-001` | Organizational constraint | Approved; mandatory for the initial baseline | Accepted permanent staffing boundary; constrains architecture and maintenance burden | First-party engineering and maintenance | Inspection of approved plans and concurrently assigned human roles | None |

## Ambiguity review

The requirement set was reviewed through the project-owner amendment of 2026-09-03 against the ambiguity checklist in the research guidance. Every current normative obligation has a stable identifier, subject, scope, threshold or closed profile reference, priority, rationale, owner, verification method, and pass/fail evidence. Exact build, script, Map, and applicable profile versions are evidence selected and recorded before an acceptance run. No definition-level ambiguity or unresolved current-baseline acceptance dependency remains; Session Authority capability availability is explicitly deferred until deployment architecture supplies a measurable subject and evidence boundary.

The Development Baseline sets no financial limit, delivery deadline, content iteration-time target, maximum planned-maintenance duration, or Session Authority capability-availability target. It requires no infrastructure redundancy, process failover, power redundancy, network high availability, scheduler, Kubernetes, or cluster platform. Those operational qualities belong to the future Platform Operations Baseline; production-security quality requirements belong to the future Production Security Baseline.

## Completion rule

Future NFR baseline versions are ready for approval when every retained NFR has a stable identifier, objective threshold, reproducible environment and workload, finite verification method, required evidence, priority, owner, rationale, trace, and no unresolved acceptance dependency; the ambiguity checklist in the research guidance has been completed; and the project owner confirms shared understanding and approves the exact version.
