# Architecture specification: runtime resources and role packs

Status: Accepted architecture; implementation, exact type schemas, dependency
qualification, evidence, and baseline acceptance remain incomplete

Approval: Project owner, 2026-09-04

Purpose: Define the stable identity, package, validation, materialization,
ownership, lifetime, and verification contracts for Runtime Resources.

Scope: Resource Identity Metadata, Content Cooker output, Authority and Client
role-pack bytes, Runtime Package and Content Admission seams, responsibility-
owned materialization, immutable runtime access, cleanup, and adoption evidence.

Intended readers: Architects, designers, content-pipeline authors, C++
implementers, security reviewers, performance engineers, and verification
authors.

Prerequisites: [ADR-0012](../adr/0012-establish-runtime-resource-and-role-pack-architecture.md),
[ADR-0007](../adr/0007-use-signed-scenario-bound-runtime-content-releases.md),
[runtime content releases](0007-runtime-content-releases.md),
[cross-cutting architecture](0010-cross-cutting-architecture-and-verification.md),
[memory architecture](0011-memory-accounting-and-allocation.md), the
[technical glossary](../glossary/technical.md), and the approved C++
engineering, functional, non-functional, observability, and verification
baselines.

Canonical information owner: Project owner.

## Decision boundary

ADR-0007 remains authoritative for one signed, paired Runtime Content Release,
one explicit role-pack path, eager complete activation, exact compatibility,
pre-Admission pair matching, immutable process lifetime, and external
retention. This specification closes the previously deferred identity,
manifest, serialization, integrity, signature, materialization, handle, and
initial I/O decisions without admitting runtime download, streaming, patching,
fallback, or content replacement.

The accepted resource architecture has four distinct identities:

| Concern | Stable meaning |
| --- | --- |
| Resource Identity | Persistent UUIDv4 identity of one semantic Runtime Resource |
| Physical location | Private Pack Manifest offset and size of one Stored Extent |
| Content identity | SHA-256 of exact authenticated bytes at manifest, extent, or Pack Core scope |
| Runtime access | Typed, execution-local, borrowed Runtime Resource Handle |

Paths, hashes, offsets, pointers, slots, and handles never substitute for a
Resource Identity. A Runtime Resource is not a source asset, manifest entry,
encoded extent, allocation, GPU API object, or evidence record.

## Canonical ownership and module correction

`Scenario` is an explicit responsibility module. It owns objective progression,
configured duration, empty-Team and other Scenario result rules, and the
resolved terminal result already assigned to it by ARCHSPEC-0006. The Session
Authority Runtime composes `Scenario` in addition to its previously listed
modules. This corrects the incomplete catalogue and composition in
ARCHSPEC-0004; it does not move Simulation or Session Lifecycle state.

Runtime-resource responsibilities are separated as follows:

| Owner | Responsibility |
| --- | --- |
| Runtime Package | Persistent package and identity schemas, deterministic codec, fixed format, crypto and integrity adapters, compatibility, private pack handle, bounded exact-range reads, and authenticated payload handoff |
| Content Admission | Candidate graph, capacity-plan coordination, ordered materialization transaction, failure cleanup, and atomic composed-view publication |
| Runtime Resource Type Inventory | Approved mapping from each type identity to its semantic owner, exact schemas, structural limits, dependency rules, materialization contract, and failures |
| Applicable responsibility module | Semantic validation and decoding, final CPU or GPU object construction, immutable owner view, Memory Accounting Owner, and release fence |
| Runtime composition | Complete launch compatibility, cross-owner ordering, aggregate readiness result, and process exit classification |

Content Admission is a coordinator, not a semantic owner, registry service, or
general-purpose `ResourceManager`. Each owner publishes its own immutable view;
the composed root makes all owner views visible at one commit point. Shared
consumption uses borrowed immutable views with one owner and one accounting
charge. A true ownership change requires an explicit one-source-to-one-recipient
handoff.

## Resource identity and authoring metadata

Every independently referenced Runtime Resource and independently addressable
subresource receives an opaque UUIDv4 generated once by an authorized authoring
tool. The binary form is the 16 RFC 9562 UUID bytes. The authoring and diagnostic
form is lowercase hyphenated text. Neither form is derived from a path, name,
timestamp, array index, content digest, or execution order.

Identity is preserved through moves, renames, and compatible edits. Duplication,
semantic replacement, a change of semantic owner, or replacement by another
resource creates a new identity. Authority and Client runtime projections use
different Resource Identities even when they have a common source or identical
bytes. The processing record relates those projections. Product identities
embedded in them, including Scenario, Map anchor, region, tactical-space, and
connection identities, remain common where their domain meaning is common.

Each canonical source has an adjacent `<source-name>.sacmeta.json` Resource
Identity Metadata sidecar. It uses UTF-8 normalized to NFC, LF line endings, a
required exact schema version, fixed property order, and arrays ordered by
semantic key. Its closed value set is strings, unsigned integers, booleans,
objects, and arrays. Unknown or duplicate properties, fractional numbers,
non-canonical Unicode, ambiguous semantic keys, and invalid UUID forms fail.

The sidecar contains only:

- the canonical-source UUID;
- each stable product semantic key, Resource Identity, and type identity; and
- each stable subresource semantic key and Subresource Identity.

It contains no source path, timestamp, derived digest, cooker result, approval,
or evidence. A rename moves source and sidecar together. Duplication is an
explicit tool operation that creates all new identities before cooking. Missing
metadata, copied identities, and merge conflicts fail the cook. Repair restores
the prior metadata or performs an explicit reidentity operation after showing
all affected references; cooking never invents or silently repairs identity.

Authoring names are relative UTF-8 NFC strings with `/` separators. The cooker
rejects absolute, drive, UNC, empty, `.`, `..`, NUL, over-length, or
non-normalized components; prevents symlinks from escaping an admitted source
root; preserves display case; and rejects collisions under its pinned,
locale-independent Unicode case-folding version. Paths remain processing-record
facts and never become runtime lookup keys.

A Map element receives a Subresource Identity when another resource references
it, it owns canonical state, it participates in evidence, or a Scenario selects
it. This includes applicable anchors, regions, tactical spaces and connections,
doors, windows, lights, circuits, and destructible objects. Representation-only
vertices, triangles, draw calls, and similar private details receive none.

## Type and reference model

The [Runtime Resource Type
Inventory](training-simulation-runtime-resource-type-inventory.md) is the sole
closed type authority. A type identity denotes one stable semantic meaning and
one owner. Any encoding change increments its exact schema version; a meaning,
owner, or invariant change creates a new type identity. The runtime content
contract enumerates exact admitted type/schema pairs. Unknown types, versions,
fields, enums, or codecs fail rather than negotiate, migrate, ignore, or fall
back.

A persistent Resource Reference contains a Resource Identity, optional
Subresource Identity, and expected type identity. Every non-null reference
resolves within the same Pack Manifest. Cross-role runtime dependencies are
forbidden. Nullable references exist only where the type schema says so;
absence of any other reference fails startup.

Materialization resolves persistent references into typed Runtime Resource
Handles. A handle is an execution-local slot or index into the process's one
immutable published view and never persists. Normal handle access performs no
I/O, allocation, hash lookup, global locking, fallback, or vendor conversion.
There is no public Resource Generation: the process publishes one view and
never replaces it. A private diagnostic cookie may detect misuse without
becoming a persistent or public contract.

## Version-one pack format

One role pack has exactly five contiguous regions and no gaps, semantic
padding, or trailing bytes:

```text
Fixed Header | Pack Envelope | Pack Manifest | Payload | Ed25519 Signature
```

The fixed header contains magic, exact format version, fixed header size, and
fixed-width offsets and lengths for every following region. Sacramento-owned
fixed-width binary integers use little-endian. Offsets must equal the canonical
contiguous positions derived from preceding lengths; arbitrary positioning is
not admitted.

The Pack Envelope and Pack Manifest use a Sacramento profile of RFC 8949 Core
Deterministic Encoding. The profile permits only preferred-form unsigned
integers, byte strings, and definite-length arrays. It forbids maps, text,
negative integers, bignums, tags, floats, simple values, indefinite lengths,
duplicate alternatives, and extensions. Positional arrays have exact lengths.
Normative golden and malformed vectors govern bytes; CDDL may document but
cannot override them.

The Pack Envelope binds exactly:

- envelope version;
- Runtime Content Release identity;
- Scenario identity and exact version;
- own pack identity and role;
- runtime content contract identity and exact version;
- own and counterpart pack identities and Pack Core Digests;
- Pack Manifest SHA-256 digest;
- processing-record identity and SHA-256 digest;
- signature-scheme identity; and
- Content Signing Key Identity.

The manifest cannot redefine an envelope value. The header, envelope, immutable
launch inputs, and trusted entry must agree exactly wherever their scopes
overlap.

Each Pack Manifest entry contains exactly:

- Resource Identity as 16 bytes;
- stable unsigned type identity and exact unsigned schema version;
- Stored Extent offset and stored size;
- decoded-size limit;
- closed codec identity, whose only version-one value is `None`;
- the extent's 32-byte SHA-256 digest; and
- an ordered, duplicate-free array of Resource References.

Each Runtime Resource owns exactly one Stored Extent and each extent belongs to
exactly one resource. Version one has no slicing, shared extent, deduplication,
aliasing, compression, or manifest-selected alignment. Manifest entries are
ordered by Resource Identity bytes. Stored Extents are physically ordered by
the canonical dependency topological order with Resource Identity bytes as the
tie-breaker, enabling one sequential verification and materialization pass.

The Pack Core is the exact Pack Manifest followed by the complete Payload. Its
SHA-256 Pack Core Digest excludes header, Pack Envelope, and signature. This
breaks reciprocal-hash circularity: both signed envelopes bind the same two
precomputed pack identities and Pack Core Digests. Runtime Content Release and
pack identities are opaque assigned values, not recursive file hashes. A
complete-file hash may support distribution and reproduction but is not the
pair binding or a trust credential.

All Stored Extents form one complete, ordered, non-overlapping partition of the
Payload. Each SHA-256 covers the exact stored bytes and is checked before schema
decoding. Because version one admits `None`, stored and decoded sizes must agree;
the separately retained decoded-size field remains an enforced bound and a
closed point for a future version.

## Signing and trust

Version one admits pure Ed25519 from RFC 8032 with a 32-byte public key and
64-byte detached signature. Ed25519ph, ECDSA, algorithm negotiation, and
pack-selected alternatives are not admitted. A later algorithm requires a new
format or successor decision.

The signature covers a fixed Sacramento domain separator followed by the exact
fixed header and exact Pack Envelope bytes. The signed envelope binds the Pack
Manifest digest and Pack Core Digest. Concrete field widths and the domain
separator bytes are fixed by normative version-one vectors before
implementation acceptance; they cannot be implementation defaults.

The Content Signing Key Identity is the complete 32-byte SHA-256 result of the
Sacramento content-signing-key domain separator, signature-scheme identity, and
raw Ed25519 public key. It is a fingerprint and exact lookup key, not a trust
root or authorization credential. The independent Content Signing Trust
Reference entry binds that identity to one exact scheme, public key, pack role,
and runtime content contract. Zero, truncated, duplicate, or ambiguous key
identities fail.

The cooker continues to receive its signing private-key path explicitly and to
use a private adapter only after the complete content gate succeeds. The key is
never stored in sources, packs, processing records, or diagnostics. Failure to
read or use it prevents pair publication. HSMs, signing services, concrete host
permissions, backup, operational rotation, and Production Security Baseline
controls remain outside this decision. Trust-reference rotation and compromise
recovery retain ADR-0007 semantics.

OpenSSL 3.5 LTS through a private `libcrypto`/EVP adapter and QCBOR are first
qualification candidates; libsodium and a minimal first-party decoder are
comparison candidates. None is an admitted dependency. Exact version, origin,
source hash, licence, CVE disposition, selected features, ABI, closure, Clang
builds on Windows and Debian, native tests, fuzzing, offline source retention,
and upgrade behavior must satisfy the C++ Engineering Baseline before
selection. A transport library's private crypto backend supplies no such
qualification by reuse.

## Bounds and capacity

Manifest values report authenticated observed sizes; they never define their
own trust limits. The format and runtime content contract fix absolute maxima
for pack size, every section, resource count, references per resource, CBOR
depth, integer values, and offsets. Each type-inventory row fixes its semantic,
decoded, scratch, object, descriptor, and GPU bounds. Memory Budget
Configuration may impose a smaller execution capacity but cannot enlarge a
format or type limit.

After authenticating and structurally validating the manifest and DAG, but
before reading Payload, each type contract applies one bounded overflow-safe
capacity function to authenticated fields. Content Admission composes the
results and the single-resource transient window. Every owner validates and
reserves:

- all required persistent CPU and applicable GPU capacity;
- candidate registry and graph state;
- the largest Stored Extent;
- the largest admitted decode and materialization scratch requirement; and
- applicable GPU upload staging and descriptors.

Required-capacity failure produces `ProcessNotReady`, complete cleanup, and non-zero
exit without Payload reads or partially visible materialization. Numerical
limits remain evidence gaps until approved Memory Budget Configurations close
them.

## Validation, failure, and publication

Runtime Package reads one explicit path through one handle. It obtains and
bounds the stable size, validates canonical contiguous sections, rejects any
observable file identity or size change, and never reopens the path during the
transaction. A Windows adapter may deny write and delete sharing; Debian
correctness cannot rely on advisory locking. Cryptographic validation remains
authoritative under concurrent mutation.

The normative validation sequence is:

```text
open one handle and obtain bounded size
-> parse only the fixed header
-> validate exact version and contiguous bounded regions
-> minimally parse the bounded Pack Envelope
-> select the exact trust-reference entry
-> verify Ed25519 over domain separator + exact header + exact envelope
-> validate signed launch/release/role/contract bindings
-> hash and parse the bounded Pack Manifest
-> validate types, schemas, references, DAG, ranges and capacity
-> read and hash every Stored Extent in canonical materialization order
-> verify the local Pack Core Digest
-> semantically materialize owner views
-> complete required GPU fences
-> close the pack handle
-> atomically publish the composed immutable view
```

Minimal unauthenticated parsing locates bounded signed material; it cannot
authorize an allocation beyond fixed bootstrap bounds, decompression,
filesystem access, type dispatch, or semantic action. Full manifest parsing
occurs only after its signed digest matches. Every non-null reference resolves
locally, types and schemas match exactly, ranges are arithmetically safe, the
graph is a DAG, and the canonical topological order is unique.

Programmatic failure has one primary stable non-sensitive outcome selected by
logical phase, never thread timing:

```text
Missing/Open
-> Header/Envelope Structure
-> Trust and Signature
-> Release/Role/Pair Binding
-> Manifest Integrity and Structure
-> Type/Schema/Graph
-> Capacity
-> Extent Integrity
-> Semantic Materialization
-> GPU Publication Fence
```

Diagnostics may retain secondary failures. The external stable result contains
only category, operation, role, and required non-sensitive release, pack,
Scenario, and trust-reference identities. Protected Diagnostic detail may add
type identity, Resource Identity, phase, offset, and one sanitized native code.
It never exposes full paths, source names, payload bytes, public keys,
signatures, secrets, or authentication material. Native errors map once inside
the owning adapter.

Stored buffers, decode scratch, and candidate graph state use the `Startup
Validation` Memory Lifetime Domain. Final resources are constructed directly
in owner-attributed candidate capacity with `Process Lifetime` but remain
invisible. Publication exposes the composed root without copying or
reattributing allocations. Presentation owns GPU objects, descriptors, upload
staging, and applicable fences even when content is their source.

Any failure prevents publication, cancels work where applicable, drains every
completion and GPU fence, destroys completed owner resources in exact reverse
materialization order, releases Startup Validation state, and closes the pack.
Normal shutdown stops consumers, observes owner release fences, destroys
resources in reverse dependency order, and releases the root last. Consumer
handles are borrowed and never control lifetime.

Complete materialization means every required resource is decoded, validated,
linked, and constructed and every required GPU object is created, uploaded,
and past its publication fence. It does not promise CPU prefaulting or permanent
physical residency. No first-use decode, construction, upload, content I/O, or
pack-backed memory mapping is permitted after publication. Closing, replacing,
or deleting the pack cannot affect the active view.

## Cooking, reproducibility, and atomic release publication

The cooker validates the exact source closure, sidecars, type inventory,
profiles, catalogues, tools, and configuration. Runtime Package owns identity
and package policy; authoring tools create identities; cooking never does so.

For identical canonical sources, Resource Identity Metadata, catalogues,
profiles, toolchain, and configuration, the Pack Manifest, Payload, and Pack
Core Digest are byte-for-byte identical. A publication execution receives new
release, pack, and processing-record identities and records executor and date,
so envelopes, signatures, and complete files may differ. Reproducibility
compares both Pack Core Digests and exact recorded inputs rather than requiring
equal complete-file hashes across publication executions.

The cooker constructs Authority Pack, Client Pack, and processing record in one
private non-discoverable staging directory. It validates and closes both cores,
creates reciprocal envelopes, writes both signatures, makes all files durable,
and publishes one complete release entry through an adapter operation with
proved atomic semantics, preferably same-filesystem directory rename. The
commit point is visibility of that complete entry. Failure before it removes
only staging and leaves every published release unchanged. Runtimes never
create, mutate, or delete published packs; external deployment retains its
existing ownership of availability, capacity, retention, and removal.

Each runtime validates only its local pack. The authenticated envelope asserts
both pack identities and Pack Core Digests. Before Admission, Authority and
Client compare Runtime Content Release, Scenario, both pack identities, and
both Pack Core Digests. Exact equality proves selection of the same signed pair;
neither process reads or validates the other pack's bytes.

## Initial I/O and deferred optimization

The private version-one byte-source seam obtains the opened pack's stable size
and performs bounded operations equivalent to `read_exact_at` into caller-owned
storage. Tests may provide an in-memory byte source through the same contract.
There is no public filesystem path, VFS, URI, mount, listing, overlay,
precedence, extraction, direct I/O, memory mapping, or asynchronous API.

The initial adapter uses sequential synchronous buffered I/O. A numeric startup
limit is not invented by architecture. Measurements span process start through
runtime readiness and separate open/read, hashing, parsing, decoding,
materialization, GPU upload, and fence time; cold and warm p50, p95, p99, and
maximum are retained for applicable Reference Hardware and Reference Workload
Profiles.

Compression or asynchronous I/O requires an approved numerical startup
requirement and evidence that the synchronous version fails it. A successor
must demonstrate reproducible benefit on native Windows and Debian without
changing bytes, identities, canonical order, stable outcomes, capacity bounds,
or publication. If async is later admitted, every request has exactly one
terminal `Complete`, `Failed`, or `Cancelled` result, and cancellation cleanup
drains all completions and fences before reusing state. An experiment may and
legitimately can conclude that async is not adopted.

## Verification and adoption gates

Normative versioned golden and malformed fixtures cover UUID binary/text forms,
Resource Identity Metadata, path normalization and case collisions, header,
envelope, restricted CBOR, manifest, Ed25519 preimage and signature, Content
Signing Key Identity, Stored Extent digests, Pack Core Digest, and reciprocal
pair binding. Each fixture retains exact bytes, expected result, and stable
failure classification. Windows and Debian must produce and accept identical
bytes.

Every parser and type materializer is fuzzed from its first untrusted byte under
allocation, depth, and execution bounds. Required properties include:

- mutation of authenticated bytes fails;
- no failure publishes a handle;
- I/O or completion order never changes the result;
- required references resolve and cycles fail;
- cleanup returns attributable counters to the expected baseline;
- a handle outside its one published view is never accepted; and
- no content open or read occurs after runtime readiness.

A crash, hang, excessive allocation, platform-dependent result, stale handle,
partial publication, or sensitive diagnostic blocks admission. Signature,
malformed-input, capacity, filesystem-mutation, dependency, semantic-decoder,
GPU-fence, cleanup, and process-loss failures are injected at every phase.

Implementation proceeds through three accumulating gates:

1. version-one format, minimal cooker, synchronous loader, fake materializers,
   deterministic fixtures, fuzz targets, and complete failure injection;
2. representative real Authority and Client resources, one GPU path, memory
   accounting, role closure, and proof that the headless Authority closure has
   no client or source-import dependency; and
3. only after an approved target and synchronous failure, a comparative
   concurrency or asynchronous-I/O experiment preserving the common suite.

The third gate is not required to adopt async. No gate turns runtime facts into
verification `Pass`; the Verification Plan and approved evidence process retain
that disposition.

## Architecture Claim contribution

ARCHSPEC-0010 remains the canonical claim register. This specification governs
the following added claims there:

| Claim | Governing contract |
| --- | --- |
| `AC-RESOURCE-001` | Semantic Resource Identity, role-specific projection, and authoring metadata |
| `AC-RESOURCE-002` | Closed type inventory, local references, typed borrowed handles, and responsibility ownership |
| `AC-RESOURCE-003` | Exact deterministic version-one header, envelope, manifest, extent, and Pack Core format |
| `AC-RESOURCE-004` | Ed25519, SHA-256, key identity, scoped trust, and no algorithm negotiation |
| `AC-RESOURCE-005` | External limits, complete capacity reservation, and stable failure precedence |
| `AC-RESOURCE-006` | Authenticated local DAG, complete owner materialization, fences, and atomic publication |
| `AC-RESOURCE-007` | No pack dependency, I/O, mapping, reload, or generation replacement after publication |
| `AC-RESOURCE-008` | Reproducible Pack Cores and all-or-nothing paired release publication |
| `AC-RESOURCE-009` | Synchronous initial I/O and evidence-gated compression or async successors |
| `AC-RESOURCE-010` | Normative vectors, fuzzing, failure injection, dual-target determinism, and accumulating adoption gates |

All ten claims have state `Accepted / Included / Not Implemented / Blocked`.

## Open evidence and excluded decisions

The accepted architecture does not admit an implementation. Exact type schemas,
type-specific numerical limits, concrete Resource Identity Metadata property
names, fixed header widths, domain-separator bytes, numeric budget values,
startup thresholds, dependencies, and adapter APIs remain blocked until their
applicable controlled artifact or evidence closes them.

Compression, shared extents, deduplication, cyclic resource graphs, direct I/O,
memory mapping, VFS behavior, streaming, lazy materialization, hot reload,
generation replacement, eviction, content download, and in-process Scenario
change are excluded. Operational key protection, HSM or signing-service use,
published-release retention and capacity, and infrastructure cleanup remain
outside this decision under their already assigned future or external owners.

## Considered options and consequences

Path identity was rejected because moves, case, Unicode, and host filesystem
semantics are not stable authorial meaning. Content hashes were rejected as
Resource Identities because compatible edits change bytes. Runtime-generated
identity was rejected because it cannot preserve references or deterministic
cooking.

A universal ResourceManager, shared ownership, per-consumer refcount, and one
generic content blob were rejected because they erase semantic ownership,
strand capacity, and couple unrelated materializers. Public VFS, logical URI,
generation, and streaming promises were rejected because the accepted process
has one explicit pack and one immutable activation.

Protobuf was rejected for canonical manifest bytes. Generic CBOR maps and open
values were rejected because duplicate keys, ordering, and expanded decoder
surface add no version-one value. A fully bespoke manifest was rejected because
the restricted RFC encoding supplies a reviewed deterministic primitive while
the Sacramento profile retains a closed schema.

Whole-file-only hashing prevents bounded per-resource validation. Merkle trees
and fixed remote chunks add complexity without streaming or random remote
access. Recursive complete-file reciprocal hashes are impossible; signed Pack
Envelopes binding two precomputed non-circular Pack Core Digests preserve the
required pair relation.

ECDSA and algorithm negotiation were rejected for version one in favor of one
deterministic fixed-width Ed25519 scheme. The algorithm decision does not
approve a library. Compression and async-first I/O were rejected because no
approved startup target or representative evidence currently justifies their
capacity, scheduling, cleanup, dependency, and attack surface.

## Trace

This specification principally satisfies `REQ-CONTENT-PROCESSING-GATE-001`,
`REQ-CONTENT-PROCESSING-RECORD-001`, `REQ-CONTENT-PROCESSING-001`,
`REQ-CONTENT-TRACEABILITY-001`, `REQ-CONTENT-PROCESSING-ADMISSION-001`,
`REQ-CONTENT-RELEASE-001`, `REQ-CONTENT-PACK-ROLE-001`,
`REQ-CONTENT-PAIR-001`, `REQ-CONTENT-PAIR-ATOMIC-001`,
`REQ-CONTENT-SIGNING-001`, `REQ-CONTENT-TRUST-001`,
`REQ-CONTENT-COMPATIBILITY-001`, `CONSTRAINT-CONTENT-DISTRIBUTION-001`,
`REQ-CONTENT-IDENTITY-001`, `REQ-CONTENT-MISMATCH-001`,
`REQ-CONTENT-VERSION-001`, `REQ-CONTENT-VERSION-002`,
`REQ-CONTENT-STARTUP-001`, `REQ-CONTENT-ACTIVATION-001`,
`REQ-CONTENT-IMMUTABILITY-001`, `REQ-CONTENT-ROLLBACK-001`,
`REQ-CONTENT-RETENTION-001`, `REQ-RUNTIME-LAUNCH-SPECIFICATION-002`,
`REQ-RUNTIME-READINESS-001`, `REQ-RUNTIME-EXTERNAL-LIFECYCLE-001`,
`PROCESS-ARCHITECTURE-CONTRACT-001`,
`PROCESS-ARCHITECTURE-VERIFICATION-001`,
`PROCESS-ARCHITECTURE-EXECUTABLE-001`, and
`PREFERENCE-PLATFORM-PARITY-001`.
