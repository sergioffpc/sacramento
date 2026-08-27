# Initial Goals, Requirements, and Constraints Document Guidance

Status: Research guidance

Purpose: Explain how to write an initial goals, requirements, and constraints document that can guide architecture.

Scope: Statement types, structure, requirement quality, game-engine considerations, ambiguity review, anti-patterns, and completion criteria.

Intended readers: Project owner, requirements authors, architects, reviewers, and verification authors.

Prerequisites: None.

Canonical information owner: Project owner.

## Table of contents

- [Purpose](#purpose)
- [The boundary of the document](#the-boundary-of-the-document)
- [Five distinct statement types](#five-distinct-statement-types)
- [Recommended document structure](#recommended-document-structure)
- [How to write a strong requirement](#how-to-write-a-strong-requirement)
- [Game-engine-specific considerations](#game-engine-specific-considerations)
- [Anti-patterns](#anti-patterns)
- [Ambiguity review checklist](#ambiguity-review-checklist)
- [Definition of done](#definition-of-done)

## Purpose

An initial goals, requirements, and constraints document defines the problem that an architecture must solve. It establishes desired outcomes, observable system obligations, operating conditions, and limits on the solution before major structural decisions are made.

The document should enable architects and reviewers to:

- understand why the system should exist and whose needs it serves;
- identify the capabilities and quality levels that will drive architecture;
- distinguish mandatory limits from preferences and unverified beliefs;
- compare architectural options against the same agreed criteria;
- detect conflicts, missing information, and infeasible expectations early;
- derive more detailed requirements without losing the original intent; and
- verify later that the selected architecture addresses every significant driver.

This is an input to architecture, not an architecture description, software design, implementation plan, feature backlog, or test plan. Later work may derive new requirements from architectural decisions, but those derived requirements must remain distinguishable from the initial baseline.

## The boundary of the document

The document owns the **problem boundary**:

- intended outcomes;
- stakeholders and affected users;
- system scope and operating context;
- required externally observable behavior;
- measurable quality expectations;
- externally imposed constraints;
- priorities and acceptable trade-offs;
- assumptions, risks, and unresolved questions; and
- the evidence that will show whether each requirement has been satisfied.

It should not own the **solution structure** unless an external obligation truly removes the choice. In particular, it should normally avoid selecting:

- module or subsystem decomposition;
- internal data models;
- inheritance, composition, or entity models;
- algorithms and data structures;
- process, thread, job, or synchronization models;
- internal messaging mechanisms;
- rendering, physics, audio, or scripting implementations;
- source-code layout;
- third-party components;
- implementation phases and work-item sequencing; or
- detailed interface shapes between components that do not yet exist.

Such decisions belong to architecture or design. If one is unavoidable at this stage, classify it explicitly as a constraint, record its source and rationale, and state what freedom remains.

## Five distinct statement types

Keeping these categories separate prevents aspirations, obligations, guesses, and solutions from being mistaken for one another.

### Goal

A goal states a valuable outcome and explains why the work matters. It guides prioritization but is not necessarily directly verifiable as written.

> Enable a small team to create and ship visually consistent two-dimensional games on the selected desktop targets.

A goal should identify the beneficiary, desired outcome, and success signal. It should not disguise a proposed solution as an outcome.

### Requirement

A requirement states a mandatory, observable property or behavior of the system under defined conditions. It must be possible to determine whether the completed system satisfies it.

> When a packaged game loads the reference scene from local storage on the baseline device, the runtime MUST make the scene interactive within 2 seconds in at least 95 of 100 cold-start trials.

A requirement should describe what must be true at the system boundary, not how internal components must achieve it.

### Constraint

A constraint is a mandatory limit on the solution space. It usually originates outside the design activity and cannot be traded away by selecting a different architecture.

> The editor and packaged runtime MUST execute on the two approved operating-system versions listed in the target-platform profile.

Cost ceilings, delivery dates, target devices, required compatibility, legal obligations, fixed file formats, and unavailable capabilities may all be constraints. A team preference is not a constraint merely because it is strongly held.

### Assumption

An assumption is a proposition treated as true for planning purposes but not yet guaranteed. It is a source of risk, not an obligation imposed on the system.

> The baseline device is assumed to provide at least 4 processor cores to the packaged game.

Every material assumption needs an owner, a validation action, a due point, and the consequence of being false. Once confirmed, it becomes a fact or constraint; once disproved, affected goals and requirements must be revisited.

### Architectural decision

An architectural decision selects a structural approach intended to satisfy goals, requirements, and constraints.

> Simulation and presentation use separate update schedules.

This statement does not belong in the initial requirements baseline unless an external obligation forces it. Architecture should be free to consider alternatives and explain the selected trade-off.

## Recommended document structure

### 1. Document identity and status

Record:

- title and stable document identifier;
- system or product covered;
- owner and required reviewers;
- status: draft, under review, approved, superseded, or withdrawn;
- version or baseline identifier;
- last meaningful update; and
- change-approval rule.

Readers must be able to distinguish agreed obligations from proposals and superseded statements.

### 2. Executive intent

Summarize in a few paragraphs:

- the problem or opportunity;
- who experiences it;
- why a new system or major change is justified;
- the outcome expected from the system; and
- the few requirements or constraints most likely to shape architecture.

Do not summarize a preferred architecture here.

### 3. Stakeholders and needs

Identify each stakeholder group, its relationship to the system, and the needs that matter to this scope. For a game engine, possible stakeholder roles include game players, game creators, content creators, engine maintainers, build and release operators, platform maintainers, and test engineers.

For each relevant role, record:

- desired outcome;
- activities performed with or around the system;
- harms or costs to avoid;
- authority to approve or reject requirements; and
- conflicts with other stakeholder needs.

Avoid a bare list of job titles. A stakeholder is useful here only when its concerns influence goals, requirements, constraints, or acceptance.

### 4. Goals, success measures, and non-goals

Give every goal a stable identifier. For each goal, state:

- beneficiary;
- desired outcome;
- reason it matters;
- success indicators;
- relative priority; and
- related non-goals.

Non-goals define deliberate exclusions. They prevent readers from interpreting silence as future commitment and protect the architecture from speculative generality.

Example:

> `GOAL-AUTHORING-01` — Enable a developer familiar with the project language to create, run, and debug a small playable scene without modifying engine source.

> `NON-GOAL-AUTHORING-01` — The first release will not provide collaborative real-time scene editing.

### 5. Scope and system boundary

Define what is inside and outside the system. For a game engine, state explicitly whether the scope includes:

- packaged runtime;
- editor and content-authoring tools;
- asset import, processing, and packaging;
- scripting or gameplay extension facilities;
- build and deployment tooling;
- diagnostic and profiling tools;
- platform adaptation;
- online or remote services; and
- example games, templates, or development kits.

Identify external actors, neighboring systems, inputs, outputs, and relevant trust boundaries. State supported and excluded operating contexts. Do not use an architecture diagram to settle this boundary implicitly.

### 6. Operational scenarios

Describe a small set of representative situations that give requirements concrete context. Include nominal use, boundary conditions, failures, recovery, and maintenance where they materially affect architecture.

Each scenario should identify:

- actor or source of the event;
- initial conditions;
- trigger;
- system boundary involved;
- expected externally visible response;
- relevant workload or content profile; and
- completion or failure outcome.

For a game engine, useful candidates may include launching a packaged game, loading a world, running a representative frame, importing changed content, saving and reopening a project, packaging a build, recovering from invalid content, and handling a lost device or unavailable service. Scenarios provide context; mandatory obligations extracted from them still require stable requirement identifiers.

### 7. Functional requirements

Functional requirements define capabilities and externally observable behavior. Organize them by stakeholder outcome or system capability rather than by imagined internal subsystem.

Each requirement should specify:

- responsible system boundary;
- triggering condition;
- required response;
- input and output limits;
- exceptional and boundary behavior;
- applicable operating modes; and
- verification approach.

Cover behavior that materially affects architecture, including lifecycle, compatibility, extension, content processing, and failure recovery. Defer minor interaction detail that does not influence the architectural choice.

### 8. Quality requirements and budgets

Quality requirements often shape architecture more strongly than feature lists. Express each important quality as a scenario with measurable acceptance boundaries.

Record:

- stimulus or change;
- workload, content, or scale profile;
- operating environment and system state;
- required response;
- threshold or allowed distribution;
- measurement window and warm-up conditions;
- baseline hardware and software configuration;
- measurement procedure or evidence type; and
- priority relative to competing qualities.

For a game engine, consider only qualities relevant to its goals, such as:

- frame-time consistency and simulation-tick deadlines;
- input-to-visible-response latency;
- startup, world-load, and asset-import time;
- memory, graphics-memory, storage, and network budgets;
- supported content scale;
- stability during long sessions;
- recovery from invalid assets or unavailable devices;
- reproducibility or determinism where required;
- portability across target platforms;
- compatibility of projects, saved data, and packaged content;
- time and effort required to add or replace capabilities;
- iteration time for creators;
- diagnostic evidence available after faults; and
- accessibility or usability of authoring workflows.

Do not write “high performance,” “low latency,” “scalable,” “portable,” “robust,” “modular,” or “easy to use” without a defined context and observable threshold.

### 9. Constraints

Group mandatory constraints by origin rather than mixing them with solution preferences. Relevant groups may include:

- target platforms and baseline devices;
- required execution environments;
- delivery, staffing, cost, or licensing limits;
- compatibility with existing projects, assets, save data, protocols, or tools;
- privacy, security, safety, or distribution obligations;
- fixed external interfaces and data formats;
- power, thermal, storage, memory, or installation limits; and
- mandated dependencies or prohibited technologies.

For each constraint, record:

- stable identifier;
- exact limit;
- source or authority within the project;
- rationale;
- effective period;
- affected scope;
- whether an exception is possible and who approves it; and
- verification approach.

If the origin cannot be identified and the limit could be changed through a design trade-off, reclassify it as a preference or candidate decision.

### 10. Assumptions and dependencies

Maintain an explicit register containing:

- assumption or dependency identifier;
- proposition being relied upon;
- affected goals and requirements;
- confidence or evidence currently available;
- owner;
- validation action and due point;
- consequence if false or unavailable; and
- fallback or decision that would need reconsideration.

Do not hide assumptions inside requirement rationale or examples. Architecture based on an invisible assumption cannot be evaluated honestly.

### 11. Priorities, conflicts, and trade-off policy

Assign priority only after defining what the priority means. A useful scheme distinguishes:

- mandatory for the initial accepted baseline;
- important but negotiable when a higher driver would otherwise fail;
- optional if time and resources permit; and
- explicitly deferred or excluded.

For every item, record the owner of the priority and the consequence of omission. Avoid marking nearly everything mandatory.

Record known conflicts explicitly. A conflict entry should include:

- competing requirement identifiers;
- scenario or operating range where they conflict;
- affected stakeholders;
- decision owner;
- evaluation criteria;
- resolution status; and
- approved precedence or remaining question.

Do not resolve a genuine conflict by weakening one requirement with words such as “where practical.” If both cannot be mandatory, change their thresholds, scope, priority, or operating conditions through an explicit decision.

### 12. Requirement catalogue

Give every normative requirement a stable unique identifier and record at least:

- statement;
- type: functional, quality, interface, compatibility, or constraint;
- status;
- priority;
- parent goal or stakeholder need;
- rationale;
- assumptions;
- applicable scenarios and operating modes;
- verification method and acceptance evidence;
- owner and approver; and
- dependencies or conflicts.

Keep rationale, examples, and notes outside the normative sentence so that they cannot change its meaning accidentally.

### 13. Risks, unknowns, and open questions

Record uncertainty instead of filling gaps with guessed design. Each open item should state:

- exact question or risk;
- why it matters to architecture;
- affected requirement identifiers;
- owner;
- evidence or decision needed;
- due point;
- consequence of delay; and
- whether architecture work may proceed safely before resolution.

An unlabeled placeholder is not an acceptable open item.

### 14. Traceability and change control

Maintain bidirectional links through the lifecycle:

```text
stakeholder need -> goal -> initial requirement or constraint
                   -> architectural decision -> derived requirement
                   -> design obligation -> acceptance evidence
```

The initial document need not contain every later artefact, but its identifiers must remain stable enough to support these links. When architecture creates a new obligation, label it as derived and trace it to the decision and parent driver that justify it.

Traceability should answer:

- Why does this requirement exist?
- Which architectural decision addresses it?
- What other obligations depend on it?
- How will satisfaction be demonstrated?
- What must be reconsidered if it changes?
- Is any goal uncovered by requirements?
- Is any requirement unjustified by a need, goal, constraint, or approved derived decision?

Changes to an approved baseline should record proposer, rationale, affected identifiers, impact on architecture and evidence, approval, and effective baseline. Do not edit approved obligations silently.

### 15. Glossary and internal references

Define domain terms, units, ranges, modes, actor names, workload names, and the exact meaning of repeated qualifiers. Use one term for one concept and one concept for one term.

Link to internal sources of truth for target-device profiles, reference workloads, representative content, approval records, and acceptance evidence. Avoid copying volatile details into several documents.

## How to write a strong requirement

A strong requirement is:

- **necessary** — it supports an approved goal, need, constraint, or derived decision;
- **atomic** — it expresses one principal obligation;
- **clear** — its actor, action, object, and conditions have one intended interpretation;
- **bounded** — applicable modes, inputs, limits, and exceptions are stated;
- **feasible** — it can be achieved within known constraints;
- **solution-neutral** — it preserves design freedom unless restriction is justified;
- **measurable** — quantities have units, thresholds, and aggregation rules;
- **verifiable** — a finite inspection, analysis, demonstration, or test can show compliance;
- **consistent** — it does not conflict with another approved obligation;
- **traceable** — its origin and downstream evidence are identifiable;
- **prioritized** — its precedence and consequence of omission are known; and
- **maintainable** — it has stable identity, ownership, status, and controlled change.

### Normative language

Declare and use a small vocabulary consistently:

- **MUST**: mandatory obligation.
- **MUST NOT**: prohibited behavior or property.
- **SHOULD**: preferred outcome with a documented exception path.
- **SHOULD NOT**: normally prohibited outcome with a documented exception path.
- **MAY**: permitted option, not a commitment.

Use one normative keyword and one principal obligation per requirement where practical. Descriptive prose, goals, assumptions, forecasts, and examples should not use normative keywords.

### General requirement template

> `[ID]` — When `<trigger or condition>`, the `<system boundary>` MUST `<observable response>` for `<defined input or scope>` within `<threshold or limit>` under `<operating conditions>`.

Supporting fields:

```text
Type:
Status:
Priority:
Parent goal or need:
Rationale:
Assumptions:
Verification:
Acceptance evidence:
Owner:
Conflicts and dependencies:
```

### Functional requirement template

> When `<actor or event>` provides `<valid input>` while the system is in `<state or mode>`, the system MUST `<observable behavior and output>`; if `<defined failure or boundary condition>` occurs, it MUST `<observable failure behavior>`.

### Quality requirement template

> Given `<baseline environment>`, `<system state>`, and `<reference workload or content profile>`, when `<stimulus>` occurs, the system MUST `<response>` with `<metric>` `<comparison>` `<threshold>` over `<measurement window or sample distribution>`.

### Changeability requirement template

> Given `<baseline skills, environment, and starting system>`, an authorized maintainer MUST be able to complete `<defined change>`, including `<required validation and integration>`, within `<effort or elapsed-time limit>` without modifying `<protected boundary>`.

### Compatibility requirement template

> The system MUST `<read, write, execute, or interoperate with>` artefacts conforming to `<internally defined version range or profile>` and MUST `<reject, migrate, or degrade>` incompatible artefacts with `<observable result>`.

### Constraint template

> `[ID]` — The solution MUST `<respect exact imposed limit>` for `<scope and effective period>` because `<internal authority or fixed dependency>` requires it. Exceptions require `<approval authority and evidence>`.

### Assumption template

> `[ID]` — Planning currently assumes `<proposition>`. `<owner>` will validate it by `<action and due point>`. If false, `<requirements or decisions>` must be reconsidered and `<fallback or consequence>` applies.

## Game-engine-specific considerations

Game engines combine real-time runtime behavior, content-heavy workflows, development tools, and platform variation. Their initial requirements need to describe representative games and workflows precisely enough to prevent the architecture from optimizing for an imaginary universal engine.

### Product identity

State what kind of engine is intended:

- internal engine for one game, a family of games, or a reusable product;
- two-dimensional, three-dimensional, or mixed content;
- relevant game genres and camera or world models;
- single-player, local multiplayer, networked, or server-authoritative operation;
- runtime-only library or runtime plus authoring environment;
- intended users and their programming or content-creation skills; and
- expected project lifetime and compatibility horizon.

These are scope inputs, not invitations to promise every genre and platform.

### Reference content and workloads

Quantitative engine requirements are meaningless without representative content. Define versioned internal profiles for:

- scene or world size;
- active and visible object counts;
- geometry, texture, animation, audio, and script load;
- light, particle, physics-body, and navigation complexity;
- number and behavior of connected players where relevant;
- streaming rate and working-set transitions; and
- worst credible creator project within the supported scope.

Separate typical, stress, and rejection-boundary profiles. Do not embed changing content statistics in every requirement; reference a controlled profile identifier.

### Target-platform profiles

For every supported target class, define a controlled baseline including processor, graphics capability, memory, graphics memory, storage, display conditions, input devices, operating environment, and relevant power or thermal limits.

Separate:

- minimum device that must satisfy correctness and reduced-quality operation;
- baseline device used for acceptance thresholds; and
- higher-tier device used for optional fidelity targets.

“Runs on desktop” or “supports mobile” is not sufficiently bounded.

### Runtime budgets

Where relevant, allocate observable budgets for:

- total frame time and allowed frame-time outliers;
- fixed simulation step and deadline misses;
- input-to-visible-response latency;
- CPU and graphics processing under the reference workload;
- main memory and graphics memory;
- transient allocation and pause behavior;
- storage and packaged size;
- content streaming bandwidth and stalls;
- network bandwidth and tolerance of latency or loss;
- startup, world transition, and save or restore time; and
- sustained power or thermal behavior.

Specify whether each threshold applies to average, percentile, maximum, or consecutive samples. A frame-rate average alone can hide unacceptable hitches.

### Creator workflows

If authoring tools are in scope, specify complete workflows rather than only runtime features. Examples include creating a project, importing or reimporting an asset, editing a scene, running a change, diagnosing an error, packaging a target build, and upgrading a project.

Measure outcomes that affect iteration, such as import latency, incremental build time, reload time, diagnostic clarity, recovery after invalid content, and steps required for common changes. Avoid choosing the editor layout or internal tool architecture prematurely.

### Content and project compatibility

State whether engine updates must preserve:

- project files;
- source assets and import settings;
- processed runtime assets;
- saved games;
- scripting interfaces;
- extension interfaces; and
- packaged-game network compatibility.

Define version ranges, migration responsibilities, failure behavior, and whether backward reading, forward reading, or round-trip preservation is required. “Backward compatible” by itself is ambiguous.

### Determinism, networking, and replay

Do not demand determinism merely because the system is a game engine. If gameplay, networking, replay, testing, or tooling requires it, define:

- observable state included;
- identical inputs and initial conditions;
- platform and build boundaries;
- time horizon;
- permitted numeric divergence;
- ordering guarantees; and
- evidence required.

Similarly, networking requirements should state authority, player count, message conditions, latency and loss profiles, correction behavior, security boundary, and acceptable user-visible degradation without prescribing an internal networking architecture.

### Extensibility and modifiability

Replace “extensible engine” with representative change scenarios. State who makes the change, what capability is added or replaced, what knowledge and tools are available, which boundaries must remain stable, and how much effort or disruption is acceptable.

Useful change scenarios may cover adding a target platform, renderer capability, asset importer, gameplay component, scripting binding, editor tool, or diagnostic provider. These scenarios should constrain outcomes while leaving architecture free to define the extension seams.

### Failure and recovery

Identify failures whose handling can affect architecture:

- missing, invalid, cyclic, or incompatible content;
- exhausted CPU, memory, graphics memory, storage, or network budgets;
- device loss or unavailable platform service;
- script failure;
- interrupted import, build, save, or packaging;
- disconnected or malicious network participant; and
- project corruption or incomplete migration.

Specify required containment, observable diagnostics, recoverable state, user impact, and whether continued degraded operation is acceptable.

## Anti-patterns

### Starting with a feature catalogue

A long list of rendering, physics, animation, audio, and editor features does not explain which games or workflows matter, which qualities dominate, or what must be sacrificed when drivers conflict. Begin with outcomes and representative scenarios.

### Designing through requirements

Statements that mandate an internal component model, task scheduler, memory layout, rendering path, or algorithm prematurely remove architectural choices. Rewrite them as observable needs unless an external constraint genuinely mandates the mechanism.

### Treating preferences as constraints

“The team likes this language” or “this pattern is familiar” is not automatically a constraint. Record the underlying skill, schedule, compatibility, or maintenance need; let architecture assess the response.

### Vague quality adjectives

Words such as fast, efficient, robust, scalable, portable, flexible, seamless, intuitive, and future-proof do not define acceptance. Replace them with scenarios, environments, measures, and thresholds.

### Missing reference conditions

A latency, memory, frame-rate, or load-time target without hardware, content, build configuration, system state, and measurement rules cannot guide design or verification.

### Combining several obligations

A compound sentence containing several actors, conditions, behaviors, and exceptions becomes hard to trace and verify. Split independent obligations and link them to the same parent goal.

### Escaping conflict with qualifiers

Phrases such as “where possible,” “as needed,” “if appropriate,” “reasonable,” and “with minimal impact” hide unresolved trade-offs. Define the decision boundary or record an open conflict.

### Making everything mandatory

If all requirements have the same highest priority, the architecture receives no guidance when qualities compete. Prioritize through explicit consequences and decision authority.

### Using examples as obligations

“Such as,” “for example,” and incomplete lists do not define the required set. Keep examples non-normative and define whether enumerations are exhaustive.

### Confusing assumptions with facts

An unverified hardware capability, team size, content profile, or external dependency can invalidate the architecture later. Track it explicitly and force validation before the affected decision becomes expensive.

### Requirements with no origin

An obligation that traces to no stakeholder need, goal, fixed constraint, or approved derived decision may be unnecessary overdesign. Give it a rationale and owner or remove it.

### Requirements with no verification path

If no finite evidence can demonstrate compliance, the statement is a goal, aspiration, or unresolved research question rather than an accepted requirement.

### Over-specifying unlikely futures

Universal portability, unlimited scale, arbitrary extension, or indefinite compatibility imposes real complexity. Specify known horizons and representative changes; revisit them under controlled change when evidence changes.

### Ignoring failure and maintenance

Nominal runtime behavior alone leaves architecture blind to recovery, diagnostics, upgrades, content migration, and creator iteration. Include the non-nominal scenarios that materially shape structure.

### Freezing derived requirements into the initial baseline

Architecture may legitimately create interface, ownership, concurrency, or allocation obligations. Label these as derived and trace them to the architectural decision; do not rewrite history by presenting them as original needs.

## Ambiguity review checklist

Review every normative statement with the following questions.

### Identity and necessity

- Does it have one stable identifier?
- Does it trace to an approved need, goal, constraint, or derived decision?
- Is the rationale recorded separately?
- Would removing it leave a real stakeholder need or parent obligation uncovered?

### Subject and obligation

- Is the responsible system boundary named?
- Is there exactly one principal obligation?
- Is the verb observable rather than subjective?
- Is mandatory, preferred, optional, or descriptive intent unmistakable?
- Could two readers identify the same compliant and non-compliant outcomes?

### Conditions and scope

- Are trigger, initial state, operating mode, and applicable lifecycle phase clear?
- Are included and excluded actors, inputs, targets, and contexts clear?
- Are boundary values and invalid inputs covered?
- Is failure, timeout, cancellation, or unavailable-dependency behavior defined where relevant?
- Is every pronoun or cross-reference unambiguous?

### Quantities and sets

- Does every quantity have a unit?
- Are threshold direction, tolerance, precision, and rounding rules clear?
- Is the measurement window and aggregation rule stated?
- Are averages distinguished from percentiles, maxima, and consecutive samples?
- Are enumerations explicitly exhaustive or illustrative?
- Are ranges and version boundaries inclusive or exclusive as intended?

### Environment and workload

- Is the target-platform profile identified?
- Is the reference workload or content profile identified?
- Are build mode, configuration, warm-up, cache state, and relevant background activity defined?
- Can the environment and inputs be reproduced for verification?

### Solution freedom

- Does the statement describe an externally visible outcome?
- Does it prescribe a mechanism, component, technology, or decomposition?
- If so, is it a real constraint with recorded authority and rationale?
- Could a different valid architecture still satisfy the requirement?

### Verification

- Is there a finite verification method?
- Are the required evidence and pass/fail rule defined?
- Can verification occur at the stated system boundary?
- Are needed instrumentation, fixtures, target devices, and datasets obtainable?
- Is the requirement feasible within current constraints?

### Consistency and priority

- Does it conflict with another requirement or constraint?
- Is precedence defined for known conflicts?
- Is priority meaningful and approved by the right owner?
- Is the consequence of omission understood?
- Are assumptions and dependencies visible?

### Language traps

Search for and resolve:

- vague adjectives and adverbs;
- “and/or”;
- “etc.” and open-ended lists;
- “where possible,” “as appropriate,” and “if necessary”;
- undefined “support,” “handle,” “optimize,” or “manage”;
- passive voice that hides responsibility;
- negative requirements whose allowed behavior is unclear;
- embedded rationale beginning with “because” or “in order to”;
- examples that could be mistaken for the full obligation; and
- future-tense promises that do not create an acceptance condition.

## Definition of done

The initial goals, requirements, and constraints document is ready to guide architecture when:

- its purpose, scope, system boundary, intended readers, owner, status, and baseline are explicit;
- relevant stakeholder needs are recorded and each goal names a beneficiary and desired outcome;
- goals and non-goals bound the intended product without prescribing its internal structure;
- representative operational, failure, maintenance, and creator workflows cover the architectural drivers;
- every normative statement has a stable identifier, type, status, priority, owner, rationale, and parent trace;
- functional requirements state observable behavior, conditions, boundaries, and exceptional outcomes;
- important quality requirements identify workload, environment, response, measure, threshold, and evidence;
- game-engine performance targets reference controlled content, platform, and measurement profiles;
- constraints are distinguished from preferences and identify their authority and exception policy;
- every material assumption has an owner, validation action, due point, and consequence if false;
- known conflicts have owners, evaluation criteria, precedence or a tracked resolution action;
- each requirement has a feasible verification path and objective pass/fail rule;
- bidirectional traceability can expose uncovered goals, unjustified requirements, and downstream change impact;
- unresolved questions identify their architectural impact and whether they block progress;
- terminology, units, modes, ranges, and priority meanings are defined consistently;
- the ambiguity checklist has been completed and findings resolved or explicitly accepted; and
- reviewers can compare architectural alternatives against the document without inventing missing requirements or mistaking a preferred solution for a need.

Being ready does not mean that every detail is known. It means that remaining uncertainty is visible, owned, bounded, and handled deliberately enough for architectural decisions to proceed.
