# Close cross-cutting architecture and verification

Status: Accepted architecture decision; implementation, evidence, and baseline acceptance remain incomplete

Approval: Project owner, 2026-09-03

Purpose: Record the cross-cutting ownership and architecture-verification decision.

Scope: Configuration, outcomes, resources, testing, evidence, and claim status.

Intended readers: Architects, implementers, and verification authors.

Prerequisites: ADR-0003 through ADR-0009.

Canonical information owner: Project owner.

## Decision

Cross-cutting behavior remains owned by the responsibility module that defines
its meaning; runtime composition coordinates ordering without becoming a
generic manager. Decision, baseline applicability, realization, and evidence
are independent states for every Architecture Claim.

Architecture verification accumulates static closure, common adapter contracts,
native executable closure, and the smallest representative end-to-end
sequences. Runtime evidence hooks report attributable facts but never assign a
verification `Pass`.

## Rationale and consequences

Explicit claim states and dependency impact prevent accepted decisions from
being mistaken for implementation or evidence. This adds claim and inventory
maintenance but keeps configuration, failure, testing, and evidence semantics
local to their owners.

The complete cross-cutting contracts, claim register, view set, verification
layers, representative sequences, closure blockers, alternatives, and traces
are in the [cross-cutting architecture specification](../architecture/0010-cross-cutting-architecture-and-verification.md).
