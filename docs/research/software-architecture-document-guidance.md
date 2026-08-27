# What a Software Architecture Document Should—and Should Not—Contain

Status: Research guidance

Purpose: Explain the intended outcomes, contents, boundaries, and completion criteria of a lean software architecture document.

Scope: General software architecture documentation and game-engine-specific implications, without defining this project's architecture.

Intended readers: Project owner, architects, design authors, reviewers, and implementers.

Prerequisites: None.

Canonical information owner: Project owner.

## Table of contents

- [Scope](#scope)
- [1. What the document is for](#1-what-the-document-is-for)
- [2. Recommended contents: general software architecture](#2-recommended-contents-general-software-architecture)
- [3. Game-engine-specific implications](#3-game-engine-specific-implications)
- [4. What the document should not contain](#4-what-the-document-should-not-contain)
- [5. A practical lean outline for a game-engine architecture document](#5-a-practical-lean-outline-for-a-game-engine-architecture-document)
- [6. Definition of done for the document](#6-definition-of-done-for-the-document)

## Scope

This note explains software architecture documentation and derives additional implications for a computer game engine. It is not an architecture for a particular engine. Game-engine-specific implications are identified as contextual guidance rather than universal requirements.

## 1. What the document is for

An architecture and its document are not the same thing. The architecture belongs to the system; an architecture description (AD) expresses that architecture for particular readers and purposes. Therefore, the goal is not to produce a particular kind of file or diagram; it is to express the architecture usefully and coherently.

Architecture concerns what is fundamental: the system in its environment, its essential elements, their internal and external relationships, and the principles governing design and evolution. It is not an inventory of everything in the codebase.

A useful architecture document should enable its intended readers to:

- understand the system sufficiently to build, use, analyze, maintain, and learn from it;
- see a shared design vision rather than reconstructing it from source code;
- evaluate whether the design addresses important qualities and risks;
- understand the constraints and significant decisions that shaped the current system; and
- navigate from a high-level view to the relevant detail without confusing levels of abstraction.

Views should be selected according to anticipated use—for example analysis, constraining implementation, project management, or providing an overview.

## 2. Recommended contents: general software architecture

There is no universally mandatory table of contents. Use this selection rule instead: identify the relevant stakeholders and their concerns, then choose viewpoints that address those concerns.

The following is therefore a tailored checklist, not a form to fill mechanically.

### 2.1 Identity, status, audience, and navigation

Record the system/version described, document owner, status, last meaningful update, intended audiences, and a short roadmap to the views and related material. Explicitly identify stakeholders and what they need from the document; doing so avoids irrelevant documentation and focuses effort on information readers actually use.

### 2.2 Goals, scope, context, and constraints

State the system's purpose and key requirements, especially its highest-priority quality goals. Define what is inside and outside the system boundary, its users and neighboring systems, external interfaces, and the technical, organizational, regulatory, or platform constraints that materially restrict design choices.

Quality claims should be concrete enough to evaluate. A quality scenario describes a stimulus or change, its context, the expected response, and a measurable criterion. Include both runtime/usage scenarios and change scenarios where they make quality requirements testable.

### 2.3 Solution strategy

Summarize the few fundamental approaches that connect the goals and constraints to the design: major decomposition principles, pivotal technologies, central patterns, and deliberate trade-offs. Keep this section brief and link to detailed views or concepts rather than duplicating them.

### 2.4 Multiple architectural views

Use several views when readers need to reason about different structures. A view represents a set of system elements and their relationships. Module views support reasoning about implementation structure and qualities such as modifiability; runtime/process views expose behavior and performance-relevant interaction; allocation/deployment views relate software to its execution or development environment.

For each selected view, include:

- its purpose and the stakeholder concerns it answers;
- its scope and level of abstraction;
- the elements and relationships shown;
- the notation or legend;
- important interfaces, responsibilities, constraints, and variation points; and
- links or mappings to related views where correspondence is not obvious.

A diagram must be understandable on its own: give it a title identifying type and scope, a legend, named and typed elements with responsibilities, and directional relationships labelled with their intent. These rules apply equally to informal boxes-and-arrows, a formal modeling language, or another notation.

Static diagrams alone are insufficient when behavior matters. Add a small number of important runtime scenarios—such as startup, a representative request or frame, failure/recovery, and shutdown—to show how elements collaborate over time.

### 2.5 Cross-cutting concepts and policies

Document rules that affect many building blocks once, rather than repeating them in each component: error handling, observability, security, concurrency, persistence, configuration, resource ownership, testing, build/release policy, and similar system-wide mechanisms.

### 2.6 Significant decisions and rationale

Record architecturally significant decisions, their context, alternatives or forces considered, the chosen outcome, status, and positive and negative consequences. A decision log or linked Architecture Decision Records (ADRs) should preserve history without turning the overview into a meeting transcript. The purpose is to explain why the architecture has its present form.

### 2.7 Risks, technical debt, and unresolved questions

Name known architectural risks, accepted technical debt, assumptions, and unresolved decisions, with impact and ownership where useful. Hiding uncertainty makes a document falsely authoritative.

### 2.8 Glossary and references

Define domain-specific and overloaded terms, abbreviations, units, and conventions. Link directly to authoritative requirements, interface specifications, ADRs, source directories, tests, and operational documents within the project rather than copying volatile detail.

## 3. Game-engine-specific implications

This section contains game-engine-specific inferences, not universal requirements. Tailor them to the engine's goals, constraints, and actual risks.

### 3.1 Define which “engine” is being described

**Inference:** State whether the subject includes only the runtime, or also the editor, asset import/cooking pipeline, scripting environment, build tools, platform ports, tests, and sample game. This boundary is unusually important for an engine because these parts may execute in different processes or targets while sharing data formats and modules.

### 3.2 Show the subsystem/module decomposition and dependency rules

**Inference:** The top-level building-block view should show the core/foundation, game-world or scene representation, rendering, physics, audio, input, scripting, assets/resources, editor/tooling, and platform adapters that are actually in scope. More important than a catalogue is the dependency direction, public interface, initialization/lifetime, and extension seam of each subsystem.

Do not assume that an entity-component system, inheritance, scene graphs, or another object model is universally correct. The architecture document should record the chosen model and its consequences rather than present a fashionable pattern as a requirement.

### 3.3 Document lifecycle and representative runtime flows

**Inference:** Include runtime scenarios for engine startup and subsystem registration, level/world loading, one representative frame, shutdown, and failure/device-loss paths relevant to the chosen design. A game engine's frame scenario should distinguish fixed simulation or physics ticks from variable rendered frames, state which work may repeat or be skipped, and identify synchronization points.

### 3.4 Make concurrency and ownership explicit

**Inference:** Add a concurrency view or cross-cutting section identifying the main, render, audio, job/worker, and I/O threads that exist; which subsystem owns mutable state; which APIs are thread-safe; permitted call directions; queues/fences; and shutdown rules. This is architectural rather than incidental when crossing the wrong boundary can stall or crash the engine.

### 3.5 Describe the asset/resource model and tool-to-runtime path

**Inference:** Document source assets versus runtime resources, identifiers and dependency graphs, import/cook/serialization stages, caching and ownership, asynchronous loading/streaming, hot reload if supported, compatibility/versioning, and failure behavior. This deserves its own data or pipeline view because content is a first-class input to games, not merely database state.

### 3.6 Expose platform abstraction and build/deployment variants

**Inference:** A deployment/allocation view should cover supported host and target platforms, graphics/audio/input backends, headless/editor/game builds, optional modules/plugins, build-time feature selection, packaging, and platform-specific constraints. Show the abstraction seam and what may remain platform-specific.

### 3.7 Turn “performance” into budgets and evidence

**Inference:** Replace “must be fast” with measurable scenarios such as target frame/tick time under a defined workload and hardware profile, latency ceilings, memory/asset budgets, startup/load-time targets, and acceptable degradation. Record measurement method and profiling evidence for decisions that trade simplicity for speed. Distinguish continuous low frame rate, intermittent stalls, and load-time slowness; profile first, change one bottleneck, and measure again.

## 4. What the document should not contain

### 4.1 A mechanical dump of the template

Do not fill every section merely because a template contains it. Select information according to stakeholder needs; every documented detail creates maintenance cost. Record only facts and reasons whose value justifies that cost.

### 4.2 An exhaustive mirror of code

Do not reproduce every class, method, directory, or small generic building block by hand. That is API/reference documentation and becomes stale quickly. Prefer stable, high-level structures, significant interfaces, unusual or risky details, and links to the project's source of truth. Omit low-level blocks that are readily understood from code; generate detailed code diagrams on demand when possible.

### 4.3 One overloaded “master diagram”

Do not combine static decomposition, runtime sequence, deployment, data flow, and thread behavior into one unlabeled picture. Different concerns require different views, and overloaded diagrams should be split or abstracted.

### 4.4 Ambiguous boxes and arrows

Do not leave element types, boundaries, relationship direction, or notation implicit. Avoid arrows labelled only “uses” when the important fact is a call, event, data flow, ownership transfer, dependency, or synchronization. Include names, types, responsibilities, technologies where relevant, a legend, and relationship labels matching arrow direction.

### 4.5 Decisions without drivers or consequences

Do not record only “we chose X.” Without context, rejected alternatives or forces, quality drivers, and consequences, future maintainers cannot tell whether the choice still applies. Include a title, status, context, decision, and both positive and negative consequences.

### 4.6 Vague quality claims and speculative optimization

Do not claim “high performance,” “scalable,” “portable,” or “modular” without a scenario or observable criterion. For a game engine, do not present an optimization as justified without stating the workload, target hardware, measurement, and trade-off. Optimizations can backfire, so remeasure after each change.

### 4.7 Unmarked aspiration presented as implemented fact

Do not mix current, planned, experimental, and deprecated architecture without status labels. Separate an “as-is” view from a proposed “to-be” view, and link proposals to decisions or issues. This follows the architecture-description goal of supporting analysis and sustainment and prevents readers from treating intent as reality.

### 4.8 A document written once and abandoned

Do not postpone documentation until implementation is “finished.” Prefer a small current description over a comprehensive stale one, update it as architecture-changing work lands, and assign ownership. Keep updates incremental and detail economical, especially for volatile components.

## 5. A practical lean outline for a game-engine architecture document

Use this only after tailoring it to actual stakeholders and risks:

1. **Document control and reading guide** — subject/version, status, owner, audiences, view map.
2. **Purpose and scope** — engine goals, non-goals, runtime/tooling boundary, neighboring systems.
3. **Stakeholders and architectural drivers** — key use cases, measurable quality scenarios, constraints.
4. **Solution strategy** — the few central principles and trade-offs.
5. **Static decomposition** — top-level subsystems/modules, responsibilities, interfaces, dependency rules, extension seams.
6. **Runtime views** — lifecycle, frame/tick, world/level loading, representative interaction, shutdown/recovery.
7. **Concurrency and ownership** — threads/jobs, mutable-state owners, queues/fences, thread-safe boundaries.
8. **Asset and data pipeline** — import/cook/serialize/load/cache/stream paths and compatibility rules.
9. **Platform and deployment views** — ports/backends, build targets/configurations, packaging and headless/editor/runtime variants.
10. **Cross-cutting concepts** — memory/resource lifetime, errors, diagnostics/profiling, scripting/reflection, configuration, testing, security where relevant.
11. **Decisions, risks, debt, and open questions** — preferably linked to small records with explicit status.
12. **Glossary and references** — canonical terminology and links to requirements, code, tests, APIs, and operational material.

## 6. Definition of done for the document

The document is fit for use when:

- each intended stakeholder can find the view answering their main concerns;
- every diagram states its type, scope, notation, element responsibilities, and relationship meaning;
- important quality claims have measurable scenarios or explicitly state that measures remain unresolved;
- the runtime, concurrency, asset, and platform seams that dominate game-engine risk are visible;
- significant decisions have rationale and consequences, while unresolved issues are clearly marked;
- the description distinguishes current reality from proposals;
- low-level facts are linked to an authoritative source rather than copied unnecessarily; and
- an owner and update trigger are defined so the description can evolve with the engine.
