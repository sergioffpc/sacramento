# Software Implementation Planning Document Guidance

## Table of contents

- [Purpose](#purpose)
- [Document control](#document-control)
- [Normative language](#normative-language)
- [Entry conditions](#entry-conditions)
- [Recommended content](#recommended-content)
- [Traceability model](#traceability-model)
- [Work-item readiness criteria](#work-item-readiness-criteria)
- [Acceptance and testability criteria](#acceptance-and-testability-criteria)
- [Ambiguity review](#ambiguity-review)
- [What the document should not contain](#what-the-document-should-not-contain)
- [Common anti-patterns](#common-anti-patterns)
- [Practical plan template](#practical-plan-template)
- [Work-item definition of done](#work-item-definition-of-done)
- [Plan definition of done](#plan-definition-of-done)

## Purpose

A software implementation planning document converts an approved design and its derived requirements into an ordered, reviewable, and executable body of work. It explains how the team will move from the current baseline to the target baseline while preserving correctness and producing evidence of completion.

The document should let a reader:

- identify exactly what will change and what will remain unchanged;
- trace every work item to approved design obligations and requirements;
- understand dependencies, sequencing, integration points, and safe stopping points;
- execute each work item without making unresolved product or design decisions;
- verify each increment independently where practical;
- assess risks, resources, and operational impact; and
- determine objectively whether the implementation is complete.

An implementation plan does not replace the design document. It may choose implementation tactics within the freedom allowed by the design, but it must not silently redefine behavior, interfaces, constraints, or acceptance criteria.

## Document control

State:

- the plan title and unique identifier;
- the current and target baselines;
- the approved design and requirement baselines;
- the plan status: draft, ready, active, paused, completed, superseded, or withdrawn;
- the plan owner and work-item owners;
- required reviewers and approvers;
- the last meaningful update; and
- the change-control rule for revising the plan.

Status must distinguish planned work from completed work. Completion claims should point to retained evidence.

## Normative language

Use a declared vocabulary consistently:

- **MUST** identifies a mandatory plan condition or implementation obligation.
- **MUST NOT** identifies a prohibited action or outcome.
- **SHOULD** identifies a preferred tactic for which a justified exception is allowed.
- **SHOULD NOT** identifies a normally prohibited tactic for which a justified exception is allowed.
- **MAY** identifies an allowed option.
- **WILL** records a forecast, assignment, or scheduled event; it does not define product behavior.

Keep three statement types distinct:

1. **Product requirement:** the observable behavior or property the implementation must satisfy.
2. **Design constraint:** a mandatory structural or technical decision that shapes the solution.
3. **Plan instruction:** an activity, ordering rule, checkpoint, or evidence obligation for delivering the change.

Tag or place each type separately. Do not use scheduling language to weaken a product requirement, and do not present an estimate as a commitment.

Every mandatory plan instruction should:

- have a stable identifier;
- name an owner or responsible role;
- state one action or exit condition;
- identify prerequisites;
- identify expected outputs or evidence;
- state failure or escalation behavior; and
- be traceable to the work item it supports.

## Entry conditions

Before detailed planning begins, confirm that:

- the target design is approved or its provisional status is explicit;
- requirements are identified, atomic, feasible, and verifiable;
- blocking design questions are resolved;
- the current implementation baseline is known;
- relevant environments and constraints are known;
- required access, tools, data, and dependencies are available or tracked; and
- the authority for accepting changes is defined.

If a missing decision could materially change behavior, interfaces, data, or system structure, return it to design. Do not bury it inside an implementation task.

## Recommended content

### 1. Objective and delivery boundary

State:

- the target outcome;
- the included requirements and design obligations;
- explicit exclusions;
- the current and target states;
- externally visible changes;
- compatibility commitments; and
- the final acceptance boundary.

Define completion in terms of delivered capability and evidence, not effort spent or code written.

### 2. Baseline assessment

Summarize only current facts that affect execution:

- existing components and integration seams;
- reusable behavior;
- known gaps against the target;
- relevant tests and verification facilities;
- data or configuration currently in use;
- operational constraints;
- known defects or debt that affect the plan; and
- assumptions requiring confirmation.

Link to internal sources of truth instead of copying volatile details. Mark observations that have not been verified.

### 3. Requirement and design coverage

List the requirements and design obligations in scope. For each, identify:

- implementing work item or items;
- verification work item or evidence;
- integration point;
- completion status; and
- any approved exception.

No in-scope requirement should be left without implementation and verification coverage. Work that does not trace to an approved outcome should be justified or removed.

### 4. Implementation strategy

Explain the delivery shape at a level stable enough to guide the work:

- decomposition into increments;
- order of integration;
- compatibility strategy during transition;
- isolation of high-risk changes;
- temporary states and how long they may exist;
- test and validation progression;
- data or configuration transition;
- release or activation strategy; and
- removal of temporary mechanisms.

Prefer increments that produce an observable, integrated result. Avoid long chains of isolated layers that cannot be validated until the final task.

### 5. Work-item decomposition

Each work item should be small enough to review and verify as one coherent outcome, but large enough to deliver meaningful progress. Record:

- stable identifier and concise title;
- intended outcome;
- requirements and design obligations covered;
- in-scope and out-of-scope changes;
- prerequisites and blocking dependencies;
- affected internal areas and interfaces;
- implementation steps at the necessary level of detail;
- tests and other verification to add or update;
- acceptance criteria;
- retained evidence;
- risks and recovery considerations;
- owner and status; and
- follow-up work that is deliberately deferred.

Steps should constrain sequence or safety where necessary. They should not prescribe every edit when the exact local edit is discoverable during implementation and does not affect contracts.

### 6. Dependencies and ordering

Represent blocking relationships explicitly. For every dependency, state:

- predecessor and successor;
- why the dependency exists;
- the evidence that unblocks the successor;
- whether work may proceed in parallel; and
- the consequence if the predecessor changes or fails.

Distinguish true blockers from convenient ordering preferences. Identify the critical chain of work and safe parallel branches. Circular dependencies must be redesigned or broken by an explicit intermediate contract.

### 7. Integration and intermediate states

For each increment, define:

- how it integrates with the current baseline;
- whether incomplete behavior is externally reachable;
- compatibility with old and new callers or data;
- temporary adapters, flags, or duplicate paths;
- safe merge, deployment, or activation conditions;
- cleanup trigger; and
- behavior if the remaining increments are delayed.

Every intermediate baseline should build, pass its required checks, and preserve declared invariants unless the plan explicitly defines an isolated non-releasable branch and its exit condition.

### 8. Data, configuration, and compatibility changes

When persistent data, protocols, configuration, or saved state changes, define:

- old and new representations;
- compatibility window;
- transformation or migration procedure;
- validation before and after transformation;
- handling of malformed or partial data;
- interruption and resume behavior;
- backup or recovery mechanism;
- rollback limitations;
- ownership and access controls; and
- retirement criteria for the old representation.

Irreversible transitions require explicit approval, rehearsal, and recovery expectations.

### 9. Verification strategy

Map each requirement to an appropriate verification level and evidence type. Specify:

- tests to add, change, or retire;
- environments and configurations;
- fixtures, datasets, workloads, and dependencies;
- nominal, boundary, failure, and recovery coverage;
- integration and end-to-end checks;
- performance or resource measurements where required;
- regression scope;
- manual checks that cannot yet be automated, with owner and script;
- evidence retention; and
- the rule for handling failures or flaky evidence.

Testing activities should be planned alongside implementation, not deferred to a final catch-all phase.

### 10. Reviews and quality gates

Define the entrance and exit conditions for each relevant checkpoint. Gates may include:

- work-item readiness;
- design conformance review;
- code and test review;
- integration readiness;
- security or safety review;
- migration rehearsal;
- release readiness; and
- post-change validation.

Each gate should name the reviewer, required evidence, pass criteria, and disposition of findings. “Reviewed” is not evidence of acceptance unless the outcome and unresolved findings are recorded.

### 11. Release, activation, and recovery

Where the change reaches a live or shared environment, define:

- packaging and configuration;
- activation sequence;
- pre-change checks;
- health signals and validation queries;
- observation period;
- stop conditions;
- rollback or forward-recovery procedure;
- authority to stop or reverse the change;
- communication responsibilities; and
- post-change cleanup.

A rollback statement must say what is restored, how restoration is performed, what data may not be reversible, and how success is verified.

### 12. Observability and support readiness

Identify the evidence needed to distinguish success from silent failure:

- health indicators;
- diagnostic events;
- measurements and thresholds;
- dashboards or queries maintained within the project;
- alert conditions and owners;
- known failure signatures;
- support instructions; and
- expected behavior during degraded operation.

Observability work is part of the implementation when it is required to verify or operate the change.

### 13. Resources, schedule, and milestones

Record only planning information that affects feasibility or coordination:

- responsible people or roles;
- required skills, environments, tools, and access;
- external availability constraints;
- effort or duration estimates with assumptions and uncertainty;
- milestones tied to measurable outputs;
- review and integration windows; and
- schedule margin for identified risks.

Dates alone do not define a plan. Every milestone should identify its deliverable, acceptance evidence, and dependent work.

### 14. Risks, issues, and change handling

For each material risk or issue, record:

- stable identifier;
- cause and possible consequence;
- likelihood or uncertainty;
- affected requirements or work items;
- prevention or mitigation;
- detection signal;
- contingency;
- owner;
- review point; and
- current status.

Define what happens when implementation reveals a design gap. The normal response is to pause affected work, update the design or requirement through its approval path, assess impact, and then revise the plan and trace links.

## Traceability model

Maintain links in both directions:

```text
Input need or constraint
  -> derived requirement
    -> design obligation
      -> implementation work item
        -> verification activity
          -> retained evidence
```

A practical coverage table:

| Requirement ID | Design ID | Work-item IDs | Verification IDs | Evidence location | Status |
| --- | --- | --- | --- | --- | --- |
| `REQ-...` | `DES-...` | `IMP-...` | `VER-...` | Internal path or record ID | Planned, active, passed, or blocked |

The table should expose:

- requirements without implementation coverage;
- requirements without verification;
- work items with no approved justification;
- changes whose tests do not demonstrate the linked requirement; and
- evidence that belongs to an obsolete baseline.

## Work-item readiness criteria

A work item is ready to start when:

- its outcome and exclusions are explicit;
- its linked requirements and design obligations are approved;
- acceptance criteria are objective;
- prerequisites and blockers are satisfied;
- affected interfaces and data contracts are known;
- required environments, access, and test data are available;
- rollback or recovery expectations are defined where relevant;
- no unresolved product or design decision is delegated to the implementer; and
- the item can reach a reviewable, internally consistent end state.

## Acceptance and testability criteria

Write acceptance criteria as observable outcomes. Each criterion should include:

- initial conditions;
- input or action;
- expected result;
- prohibited result where relevant;
- measurement boundary;
- threshold and tolerance where relevant;
- applicable environment or configuration; and
- evidence required for acceptance.

Good criteria allow a reviewer to answer pass or fail from retained evidence. Avoid criteria such as:

- “implementation completed”;
- “works correctly”;
- “code is clean”;
- “performance is acceptable”;
- “errors are handled”; or
- “tests pass” without naming the required scope and relationship to requirements.

Code quality and maintainability expectations should be expressed through specific repository checks, interface constraints, complexity limits where justified, required review evidence, or change scenarios with measurable outcomes.

## Ambiguity review

Review the plan for:

- tasks whose output cannot be named;
- verbs such as “support,” “handle,” “improve,” “update,” or “refactor” without a bounded outcome;
- missing owners or multiple owners with no accountable lead;
- implicit dependencies;
- milestones defined only by dates;
- estimates without assumptions or uncertainty;
- completion criteria based on effort rather than evidence;
- tests that are not linked to requirements;
- unclear current, intermediate, and target states;
- temporary mechanisms with no removal trigger;
- “later,” “if needed,” or “where appropriate” without an owner and decision point;
- open design decisions hidden inside work items;
- undefined failure, interruption, or rollback behavior;
- steps that cannot be safely resumed or repeated;
- conflicting status between the plan and the work tracker; and
- terminology inconsistent with the design and requirements.

For each work item, ask a reader unfamiliar with the planning discussion to identify its starting state, final state, blockers, acceptance evidence, and next consumer. Any disagreement indicates missing information.

## What the document should not contain

Do not include:

- new product behavior or design decisions disguised as tasks;
- work items with no link to an approved requirement, design obligation, risk, or enabling need;
- a flat checklist that hides dependency order;
- broad phase labels without concrete deliverables;
- exhaustive edit-by-edit instructions that become stale immediately;
- dates or estimates presented without assumptions;
- testing postponed until all implementation is complete;
- “done” criteria based only on code being written or merged;
- unnamed manual verification;
- irreversible changes without explicit approval and recovery treatment;
- temporary compatibility mechanisms without cleanup work;
- unresolved placeholders without owners and deadlines;
- duplicate sources of task status; or
- aspirational future work mixed with committed scope.

## Common anti-patterns

### The feature-sized task

A single item such as “implement the subsystem” hides interfaces, dependencies, verification, and intermediate integration states. It cannot be estimated or accepted reliably.

### The layer-first sequence

Building every data layer, then every service layer, then every interface delays integrated evidence and concentrates risk at the end. Prefer coherent increments that cross the necessary boundaries and demonstrate behavior.

### The test-later tail

Placing all verification in the final work item allows defects and design misunderstandings to accumulate without a tight feedback loop.

### The filename plan

A list of files to edit does not explain the behavioral outcome, ordering, contracts, or acceptance evidence. File paths may support a work item but cannot define it.

### The optimistic straight line

A plan containing only successful steps ignores migration failure, unavailable dependencies, partial completion, interruption, and rollback.

### The hidden redesign

If an implementation item must decide externally visible behavior or a major structural boundary, the design is incomplete. Resolve and approve the decision before continuing affected work.

### The permanent temporary path

Flags, adapters, dual writes, compatibility paths, and diagnostic scaffolding tend to remain unless the plan gives each one an owner, removal condition, and verification.

### The ceremonial gate

A review with no entrance criteria, evidence, decision authority, or recorded disposition creates delay without controlling risk.

### The stale master plan

A plan that is not updated after discoveries, requirement changes, or failed checks becomes misleading. Update it at meaningful checkpoints while preserving the history of baseline changes.

## Practical plan template

```markdown
# <Implementation plan title>

Plan ID: <stable identifier>
Status: <draft | ready | active | paused | completed | superseded>
Owner: <role or person>
Current baseline: <identifier>
Target baseline: <identifier>
Design baseline: <identifier>
Requirement baseline: <identifier>

## 1. Objective and delivery boundary
## 2. Entry conditions and assumptions
## 3. Current-state assessment
## 4. Requirement and design coverage
## 5. Implementation strategy
## 6. Work breakdown and dependency order
## 7. Integration and intermediate states
## 8. Data, configuration, and compatibility changes
## 9. Verification strategy
## 10. Reviews and quality gates
## 11. Release, activation, and recovery
## 12. Observability and support readiness
## 13. Resources, estimates, and milestones
## 14. Risks, issues, and contingencies
## 15. Plan definition of done
```

### Work-item template

```markdown
## IMP-<ID>: <Outcome-focused title>

Status: <planned | ready | active | blocked | completed>
Owner: <role or person>
Requirements: <REQ identifiers>
Design obligations: <DES identifiers>
Prerequisites: <work-item or evidence identifiers>

### Outcome
<Observable capability or enabling result>

### In scope
<Bounded changes>

### Out of scope
<Explicit exclusions>

### Implementation notes
<Necessary constraints, sequence, and affected seams>

### Verification
<Tests, analyses, inspections, or demonstrations>

### Acceptance criteria
- <Observable pass/fail condition>

### Failure and recovery
<Stop, resume, rollback, or forward-recovery behavior>

### Evidence
<Records that must exist at completion>

### Follow-up
<Explicitly deferred work and its owner>
```

## Work-item definition of done

A work item is complete when:

- its stated outcome exists in the integrated baseline;
- all linked requirements and design obligations are satisfied for its declared scope;
- required tests and checks pass in the stated environments;
- boundary, failure, and recovery behavior has been exercised where relevant;
- required reviews are complete and findings are resolved or explicitly accepted;
- compatibility and migration obligations are satisfied;
- diagnostics and support material are present where required;
- temporary mechanisms have a tracked removal condition;
- retained evidence is linked from the work item;
- affected documentation and traceability records are current; and
- no undeclared follow-up is required for the item to be safe and internally consistent.

## Plan definition of done

The implementation plan is ready for execution when:

- entry conditions and approval baselines are explicit;
- every in-scope requirement and design obligation has implementation and verification coverage;
- every work item has an outcome, scope, prerequisites, acceptance criteria, owner, and evidence obligation;
- blocking dependencies and safe parallel work are visible;
- intermediate states are buildable, testable, and operationally understood;
- integration, compatibility, data transition, and recovery are addressed where relevant;
- verification is distributed through the plan and covers nominal, boundary, and failure behavior;
- quality gates have objective entrance and exit criteria;
- material risks have detection, mitigation, contingency, ownership, and review points;
- estimates and milestones state assumptions and measurable deliverables;
- no work item contains an unresolved decision that belongs in the design;
- current state, target state, and deferred work are clearly separated;
- two independent readers can explain the same execution order and acceptance conditions; and
- ownership and update triggers keep the plan aligned with implementation reality.
