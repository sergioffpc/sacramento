# SDD-0004: Content Cooker Tool

Status: Candidate successor design; project-owner approval pending

Last meaningful change: 2026-09-04

Purpose: Define the exact finite offline tool that cooks one immutable authoring
closure into one atomically published Runtime Content Release.

Scope: CLI, deterministic-CBOR job and result codecs, source snapshot,
workflow, publisher, retry, signing, provenance, cleanup, and acceptance.

Intended readers: Content-pipeline designers, implementers, verification
authors, release operators, and security reviewers.

Required reviewers: Content-design reviewer and verification-design reviewer.

Prerequisites: SDB-002, SAD-003, ADR-0013, ARCHSPEC-0007, ARCHSPEC-0012,
ARCHSPEC-0013, and requirements traced by `DC-COOKER-*` in `SDB-002-DC`.

Canonical information owner: Content Cooker Tool.

## Boundary and ownership

The only invocation is `content_cooker --job <specification-path>`. No other
argument, environment variable, current directory, discovery result, or mutable
default affects a job. Standard streams contain diagnostics only; the atomically
written Cooking Job Result is terminal authority.

The tool is not a runtime and owns no launch, Process Control, endpoint,
Admission, Controlled LAN, supervisor, or resident multi-job behavior. Its
executable closure is a Tool Release. Platform, Reference Hardware Profile,
packaging, and distribution remain the explicit `SDR-003` deferral.

## Cooking codecs

`DC-COOKER-008` incorporates this section. SDD-0001 common deterministic-CBOR
and scalar rules apply, except the hard Cooking Job Specification size is
1 MiB, maximum nesting is eight, `SourceList` has `1..100000` entries, and a
diagnostic list has `0..128` entries.

The Cooking Job Specification is a closed map with every key exactly once:

| Key | Field | Type and exact rule |
| --- | --- | --- |
| `0` | contract version | `uint`, exactly `1` |
| `1` | Cooking Job identity | `Identity` |
| `2` | Tool Release identity | `Identity` |
| `3` | authoring root | `Path` |
| `4` | source entries | `SourceList`, sorted by path bytes |
| `5` | processing-gate identity | `Identity` |
| `6` | catalogue identities | `IdentityList` |
| `7` | Approved Profile identities | `IdentityList` |
| `8` | tool records | `1..64` records sorted by identity |
| `9` | configuration identity | `Identity` |
| `10` | Runtime Content Release identity | `Identity` |
| `11` | Authority Pack identity | `Identity` |
| `12` | Client Pack identity | `Identity` |
| `13` | processing-record identity | `Identity` |
| `14` | Resource output identities | `IdentityList` |
| `15` | signing-key reference | `Identity` |
| `16` | ReleasePublisher destination | `Path` |
| `17` | capacity map | `{0: persistent bytes, 1: transient bytes}`, each `1..2^40` |
| `18` | executor provenance | `Provenance` |
| `19` | execution-instant provenance | `Provenance` |
| `20` | Cooking Job Result destination | `Path` |
| `21` | Scenario identity | `Identity` |
| `22` | processing-record output name | `Identity` |

A source entry is `{0: relative Path, 1: kind, 2: Digest, 3: sidecar array}`.
Kind is `1` regular canonical source or `2` sidecar. Sidecars are unique sorted
relative paths. A tool record is `{0: Identity, 1: Digest}`. `Provenance` is
`{0: value, 1: source, 2: authority, 3: format, 4: trust}`, where the first four
are `Identity` and trust is `1` Authoritative, `2` VerifiedExternal, or
`3` DeclaredUnverified. Output names derive only from supplied identities.

The Cooking Job Result is the closed map `{0: version, 1: job identity,
2: status, 3: failure, 4: release identity, 5: authority digest, 6: client
digest, 7: record digest, 8: diagnostics}`. Version is `1`; status is
`1` Committed or `2` Failed. Committed requires null failure and all release/
digest fields. Failed requires one failure code and null release/digests.
Diagnostics are sorted closed non-sensitive codes. Failure codes are, in order,
`SpecificationRejected`, `CapacityRejected`, `SnapshotRejected`,
`GateRejected`, `ProcessingRejected`, `SigningRejected`,
`PublicationRejected`, `IdentityConflict`, `PublicationAmbiguous`,
`Interrupted`, and `InternalFailure`.

## Normative golden vectors

Spaces are non-data. `CCV-001` is a complete minimal valid job using one source,
one catalogue, one profile, one tool, and one Resource identity. `CCV-002` is
its successful result; zero digests are schema values for codec testing, not an
accepted content claim.

| ID | Exact hexadecimal bytes | Result |
| --- | --- | --- |
| `CCV-001` | `b7000101616a0261740369617574686f72696e670481a400616101010258200000000000000000000000000000000000000000000000000000000000000000038005616706816163078161700881a200617801582000000000000000000000000000000000000000000000000000000000000000000961710a61720b61610c61620d616d0e8161750f616b10636f757411a20001010112a5006165016173026161036166040113a500616901617302616103616604011466726573756c7415687363656e6172696f16667265636f7264` | Decode the complete job; re-encode identically. |
| `CCV-002` | `a9000101616a020103f60461720558200000000000000000000000000000000000000000000000000000000000000000065820000000000000000000000000000000000000000000000000000000000000000007582000000000000000000000000000000000000000000000000000000000000000000880` | Decode Committed result; re-encode identically. |
| `CCV-003` | `a10001` | Reject missing required job keys before source access. |
| `CCV-004` | `bf0001ff` | Reject indefinite map before source access. |

## Snapshot and workflow

The source adapter traverses exactly one `authoring/` root in normalized byte
order without following symlinks. Every entry must occur exactly once in the
SourceList. Missing, unexpected, special, out-of-root, case-colliding, Unicode-
colliding, digest-mismatched, or changing input fails the job. A private
immutable snapshot completes before later stages, which never reread live input.

One coordinator orders: specification validation; capacity reservation;
snapshot; gate and input validation; Authority and Client Pack Cores; complete
processing record; reciprocal envelopes; both signatures; candidate durability;
release publication; result commit; owned-staging cleanup. There is no cache,
incremental cook, configurable scheduler, or concurrent coordinator in v1.
Cancellation occurs only between these stages and at declared cancellable
adapter operations. Failure precedence is the result-code order above.

## Deep interfaces, publication, and retry

| Interface | Caller / provider | Ownership, lifetime, blocking, and failure |
| --- | --- | --- |
| `SourceSnapshot.capture(spec)` | coordinator / source adapter | Borrows spec; bounded by declared transient capacity; returns closed failure or move-only immutable snapshot; destruction removes only owned private snapshot. |
| `Signer.sign(key_ref, digest)` | coordinator / signing adapter | Borrows reference/digest; returns signature and non-secret key identity; adapter retains secret; bounded and cancellable before result. |
| `ReleasePublisher.prepare(candidate)` | coordinator / publisher | Consumes move-only candidate into private same-domain staging; returns failure or prepared publication; no general filesystem operation is exposed. |
| `ReleasePublisher.commit(prepared)` | coordinator / publisher | Consumes prepared value; establishes durable atomic release entry; returns exactly `Committed`, `NotCommitted`, or `Ambiguous`; no overwrite. |
| result writer | coordinator / result adapter | Atomically replaces only the job-selected result destination after terminal classification; never changes a published release. |

Publication exposes Authority pack, Client pack, and processing record together
or none. Retry with the same release identity and all three exact digests returns
the existing release. Any mismatch is `IdentityConflict` without overwrite,
merge, rename, or partial replacement. `Ambiguous` yields failed result code 9
and prohibits automatic retry. Recovery deletes only incomplete staging whose
ownership marker and exact job identity are proven; uncertain, corrupt, or
committed material remains unchanged. Secret key bytes never cross Signer or
enter result, record, or diagnostics.

## Design commitments

- `DC-COOKER-001`: Content Cooker MUST remain one finite offline invocation
  with no runtime lifecycle surface.
- `DC-COOKER-002`: one closed immutable Cooking Job Specification MUST be the
  sole source of every execution-affecting value.
- `DC-COOKER-003`: cooking MUST consume one completely validated immutable
  snapshot of the exhaustively classified authoring root.
- `DC-COOKER-004`: ReleasePublisher MUST durably publish both packs and the
  processing record through one atomic release entry.
- `DC-COOKER-005`: retry MUST return an existing release only for exact release
  identity and three-digest equality.
- `DC-COOKER-006`: the tool MUST copy validated executor and instant provenance
  from the job specification without ambient inference.
- `DC-COOKER-007`: this baseline MUST NOT select a Content Cooker platform or
  accept test adapters as native product evidence.
- `DC-COOKER-008`: every job and result MUST conform byte-for-byte to the closed
  codecs and bounds declared by this SDD.
- `DC-COOKER-009`: the atomic Cooking Job Result MUST be the sole authoritative
  terminal result of an invocation.
- `DC-COOKER-010`: the coordinator MUST execute the declared deterministic
  workflow in order without live-source reread or incremental cache.
- `DC-COOKER-011`: recovery MUST delete only incomplete staging whose ownership
  and job identity are proven.
- `DC-COOKER-012`: each expected failure or cancellation MUST produce the first
  applicable stable result classification and owned cleanup.
- `DC-COOKER-013`: secret signing-key bytes MUST NOT cross the Signer interface
  or enter any retained output or diagnostic.
- `DC-COOKER-014`: a digest mismatch for an existing release identity MUST
  return `IdentityConflict` without modifying either release.

## Rationale and trade-offs

A single closed job prevents ambient state from becoming undeclared provenance.
Full snapshotting costs transient space but removes source-race ambiguity.
One coordinator sacrifices parallel scheduling in v1 for deterministic order
and simpler failure precedence. ReleasePublisher is deep so atomicity and native
durability remain behind one contract instead of leaking filesystem operations.
An ambiguous publication is failed rather than retried because retry could
overwrite an already committed identity. The platform remains deferred because
choosing limits without native evidence would create false precision.

| Commitments | Rationale allocation |
| --- | --- |
| `DC-COOKER-001`, `DC-COOKER-009` | Keep offline work finite and give callers one authoritative terminal surface. |
| `DC-COOKER-002`, `DC-COOKER-006`, `DC-COOKER-008` | Eliminate ambient input and make bytes and provenance reproducible. |
| `DC-COOKER-003`, `DC-COOKER-010` | Remove live-source races and scheduler-dependent ordering. |
| `DC-COOKER-004`, `DC-COOKER-005`, `DC-COOKER-011`, `DC-COOKER-014` | Preserve atomic visibility, idempotency, and preceding releases across failure and retry. |
| `DC-COOKER-007` | Avoid claiming a native platform before a governed selection and execution evidence exist. |
| `DC-COOKER-012` | Give every failure one deterministic external classification and cleanup result. |
| `DC-COOKER-013` | Keep secret material inside the only adapter authorized to handle it. |

## Acceptance criteria

Evidence retains specification/result bytes, complete source manifest and
snapshot digests, ordered stage trace, fault point, publisher state, output
directory listing, secret scan, capacity high-water, executable identity, and
native environment when applicable.

| Criterion | Preconditions and stimulus | Required and prohibited observation |
| --- | --- | --- |
| `DAC-COOKER-001` | Inspect invocation and attempt runtime interaction/residency. | One job terminates with result; no runtime contract, endpoint, LAN, or second job. |
| `DAC-COOKER-002` | Vary CLI, environment, cwd, defaults, and unlisted files around identical job bytes. | All effective values come from the job; overrides fail or have zero output effect. |
| `DAC-COOKER-003` | Inject missing/unexpected/special/symlink/collision/digest/mutation cases. | Every case fails before cooking; valid snapshot is immutable and no later live read occurs. |
| `DAC-COOKER-004` | Fail at every durability/publication boundary and list destination after restart. | Exactly all three outputs or none are visible; preceding release is byte-identical. |
| `DAC-COOKER-005` | Retry same identity with equal and each unequal digest. | Equal returns existing bytes; no new write; unequal uses criterion 14. |
| `DAC-COOKER-006` | Change OS account/clock while job provenance is fixed; mutate each provenance field. | Fixed jobs yield fixed record values; invalid provenance fails; ambient values never appear. |
| `DAC-COOKER-007` | Inspect package and run only test adapters. | No platform selection or native Pass is claimed; test results remain non-product evidence. |
| `DAC-COOKER-008` | Round-trip CCV-001..004 and mutate key/order/type/bound/trailing bytes. | Positive vectors are identical; negatives fail before source access or output. |
| `DAC-COOKER-009` | Crash before/during/after result replacement. | One complete terminal result or preceding complete result exists; stdout/stderr cannot establish success. |
| `DAC-COOKER-010` | Repeat identical cook and interrupt each ordered stage. | Stage order is exact and successful output bytes match; no cache or live reread is observed. |
| `DAC-COOKER-011` | Seed owned, foreign, corrupt, uncertain, and committed staging. | Only proven owned incomplete staging is deleted; all other bytes remain unchanged. |
| `DAC-COOKER-012` | Inject all failure codes and simultaneous faults at stage boundaries. | First code by declared precedence is retained with bounded diagnostics and owned cleanup. |
| `DAC-COOKER-013` | Sign successfully/fail and scan memory handoff, record, result, diagnostics. | Only key reference/identity and signatures cross; zero secret bytes occur in retained surfaces. |
| `DAC-COOKER-014` | Publish an existing identity with each one-digest mismatch. | Result is IdentityConflict; existing and candidate publication locations remain unmodified. |
