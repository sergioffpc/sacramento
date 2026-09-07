# Close cross-cutting architecture and verification

Status: Accepted architecture decision; implementation, evidence, and baseline acceptance remain incomplete

Document-control and evidence-administration portions superseded by
[ADR-0014](0014-use-lightweight-executable-documentation.md). Responsibility
ownership, independent states, adapter contracts and native/integration checks
remain in force; mandatory nine-view metadata and cyclic inventory approvals do not.

Approval: Project owner, 2026-09-03

Purpose: Record the cross-cutting ownership and architecture-verification decision.

Owner: Project owner.

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

Explicit claim states and conservative dependency impact prevent accepted
decisions from being mistaken for implementation or evidence. ADR-0014 generates
mechanical indexes while retaining semantic claim and contract ownership.

The complete cross-cutting contracts, architecture views, verification
layers, representative sequences, closure blockers, alternatives, and traces
are in the [cross-cutting architecture specification](../architecture/0010-cross-cutting-architecture-and-verification.md).
