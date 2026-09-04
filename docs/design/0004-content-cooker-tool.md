# SDD-0004: Content Cooker Tool

Status: Approved design; realization and evidence remain incomplete

Approval: Project owner, 2026-09-04

Purpose: Define the finite offline executable that cooks one authoring closure
into one atomically published Runtime Content Release.

Scope: CLI, Cooking Job Specification and Result, input snapshot, deterministic
workflow, release publication, retry, signing, provenance, and cleanup.

Intended readers: Content-pipeline designers, implementers, verification
authors, release operators, and security reviewers.

Prerequisites: SDB-001, SAD-003, ADR-0013, ARCHSPEC-0007, ARCHSPEC-0012,
and ARCHSPEC-0013.

Canonical information owner: Content Cooker Tool.

## Tool boundary

The sole product invocation is:

```text
content_cooker --job <specification-path>
```

The path locates one restricted deterministic-CBOR Cooking Job Specification.
No other command-line option, environment variable, current directory,
directory discovery, or mutable default may affect the job. Standard output
and standard error are diagnostics only. The atomic Cooking Job Result file is
the authoritative terminal result.

The tool is not a runtime. It has no Runtime Launch Specification, Process
Control Contract, Process Lifecycle State, endpoint, Admission, Controlled LAN
dependency, supervisor, or resident multi-job mode. Its executable closure is
a Tool Release. Platform, Reference Hardware Profile, native environment,
packaging, and distribution remain unselected.

## Closed job specification

The exact schema contains: contract version; Cooking Job and Tool Release
identities; authoring-root location; complete normalized source-entry list with
kind, digest and sidecars; processing-gate identity; catalogue and Approved
Profile identities; tool and configuration identities; Runtime Content
Release, Authority Pack, Client Pack, processing-record, and Resource output
identities; signing-key reference; Release Publisher destination; persistent
and transient capacity limits; executor and execution-instant values with
source, authority, format, and trust classifications; and Cooking Job Result
destination. Unknown, duplicate, missing, noncanonical, or out-of-range fields
fail before source capture.

Output names derive only from supplied identities. The tool never invents an
identity or obtains provenance from the OS account or uncontrolled wall clock.

## Snapshot and workflow

The source adapter walks exactly one `authoring/` root in normalized
deterministic order without following symlinks. Every filesystem entry must be
listed and classified. Missing, unexpected, special, out-of-root,
case-colliding, Unicode-colliding, digest-mismatched, or changing input fails
the complete job. A private immutable snapshot is completed before cooking;
subsequent stages never read the live authoring root.

One coordinator performs: specification validation, snapshot, gate/input
validation, both deterministic Pack Cores, complete processing record,
reciprocal envelopes, both signatures, durability, release publication,
Cooking Job Result commit, and owned-staging cleanup. There is no incremental
cache or configurable scheduler in the initial design.

Private operations return closed Sacramento results or move-only prepared
values. Cancellation is observed at declared boundaries. Deterministic primary
failure precedence and bounded secondary diagnostics apply. Exceptions are
contained at the tool boundary.

## Release Publisher and retry

`ReleasePublisher` is a deep interface for private same-domain staging,
complete-candidate durability, and atomic publication of one release entry. It
does not expose general filesystem operations. Publication makes the Authority
`.pack`, Client `.pack`, and processing record visible together or exposes none
of them.

Retry with the same release identity and exact three output digests succeeds
idempotently with the existing release. Any mismatch is `IdentityConflict` and
cannot overwrite, merge, rename, or partially replace it. A publication attempt
must resolve to `Committed` or `Not Committed`; ambiguity produces a failed,
non-accepted result and prevents automatic retry.

Recovery removes only incomplete staging whose ownership is proved. Committed,
corrupt, or ownership-uncertain material is never deleted. There is no
incremental cache in this baseline.

The signing adapter accepts a key reference and returns signatures and the
non-secret signing-key identity. Secret key bytes never cross the seam or
appear in the processing record, result, or diagnostics.

## Design commitments

- `DC-COOKER-001`: the Content Cooker MUST remain a finite offline tool with no
  runtime lifecycle surface.
- `DC-COOKER-002`: one closed immutable Cooking Job Specification MUST be the
  sole source of every execution-affecting value.
- `DC-COOKER-003`: cooking MUST consume one completely validated immutable
  snapshot of an exhaustively classified authoring root.
- `DC-COOKER-004`: Release Publisher MUST durably publish both packs and the
  processing record through one atomic release entry.
- `DC-COOKER-005`: retry MUST be idempotent only for exact identity/digest
  equality and MUST otherwise return `IdentityConflict` without overwrite.
- `DC-COOKER-006`: the tool MUST copy validated provenance from the job
  specification and keep signing secrets private.
- `DC-COOKER-007`: this baseline MUST NOT select a Content Cooker execution
  platform or accept test adapters as product evidence.

## Verification design

Golden CBOR vectors, hostile-input tests, traversal/snapshot mutation tests,
repeat-cook byte comparison, capacity and cancellation injection, signing
failure, secret scanning, every durability/publication boundary, exact retry,
identity conflict, staging recovery, result atomicity, and interface inspection
cover the design. Release Publisher implementations share one contract suite;
native platform acceptance waits for the deferred platform decision.
