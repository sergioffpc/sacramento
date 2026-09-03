# Software Design Document Guidance

## Table of contents

- [Purpose](#purpose)
- [Document control](#document-control)
- [Normative language](#normative-language)
- [Recommended content](#recommended-content)
- [Traceability into requirements](#traceability-into-requirements)
- [Making design statements requirement-ready](#making-design-statements-requirement-ready)
- [Acceptance and testability criteria](#acceptance-and-testability-criteria)
- [Ambiguity review](#ambiguity-review)
- [What the document should not contain](#what-the-document-should-not-contain)
- [Common anti-patterns](#common-anti-patterns)
- [Practical template](#practical-template)
- [Design definition of done](#design-definition-of-done)

## Purpose

A software design document describes how an agreed set of needs will be satisfied by a coherent software solution. Its job is to remove design uncertainty before implementation planning begins.

The document should let a reader:

- understand the problem being solved and the boundaries of the solution;
- identify every significant design decision and the reason for it;
- see how responsibilities, data, control, and failure handling are divided;
- trace each design obligation back to an input requirement or constraint;
- derive concrete, independently verifiable requirements without inventing missing behavior; and
- determine which questions remain open and whether they block implementation.

A design document is not an implementation schedule. It defines the intended solution and its contracts; a separate implementation plan defines the ordered work needed to realize them.

## Document control

State:

- the design title and unique identifier;
- the system, subsystem, or capability covered;
- the version or baseline being designed;
- the document status: draft, under review, approved, superseded, or withdrawn;
- the owner and required reviewers;
- the date of the last meaningful change; and
- the requirements baseline and other internal artefacts on which the design depends.

Readers must be able to distinguish approved commitments from proposals and historical material.

## Normative language

Use a small, declared vocabulary consistently:

- **MUST** identifies a mandatory property or obligation.
- **MUST NOT** identifies a prohibited property or behavior.
- **SHOULD** identifies the preferred choice when an exception may be justified.
- **SHOULD NOT** identifies a normally prohibited choice for which a justified exception may exist.
- **MAY** identifies a permitted option, not a commitment.
- **WILL** records an expected fact or declared future event; it does not create a requirement.

Every **SHOULD** or **SHOULD NOT** statement should explain the permitted exception and who may approve it. Avoid using ordinary prose words such as “needs to,” “is expected to,” or “normally” to express hidden obligations.

A normative statement should:

- have a stable unique identifier;
- contain one principal obligation;
- name the responsible element;
- use active voice and an observable verb;
- state relevant conditions and boundaries;
- use defined terms and units;
- provide a rationale separately from the obligation; and
- identify how compliance can be verified.

Example structure:

> `DES-CACHE-004` — When a stored item fails integrity validation, the cache MUST reject the item, record the failure category, and request an authoritative replacement before returning data to a caller.

If the three observable outcomes require independent ownership or verification, split them into three linked statements.

## Recommended content

### 1. Problem, goals, and non-goals

Describe the problem in domain terms before describing the solution. Include:

- the intended outcome;
- the users or systems that receive value;
- success measures;
- explicit non-goals;
- assumptions that the design depends on; and
- known constraints on behavior, technology, compatibility, resources, or delivery.

Goals should state outcomes. Do not disguise a preferred mechanism as a goal.

### 2. Scope and system boundary

Define what is inside and outside the design. Identify:

- responsibilities owned by the designed system;
- responsibilities delegated elsewhere;
- external actors and neighboring systems;
- inputs, outputs, and trust boundaries;
- supported operating contexts; and
- excluded contexts.

Boundary statements should be testable. “Supports large workloads” is not a boundary; a defined workload range with units is.

### 3. Input requirements and constraints

List every authoritative internal input by stable identifier. For each input, record whether the design:

- satisfies it directly;
- allocates it to one or more elements;
- constrains it further;
- depends on another decision to satisfy it; or
- cannot yet satisfy it.

Do not silently modify an input requirement. Record conflicts, gaps, or infeasible constraints as issues to resolve at their source.

### 4. Design overview

Give a compact explanation of the solution strategy. It should identify:

- the major elements;
- their responsibilities;
- the allowed dependency directions;
- the primary data and control paths;
- the most important lifecycle stages; and
- the decisions that dominate cost, risk, or future change.

Use diagrams only when they clarify relationships or sequences. Every diagram should define its scope, notation, element types, relationship direction, and status. Supporting prose must state the obligations that the diagram alone cannot express precisely.

### 5. Element responsibilities and boundaries

For each significant element, specify:

- its purpose;
- responsibilities it owns;
- responsibilities it explicitly does not own;
- provided and required interfaces;
- data it owns or may mutate;
- lifecycle and resource ownership;
- permitted dependencies;
- concurrency assumptions; and
- failure containment boundary.

Responsibilities should not overlap accidentally. If two elements may perform the same action, define the selection, precedence, and coordination rules.

### 6. Interfaces and contracts

For every significant interface, describe:

- caller and provider;
- operation or message semantics;
- input and output shapes;
- valid ranges, units, encodings, and defaults;
- preconditions and postconditions;
- ordering and timing guarantees;
- idempotency or duplication behavior where relevant;
- ownership and lifetime of transferred data or resources;
- compatibility and versioning rules;
- authentication and authorization expectations where relevant; and
- errors, timeouts, cancellation, retries, and partial-success behavior.

Avoid contracts that say only “returns an error.” Enumerate meaningful failure categories and define the caller's allowed response.

### 7. Data design

Describe the information that crosses a boundary or must remain stable over time:

- canonical entities and value definitions;
- identity and uniqueness rules;
- invariants;
- ownership and source of truth;
- lifecycle and retention;
- relationships and cardinality;
- validation rules;
- serialization and compatibility expectations;
- concurrency and consistency rules; and
- migration or recovery behavior.

Use one term for one concept. Put aliases, abbreviations, units, sentinel values, and special states in the glossary.

### 8. Behavior and state

Document representative nominal, boundary, and failure scenarios. For each scenario, state:

- initial state;
- triggering event;
- relevant inputs;
- ordered interactions or state transitions;
- observable outputs and side effects;
- final state; and
- failure or interruption behavior.

If order does not matter, say so. If an action is atomic, resumable, repeatable, or compensating, define exactly what that means at the system boundary.

### 9. Quality and operational properties

Translate quality goals into measurable conditions. Cover only relevant properties, such as:

- latency, throughput, capacity, and resource budgets;
- availability and recovery objectives;
- security and privacy boundaries;
- correctness and consistency;
- portability and compatibility;
- maintainability and replaceability;
- diagnostics and observability; and
- accessibility or usability.

Each claim should name the workload or stimulus, operating conditions, expected response, measurement, and threshold. Replace “fast,” “robust,” “scalable,” “secure,” and similar adjectives with observable criteria.

### 10. Failure model

Identify credible failures, including invalid input, unavailable dependencies, resource exhaustion, concurrency conflicts, interrupted operations, corrupted state, and incompatible versions. For each relevant failure, define:

- detection;
- containment;
- externally observable behavior;
- retry or recovery policy;
- data integrity expectations;
- diagnostic evidence; and
- conditions requiring operator or user action.

Nominal flows alone are not a complete design.

### 11. Decisions and rationale

For each significant decision, record:

- decision identifier and status;
- context and forces;
- alternatives considered;
- chosen option;
- rationale;
- positive and negative consequences;
- assumptions and evidence; and
- conditions that would trigger reconsideration.

Keep rationale separate from normative statements so that explanation cannot be mistaken for an obligation.

### 12. Risks, unknowns, and deferred decisions

For each unresolved item, record:

- a stable identifier;
- the exact question or risk;
- impact if unresolved;
- owner;
- resolution criterion;
- due point; and
- whether it blocks requirements extraction or implementation planning.

Do not hide uncertainty behind placeholders. A placeholder without an owner and resolution condition is an omission.

## Traceability into requirements

Maintain bidirectional traceability at the level where change impact can be assessed without reconstructing intent.

Each design obligation should link to:

- one or more input requirements, constraints, or approved decisions;
- the design element or contract that realizes it;
- one or more derived requirements; and
- the planned verification evidence.

Each input requirement should map to at least one design obligation, or to an explicit explanation that it has no design impact. Each derived requirement should map back to the design fact that necessitates it.

A practical traceability table:

| Design ID | Input IDs | Design obligation | Derived requirement IDs | Verification approach | Status |
| --- | --- | --- | --- | --- | --- |
| `DES-...` | `REQ-...` | One concise obligation | `DREQ-...` | Test, analysis, inspection, or demonstration | Draft or approved |

Trace links should use identifiers, not only section numbers or prose descriptions, because headings and document layout change.

## Making design statements requirement-ready

Before extracting a requirement, check that the design statement answers:

1. **Who or what is responsible?**
2. **What observable behavior or property is required?**
3. **Under which conditions does it apply?**
4. **What inputs, boundaries, units, or tolerances apply?**
5. **What outcome is observable at the chosen verification boundary?**
6. **How can compliance be checked?**
7. **Which source need or decision justifies it?**

The derived requirement should describe the necessary observable outcome. Include an implementation mechanism only when the mechanism is itself an approved constraint or an essential interoperability contract.

## Acceptance and testability criteria

For each behavior or quality property, define acceptance in terms of evidence. A criterion should specify:

- preconditions and test data;
- initiating action or stimulus;
- expected observable result;
- prohibited result where relevant;
- measurement point and method;
- numerical threshold and tolerance where relevant;
- time window or ordering constraint;
- applicable environments or configurations; and
- required evidence to retain.

Cover at least:

- nominal behavior;
- lower and upper boundaries;
- invalid or missing input;
- dependency failure;
- interruption and recovery;
- concurrent or repeated operation where relevant; and
- compatibility with supported prior states or versions where required.

Do not use internal implementation details as the only acceptance evidence unless the requirement is explicitly about that internal structure.

## Ambiguity review

Review every normative statement and contract for the following defects:

- pronouns with uncertain referents;
- undefined actors, data, states, units, or acronyms;
- subjective adjectives or adverbs;
- open-ended lists such as “and so on”;
- undefined phrases such as “as needed,” “where possible,” or “appropriate”;
- “and/or” constructions;
- multiple obligations hidden in one sentence;
- passive voice that hides responsibility;
- missing boundary values or tolerances;
- unclear precedence between rules;
- unspecified behavior for empty, invalid, duplicate, late, or partial input;
- inconsistent terminology between sections;
- diagrams that conflict with prose;
- current and proposed behavior mixed without status labels; and
- requirements that can only be verified by personal judgment.

An effective review asks two independent readers to restate each important obligation and propose a verification. Different interpretations reveal ambiguity.

## What the document should not contain

Do not include:

- a task list, staffing plan, schedule, or work estimate;
- exhaustive source-level detail that is easier to obtain from the code;
- a single diagram attempting to express every concern;
- solution choices without drivers, trade-offs, or consequences;
- requirements copied without showing how the design satisfies them;
- speculative features outside the declared scope;
- vague quality claims without measurement conditions;
- happy-path behavior without boundaries and failures;
- examples that silently override normative rules;
- unresolved placeholders presented as approved design;
- duplicated facts with no declared source of truth;
- personal preferences stated as mandatory constraints; or
- implementation steps masquerading as design decisions.

## Common anti-patterns

### The component catalogue

A list of modules and classes does not explain responsibilities, contracts, behavior, or trade-offs. Readers still have to invent the design between the boxes.

### The code forecast

Predicting filenames, functions, and line-level changes too early makes the document brittle and obscures stable behavioral obligations.

### The perfect-path narrative

Describing only successful execution leaves failure handling, recovery, and partial state undefined.

### The adjective specification

Terms such as “simple,” “efficient,” and “flexible” create agreement in conversation but cannot be verified consistently.

### The decision graveyard

Recording outcomes without context or consequences prevents later readers from knowing whether the decisions still apply.

### The hidden fork

Leaving two incompatible alternatives in approved prose transfers a design decision to the implementer and produces inconsistent requirements.

### The false precision trap

Inventing unsupported thresholds or detailed mechanisms merely to remove a placeholder produces a precise but unjustified design. Track the unknown and resolve it deliberately.

### The mixed-baseline document

Combining current behavior, approved target behavior, and optional future ideas without labels makes traceability unreliable.

## Practical template

```markdown
# <Design title>

Status: <draft | under review | approved | superseded>
Owner: <role or person>
Scope: <system or capability>
Target baseline: <identifier>
Input baseline: <requirement and decision identifiers>

## 1. Purpose
## 2. Goals and non-goals
## 3. Scope and boundaries
## 4. Inputs, constraints, and assumptions
## 5. Design overview
## 6. Elements and responsibilities
## 7. Interfaces and contracts
## 8. Data model and invariants
## 9. Runtime behavior and state
## 10. Quality and operational properties
## 11. Failure model and recovery
## 12. Significant decisions and trade-offs
## 13. Risks, unknowns, and deferred decisions
## 14. Requirement traceability
## 15. Verification and acceptance criteria
## 16. Glossary
## 17. Design definition of done
```

## Design definition of done

The design document is ready for requirements extraction and implementation planning when:

- scope, goals, non-goals, assumptions, and constraints are explicit;
- every mandatory input is addressed or has a tracked blocking issue;
- element responsibilities and boundaries are non-overlapping or have explicit coordination rules;
- significant interfaces define semantics, data, errors, timing, ownership, and compatibility;
- representative nominal, boundary, and failure scenarios are specified;
- important quality claims have measurable conditions and thresholds;
- significant decisions include rationale, consequences, and status;
- all open items have owners, resolution criteria, and blocking status;
- normative statements are atomic, identified, consistent, and verifiable;
- every design obligation traces backward to an input and forward to a derived requirement or verification;
- two independent readers interpret critical statements consistently;
- every derived requirement has a feasible verification approach;
- current, target, and speculative states are clearly separated; and
- the document has an owner and a defined trigger for updates.
