# SDD-0004: Content Cooker Tool

Status: Candidate successor design; project-owner approval pending

Last meaningful change: 2026-09-06

Purpose: Define the exact finite offline tool that cooks one immutable authoring
closure into one atomically published Runtime Content Release.

Review focus: Changed content semantics and verification criteria under ADR-0014;
no fixed reviewer count or full-package reread is required for a routine edit.

Owner: Content Cooker Tool.

## Boundary and ownership

The only invocation is `content_cooker --job <specification-path>`, where the
value is one absolute host path. A relative or empty path, option alias, or any
other argument is rejected before file access. The executable opens that exact
path without search and uses its canonical parent directory to resolve every
job `Path` under SDD-0001; therefore environment, current directory, discovery
results, and mutable defaults cannot affect a job. Standard streams contain
diagnostics only; the atomically written Cooking Job Result is terminal
authority.

The tool is not a runtime and owns no launch, Process Control, endpoint,
Admission, Controlled LAN, supervisor, or resident multi-job behavior. Its
executable closure is a Tool Release. Platform, Reference Hardware Profile,
packaging, and distribution remain the explicit `SDR-003` deferral.

## Cooking codecs

`DC-COOKER-008` incorporates this section. SDD-0001 common deterministic-CBOR
and scalar rules apply, except the hard Cooking Job Specification size is
1 MiB, maximum nesting is eight, `SourceList` has `2..100000` entries, and a
diagnostic list has `0..6` entries.

The Cooking Job Specification is a closed map with every key exactly once:

| Key | Field | Type and exact rule |
| --- | --- | --- |
| `0` | contract version | `uint`, exactly `1` |
| `1` | Cooking Job identity | `Identity` |
| `2` | Tool Release identity | `Identity` |
| `3` | authoring root | `Path` |
| `4` | source entries | `SourceList`, sorted by path bytes |
| `5` | processing gate | `VersionedInputReference` |
| `6` | catalogues | `ReferenceList` |
| `7` | Approved Profiles | `ReferenceList` |
| `8` | tools | `ReferenceList` |
| `9` | configuration | `VersionedInputReference` |
| `10` | Runtime Content Release identity | `Identity` |
| `11` | Authority Pack identity | `Identity` |
| `12` | Client Pack identity | `Identity` |
| `13` | processing-record identity | `Identity` |
| `14` | Resource outputs | `ResourceOutputList` |
| `15` | signing-key reference | `SigningKeyReference` |
| `16` | ReleasePublisher destination | `Path` |
| `17` | capacity map | `{0: persistent bytes, 1: transient bytes, 2: Failed-record reserve bytes}`, each `1..2^40`, with key 2 not greater than key 1 |
| `18` | executor provenance | `Provenance` |
| `19` | execution-instant provenance | `Provenance` |
| `20` | Cooking Job Outcome destination | `Path` |
| `21` | Scenario | `VersionedIdentity` |

A source entry is `{0: relative Path, 1: kind, 2: Digest, 3: sidecar array,
4: canonical Source Identity, 5: canonical source version}`; key 4 uses the
same 16-byte UUIDv4 representation as `ResourceIdentity`, and key 5 uses
`Identity`. Kind is `1` regular canonical source or `2` sidecar. A kind-1 entry
lists `1..64` unique kind-2 paths in encoded-byte order; exactly one is its
adjacent Resource Identity Metadata path `<source-path>.sacmeta.json`, and it
cannot list itself or another kind-1 entry. A kind-2 entry has an empty sidecar
array, repeats the owning kind-1 Source Identity/version in keys 4/5, and is
named by exactly one kind-1 entry. Every source path occurs in exactly one
SourceList entry. `VersionedInputReference` is the closed map `{0: Identity, 1:
exact-version Identity, 2: Path, 3: Digest}`. `ReferenceList` is a definite
array of `1..64` such references with unique identity/version pairs and
resolved paths, sorted by the encoded pair. `VersionedIdentity` is the closed
map `{0: Identity, 1: exact-version Identity}`. A `ResourceIdentity` is a
16-byte byte string whose RFC 9562 version nibble is `4` and variant bits are
`10`; its diagnostic form is the corresponding lowercase hyphenated UUID.
`ResourceOutputList` is a definite array of `1..100000` closed maps
`{0: ResourceIdentity, 1: product semantic Identity, 2: role}`, sorted by
ResourceIdentity bytes, with no repeated ResourceIdentity and role `1`
Authority or `2` Client. A semantic product needed by both roles therefore has
two declarations with one common product identity and two different Resource
Identities, as required by ARCHSPEC-0012. `SigningKeyReference` is the closed
map `{0: non-secret key-reference Identity, 1: Path, 2: signature-scheme
uint exactly `1` for pure Ed25519, 3: expected Content Signing Key Identity as
Digest}`. The path resolves only from the selected specification's canonical
parent, is not searched or environment-resolved, and is opened only inside
`Signer`. `Provenance`
is `{0: value, 1: source, 2: authority, 3: format, 4: trust}`, where the first four are
`Identity` and trust is `1` Authoritative, `2` VerifiedExternal, or `3`
DeclaredUnverified. `DC-COOKER-006` incorporates the following validation: the
exact approved processing gate supplies separate
`ExecutorProvenance` and `ExecutionInstantProvenance` criteria; both must return
`Pass` before the values are copied. A missing criterion or `Fail`, `Blocked`,
`Stale`, or `Uncertain` result is invalid provenance. Published release entries
always use the three literal names `authority.pack`, `client.pack`, and
`processing.record`; no job field or adapter may select another name.

`DC-COOKER-003` additionally incorporates this rule: the cooker parses every
required `.sacmeta.json` as the exact
ARCHSPEC-0012 Resource Identity Metadata schema version selected by the gate:
strict UTF-8 NFC, LF endings, fixed property order, closed JSON value set, and
arrays ordered by semantic key. Its canonical-source UUID must equal source
entry key 4 and must be unique across all kind-1 sources in the snapshot; every
declared product Resource Identity/type and subresource identity must likewise
be unique, syntactically valid, and consistent with key 14 and the gate-selected
Runtime Resource Type Inventory. Missing metadata, an
auxiliary sidecar substituted at the adjacent name, or any unknown, duplicate,
fractional, noncanonical, ambiguous, or inconsistent value is
`SnapshotRejected`.

`DC-COOKER-002` incorporates the following selection and path rule. Selection
consists of the absolute `<specification-path>` plus the exact file
bytes. The same bytes at another absolute path are a different selected
specification because relative `Path` values have another base. After
handle-based no-follow resolution, the specification file, complete authoring
tree, every processing-gate/catalogue/profile/tool/configuration referenced
file, signing-key path, ReleasePublisher destination tree, and Cooking Job
Outcome destination tree must be pairwise disjoint. Any equality,
ancestor/descendant overlap, symlink/reparse traversal, or unresolved path is
`SpecificationRejected` after the routing preamble and before snapshot or
release output. Every referenced non-secret input is opened by its resolved
no-follow path, checked against its identity, exact version, and digest, and
retained through an immutable handle until result commit. Only `Signer` opens
the signing-key path.

The Cooking Job Result is the closed map `{0: version, 1: job identity,
2: status, 3: failure, 4: release identity, 5: Authority complete-file digest,
6: Client complete-file digest, 7: complete processing-record digest,
8: diagnostics}`. Version is `1`; status is
`1` Committed or `2` Failed. Committed requires null failure and all release/
digest fields. Failed requires one `uint` failure code and null release/digests.
Diagnostics are a definite array of unique `uint` values in ascending encoded
order, with `0..6` entries drawn only from: `1` ExistingReleaseReused, `2`
ForeignStagingPreserved, `3` CorruptStagingPreserved, `4`
UncertainStagingPreserved, `5` CleanupPending, and `6`
RecoveredStagingRemoved. Failure codes are, in order,
`1` SpecificationRejected, `2` CapacityRejected, `3` SnapshotRejected, `4`
GateRejected, `5` ProcessingRejected, `6` SigningRejected, `7`
PublicationRejected, `8` IdentityConflict, `9` PublicationAmbiguous, `10`
Interrupted, and `11` InternalFailure.

`DC-COOKER-009` and `DC-COOKER-012` incorporate the following routing and exit
rule. The tool validates a routing preamble only when the complete CBOR item is
canonical, contains every key once, and keys `0`, `1`, and `20` have valid
types. Structural failure before that point is `InvocationRejected` and cannot
select a job outcome destination. Later schema or semantic failure is
`SpecificationRejected` and uses the validated destination. Outcome-writer
failure means failure of the atomic outcome writer and is
`ResultCommitFailed`; it cannot manufacture a Processing Record or Cooking Job Result or
use stdout/stderr as fallback. Closed process exits are `0` Committed result,
`10` Failed result, `20` InvocationRejected without result, `30`
ResultCommitFailed without a new result, and `40` PostResultCleanupIncomplete
with the already committed result unchanged.

For ARCHSPEC-0013's “every classified failure” rule, a classified job failure
begins only after the routing preamble has selected a valid outcome destination.
`InvocationRejected` is an intake outcome before a job can be classified;
`ResultCommitFailed` is failure of the mandated commit itself. Neither can
truthfully create the missing authoritative result, and both retain their
distinct closed exits above.

The three result, retry, marker, and `IdentityConflict` digests always mean
SHA-256 over every byte of the final `authority.pack`, `client.pack`, and
`processing.record`, respectively. They never mean a Pack Core Digest. Pair
bindings use only the two Pack Core Digests defined by ARCHSPEC-0012. Neither
digest scope may substitute for the other.

`DC-COOKER-016` and `DC-COOKER-023` incorporate this record/outcome contract.
A content-processing execution begins within workflow stage 3 immediately
after the exact approved gate identity/version/digest/schema and criterion
inventory validate, and ends when stage 7 has made the closed candidate
artifacts durable. Intake, specification, capacity, snapshot, gate-reference,
and later publication/result/cleanup operations are outside that execution.
From the start boundary through stage 7, exactly one versioned processing
record is produced for each success or failure. The gate-selected record schema
has two closed variants:

- `Passed` contains every population enumerated under `DC-COOKER-016`, all
  criterion results `Pass`, the expected two signature descriptors, and no
  primary failure, unavailable value, detached signature, own digest, or
  complete-file digest. This exact record is placed in both envelopes by digest
  and published inside the successful release.
- `Failed` contains the same supplied job, gate, Scenario, intended release,
  pack, Resource, role, contract, provenance, and expected-signature identities;
  every available input/output/mapping and integrity value; exactly one result
  for every gate criterion using `Pass`, `Fail`, `Blocked`, `Stale`, `Uncertain`,
  or `NotRun`; the primary failure code and terminal workflow stage; and, for
  each role, signing disposition `NotAttempted`, `Failed`, or `Verified` plus an
  optional exact detached-signature value only when `Verified`. Every value not
  produced before failure uses the gate schema's explicit `Unavailable`
  alternative; zero, null, omission, and fabricated values are forbidden.

The exact approved gate must define those two variants, alternatives, criterion
ordering, field encodings, and the maximum encoded size of its Failed variant.
During stage 1 the coordinator reserves exactly capacity-map key 2 bytes from
the key-1 transient budget; all other transient work is limited to the
remainder. Before the content-processing start boundary in stage 3, gate
validation rejects with `GateRejected` any schema whose declared maximum is
missing, is not exact, exceeds that reserve, or cannot encode every maximum-size
job population. On any stage-3-through-stage-7 failure, the successful
candidate record is discarded if it exists and the coordinator seals the
Failed variant without rerunning processing. Key 20 names an atomic outcome
entry: it contains fixed `result.cbor` and, for a content-processing failure,
fixed `processing.record`; failures outside the declared processing boundaries
contain only `result.cbor`. A stage-8 publication failure therefore does not
retroactively alter or duplicate the durable Passed record already bound into
the signed candidate.
`OutcomeWriter.commit` publishes that closed entry together or not at all and
atomically replaces only the selected prior outcome entry. A successful release
already contains its Passed record, so its outcome entry contains only
`result.cbor`. Outcome commit failure is `ResultCommitFailed`, exit `30`, with
no new record/result and the prior outcome entry unchanged; it cannot fabricate
the artifacts whose commit failed.

## Normative golden vectors

Spaces are non-data. `DC-COOKER-008` incorporates every `CCV-*` vector and
`DC-COOKER-011` incorporates `CMV-001`. `CCV-001` is a complete minimal schema-valid
job using canonical source UUID `10213243-5465-4787-98a9-bacbdcedfe0f`, its
mandatory `a.sacmeta.json`, one catalogue, one profile, one tool, exact version
`1` references, Resource UUID `00112233-4455-4677-8899-aabbccddeeff`, and the
`RPV-001` expected signing descriptor. `CCV-002` is
its successful result; zero digests are schema values for codec testing, not an
accepted content claim.

| ID | Exact hexadecimal bytes | Result |
| --- | --- | --- |
| `CCV-001` | `b6000101616a0261740369617574686f72696e670482a60061610101025820000000000000000000000000000000000000000000000000000000000000000003816e612e7361636d6574612e6a736f6e0450102132435465478798a9bacbdcedfe0f056131a6006e612e7361636d6574612e6a736f6e0102025820000000000000000000000000000000000000000000000000000000000000000003800450102132435465478798a9bacbdcedfe0f05613105a400616701613102646761746503582000000000000000000000000000000000000000000000000000000000000000000681a40061630161310269636174616c6f67756503582000000000000000000000000000000000000000000000000000000000000000000781a4006170016131026770726f66696c6503582000000000000000000000000000000000000000000000000000000000000000000881a40061780161310264746f6f6c035820000000000000000000000000000000000000000000000000000000000000000009a4006171016131026d636f6e66696775726174696f6e03582000000000000000000000000000000000000000000000000000000000000000000a61720b61610c61620d616d0e81a3005000112233445546778899aabbccddeeff01617502010fa400616b01636b65790201035820b36b7e4972f4523bc394ed3e7c6cb898ee76c85e1c4c5e177afe8e77fa27229410636f757411a300010101020112a5006165016173026161036166040113a500616901617302616103616604011466726573756c7415a200687363656e6172696f016131` | Decode the complete job; re-encode identically. |
| `CCV-002` | `a9000101616a020103f60461720558200000000000000000000000000000000000000000000000000000000000000000065820000000000000000000000000000000000000000000000000000000000000000007582000000000000000000000000000000000000000000000000000000000000000000880` | Decode Committed result; re-encode identically. |
| `CCV-003` | `a10001` | Reject missing required job keys before source access. |
| `CCV-004` | `bf0001ff` | Reject indefinite map before source access. |
| `CCV-005` | `a9000101616a020103f60461720558200000000000000000000000000000000000000000000000000000000000000000065820000000000000000000000000000000000000000000000000000000000000000007582000000000000000000000000000000000000000000000000000000000000000000886010203040506` | Decode a Committed result containing every diagnostic code; re-encode identically. |
| `CCV-006` | `a9000101616a0202030104f605f606f607f60880` | Decode a Failed `SpecificationRejected` result; re-encode identically. |
| `CMV-001` | `a5000101616a02582000000000000000000000000000000000000000000000000000000000000000000361720401` | Decode the canonical Incomplete marker for job `j`, zero job digest, and release `r`; re-encode identically. |

### Normative role-pack signing codec

`DC-COOKER-019`, `DC-COOKER-020`, and `DC-COOKER-022` incorporate this exact v1 contract,
provided by Runtime Package without transferring its canonical ownership to the
cooker. The five contiguous regions use this 80-byte fixed header; every
multi-byte integer is unsigned little-endian:

| Offset | Width | Field and exact value/rule |
| --- | --- | --- |
| `0` | `8` | magic bytes `53 41 43 50 41 43 4b 00` (`SACPACK\0`) |
| `8` | `4` | format version, exactly `1` |
| `12` | `4` | header size, exactly `80` |
| `16` | `8` | envelope offset, exactly `80` |
| `24` | `8` | envelope byte length |
| `32` | `8` | manifest offset, exactly envelope offset plus length |
| `40` | `8` | manifest byte length |
| `48` | `8` | Payload offset, exactly manifest offset plus length |
| `56` | `8` | Payload byte length |
| `64` | `8` | signature offset, exactly Payload offset plus length |
| `72` | `8` | signature byte length, exactly `64` |

The Pack Envelope is one restricted deterministic-CBOR positional array of
exactly 16 items. An `EnvelopeIdentity` is a byte string containing the exact
UTF-8 bytes of its validated SDD-0001 `Identity`, length `1..64`; no text item
is admitted. Its positions are: `0` envelope version uint `1`; `1` Runtime
Content Release `EnvelopeIdentity`; `2` Scenario `EnvelopeIdentity`; `3`
Scenario-version `EnvelopeIdentity`; `4` own-pack `EnvelopeIdentity`; `5` role
uint `1` Authority or `2` Client; `6` runtime-content-contract
`EnvelopeIdentity`; `7` contract-version `EnvelopeIdentity`; `8` own Pack Core
`Digest`; `9` counterpart-pack `EnvelopeIdentity`; `10` counterpart Pack Core
`Digest`; `11` own Pack Manifest `Digest`; `12` processing-record
`EnvelopeIdentity`; `13` processing-record `Digest`; `14` signature-scheme uint
exactly `1`; and `15` Content Signing Key Identity `Digest`. No other length,
type, item, role, or scheme is valid.

The Pack Manifest is one definite array of `1..contract.resource_limit`
entries. Each entry is a positional array of exactly nine items: `0` 16-byte
UUIDv4 Resource Identity; `1` unsigned type identity; `2` unsigned exact schema
version; `3` unsigned Stored Extent offset relative to the first Payload byte;
`4` unsigned stored size; `5` unsigned decoded-size limit; `6` codec uint exactly
`0` (`None`); `7` extent `Digest`; and `8` a definite Resource Reference array
of `0..contract.references_per_resource_limit` items. Entries are ordered by
Resource Identity bytes. Their ranges form one complete non-overlapping Payload
partition; with codec `0`, stored size equals decoded-size limit. Physical
extents in that partition use the unique canonical dependency topological
order: every referenced target extent precedes every extent whose manifest
entry references it, and Resource Identity bytes break ties among all currently
ready entries. A cyclic reference graph is invalid.

A Resource Reference is a positional array of exactly three items: `0` target
16-byte UUIDv4 Resource Identity; `1` optional Subresource Identity alternative;
and `2` unsigned expected type identity. The optional alternative is exactly an
empty array for absence or a one-item array containing one 16-byte UUIDv4
Subresource Identity for presence; `null`, a bare byte string, or any other
length is forbidden. References are duplicate-free and ordered by target
Resource Identity, absent-before-present Subresource alternative bytes, then
expected type. `MRV-001` is the absent form
`835000112233445546778899aabbccddeeff8001`; `MRV-002` is the present form
`835000112233445546778899aabbccddeeff8150102132435465478798a9bacbdcedfe0f01`;
`MRV-003` replaces the alternative with CBOR null and must be rejected:
`835000112233445546778899aabbccddeefff601`.

The exact role-pack signing domain separator is the 33 bytes
`53616372616d656e746f2e526f6c655061636b2e5369676e61747572652e763100`.
The Ed25519 preimage is exactly those bytes followed by the complete 80-byte
header and exact envelope bytes, without a length, digest, or terminator added.
The exact Content Signing Key Identity domain separator is the 32 bytes
`53616372616d656e746f2e436f6e74656e745369676e696e674b65792e763100`;
the key identity is SHA-256 of those bytes followed by scheme identity `1` as
four-byte little-endian `01000000` and the raw 32-byte Ed25519 public key.

`RPV-001` is a codec-only pack with one manifest entry for Resource UUID
`00112233-4455-4677-8899-aabbccddeeff`, type/schema `1`, one-byte Payload `00`,
no references, zero processing-record digest, and one-item envelope identities;
the unregistered fixture type means it is not an admitted product content
closure. Its test seed is fixture data, never a product key.

| Vector field | Exact hexadecimal bytes |
| --- | --- |
| private test seed | `000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f` |
| public key | `03a107bff3ce10be1d70dd18e74bc09967e4d6309ba50d5f1ddc8664125531b8` |
| Content Signing Key Identity | `b36b7e4972f4523bc394ed3e7c6cb898ee76c85e1c4c5e177afe8e77fa272294` |
| Pack Manifest bytes | `81895000112233445546778899aabbccddeeff01010001010058206e340b9cffb37a989ca544e6bb780a2c78901d3fb33738768511a30617afa01d80` |
| Payload bytes and Stored Extent digest | `00`; `6e340b9cffb37a989ca544e6bb780a2c78901d3fb33738768511a30617afa01d` |
| Pack Manifest digest | `75be574d2939b10af7e3bb9539d48c8008db0a63ae9f8b67fb2cab6473619da4` |
| Pack Core digest | `160af4bbd8e9839d7d182a6aa3b00ff226d8f7304c3450046f996e08b5d766bd` |
| fixed header | `5341435041434b0001000000500000005000000000000000be000000000000000e010000000000003c000000000000004a0100000000000001000000000000004b010000000000004000000000000000` |
| Pack Envelope | `9001417241734131416101416341315820160af4bbd8e9839d7d182a6aa3b00ff226d8f7304c3450046f996e08b5d766bd41625820160af4bbd8e9839d7d182a6aa3b00ff226d8f7304c3450046f996e08b5d766bd582075be574d2939b10af7e3bb9539d48c8008db0a63ae9f8b67fb2cab6473619da4416d58200000000000000000000000000000000000000000000000000000000000000000015820b36b7e4972f4523bc394ed3e7c6cb898ee76c85e1c4c5e177afe8e77fa272294` |
| pure-Ed25519 preimage | `53616372616d656e746f2e526f6c655061636b2e5369676e61747572652e7631005341435041434b0001000000500000005000000000000000be000000000000000e010000000000003c000000000000004a0100000000000001000000000000004b0100000000000040000000000000009001417241734131416101416341315820160af4bbd8e9839d7d182a6aa3b00ff226d8f7304c3450046f996e08b5d766bd41625820160af4bbd8e9839d7d182a6aa3b00ff226d8f7304c3450046f996e08b5d766bd582075be574d2939b10af7e3bb9539d48c8008db0a63ae9f8b67fb2cab6473619da4416d58200000000000000000000000000000000000000000000000000000000000000000015820b36b7e4972f4523bc394ed3e7c6cb898ee76c85e1c4c5e177afe8e77fa272294` |
| detached signature | `7dd10bad19fcdd7df83667092d6d27c4dc1486f845e4035794a42414f195fe7af6c878b0bdac994cf1b3e4be33801854e5bab135b351cd1b22d6199d1026fb02` |
| complete role pack | `5341435041434b0001000000500000005000000000000000be000000000000000e010000000000003c000000000000004a0100000000000001000000000000004b0100000000000040000000000000009001417241734131416101416341315820160af4bbd8e9839d7d182a6aa3b00ff226d8f7304c3450046f996e08b5d766bd41625820160af4bbd8e9839d7d182a6aa3b00ff226d8f7304c3450046f996e08b5d766bd582075be574d2939b10af7e3bb9539d48c8008db0a63ae9f8b67fb2cab6473619da4416d58200000000000000000000000000000000000000000000000000000000000000000015820b36b7e4972f4523bc394ed3e7c6cb898ee76c85e1c4c5e177afe8e77fa27229481895000112233445546778899aabbccddeeff01010001010058206e340b9cffb37a989ca544e6bb780a2c78901d3fb33738768511a30617afa01d80007dd10bad19fcdd7df83667092d6d27c4dc1486f845e4035794a42414f195fe7af6c878b0bdac994cf1b3e4be33801854e5bab135b351cd1b22d6199d1026fb02` |

The vector passes only when every field decodes at the stated offset, the
envelope re-encodes identically, both SHA-256 values and the key identity match,
the pure-Ed25519 signature verifies over the exact preimage, and reassembly
equals the complete 395-byte pack. Any one-bit mutation in header, envelope,
manifest, Payload, extent, reference, domain separators, scheme, public key, or signature must fail its
applicable integrity or signature check.

## Snapshot and workflow

`DC-COOKER-003` incorporates the following snapshot contract. The source
adapter traverses exactly one `authoring/` root without following
symlinks. It decodes every host name as strict UTF-8, normalizes it to Unicode
15.1 NFC, applies the SDD-0001 portable `Path` grammar, and sorts by normalized
UTF-8 path bytes. Only regular files occur in the SourceList. A directory is
structural and permitted only when its normalized path is a proper prefix by
whole `/`-delimited components of at least one listed file; thus `a` is not a
prefix of `ab/file`. The root itself is implicit. An empty directory is unexpected,
and every non-directory entry not represented by kind 1 or 2 is special. Every
regular file must occur exactly once in the SourceList. Two
raw names Unicode-collide when their NFC paths are equal. They case-collide when
Unicode 15.1 Default Case Folding applied to each NFC path, followed by NFC,
produces equal UTF-8 bytes. Distinct raw entries in either relation are rejected
before snapshot. Missing, unexpected, special, out-of-root, digest-mismatched,
or changing input likewise fails the job. A private immutable snapshot
completes before later stages, which never reread live input.

For each listed file the source adapter obtains one no-follow handle and a
`SourceFileToken` containing stable file identity, regular-file kind, byte
length, link count exactly `1`, and native change generation. For the root and
every admitted directory it obtains a no-follow directory handle and a
`DirectoryToken` containing stable directory identity, native change
generation, and the ordered immediate-child sequence of raw name bytes and
entry kinds. It reads and hashes each file through its handle, compares every
file token before and after that read and after the complete traversal, then
re-enumerates every directory through its retained handle and compares both
the DirectoryToken and exact immediate-child sequence. Any token field change,
entry addition/removal/rename/reclassification, replacement, link count other
than one, unavailable generation, or digest difference is
`SnapshotRejected`. Platform admission must prove that retained handles,
tokens, and final enumeration detect every mutation allowed by that
filesystem; a platform without that guarantee cannot realize this interface.

`DC-COOKER-010` incorporates the following workflow and cancellation order. One
coordinator follows the accepted ARCHSPEC-0013 order exactly:

1. validate specification, Tool Release identity, disjoint paths, and capacity;
2. capture and validate the complete authoring snapshot;
3. validate the exact processing gate, catalogues, profiles, tools, and
   configuration;
4. produce both deterministic Pack Cores in private staging;
5. produce the complete processing record and reciprocal pack envelopes;
6. sign both role packs through the private signing seam;
7. make both packs and the processing record durable;
8. atomically publish one complete release entry;
9. atomically commit one Cooking Job Result; and
10. clean owned staging and exit.

There is no cache, incremental cook, configurable scheduler, or concurrent
coordinator in v1. Cancellation is sampled between stages 1–7 and within only
specification read, source capture, gate validation, processing, signing,
publisher preparation, and candidate-durability adapter calls. Each cancelled
call returns no owned partial result. Cancellation before the routing preamble
is valid is terminal `InvocationRejected`, exit `20`, without a result;
cancellation after routing and before stage 8 commits a Failed `Interrupted`
result. From the start of publication stage 8 through result stage 9
cancellation is deferred and then discarded: it never changes the publication
outcome, committed result, cleanup obligation, or exit. At a fence, a completed
operation failure is classified before cancellation; otherwise sampled
cancellation wins before the next operation. Multiple returned failures use
the numeric result-code precedence. Stage 10 is always attempted after stage 9
and cannot revise a committed result.

## Gate, record, trace, pair, and signing

`DC-COOKER-015` incorporates this processing-gate rule. The key-5
`VersionedInputReference` must resolve byte-for-byte to a project-owner-approved
gate whose embedded identity and exact version equal the reference. The gate is immutable
for the invocation and supplies the exact criterion inventory, input and output
schemas, tool/configuration constraints, disposition rules, and admission
effect. Missing approval or identity/digest mismatch is `GateRejected` before
processing.

`DC-COOKER-016` incorporates this processing-record population. The record
conforms to the exact gate-selected output schema and contains the gate identity
and exact version; Scenario identity and exact version; every source entry,
version, and digest; every catalogue, Approved Profile, dependency, tool, and
configuration identity, version, and digest; pipeline identity and version;
Runtime Content Release and both role-pack identities; each role and runtime
content-contract identity/version; both Pack Core Digests; Pack Manifest
digests; reciprocal pair bindings; for each role the key-15 expected
pure-Ed25519 scheme and Content Signing Key Identity;
every source-to-output mapping; one result for every gate criterion; and the
two validated provenance values. No field is inferred from ambient state.

The processing record does not contain its own digest, either detached
signature value, either complete-file digest, or any value computed from its
own bytes. In `REQ-CONTENT-PROCESSING-RECORD-001`, “identifying ... signatures”
therefore means the exact role, pack identity, pure-Ed25519 scheme, and Content
Signing Key Identity tuple; the deterministic detached 64-byte signature is
carried only in that pack's signature region and is verified against its exact
signed header and envelope. After the record is encoded once, its SHA-256 is
placed in both envelopes. This is the non-circular order required by
ARCHSPEC-0012: Pack Cores, signing context, record, record digest, envelopes,
signatures, then complete-file digests.

The record's reciprocal-binding value contains only release and Scenario
identity/version, both roles and exact contracts, and both pack identities and
Pack Core Digests. It excludes the processing-record digest, envelope bytes,
detached signatures, and complete-file digests.

`DC-COOKER-017` incorporates this mapping rule. Before the record is sealed,
each key-14 declaration must occur exactly once in its declared role pack and
map to one or more source entries with exact source identity/version and digest.
Two role-specific projections of one product use distinct Resource Identities,
their common product semantic identity relates them in the record, and each has
its own role mapping. Every Map-derived output additionally maps to its canonical
Blender source entry/version. A kind-2 sidecar may map directly to every output
it contributes to; its owning kind-1 source relation does not imply that trace.
Each kind-1 or kind-2 source either maps directly to at least one output or has
one gate-defined `NoOutput` disposition. A missing, duplicate, dangling, or
cross-role-inconsistent declaration or mapping is `ProcessingRejected`.

`DC-COOKER-021` incorporates this role-closure rule. Against each exact
gate-selected runtime content contract and Runtime Resource Type Inventory, the
Authority pack must contain every and only the Resource closure required by
Simulation, Scenario, Session Lifecycle, and the other Authority owners; the
Client pack must contain every and only the closure required by Prediction,
Presentation, and the other Client owners. Every dependency is local to the
same role pack. Client-only Resource projections, source formats, metadata
sidecars, importer/vendor types, and a dependency on the counterpart pack are
prohibited from the Authority pack; source formats, sidecars, importer/vendor
types, and counterpart-pack dependencies are prohibited from the Client pack.
Missing, extra, wrong-role, cross-role, or source-format closure is
`ProcessingRejected` before record sealing.

`DC-COOKER-018` incorporates this admission rule. After both Pack Cores and
source/output representations exist, the coordinator evaluates every criterion
from the exact gate once in its gate-declared order. Only when all results are
`Pass` does it construct and validate the single complete processing record,
its digest, and the two reciprocal envelopes using the key-15 expected signing
descriptor. It proceeds to `Signer` only after those non-signing integrity
checks pass. Missing, failed, blocked, stale, uncertain, wrong-gate,
incompatible, corrupt, or unclassified input, dependency, mapping, output,
integrity result, or criterion is `GateRejected` or `ProcessingRejected` by
numeric precedence and prevents both signing and publication.

`DC-COOKER-019` incorporates this pair rule. Each envelope contains every
ARCHSPEC-0012 field: envelope version; common Runtime Content Release identity;
key-21 Scenario identity and exact version; own pack identity and closed role
(`1` Authority or `2` Client); own runtime-content-contract identity and exact
version; own and counterpart pack identities and Pack Core Digests; own Pack
Manifest SHA-256 digest; common processing-record identity and SHA-256 digest;
pure-Ed25519 signature-scheme identity; and Content Signing Key Identity. The
two envelopes must agree byte-for-byte on release, Scenario/version,
processing-record identity/digest, signing scheme/key identity, and reciprocal
pack identity/core-digest values. Each role's contract may differ and is
validated against the gate-selected exact contract for that role.

`DC-COOKER-020` incorporates this signing rule. After criterion 18 has produced
the single sealed record and two envelopes, the coordinator calls
`Signer.inspect(key-15)` once. An unreadable/missing key, invalid Ed25519 key,
scheme other than key-15 field 2, or derived Content Signing Key Identity other
than key-15 field 3 is `SigningRejected`; cancellation before a returned
outcome is `Interrupted` under the stage-6 fence. Success returns an opaque
signing handle and the exact matching non-secret scheme/key identity without
exporting secret or public-key bytes. The coordinator then calls
`Signer.sign(handle, preimage)` exactly once for Authority and once for Client,
in that order. Each `preimage` is the fixed Sacramento domain
separator followed by the exact fixed header and exact Pack Envelope bytes;
the adapter performs pure Ed25519 and rejects Ed25519ph or any alternative.
The two detached 64-byte signatures occupy only their packs' signature regions.
Both must verify against the inspected signing context before candidate
durability. A missing, failed, wrong-size, or non-verifying signature is
`SigningRejected`; no unsigned or singly signed candidate can enter publisher
preparation.

## Deep interfaces, publication, and retry

| Interface | Caller / provider | Ownership, lifetime, blocking, and failure |
| --- | --- | --- |
| `SourceSnapshot.capture(spec)` | coordinator / source adapter | Borrows spec; bounded by declared transient capacity; returns closed failure or move-only immutable snapshot; destruction removes only owned private snapshot. |
| `Signer.inspect(key_ref)` | coordinator / signing adapter | Cancellable before outcome; opens the exact private-key path internally and returns exactly `Interrupted`, `SigningRejected`, or a move-only opaque handle plus the non-secret scheme/key identity equal to key 15; no secret or public-key bytes cross the seam. |
| `Signer.sign(handle, preimage)` | coordinator / signing adapter | Borrows the handle and exact bounded domain-separator/header/envelope bytes; returns one detached 64-byte pure-Ed25519 signature only after internal verification against the inspected context; bounded and cancellable before success. |
| `ReleasePublisher.prepare(candidate)` | coordinator / publisher | Returns `Busy` if it cannot obtain the exclusive current-job lease. Under the lease it performs exact DC-011 recovery, records deletion/preservation diagnostics, then independently compares the final release entry. An equal entry returns `ExistingReleaseReused` and an unequal entry returns `IdentityConflict`, irrespective of preserved staging. Only an absent release plus clean or proven-removed staging returns `Prepared`; an absent/unreadable release plus preserved staging returns `PublicationRejected`. Reuse carries equal digests; conflict carries a mismatch mask. `Prepared` creates directory/Incomplete marker before moving candidate into `candidate/`. Busy maps to `PublicationRejected`. |
| `ReleasePublisher.make_durable(session)` | coordinator / publisher | Accepts only `Prepared`; makes the existing marker, closed `candidate/` directory, its three literal files, and required parent metadata durable; returns success or `PublicationRejected`; cancellable before success. |
| `ReleasePublisher.commit(session)` | coordinator / publisher | Borrows and mutates a durable `Prepared` session; noncancellable once entered; atomically renames only its `candidate/` child to the independently durable final release-entry path and returns exactly `Committed`, `NotCommitted`, or `Ambiguous`; it never consumes the session or overwrites. |
| `ReleasePublisher.mark_published(session)` | coordinator / publisher | After `Committed`, atomically changes only the staging marker to Published. Failure cannot alter the independent release entry and adds `CleanupPending` to the result about to be committed. |
| `ReleasePublisher.cleanup(session)` | coordinator / publisher | Stage-10 operation for every session state. It preserves staging after `Ambiguous`; otherwise it removes only session-owned candidate/marker remnants proven unreferenced. It always releases the in-process lease even when removal fails and returns `Clean` or `CleanupIncomplete`. |
| `OutcomeWriter.commit(entry)` | coordinator / outcome adapter | Consumes the closed entry containing `result.cbor` and the required optional Failed `processing.record`; atomically replaces only the validated key-20 entry, returns `Committed` or `ResultCommitFailed`, leaves its prior entry unchanged on failure, and never changes a published release. |

Publication exposes Authority pack, Client pack, and processing record together
or none. The final release entry contains exactly those three files and is
independent of staging after the atomic rename. Retry with the same release
identity and all three exact complete-file digests returns
`ExistingReleaseReused`; any mismatch returns `IdentityConflict` without
overwrite, merge, rename, or partial replacement. `Ambiguous` yields failed
result code 9, preserves staging, and prohibits automatic retry.

Publisher outcomes have this closed routing: `ExistingReleaseReused` commits a
Committed result with diagnostic `1` and skips durability/commit;
`IdentityConflict` commits Failed code `8`; `Busy`, preparation/durability
failure, or `NotCommitted` commits Failed code `7`; `Ambiguous` commits Failed
code `9`; `Committed` proceeds to marker transition and a Committed result; and
marker-transition failure preserves that Committed result but adds diagnostic
`5`. No other mapping or retry is permitted.

Recovery always precedes final-release comparison under the same lease. If a
valid current-job Incomplete orphan coexists with an equal published release,
preparation first deletes the orphan, adds `RecoveredStagingRemoved`, then
returns `ExistingReleaseReused`. If staging is instead preserved, preparation
records its exact preservation diagnostic and still performs the read-only
final-release comparison: an equal release is reused, an unequal release is an
`IdentityConflict`, and only absence or unreadability of the final release is
`PublicationRejected`. No preservation case permits creation of new staging or
a release write. Reuse performs no staging/candidate/release write and the
outcome writer still commits the new result.

`DC-COOKER-011` incorporates the following marker and recovery contract. Every
prepared staging directory is named by lowercase hexadecimal SHA-256 of the
exact Cooking Job Specification bytes and contains an atomically created file
`.sacramento-owner.cbor`. Its closed deterministic-CBOR marker is `{0: version,
1: job identity, 2: job-specification digest, 3: release identity, 4: state}`:
version is `1`, identities use `Identity`, the digest uses `Digest`, and state
is `1` Incomplete or `2` Published. A marker proves ownership only when its
directory name equals the lowercase hexadecimal encoding of field 2, fields 1
through 3 equal the supplied retry job, its bytes are canonical, its state is
Incomplete, the directory contains only `.sacramento-owner.cbor` and a
`candidate/` directory containing exactly `authority.pack`, `client.pack`, and
`processing.record`, the three complete-file digests equal the candidate
digests, and no durable release entry refers to it. Recovery deletes
only a directory satisfying all conditions. Recovery examines only the single
current-job path `<ReleasePublisher destination>/.sacramento-staging/<job-specification-digest>`;
it never scans or mutates a sibling. Failure to acquire the exclusive lease
returns `PublicationRejected`. Failure under the held lease to read,
permission-check, or classify every staging entry preserves every byte and
records `UncertainStagingPreserved`; it may then perform only the independent
read-only final-release comparison and the routing declared above. A different
directory name or a valid marker for another job adds
`ForeignStagingPreserved`; malformed or
noncanonical marker bytes, an unknown marker value, or a digest mismatch adds
`CorruptStagingPreserved`; a current valid marker with a missing/extra entry,
Published state, or durable-release reference adds
`UncertainStagingPreserved`. Every preserved byte remains unchanged.

The marker starts Incomplete before the first candidate write. Atomic release
commit moves only `candidate/`; the marker remains in staging and the release
entry no longer references staging. The live lease holder then atomically
changes the marker to Published; a failure in that bookkeeping preserves the
release, adds `CleanupPending` to the result about to be committed, and leaves
the marker ownership-uncertain for later inspection. In stage 10 the live lease
holder may remove its own proven Incomplete staging after `NotCommitted` or a
pre-publication Failed result, and its own Published staging after `Committed`;
it preserves staging after `Ambiguous`. Recovery never removes Published state.

`DC-COOKER-009`, `DC-COOKER-010`, and `DC-COOKER-012` incorporate the
following terminal rule. Result commit precedes cleanup exactly as required by
ARCHSPEC-0013. Stage 10 is always attempted: it destroys the owned snapshot and
signing handle and calls publisher cleanup whenever a `PublicationSession`
exists.

A stage-10 cleanup failure after a successfully committed Cooking Job Result
leaves that result and any published release byte-identical, emits only the
non-authoritative diagnostic `PostResultCleanupIncomplete`, releases the
in-process lease, and exits `40`; it is not a job failure and cannot be added
retroactively to result diagnostics. If result commit itself failed, cleanup is
still attempted, exit `30` has precedence over cleanup exit `40`, and cleanup
failure emits only `PostResultCleanupIncompleteAfterResultCommitFailure` while
leaving the prior result destination unchanged. A pre-result primary failure
that did commit its Failed result likewise cannot be reclassified by cleanup.
Secret key bytes never cross Signer or enter result, record, marker, or
diagnostics.

## Design commitments

- `DC-COOKER-001`: Content Cooker MUST remain one finite offline invocation
  with no runtime lifecycle surface.
- `DC-COOKER-002`: one closed immutable Cooking Job Specification selected by
  its absolute invocation path and exact bytes MUST be the sole source of every
  execution-affecting value.
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
- `DC-COOKER-009`: the result interface MUST make a committed atomic Cooking
  Job Result the sole authoritative job result while leaving invocation and
  result-commit failures explicitly distinguishable without a fallback result.
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
- `DC-COOKER-015`: the coordinator MUST validate and use exactly the immutable
  project-owner-approved processing gate referenced by the job.
- `DC-COOKER-016`: every successful cook MUST produce the complete Passed
  processing-record population declared in this SDD and the exact approved gate schema.
- `DC-COOKER-017`: every output and source MUST have the exact complete mapping
  or gate-defined `NoOutput` disposition declared in this SDD.
- `DC-COOKER-018`: signing and publication MUST begin only after every exact
  processing-gate criterion and complete input, output, mapping, and integrity
  check returns `Pass`.
- `DC-COOKER-019`: both role-pack envelopes MUST contain mutually consistent
  reciprocal release, Scenario, role, contract, identity, and digest bindings.
- `DC-COOKER-020`: the coordinator MUST submit only a complete twice-signed
  role-pack pair produced after gate admission for publication.
- `DC-COOKER-021`: each role pack MUST contain exactly its complete
  gate-and-contract-declared Resource closure with no cross-role or source-format
  dependency.
- `DC-COOKER-022`: every role pack MUST conform byte-for-byte to the fixed v1
  header, envelope, manifest, Resource Reference, Pack Core, and signing codec.
- `DC-COOKER-023`: every classified failed content-processing execution MUST
  atomically retain its complete Failed processing record with its Cooking Job
  Result.

## Rationale and trade-offs

A single closed job prevents ambient state from becoming undeclared provenance.
Full snapshotting costs transient space but removes source-race ambiguity.
One coordinator sacrifices parallel scheduling in v1 for deterministic order
and simpler failure precedence. ReleasePublisher is deep so atomicity and native
durability remain behind one contract instead of leaking filesystem operations.
An ambiguous publication is failed rather than retried because retry could
overwrite an already committed identity. The platform remains deferred because
choosing limits without native evidence would create false precision.
The record identifies signing authority but excludes detached signature bytes
because the accepted envelope binds the record digest before signing; this
breaks the otherwise impossible record→envelope→signature→record cycle while
retaining exact verification through each pack. Pack Core Digests bind the
pair, whereas complete-file digests govern byte-identical publication retry.
Renaming a closed `candidate/` child makes the published entry independent of
the marker so post-commit bookkeeping and cleanup cannot mutate it.

| Commitments | Rationale allocation |
| --- | --- |
| `DC-COOKER-001`, `DC-COOKER-009` | Keep offline work finite, give callers one authoritative committed result, and make pre-result failure absence explicit. |
| `DC-COOKER-002`, `DC-COOKER-006`, `DC-COOKER-008` | Make selection explicit, eliminate ambient input, and make bytes and provenance reproducible. |
| `DC-COOKER-003`, `DC-COOKER-010` | Remove live-source races and scheduler-dependent ordering. |
| `DC-COOKER-004`, `DC-COOKER-005`, `DC-COOKER-011`, `DC-COOKER-014` | Preserve atomic visibility, idempotency, and preceding releases across failure and retry. |
| `DC-COOKER-007` | Avoid claiming a native platform before a governed selection and execution evidence exist. |
| `DC-COOKER-012` | Give every classifiable job failure one deterministic result and keep post-result cleanup separate. |
| `DC-COOKER-013` | Keep secret material inside the only adapter authorized to handle it. |
| `DC-COOKER-015`, `DC-COOKER-018` | Prevent processing, signing, or publication under the wrong gate or any non-Pass criterion. |
| `DC-COOKER-016`, `DC-COOKER-017` | Make provenance and source-to-output trace complete rather than an implementation-local record choice. |
| `DC-COOKER-019`, `DC-COOKER-020` | Make the pair mutually self-identifying and prohibit usable unsigned or half-signed output. |
| `DC-COOKER-021` | Prove role completeness and headless/source-format closure rather than treating declared output mappings as sufficient. |
| `DC-COOKER-022` | Keep the type-independent pack wrapper, optional-reference encoding, and dependency-ordered physical layout identical across cooker, runtime loader, platforms, and tests. |
| `DC-COOKER-023` | Pre-reserve an explicit gate-checked bound so every processing failure can preserve criterion-level provenance instead of retaining only its summary result. |

## Acceptance criteria

Evidence retains specification/result bytes, complete source manifest and
snapshot digests, ordered stage trace, fault point, publisher state, output
directory listing, secret scan, capacity high-water, executable identity, and
native environment when applicable.

| Criterion | Preconditions and stimulus | Required and prohibited observation |
| --- | --- | --- |
| `DAC-COOKER-001` | Inspect invocation and attempt runtime interaction/residency. | One invocation terminates once; it has a committed outcome entry except for the explicit intake/outcome-writer failures in criterion 9; no runtime contract, endpoint, LAN, or second job exists. |
| `DAC-COOKER-002` | Hold the absolute specification path and bytes fixed while varying cwd, environment, defaults, discovery results, unlisted files, and extra CLI arguments; separately place the bytes at another absolute path; exercise every equality/ancestor/symlink overlap and key-reference path. | Ambient variations have zero output effect and extra arguments reject; the copied file is a different selected specification whose relative paths resolve only from its own parent; every overlap commits `SpecificationRejected` after routing and before snapshot/release output; the key is opened only at its explicit resolved path. |
| `DAC-COOKER-003` | Inject missing/unexpected/empty-directory/special/symlink/digest cases, pre-existing/add/remove/rename hard links, file mutation, directory-entry mutation, missing/misnamed/duplicate/invalid `.sacmeta.json`, copied canonical-source UUIDs, duplicate product/subresource UUIDs, every auxiliary-sidecar graph error, unavailable/change-varying file/directory tokens, `a` versus `ab/file`, and both Unicode 15.1 collision relations. | Every case fails before cooking; each source has one adjacent canonical metadata sidecar whose unique UUID/schema agrees with the job, all other declared UUIDs are unique, file link count is one, only component-prefix directories pass, final directory enumeration is identical, traversal is normalized byte order, and no valid snapshot rereads live input. |
| `DAC-COOKER-004` | Fail before/after each candidate-file durability point, marker durability/state transition, `candidate/` rename, atomic release-entry commit, and restart boundary. | Exactly the independent final entry with all three literal files or none is visible; it never references staging; marker/release relation has the declared state; preceding releases are byte-identical. |
| `DAC-COOKER-005` | Retry equal/unequal/absent/unreadable releases with initially absent staging and with each current-job staging class, including an equal release plus proven Incomplete orphan. | Recovery runs first; the proven-orphan/equal case deletes only the orphan and returns diagnostics `1,6`; every preserved-staging/equal case preserves it, returns diagnostic `1` plus the exact preservation code, writes only the outcome, and reuses the release; unequal uses criterion 14; preserved staging with no readable release is PublicationRejected and never creates staging/candidate/release bytes. |
| `DAC-COOKER-006` | Change OS account/clock while job provenance is fixed; mutate each provenance field and return Pass, Fail, Blocked, Stale, Uncertain, or missing from each named gate criterion. | Only syntactically valid values with both exact criterion results Pass are copied byte-for-byte; every other case rejects; ambient values never appear. |
| `DAC-COOKER-007` | Inspect package and run only test adapters. | No platform selection or native Pass is claimed; test results remain non-product evidence. |
| `DAC-COOKER-008` | Round-trip CCV-001..006; mutate key/order/type/bound/version/diagnostic/trailing bytes, each capacity including reserve greater than transient, each source/Resource UUID version/variant/length, signing descriptor, and duplicate identity/version/path. | Positive vectors and diagnostic arrays are identical; only the three-key capacity partition, 16-byte UUIDv4 source/Resource identities, mandatory metadata sidecars, complete versioned references, and the closed signing descriptor pass; every malformed value fails before source access or output. |
| `DAC-COOKER-009` | Exercise malformed/no-routing input, every pre/post-processing failure, outcome-writer error alone/with cleanup error, crash before/during/after outcome replacement, and stream claims. | Outcomes are exactly exit 20/no outcome, committed result plus required Failed record/exit 10, exit 30 with no new outcome, or complete Committed result; exit 30 wins over cleanup failure, the prior atomic outcome is unchanged, and streams establish neither artifact. |
| `DAC-COOKER-010` | Repeat identical cook; interrupt each ordered stage; fail stage-10 cleanup after Committed/Failed results and after outcome-writer failure. | ARCHSPEC-0013 stage order is exact and successful output bytes match; stage 10 is attempted after stage 9 when a session exists; cleanup failure leaves outcome/release unchanged and exits 40 only after a committed result, otherwise exit 30 wins; no cache or live reread is observed. |
| `DAC-COOKER-011` | Round-trip CMV-001; seed every marker mismatch, sibling, extra/corrupt entry, state/reference/error/lease case and each equal/unequal/absent release combination; exercise live cleanup. | Under one lease recovery precedes release comparison, deletes only the current-job proven-Incomplete unreferenced `candidate/`, adds diagnostic 6, and scans no sibling; preservation permits only read-only equal reuse or unequal conflict and blocks new publication when no release is readable; the live holder handles eligible Incomplete/Published/Ambiguous states exactly and releases its lease. |
| `DAC-COOKER-012` | Inject all failure codes, request cancellation before routing and inside/either side of every declared fence including stages 8–9, and return simultaneous result/cleanup faults. | Completed-operation failure wins at a fence, otherwise cancellation wins before stage 8; pre-routing cancellation exits 20, routed cancellation commits Interrupted, stages 8–9 discard deferred cancellation, numeric precedence resolves failures, exit 30 beats cleanup exit 40, and cleanup never changes a committed result. |
| `DAC-COOKER-013` | Inspect/sign successfully and fail, then scan interface values, memory handoff, record, result, marker, and diagnostics. | Only opaque handle, non-secret scheme/key identity, preimage, and detached signature cross their declared calls; zero private/public key bytes or secret material occur outside Signer or in retained surfaces. |
| `DAC-COOKER-014` | Publish an existing identity with each one-digest mismatch. | Result is IdentityConflict; existing and candidate publication locations remain unmodified. |
| `DAC-COOKER-015` | Substitute missing, unapproved, identity/version/digest-mismatched, schema-incomplete, and exact approved gate references. | Only the exact approved gate identity, version, digest, and schema reach processing; every other case is GateRejected before a Pack Core or signature. |
| `DAC-COOKER-016` | Remove or mutate each Passed-record population, expected signing descriptor, or criterion result; add own/complete-file/signature-derived data; violate schema; trace construction. | After all gate results Pass, exactly one non-circular Passed record is encoded before digest/envelopes/signatures; every omission, extra, mismatch, ambient value, unavailable/circular field is ProcessingRejected. |
| `DAC-COOKER-017` | Exercise each role-specific Resource declaration, shared product with two projection UUIDs, kind-1/kind-2 output edge, Map-derived edge, NoOutput disposition, duplicate, dangling, missing, and cross-role mismatch. | Every Resource UUID occurs once in its declared pack, shared products retain one common product identity with distinct role Resource UUIDs, every contributing sidecar has a direct edge, and every invalid graph is ProcessingRejected before signing. |
| `DAC-COOKER-018` | For every gate criterion/input/output/mapping/integrity class, return Pass and each non-Pass/absent/wrong-gate state while tracing cores, results, Passed/Failed record, envelopes, Signer, and publisher. | Success order is cores/representations, all-Pass, Passed record/digest, two envelopes, Signer, publisher; non-Pass produces the exact Failed record/outcome and zero signing/publication. |
| `DAC-COOKER-019` | Round-trip the `RPV-001` header/envelope and mutate each width/offset/length plus envelope version, release, Scenario/version, role, contracts, pack identities/Core Digests, manifest, record, scheme, key identity, and role order. | Only the exact 80-byte header, restricted 16-item envelope, contiguous regions, and two complete reciprocal ARCHSPEC-0012 bindings proceed; every mutation is ProcessingRejected before signing. |
| `DAC-COOKER-020` | Reproduce and mutate every `RPV-001` field; make key path unreadable/invalid, scheme/key identity unequal or inspect cancelled; request Ed25519ph; fail either sign; omit, resize, or corrupt either signature; and prepare after one signature. | Exact header/envelope/domains/key identity/preimage/signature/395-byte pack match the vector; inspect returns only the closed outcome and occurs after all-Pass record/envelopes; pure Ed25519 signs Authority then Client; only the verified twice-signed pair reaches publisher. |
| `DAC-COOKER-021` | For each role contract/type-inventory closure, omit every required Resource/dependency and inject every extra, wrong-role, client-only, counterpart-pack, source-format, sidecar, importer, and vendor dependency. | Each pack equals its exact transitive role closure; the Authority closure is headless; both closures are source-free and locally closed; every mutation is ProcessingRejected before record sealing. |
| `DAC-COOKER-022` | Round-trip RPV-001 and MRV-001/002; exercise a multi-resource dependency diamond, its ready-set identity tie, and a cycle; mutate every header/envelope/manifest-entry/reference position, optional alternative, manifest order, extent range/partition/physical order, codec, digest, Payload byte, and malformed MRV-003. | Exact fixed bytes re-encode identically, RPV signature/digests verify and reassemble to 395 bytes; the diamond extents are target-before-referrer with the exact identity tie-break; null/bare/multi-item optional forms, unknown lengths/codecs, duplicate/unsorted references, cycles, non-topological extents, gaps/overlaps and every mutation reject at the declared layer. |
| `DAC-COOKER-023` | Vary the gate-declared Failed-record maximum below/equal/above capacity-map key 2 and separately make it missing, non-exact, or unable to cover a maximum-size job population; after exact gate validation, fail every criterion and each processing operation through stage-7 candidate durability, including maximum job populations, partial criteria and Authority-only signing; separately fail publication and atomic outcome commit, then inspect retained bytes/listing and transient high-water. | An exact positive maximum below or equal to key 2 passes this capacity check when it covers every maximum-size job population; an above-reserve, missing, non-exact, or insufficient maximum is GateRejected before processing. Key 2 is reserved during stage 1 and all other transient use stays within key 1 minus key 2; every content-processing failure atomically retains one gate-conforming Failed record plus result with known/unavailable values and all criterion/signing dispositions; failures before or after the declared processing boundaries retain result only; a stage-8 failure does not alter or duplicate the candidate's Passed record; writer failure retains neither new outcome artifact and exits 30. |
