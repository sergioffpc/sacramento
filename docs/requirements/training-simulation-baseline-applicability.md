# Baseline Applicability Inventory Control

Status: Candidate successor; project-owner approval pending

Inventory version: `BAI-002`

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
| Approval | Candidate — project-owner approval pending |
| Change impact | Reconciled — no source or classification change pending |

| Controlled source | Version basis | SHA-256 |
| --- | --- | --- |
| `training-simulation-initial-requirements.md` | Candidate documentation-control amendment | `706938fbe3cb4ee616cd882e5981c3c9f519357a19114e4c48a6827e518fe574` |
| `training-simulation-non-functional-requirements.md` | Approved baseline amended 2026-09-03 | `8a024d6b7538f04e19df6dcae66c68160b2b6b474423d5d52f43a9fbee6ae092` |
| `training-simulation-observability-contract.md` | `OBS-CONTRACT-003` | `45c5392ca799388eac588ad54a5aa9e980ff4261de3b2b90fa0ba524f4a1f592` |
| `training-simulation-performance-assessment-requirements.md` | `PERF-BASELINE-001`, amended 2026-09-03 | `4d036de0500b7d0161dcf988fc40c2c0a53f9cfc69288c7c2c9f805755df01f9` |
| `training-simulation-performance-profile-engagement-target-001.md` | `ENGAGEMENT-TARGET-001` | `cc5f2fb21b692452d7fa12e34d05bfd83baded1eaf325f3c7bb754a79baae493` |
| `training-simulation-reference-hardware-profiles.md` | `RHP-SET-001` | `074dc42d25cf44800198b4207b8b90a2897ebe7109dadab4c3766e3cbc644095` |
| `training-simulation-verification-plan.md` | Candidate normalized-assignment amendment | `aa366423a0f6f6a469765491ee2c2d822b7c7eb8f977f9efe20ae62caa09e59e` |

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

The dataset contains 1,148 exactly-once entries: 928 `Included`, 201 `Future`,
and 19 `Not Applicable`. Normalization changes representation only; every
`BAI-001` disposition and owner is preserved in `BAI-002`.
