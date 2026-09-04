# Training Simulation Evidence Dependency Inventory

Status: Approved

Approval: Project owner, 2026-09-04

Inventory version: `EDI-003`

Package SHA-256: `63b5b394d27126af1d045868ca9e0b92e4098a9082e0db7de0e9b37d8593f5cb`

Approved package SHA-256: `63b5b394d27126af1d045868ca9e0b92e4098a9082e0db7de0e9b37d8593f5cb`

Approved predecessor: `EDI-002@sha256:42d23f34b82914c0530cdaf5107555cc8711788d5a49785b091921bbc75cdc0e`, project owner, 2026-09-04

Version basis: The package SHA-256 and the exact approved predecessor
inventory identities recorded below. A registered node, classification, or
directed relation change creates a successor; populating a pre-registered
immutable evidence record does not.

Purpose: Register the current evidence-dependency graph used to decide which
accepted evidence a change may affect and to prevent acceptance through an
unregistered or uncertain dependency.

Scope: Every current requirement, governed baseline artifact, Architecture
Claim, architecture-level product component, planned Software Architecture
Description view, repository verification dependency, and evidence record
known at this inventory version. Product-instance categories with no current
authoritative population are closed explicitly at zero rather than inferred.

Intended readers: Project owner, architects, implementers, verification
authors, reviewers, evidence custodians, and repository agents.

Prerequisites: Approved [Baseline Applicability Inventory
`BAI-004`](../requirements/training-simulation-baseline-applicability.md),
approved [Baseline Artifact Inventory
`BARTINV-005`](training-simulation-baseline-artifact-inventory.md), approved
[Documentation Inventory
`DOCINV-008`](training-simulation-documentation-inventory.md),
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
- [`EDI-003` impact analysis](#edi-003-impact-analysis)
- [Change control](#change-control)

## Inventory package

`EDI-003` is one atomic version comprising this control document, the
[supplemental node register](training-simulation-evidence-dependency-nodes.csv),
the [supplemental directed-relation
register](training-simulation-evidence-dependency-relations.csv), and the
[impact-case register](training-simulation-evidence-impact-cases.csv). The
effective graph is the deterministic union of those registers and the exact
imports described below; the supplemental files do not duplicate predecessor
inventory rows.

The digest hashes the four sorted paths and contents after replacing every
embedded copy of its own digest and the cyclic `BARTINV-005` package digest
with 64 zeroes. This makes the EDI and Baseline Artifact inventories mutually
addressable without pretending that a cryptographic fixed point exists. Every
non-package file version remains the exact version supplied by its authoritative
inventory.

| Imported inventory | Exact identity |
| --- | --- |
| Baseline Applicability Inventory | Approved `BAI-004` |
| Baseline Artifact Inventory | Approved `BARTINV-005@sha256:05d2639bd506a4cd65a8b60a12f37ab7351f96c76652c446bfe021a46a32af6d` |
| Documentation Inventory | Approved `DOCINV-008` repository tree |

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
The Spec reviewer fetches issue #29 directly, hashes the emitted body including
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

1. every `BAI-004` row, using its requirement identifier as a `Requirement
   Identifier` node;
2. every `BARTINV-005` row, using its stable artifact identifier and classifying
   it as a `Configuration Item`, `Verification Procedure`, `Input Data Set`, or
   `Governed Artifact` according to the reviewed path rules in the validator;
3. every Architecture Claim trace row, using its `AC-*` key as an `Architecture
   Claim` node; and
4. every row in the supplemental node register, which supplies the current
   architecture-level product components, planned Software Architecture
Description views, exact validation environment, procedure-specific data,
review and approval procedures, and pre-registered outputs.

The validator derives requirement-to-artifact traces from `BARTINV-005`, and
requirement-to-claim plus governing-artifact-to-claim mappings from the exact
Architecture Claim register. It adds the reviewed explicit relations from the
supplemental relation register. No imported source row is silently copied or
renumbered.

## Node classes and reconciliation

| Required class | Authoritative population | `EDI-003` reconciliation |
| --- | --- | --- |
| `Requirement Identifier` | `BAI-004` | Every row imported exactly once. |
| `Obligation Key` | Approved verification procedures | Zero current approved obligation keys; any procedure execution or `Pass` remains blocked until keys are registered in a successor. |
| `Product Component` | ARCHSPEC-0004 responsibility-module and runtime-composition tables | Every current architecture-level module and runtime registered explicitly. |
| `Configuration Item` | `BARTINV-005` Implementation artifacts | Every current row imported exactly once under the reviewed class mapping. |
| `Scenario` | Approved Scenario inventory | Zero current approved Scenario versions; prose examples do not create an admitted instance. |
| `Map` | Approved Map inventory | Zero current approved Map versions. |
| `Content Item` | Approved content and catalogue inventories | Zero current admitted content items. |
| `Approved Profile` | Approved Profile inventory | Zero current admitted Approved Profile versions; Reference Hardware and Performance Profiles retain their distinct governed-artifact identities. |
| `Verification Procedure` | `BARTINV-005` executable verification artifacts and this inventory's explicit review/approval procedures | Every current executable or explicit procedure imported or registered exactly once, with declared inputs or dependencies and at least one pre-registered output. |
| `Input Data Set` | `BARTINV-005` verification configuration and inventory datasets plus this inventory's supplemental procedure data | Every current row imported or registered exactly once under the reviewed class mapping. |
| `Verification Environment` | This inventory's supplemental register | Exact repository validation environment registered before execution. |
| `Evidence Record` | This inventory's pre-registered output population | Inventory validations, repository gates, Standards review, Spec review, and exact-version approval identities registered before production. |
| `Architecture Claim` | `BARTINV-005` Architecture Claim trace register | Every `AC-*` row imported exactly once with its governing artifact mapping. |
| `Software Architecture Description View` | ARCHSPEC-0010 view-set table | Every selected future view registered; no document realization is inferred. |
| `Governed Artifact` | Remaining `BARTINV-005` rows | Every remaining architecture, design, and verification artifact imported exactly once. |

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

Approved `EDI-003` registers and coverage-validates the current graph without claiming
product realization or accepted product evidence. The current zero populations
and absence of approved obligation keys prohibit product evidence from
receiving `Pass`. Architecture Claims and planned Software Architecture
Description views participate in impact traversal through exact governing
artifact and claim mappings, but their realization and evidence states remain
unchanged.

Project-owner approval applies to this exact package identity. Structural
validation cannot approve it, and approval cannot convert missing product
instances, obligation keys, procedures, or evidence into a nonzero population.

## `EDI-003` impact analysis

This successor preserves the complete node and relation populations of
`EDI-002`. It changes the exact imports to approved `BAI-004`, `BARTINV-005`,
and `DOCINV-008`; changes the registered Spec-review input from issue #26 to
issue #29; and retains the stable review, validation, gate, and approval record
identities. No Product Component, Scenario, Map, Content Item, Approved
Profile, obligation key, artifact trace, or Architecture Claim mapping is
added, removed, or reclassified.

The changed `NFR-OBSERVABILITY-CORE-001` definition, verification assignments,
contract and glossary artifacts, imported source versions, fixed review input,
and every predecessor-bound validation and review result are `Affected`. No
accepted product or Architecture Claim evidence exists to retain as
`Unaffected`. Every retained analysis bound to `EDI-002` requires
re-evaluation; exact-version project-owner approval was granted on 2026-09-04.

The conservative traversal was performed from the following complete changed-
start populations. Sets shown after the arrow are the complete reachable sets
in the approved graph; the fixed staged-diff start additionally covers every
changed file and reaches `EDI-PROC-001`, `EDI-PROC-002`, `EDI-PROC-003`, and
`EDI-EVID-003` through `EDI-EVID-005`.

| Changed start population | Complete reachable affected set |
|---|---|
| `NFR-OBSERVABILITY-CORE-001` | `BART-DES-006`; `BART-VER-014`; `EDI-EVID-009` |
| `BART-DES-003`; `BART-DES-005`; `BART-DES-006` | Empty set; each artifact remains `Affected` because it is present in `EDI-DATA-001`, but the approved graph has no approved downstream product-evidence path from the artifact node |
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
