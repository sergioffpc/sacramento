# Engagement Target Performance Profile

Status: Approved

Approval: Project owner, 2026-09-01

Profile identifier: `ENGAGEMENT-TARGET-001`

Use readiness: Not admitted until `ETP-VALIDATION-001` receives `Pass`.

Assessment baseline: [`PERF-BASELINE-001`](training-simulation-performance-assessment-requirements.md)

Purpose: Define the first versioned performance-comparison profile for a Rifleman engaging a sequence of targets at Standard difficulty.

Scope: Target-identification and engagement tasks in Desktop Mode.

Intended readers: Project owner, assessment designers, implementers,
verification authors, and Representative Evaluators.

Prerequisites: [Trainee Performance Assessment
Requirements](training-simulation-performance-assessment-requirements.md),
[Training Simulation Verification Plan](training-simulation-verification-plan.md),
and the applicable approved content and profiles.

Canonical information owner and approver: Project owner.

## Comparison conditions

**ETP-COMPARISON-001** — Every result under this profile MUST use and record these comparison conditions:

- Trainee role: Rifleman
- Difficulty: Standard
- Task: identify and engage a sequence of targets
- Position: standing
- Target distance: 25 metres
- Presentation environment: fixed indoor-range geometry and lighting identified by the execution record
- Equipment: the same exact approved Rifleman Loadout and weapon-profile versions for every compared result
- Required outputs: Training Feedback, Formal Assessment, and Leaderboard
- Session eligibility: every session with valid evidence contributes under `PERF-ELIGIBILITY-001`

A result MUST NOT be compared with a result produced under different values for any comparison condition.

## Target sequence

**ETP-SEQUENCE-001** — Exactly 10 targets MUST be presented one at a time in this fixed order:

`Valid, Valid, NonValid, Valid, Valid, NonValid, Valid, NonValid, Valid, Valid`

The classification of the current target MUST NOT be announced to the Trainee during its presentation.

**ETP-TIMING-001** — Each target MUST remain presented for five seconds. A two-second interval MUST follow each of the first nine targets and MUST be excluded from reaction-time measurement. A valid target MUST close on its first hit, its second shot, or timeout, whichever occurs first. A non-valid target MUST remain presented for the complete five seconds regardless of Trainee action.

**ETP-SHOT-RULES-001** — At most two shots are permitted while a valid target is open. A shot after closure MUST be an error and MUST NOT affect that target's result. A valid target with no shot before timeout MUST be a non-engagement error. Every shot at a non-valid target MUST be an error.

## Metric definitions

**ETP-METRICS-001** — All durations MUST use milliseconds. Intermediate calculations MUST retain full precision; displayed metrics and the final score MUST be rounded to two decimal places using round-half-up. The metrics MUST use these exact definitions:

| Metric | Definition |
| --- | --- |
| Target hits | Number of valid targets receiving at least one authoritative projectile collision inside the target scoring silhouette while open; integer from 0 to 7 |
| Shot hit rate | Authoritative hit shots on open valid targets divided by every shot fired during the task, multiplied by 100; zero when no shot is fired |
| Reaction time | For each valid target, elapsed time from authoritative presentation to the first shot; timeout without a shot is assigned 5,000 ms for aggregation |
| Mean reaction time | Arithmetic mean of the seven valid-target reaction times |
| Task completion time | Elapsed time from presentation of the first target until the tenth target closes, including inter-target intervals |
| Relevant task errors | One error per shot at a non-valid target, shot after target closure, and valid-target timeout without a shot |

**ETP-EVIDENCE-001** — The authoritative event record MUST identify the Trainee Identity, Training Session, task, target ordinal and classification, presentation and closure timestamps, every shot, every authoritative hit, and every relevant task error. Missing required evidence MUST invalidate the affected metric under `PERF-DATA-VALIDITY-001`.

## Leaderboard score

**ETP-SCORE-001** — The score MUST range from 0 to 100 and MUST equal the sum of these components:

| Component | Weight | Formula |
| --- | ---: | --- |
| Target hits | 40 | `40 × target_hits / 7` |
| Shot hit rate | 20 | `20 × shot_hit_rate / 100` |
| Reaction time | 15 | `15 × mean(clamp((5000 - reaction_time_ms) / 4500, 0, 1))` across the seven valid targets |
| Completion time | 10 | `10 × clamp((68000 - completion_time_ms) / 35000, 0, 1)` |
| Error control | 15 | `15 × clamp(1 - relevant_task_errors / 5, 0, 1)` |

`clamp(x, 0, 1)` returns 0 when `x < 0`, 1 when `x > 1`, and otherwise returns `x`.

**ETP-LEADERBOARD-001** — The Leaderboard MUST use the Trainee's highest eligible session score for the applicable period. Equal scores MUST be ordered by the earliest session-completion timestamp that achieved the score.

## Formal Assessment

**ETP-FORMAL-001** — The proposed Formal Assessment MUST report each criterion separately. Overall `Pass` MUST require every criterion to pass:

| Criterion | Pass threshold |
| --- | --- |
| Target engagement | At least 6 of 7 valid targets hit |
| Accuracy | Shot hit rate at least 70 percent |
| Reaction | Mean reaction time no greater than 2,000 ms |
| Completion | Task completion time no greater than 60,000 ms |
| Error control | No shot at a non-valid target and no more than one other relevant task error |

**ETP-FORMAL-VALIDITY-001** — The qualification MUST have no expiry. The result MUST become formally valid only after approval by an authorized evaluator under `PERF-FORMAL-APPROVAL-001`.

## Presentation and verification

**ETP-PRESENTATION-001** — Training Feedback MAY present current metrics during execution. The proposed Formal Assessment and Leaderboard update MUST be available no later than five seconds after the tenth target closes.

**ETP-VALIDATION-001** — Before this profile is admitted for Formal Assessment or Leaderboard use, at least two in-scope Representative Evaluators MUST independently confirm that its task, comparison conditions, metric interpretation, score weights, and Formal Assessment thresholds are appropriate for Rifleman training at Standard difficulty, and the project owner MUST approve the retained findings for this exact profile version.

**ETP-VERIFICATION-001** — Verification MUST use deterministic event fixtures covering zero and maximum results, every timeout and error class, exact threshold boundaries, score clamping, rounding, invalid evidence, historical profile-version preservation, best-score selection, and equal-score temporal ordering. The execution evidence MUST identify the exact build, this profile version, comparison conditions, input events, calculated metrics, score, assessment result, and publication timestamps.

| Requirement identifiers | Required methods | Required evidence | Evidence owner | Final approver |
| --- | --- | --- | --- | --- |
| `ETP-COMPARISON-001`, `ETP-SEQUENCE-001`, `ETP-TIMING-001`, `ETP-SHOT-RULES-001` | Automated Test, Inspection | Exact condition record and deterministic sequence executions covering every presentation, closure, interval, shot limit, timeout, and error boundary | Implementation team | Project owner |
| `ETP-METRICS-001`, `ETP-EVIDENCE-001`, `ETP-SCORE-001`, `ETP-LEADERBOARD-001` | Automated Test, Inspection | Event fixtures and independently calculated expected results covering every metric, component, clamp, rounding boundary, best-score choice, and temporal tie | Implementation team | Project owner |
| `ETP-FORMAL-001`, `ETP-FORMAL-VALIDITY-001`, `ETP-PRESENTATION-001` | Automated Test, Inspection | Each exact pass/fail boundary, approval transition, no-expiry state, and post-session publication timestamp under applicable reference profiles | Implementation team | Project owner |
| `ETP-VALIDATION-001` | Inspection, Representative Evaluation | Two independent in-scope findings and exact-version project-owner approval | Implementation team and Representative Evaluators | Project owner |
| `ETP-VERIFICATION-001` | Inspection | Complete obligation-level evidence package containing every required fixture and attributable disposition | Implementation team | Project owner |

Normative effect: This approved profile is mandatory for results identified as `ENGAGEMENT-TARGET-001`.
