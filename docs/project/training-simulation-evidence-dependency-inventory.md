# Training Simulation Evidence Dependency Inventory

Status: Candidate; project-owner approval pending

Inventory version: `EDI-007`

Package SHA-256: `071a30be9e35896625046b2af80f39cdffe8bea555f5acf371baf7b7a4d822b0`

Approved predecessor: `EDI-006@sha256:eb8ee482822dc5a1d1b930de0f53b191b75e20eb30bc16314b07ad2a34119358`, project owner, 2026-09-04

Version basis: The package SHA-256 and the exact approved predecessor
inventory identities recorded below. A registered node, classification, or
directed relation change creates a successor; populating a pre-registered
immutable evidence record does not.

Purpose: Register the current evidence-dependency graph used to decide which
accepted evidence a change may affect and to prevent acceptance through an
unregistered or uncertain dependency.

Scope: Every current requirement, governed baseline artifact, Architecture
Claim, architecture-level product component, realized Software Architecture
Description view, repository verification dependency, and evidence record
known at this inventory version. Product-instance categories with no current
authoritative population are closed explicitly at zero rather than inferred.

Intended readers: Project owner, architects, implementers, verification
authors, reviewers, evidence custodians, and repository agents.

Prerequisites: Approved [Baseline Applicability Inventory
`BAI-006`](../requirements/training-simulation-baseline-applicability.md),
approved [Baseline Artifact Inventory
`BARTINV-009`](training-simulation-baseline-artifact-inventory.md), approved
[Documentation Inventory
`DOCINV-012`](training-simulation-documentation-inventory.md),
[ADR-0010](../adr/0010-close-cross-cutting-architecture-and-verification.md),
and the [Verification
Plan](../requirements/training-simulation-verification-plan.md).

Canonical information owner and approver: Project owner.

## Table of contents

- [Inventory package](#inventory-package)
- [Who uses it and when](#who-uses-it-and-when)
- [Effective node population](#effective-node-population)
- [Node classes and reconciliation](#node-classes-and-reconciliation)
- [Directed relation semantics](#directed-relation-semantics)
- [Pre-registered outputs](#pre-registered-outputs)
- [Impact-analysis procedure](#impact-analysis-procedure)
- [Coverage validation](#coverage-validation)
- [Demonstrated impact cases](#demonstrated-impact-cases)
- [Current acceptance boundary](#current-acceptance-boundary)
- [`EDI-007` impact analysis](#edi-006-impact-analysis)
- [Change control](#change-control)

## Inventory package

`EDI-007` is one atomic version comprising this control document, the
[supplemental node register](training-simulation-evidence-dependency-nodes.csv),
the [supplemental directed-relation
register](training-simulation-evidence-dependency-relations.csv), and the
[impact-case register](training-simulation-evidence-impact-cases.csv). The
effective graph is the deterministic union of those registers and the exact
imports described below; the supplemental files do not duplicate predecessor
inventory rows.

The digest hashes the four sorted paths and contents after replacing every
embedded copy of its own digest and the cyclic `BARTINV-009` package digest
with 64 zeroes. This makes the EDI and Baseline Artifact inventories mutually
addressable without pretending that a cryptographic fixed point exists. Every
non-package file version remains the exact version supplied by its authoritative
inventory.

| Imported inventory | Exact identity |
| --- | --- |
| Baseline Applicability Inventory | Candidate `BAI-006`; project-owner approval pending |
| Baseline Artifact Inventory | Candidate `BARTINV-009@sha256:c2afc4ba1342d34e204f8db094c0eeea9e7f24329e2b93a7c597f9862ede6b0e` |
| Documentation Inventory | Candidate `DOCINV-012` repository tree |

Repository discovery and graph traversal prove structural population and
reachability only. They cannot decide semantic canonicality, completeness of a
human-authored dependency, obligation-level invariance, or approval.

## Who uses it and when

Verification authors consult the approved graph before approving a procedure
and pre-register its inputs, outputs, environment, dependencies, obligation
keys, and evidence-record identities. Executors bind an execution to this exact
inventory version before starting and may populate only those registered output
records. Reviewers and evidence custodians reject `Pass` when any used node or
relation is absent, stale, unclassified, or bound to another version.

Before either code-review axis starts, the implementation team stages only the
issue change and validates its canonicalized SHA-256 against `EDI-DATA-001`.
Canonicalization removes package digests and approval-only lines so the reviewed
substantive snapshot remains identical when exact-version approval is recorded.
The Spec reviewer fetches issue #53 directly, hashes the emitted body including
its trailing newline, and validates it against `EDI-DATA-002`; a mismatch stops
the review as stale input.

After any governed change, the implementation team starts impact traversal at
every changed node and records all reachable obligations, procedures,
environments, profiles, content, and evidence. The project owner audits and
approves the exact inventory and every `Unaffected` decision. Repository agents
reach this procedure before changing a registered node or relation, executing a
verification or inventory validator, accepting evidence, or classifying change
impact.

## Effective node population

The validator materializes one effective node for each exact source identity:

1. every `BAI-006` row, using its requirement identifier as a `Requirement
   Identifier` node;
2. every `BARTINV-009` row, using its stable artifact identifier and classifying
   it as a `Configuration Item`, `Verification Procedure`, `Input Data Set`, or
   `Governed Artifact` according to the reviewed path rules in the validator;
3. every Architecture Claim trace row, using its `AC-*` key as an `Architecture
   Claim` node; and
4. every row in the supplemental node register, which supplies the current
   architecture-level product components, realized Software Architecture
Description views, exact validation environment, procedure-specific data,
review and approval procedures, and pre-registered outputs.

The validator derives requirement-to-artifact traces from `BARTINV-009`, and
requirement-to-claim plus governing-artifact-to-claim mappings from the exact
Architecture Claim register. It adds the reviewed explicit relations from the
supplemental relation register. No imported source row is silently copied or
renumbered.

## Node classes and reconciliation

| Required class | Authoritative population | `EDI-007` reconciliation |
| --- | --- | --- |
| `Requirement Identifier` | `BAI-006` | Every row imported exactly once. |
| `Obligation Key` | Approved verification procedures | Zero current approved obligation keys; any procedure execution or `Pass` remains blocked until keys are registered in a successor. |
| `Product Component` | ARCHSPEC-0004 responsibility-module and runtime-composition tables | Every current architecture-level module and runtime registered explicitly. |
| `Configuration Item` | `BARTINV-009` Implementation artifacts | Every current row imported exactly once under the reviewed class mapping. |
| `Scenario` | Approved Scenario inventory | Zero current approved Scenario versions; prose examples do not create an admitted instance. |
| `Map` | Approved Map inventory | Zero current approved Map versions. |
| `Content Item` | Approved content and catalogue inventories | Zero current admitted content items. |
| `Approved Profile` | Approved Profile inventory | Zero current admitted Approved Profile versions; Reference Hardware and Performance Profiles retain their distinct governed-artifact identities. |
| `Verification Procedure` | `BARTINV-009` executable verification artifacts and this inventory's explicit review/approval procedures | Every current executable or explicit procedure imported or registered exactly once, with declared inputs or dependencies and at least one pre-registered output. |
| `Input Data Set` | `BARTINV-009` verification configuration and inventory datasets plus this inventory's supplemental procedure data | Every current row imported or registered exactly once under the reviewed class mapping. |
| `Verification Environment` | This inventory's supplemental register | Exact repository validation environment registered before execution. |
| `Evidence Record` | This inventory's pre-registered output population | Inventory validations, repository gates, Standards review, Spec review, and exact-version approval identities registered before production. |
| `Architecture Claim` | `BARTINV-009` Architecture Claim trace register | Every `AC-*` row imported exactly once with its governing artifact mapping. |
| `Software Architecture Description View` | ARCHSPEC-0010 view-set table and `SAD-003` | Every selected view registered under its surviving `EDI-VIEW-*` identity with the exact current SAD file version and section location. |
| `Software Design Document` | `BARTINV-009` numbered files under `docs/design/` | Every `SDD-0001` through `SDD-0004` artifact imported exactly once with its exact hash. |
| `Design Commitment` | Candidate `SDB-002-DC` | All 48 `DC-*` rows are imported exactly once; requirement, Architecture Claim, SAD view, and governing-SDD relations are derived from their exact traces. `DAC-*` entries remain SDD-local acceptance criteria rather than approved product-evidence Obligation Keys. |
| `Governed Artifact` | Remaining `BARTINV-009` rows | Every remaining architecture, design, and verification artifact imported exactly once. |

A zero population is a closed current result, not permission to omit a newly
discovered item. The first item in any zero-population class requires its
applicable authoritative inventory, a successor EDI, coverage validation, and
rerun of every affected verification before acceptance.

## Directed relation semantics

Every edge points from the node whose change can affect the dependent node.
The admitted types are `governs`, `defines`, `depends-on`, `maps-to`,
`input-to`, `verified-by`, `produces`, and `supports-approval`. The effective
relation identifier is stable; surviving relations keep their identity and
retired identities are never reused.

Derived `governs` edges run from each exact requirement to its traced artifact
and Architecture Claims. Derived `defines` edges run from each governing
architecture artifact to its exact claims. Explicit edges retain module
dependencies, claim-to-view mappings, procedure inputs, produced records, and
approval support. Reversing an edge changes impact meaning and therefore
requires a successor inventory.

## Pre-registered outputs

`EDI-EVID-001` through `EDI-EVID-012` are immutable record identities for
inventory validations, repository gates, Standards review, Spec review, and
project-owner exact-version approval. `EDI-DATA-006` is the pre-registered
generated assignment output. Their classifications and incoming relations are
fixed before execution. Populating their external execution results changes
neither identity nor graph relation and therefore does not create a successor
under `PROCESS-EVIDENCE-DEPENDENCY-007`.

An execution that produces another output, uses another input, changes a
classification or relation, or cannot populate the registered identity stops
with affected-set membership `Uncertain`. The implementation team creates a
successor, revalidates coverage, and reruns affected work. Validation terminates
only when every discovered output and edge already exists in the approved
version and no unregistered output is pending.

## Impact-analysis procedure

1. Bind the record to the changed baseline, exact changed node identities, and
   current approved EDI identity. Completion requires every changed item to be
   registered and current.
2. Traverse every outgoing edge transitively without choosing a preferred path.
   Completion requires the union of all directly and transitively reachable
   nodes, including multiple paths and exact Architecture Claim-to-view paths.
3. Classify missing, stale, unclassified, or ambiguous nodes and edges as
   `Uncertain`; the affected set then includes the uncertain branch and every
   potentially dependent verification. Completion requires reverification, not
   an `Unaffected` inference.
4. Classify an accepted result `Unaffected` only when the approved graph has no
   path to it, or a reproducible analysis proves the changed baseline still
   satisfies its exact obligation-level acceptance criterion with `Pass`.
   Completion requires the inputs, analysis, result, changed baseline,
   criterion, disposition, EDI identity, and project-owner approval.
5. Classify every other reachable or uncertain result `Affected` and rerun it
   against the changed baseline. Completion requires new attributable evidence.
6. When the EDI changes, repeat this procedure for every retained analysis that
   names its predecessor. Completion requires no predecessor-bound analysis and
   no pending unregistered output.

## Coverage validation

Run from the repository root:

```sh
python3 scripts/validate-evidence-dependency-inventory.py
```

The validator checks package identity, exact approved predecessor versions,
node and edge schemas, stable uniqueness, imported population reconciliation,
all Architecture Claim artifact mappings, every procedure's declared inputs or
dependencies and outputs, class closure, and calculated impact cases. It
injects stale, unclassified, missing-relation, invariance, and predecessor-bound
conditions and calculates the required dispositions. Those checks do not grant
approval or prove that a human has named every semantically real dependency.

## Demonstrated impact cases

The impact-case register contains direct, transitive, multiple-path,
absent-path, stale, unclassified, uncertain, obligation-level invariance, and
inventory-successor re-evaluation cases. Positive traversal cases use the real
effective graph. Fault cases inject one declared defect and require
`Affected — reverification required`; the absent-path case is the only graph-
only `Unaffected` case. The invariance case is eligible only with a reproducible
obligation-level proof and project-owner approval, neither of which traversal
can manufacture.

## Current acceptance boundary

Candidate `EDI-007` registers and coverage-validates the current graph without
claiming product realization or accepted product evidence. The current zero
populations and absence of approved obligation keys prohibit product evidence
from receiving `Pass`. Architecture Claims and all nine current Software
Architecture Description views participate in impact traversal through exact
governing artifact and claim mappings. Their realization records architecture
description coverage only and do not change product realization or evidence
state.

Project-owner approval remains pending for this exact package identity.
Structural
validation cannot approve it, and approval cannot convert missing product
instances, obligation keys, procedures, or evidence into a nonzero population.

## `EDI-007` impact analysis

This successor preserves the approved `EDI-006` non-design node and relation
population, imports candidate `BARTINV-009` and `DOCINV-012`, updates exact
versions for the documentation-audit corrections, and imports candidate
`SDB-002`. The design successor retains 26 predecessor Design Commitment keys,
adds 22 proposed keys, and derives their exact requirement, Architecture Claim,
SAD-view, and SDD relations. No Scenario, Map, Content Item, Runtime Resource
Type, Approved Profile, or approved obligation key is admitted.

`BART-ARC-024`, `BART-DES-014` through `BART-DES-019`, all 48 candidate Design
Commitments, all nine SAD views, the recursively affected inventory and
validator artifacts, the fixed review input, and every predecessor-bound
validation and review result are `Affected`. No accepted product or Architecture
Claim evidence exists to retain as `Unaffected`. Every retained analysis bound
to `EDI-006` requires re-evaluation; coverage validation, the two independent
SDB reviews, and exact-version project-owner approval remain pending.

Candidate `EDI-007` traversal starts at `BART-ARC-004` through `BART-ARC-006`,
`BART-ARC-013`, `BART-ARC-014`, `BART-ARC-017`, `BART-ARC-018`, `BART-ARC-020`,
`BART-ARC-024`, `BART-DES-001`, `BART-DES-004`, `BART-DES-007`,
`BART-DES-008`, `BART-DES-011`, `BART-DES-012`, `BART-IMP-001` through
`BART-IMP-003`, `BART-VER-001`, `BART-VER-002`, `BART-VER-007` through
`BART-VER-009`, `BART-VER-015`, `BART-VER-018`, `BART-VER-019`,
`BART-VER-021`, and `BART-VER-022`.

The complete reachable union is `AC-CONCURRENCY-001` through
`AC-CONCURRENCY-008`, `AC-CROSSCUTTING-001` through `AC-CROSSCUTTING-012`,
`AC-DEPLOYMENT-001` through `AC-DEPLOYMENT-010`, `AC-MEMORY-001` through
`AC-MEMORY-009`, `AC-RUNTIME-001` through `AC-RUNTIME-008`, `BART-DES-016`
through `BART-DES-019`, `BART-VER-013` through `BART-VER-016`, `BART-VER-022`,
`BART-VER-023`, every `DC-AUTHORITY-*`, `DC-CLIENT-*`, `DC-COOKER-*`, and
`DC-PROCESS-*` row, `EDI-DATA-005`, `EDI-DATA-006`, `EDI-EVID-001` through
`EDI-EVID-005`, `EDI-EVID-009` through `EDI-EVID-011`, `EDI-EVID-013`,
`EDI-PROC-001` through `EDI-PROC-003`, and `EDI-VIEW-001` through
`EDI-VIEW-009`. Every member is `Affected`; no invariance or `Unaffected`
disposition is claimed. The fixed staged-diff input additionally binds every
changed file to both review procedures.

The following table retains the predecessor's demonstrated traversal cases as
regression context; it is not the candidate successor's changed-start set.

| Changed start population | Complete reachable affected set |
|---|---|
| `NFR-OBSERVABILITY-CORE-001` | `BART-DES-006`; `BART-VER-014`; `EDI-EVID-009` |
| `BART-DES-003`; `BART-DES-005`; `BART-DES-006` | Empty set; each artifact remains `Affected` because it is present in `EDI-DATA-001`, but the approved graph has no approved downstream product-evidence path from the artifact node |
| `BART-DES-014` through `BART-DES-019` | Empty outgoing set; each candidate SDB artifact and its derived Design Commitment population remains directly `Affected` through the fixed staged diff, with product `Pass` blocked by the zero approved Obligation Key population |
| `BART-VER-012` | `BART-VER-013`; `BART-VER-014`; `EDI-DATA-005`; `EDI-DATA-006`; `EDI-EVID-009` |
| `BART-VER-006`; `BART-VER-008` | `BART-VER-015`; `BART-VER-022`; `EDI-EVID-001`; `EDI-EVID-002`; `EDI-EVID-005`; `EDI-EVID-010`; `EDI-PROC-003` |
| `BART-VER-007`; `BART-VER-011` | `BART-VER-022`; `EDI-EVID-001`; `EDI-EVID-002`; `EDI-EVID-005`; `EDI-PROC-003` |
| `BART-VER-009` | `BART-VER-016`; `BART-VER-022`; `EDI-EVID-001`; `EDI-EVID-002`; `EDI-EVID-005`; `EDI-EVID-011`; `EDI-PROC-003` |
| `BART-VER-010` | `BART-VER-014`; `BART-VER-015`; `BART-VER-022`; `EDI-EVID-001`; `EDI-EVID-002`; `EDI-EVID-005`; `EDI-EVID-009`; `EDI-EVID-010`; `EDI-PROC-003` |
| `BART-VER-013` | `EDI-DATA-006` |
| `BART-VER-014` | `EDI-EVID-009` |
| `BART-VER-015` | `EDI-EVID-010` |
| `BART-VER-018` | `BART-VER-022`; `EDI-EVID-001`; `EDI-EVID-002`; `EDI-EVID-003`; `EDI-EVID-004`; `EDI-EVID-005`; `EDI-PROC-001`; `EDI-PROC-002`; `EDI-PROC-003`; `EDI-VIEW-008` |
| `BART-VER-019`; `BART-VER-020`; `BART-VER-021` | `BART-VER-022`; `EDI-EVID-001`; `EDI-EVID-002`; `EDI-EVID-005`; `EDI-PROC-003` |
| `BART-VER-022` | `EDI-EVID-001`; `EDI-EVID-002`; `EDI-EVID-005`; `EDI-PROC-003` |
| `BART-ARC-024` | `EDI-VIEW-001` through `EDI-VIEW-009` |
| `EDI-VIEW-001` through `EDI-VIEW-009` | Empty set; each changed view remains directly `Affected` |
| `EDI-PROC-002` | `EDI-EVID-004`; `EDI-EVID-005`; `EDI-PROC-003` |
| `EDI-DATA-001` | `EDI-EVID-003`; `EDI-EVID-004`; `EDI-EVID-005`; `EDI-PROC-001`; `EDI-PROC-002`; `EDI-PROC-003` |
| `EDI-DATA-002` | `EDI-EVID-004`; `EDI-EVID-005`; `EDI-PROC-002`; `EDI-PROC-003` |
| `EDI-DATA-005` | `BART-VER-013`; `BART-VER-014`; `EDI-DATA-006`; `EDI-EVID-009` |
| `EDI-DATA-007` | `BART-VER-016`; `EDI-EVID-011` |

The three explicit source-to-`EDI-DATA-005` relations keep changed assignment
sources and ranges traceable to both the generated output and applicability
validation. The changed Observability Contract remains governed from
`NFR-OBSERVABILITY-CORE-001` through `BART-DES-006`; the fixed staged diff
binds every changed file to both review procedures. No invariance override is
claimed for any changed start or reachable node.

## Change control

Adding, removing, reclassifying, or changing a node or relation creates an
`EDI-*` successor and triggers re-evaluation of every retained analysis bound
to this version. Stable surviving identifiers remain unchanged; gaps left by
retirement remain gaps. The implementation team maintains and reconciles the
graph. The project owner approves each exact coverage-validated version and
every `Unaffected` disposition.
