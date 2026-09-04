# Decompose Sacramento by canonical responsibility

Status: Accepted

Latest approved amendment: ADR-0013 separates the offline Content Cooker Tool
from runtime compositions, project owner, 2026-09-04

Purpose: Record the module-decomposition decision.

Scope: Architecture-level responsibility, dependency direction, and runtime composition.

Intended readers: Architects, designers, and implementers.

Prerequisites: ADR-0003.

Canonical information owner: Project owner.

## Decision

Sacramento is decomposed into deep modules that exclusively own canonical
product responsibilities. Runtime processes compose those modules and
coordinate multi-owner workflows without becoming owners of module-private
state. Dependencies point towards the canonical owner and remain acyclic;
vendor and platform integrations stay private adapters.

The Content Cooker is an offline finite tool composition governed by ADR-0013,
not a product-runtime composition. The Session Authority and Trainee Client
remain the product-runtime compositions in this decision.

## Rationale and consequences

Responsibility-first modules keep authority and failure boundaries visible and
avoid both vendor-shaped wrappers and a universal shared module. Cross-owner
work therefore requires explicit orchestration and immutable handoffs.

The authoritative module catalogue, runtime compositions, dependency view,
adapter rules, future Autonomous Participant seam, alternatives, and traces
are in the [responsibility architecture specification](../architecture/0004-canonical-responsibility.md).
