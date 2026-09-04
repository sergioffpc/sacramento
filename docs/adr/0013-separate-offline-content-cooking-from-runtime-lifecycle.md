# Separate offline content cooking from runtime lifecycle

Status: Accepted

Approval: Project owner, 2026-09-04

Purpose: Record that content cooking is an offline finite tool operation rather
than a product-runtime composition.

Scope: Content Cooker classification, invocation, release identity, lifecycle,
and its relationship to runtime deployment contracts.

Intended readers: Architects, content-pipeline designers, implementers,
verification authors, and release operators.

Prerequisites: ADR-0004, ADR-0007, ADR-0009, ADR-0012, and the approved
functional and architecture baselines.

Canonical information owner: Project owner.

## Decision

Sacramento treats the `Content Cooker Tool` as one offline executable invoked
for one finite `Cooking Job Specification`. It is not a runtime composition,
does not participate in a Training Session, and does not expose a Runtime
Launch Specification, Process Control Contract, Process Lifecycle State,
endpoint, Admission, or resident supervision interface.

One successful invocation publishes exactly one Runtime Content Release made
of one Authority `.pack`, one Client `.pack`, and their processing record under
one atomic release entry. The tool's executable and dependency closure are a
`Tool Release`, not an Application Release. Its platform remains unselected
until a successor architecture decision and applicable profile admit one.

This decision amends the Content Cooker rows and prose in ADR-0004,
ADR-0007, ADR-0009 and their detailed specifications. Their runtime decisions
remain accepted for the Session Authority and Trainee Client.

## Rationale and consequences

Applying runtime readiness, process supervision, endpoint, and replacement
semantics to a finite offline transformation would enlarge the interface
without protecting a runtime behavior. A job specification and terminal job
result preserve exact input, provenance, idempotency, failure, and publication
semantics at the seam that actually varies.

The separation requires a distinct tool-release identity, job-result contract,
platform-admission decision, and design document. It retains the accepted
two-pack isolation, signing, deterministic Pack Core, staging, and atomic
publication decisions.

The complete architecture correction is in
[ARCHSPEC-0013](../architecture/0013-offline-content-cooker-tool.md).
