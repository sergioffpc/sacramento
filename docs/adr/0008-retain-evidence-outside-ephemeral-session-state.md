# Retain evidence outside ephemeral session state

Status: Accepted

Approval: Project owner, 2026-09-03

Purpose: Record the persistence, evidence, trust, and Technical Removal boundary.

Scope: Live session state and every retained evidence class.

Intended readers: Architects, implementers, security reviewers, and verification authors.

Prerequisites: ADR-0004 through ADR-0007.

Canonical information owner: Project owner.

## Decision

Live Training Session state exists only in its ephemeral Session Authority and
is never restored. Each retained data class crosses a private persistence seam
owned by the module that defines its meaning; trust roots remain independently
provisioned and scoped. Client loss during active simulation produces one
atomic, irreversible Technical Removal.

## Rationale and consequences

Separating live state from retained truth avoids a generic persistence module,
shared trust root, and complex reconnection protocol. The costs are no recovery
from transient client or authority failure, explicit loss classifications, and
potentially permanent evidence retention.

The authoritative data-owner table, commit and handoff boundaries, trust
rotation, recovery, failure verification, alternatives, and traces are in the
[evidence architecture specification](../architecture/0008-evidence-and-ephemeral-state.md).
