# Training Simulation Documentation Inventory

Status: Approved initial inventory

Approval: Project owner, 2026-09-03

Inventory version: `DOCINV-001`

Version basis: The exact repository tree containing this inventory version;
any listed-document or information-map change creates a successor inventory
version before integration.

Purpose: Enumerate and classify every retained project document in the
authoritative repository and map each governed information item to exactly one
canonical owner and document.

Scope: Root project Markdown and legal documents, every retained document under
`docs/`, and generated documentation datasets under `docs/`. Source code,
build configuration, dependency manifests, repository automation, transient
files outside the repository, and GitHub issues are governed artifacts but are
not project documents in this inventory.

Intended readers: Project owner, documentation maintainers, architects,
designers, implementers, verification authors, and repository agents.

Prerequisites: [Training Simulation Initial
Requirements](../requirements/training-simulation-initial-requirements.md),
[Training Simulation Verification
Plan](../requirements/training-simulation-verification-plan.md), and
[cross-cutting architecture closure](../adr/0010-close-cross-cutting-architecture-and-verification.md).

Canonical information owner: Project owner.

## Table of contents

- [Classification rules](#classification-rules)
- [Canonical information map](#canonical-information-map)
- [Document inventory](#document-inventory)
- [Reconciliation and validation](#reconciliation-and-validation)
- [Current acceptance boundary](#current-acceptance-boundary)
- [Change control](#change-control)

## Classification rules

`Persistent` means the document is retained in the authoritative Git history.
No `Non-persistent` document is currently stored in the authoritative
repository. Handoffs and local working notes outside the repository are not
silently promoted to project documents.

`Manual` and `Generated` identify how content is maintained. Generated content
names its producer and is never edited directly. `Canonical` means the document
owns the mapped information item. `Non-canonical` means it provides navigation,
research, a derived view, instructions, or an explicitly marked placeholder and
must link to the canonical item rather than restating it as independent truth.

Markdown document-control metadata and declared Markdown prerequisites are
structurally validated. The standard-form `LICENSE` and generated CSV carry
their complete title, purpose, scope, intended-reader, status, prerequisite,
and owner control metadata in their inventory rows because their formats cannot
safely embed the repository's Markdown control block. Table-of-Contents coverage is
mandatory for generated Markdown; the current repository contains no generated
Markdown document.

## Canonical information map

| Information identifier | Canonical document | Canonical owner | Information owned |
| --- | --- | --- | --- |
| `DOCINFO-AGENT-ROUTING-001` | `AGENTS.md` | Project owner | Repository-agent routing instructions |
| `DOCINFO-DOMAIN-LANGUAGE-001` | `CONTEXT.md` | Project owner | Training Simulation domain language |
| `DOCINFO-REPOSITORY-OVERVIEW-001` | `README.md` | Project owner | Repository orientation and navigation |
| `DOCINFO-LICENSE-001` | `LICENSE` | Project owner | Adopted repository licence text |
| `ADR-0001` through `ADR-0010` | Corresponding file under `docs/adr/` | Project owner | Accepted or conditionally accepted architecture decision and rationale |
| `AC-TOOLCHAIN-001` through `AC-TOOLCHAIN-002` | `docs/adr/0010-close-cross-cutting-architecture-and-verification.md` | Project owner | Stable claim records pointing to the canonical ADR-0001 and ADR-0002 decision text |
| `AC-FOUNDATION-001` through `AC-FOUNDATION-007` | `docs/adr/0010-close-cross-cutting-architecture-and-verification.md` | Project owner | Stable claim records pointing to the canonical ADR-0003 decision text |
| `AC-DECOMPOSITION-001` through `AC-DECOMPOSITION-006` | `docs/adr/0010-close-cross-cutting-architecture-and-verification.md` | Project owner | Stable claim records pointing to the canonical ADR-0004 decision text |
| `AC-RUNTIME-001` through `AC-RUNTIME-008` | `docs/adr/0010-close-cross-cutting-architecture-and-verification.md` | Project owner | Stable claim records pointing to the canonical ADR-0005 decision text |
| `AC-CONCURRENCY-001` through `AC-CONCURRENCY-008` | `docs/adr/0010-close-cross-cutting-architecture-and-verification.md` | Project owner | Stable claim records pointing to the canonical ADR-0006 decision text |
| `AC-CONTENT-001` through `AC-CONTENT-007` | `docs/adr/0010-close-cross-cutting-architecture-and-verification.md` | Project owner | Stable claim records pointing to the canonical ADR-0007 decision text |
| `AC-RETENTION-001` through `AC-RETENTION-006` | `docs/adr/0010-close-cross-cutting-architecture-and-verification.md` | Project owner | Stable claim records pointing to the canonical ADR-0008 decision text |
| `AC-DEPLOYMENT-001` through `AC-DEPLOYMENT-010` | `docs/adr/0010-close-cross-cutting-architecture-and-verification.md` | Project owner | Stable claim records pointing to the canonical ADR-0009 decision text |
| `AC-CROSSCUTTING-001` through `AC-CROSSCUTTING-012` | `docs/adr/0010-close-cross-cutting-architecture-and-verification.md` | Project owner | Stable claim records for the ADR-0010 decision text |
| `DOCINFO-AGENT-DOMAIN-001` | `docs/agents/domain.md` | Project owner | Agent workflow for domain documentation |
| `DOCINFO-ISSUE-TRACKER-001` | `docs/agents/issue-tracker.md` | Project owner | Agent workflow for GitHub Issues |
| `DOCINFO-TRIAGE-LABELS-001` | `docs/agents/triage-labels.md` | Project owner | Canonical issue-triage label mapping |
| `GOAL-TRAINING-001` through `DEFERRED-MELEE-RESTRAINT-001` | `docs/requirements/training-simulation-initial-requirements.md` | Project owner | Functional, process, scope, constraint, non-goal, and deferred-capability baseline entries defined there |
| `NFR-BASELINE-001` | `docs/requirements/training-simulation-non-functional-requirements.md` | Project owner | Non-functional baseline and its stable entries |
| `OBS-CONTRACT-003` | `docs/requirements/training-simulation-observability-contract.md` | Project owner | Observability signal contract |
| `PERF-BASELINE-001` | `docs/requirements/training-simulation-performance-assessment-requirements.md` | Project owner | Trainee Performance Assessment baseline |
| `ENGAGEMENT-TARGET-001` | `docs/requirements/training-simulation-performance-profile-engagement-target-001.md` | Project owner | Engagement Target Performance Profile |
| `RHP-SET-001` | `docs/requirements/training-simulation-reference-hardware-profiles.md` | Project owner | Reference Hardware Profiles |
| `DOCINFO-VERIFICATION-PLAN-001` | `docs/requirements/training-simulation-verification-plan.md` | Project owner | Verification methods, assignments, evidence process, and acceptance gates |
| `DOCINFO-DOCUMENTATION-INVENTORY-001` | `docs/project/training-simulation-documentation-inventory.md` | Project owner | Documentation population, classifications, and canonical information mappings |
| `CPP-ENGINEERING-BASELINE-003` | `docs/standards/cpp-engineering.md` | Project owner | C++ engineering and toolchain baseline |
| `DOCINFO-CONVENTIONAL-COMMITS-001` | `docs/standards/conventional-commits.md` | Project owner | Conventional Commit Profile |
| `DOCINFO-GIT-FLOW-001` | `docs/standards/git-flow.md` | Project owner | Branch and integration workflow |

The exact stable identifiers defined inside each requirement or profile
document remain owned by that document. A range above is an inventory summary,
not a replacement for identifier-level traceability.

## Document inventory

Every row has version basis `DOCINV-001 repository tree`. `Metadata` means the
required title, purpose, scope, intended readers, status, prerequisites, and
single canonical information owner. `ToC` is `Not Applicable` for manually
maintained Markdown and non-Markdown formats under the current requirement;
manual documents may still provide one.

| Document ID | Path | Retention | Format | Maintenance | Authority and mapped information | Owner | Metadata / ToC | Prerequisites | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `DOC-001` | `AGENTS.md` | Persistent | Markdown | Manual | Canonical: `DOCINFO-AGENT-ROUTING-001` | Project owner | Required / Not Applicable | None | Current |
| `DOC-002` | `CONTEXT.md` | Persistent | Markdown | Manual | Canonical: `DOCINFO-DOMAIN-LANGUAGE-001` | Project owner | Required / Not Applicable | None | Approved |
| `DOC-003` | `README.md` | Persistent | Markdown | Manual | Canonical: `DOCINFO-REPOSITORY-OVERVIEW-001`; non-canonical navigation to all linked items | Project owner | Required / Not Applicable | None | Current |
| `DOC-004` | `SECURITY.md` | Persistent | Markdown | Manual | Non-canonical placeholder linking to `DEFERRED-PRODUCTION-SECURITY-001` in the Development Baseline requirements amended 2026-09-03 | Project owner | Required / Not Applicable | Deferred: Production Security Baseline and release policy | Explicitly unapproved placeholder |
| `DOC-005` | `LICENSE` | Persistent | Plain text | Manual | Canonical: `DOCINFO-LICENSE-001`; title `MIT License`; purpose and scope: license this repository's software and documentation under the included terms; intended readers: recipients and contributors | Project owner | Inventory control / Not Applicable | None | Current externally standardized MIT licence text |
| `DOC-006` | `docs/adr/0001-use-clang-only-for-cpp.md` | Persistent | Markdown | Manual | Canonical: `ADR-0001` | Project owner | Required / Not Applicable | Declared; links validated | Accepted |
| `DOC-007` | `docs/adr/0002-cross-compile-windows-from-ubuntu-with-clang.md` | Persistent | Markdown | Manual | Canonical: `ADR-0002` | Project owner | Required / Not Applicable | Declared; links validated | Accepted |
| `DOC-008` | `docs/adr/0003-adopt-nvidia-oriented-foundation.md` | Persistent | Markdown | Manual | Canonical: `ADR-0003` | Project owner | Required / Not Applicable | Declared; links validated | Accepted conditionally |
| `DOC-009` | `docs/adr/0004-decompose-by-canonical-responsibility.md` | Persistent | Markdown | Manual | Canonical: `ADR-0004` | Project owner | Required / Not Applicable | Declared; links validated | Accepted |
| `DOC-010` | `docs/adr/0005-use-fixed-step-authoritative-runtime.md` | Persistent | Markdown | Manual | Canonical: `ADR-0005` | Project owner | Required / Not Applicable | Declared; links validated | Accepted |
| `DOC-011` | `docs/adr/0006-isolate-runtime-owners-and-bound-failure.md` | Persistent | Markdown | Manual | Canonical: `ADR-0006` | Project owner | Required / Not Applicable | Declared; links validated | Accepted |
| `DOC-012` | `docs/adr/0007-use-signed-scenario-bound-runtime-content-releases.md` | Persistent | Markdown | Manual | Canonical: `ADR-0007` | Project owner | Required / Not Applicable | Declared; links validated | Accepted |
| `DOC-013` | `docs/adr/0008-retain-evidence-outside-ephemeral-session-state.md` | Persistent | Markdown | Manual | Canonical: `ADR-0008` | Project owner | Required / Not Applicable | Declared; links validated | Accepted |
| `DOC-014` | `docs/adr/0009-expose-orchestration-neutral-runtime-deployment-contracts.md` | Persistent | Markdown | Manual | Canonical: `ADR-0009` | Project owner | Required / Not Applicable | Declared; links validated | Accepted |
| `DOC-015` | `docs/adr/0010-close-cross-cutting-architecture-and-verification.md` | Persistent | Markdown | Manual | Canonical: `ADR-0010` and every registered `AC-*` claim record | Project owner | Required / Not Applicable | Declared; links validated | Accepted decision; realization and evidence incomplete |
| `DOC-016` | `docs/agents/domain.md` | Persistent | Markdown | Manual | Canonical: `DOCINFO-AGENT-DOMAIN-001` | Project owner | Required / Not Applicable | None | Active |
| `DOC-017` | `docs/agents/issue-tracker.md` | Persistent | Markdown | Manual | Canonical: `DOCINFO-ISSUE-TRACKER-001` | Project owner | Required / Not Applicable | External: GitHub CLI repository access | Active |
| `DOC-018` | `docs/agents/triage-labels.md` | Persistent | Markdown | Manual | Canonical: `DOCINFO-TRIAGE-LABELS-001` | Project owner | Required / Not Applicable | `DOC-017` | Active |
| `DOC-019` | `docs/requirements/training-simulation-initial-requirements.md` | Persistent | Markdown | Manual | Canonical: stable entries defined in the functional baseline | Project owner | Required / Not Applicable | Declared; links validated | Approved Development Baseline requirements |
| `DOC-020` | `docs/requirements/training-simulation-non-functional-requirements.md` | Persistent | Markdown | Manual | Canonical: `NFR-BASELINE-001` and stable entries defined there | Project owner | Required / Not Applicable | Declared; links validated | Approved |
| `DOC-021` | `docs/requirements/training-simulation-observability-contract.md` | Persistent | Markdown | Manual | Canonical: `OBS-CONTRACT-003` | Project owner | Required / Not Applicable | Declared; links validated | Approved |
| `DOC-022` | `docs/requirements/training-simulation-performance-assessment-requirements.md` | Persistent | Markdown | Manual | Canonical: `PERF-BASELINE-001` and stable entries defined there | Project owner | Required / Not Applicable | Declared; links validated | Approved |
| `DOC-023` | `docs/requirements/training-simulation-performance-profile-engagement-target-001.md` | Persistent | Markdown | Manual | Canonical: `ENGAGEMENT-TARGET-001` | Project owner | Required / Not Applicable | Declared; links validated | Approved but not admitted until its validation passes |
| `DOC-024` | `docs/requirements/training-simulation-reference-hardware-profiles.md` | Persistent | Markdown | Manual | Canonical: `RHP-SET-001` | Project owner | Required / Not Applicable | Declared; links validated | Approved |
| `DOC-025` | `docs/requirements/training-simulation-verification-assignment-inventory.csv` | Persistent | CSV | Generated by `scripts/generate-verification-assignment-inventory.py` | Non-canonical derived view of `DOC-019` and `DOC-026`; title `Training Simulation Verification Assignment Inventory`; purpose and scope: identifier-level expansion of the two named sources; intended readers: implementation team and verification authors | Project owner | Inventory control / Not Applicable | `DOC-019`, `DOC-026` | Regenerated dataset; acceptance follows source validation |
| `DOC-026` | `docs/requirements/training-simulation-verification-plan.md` | Persistent | Markdown | Manual | Canonical: `DOCINFO-VERIFICATION-PLAN-001` | Project owner | Required / Not Applicable | Declared; links validated | Approved |
| `DOC-027` | `docs/project/training-simulation-documentation-inventory.md` | Persistent | Markdown | Manual | Canonical: `DOCINFO-DOCUMENTATION-INVENTORY-001` | Project owner | Required / Not Applicable | Declared; links validated | Approved `DOCINV-001` |
| `DOC-028` | `docs/research/cpp-engineering-toolchain-and-quality-guidance.md` | Persistent | Markdown | Manual | Non-canonical research informing `CPP-ENGINEERING-BASELINE-003` | Project owner | Required / Not Applicable | Declared; links validated | Retained research guidance |
| `DOC-029` | `docs/research/initial-goals-requirements-and-constraints-guidance.md` | Persistent | Markdown | Manual | Non-canonical requirements-writing research informing `DOC-019` | Project owner | Required / Not Applicable | None | Retained research guidance |
| `DOC-030` | `docs/research/software-architecture-document-guidance.md` | Persistent | Markdown | Manual | Non-canonical architecture-description research informing `ADR-0010` | Project owner | Required / Not Applicable | None | Retained research guidance |
| `DOC-031` | `docs/research/software-design-document-guidance.md` | Persistent | Markdown | Manual | Non-canonical design-document research; future design input | Project owner | Required / Not Applicable | None | Retained research guidance |
| `DOC-032` | `docs/research/software-implementation-planning-document-guidance.md` | Persistent | Markdown | Manual | Non-canonical implementation-planning research; future planning input | Project owner | Required / Not Applicable | None | Retained research guidance |
| `DOC-033` | `docs/research/viable-technology-foundations.md` | Persistent | Markdown | Manual | Non-canonical technology research informing `ADR-0003` | Project owner | Required / Not Applicable | Declared; links validated | Retained research guidance |
| `DOC-034` | `docs/standards/conventional-commits.md` | Persistent | Markdown | Manual | Canonical: `DOCINFO-CONVENTIONAL-COMMITS-001` | Project owner | Required / Not Applicable | `DOC-019` | Approved initial profile |
| `DOC-035` | `docs/standards/cpp-engineering.md` | Persistent | Markdown | Manual | Canonical: `CPP-ENGINEERING-BASELINE-003` | Project owner | Required / Not Applicable | Declared; links validated | Approved |
| `DOC-036` | `docs/standards/git-flow.md` | Persistent | Markdown | Manual | Canonical: `DOCINFO-GIT-FLOW-001` | Project owner | Required / Not Applicable | `DOC-034` | Approved initial profile |

## Reconciliation and validation

The authoritative population is the union of root `AGENTS.md`, `CONTEXT.md`,
`README.md`, `SECURITY.md`, `LICENSE`, every `*.md` below `docs/`, and generated
documentation datasets below `docs/`. `DOCINV-001` contains 36 documents: 34
manually maintained Markdown documents, one external-standard plain-text legal
document, and one generated CSV dataset. It contains no retained
`Non-persistent` document and no generated Markdown document.

Run the structural validator from the repository root:

```sh
python3 scripts/validate-documentation-inventory.py
```

The validator reconciles this population, stable document identifiers, paths,
classifications, owners, required Markdown control fields, declared Markdown
links, and generated-Markdown Table-of-Contents rules. Semantic canonicality,
the completeness of information-item mappings, project-owner approval, and
evidence impact remain review decisions rather than facts a script can infer.

## Current acceptance boundary

The approved inventory and its document population are structurally reconciled
for `DOCINV-001`; the project owner approved this exact version on 2026-09-03.
`SECURITY.md` remains an explicitly non-authoritative future placeholder and
cannot support a security claim. The generated verification-assignment
inventory remains a derived view and cannot substitute for the Baseline
Applicability, Baseline Artifact, or Evidence Dependency Inventory.

Architecture decisions are closed by ADR-0010. Product realization and
architecture evidence remain incomplete. Baseline approval remains blocked by
the missing inventories and every other unresolved requirement or evidence
dependency identified by the approved baselines and architecture decisions.

## Change control

Adding, removing, renaming, reclassifying, or changing ownership of a document
or mapped information item requires a successor Documentation Inventory
version. The change triggers documentation and evidence-impact analysis under
`PROCESS-DOCUMENTATION-INVENTORY-006` and `PROCESS-EVIDENCE-CHANGE-001`
through `PROCESS-EVIDENCE-CHANGE-006`.

The implementation team maintains the inventory. The project owner approves
each exact reconciled version. A structural validator result supports but does
not replace that reconciliation and approval.
