# Training Simulation Documentation Inventory

Status: Approved

Approval: Project owner, 2026-09-04

Inventory version: `DOCINV-006`

Version basis: The exact repository tree containing this inventory version;
any listed-document or information-map change creates a successor inventory
version before integration.

Purpose: Enumerate and classify every retained project document in the
authoritative repository and map each governed information item to exactly one
canonical owner and document.

Scope: Root project Markdown and legal documents, every retained document under
`docs/`, and retained documentation datasets under `docs/`. Source code,
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
- [`DOCINV-006` impact analysis](#docinv-006-impact-analysis)
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

Each document has one control tier. `Controlled` documents own normative or
canonical project information and embed the complete control block when they
are Markdown. `Routed` documents provide operational navigation or agent
instructions. `Reference` documents retain non-canonical research. `Generated`
documents are reproducible views. The latter three tiers may keep control data
in the document or this inventory, whichever produces the clearer form.

The standard-form `LICENSE` and retained CSV datasets carry their controls in
their inventory rows. Table-of-Contents coverage is mandatory for generated
Markdown; the current repository contains no persistent generated document.

## Canonical information map

| Information identifier | Canonical document | Canonical owner | Information owned |
| --- | --- | --- | --- |
| `DOCINFO-AGENT-ROUTING-001` | `AGENTS.md` | Project owner | Repository-agent routing instructions |
| `DOCINFO-DOMAIN-LANGUAGE-001` | `CONTEXT.md` | Project owner | Training Simulation product and represented-world language |
| `DOCINFO-TECHNICAL-LANGUAGE-001` | `docs/glossary/technical.md` | Project owner | Runtime, identity, packaging, timing, and deployment language |
| `DOCINFO-GOVERNANCE-LANGUAGE-001` | `docs/glossary/governance.md` | Project owner | Baseline, profile, catalogue, inventory, evidence-role, and project-control language |
| `DOCINFO-REPOSITORY-OVERVIEW-001` | `README.md` | Project owner | Repository orientation and navigation |
| `DOCINFO-LICENSE-001` | `LICENSE` | Project owner | Adopted repository licence text |
| `ADR-0001` through `ADR-0010` | Corresponding file under `docs/adr/` | Project owner | Accepted or conditionally accepted architecture decision and concise rationale |
| `ARCHSPEC-0003` through `ARCHSPEC-0010` | Corresponding file under `docs/architecture/` | Project owner | Detailed contracts, views, alternatives, consequences, and traces governed by ADR-0003 through ADR-0010 |
| `AC-TOOLCHAIN-001` through `AC-CROSSCUTTING-012` | `docs/architecture/0010-cross-cutting-architecture-and-verification.md` | Project owner | Stable Architecture Claim register pointing to the governing decisions and specifications |
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
| `BAI-CONTROL-002` | `docs/requirements/training-simulation-baseline-applicability.md` | Project owner | Global identity, provenance, schema, and approval state for the normalized applicability inventory |
| `BAI-002` | `docs/requirements/training-simulation-baseline-applicability-inventory.csv` | Project owner | Exact disposition, milestone or justification, and owner for every current normative identifier |
| `BARTINV-CONTROL-001` | `docs/project/training-simulation-baseline-artifact-inventory.md` | Project owner | Global identity, population boundary, schema, reconciliation rules, and approval state for the Baseline Artifact Inventory |
| `BARTINV-003` | `docs/project/training-simulation-baseline-artifacts.csv` | Project owner | Exact identity, class, version, location, status, owner, and requirement traces for every governed artifact |
| `DOCINFO-ARCHITECTURE-CLAIM-TRACE-001` | `docs/project/training-simulation-architecture-claim-traces.csv` | Project owner | Exact state, claim and per-requirement dispositions, governing artifact, and requirement-trace expansion for every ADR-0010 Architecture Claim |
| `EDI-CONTROL-001` | `docs/project/training-simulation-evidence-dependency-inventory.md` | Project owner | Global identity, effective population, graph semantics, reconciliation rules, impact procedure, and approval state for the Evidence Dependency Inventory |
| `EDI-001-NODES` | `docs/project/training-simulation-evidence-dependency-nodes.csv` | Project owner | Supplemental current nodes not imported from approved predecessor inventories |
| `EDI-001-RELATIONS` | `docs/project/training-simulation-evidence-dependency-relations.csv` | Project owner | Reviewed explicit directed and typed dependency relations not derived from predecessor traces |
| `EDI-001-IMPACT-CASES` | `docs/project/training-simulation-evidence-impact-cases.csv` | Project owner | Direct, transitive, multiple-path, absent-path, stale, unclassified, uncertain, invariance, and successor impact cases |
| `DOCINFO-DOCUMENTATION-INVENTORY-001` | `docs/project/training-simulation-documentation-inventory.md` | Project owner | Documentation population, classifications, and canonical information mappings |
| `CPP-ENGINEERING-BASELINE-003` | `docs/standards/cpp-engineering.md` | Project owner | C++ engineering and toolchain baseline |
| `DOCINFO-CONVENTIONAL-COMMITS-001` | `docs/standards/conventional-commits.md` | Project owner | Conventional Commit Profile |
| `DOCINFO-GIT-FLOW-001` | `docs/standards/git-flow.md` | Project owner | Branch and integration workflow |

The exact stable identifiers defined inside each requirement or profile
document remain owned by that document. A range above is an inventory summary,
not a replacement for identifier-level traceability.

## Document inventory

Every row has version basis `DOCINV-006 repository tree`. `Control tier` selects
the information hierarchy. `Metadata` states whether document control is
embedded or inventory-held. `ToC` is `Not Applicable` for manually maintained
Markdown and non-Markdown formats; manual documents may still provide one.

| Document ID | Path | Retention | Format | Maintenance | Authority and mapped information | Owner | Control tier / metadata / ToC | Prerequisites | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `DOC-001` | `AGENTS.md` | Persistent | Markdown | Manual | Canonical: `DOCINFO-AGENT-ROUTING-001`; title `Agent Instructions`; purpose and scope: route every repository agent to conditional instructions; intended readers: repository agents and maintainers | Project owner | Routed / Inventory / Not Applicable | None | Active |
| `DOC-002` | `CONTEXT.md` | Persistent | Markdown | Manual | Canonical: `DOCINFO-DOMAIN-LANGUAGE-001` | Project owner | Controlled / Embedded / Not Applicable | None | Candidate successor; approval pending |
| `DOC-003` | `README.md` | Persistent | Markdown | Manual | Canonical: `DOCINFO-REPOSITORY-OVERVIEW-001`; title `Sacramento`; purpose and scope: repository orientation, navigation, and supported workflows; intended readers: contributors, reviewers, and stakeholders | Project owner | Routed / Inventory / Not Applicable | None | Active overview |
| `DOC-004` | `SECURITY.md` | Persistent | Markdown | Manual | Non-canonical placeholder linking to `DEFERRED-PRODUCTION-SECURITY-001`; title `Security Policy`; purpose and scope: reserve vulnerability-reporting guidance without a current support commitment; intended readers: stakeholders and future security-policy authors | Project owner | Routed / Inventory / Not Applicable | Deferred: Production Security Baseline and release policy | Explicitly unapproved placeholder |
| `DOC-005` | `LICENSE` | Persistent | Plain text | Manual | Canonical: `DOCINFO-LICENSE-001`; title `MIT License`; purpose and scope: license this repository's software and documentation under the included terms; intended readers: recipients and contributors | Project owner | Controlled / Inventory / Not Applicable | None | Current externally standardized MIT licence text |
| `DOC-006` | `docs/adr/0001-use-clang-only-for-cpp.md` | Persistent | Markdown | Manual | Canonical: `ADR-0001` | Project owner | Controlled / Embedded / Not Applicable | Declared; links validated | Accepted |
| `DOC-007` | `docs/adr/0002-cross-compile-windows-from-ubuntu-with-clang.md` | Persistent | Markdown | Manual | Canonical: `ADR-0002` | Project owner | Controlled / Embedded / Not Applicable | Declared; links validated | Accepted |
| `DOC-008` | `docs/adr/0003-adopt-nvidia-oriented-foundation.md` | Persistent | Markdown | Manual | Canonical: `ADR-0003` | Project owner | Controlled / Embedded / Not Applicable | Declared; links validated | Accepted conditionally |
| `DOC-009` | `docs/adr/0004-decompose-by-canonical-responsibility.md` | Persistent | Markdown | Manual | Canonical: `ADR-0004` | Project owner | Controlled / Embedded / Not Applicable | Declared; links validated | Accepted |
| `DOC-010` | `docs/adr/0005-use-fixed-step-authoritative-runtime.md` | Persistent | Markdown | Manual | Canonical: `ADR-0005` | Project owner | Controlled / Embedded / Not Applicable | Declared; links validated | Accepted |
| `DOC-011` | `docs/adr/0006-isolate-runtime-owners-and-bound-failure.md` | Persistent | Markdown | Manual | Canonical: `ADR-0006` | Project owner | Controlled / Embedded / Not Applicable | Declared; links validated | Accepted |
| `DOC-012` | `docs/adr/0007-use-signed-scenario-bound-runtime-content-releases.md` | Persistent | Markdown | Manual | Canonical: `ADR-0007` | Project owner | Controlled / Embedded / Not Applicable | Declared; links validated | Accepted |
| `DOC-013` | `docs/adr/0008-retain-evidence-outside-ephemeral-session-state.md` | Persistent | Markdown | Manual | Canonical: `ADR-0008` | Project owner | Controlled / Embedded / Not Applicable | Declared; links validated | Accepted |
| `DOC-014` | `docs/adr/0009-expose-orchestration-neutral-runtime-deployment-contracts.md` | Persistent | Markdown | Manual | Canonical: `ADR-0009` | Project owner | Controlled / Embedded / Not Applicable | Declared; links validated | Accepted |
| `DOC-015` | `docs/adr/0010-close-cross-cutting-architecture-and-verification.md` | Persistent | Markdown | Manual | Canonical: `ADR-0010`; links to detailed specification and `AC-*` register | Project owner | Controlled / Embedded / Not Applicable | Declared; links validated | Accepted decision; realization and evidence incomplete |
| `DOC-016` | `docs/agents/domain.md` | Persistent | Markdown | Manual | Canonical: `DOCINFO-AGENT-DOMAIN-001`; title `Domain Documentation`; purpose and scope: route agents interpreting or changing project behavior, language, requirements, architecture, or verification obligations; intended readers: repository agents and maintainers | Project owner | Routed / Inventory / Not Applicable | None | Active |
| `DOC-017` | `docs/agents/issue-tracker.md` | Persistent | Markdown | Manual | Canonical: `DOCINFO-ISSUE-TRACKER-001`; title `Issue Tracker`; purpose and scope: govern agent interaction with project work items; intended readers: repository agents and maintainers | Project owner | Routed / Inventory / Not Applicable | External: GitHub CLI repository access | Active |
| `DOC-018` | `docs/agents/triage-labels.md` | Persistent | Markdown | Manual | Canonical: `DOCINFO-TRIAGE-LABELS-001`; title `Triage Labels`; purpose and scope: map canonical triage roles to repository labels; intended readers: agents, maintainers, and triagers | Project owner | Routed / Inventory / Not Applicable | `DOC-017` | Active |
| `DOC-019` | `docs/requirements/training-simulation-initial-requirements.md` | Persistent | Markdown | Manual | Canonical: stable entries defined in the functional baseline | Project owner | Controlled / Embedded / Not Applicable | Declared; links validated | Approved baseline; candidate document-control amendment |
| `DOC-020` | `docs/requirements/training-simulation-non-functional-requirements.md` | Persistent | Markdown | Manual | Canonical: `NFR-BASELINE-001` and stable entries defined there | Project owner | Controlled / Embedded / Not Applicable | Declared; links validated | Approved |
| `DOC-021` | `docs/requirements/training-simulation-observability-contract.md` | Persistent | Markdown | Manual | Canonical: `OBS-CONTRACT-003` | Project owner | Controlled / Embedded / Not Applicable | Declared; links validated | Approved |
| `DOC-022` | `docs/requirements/training-simulation-performance-assessment-requirements.md` | Persistent | Markdown | Manual | Canonical: `PERF-BASELINE-001` and stable entries defined there | Project owner | Controlled / Embedded / Not Applicable | Declared; links validated | Approved |
| `DOC-023` | `docs/requirements/training-simulation-performance-profile-engagement-target-001.md` | Persistent | Markdown | Manual | Canonical: `ENGAGEMENT-TARGET-001` | Project owner | Controlled / Embedded / Not Applicable | Declared; links validated | Approved but not admitted until its validation passes |
| `DOC-024` | `docs/requirements/training-simulation-reference-hardware-profiles.md` | Persistent | Markdown | Manual | Canonical: `RHP-SET-001` | Project owner | Controlled / Embedded / Not Applicable | Declared; links validated | Approved |
| `DOC-025` | `docs/requirements/training-simulation-verification-plan.md` | Persistent | Markdown | Manual | Canonical: `DOCINFO-VERIFICATION-PLAN-001` | Project owner | Controlled / Embedded / Not Applicable | Declared; links validated | Candidate successor; approval pending |
| `DOC-026` | `docs/project/training-simulation-documentation-inventory.md` | Persistent | Markdown | Manual | Canonical: `DOCINFO-DOCUMENTATION-INVENTORY-001` | Project owner | Controlled / Embedded / Not Applicable | Declared; links validated | Approved `DOCINV-006` |
| `DOC-027` | `docs/research/cpp-engineering-toolchain-and-quality-guidance.md` | Persistent | Markdown | Manual | Non-canonical research informing `CPP-ENGINEERING-BASELINE-003`; title `C++ Engineering Toolchain and Quality Guidance`; purpose and scope: evaluate toolchain, quality, portability, and reproducibility options; intended readers: architects, implementers, build operators, dependency reviewers, and verification authors | Project owner | Reference / Inventory / Not Applicable | `DOC-002`, `DOC-019`, `DOC-020`, `DOC-024`, `DOC-025` | Retained research, 2026-09-01 |
| `DOC-028` | `docs/research/initial-goals-requirements-and-constraints-guidance.md` | Persistent | Markdown | Manual | Non-canonical research informing `DOC-019`; title `Initial Goals, Requirements, and Constraints Document Guidance`; purpose and scope: guide requirement types, structure, quality, and ambiguity review; intended readers: requirements authors, architects, reviewers, and verification authors | Project owner | Reference / Inventory / Not Applicable | None | Retained research guidance |
| `DOC-029` | `docs/research/software-architecture-document-guidance.md` | Persistent | Markdown | Manual | Non-canonical research informing `ARCHSPEC-0010`; title `What a Software Architecture Document Should—and Should Not—Contain`; purpose and scope: guide lean architecture descriptions and game-engine-specific views; intended readers: architects, design authors, reviewers, and implementers | Project owner | Reference / Inventory / Not Applicable | None | Retained research guidance |
| `DOC-030` | `docs/research/software-design-document-guidance.md` | Persistent | Markdown | Manual | Non-canonical future design input; title `Software Design Document Guidance`; purpose and scope: guide testable design, traceability, interfaces, failure, and acceptance; intended readers: design authors, reviewers, implementers, and verification authors | Project owner | Reference / Inventory / Not Applicable | `DOC-019`, `DOC-006` through `DOC-015` | Retained research guidance |
| `DOC-031` | `docs/research/software-implementation-planning-document-guidance.md` | Persistent | Markdown | Manual | Non-canonical future planning input; title `Software Implementation Planning Document Guidance`; purpose and scope: turn approved design into ordered, verifiable work; intended readers: planning authors, implementers, reviewers, and verification authors | Project owner | Reference / Inventory / Not Applicable | `DOC-019`, `DOC-006` through `DOC-015` | Retained research guidance |
| `DOC-032` | `docs/research/viable-technology-foundations.md` | Persistent | Markdown | Manual | Non-canonical research informing `ADR-0003`; title `Viable Technology Foundations for the Initial Training Simulation`; purpose and scope: evaluate feasible foundations and evidence gaps without selecting one; intended readers: architects, implementers, dependency reviewers, and verification authors | Project owner | Reference / Inventory / Not Applicable | `DOC-002`, `DOC-006`, `DOC-007`, `DOC-019`, `DOC-020`, `DOC-021`, `DOC-024`, `DOC-025`, `DOC-034` | Retained research, 2026-09-01 |
| `DOC-033` | `docs/standards/conventional-commits.md` | Persistent | Markdown | Manual | Canonical: `DOCINFO-CONVENTIONAL-COMMITS-001` | Project owner | Controlled / Embedded / Not Applicable | `DOC-019` | Approved initial profile |
| `DOC-034` | `docs/standards/cpp-engineering.md` | Persistent | Markdown | Manual | Canonical: `CPP-ENGINEERING-BASELINE-003` | Project owner | Controlled / Embedded / Not Applicable | Declared; links validated | Approved |
| `DOC-035` | `docs/standards/git-flow.md` | Persistent | Markdown | Manual | Canonical: `DOCINFO-GIT-FLOW-001` | Project owner | Controlled / Embedded / Not Applicable | `DOC-033` | Approved initial profile |
| `DOC-036` | `docs/requirements/training-simulation-baseline-applicability-inventory.csv` | Persistent | CSV | Manual | Canonical: `BAI-002`; title `Training Simulation Baseline Applicability Inventory`; purpose and scope: store normalized per-identifier Development Baseline dispositions and owners; intended readers: project owner, requirements reviewers, architects, implementers, verification authors, and tooling; structurally validated by `scripts/validate-baseline-applicability-inventory.sh` | Project owner | Controlled / Inventory / Not Applicable | `DOC-019`, `DOC-020`, `DOC-021`, `DOC-022`, `DOC-023`, `DOC-024`, `DOC-025`, `DOC-045` | Approved `BAI-002` |
| `DOC-037` | `docs/architecture/0003-nvidia-oriented-foundation.md` | Persistent | Markdown | Manual | Canonical: `ARCHSPEC-0003`, governed by `ADR-0003` | Project owner | Controlled / Embedded / Not Applicable | Declared; links validated | Accepted detail; organization changed only |
| `DOC-038` | `docs/architecture/0004-canonical-responsibility.md` | Persistent | Markdown | Manual | Canonical: `ARCHSPEC-0004`, governed by `ADR-0004` | Project owner | Controlled / Embedded / Not Applicable | Declared; links validated | Accepted detail; organization changed only |
| `DOC-039` | `docs/architecture/0005-fixed-step-authoritative-runtime.md` | Persistent | Markdown | Manual | Canonical: `ARCHSPEC-0005`, governed by `ADR-0005` | Project owner | Controlled / Embedded / Not Applicable | Declared; links validated | Accepted detail; organization changed only |
| `DOC-040` | `docs/architecture/0006-runtime-ownership-and-failure.md` | Persistent | Markdown | Manual | Canonical: `ARCHSPEC-0006`, governed by `ADR-0006` | Project owner | Controlled / Embedded / Not Applicable | Declared; links validated | Accepted detail; organization changed only |
| `DOC-041` | `docs/architecture/0007-runtime-content-releases.md` | Persistent | Markdown | Manual | Canonical: `ARCHSPEC-0007`, governed by `ADR-0007` | Project owner | Controlled / Embedded / Not Applicable | Declared; links validated | Accepted detail; organization changed only |
| `DOC-042` | `docs/architecture/0008-evidence-and-ephemeral-state.md` | Persistent | Markdown | Manual | Canonical: `ARCHSPEC-0008`, governed by `ADR-0008` | Project owner | Controlled / Embedded / Not Applicable | Declared; links validated | Accepted detail; organization changed only |
| `DOC-043` | `docs/architecture/0009-runtime-deployment-contracts.md` | Persistent | Markdown | Manual | Canonical: `ARCHSPEC-0009`, governed by `ADR-0009` | Project owner | Controlled / Embedded / Not Applicable | Declared; links validated | Accepted detail; organization changed only |
| `DOC-044` | `docs/architecture/0010-cross-cutting-architecture-and-verification.md` | Persistent | Markdown | Manual | Canonical: `ARCHSPEC-0010` and every registered `AC-*` claim | Project owner | Controlled / Embedded / Not Applicable | Declared; links validated | Accepted detail; organization changed only |
| `DOC-045` | `docs/requirements/training-simulation-baseline-applicability.md` | Persistent | Markdown | Manual | Canonical: `BAI-CONTROL-002` | Project owner | Controlled / Embedded / Not Applicable | Declared; links validated | Approved `BAI-002` control |
| `DOC-046` | `docs/glossary/technical.md` | Persistent | Markdown | Manual | Canonical: `DOCINFO-TECHNICAL-LANGUAGE-001` | Project owner | Controlled / Embedded / Not Applicable | Declared; links validated | Candidate; approval pending |
| `DOC-047` | `docs/glossary/governance.md` | Persistent | Markdown | Manual | Canonical: `DOCINFO-GOVERNANCE-LANGUAGE-001` | Project owner | Controlled / Embedded / Not Applicable | Declared; links validated | Candidate; approval pending |
| `DOC-048` | `docs/project/training-simulation-baseline-artifact-inventory.md` | Persistent | Markdown | Manual | Canonical: `BARTINV-CONTROL-001` | Project owner | Controlled / Embedded / Not Applicable | Declared; links validated | Approved `BARTINV-003` |
| `DOC-049` | `docs/project/training-simulation-baseline-artifacts.csv` | Persistent | CSV | Manual | Canonical: `BARTINV-003`; title `Training Simulation Baseline Artifact Register`; purpose and scope: store normalized artifact identity, class, exact version, location, status, owner, and trace rows; intended readers: project owner, architects, designers, implementers, verification authors, reviewers, and tooling; structurally validated by `scripts/validate-baseline-artifact-inventory.py` | Project owner | Controlled / Inventory / Not Applicable | `DOC-019`, `DOC-036`, `DOC-044`, `DOC-045`, `DOC-048` | Approved `BARTINV-003` |
| `DOC-050` | `docs/project/training-simulation-architecture-claim-traces.csv` | Persistent | CSV | Manual | Canonical: `DOCINFO-ARCHITECTURE-CLAIM-TRACE-001`; title `Training Simulation Architecture Claim Trace Register`; purpose and scope: map every canonical ADR-0010 Architecture Claim state, claim disposition, and per-requirement disposition to one governing artifact and exact requirements; intended readers: project owner, architects, implementers, verification authors, reviewers, and tooling; structurally validated by `scripts/validate-baseline-artifact-inventory.py` | Project owner | Controlled / Inventory / Not Applicable | `DOC-036`, `DOC-044`, `DOC-048`, `DOC-049` | Approved `BARTINV-003` |
| `DOC-051` | `docs/project/training-simulation-evidence-dependency-inventory.md` | Persistent | Markdown | Manual | Canonical: `EDI-CONTROL-001`; global identity, effective population, graph semantics, reconciliation rules, impact procedure, and approval state | Project owner | Controlled / Embedded / Not Applicable | Declared; links validated | Approved `EDI-001` |
| `DOC-052` | `docs/project/training-simulation-evidence-dependency-nodes.csv` | Persistent | CSV | Manual | Canonical: `EDI-001-NODES`; title `Training Simulation Evidence Dependency Supplemental Node Register`; purpose and scope: store current nodes not imported from predecessor inventories; intended readers: project owner, architects, implementers, verification authors, reviewers, evidence custodians, and tooling; structurally validated by `scripts/validate-evidence-dependency-inventory.py` | Project owner | Controlled / Inventory / Not Applicable | `DOC-044`, `DOC-051` | Approved `EDI-001` |
| `DOC-053` | `docs/project/training-simulation-evidence-dependency-relations.csv` | Persistent | CSV | Manual | Canonical: `EDI-001-RELATIONS`; title `Training Simulation Evidence Dependency Supplemental Relation Register`; purpose and scope: store reviewed explicit directed typed relations not derived from predecessor traces; intended readers: project owner, architects, implementers, verification authors, reviewers, evidence custodians, and tooling; structurally validated by `scripts/validate-evidence-dependency-inventory.py` | Project owner | Controlled / Inventory / Not Applicable | `DOC-044`, `DOC-048`, `DOC-049`, `DOC-050`, `DOC-051`, `DOC-052` | Approved `EDI-001` |
| `DOC-054` | `docs/project/training-simulation-evidence-impact-cases.csv` | Persistent | CSV | Manual | Canonical: `EDI-001-IMPACT-CASES`; title `Training Simulation Evidence Impact Case Register`; purpose and scope: retain finite conservative traversal and fault-case expectations for `EDI-001`; intended readers: project owner, implementers, verification authors, reviewers, evidence custodians, and tooling; structurally validated by `scripts/validate-evidence-dependency-inventory.py` | Project owner | Controlled / Inventory / Not Applicable | `DOC-025`, `DOC-051`, `DOC-052`, `DOC-053` | Approved `EDI-001` |

## Reconciliation and validation

The authoritative population is the union of root `AGENTS.md`, `CONTEXT.md`,
`README.md`, `SECURITY.md`, `LICENSE`, every `*.md` below `docs/`, and retained
documentation datasets below `docs/`. `DOCINV-006` contains 54 documents: 47
manually maintained Markdown documents, one external-standard plain-text legal
document, and six manually maintained CSV inventories. It contains no retained
`Non-persistent` or `Generated` document.

Run the structural validator from the repository root:

```sh
python3 scripts/validate-documentation-inventory.py
```

The validator reconciles this population, stable document identifiers, paths,
classifications, owners, tier-applicable control fields, declared Markdown
links, and generated-Markdown Table-of-Contents rules. Semantic canonicality,
the completeness of information-item mappings, project-owner approval, and
evidence impact remain review decisions rather than facts a script can infer.

## Current acceptance boundary

The inventory and its document population are structurally reconciled for exact
version `DOCINV-006`, approved by the project owner on 2026-09-04.
`SECURITY.md` remains an explicitly non-authoritative future placeholder and
cannot support a security claim. The generated verification-assignment
inventory is a compact canonical index and cannot substitute for the Baseline
Artifact or Evidence Dependency Inventory.

Architecture decisions remain closed by ADR-0010; their detailed specifications
now live separately under `docs/architecture/`. Product realization and
architecture evidence remain incomplete. Approved `BAI-002` contains 1,148
exactly-once entries: 928 `Included`, 201 `Future`, and 19 `Not Applicable`.
It makes no realization, evidence, or baseline-approval claim. Baseline approval
remains blocked by every other unresolved requirement or evidence dependency
identified by the approved baselines and architecture decisions.

## `DOCINV-006` impact analysis

This successor registers the Evidence Dependency Inventory control and its
three retained CSV registers and routes repository agents to the inventory at
the governed verification and change-impact decisions. Existing document
identifiers, canonical owners, applicability dispositions, and Architecture
Claim relations are unchanged.

Evidence impact is conservative: no accepted product-baseline or Architecture
Claim evidence exists to retain or invalidate. Existing prototype evidence and
the generated verification-assignment view cannot acquire an acceptance
disposition from `BAI-002` or `BARTINV-003`. Neither inventory assigns
realization or evidence state or turns `Future` or `Not Applicable` into
`Pass`. Approved `BARTINV-002` is the predecessor input to the
coverage-validated, project-owner-approved `BARTINV-003` and `EDI-001`; baseline
approval remains blocked by every other unresolved evidence dependency.
Any source, classification, trace, disposition, milestone, ownership, or
dependency change requires the applicable successor inventory and fresh impact
analysis.

## Change control

Adding, removing, renaming, reclassifying, or changing ownership of a document
or mapped information item requires a successor Documentation Inventory
version. The change triggers documentation and evidence-impact analysis under
`PROCESS-DOCUMENTATION-INVENTORY-006` and `PROCESS-EVIDENCE-CHANGE-001`
through `PROCESS-EVIDENCE-CHANGE-006`.

The implementation team maintains the inventory. The project owner approves
each exact reconciled version. A structural validator result supports but does
not replace that reconciliation and approval.
