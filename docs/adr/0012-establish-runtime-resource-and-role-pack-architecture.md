# Establish runtime-resource and role-pack architecture

Status: Accepted architecture decision; implementation, type-schema admission,
dependency qualification, evidence, and baseline acceptance remain incomplete

Approval: Project owner, 2026-09-04

Purpose: Record the runtime-resource identity, role-pack format, validation,
materialization, ownership, and publication decision.

Scope: Content authoring identity metadata, cooking, role-pack representation,
runtime validation and materialization, immutable resource access, and startup
evidence.

Intended readers: Architects, content-pipeline designers, engine implementers,
security reviewers, performance engineers, and verification authors.

Prerequisites: ADR-0003 through ADR-0011 and the approved C++ engineering,
functional, non-functional, observability, and verification baselines.

Canonical information owner: Project owner.

## Decision

Sacramento identifies each independently referenced Runtime Resource with one
opaque UUIDv4 Resource Identity, separates persistent Resource References from
typed execution-local Runtime Resource Handles, and admits resources only
through a closed Runtime Resource Type Inventory. Authority and Client
projections have distinct resource identities and one semantic owner each;
Content Admission coordinates one atomic publication without becoming a
generic resource owner or manager.

Each role pack uses one exact, deterministic format with a fixed header, a
signed Pack Envelope, a restricted deterministic CBOR Pack Manifest, one
uncompressed Stored Extent per Runtime Resource, and an Ed25519 signature.
SHA-256 authenticates the manifest, every extent, each non-circular Pack Core,
and the full content-signing public-key identity. Runtime Package owns package
structure, cryptography, integrity, compression, and private filesystem access;
each responsibility module owns semantic decoding, final materialization, and
lifetime for its resource types.

Runtime activation is a bounded startup transaction. It authenticates the
manifest, validates the complete local DAG, reserves all required persistent
and transient capacity, verifies every extent, completely materializes all
CPU and GPU resources, closes the pack handle, and only then publishes the
composed immutable view. The first implementation uses sequential synchronous
buffered I/O. Compression and asynchronous I/O require an approved startup
target and representative native evidence before a successor may admit them.

`Scenario` is an explicit responsibility module, resolving the discrepancy
between the responsibility catalogue in ARCHSPEC-0004 and the exclusive owner
already defined by ARCHSPEC-0006.

## Rationale and consequences

Separating semantic identity, package location, exact bytes, and execution-local
access keeps authoring changes from breaking references and keeps filesystem,
crypto, vendor, and allocator representations out of behavior-owner seams. A
closed type inventory and eager atomic publication make hostile-input failure,
capacity, cleanup, and ownership testable without a universal
`ResourceManager`.

The narrow version-one format deliberately rejects compression, cycles,
deduplicated extents, mounts, overlays, memory mapping, lazy loading, generation
replacement, and algorithm negotiation. It pays startup I/O and format-change
cost to obtain deterministic bytes, bounded parsing, independent role closure,
and no content-file dependency after runtime readiness.

The complete contracts, format, validation order, failure precedence,
materialization rules, evidence gates, alternatives, and traces are in the
[runtime-resource architecture specification](../architecture/0012-runtime-resource-and-role-pack-architecture.md).
The separately governed [Runtime Resource Type
Inventory](../architecture/training-simulation-runtime-resource-type-inventory.md)
remains a candidate until every admitted type has an exact schema, limits,
dependencies, and materializer contract.
