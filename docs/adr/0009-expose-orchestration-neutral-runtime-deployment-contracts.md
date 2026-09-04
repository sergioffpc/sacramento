# Expose orchestration-neutral runtime deployment contracts

Status: Accepted

Approval: Project owner, 2026-09-03

Latest approved amendment: ADR-0013 removes the offline Content Cooker Tool
from runtime lifecycle scope, project owner, 2026-09-04

Purpose: Record the runtime deployment boundary.

Scope: Deployable units, launch, readiness, compatibility, handoffs, and shutdown.

Intended readers: Architects, implementers, operators, and infrastructure owners.

Prerequisites: ADR-0003 through ADR-0008.

Canonical information owner: Project owner.

## Decision

Sacramento exposes immutable launch, readiness, endpoint, capacity, shutdown,
and exit contracts while external infrastructure owns scheduling and
supervision. One authority process serves one Training Session; replacement
always creates a new session. Platform capabilities remain private
responsibility-owned adapters rather than one Platform module.

This runtime contract applies to the Session Authority and Trainee Client. The
offline Content Cooker Tool is governed by ADR-0013 and has a finite job/result
contract instead of a Runtime Launch Specification or Process Lifecycle State.

Production security and platform operations remain named future baselines. The
Development Baseline preserves the AUTH seam through an explicitly permissive,
non-production Synthetic Identity adapter.

## Rationale and consequences

The contract can be hosted by later orchestration without importing
orchestrator concepts into canonical modules. It requires complete pre-start
validation, explicit compatibility administration, and accepts loss of an
individual Training Session when its authority process fails.

The deployment allocation, platform seams, launch sequence, handoff and failure
contracts, shutdown paths, security boundary, alternatives, and traces are in
the [deployment architecture specification](../architecture/0009-runtime-deployment-contracts.md).
