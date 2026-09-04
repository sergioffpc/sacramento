# Game Engine Filesystem Resource Management

Research date: 2026-09-04

Status: Non-canonical research. This document presents principles, alternatives,
and a candidate recommendation; it does not change approved requirements,
Architecture Claims, ADRs, interfaces, formats, cryptographic algorithms,
dependencies, or baselines. Where it conflicts with a canonical source identified
by [Domain Documentation](../agents/domain.md), that source is authoritative.

Outcome: Project-owner review promoted the resulting decisions to
[ADR-0012](../adr/0012-establish-runtime-resource-and-role-pack-architecture.md),
the [runtime-resource architecture
specification](../architecture/0012-runtime-resource-and-role-pack-architecture.md),
and the candidate [Runtime Resource Type
Inventory](../architecture/training-simulation-runtime-resource-type-inventory.md).
Those controlled sources supersede every candidate recommendation here; this
document remains retained historical input.

## Table of contents

- [Executive recommendation](#executive-recommendation)
- [Sacramento boundary](#sacramento-boundary)
- [Core principles](#core-principles)
- [Names, paths, and a narrow virtual filesystem](#names-paths-and-a-narrow-virtual-filesystem)
- [Synchronous and asynchronous I/O](#synchronous-and-asynchronous-io)
- [Runtime resource pipeline](#runtime-resource-pipeline)
- [File, directory, and pack organization](#file-directory-and-pack-organization)
- [Identity: GUID, hash, and version](#identity-guid-hash-and-version)
- [Lifetime and memory management](#lifetime-and-memory-management)
- [Integrity, signing, and key rotation](#integrity-signing-and-key-rotation)
- [Candidate Sacramento blueprint](#candidate-sacramento-blueprint)
- [Options and trade-offs](#options-and-trade-offs)
- [Verification and incremental adoption](#verification-and-incremental-adoption)
- [Risks and open questions](#risks-and-open-questions)
- [Primary sources](#primary-sources)

## Executive recommendation

An efficient and correct engine should neither expose `std::filesystem::path` to
all modules nor centralize domain behavior in an omniscient `ResourceManager`.
It should separate five concepts:

1. a stable **logical identity** that does not change with a file name or directory;
2. an **immutable catalogue/manifest** that resolves identity to type,
   dependencies, integrity data, and physical location;
3. a private, replaceable **storage adapter and I/O scheduler**;
4. type-specific materializers that validate and transform bytes into
   Sacramento-owned representations; and
5. typed handles into a published immutable view with explicit ownership,
   generation, lifetime, and release fences.

Mature engines implement variants of this separation. Unity stores an asset GUID
in a `.meta` sidecar so moves and renames preserve references
([Unity Asset Metadata](https://docs.unity3d.com/Manual/AssetMetadata.html)); Godot
resolves `uid://` identities to current paths
([Godot `ResourceUID`](https://docs.godotengine.org/en/stable/classes/class_resourceuid.html));
and O3DE combines a source UUID and sub-ID into the Asset ID of a processed product
([O3DE Product Assets](https://docs.o3de.org/docs/user-guide/assets/pipeline/product-assets/)).
These are evidence for identity/location separation, not reasons to copy any one
engine's model.

For Sacramento, the candidate should be narrower:

- the Content Cooker assigns and validates identities, closes the dependency graph,
  and produces both role packs with a manifest for each pack;
- a runtime receives exactly one physical role-pack path in its Runtime Launch
  Specification, and `Runtime Package` opens it through a private adapter;
- `Content Admission` validates the pack and builds a complete candidate generation,
  initially with sequential I/O and, only if justified, bounded concurrent I/O;
- the runtime atomically publishes an immutable view only after all validation,
  capacity reservation, materialization, linking, and GPU upload fences succeed;
- after `Ready`, consumers use only `ResourceId` values and typed handles into that
  view: they do not scan directories, reread packs, stream, replace generations, or
  evict active Runtime Content Release resources; and
- read/decompression staging belongs to `Startup Validation`; materialized CPU
  resources belong to their exact Memory Accounting Owners in `Process Lifetime`;
  GPU resources remain owned by `Presentation` and are reclaimed only after their
  applicable fence.

Asynchronous I/O is therefore a measurable startup optimization, not a domain API
property. A first synchronous implementation entirely before `Ready` is the
smallest valid baseline. An asynchronous implementation is justified only by
representative native evidence and must preserve identical identity, failure,
capacity, cancellation, memory-attribution, and publication semantics.

## Sacramento boundary

Canonical meaning comes from the [Technical Glossary](../glossary/technical.md),
[ADR-0007](../adr/0007-use-signed-scenario-bound-runtime-content-releases.md),
the [Runtime Content Release specification](../architecture/0007-runtime-content-releases.md),
[ADR-0010](../adr/0010-close-cross-cutting-architecture-and-verification.md),
the [cross-cutting architecture](../architecture/0010-cross-cutting-architecture-and-verification.md),
[ADR-0011](../adr/0011-establish-memory-accounting-and-allocation-boundaries.md),
and the [memory architecture](../architecture/0011-memory-accounting-and-allocation.md).
The prior [memory allocation and tracking research](game-engine-memory-allocation-and-tracking.md)
is historical input, not another decision.

Those accepted sources already require:

- one immutable signed Runtime Content Release for each exact Scenario version,
  containing reciprocally bound Authority and Client Packs;
- one explicit role-pack path and independent Content Signing Trust Reference as
  immutable launch configuration, with no directory discovery, newest-version
  selection, negotiation, or fallback;
- ownership of pack codec, identity, and the private filesystem adapter by
  `Runtime Package`, without source or vendor representations crossing its seam;
- complete validation and materialization by `Content Admission` before one
  immutable view is published and before `Ready`;
- no pack reread, polling, streaming, patching, or replacement after activation;
- consumption of Sacramento-owned views by `Simulation`, `Prediction`, and
  `Presentation`, without pack parsing, signature verification, or content I/O;
- resource meaning and lifetime owned by the applicable responsibility module,
  with composition coordinating order rather than becoming a generic manager;
- independent memory dimensions for owner, Memory Lifetime Domain, memory resource,
  and budget identity, propagated explicitly through asynchronous work; and
- no general-purpose heap access, backing-storage growth, or hidden fallback from a
  Measured Real-Time Hot Loop after `Ready`.

Consequently, hot reload, runtime download, live patching, content streaming,
directory scanning, an evictable active-view cache, and in-process Scenario changes
are not implementation choices for this baseline. Manifest schema, binary layout,
hash and signature algorithms, extension, source-tree layout, concrete C++ API,
internal ID policy, block granularity, compression, and I/O mechanism remain design
decisions.

## Core principles

### Separate identity, location, content, and live instance

A resource needs four distinct names:

- **logical identity**: stable key used by references and the dependency graph;
- **physical location**: pack, offset, sizes, codec, and alignment used privately;
- **content identity**: digest of the exact bytes whose integrity is checked; and
- **live-instance identity**: handle and generation valid only in one execution.

Conflating them creates predictable defects. Paths break on moves; hashes change on
every edit and are unsuitable as authorial identity; pointers do not persist across
executions; and GUID uniqueness proves neither integrity nor authenticity. RFC 9562
defines UUIDs as 128-bit values, recommends treating them as opaque, and warns that
uniqueness does not imply unpredictability
([RFC 9562](https://www.rfc-editor.org/rfc/rfc9562.html)). Unity similarly persists
an asset GUID plus an internal `fileID`, then resolves it to an execution-local
`InstanceID`
([Unity direct references](https://docs.unity3d.com/Manual/assets-direct-reference.html)).

### Separate source assets, processed products, and runtime views

The pipeline should be one-way:

```text
canonical sources + sidecars + import configuration
                         |
                         v
               Content Cooker validation
                         |
                         v
         reproducible, disposable intermediate products
                         |
                         v
       Authority Pack + Client Pack + processing record
                         |
                         v
            runtime validation and materialization
                         |
                         v
             typed immutable Sacramento view
```

Godot keeps imported products separate and directs users through `ResourceLoader`
because direct access may work in the editor but fail in exports
([Godot import process](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/import_process.html)).
O3DE likewise separates source assets, Asset Builders, product assets, and Asset
Cache ([O3DE Asset Pipeline](https://docs.o3de.org/docs/user-guide/assets/pipeline/)).
For Sacramento, authoring formats and directories should remain outside the runtime
contract, while derived products remain reproducible and disposable.

### Validate before publication

Reading, hashing, decompression, CPU construction, GPU upload, and dependency linking
form one startup transaction. Candidate references never escape. Only the root of a
completely validated generation is published. Failure prevents publication, cancels
pending work, drains all completions and fences, destroys the candidate in reverse
dependency order, and produces a stable Sacramento startup result.

This is consistent with secure distribution workflows that expose a target only
after metadata, length, and hash checks
([TUF client workflow](https://theupdateframework.github.io/specification/v1.0.28/)).

### Measure efficiency end to end

Fewer syscalls do not necessarily mean less time to `Ready`. Measure read time,
page faults, hashing, decompression, parsing, construction, GPU upload/fence time,
and peak memory. DirectStorage recommends batched requests and one notification
after all blocks for an asset, while sizing staging from actual requests
([DirectStorage guidance](https://github.com/microsoft/DirectStorage/blob/main/Docs/DeveloperGuidance.md)).
This supports batching as a candidate, not a Windows-only dependency assumption.

## Names, paths, and a narrow virtual filesystem

Product modules should not accept native paths. Candidate semantic types are:

```cpp
struct ResourceId;          // opaque persistent logical identity
struct ResourceTypeId;      // closed versioned runtime type
struct ResourceGeneration;  // identity of this activated view
struct ResourceHandleBase;  // ResourceId + type + generation + slot

// Private to Runtime Package and Content Admission:
struct PackPath;
struct PackEntryLocation;   // offset, sizes, codec, alignment
struct IoRequest;
```

A logical URI such as `sac-resource:<id>` may help tooling and diagnostics, but it
must not behave like a path or enable implicit mounts. Normal lookup is
`ResourceId -> authenticated manifest entry -> PackEntryLocation`. Source paths
belong only in processing records and governed diagnostics.

The C++ filesystem model distinguishes generic and native path formats and gives
lexical and canonical operations different semantics
([C++ working draft](https://eel.is/c++draft/filesystems)). Windows has its own
namespaces, separators, reserved names, length behavior, and case rules; software
must not assume case sensitivity
([Microsoft file naming](https://learn.microsoft.com/en-us/windows/win32/fileio/naming-a-file)).

The Content Cooker should define one cross-platform policy that:

- converts logical separators to `/` and rejects absolute, drive, UNC, empty, `.`,
  `..`, and NUL components;
- chooses one Unicode normalization and rejects multiple spellings of one key;
- applies a locale-independent project case policy and detects collisions even on a
  case-sensitive authoring host;
- bounds total and component lengths before allocation or copying;
- prevents symlinks from escaping admitted canonical-source roots; and
- rejects path and ID collisions before cooking, naming both origins diagnostically.

Godot documents that case-only differences can work on one host and fail on another
([Godot filesystem](https://docs.godotengine.org/en/stable/tutorials/scripting/filesystem.html)).
For untrusted inputs, canonicalization must be followed by an authorized-root check;
raw input in filesystem operations permits traversal
([MITRE MID-075](https://emb3d.mitre.org/mitigations/MID-075.html)).

Sacramento should not extract pack entries to manifest-chosen filesystem paths.
It should validate offsets arithmetically against the pack size and read into owned
memory, eliminating traversal, output-name collision, and extracted-file TOCTOU from
the normal runtime surface.

A virtual-location layer may unify one file, memory-backed tests, and a future
backend, but it should remain private to `Runtime Package`, with explicit immutable
mounts and no listing or precedence. Godot can mount PCK/ZIP files with later packs
overriding earlier paths
([Godot PCK export](https://docs.godotengine.org/en/stable/tutorials/export/exporting_pcks.html));
that overlay behavior is intentionally incompatible with Sacramento's one explicit,
immutable activation.

## Synchronous and asynchronous I/O

| Phase | Candidate policy | Reason |
| --- | --- | --- |
| Content Cooker | Async or bounded blocking pool; graph batching and sequential output | Offline throughput and determinism matter more than frame latency |
| Startup, first increment | Sequential synchronous read behind the common seam | Smallest correct implementation and measurable baseline |
| Startup, after evidence | Bounded async ranges, coalescing, and critical-path priority | Overlap read, verification, decode, and upload without unbounded memory |
| After `Ready` | No Runtime Content Release I/O | Required by ADR-0007/ARCHSPEC-0007 |
| Evidence/Observability | Separate existing asynchronous contracts | Do not mix immutable content with retained export |

On Windows, synchronous I/O waits; overlapped I/O requires the buffer and
`OVERLAPPED` state to survive until completion. Immediate completion can still be
followed by a completion packet, so dual-path cleanup is unsafe
([Microsoft sync/async I/O](https://learn.microsoft.com/en-us/windows/win32/fileio/synchronous-and-asynchronous-i-o)).
I/O completion ports suit many concurrent operations; synchronous or simple
overlapped I/O can be better for low volume
([Microsoft IOCP](https://learn.microsoft.com/en-us/windows/win32/fileio/i-o-completion-ports)).

“Always async” is therefore incorrect. Async adds queues, states, wakeups, concurrent
buffers, and cleanup complexity; sync risks blocking the wrong thread. The choice
depends on phase, volume, latency tolerance, memory bounds, and evidence. Godot also
documents that retrieving a threaded resource before terminal status blocks the
caller, while subthreads can affect the main thread
([Godot `ResourceLoader`](https://docs.godotengine.org/en/stable/classes/class_resourceloader.html)).

A candidate asynchronous request carries a validated location, owned destination,
Memory Resource Context, closed priority, startup cancellation token, and correlation
identity. Its terminal result is exactly `Complete`, `Failed`, or `Cancelled`;
“cancel requested” is not terminal. `CancelIoEx` does not guarantee cancellation
before completion, so request state cannot be reused early
([Microsoft `CancelIoEx`](https://learn.microsoft.com/en-us/windows/win32/fileio/cancelioex-func)).

Required invariants are:

- every request has exactly one observable terminal completion;
- buffer, request state, pack handle, and Memory Resource Context survive until it;
- cancellation prevents publication but cleanup drains all completions;
- completion order never defines canonical ordering or layout;
- request count and bytes in flight obey hard Memory Budget Configuration bounds;
- callbacks never publish individual resources or invoke consumers;
- native errors map once to stable, non-sensitive Sacramento outcomes; and
- tests cover immediate, late, partial, reordered, cancelled, and post-peer-failure
  completions.

I/O, verification/decompression, CPU materialization, and GPU upload are separate
bounded stages. Backpressure prevents a faster stage from exhausting the next one.

## Runtime resource pipeline

Each role pack needs one deterministic, authenticated, complete manifest. A candidate
entry records `ResourceId`, `ResourceTypeId`, type-schema version, offset, stored and
decoded sizes, alignment, codec, stored digest, dependencies, materialization owner,
Memory Lifetime Domain, and budget class. The pack-level envelope binds release,
Scenario, role, runtime content contract, counterpart, manifest, and processing
record identities.

Before payload work, validation rejects duplicate IDs, unknown types/codecs/schemas,
integer overflow, out-of-pack or overlapping ranges, decoded-size excess, missing
dependencies, incomplete role closure, and cycles forbidden by a materializer. A
strongly connected component is admissible only when its type contract defines a
bounded two-phase construction that exposes nothing before final linking.

Candidate internal states are:

```text
Declared -> Located -> Reading -> Bytes Verified -> Decoded
         -> Materialized -> Linked -> Candidate Complete -> Published
                    \-> Failed / Cancelled
```

Only `Published` is visible to consumers. A typed handle contains logical identity,
expected type, generation, and slot/index; lookup validates them without I/O,
allocation, global locking, fallback, or vendor exposure. Unreal's Asset Manager and
async Primary Asset loading illustrate stable asset identity and load grouping
([Epic Asset Management](https://dev.epicgames.com/documentation/en-us/unreal-engine/asset-management-in-unreal-engine),
[Epic `LoadPrimaryAssets`](https://dev.epicgames.com/documentation/en-us/unreal-engine/API/Runtime/Engine/UAssetManager/LoadPrimaryAssets)).

The candidate registry owns temporary graph state and partially built resources.
Publication swaps exactly one immutable root only after every required resource,
dependency, reservation, and fence succeeds. A failure publishes nothing, cleans the
candidate, reports `Not Ready`, and exits non-zero. Sacramento's one-Scenario,
one-Training-Session process makes this eager generation model simpler and safer than
independent dynamic resource publication.

## File, directory, and pack organization

Organize by ownership and reproducibility rather than by runtime lookup path:

```text
authoring/
  sources/             canonical source assets
  metadata/            stable IDs and import settings
derived/
  cache/               disposable keyed importer outputs
  staging/             private incomplete cook candidates
published/
  releases/<release>/  immutable Authority and Client Packs
evidence/
  processing-records/  provenance and source-to-output mapping
```

This is a conceptual split, not a required repository layout. Canonical sources and
identity metadata are reviewed; caches are rebuildable and never referenced by
runtime content; staging candidates are private and deleted on failure; published
packs are never overwritten; processing evidence remains outside runtime packs; and
external deployment, not a runtime, owns retention and removal.

Within a pack, order bytes using measured role closure, critical materialization path,
access affinity, alignment, compression behavior, and bounded decode windows. Fewer
external packs reduce opens, metadata work, and partial-deployment risk; internal
blocks preserve parallelism and per-region integrity. DirectStorage's BulkLoadDemo
shows batched reads with a final completion notification
([BulkLoadDemo](https://github.com/microsoft/DirectStorage/blob/main/Samples/BulkLoadDemo/README.md)).
Unreal cooking packages content into Pak/IoStore and can assign packages to chunks
([Epic cooking reference](https://dev.epicgames.com/documentation/en-us/unreal-engine/cplusplus-cooking-development-reference)).
Sacramento already fixes the two role packs as external units; block granularity
inside them remains a measurement-driven design choice.

## Identity: GUID, hash, and version

A candidate source policy assigns an opaque UUIDv4 once and preserves it in controlled
metadata through moves and renames. Duplication intentionally creates a new ID;
copied sidecars that collide fail the cook. Merge tooling must make duplicate IDs
visible. UUIDs are stored canonically as 16 bytes; text is a display/authoring form.
UUIDv4 is simple and does not leak timestamps or topology, but collision checking is
still required; RFC 9562 does not make UUIDs integrity or authorization credentials.

For imported resources with addressable internals, `{ResourceId, SubresourceId}` is
usually preferable to globally minting an unrelated GUID for every node. The
sub-resource key must be deterministic and semantically stable rather than an array
index. O3DE's source UUID plus product sub-ID is relevant prior art
([O3DE Product Assets](https://docs.o3de.org/docs/user-guide/assets/pipeline/product-assets/)).

Content digests change when bytes change and support integrity checking, cache keys,
deduplication, and reproducibility comparison. They do not replace stable logical
identity or signatures. NIST defines the SHA family as algorithms for producing
digests used to detect message changes
([FIPS 180-4](https://csrc.nist.gov/pubs/fips/180-4/upd1/final)).

| Identity | Changes when | Purpose |
| --- | --- | --- |
| `ResourceId` | Explicit identity replacement | Stable authorial reference |
| sub-resource key | Incompatible semantic internal structure | Stable reference inside a resource |
| content digest | Exact covered bytes change | Integrity and cache identity |
| type/schema version | Interpretation contract changes | Decoder compatibility |
| role-pack identity/hash | Any relevant byte or binding changes | Exact pack validation |
| Runtime Content Release identity | Any normative input, provenance, or pack changes | Common pair identity |
| generation | Every process activation | Reject stale live handles |

## Lifetime and memory management

Bytes and objects must have explicit owners:

- compressed read buffers and decode scratch belong to the operation/materializer in
  `Startup Validation`;
- registry metadata genuinely owned by `Runtime Package` or `Content Admission` is
  charged there;
- materialized Sacramento objects are charged to the responsibility module that owns
  their semantics in `Process Lifetime`;
- GPU objects, descriptor allocations, upload staging, and deferred frees belong to
  `Presentation`, even when their immutable source is content; and
- every task, callback, and continuation carries its Memory Resource Context.

Stored, decoded, staging, CPU-object, and GPU sizes remain separate quantities.
Physical deduplication has one owner; consumers do not receive duplicate accounting.

For this baseline, the immutable-view root strongly owns the whole generation.
Consumer handles are borrowed and do not alter lifetime. This avoids refcount cycles,
nondeterministic unloading, eviction, and use-after-eviction. Unity Addressables
shows the trade-off of a dynamic refcount model: loads increment and releases
decrement, but zero only makes an asset unloadable and bundle memory may remain
([Unity Addressables memory](https://docs.unity3d.com/Packages/com.unity.addressables@1.21/manual/MemoryManagement.html)).
That complexity is unnecessary for one Sacramento Scenario and Training Session.

Startup-failure cleanup should:

1. prevent publication and request cancellation;
2. drain I/O and job completions while preserving their buffers;
3. wait for GPU fences that may touch staging or resources;
4. destroy linked/materialized objects in reverse dependency order;
5. release staging and the candidate registry; and
6. close file/device handles and publish the terminal startup outcome.

Normal shutdown stops consumers first, destroys resources in reverse dependency
order, and releases the generation/registry last. A bulk reset occurs only after no
task, I/O request, or GPU command can still refer to that lifetime.

The manifest allows startup to calculate stored, decoded, object, descriptor, and GPU
bounds. A materialization plan declares its maximum concurrent window rather than
blindly summing all transient peaks. Backpressure is byte-based as well as job-based.
Unavailable required capacity produces `Not Ready`, complete cleanup, and non-zero
exit; it never enables lower quality, lazy loading, or predecessor fallback.

## Integrity, signing, and key rotation

A hash detects a difference only when the expected digest is already trusted. An
attacker replacing both pack and manifest can recalculate hashes. A digital signature
authenticates a signer and detects modification, which is the purpose defined by the
Digital Signature Standard
([FIPS 186-5](https://csrc.nist.gov/pubs/fips/186-5/final)). Therefore:

- hashes cover individual regions and enable bounded/incremental verification;
- the signature authenticates the manifest containing hashes, sizes, IDs, roles,
  contracts, bindings, schemas, and dependencies;
- the independent Content Signing Trust Reference defines which key may sign the
  exact role and runtime content contract; and
- a non-cryptographic checksum may detect accidental internal error but never makes
  a Content Admission decision.

A robust envelope has a bounded fixed header, deterministic manifest, payload blocks,
and a signature over an unambiguous representation linking the header, manifest, and
all digests. Treat all input as hostile until validation:

1. open only the explicit path and obtain a stable file size;
2. parse the bounded header and reject bad magic, exact version, sizes, or overflow;
3. read a bounded manifest and validate only the minimum structural encoding;
4. select the exact trust entry by key identity, role, and runtime content contract;
5. verify the signature before treating manifest fields as authority;
6. validate release/Scenario/role/counterpart identities and pair bindings;
7. bound each read to an authenticated range, verify its digest before decoding, and
   enforce decoded-size and capacity limits;
8. validate schema, dependencies, and semantics and materialize the generation; and
9. publish only after complete success.

“Verify before parsing” cannot literally apply to locating an embedded signature.
The correct rule is minimal, bounded, memory-safe structural parsing before
authentication and no action based on unauthenticated fields.

ADR-0007 already fixes rotation semantics: trust-reference changes affect new starts;
an active process keeps its validated immutable view; a removed key cannot start a
new process; and compromise requires a new trust reference plus new releases. A
rotation window may authorize old and new keys, each still scoped by role/contract,
then remove the old key. This is not negotiation and a pack never supplies its own
root. TUF is useful prior art for role separation, size/hash binding, versions, and
rollback/mix-and-match resistance
([TUF specification](https://theupdateframework.github.io/specification/v1.0.28/)),
but it is not a proposed dependency.

## Candidate Sacramento blueprint

| Layer | Input | Responsibility | Output/lifetime | Main invariant |
| --- | --- | --- | --- | --- |
| Logical reference | ID and expected type | Refer without paths | Serializable value | Stable across move/rename; proves no integrity |
| Catalogue/manifest | Signed role-pack manifest | Close types, graph, sizes, hashes, budgets | Immutable startup entries | Every ID/dependency resolved; complete role closure |
| Physical location | Authenticated entry | Translate ID to validated range/codec | Private `PackEntryLocation` | No scan; overflow-safe; inside pack |
| I/O scheduler | Locations, contexts, bounds | Read/coalesce/prioritize/cancel with backpressure | Owned `Startup Validation` buffers | One completion; bounded bytes; no semantic ordering |
| Verifier/decoder | Bytes and authenticated entry | Hash, decompress, schema, bounds | Validated intermediate | Verify before interpretation; bounded expansion |
| Materializer | Intermediate, dependencies, memory context | Build Sacramento CPU/GPU objects | Candidate resources | Explicit owner/lifetime; no vendor type escapes |
| Candidate registry | Linked resources and generation | Close graph and fences | Candidate root | Invisible to consumers |
| Publication | Complete root | Single commit before `Ready` | Immutable `Process Lifetime` view | Zero or one generation; no reload/unload/streaming |
| Runtime lookup | Typed handle | Resolve in active generation | Borrowed `ResourceView<T>` | No I/O, allocation, global lock, or fallback |
| Shutdown | Root and dependency order | Stop, fence, destroy | Released resources | Reverse order; generation last |

```text
ResourceId / logical URI
          |
          v
signed closed manifest ----> graph, budgets, hashes
          |
          v
private PackEntryLocation
          |
          v
bounded I/O -> verification -> decode -> CPU/GPU materialization
                                                |
                                                v
                                      candidate registry
                                                |
                                   complete validation + fences
                                                |
                                                v
                                  atomic immutable publication
                                                |
                                                v
                                   typed filesystem-free handles
```

A small seam may expose operations conceptually equivalent to `open_exact_pack`,
`read_ranges`, `materialize_candidate`, `publish`, and `lookup<T>`. It need not
promise future streaming.

## Options and trade-offs

| Decision | Simple option | Sophisticated option | Sacramento candidate |
| --- | --- | --- | --- |
| Logical ID | UUIDv4 sidecar | Hierarchical/content-addressed ID | Opaque UUIDv4 plus sub-resource key; separate hash |
| Reference | Logical path | ID plus catalogue | ID in content; paths only in tooling/diagnostics |
| Startup I/O | Sequential sync | Native async, coalescing, pipeline | Start sync; adopt bounded async only with evidence |
| Backend | One file | VFS and multiple mounts | Narrow adapter for one explicit role pack |
| Layout | Loose files | Indexed/compressed pack | One pack per role with measured internal blocks |
| Loading | Lazy/on-demand | Eager parallel | Complete eager load before `Ready` |
| Lifetime | Per-asset refcount | Generation/arena plus fences | Root owns the generation until shutdown |
| Cache | Evictable LRU | Resident view | No active-content runtime cache; separate tooling cache |
| Dependencies | Resolve by attempts | Closed graph | Authenticated graph materialized before commit |
| Integrity | Checksum/whole-file hash | Region digests plus manifest signature | Scoped signature, region hashes, pack/pair binding |
| GPU upload | First use | Startup staging and fences | Required uploads complete before publication |

Many small async reads may use modern queues well but increase staging peaks and
state complexity. Large packs improve sequentiality and atomicity but may increase
distribution/retention cost for small changes. Compression trades I/O and disk for
CPU/GPU decode, staging, and worst-case expansion. Content addressing improves reuse
but changes identity on edits and does not replace authorial meaning. Evaluate every
choice with representative role packs on both native targets.

## Verification and incremental adoption

### Increment 1 — contract and synchronous loader

- fix path, Unicode, case, UUID, manifest, hash, and signature test vectors;
- cook one minimal real closure into both role packs;
- implement a synchronous file adapter, bounded parser, integrity/signature seam,
  fake materializers, and atomic publication;
- inject missing/truncated input, overflow, overlap, duplicate ID, missing dependency,
  cycle, wrong type/schema/role/contract, corrupt block, invalid signature,
  unauthorized signer, broken pair, and exhaustion; and
- prove leak-free cleanup, zero-or-one publication, and zero opens/reads after `Ready`.

### Increment 2 — representative resources and memory

- use real `Simulation`, `Prediction`, and `Presentation` resources, including one
  GPU upload and proof of headless closure;
- measure stored, decoded, staging, object, GPU, private-commit, resident, and
  per-owner/lifetime/resource peaks plus time for every stage;
- derive in-flight capacity and Memory Budget Configuration from evidence; and
- prove source importers, source formats, and client-only dependencies are absent
  from the Authority Pack and executable closure.

### Increment 3 — concurrency only when justified

- preserve the synchronous contract suite as the common behavioral oracle;
- compare sync, bounded blocking workers, and native async behind one seam;
- measure cold/warm p50, p95, p99, maximum, CPU, queue depth, in-flight bytes, peak
  memory, and applicable storage profiles;
- vary block size and concurrency and check that throughput does not hide worse tails;
- test immediate, late, reordered, and cancelled completion under sanitizers; and
- adopt only reproducible benefit on native Windows and Debian without changing
  results, identities, failure boundaries, or portability obligations.

Fuzz every parser and decoder from the first untrusted byte under allocation and
decoded-size limits, without filesystem extraction. Useful properties include: any
authenticated-bit mutation fails; completion order does not affect the view; failure
before commit exposes no handle; identical admitted cook inputs/tool identities
produce the defined deterministic output; and a handle from another generation is
always rejected.

Evidence must correlate Application Release, Runtime Launch Specification, Runtime
Content Release, role pack/hash, trust reference, Memory Budget Configuration,
platform, and workload. Runtime hooks report facts and never assign `Pass`.

## Risks and open questions

1. Which canonical manifest encoding gives bounded parsing, deterministic bytes,
   exact-version rejection, and adequate tooling?
2. Which hash, signature, key-identity scheme, and qualified crypto library meet the
   project need? Architecture has not selected them.
3. Should integrity use a digest per resource, per block, or a tree?
4. Who creates, preserves, duplicates, and repairs GUID metadata, and how do merge
   workflows reject duplicates?
5. Which exact Unicode normalization and case-folding policy applies on Windows and
   Debian?
6. Which resource types require persistent internal identities, and when does an edit
   preserve or replace one?
7. Which cycles are legitimate, and which materializers can build them in two phases
   without exposing partial objects?
8. Which block sizes, alignment, and compression minimize time to `Ready` without an
   excessive `Startup Validation` peak?
9. Is there an approved startup target that can justify asynchronous complexity?
10. Does “completely materialized” require touching all CPU pages and completing all
    GPU uploads, or can some resident representations remain pageable?
11. Can a memory mapping remain after `Ready` while still proving that replacement or
    deletion of the backing file cannot affect the active process?
12. Who provisions, protects, rotates, and revokes the signing key and trust reference?
13. What external deployment policy governs retention, disk capacity, and cleanup?
14. How will every image, audio, and geometry decoder bound hostile input and expose
    stable failures?

These gaps remain visible until requirements, design, and evidence close them. This
research does not authorize a concrete implementation or dependency.

## Primary sources

### Standards and security

- [RFC 9562 — Universally Unique IDentifiers](https://www.rfc-editor.org/rfc/rfc9562.html)
- [C++ working draft — Filesystems](https://eel.is/c++draft/filesystems)
- [NIST FIPS 180-4 — Secure Hash Standard](https://csrc.nist.gov/pubs/fips/180-4/upd1/final)
- [NIST FIPS 186-5 — Digital Signature Standard](https://csrc.nist.gov/pubs/fips/186-5/final)
- [The Update Framework Specification 1.0.28](https://theupdateframework.github.io/specification/v1.0.28/)
- [MITRE EMB3D MID-075 — Avoid Path Traversal](https://emb3d.mitre.org/mitigations/MID-075.html)

### Operating systems and I/O

- [Microsoft — Naming Files, Paths, and Namespaces](https://learn.microsoft.com/en-us/windows/win32/fileio/naming-a-file)
- [Microsoft — Synchronous and Asynchronous I/O](https://learn.microsoft.com/en-us/windows/win32/fileio/synchronous-and-asynchronous-i-o)
- [Microsoft — I/O Completion Ports](https://learn.microsoft.com/en-us/windows/win32/fileio/i-o-completion-ports)
- [Microsoft — `CancelIoEx`](https://learn.microsoft.com/en-us/windows/win32/fileio/cancelioex-func)
- [Microsoft DirectStorage — Developer Guidance](https://github.com/microsoft/DirectStorage/blob/main/Docs/DeveloperGuidance.md)
- [Microsoft DirectStorage — BulkLoadDemo](https://github.com/microsoft/DirectStorage/blob/main/Samples/BulkLoadDemo/README.md)

### Engines and pipelines

- [Unity — Asset Metadata](https://docs.unity3d.com/Manual/AssetMetadata.html)
- [Unity — Direct reference asset management](https://docs.unity3d.com/Manual/assets-direct-reference.html)
- [Unity Addressables — Memory Management](https://docs.unity3d.com/Packages/com.unity.addressables@1.21/manual/MemoryManagement.html)
- [Godot — `ResourceUID`](https://docs.godotengine.org/en/stable/classes/class_resourceuid.html)
- [Godot — `ResourceLoader`](https://docs.godotengine.org/en/stable/classes/class_resourceloader.html)
- [Godot — Import process](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/import_process.html)
- [Godot — File system](https://docs.godotengine.org/en/stable/tutorials/scripting/filesystem.html)
- [Godot — Exporting packs, patches, and mods](https://docs.godotengine.org/en/stable/tutorials/export/exporting_pcks.html)
- [O3DE — Asset Pipeline](https://docs.o3de.org/docs/user-guide/assets/pipeline/)
- [O3DE — Product Assets](https://docs.o3de.org/docs/user-guide/assets/pipeline/product-assets/)
- [Epic — Asset Management](https://dev.epicgames.com/documentation/en-us/unreal-engine/asset-management-in-unreal-engine)
- [Epic — `UAssetManager::LoadPrimaryAssets`](https://dev.epicgames.com/documentation/en-us/unreal-engine/API/Runtime/Engine/UAssetManager/LoadPrimaryAssets)
- [Epic — C++ Cooking Development Reference](https://dev.epicgames.com/documentation/en-us/unreal-engine/cplusplus-cooking-development-reference)
