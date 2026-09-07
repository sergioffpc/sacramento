# Baseline Applicability Inventory Control

Status: Candidate successor; project-owner approval pending

Last meaningful change: 2026-09-04

Inventory version: `BAI-006`

Approved predecessor: `BAI-005`, project owner, 2026-09-04

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
| Approval | Pending project-owner approval |
| Change impact | Clarifies existing non-goal ownership, verification-assignment ownership, and Engagement Target presentation/AUTH semantics without changing the requirement population or any applicability disposition |

| Controlled source | Version basis | SHA-256 |
| --- | --- | --- |
| `training-simulation-initial-requirements.md` | Development Baseline; candidate documentation-audit clarification | `dc70b8f791e02b8a7e242f2986b16e0524dd8365128ff2278d303c4838714970` |
| `training-simulation-non-functional-requirements.md` | Approved `OBS-CONTRACT-004` reconciliation | `5bef2f87282a4eb8575d4766edde9319ad494a3dbfb725c041b504518b07294c` |
| `training-simulation-observability-contract.md` | Approved process-lifecycle terminology amendment | `038b25be192b5a5326a51ac8eb4545d22f377a70a17fa3e0ffa912125b9c7224` |
| `training-simulation-performance-assessment-requirements.md` | `PERF-BASELINE-001`; candidate assignment-ownership clarification | `e6d3402c8fe723ce01d782e2ec9bea36a5e260bd912339ff5849aaed0095d7ed` |
| `training-simulation-performance-profile-engagement-target-001.md` | `ENGAGEMENT-TARGET-001`; candidate presentation/AUTH clarification | `7ab533810292e60c5836117d5130440726794521dc8e442d3cef84d479896dd6` |
| `training-simulation-reference-hardware-profiles.md` | `RHP-SET-001` | `074dc42d25cf44800198b4207b8b90a2897ebe7109dadab4c3766e3cbc644095` |
| `training-simulation-verification-plan.md` | Approved `SDB-001` and offline-tool evidence assignments | `f9d9fdcbef474d9b5154defdb00987e3924047ed3d2318dbd3b4ddc3a3ecc746` |
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

The candidate dataset contains 1,227 exactly-once entries: 939 `Included`, 269
`Future`, and 19 `Not Applicable`. Every `BAI-004` disposition and owner is
preserved. Eleven new software-design, runtime/client, and cooker obligations
are `Included`; `DEFERRED-CONTENT-COOKER-PLATFORM-001` is `Future` under the
`Content Cooker Platform Baseline`.

## `BAI-006` impact analysis

`BAI-006` preserves all 1,227 `BAI-005` entries, dispositions, milestones,
justifications, and owners. Only controlled-source wording and hashes change.
The changed source identities and all predecessor-bound applicability,
assignment, artifact, dependency, design, and review evidence are `Affected`;
no accepted product evidence is retained as `Unaffected`. Exact impact
traversal remains governed by the Evidence Dependency Inventory. Approval of
this exact successor remains pending.
