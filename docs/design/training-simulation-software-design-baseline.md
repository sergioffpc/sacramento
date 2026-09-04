# Training Simulation Software Design Baseline

Status: Approved design decisions; realization and evidence remain incomplete

Approval: Project owner, 2026-09-04

Baseline version: `SDB-001`

Approved predecessor: None

Version basis: This control document, the Design Commitment register, and the
four subordinate SDDs listed below. Any normative edit creates a successor
Software Design Baseline.

Purpose: Control the first implementation-facing design slice derived from the
approved requirements and Software Architecture Description.

Scope: Process control, common runtime startup, Session Authority composition,
Trainee Client composition, and the offline Content Cooker Tool.

Intended readers: Project owner, designers, implementers, verification authors,
architects, and reviewers.

Prerequisites: Approved initial requirements, SAD-003, ADR-0013,
ARCHSPEC-0013, and the approved governance inventories.

Canonical information owner: Project owner.

## Package and authority

The canonical package is:

| Component | Identity | SHA-256 |
| --- | --- | --- |
| Design Commitment register | `SDB-001-DC` | `c3789df10d1a54d973e7a752956d01265ffb594fd215660a79e2e0a1753d28b0` |
| Process Control Contract SDD | `SDD-0001` | `78e4469f9d18bc68a97d1b5d9718e1e34d5416c4b8d3af8157c59f227892bfa6` |
| Session Authority Runtime SDD | `SDD-0002` | `62e0cac76b5dd6666b5b27d35328792a539338413da6d71d28f7b86c638a53c2` |
| Trainee Client Runtime SDD | `SDD-0003` | `e73208d8ecd2142d5bba3df8aab75e8acf686f94639c4d0a551247a551721344` |
| Content Cooker Tool SDD | `SDD-0004` | `4eb4bb988bd16cfa4b81f2f515cbaeaf75b9d167e9ebca6d77637cdbac15bfef` |

The CSV register owns each Design Commitment's identity, four mutable states,
disposition, traces, owner, and verification approach. An SDD owns normative
obligation text, interface shape, ordering, failure semantics, and rationale;
it does not restate mutable register state.

## Design state model

The dimensions are independent:

| Dimension | Closed values |
| --- | --- |
| Decision | `Proposed`, `Accepted`, `Superseded` |
| Applicability | `Included`, `Future`, `Not Applicable` |
| Realization | `Not Implemented`, `Partial`, `Implemented` |
| Evidence | `Blocked`, `Planned`, `Pass`, `Fail` |

`Accepted` means that the design decision governs. It never implies that code
exists, evidence passed, or a baseline was accepted. Incremental approval is
allowed when every included commitment is internally decided and its external
blockers are explicit. A design-local unresolved choice blocks approval.

## Commitment rules

Each `DC-*` has exactly one governing SDD, one responsible owner, and one
principal `MUST` or `MUST NOT` obligation. Rationale is separate from the
obligation. Requirements remain owned by their canonical requirement source;
an SDD never invents `DREQ-*` identifiers. A missing product obligation must be
corrected there before the design can trace it.

Every interface design states ownership, lifetime, order, blocking behavior,
capacity, and failure semantics. Verification planning covers success, failure,
bounds, malformed input, interruption, idempotency, cleanup, native-type
leakage, and adapter conformance where applicable. Doubles may reproduce
prepared results and failures at real seams, but cannot replace product
behavior for acceptance.

## Initial implementation boundary

A partial executable may parse bootstrap input and reject an invalid launch.
It must not publish `ProcessReady` until every real role-applicable module,
content view, capacity, adapter, endpoint effect, and required destination is
prepared and committed as defined by its SDD.

Implementation should use one library target per runtime/tool composition plus
a thin executable composition root. Shared code may own Sacramento process
types and the Process Control codec; it must not become a generic runtime
framework, service locator, or owner of role behavior.

## Change and acceptance control

A requirement, Architecture Claim, SAD view, SDD obligation, interface, or
state change triggers conservative impact traversal through the Evidence
Dependency Inventory. Editing any pinned SDD or the register creates an SDB
successor and requires a new package review. Acceptance requires all included
commitments to be `Accepted / Included / Implemented / Pass`; external future
decisions remain explicit blockers and cannot be inferred away.
