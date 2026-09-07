# Training Simulation Software Design Baseline

Status: Candidate successor; project-owner approval pending

Last meaningful change: 2026-09-06

Baseline version: `SDB-002`

Approved predecessor: `SDB-001`, project owner, 2026-09-04

Version basis: This control document, the Design Commitment register, and the
four subordinate SDDs listed below. Any normative edit creates a successor
Software Design Baseline.

Purpose: Control the implementation-facing design slice derived from the
approved requirements and Software Architecture Description, including exact
codecs, acceptance, rationale, and visible design risk.

Scope: Process control, common runtime startup, Session Authority composition,
Trainee Client composition, and the offline Content Cooker Tool.

Intended readers: Project owner, designers, implementers, verification authors,
architects, and reviewers.

Required reviewers: One runtime-design reviewer, one content-design reviewer,
and one verification-design reviewer acting independently, followed by the
project owner. The runtime and verification reviewers cover the complete
package; the content reviewer additionally covers `SDD-0004`.

Prerequisites: Approved initial requirements, SAD-003, ADR-0013,
ARCHSPEC-0013, approved governance inventories, and the retained Software
Design Document Guidance.

Canonical information owner: Project owner.

## Goals, non-goals, assumptions, and constraints

The goal is to leave no implementation-local choice about startup ordering,
representation, ownership, failure containment, or acceptance. Success means
that all three independent reviewers derive the same observable behavior and a
verification author can construct every acceptance case without inventing a
schema, limit, order, or expected result.

This baseline does not design Training Session gameplay, native adapters,
orchestration, distribution, a resident launcher, a Content Cooker execution
platform, or an implementation schedule. It assumes selected identities,
profiles, catalogues, signing authorization, and destinations were provisioned
by their owners; every applicable value is nevertheless validated before
commit. English remains canonical. An upstream requirement, Approved Profile,
catalogue, or architecture specification continues to own its values and
meaning.

## Package and authority

The candidate package is:

| Component | Identity | SHA-256 |
| --- | --- | --- |
| Design Commitment register | `SDB-002-DC` | `e8cd5a58124fda7260f117b7b4ba716fd4daec10e01b51d342b2760fd51fdcf4` |
| Process Control Contract SDD | `SDD-0001` | `f589a365b6acd4026c697e5a8f04124d101170a9d63a0eb59b610099878a3a62` |
| Session Authority Runtime SDD | `SDD-0002` | `58f741603c3cecefee06c29a2b4f3e0fc6f41b155a642fb067e331a1855e8c6b` |
| Trainee Client Runtime SDD | `SDD-0003` | `fe2c5c4f513e36eb899a1c73aa854e77b52fa3ddab2308435a74cb88691c8484` |
| Content Cooker Tool SDD | `SDD-0004` | `730667db778dd840722ac5edb57490fe716a9446f9c106fc148b3c48e8636f46` |

The CSV register owns identity, state, disposition, traces, owner, and
verification approach. Each SDD owns its obligation text, interface and codec
tables, ordering, failure semantics, rationale, and acceptance criteria.

Only text explicitly attached to a `DC-*` key, including a table or schema it
incorporates, is normative software-design text. Other prose is explanatory.
`MUST` and `MUST NOT` have their RFC 2119 meanings. This package uses no
normative `SHOULD`, `SHOULD NOT`, `MAY`, or `WILL`.

## Design state model

| Dimension | Closed values |
| --- | --- |
| Decision | `Proposed`, `Accepted`, `Superseded` |
| Applicability | `Included`, `Future`, `Not Applicable` |
| Realization | `Not Implemented`, `Partial`, `Implemented` |
| Evidence | `Blocked`, `Planned`, `Pass`, `Fail` |

The dimensions are independent. `Accepted` means only that a design decision
governs. A design-local unresolved choice blocks approval; an external
realization or evidence blocker may remain only when it is explicit.

## Commitment and acceptance rules

Each `DC-*` has one governing SDD, owner, principal `MUST` or `MUST NOT`,
separate rationale, canonical input trace, and objective `DAC-*` acceptance
criterion. Requirements remain owned by their canonical sources; a missing
product obligation is corrected there rather than invented as `DREQ-*`.

Each `DAC-*` fixes preconditions, stimulus, result, prohibited result,
measurement boundary, configuration, and retained evidence. It is an SDD-local
criterion, not an Evidence Dependency Inventory `Obligation Key`; product
`Pass` remains blocked until an approved procedure registers the corresponding
key and evidence record. Doubles can inject results at real seams but cannot
replace product behavior for acceptance.

## Input coverage and inverse trace

The register is the canonical forward trace. This inverse index covers every
authoritative input selected for this design slice. No derived requirement is
needed because every commitment is governed directly by a canonical input.

| Input | Design allocation |
| --- | --- |
| `REQ-RUNTIME-EXTERNAL-LIFECYCLE-001` | `DC-PROCESS-001`, `DC-PROCESS-003`, `DC-PROCESS-005`, `DC-PROCESS-007`, `DC-PROCESS-008`, `DC-PROCESS-010`, `DC-CLIENT-002` |
| `REQ-RUNTIME-CONTROL-LOSS-001` | `DC-PROCESS-001`, `DC-PROCESS-004`, `DC-PROCESS-009`; `DC-AUTHORITY-006`; `DC-CLIENT-006` |
| `REQ-RUNTIME-LAUNCH-SPECIFICATION-001` | `DC-PROCESS-002`, `DC-PROCESS-008`, `DC-PROCESS-013`; `DC-AUTHORITY-002`, `DC-AUTHORITY-008`; `DC-CLIENT-001`, `DC-CLIENT-008` |
| `REQ-RUNTIME-LAUNCH-SPECIFICATION-002` | `DC-PROCESS-002`, `DC-PROCESS-006`, `DC-PROCESS-009`, `DC-PROCESS-011`, `DC-PROCESS-012`, `DC-PROCESS-013`, `DC-PROCESS-014`, `DC-PROCESS-015`; `DC-AUTHORITY-002`, `DC-AUTHORITY-007`; `DC-CLIENT-001`, `DC-CLIENT-007`, `DC-CLIENT-010` |
| `REQ-RUNTIME-READINESS-001` | `DC-PROCESS-006`, `DC-PROCESS-014`; `DC-AUTHORITY-001`, `DC-AUTHORITY-003`, `DC-AUTHORITY-007` |
| `REQ-AUTHORITY-SINGLE-SESSION-001` | `DC-AUTHORITY-001`, `DC-AUTHORITY-008` |
| `REQ-AUTHORITY-TERMINAL-SETTLEMENT-001` | `DC-AUTHORITY-004`, `DC-AUTHORITY-009` |
| `REQ-AUTHORITY-TERMINAL-SHUTDOWN-001` | `DC-AUTHORITY-004`, `DC-AUTHORITY-009` |
| `REQ-STATE-CONSISTENCY-001` | `DC-AUTHORITY-005`; `DC-CLIENT-009` |
| `NFR-OBSERVABILITY-INTEGRITY-001` | `DC-AUTHORITY-006` |
| `REQ-CONTENT-ACTIVATION-001` | `DC-AUTHORITY-002`; `DC-CLIENT-001` |
| `REQ-READINESS-001` | `DC-CLIENT-002` |
| `REQ-SESSION-CONNECTION-001` | `DC-CLIENT-003`, `DC-CLIENT-008` |
| `REQ-CLIENT-RECONNECT-001` | `DC-CLIENT-003` |
| `REQ-ADMISSION-FAILURE-001` | `DC-CLIENT-004` |
| `REQ-VOLUNTARY-LEAVE-CONFIRMATION-001` | `DC-CLIENT-005` |
| `REQ-CONTENT-COOKER-TOOL-001` | `DC-COOKER-001`, `DC-COOKER-009` |
| `REQ-COOKING-JOB-SPECIFICATION-001` | `DC-COOKER-002`, `DC-COOKER-008`, `DC-COOKER-010`, `DC-COOKER-012` |
| `REQ-CONTENT-PROCESSING-001` | `DC-COOKER-003`, `DC-COOKER-010`, `DC-COOKER-012`, `DC-COOKER-018`, `DC-COOKER-022` |
| `REQ-CONTENT-PROCESSING-GATE-001` | `DC-COOKER-015` |
| `REQ-CONTENT-PROCESSING-RECORD-001` | `DC-COOKER-016`, `DC-COOKER-023` |
| `REQ-CONTENT-TRACEABILITY-001` | `DC-COOKER-017` |
| `REQ-CONTENT-PROCESSING-ADMISSION-001` | `DC-COOKER-018` |
| `REQ-CONTENT-PAIR-001` | `DC-COOKER-019`, `DC-COOKER-022` |
| `REQ-CONTENT-PACK-ROLE-001` | `DC-COOKER-021` |
| `REQ-CONTENT-PAIR-ATOMIC-001` | `DC-COOKER-004`, `DC-COOKER-005`, `DC-COOKER-011`, `DC-COOKER-014`, `DC-COOKER-020` |
| `REQ-CONTENT-RELEASE-001` | `DC-COOKER-004` |
| `REQ-COOKING-JOB-PROVENANCE-001` | `DC-COOKER-006` |
| `REQ-CONTENT-SIGNING-001` | `DC-COOKER-013`, `DC-COOKER-020`, `DC-COOKER-022` |
| `DEFERRED-CONTENT-COOKER-PLATFORM-001` | `DC-COOKER-007`; `SDR-003` |

## Design risks, assumptions, and deferred decisions

| ID | State | Item and impact | Owner | Resolution criterion and due point | Blocking effect |
| --- | --- | --- | --- | --- | --- |
| `SDR-001` | Risk | Native pipes may violate complete-frame publication or terminal reserve under short writes. | Runtime composition | Native contract suite passes before adapter acceptance. | Blocks adapter `Implemented` and `Pass`. |
| `SDR-002` | Risk | Native publication may report ambiguous durability after interruption. | Content Cooker Tool | Publisher suite proves `Committed` or `Not Committed` at every boundary before native acceptance. | Blocks native publisher `Implemented` and `Pass`. |
| `SDR-003` | Deferred | Content Cooker platform, hardware profile, packaging, and distribution are unselected. | Project owner | Approve the baseline named by `DEFERRED-CONTENT-COOKER-PLATFORM-001`. | Blocks `DC-COOKER-007` evidence `Pass`. |
| `SDR-004` | Assumption | Provisioned identity bytes and paths are canonical under their owning contracts. | Project and deployment owners | Re-evaluate when an identity or platform path model changes. | Trigger requires an SDB successor. |
| `SDR-005` | Risk | The 64 KiB launch and 1 MiB cooking-job bounds may not fit the largest admitted closure. | Runtime composition and Content Cooker Tool | Prove the largest approved closure fits with 10% headroom before implementation planning, or revise the design. | Blocks planning for a failing input. |
| `SDR-006` | Review gate | Different interpretations would invalidate approval. | Independent reviewers | Runtime and verification reviewers both restate every `DC-*` and derive its `DAC-*`; the content reviewer does the same for every `DC-COOKER-*`; all three report no unresolved material difference. | Blocks SDB-002 approval. |
| `SDR-007` | External dependency | No approved concrete Content Processing Gate is retained and `RRTI-001` admits zero Runtime Resource Types, so no deployment-ready role closure can yet be cooked. | Project owner and resource semantic owners | Approve one exact gate version and a nonzero applicable RRTI population before cooker realization or evidence acceptance. | Does not block design approval; blocks `DC-COOKER-015` through `DC-COOKER-023` realization and `Pass`. |

## Decisions, rationale, and trade-offs

| Decision | Choice and rationale | Rejected alternative | Reconsideration trigger |
| --- | --- | --- | --- |
| `SDD-DEC-001` | Fixed binary framing plus closed deterministic CBOR gives bounded, inspectable, portable contracts. | Native structs leak ABI; JSON varies; generic Protobuf/CBOR permits unknown behavior. | A required field cannot fit v1 or a platform lacks a conforming codec. |
| `SDD-DEC-002` | Finish reversible endpoint effects before semantic-owner commit. | Post-commit bind may strand committed owners after endpoint failure. | An accepted requirement requires post-commit allocation. |
| `SDD-DEC-003` | Keep lifecycle and ReleasePublisher interfaces deep and composition roots thin. | General filesystem/socket interfaces and service locators distribute policy. | A second real caller cannot use the seam without violating ownership. |
| `SDD-DEC-004` | Use specification-selected finite capacities and document bounds. | Adaptive growth makes readiness depend on ambient state. | An approved profile proves a different finite bound is necessary. |

## Change and acceptance control

A requirement, claim, SAD view, SDD obligation, interface, codec, criterion,
risk, or state change triggers conservative Evidence Dependency Inventory
impact traversal. Editing a pinned SDD or register creates an SDB successor.

Candidate `SDB-002` cannot become approved until `SDR-006` passes and every
included commitment is `Accepted / Included`. Product acceptance additionally
requires `Implemented / Pass` and resolution of every applicable external
decision.
