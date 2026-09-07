# Training Simulation Software Design Baseline

Status: Candidate successor; project-owner approval pending

Last meaningful change: 2026-09-06

Baseline version: `SDB-002`

Approved predecessor: `SDB-001`, project owner, 2026-09-04

Version basis: Git identifies this control document, the Design Commitment
register and the four subordinate SDDs. ADR-0014 removes manually recopied hashes
and full-package mechanical approval; design meaning remains candidate.

Purpose: Control the implementation-facing design slice derived from the
approved requirements and Software Architecture Description, including exact
codecs, acceptance, rationale, and visible design risk.

Scope: Process control, common runtime startup, Session Authority composition,
Trainee Client composition, and the offline Content Cooker Tool.

Intended readers: Project owner, designers, implementers, verification authors,
architects, and reviewers.

Review scope: Review changed runtime, content and verification semantics with
the relevant expertise; use independent review where ambiguity or risk warrants
it. ADR-0014 removes the mandatory three-person/full-package documentary gate,
not objective acceptance criteria or owner decisions about design meaning.

Read only affected requirements, architecture sections and interface contracts.
Research guidance and generated inventory listings are not approval prerequisites.

Canonical information owner: Project owner.

## Goals, non-goals, assumptions, and constraints

The goal is unambiguous startup ordering, representation, ownership, failure
containment and acceptance. A verification author must be able to construct each
acceptance case without inventing a schema, limit, order or expected result.

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

| Component | Identity |
| --- | --- |
| [Design Commitment register](training-simulation-design-commitments.csv) | `SDB-002-DC` |
| [Process Control Contract](0001-process-control-contract.md) | `SDD-0001` |
| [Session Authority Runtime](0002-session-authority-runtime.md) | `SDD-0002` |
| [Trainee Client Runtime](0003-trainee-client-runtime.md) | `SDD-0003` |
| [Content Cooker Tool](0004-content-cooker-tool.md) | `SDD-0004` |

Exact content hashes are generated in `build/docs/documents.csv`, not maintained
here. Candidate commitments and product acceptance states are unchanged.

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
| `SDR-006` | Review gate | Different interpretations would invalidate acceptance of affected design. | Project owner and relevant reviewers | Changed commitments and criteria have no unresolved material ambiguity; review scopes follow ADR-0014 rather than a mandatory full-package panel. | Blocks acceptance of ambiguous design. |
| `SDR-007` | External dependency | No approved concrete Content Processing Gate is retained and `RRTI-001` admits zero Runtime Resource Types, so no deployment-ready role closure can yet be cooked. | Project owner and resource semantic owners | Approve one exact gate version and a nonzero applicable RRTI population before cooker realization or evidence acceptance. | Does not block design approval; blocks `DC-COOKER-015` through `DC-COOKER-023` realization and `Pass`. |

## Decisions, rationale, and trade-offs

| Decision | Choice and rationale | Rejected alternative | Reconsideration trigger |
| --- | --- | --- | --- |
| `SDD-DEC-001` | Fixed binary framing plus closed deterministic CBOR gives bounded, inspectable, portable contracts. | Native structs leak ABI; JSON varies; generic Protobuf/CBOR permits unknown behavior. | A required field cannot fit v1 or a platform lacks a conforming codec. |
| `SDD-DEC-002` | Finish reversible endpoint effects before semantic-owner commit. | Post-commit bind may strand committed owners after endpoint failure. | An accepted requirement requires post-commit allocation. |
| `SDD-DEC-003` | Keep lifecycle and ReleasePublisher interfaces deep and composition roots thin. | General filesystem/socket interfaces and service locators distribute policy. | A second real caller cannot use the seam without violating ownership. |
| `SDD-DEC-004` | Use specification-selected finite capacities and document bounds. | Adaptive growth makes readiness depend on ambient state. | An approved profile proves a different finite bound is necessary. |

## Change and acceptance control

A requirement, claim, architecture section, SDD obligation, interface, codec,
criterion, risk or state change triggers conservative impact analysis under
`VERIFY-CHANGE-001`. Git versions the changed design; only changed meaning and
affected dependencies require review.

Candidate `SDB-002` cannot become approved until `SDR-006` passes and every
included commitment is `Accepted / Included`. Product acceptance additionally
requires `Implemented / Pass` and resolution of every applicable external
decision.
