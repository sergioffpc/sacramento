# Detailed software design

Status: Candidate `SDB-002`; project-owner approval of changed design meaning
remains pending. The approved predecessor is `SDB-001` (2026-09-04).
Owner: Project owner. Git identifies the revision.

The four design contracts define process control, runtime startup and composition,
and offline cooking. Their existing commitments remain Proposed / Included /
Not Implemented / Planned. These shared statuses live here rather than in a CSV;
a future exception must be explicit in its owning contract.

| Affected boundary | Contract |
| --- | --- |
| Framing, launch and lifecycle control | [Process control](0001-process-control-contract.md) |
| Authority startup and terminal settlement | [Session Authority](0002-session-authority-runtime.md) |
| Client startup, Admission and removal | [Trainee Client](0003-trainee-client-runtime.md) |
| Offline processing and durable publication | [Content Cooker](0004-content-cooker-tool.md) |

Read only affected requirements, architecture contracts and acceptance criteria.
Each `DC-*` obligation retains its owner, rationale and objective `DAC-*` criterion
in the owning SDD. Criteria specify inputs, observable outcomes, bounds, failure
cases and evidence. A planned criterion is not an executed Pass; test doubles
cannot replace required product behavior. Trace changes directly to governing
requirements and contracts, without a register or inverse coverage table.

The design does not select gameplay, native adapters, orchestration, distribution,
a resident launcher, a cooker execution platform or an implementation schedule.
Selected profiles, identities, signing authority and destinations remain governed
upstream and must be validated before commit.

## Design risks, assumptions, and deferred decisions

| ID | State | Item and impact | Owner | Resolution criterion and due point | Blocking effect |
| --- | --- | --- | --- | --- | --- |
| `SDR-001` | Risk | Native pipes may violate complete-frame publication or terminal reserve under short writes. | Runtime composition | Native contract suite passes before adapter acceptance. | Blocks adapter `Implemented` and `Pass`. |
| `SDR-002` | Risk | Native publication may report ambiguous durability after interruption. | Content Cooker Tool | Publisher suite proves `Committed` or `Not Committed` at every boundary before native acceptance. | Blocks native publisher `Implemented` and `Pass`. |
| `SDR-003` | Deferred | Content Cooker platform, hardware profile, packaging, and distribution are unselected. | Project owner | Approve the baseline named by `DEFERRED-CONTENT-COOKER-PLATFORM-001`. | Blocks `DC-COOKER-007` evidence `Pass`. |
| `SDR-004` | Assumption | Provisioned identity bytes and paths are canonical under their owning contracts. | Project and deployment owners | Re-evaluate when an identity or platform path model changes. | Review affected contracts at the changed Git revision. |
| `SDR-005` | Risk | The 64 KiB launch and 1 MiB cooking-job bounds may not fit the largest admitted closure. | Runtime composition and Content Cooker Tool | Prove the largest approved closure fits with 10% headroom before implementation planning, or revise the design. | Blocks planning for a failing input. |
| `SDR-006` | Review gate | Different interpretations would invalidate acceptance of affected design. | Project owner and relevant reviewers | Changed commitments and criteria have no unresolved material ambiguity; review scopes follow ADR-0014 rather than a mandatory full-package panel. | Blocks acceptance of ambiguous design. |
| `SDR-007` | External dependency | No approved concrete Content Processing Gate is retained and no Runtime Resource Type has an approved concrete contract, so no deployment-ready role closure can yet be cooked. | Project owner and resource semantic owners | Approve one exact gate version and the required exact Runtime Resource Type contracts before cooker realization or evidence acceptance. | Does not block design approval; blocks `DC-COOKER-015` through `DC-COOKER-023` realization and `Pass`. |

## Decisions, rationale, and trade-offs

| Decision | Choice and rationale | Rejected alternative | Reconsideration trigger |
| --- | --- | --- | --- |
| `SDD-DEC-001` | Fixed binary framing plus closed deterministic CBOR gives bounded, inspectable, portable contracts. | Native structs leak ABI; JSON varies; generic Protobuf/CBOR permits unknown behavior. | A required field cannot fit v1 or a platform lacks a conforming codec. |
| `SDD-DEC-002` | Finish reversible endpoint effects before semantic-owner commit. | Post-commit bind may strand committed owners after endpoint failure. | An accepted requirement requires post-commit allocation. |
| `SDD-DEC-003` | Keep lifecycle and ReleasePublisher interfaces deep and composition roots thin. | General filesystem/socket interfaces and service locators distribute policy. | A second real caller cannot use the seam without violating ownership. |
| `SDD-DEC-004` | Use specification-selected finite capacities and document bounds. | Adaptive growth makes readiness depend on ambient state. | An approved profile proves a different finite bound is necessary. |

## Change and acceptance

Review changed meaning and affected dependencies under
[the acceptance workflow](../requirements/training-simulation-verification-plan.md).
Unresolved design ambiguity blocks the affected design; external implementation
or evidence blockers remain explicit. Owner acceptance of candidate design
does not implement it or satisfy product acceptance. Git versions the change;
there is no inventory-successor or full-package mechanical approval cycle.
