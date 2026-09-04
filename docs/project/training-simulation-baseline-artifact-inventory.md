# Training Simulation Baseline Artifact Inventory

Status: Approved

Approval: Project owner, 2026-09-04

Inventory version: `BARTINV-003`

Package SHA-256: `990d0026ac349b6ccc14ac2fa5211536271767a5a6b411638a667dc3666e3a70`

Approved package SHA-256: `990d0026ac349b6ccc14ac2fa5211536271767a5a6b411638a667dc3666e3a70`

Version basis: The package SHA-256 and the per-artifact SHA-256 versions in the
three inventory-package documents; any governed artifact, trace,
classification, owner, or status change creates a successor inventory version
before integration.

Purpose: Reconcile every governed architecture, design, implementation, and
verification artifact for the Development Baseline and retain exact
requirement and Architecture Claim traces.

Scope: The governed artifact populations declared by the authoritative sources
below. Retained legal text, navigation, agent routing, non-canonical research,
repository-hygiene configuration, dependency-update scheduling, Git objects,
transient files, GitHub issues, and pull requests are not Development Baseline
architecture, design, implementation, or verification artifacts.

Intended readers: Project owner, architects, designers, implementers,
verification authors, reviewers, and repository agents.

Prerequisites: [Documentation
Inventory](training-simulation-documentation-inventory.md), [Baseline
Applicability Inventory](../requirements/training-simulation-baseline-applicability.md),
[ADR-0010](../adr/0010-close-cross-cutting-architecture-and-verification.md),
and its [Architecture Claim
register](../architecture/0010-cross-cutting-architecture-and-verification.md#architecture-claim-register).

Canonical information owner: Project owner.

## Table of contents

- [Inventory package](#inventory-package)
- [Authoritative populations](#authoritative-populations)
- [Artifact classes](#artifact-classes)
- [Artifact schema](#artifact-schema)
- [Architecture Claim traces](#architecture-claim-traces)
- [Reconciliation and validation](#reconciliation-and-validation)
- [Current acceptance boundary](#current-acceptance-boundary)
- [Change control](#change-control)

## Inventory package

`BARTINV-003` is one atomic version comprising this control document, the
[artifact register](training-simulation-baseline-artifacts.csv), and the
[Architecture Claim trace register](training-simulation-architecture-claim-traces.csv).
Those three files use `BARTINV-003@sha256:<package-digest>` as their exact
version. The digest hashes their sorted paths and contents after replacing each
embedded copy of the digest with 64 zeroes, avoiding a cyclic self-hash while
binding the complete package content. Every other artifact version is its
lowercase SHA-256 digest prefixed by `sha256:`.

The artifact register is the reviewed canonical classification. Repository
discovery within the declared authoritative source selectors is only a
structural population cross-check; it cannot establish an artifact's class,
canonicality, semantic trace completeness, status, or owner.

## Authoritative populations

Each selector below is an explicit registry boundary derived from the approved
Documentation Inventory, ADR-0010, and C++ Engineering Baseline. A selector
must resolve to at least one artifact. Overlap is invalid.

| Source selector | Artifact class | Authority |
| --- | --- | --- |
| `docs/adr/*.md` | `Architecture` | Documentation Inventory `ADR-0001` through `ADR-0010` mapping |
| `docs/architecture/*.md` | `Architecture` | Documentation Inventory `ARCHSPEC-0003` through `ARCHSPEC-0010` mapping |
| `CONTEXT.md` | `Design` | Documentation Inventory `DOCINFO-DOMAIN-LANGUAGE-001` mapping |
| `docs/glossary/*.md` | `Design` | Documentation Inventory technical and governance language mappings |
| `docs/requirements/training-simulation-initial-requirements.md` | `Design` | Canonical functional and process requirement source |
| `docs/requirements/training-simulation-non-functional-requirements.md` | `Design` | Canonical non-functional requirement source |
| `docs/requirements/training-simulation-observability-contract.md` | `Design` | Canonical Observability Contract source |
| `docs/requirements/training-simulation-performance-assessment-requirements.md` | `Design` | Canonical performance-assessment source |
| `docs/requirements/training-simulation-performance-profile-engagement-target-001.md` | `Design` | Canonical Engagement Target Performance Profile source |
| `docs/requirements/training-simulation-reference-hardware-profiles.md` | `Design` | Canonical Reference Hardware Profile source |
| `docs/standards/*.md` | `Design` | Documentation Inventory approved-standard mappings |
| `CMakeLists.txt` | `Implementation` | C++ Engineering Baseline build definition |
| `CMakePresets.json` | `Implementation` | C++ Engineering Baseline checked-in build interface |
| `cmake/*.cmake` | `Implementation` | C++ Engineering Baseline CMake population |
| `cmake/toolchains/*.cmake` | `Implementation` | C++ Engineering Baseline target toolchains |
| `config/cpp/*` | `Implementation` | C++ Engineering Baseline machine-readable toolchain inventory and configurations |
| `scripts/cpp-toolchain-bootstrap.sh` | `Implementation` | C++ Engineering Baseline bootstrap entry point |
| `triplets/*.cmake` | `Implementation` | C++ Engineering Baseline project triplets |
| `vcpkg-configuration.json` | `Implementation` | C++ Engineering Baseline dependency-registry configuration |
| `vcpkg.json` | `Implementation` | C++ Engineering Baseline dependency manifest |
| `.clang-format` | `Verification` | C++ Engineering Baseline format gate configuration |
| `.clang-tidy` | `Verification` | C++ Engineering Baseline lint gate configuration |
| `.githooks/commit-msg` | `Verification` | Conventional Commit Profile local gate |
| `.github/workflows/*.yml` | `Verification` | Git Flow authoritative remote gates |
| `docs/project/training-simulation-documentation-inventory.md` | `Verification` | Documentation Inventory control and reconciliation record |
| `docs/project/training-simulation-baseline-artifact-inventory.md` | `Verification` | Baseline Artifact Inventory control |
| `docs/project/training-simulation-baseline-artifacts.csv` | `Verification` | Baseline Artifact register |
| `docs/project/training-simulation-architecture-claim-traces.csv` | `Verification` | Architecture Claim trace register |
| `docs/project/training-simulation-evidence-dependency-inventory.md` | `Verification` | Evidence Dependency Inventory control |
| `docs/project/training-simulation-evidence-*.csv` | `Verification` | Evidence Dependency supplemental registers and impact cases |
| `docs/requirements/training-simulation-baseline-applicability-inventory.csv` | `Verification` | Baseline Applicability register |
| `docs/requirements/training-simulation-baseline-applicability.md` | `Verification` | Baseline Applicability control |
| `docs/requirements/training-simulation-verification-plan.md` | `Verification` | Canonical Verification Plan |
| `scripts/generate-verification-assignment-inventory.py` | `Verification` | Verification-assignment generator |
| `scripts/validate-*` | `Verification` | Repository-owned inventory and commit-policy validators |
| `scripts/validate_commit_message.py` | `Verification` | Conventional Commit Profile validator |

## Artifact classes

| Class | Boundary |
| --- | --- |
| `Architecture` | Accepted decisions and their detailed architecture specifications |
| `Design` | Canonical product, requirement, profile, and approved-standard artifacts |
| `Implementation` | Build, dependency, toolchain, automation, and repository-execution artifacts |
| `Verification` | Verification plans, inventories, validation programs, quality gates, and their workflow definitions |

Every artifact resolved by the declared selectors has exactly one class. A
future selector may admit `Not Applicable` or `Future` artifacts only with the
corresponding objective disposition required below.

## Artifact schema

The artifact register columns are normative:

| Field | Rule |
| --- | --- |
| `sequence` | Contiguous register order starting at 1 |
| `artifact_identifier` | Stable `BART-<class>-NNN` identity; surviving IDs are never renumbered and retired IDs are never reused |
| `artifact_class` | Exactly `Architecture`, `Design`, `Implementation`, or `Verification` |
| `exact_version` | `sha256:<digest>` or the version-plus-digest identity for an inventory-package file |
| `canonical_location` | Unique repository-relative retained path |
| `baseline_status` | Exactly `Included`, `Future`, or `Not Applicable` |
| `responsible_owner` | One named owner |
| `trace_disposition` | Exactly `Satisfies`, `Intentional Deferral`, or `Not Applicable` |
| `requirement_traces` | Semicolon-separated exact stable requirement identifiers, or empty only for `Not Applicable` |
| `trace_basis` | Concise artifact-specific satisfaction, deferral, or objective non-applicability basis |

`Satisfies` belongs to an `Included` artifact. `Intentional Deferral` belongs
to a `Future` artifact and names only `Future` requirements from `BAI-002`.
`Not Applicable` belongs to a `Not Applicable` artifact and states an objective
basis. Ranges, wildcard-only traces, section names, and unknown identifiers are
invalid.

## Architecture Claim traces

The claim register maps every stable `AC-*` key in ADR-0010's canonical
register to one governing architecture artifact, its exact four-dimensional
state, a claim disposition, and the complete expansion of its primary
requirement traces. Each trace records its own `Satisfies`, `Intentional
Deferral`, or `Not Applicable` relation from the matching `BAI-002`
disposition. The artifact supplies its exact version, location, class, status,
and owner. A range in the architecture source is expanded according to the
ordered `BAI-002` requirement population and is never retained as a wildcard
or textual range in this inventory.

## Reconciliation and validation

When a governed artifact changes:

1. create a successor `BARTINV-*` version and update its artifact row, SHA-256,
   classification, status, owner, and exact traces;
2. update every affected Architecture Claim row from the canonical ADR-0010
   register;
3. reconcile the Documentation Inventory when its population or ownership
   changes; and
4. run from the repository root:

```sh
python3 scripts/validate-baseline-artifact-inventory.py
```

Completion requires one row for every artifact resolved from the authoritative
selectors, valid exact versions, all four classes, complete row metadata, known
exact traces, and one exact mapping and disposition for every canonical
Architecture Claim. Semantic completeness and project-owner approval remain
review decisions.

## Current acceptance boundary

`BARTINV-003` is structurally reconciled for 70 artifacts: 18 Architecture, 12
Design, 18 Implementation, and 22 Verification. Every one of the 66 ADR-0010
Architecture Claims resolves to its governing artifact and exact primary
requirement identifiers.

The inventory records artifacts and trace relations; it does not claim product
realization, verification evidence, Production Security Baseline or Platform
Operations Baseline satisfaction, or Development Baseline acceptance. The
Evidence Dependency Inventory is now the coverage-validated and
project-owner-approved `EDI-001`. Neither inventory can support `Pass` or
`Unaffected` without satisfying the inventory's substantive rules.

## Change control

Adding, removing, changing, or reclassifying a governed artifact, trace,
status, owner, or Architecture Claim mapping creates a successor inventory
version. The implementation team maintains and reconciles the inventory. The
project owner approves each exact version. Validation supports but never
replaces semantic review, reconciliation, or approval.
