# Isolate runtime owners and bound failure

Status: Accepted

Purpose: Record the concurrency, ownership, capacity, and failure-containment decision.

Scope: Session Authority and Trainee Client execution boundaries.

Intended readers: Architects, designers, implementers, and verification authors.

Prerequisites: ADR-0004 and ADR-0005.

Canonical information owner: Project owner.

## Decision

Every mutable state class has one exclusive responsibility owner. Owners
communicate through revision-bound immutable views and explicit messages;
capacity is reserved before admission and every ingress path has deterministic
backpressure. The Canonical Tick waits only at its declared commit fences.

Failures are contained to the smallest safe semantic scope. Canonical-integrity
failure terminates a Training Session, client loss removes one Trainee, and
asynchronous observability or assessment failure cannot change Simulation.

## Rationale and consequences

This makes scheduling and partial failure explicit without prescribing threads,
queues, processes, or storage products. Implementations must expose ownership,
capacity, publication, loss, and idempotent recovery contracts.

The complete owner matrix, handoff, scheduling, atomicity, backpressure,
startup/shutdown rules, alternatives, and traces are in the
[ownership architecture specification](../architecture/0006-runtime-ownership-and-failure.md).
