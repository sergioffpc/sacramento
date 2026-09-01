# Training Simulation Trainee Performance Assessment Requirements

Status: Approved

Approval: Project owner, 2026-09-01

Baseline identifier: `PERF-BASELINE-001`

Latest approved amendment: Verification closure and `ENGAGEMENT-TARGET-001`, project owner, 2026-09-01

Purpose: Define the evidence, results, and boundaries for Training Feedback, Formal Assessment, and Leaderboard outputs about Trainee performance.

Scope: Performance assessment for authenticated Trainees in Desktop Mode and the Session Authority. Virtual-Reality Mode and instructor workflows require a later named baseline unless explicitly added here.

Intended readers: Project owner, requirements reviewers, architects, designers, implementers, operators, and verification authors.

Prerequisites: [Training Simulation context](../../CONTEXT.md), [Training Simulation Initial Requirements](training-simulation-initial-requirements.md), [Training Simulation Non-Functional Requirements](training-simulation-non-functional-requirements.md), [Training Simulation Observability Contract](training-simulation-observability-contract.md), and [Training Simulation Verification Plan](training-simulation-verification-plan.md).

Canonical information owner and approver: Project owner.

Normative effect: This approved document is the canonical Trainee Performance Assessment baseline for initial Desktop Mode and Session Authority scope.

## Boundary with technical observability

Performance assessment is a separate product concern from technical observability. The Observability Contract supplies evidence-linked events without personal data; an authorized assessment process may associate accepted evidence with the authenticated `Trainee Identity` under the requirements in this document.

Performance assessment is not a full `After-Action Review`. Training Session reconstruction, a tactical timeline, and detailed post-action analysis remain deferred by `DEFERRED-AAR-001`.

## Accepted decisions

**PERF-IDENTITY-001** — Every Training Feedback, Formal Assessment, and Leaderboard result MUST identify the authenticated `Trainee Identity` to which it applies. A Training Session-local Call Sign or display pseudonym MUST NOT be the authoritative identity for a result.

**PERF-SCOPE-001** — `Formal Assessment` MUST be limited to training qualification and competence decisions within the Training Simulation. It MUST NOT directly determine administrative, employment, promotion, or other personnel decisions. Any such use requires a separate external process with explicit human authority.

**PERF-METRICS-001** — The initial performance baseline MUST include, at minimum, target hits and hit rate, reaction time, task completion time, and relevant task errors. These metrics MUST be available as evidence for Training Feedback, Formal Assessment, and Leaderboard outputs, with output-specific calculation or eligibility rules permitted.

**PERF-GRANULARITY-001** — The assessment record MUST retain individual attempt/action measurements and aggregates for each task and Training Session. Individual measurements MUST support Training Feedback and result review; task and session aggregates MUST support Formal Assessment and Leaderboard calculations.

**PERF-COMPARABILITY-001** — A `Leaderboard` MUST compare results only within an explicitly identified comparison profile. At minimum, the profile MUST identify the task, Trainee role, difficulty, and any configuration difference that materially affects performance.

**PERF-VISIBILITY-001** — A Trainee MUST be able to view their own performance results. An authorized evaluator MAY view results for Trainees under their responsibility. A Leaderboard MUST expose only rank/order and a presentation identifier, not individual attempt details or other Trainees' detailed results.

**PERF-RETENTION-001** — Performance assessment records MUST be retained indefinitely and remain associated with the authenticated `Trainee Identity`. No automatic expiry or deletion period is defined by this requirements baseline.

**PERF-INTEGRITY-001** — A recorded performance result MUST NOT be overwritten or deleted as part of correction. A correction MUST preserve the prior value and record the author, timestamp, reason, and changed value.

**PERF-PERIOD-001** — A `Leaderboard` MUST declare its ranking period and comparison profile. The system MUST support both explicitly bounded periods (for example, a course or training cycle) and an all-time historical view.

**PERF-TIE-001** — When eligible Leaderboard results have equal scores, the result that first achieved that score MUST rank ahead of later results.

**PERF-SCORE-001** — Each comparison profile MUST define a fixed, versioned Leaderboard score formula and metric weights before results are collected. The same formula and weights MUST apply to all eligible Trainees in that profile.

**PERF-FORMAL-APPROVAL-001** — The system MAY calculate and present a proposed `Formal Assessment`, but the result MUST NOT become formally valid until an authorized evaluator explicitly approves it. The approved result MUST identify the evaluator and approval timestamp.

**PERF-FORMAL-RESULT-001** — A `Formal Assessment` MUST present the result of each pre-approved criterion and an overall pass/fail result. A Leaderboard score MUST NOT by itself determine either result.

**PERF-FORMAL-VALIDITY-001** — Each Formal Assessment profile MUST define the validity of an approved qualification as either an explicit expiry rule or no expiry. Expiry MUST change qualification status without deleting or altering the retained assessment history.

**PERF-METRIC-DEFINITION-001** — Each performance metric MUST have a versioned definition fixed before the Training Session. The definition MUST identify its input events, start and end conditions where applicable, unit, exclusions, precision, and rounding rule. Each result MUST identify the definition version used so that its calculation can be reproduced.

**PERF-DATA-VALIDITY-001** — When required evidence is missing or invalid, the affected metric MUST be marked invalid and MUST be excluded from Formal Assessment and Leaderboard calculations. The system MUST NOT silently estimate or substitute an incomplete result.

**PERF-EVENTS-001** — The minimum performance-event inventory MUST include stimulus presented, attempt/action performed, target hit or miss, task started and completed, and relevant task error. Every event MUST carry the identifiers and timestamp needed to associate it with the authenticated Trainee, Training Session, and task.

**PERF-TIME-001** — Reaction and task-completion durations MUST be measured and presented in milliseconds. Cross-machine timing MUST use the clock-synchronization requirements defined by the Observability Contract; a separate assessment time base MUST NOT be introduced.

**PERF-ELIGIBILITY-001** — Every Training Session with valid performance evidence MUST contribute to Training Feedback, Formal Assessment, and the applicable Leaderboard. The system MUST NOT exclude a valid session by classifying it as practice-only.

**PERF-LEADERBOARD-AGGREGATION-001** — Within a Leaderboard period and comparison profile, each Trainee MUST be ranked by their highest eligible session score. All eligible session results MUST remain retained and available to the other assessment outputs.

**PERF-FORMAL-AGGREGATION-001** — Each Training Session MUST produce its own proposed Formal Assessment result. The Trainee's current qualification status MUST be determined by the most recently approved Formal Assessment, while every prior assessment remains in the retained history.

**PERF-AUTHORITY-001** — Authorization to view, approve, or correct performance assessments MUST be derived from the external identity and authorization authority already used by the Training Simulation. The performance-assessment capability MUST NOT create accounts or administer authorization assignments.

**PERF-PERMISSIONS-001** — Permission to view, approve, and correct performance assessments MUST be granted independently. Possession of one permission MUST NOT imply either of the others.

**PERF-LEADERBOARD-IDENTIFIER-001** — A Leaderboard MUST display the Trainee presentation name supplied by the external identity authority. The authoritative result association MUST remain the authenticated `Trainee Identity`; the Training Simulation MUST NOT administer a separate Leaderboard alias.

**PERF-PROFILES-001** — Exact metric formulas, Leaderboard weights, and Formal Assessment thresholds MUST be defined in versioned assessment profiles approved before use. A profile MUST identify its task, role, difficulty, and materially relevant configuration.

**PERF-PROFILE-VALIDATION-001** — Before an assessment profile is admitted for Formal Assessment or Leaderboard use, at least two in-scope Representative Evaluators MUST independently confirm that its task, comparison conditions, metric interpretation, score weights, and Formal Assessment thresholds are appropriate for the declared training role and difficulty, and the project owner MUST approve the exact profile version and retained findings.

The first approved profile is [`ENGAGEMENT-TARGET-001`](training-simulation-performance-profile-engagement-target-001.md), for Rifleman at Standard difficulty.

**PERF-PROFILE-EFFECT-001** — A new assessment-profile version MUST apply only to Training Sessions started after that version becomes effective. Historical results MUST retain their original profile version and MUST NOT be automatically recalculated under a later version.

**PERF-PRESENTATION-001** — Training Feedback metrics MAY be presented during an active Training Session. A proposed Formal Assessment and the applicable Leaderboard update MUST be consolidated only after the Training Session ends.

**PERF-AVAILABILITY-001** — The proposed Formal Assessment and updated applicable Leaderboard MUST be available no later than five seconds after the Training Session ends, measured under the approved reference hardware and workload profiles.

The three outputs are independent:

- `Training Feedback` supports learning and improvement within or after a session;
- `Formal Assessment` evaluates fixed pre-approved criteria and is not derived from relative rank; and
- `Leaderboard` orders eligible Trainees within an explicitly defined comparison scope.

## Verification catalogue

| Requirement identifiers | Required methods | Required evidence | Evidence owner | Final approver |
| --- | --- | --- | --- | --- |
| `PERF-IDENTITY-001`, `PERF-SCOPE-001` | Automated Test, Inspection | Identity-bound result records; rejection of Call Sign as authoritative identity; inspection of the training-only decision boundary | Implementation team | Project owner |
| `PERF-METRICS-001`, `PERF-GRANULARITY-001`, `PERF-METRIC-DEFINITION-001`, `PERF-DATA-VALIDITY-001`, `PERF-EVENTS-001`, `PERF-TIME-001` | Automated Test, Inspection | Versioned metric definitions and deterministic event fixtures covering individual measurements, aggregates, units, rounding, missing evidence, invalid evidence, and cross-machine timing | Implementation team | Project owner |
| `PERF-COMPARABILITY-001`, `PERF-PERIOD-001`, `PERF-TIE-001`, `PERF-SCORE-001`, `PERF-ELIGIBILITY-001`, `PERF-LEADERBOARD-AGGREGATION-001` | Automated Test, Inspection | Positive and negative comparison-profile cases; bounded and all-time periods; equal-score ordering; fixed score versions; all-session eligibility; best-score selection | Implementation team | Project owner |
| `PERF-VISIBILITY-001`, `PERF-AUTHORITY-001`, `PERF-PERMISSIONS-001`, `PERF-LEADERBOARD-IDENTIFIER-001` | Automated Test, Inspection | Role and ownership access matrix; denied cross-Trainee detail access; independent permission cases; external identity and presentation-name traces | Implementation team | Project owner |
| `PERF-RETENTION-001`, `PERF-INTEGRITY-001`, `PERF-PROFILE-EFFECT-001` | Automated Test, Inspection | Retention configuration; immutable correction history; preserved historical result and profile version after profile change | Implementation team | Project owner |
| `PERF-FORMAL-APPROVAL-001`, `PERF-FORMAL-RESULT-001`, `PERF-FORMAL-VALIDITY-001`, `PERF-FORMAL-AGGREGATION-001` | Automated Test, Inspection | Proposed and approved assessment state transitions; evaluator identity and timestamp; criterion and overall results; expiry/no-expiry cases; latest-approved qualification state with retained history | Implementation team | Project owner |
| `PERF-PROFILES-001`, `PERF-PROFILE-VALIDATION-001` | Inspection, Representative Evaluation | Exact versioned profile; two independently submitted in-scope findings covering task, conditions, metric meaning, weights, thresholds, role and difficulty; project-owner approval | Implementation team and Representative Evaluators | Project owner |
| `PERF-PRESENTATION-001`, `PERF-AVAILABILITY-001` | Automated Test | Active-session feedback cases and post-session consolidation timestamps under every applicable approved reference hardware and workload profile | Implementation team | Project owner |
| `PERF-VERIFICATION-001` | Inspection | Approved procedures enumerating every independently fail-able obligation and retaining separately attributable dispositions; method-applicability record confirming where Representative Evaluation is required | Implementation team | Project owner |

**PERF-VERIFICATION-001** — Every normative clause within a listed identifier MUST receive a separately attributable `Pass`, `Fail`, or `Blocked` result under the approved Verification Plan. Objective calculation evidence MUST NOT substitute for Representative Evaluation where `PERF-PROFILE-VALIDATION-001` requires it.

## Ambiguity review

The baseline has a closed output boundary, identity association, minimum event and metric inventory, comparison scope, retention rule, access model, aggregation rules, profile-version behavior, response-time threshold, verification method, evidence owner, and final approver. Exact task formulas and thresholds belong only to approved assessment profiles. Full After-Action Review and personnel decisions remain outside this baseline.

## Completion rule

Future baseline versions are ready for approval when every retained metric and output has a stable identifier, fixed input and comparison scope, objective calculation, evidence path, privacy and access rule, retention rule, and project-owner approval.
