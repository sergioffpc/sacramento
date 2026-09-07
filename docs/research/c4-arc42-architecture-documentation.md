# C4, arc42, ADRs and UML: Architecture Documentation Research

## Scope and status

Research date: 2026-09-06. Non-canonical research and a proposal for later work;
this note does not approve an architecture change or supersede existing project
documents. External facts have primary-source citations. Recommendations and
project-specific inferences are identified separately.

## Finding

**Recommendation:** use one short architecture description organized with arc42,
containing C4 structural views, selected UML behavioral views and links to the
existing ADRs. Give each kind of information one maintained home. Replacing
repeated prose with useful views can reduce reading; maintaining four parallel
descriptions would increase it.

## What the four approaches contribute

### C4: structural views at different scales

C4 organizes architecture visualization into four levels; it does not prescribe
a drawing notation. Its guidance says context and container diagrams suffice for
many teams, with further levels used when valuable. It also provides supporting
dynamic, deployment and landscape diagrams.
[C4 diagrams](https://c4model.com/diagrams),
[C4 notation](https://c4model.com/diagrams/notation).

| Level | Question answered |
| --- | --- |
| 1. Context | Who uses the system, and which other systems interact with it? [Context](https://c4model.com/diagrams/system-context) |
| 2. Containers | Which applications and data stores compose it, and how do they communicate? [Containers](https://c4model.com/diagrams/container) |
| 3. Components | How is one container internally divided into responsibilities? This level is optional. [Components](https://c4model.com/diagrams/component) |
| 4. Code | Which implementation elements realize a component? Usually optional and preferably generated when needed. [Code](https://c4model.com/diagrams/code) |

A C4 **container** is a runtime or storage boundary, such as a desktop
application or data store. It does not mean Docker. A library, DLL or source
module is normally not a container. Deployment is a separate concern.
[Container definition](https://c4model.com/abstractions/container).

### arc42: an outline for the architecture description

arc42 supplies twelve sections. In paraphrased form, they cover:

1. Purpose, important requirements and goals.
2. Constraints on the solution.
3. System boundary and external context.
4. Overall solution approach.
5. Internal building blocks and responsibilities.
6. Behavior during execution.
7. Mapping software onto infrastructure.
8. Concepts shared across the system.
9. Significant choices and their rationale.
10. Detailed quality expectations and scenarios.
11. Known risks and accumulated compromises.
12. Definitions of relevant terms.

[Official arc42 overview](https://arc42.org/overview/).

These are categories of information, not twelve required large documents.
The authors explicitly advise against filling everything: document what readers
need, accounting for future maintenance. Their suggested minimum includes a few
quality scenarios, context/interfaces, solution strategy, top-level building
blocks and important shared concepts.
[Tailoring](https://faq.arc42.org/questions/B-1/),
[Minimum useful content](https://faq.arc42.org/questions/B-4/).

### ADRs: the reasons behind important choices

Michael Nygard's original proposal is a short record of one significant decision,
with title, context, decision, status and consequences, including drawbacks.
Superseded records remain available with a link to the successor.
[Original ADR proposal](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions).

arc42 section 9 explicitly accommodates ADRs and advises avoiding repeated
decision text.
[arc42 decisions](https://docs.arc42.org/section-9/).

**Recommendation:** preserve useful existing ADRs and link to them. Reformatting
them all has little value unless their content is difficult to use.

### UML: behavior where structure is insufficient

UML is a modeling language with defined semantics; sequence diagrams describe
interactions, while state machines describe event-driven state and transition
behavior. UML also defines explicit time and duration constraints.
[OMG UML 2.5.1, chapters 8, 14 and 17](https://www.omg.org/spec/UML/2.5.1/PDF).

Sequence diagrams can expose calls, messages, responses and participating
responsibilities. Alternatives, loops and parallel fragments make important
branches visible. arc42 recommends a representative selection of scenarios,
including failures, and using participants from the building-block view.
[arc42 runtime view](https://docs.arc42.org/section-6/),
[Mapping behavior to blocks](https://docs.arc42.org/tips/6-1/),
[PlantUML sequence notation](https://plantuml.com/sequence-diagram).

**Interpretation and recommendation:** a drawn order does not establish a
measured latency or prove that the implementation follows it. Specify timing
constraints and obtain measurements separately. A successful scenario does not
cover omitted failures or alternate paths. Use state diagrams when valid states
and transitions are the real question; do not expand every function into a
sequence diagram.
[UML time constraints, section 8.5](https://www.omg.org/spec/UML/2.5.1/PDF),
[State diagram notation](https://plantuml.com/state-diagram).

## Combining them without repeating information

The following mapping is a recommendation, not a mandatory mapping from either
framework:

| Information | One maintained home |
| --- | --- |
| Goals, constraints and strategy | Short arc42 sections 1, 2 and 4; link to requirements |
| External context | C4 context view in section 3 |
| Applications and selected internal structure | C4 container/component views in section 5 |
| Significant interaction and lifecycle scenarios | UML sequence/state views in section 6 |
| Execution environment | Deployment view in section 7 |
| Shared rules, including ownership and failure handling | Concise contracts in section 8 |
| Decision rationale | Existing ADRs linked from section 9 |
| Quality criteria, risks and terminology | Sections 10–12 link to their authoritative sources |

**Recommendation:** retain concise text for invariants, units, ownership,
ordering rules and obligations that a diagram cannot express clearly. Give
diagrams consistent names, scope and status: implemented, accepted design or
proposed. A new format must not silently turn accepted design into an
implementation claim.

## Text-based diagram tools

These are options for a later decision; no tool installation or rendering trial
was performed.

| Option | Sourced capability | Assessment for this project |
| --- | --- | --- |
| C4-PlantUML with PlantUML | C4 macros are available through the standard library; PlantUML also renders sequence/state diagrams. [C4 library](https://plantuml.com/stdlib), [Sequences](https://plantuml.com/sequence-diagram), [States](https://plantuml.com/state-diagram) | Strong initial candidate for a small C4/UML set using one rendering family. Plan shared identifiers/includes to avoid inconsistent separate drawings. |
| Structurizr DSL | Defines a model and multiple views. Export supports PlantUML, Mermaid and static HTML, with feature differences between renderers. [DSL tutorial](https://docs.structurizr.com/dsl/tutorial), [Export](https://docs.structurizr.com/export) | Prefer if many views repeat the same elements and relationships. Adds a modeling workflow; detailed UML interactions may still need a separate notation. |
| Mermaid | Supports textual sequence diagrams; its C4 syntax is currently marked experimental and subject to change. [Sequences](https://mermaid.js.org/syntax/sequenceDiagram.html), [C4 status](https://mermaid.js.org/syntax/c4.html) | Convenient where the existing Markdown viewer supports it. Check actual viewer compatibility before selecting it as the maintained C4 format. |

**Recommendation:** choose after trying one representative structural diagram
and one sequence diagram. Keep their text sources in version control and produce
readable previews. Rendering success checks syntax, not architectural truth.

## Relationship to agile work and TDD

Kent Beck describes TDD as a programming workflow: list behavioral scenarios,
turn one into a runnable test, make it pass with existing tests, and optionally
refactor before repeating. It does not require specifying all tests or internals
in advance.
[Kent Beck, Canon TDD](https://newsletter.kentbeck.com/p/canon-tdd).

**Recommendation:** connect a short requirement/example to the relevant
architectural scenario and executable tests. Maintain only the views affected by
each increment. Tests can carry precise behavioral examples; diagrams explain
responsibility and interaction; ADRs retain rationale. Passing selected tests
does not establish that the chosen requirement meets the real training need.
Retain proportionate user feedback, acceptance exercises and performance
measurements where those questions remain open. This is consistent with agile
principles emphasizing working software, collaboration and adaptation.
[Agile principles](https://agilemanifesto.org/principles.html).

## Sacramento mapping

The pre-reform Software Architecture Description, `SAD-003` (now replaced by the
[arc42 overview](../architecture/software-architecture-description.md#1-goals-and-quality-priorities))
describes accepted Development Baseline decisions; it explicitly does not claim
implementation or verification. Its nine views already cover most of the
information needed by arc42. The proposed reform therefore changes organization
and presentation while preserving decision status and important contracts.
The [existing ADRs](../adr/0010-close-cross-cutting-architecture-and-verification.md)
already separate concise decisions from detailed specifications.

The following is a proposed destination map, not a change to canonical ownership:

| Existing SAD view | Proposed destination |
| --- | --- |
| `EDI-VIEW-001`, reading guide and drivers | One shared status block; arc42 1, 2 and 4 |
| `EDI-VIEW-002`, context and allocation | Separate C4 context/container views and arc42 7 deployment |
| `EDI-VIEW-003`, responsibilities | arc42 5: C4 containers, selective components and dependency rules |
| `EDI-VIEW-004`, lifecycle and sequences | arc42 6: selected UML sequences and lifecycle states |
| `EDI-VIEW-005`, concurrency and ownership | arc42 8 ownership/handoff rules, referenced by sequences |
| `EDI-VIEW-006`, content and retained evidence | Cooking sequence, structural relationships and linked data contracts |
| `EDI-VIEW-007`, cross-cutting policies | arc42 8, keeping only architecture-significant rules |
| `EDI-VIEW-008`, verification and traceability | arc42 10 quality scenarios and links to checks; governance reform handled separately |
| `EDI-VIEW-009`, risks and open work | arc42 11 with links to current issues |

For a first C4 model, use **Training Simulation** as the system boundary.
The **Trainee Client Runtime**, **Session Authority Runtime** and **Content Cooker
Tool** are candidate application-level containers. The cooker remains a finite
offline tool; a C4 container classification does not make it a product runtime.
Its target platform is still unselected. External provisioning and custody stay
outside the product boundary. Administrative Tools whose executable boundaries
are undecided should remain explicitly unresolved. The Simulation Engine and
responsibility modules are not invented services or extra deployables.
These are C4 interpretations of [SAD context/allocation](../architecture/software-architecture-description.md#3-context-and-scope),
[ARCHSPEC-0004 compositions](../architecture/0004-canonical-responsibility.md#runtime-compositions)
and [ADR-0013](../adr/0013-separate-offline-content-cooking-from-runtime-lifecycle.md).

Useful first sequences are startup and rejected startup; Canonical Tick commit
and publication; client loss versus authority loss; and finite cooking with
atomic release publication. Show messages at existing responsibility boundaries,
not imaginary methods. Retain the six existing architecture-dominating
success/failure scenarios as diagrams or linked acceptance examples, including
external-handoff failure and failure before/after commitment.
[Lifecycle and tick](../architecture/software-architecture-description.md#6-runtime-view),
[required representative scenarios](../architecture/0010-cross-cutting-architecture-and-verification.md#architecture-level-verification),
[offline cooking decision](../adr/0013-separate-offline-content-cooking-from-runtime-lifecycle.md).

**Replacement recommendation:** rewrite the SAD in place; migrate useful
`ARCHSPEC-*` prose into the relevant view or a concise linked contract; retain
ADRs as the decision history. Keep exact pack schemas, wire formats, finite
capacities, ordering, ownership and failure semantics wherever they remain
normative. C4 boxes and sequence arrows do not replace that information.
The [Runtime Resource specification](../architecture/0012-runtime-resource-and-role-pack-architecture.md)
and [candidate Software Design Baseline](../design/training-simulation-software-design-baseline.md)
are concrete examples requiring selective migration, not blanket deletion.

Before the reform, process requirements imposed per-view controls and the old
validator expected exactly nine `EDI-VIEW-*` sections with ten control rows each.
ADR-0014 changes those requirements together with the format; the
[replacement validator](../../scripts/documentation.py) checks canonical sources,
links, traces and diagram provenance without enforcing the old layout. This
administrative amendment to [ADR-0010](../adr/0010-close-cross-cutting-architecture-and-verification.md)
is an explicit policy decision, not an automatic consequence of adopting arc42.

The concrete phased reform plan is maintained in [issue #61](https://github.com/sergioffpc/sacramento/issues/61).
This note supplied its research basis. The owner authorized application on
2026-09-07; [ADR-0014](../adr/0014-use-lightweight-executable-documentation.md)
now records the replacement policy. The pre-reform observations above remain
historical research, not the current documentation contract.
