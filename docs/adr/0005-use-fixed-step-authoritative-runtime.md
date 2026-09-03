# Use a fixed-step authoritative runtime

Status: Accepted

Purpose: Record the authoritative runtime model.

Scope: Canonical time, state commitment, prediction, publication, and lifecycle.

Intended readers: Architects, designers, implementers, and verification authors.

Prerequisites: ADR-0004.

Canonical information owner: Project owner.

## Decision

The Session Authority advances Simulation through deterministic, fixed-duration
Canonical Ticks. Each tick atomically seals and orders eligible Intentions,
resolves effects, commits one state version and reconstruction record, and only
then publishes immutable views. Clients predict for presentation but never
author canonical outcomes.

One authority process owns one Scenario and one Training Session. Connection
loss during active simulation produces irreversible Technical Removal; process
loss never restores live session state.

## Rationale and consequences

Fixed steps prevent rendering cadence, transport jitter, and machine speed from
becoming gameplay rules. They require explicit timing profiles, commit fences,
deterministic ordering, correction of prediction, and reconstruction evidence.

The complete lifecycle, tick transaction, ordering, replication, replay,
failure rules, alternatives, and requirement traces are in the
[runtime architecture specification](../architecture/0005-fixed-step-authoritative-runtime.md).
