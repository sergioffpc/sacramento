# Baseline Applicability Inventory Control

Status: Approved

Approval: Project owner, 2026-09-04

Inventory version: `BAI-003`

Purpose: Control the normalized Development Baseline applicability dataset.

Scope: Global identity, provenance, schema, and approval state for the per-requirement dispositions stored in the accompanying CSV.

Intended readers: Project owner, requirements reviewers, architects, implementers, and verification authors.

Prerequisites: The requirement sources listed below and the canonical applicability CSV.

Canonical information owner: Project owner.

## Global fields

| Field | Value |
| --- | --- |
| Baseline | `Development Baseline` |
| Entry identity | `BAI-<requirement_identifier>` |
| Approval | Project owner, 2026-09-04 |
| Change impact | Approved Autonomous Participant population reconciled; independent evidence review passed |

| Controlled source | Version basis | SHA-256 |
| --- | --- | --- |
| `training-simulation-initial-requirements.md` | Approved Autonomous Recovery Subject reconciliation | `85909f1016a3eb89e3c1eb25370eea8872dccdf5389feb5613f5f5a1b575f9de` |
| `training-simulation-non-functional-requirements.md` | Approved baseline amended 2026-09-03 | `8a024d6b7538f04e19df6dcae66c68160b2b6b474423d5d52f43a9fbee6ae092` |
| `training-simulation-observability-contract.md` | `OBS-CONTRACT-003` | `45c5392ca799388eac588ad54a5aa9e980ff4261de3b2b90fa0ba524f4a1f592` |
| `training-simulation-performance-assessment-requirements.md` | `PERF-BASELINE-001`, amended 2026-09-03 | `4d036de0500b7d0161dcf988fc40c2c0a53f9cfc69288c7c2c9f805755df01f9` |
| `training-simulation-performance-profile-engagement-target-001.md` | `ENGAGEMENT-TARGET-001` | `cc5f2fb21b692452d7fa12e34d05bfd83baded1eaf325f3c7bb754a79baae493` |
| `training-simulation-reference-hardware-profiles.md` | `RHP-SET-001` | `074dc42d25cf44800198b4207b8b90a2897ebe7109dadab4c3766e3cbc644095` |
| `training-simulation-verification-plan.md` | Approved Autonomous Participant assignments | `1310a09886771ae2552b968ac8f32856ec9f6f66e058566af91f0c9bb19b26fb` |
| `training-simulation-autonomous-participant-requirements.md` | Approved `AUTONOMOUS-PARTICIPANT-BASELINE-001` | `58acf4f8b6065f45903e198ca28fd326a971067272930ff0f6cb192515ee477d` |

The row number is the sequence. The source document is the unique controlled
source defining the row's requirement identifier. Source versions and hashes
are validated by `scripts/validate-baseline-applicability-inventory.sh` and are
updated only with a reconciled successor.

## Dataset

The [normalized CSV](training-simulation-baseline-applicability-inventory.csv)
stores only values that can vary per requirement: identifier, disposition,
milestone or justification, and responsible owner. `Included` rows belong to
the Development Baseline; `Future` rows name their milestone; `Not Applicable`
rows carry their approved objective-scope justification.

The approved dataset contains 1,215 exactly-once entries: 928 `Included`, 268
`Future`, and 19 `Not Applicable`. Every `BAI-002` disposition and owner is
preserved. The 67 new requirement identifiers are `Future` under the
`Autonomous Participant baseline`; `DEFERRED-RECOVERY-SUBJECT-001` remains
`Future` under the distinct `Autonomous Recovery Subject Baseline`.

## `BAI-003` impact analysis

`BAI-003` adds the complete approved Autonomous Participant requirement
population without moving any requirement into the Development Baseline or
changing an existing disposition, milestone, or owner. The explanatory wording
of `DEFERRED-RECOVERY-SUBJECT-001` now records that its narrower future baseline
may depend on the Autonomous Participant baseline but cannot cover the general
role. Every new identifier and the changed source versions are affected; all
predecessor-bound validation, assignment, artifact, dependency, and review
evidence was re-evaluated under approved `EDI-002`. No accepted product
or Architecture Claim evidence exists to retain as `Unaffected`.
