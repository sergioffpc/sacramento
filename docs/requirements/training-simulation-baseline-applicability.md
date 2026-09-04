# Baseline Applicability Inventory Control

Status: Approved

Approval: Project owner, 2026-09-04

Inventory version: `BAI-004`

Approved predecessor: `BAI-003`, project owner, 2026-09-04

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
| Change impact | Approved Observability Contract successor changes controlled source versions without changing the normalized requirement population or dispositions |

| Controlled source | Version basis | SHA-256 |
| --- | --- | --- |
| `training-simulation-initial-requirements.md` | Approved Autonomous Recovery Subject reconciliation | `85909f1016a3eb89e3c1eb25370eea8872dccdf5389feb5613f5f5a1b575f9de` |
| `training-simulation-non-functional-requirements.md` | Approved `OBS-CONTRACT-004` reconciliation | `5bef2f87282a4eb8575d4766edde9319ad494a3dbfb725c041b504518b07294c` |
| `training-simulation-observability-contract.md` | Approved `OBS-CONTRACT-004` | `eaa4c2088f4ca9cfc9636a847ace54cdc03d41da54f45e6605ddce68888d316b` |
| `training-simulation-performance-assessment-requirements.md` | `PERF-BASELINE-001`, amended 2026-09-03 | `4d036de0500b7d0161dcf988fc40c2c0a53f9cfc69288c7c2c9f805755df01f9` |
| `training-simulation-performance-profile-engagement-target-001.md` | `ENGAGEMENT-TARGET-001` | `cc5f2fb21b692452d7fa12e34d05bfd83baded1eaf325f3c7bb754a79baae493` |
| `training-simulation-reference-hardware-profiles.md` | `RHP-SET-001` | `074dc42d25cf44800198b4207b8b90a2897ebe7109dadab4c3766e3cbc644095` |
| `training-simulation-verification-plan.md` | Approved `OBS-CONTRACT-004` evidence assignments | `fe9d83257d3093a9555249d2c440069676e99c7fe52a5335738b00454ddce45a` |
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

## `BAI-004` impact analysis

`BAI-004` preserves all 1,215 `BAI-003` requirement identifiers, dispositions,
milestones, and owners. It updates only the controlled versions of the
non-functional requirements, Observability Contract, and Verification Plan for
the approved `OBS-CONTRACT-004` reconciliation. Those source identities and
all predecessor-bound applicability, assignment, artifact, dependency, and
review evidence are `Affected`; no accepted product or Architecture Claim
evidence exists to retain as `Unaffected`. Exact impact traversal and approval
were re-evaluated under approved `EDI-003`; the project owner approved this
exact successor on 2026-09-04.
