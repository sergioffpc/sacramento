# Architecture specification: offline Content Cooker Tool

Status: Accepted architecture decision; implementation, evidence, platform
selection, and baseline acceptance remain incomplete

Approval: Project owner, 2026-09-04

Purpose: Correct the Content Cooker classification and define its
architecture-level offline job, identity, publication, and runtime-separation
contracts.

Scope: Content Cooker Tool input and output boundaries, authoring closure,
Tool Release identity, failure containment, publication, and platform deferral.

Intended readers: Architects, content-pipeline designers, implementers,
verification authors, and release operators.

Prerequisites: ADR-0013, ARCHSPEC-0004, ARCHSPEC-0007, ARCHSPEC-0009,
ARCHSPEC-0012, and the approved functional-baseline correction.

Canonical information owner: Project owner.

## Classification and boundary

The Content Cooker Tool is an offline module and executable, not a runtime
composition. One invocation consumes one immutable Cooking Job Specification,
performs one finite cooking job, commits one Cooking Job Result, and exits. It
never joins the Controlled LAN, hosts or joins a Training Session, accepts an
Admission, publishes a Process Lifecycle State, or remains resident for later
jobs.

The Session Authority Runtime and Trainee Client Runtime remain product-runtime
compositions governed by the Process Control Contract and role-specific Runtime
Launch Specifications. Administrative Tool Runtimes in ARCHSPEC-0004 become
`Administrative Tools`; a later decision selects their concrete executable
population and contracts.

## Tool and job identities

A Tool Release is the immutable executable and dependency closure for one exact
offline tool role and platform. It remains distinct from an Application
Release, Runtime Content Release, Cooking Job Specification, and processing
record. No Content Cooker Tool platform, Reference Hardware Profile, package,
or distribution mechanism is selected by this correction.

The Cooking Job Specification fixes the job identity, Tool Release, exact
authoring root and source closure, processing gate, catalogues, profiles,
tool/configuration versions, output identities, signing-key reference,
publication destination, capacities, provenance, and Cooking Job Result
destination before execution. Command-line options only identify the
specification. Environment variables, current working directory, directory
discovery, and mutable defaults cannot add or override job inputs.

Output identities are supplied by the specification. Cooking does not invent a
Runtime Content Release, role-pack, processing-record, Resource, or subresource
identity. An identical retry may complete the same candidate; it cannot create
a new identity implicitly.

## Authoring closure and snapshot

One specification selects one `authoring/` root and enumerates every admitted
relative path, expected digest, source classification, and sidecar relation.
The tool walks the root in normalized deterministic order without following
symbolic links. A missing, unexpected, special, case-colliding,
Unicode-colliding, out-of-root, changed, or misclassified entry fails the job.

Before transformation, the tool creates one private immutable input snapshot.
Every later stage reads that snapshot rather than the live authoring tree.
Mutation detected while capturing it fails the job. The snapshot is staging,
not a canonical source or published artifact, and is removed after a classified
terminal outcome when ownership is certain.

## Finite workflow

The deterministic job coordinator performs the accepted ARCHSPEC-0007 and
ARCHSPEC-0012 workflow in this order:

1. validate the Cooking Job Specification and Tool Release identity;
2. capture and validate the complete authoring snapshot;
3. validate the exact processing gate, catalogues, profiles, tools and
   configuration;
4. produce both deterministic Pack Cores in private staging;
5. produce the complete processing record and reciprocal pack envelopes;
6. sign both role packs through the private signing seam;
7. make both packs and the processing record durable;
8. atomically publish one complete release entry;
9. atomically commit one Cooking Job Result; and
10. clean owned staging and exit.

The first version has one job coordinator and no configurable scheduler,
incremental cache, source fallback, implicit discovery, or automatic retry. A
private source adapter may perform internal work only when its bounded output
is independent of completion order and returned in canonical order.

## Publication and retry

The Release Publisher interface owns three capabilities: private same-domain
staging, durability of the complete candidate, and atomic publication of one
release entry. It does not expose a generic filesystem interface. An admitted
platform adapter and an in-memory test adapter satisfy the same contract.

The publication commit point is visibility of the complete release entry
containing the Authority `.pack`, Client `.pack`, and processing record. Before
that point, no candidate is usable. Failure leaves every preceding published
release unchanged. If the same release identity is already committed, exact
identity and digest equality returns the existing result idempotently; any
difference is `IdentityConflict` and never overwrites, merges, or renames the
existing release.

Cancellation is observed only at declared operation boundaries. Once
publication begins, the adapter must classify the result as `Committed` or
`Not Committed`; ambiguity produces a failed, non-accepted job result and
blocks automatic retry. On a later invocation, only incomplete staging whose
tool ownership is proved may be removed. Committed, corrupt, or
ownership-uncertain material is never deleted by recovery.

## Signing and provenance

The specification contains a signing-key reference, never key material. The
private signing adapter exposes signing operations and the non-secret Content
Signing Key Identity; secret bytes do not cross its interface or enter a
processing record or job result.

Executor and execution instant are immutable specification fields with exact
source, authority, format, and trust classifications. The tool validates and
copies them. It does not infer executor identity from an operating-system
account or obtain the evidence instant from an uncontrolled wall clock.

## Failures and evidence

Every classified failure commits one Cooking Job Result and references no
usable successor release. Process loss before that commit is distinguishable
from a tool-produced failure. Stdout and stderr are diagnostic surfaces only;
they never establish the job result, publication commit, identity, or evidence
disposition.

Verification covers deterministic traversal and snapshots, every rejected path
class, mutation at every capture boundary, each workflow failure, cancellation
at every fence, signing failure, partial durability, atomic publication,
identity collision, identical retry, staging recovery, sensitive-data absence,
and proof that no runtime lifecycle or Controlled LAN dependency enters the
tool interface.

## Architecture Claims and trace

This specification governs `AC-TOOLING-001` through `AC-TOOLING-005`. It
principally satisfies `REQ-CONTENT-COOKER-TOOL-001`,
`REQ-COOKING-JOB-SPECIFICATION-001`, `REQ-COOKING-JOB-PROVENANCE-001`,
`REQ-CONTENT-PROCESSING-GATE-001` through
`REQ-CONTENT-PROCESSING-ADMISSION-001`, `REQ-CONTENT-RELEASE-001` through
`REQ-CONTENT-SIGNING-001`, and
`DEFERRED-CONTENT-COOKER-PLATFORM-001`.
