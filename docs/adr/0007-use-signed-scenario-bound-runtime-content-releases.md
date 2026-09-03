# Use signed scenario-bound runtime content releases

Status: Accepted

Purpose: Record the runtime-content identity and activation decision.

Scope: Cooking, signing, pairing, compatibility, activation, and process lifetime.

Intended readers: Architects, content-pipeline designers, implementers, and security reviewers.

Prerequisites: ADR-0003 through ADR-0006.

Canonical information owner: Project owner.

## Decision

Each exact Scenario version is cooked into one immutable signed Runtime Content
Release containing reciprocally bound Authority and Client Packs. A runtime
receives one explicit role pack, validates and materializes it completely before
readiness, and never replaces it during that process.

Compatibility is an exact pre-approved relation: there is no runtime download,
format negotiation, migration, directory discovery, or automatic fallback.

## Rationale and consequences

Paired releases preserve headless closure and make content identity, provenance,
and cross-host matching auditable. Every relevant change requires a new pair;
startup is eager and a Training Session requires fresh processes and Admissions.

The complete release model, cooker sequence, trust boundary, matching, retention,
failure cases, verification, alternatives, and traces are in the
[content architecture specification](../architecture/0007-runtime-content-releases.md).
