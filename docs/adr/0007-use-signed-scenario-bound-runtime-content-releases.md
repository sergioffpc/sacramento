# Use signed scenario-bound runtime content releases

Status: Accepted

Amendment: ADR-0008 supersedes this decision's former client-continuity exception.

Amendment: ADR-0009 defines the external launch, packaging, compatibility, readiness, update, rollback, and supervision contracts deferred by this decision.

Sacramento cooks every exact Scenario version into one immutable Runtime
Content Release containing an Authority Pack and a Client Pack. The two packs
are signed, cryptographically bound as one release, selected explicitly at
process start, validated and fully materialized before network readiness, and
never replaced during the process lifetime. Each Session Authority process
serves exactly one Scenario and one Training Session and then exits. This
deliberately favors a small, fail-fast, orchestration-neutral runtime over
in-process Scenario switching, content streaming, or live compatibility
negotiation.

## Release identity and composition

One Content Cooker execution produces exactly one Runtime Content Release for
one exact Scenario version. The release has one Sacramento-owned identity and
contains exactly:

- one Authority Pack with the complete closed content required by Simulation,
  Session Lifecycle, and the other applicable Session Authority modules; and
- one Client Pack with the complete closed content required by Prediction,
  Presentation, and the other applicable Trainee Client modules.

The release identity binds the exact Scenario, Map, Approved Profiles,
catalogues, other admitted inputs, role-specific runtime content contracts,
pack identities, and integrity hashes. Each pack binds the identity, role, and
hash of its counterpart. Data required by both roles may be represented in
both packs under the same Sacramento identity; client-only representation is
absent from the headless Authority Pack. Neither runtime needs the other
role's pack.

The pack codec and identity remain owned by Runtime Package. Vendor types,
source formats, Blender data, Assimp structures, Falcor scenes, Flecs values,
and other adapter representations do not enter a pack interface. The concrete
manifest schema, serialization layout, hash and signature algorithms, file
extension, and source-tree layout remain design decisions.

Changing any normative source, Approved Profile, catalogue, relevant tool or
configuration, runtime payload, content contract, or processing provenance
creates a new release identity and a newly signed pair. A published pack is
never updated in place. An unchanged role payload may be reused internally by
the cooker, but the resulting pack remains a member of the new paired release
and receives the new release binding.

## Cooking, admission, and signing

The Content Cooker accepts only an exact canonical-source closure and one
approved content-processing gate version. Its private source-import adapters
produce Sacramento data and never survive in a pack or runtime closure. One
job performs this ordered workflow:

1. identify every canonical source, Approved Profile, catalogue, dependency,
   pipeline, tool, and configuration version;
2. validate every gate criterion and source-to-output mapping;
3. deterministically produce both complete role packs as private candidates;
4. materialize and validate the common release and reciprocal pack bindings;
5. produce the complete versioned processing record;
6. sign both packs with the cooker host's configured content-signing key; and
7. publish the complete pair as one usable release outcome.

Any missing, stale, uncertain, corrupt, incompatible, or failed input or
criterion fails the job. Loss of the cooker, resource exhaustion, failure to
produce either role, failure to sign either role, or inability to prove the
complete pair likewise produces no usable release. Candidate output is not a
fallback or a partially deployment-ready pack. Already published releases
remain unchanged.

The signed release binds the identity and digest of its complete processing
record, approved gate, sources, tools, and configuration. Full source and
evidence material remains outside runtime packs in its governed evidence
repositories; runtimes need only the non-sensitive identity and integrity
references required for traceability.

Signing is the authoritative content-admission decision. Content Admission on
each host performs no second discretionary approval: it enforces the signed
decision by validating and atomically activating the exact local bytes.

## Trust and compatibility

Each runtime receives a versioned Content Signing Trust Reference independently
of the pack. It maps authorized signing keys to the exact Authority Pack or
Client Pack roles and runtime content contracts that each key may sign. A pack
cannot introduce or authorize its own trust root, and no live network lookup
or negotiation supplies content trust.

Compatibility is admitted through signature validation against that scoped
trust reference. A cryptographically valid signature from a key not authorized
for the pack's role and exact runtime content contract is incompatible. There
is no version range, format negotiation, translation, migration, backward
compatibility, forward compatibility, or automatic fallback. Structural or
materialization failure of an otherwise authorized pack remains a startup
failure because it demonstrates a defective or unusable artifact rather than
an admitted compatibility path.

The cooker holds its content-signing private key in its filesystem without an
additional Sacramento control. This keeps the baseline small but makes the
cooker host and access to that key part of the trusted computing base. The
signature protects runtime hosts from accidental corruption and unauthorized
pack replacement only while that key remains controlled. Compromise of the
cooker or copying the key permits indistinguishable forged packs. Recovery
requires a new Content Signing Trust Reference and new releases; it cannot
retroactively distinguish a forged pack signed by the compromised key.

A trust-reference change affects only new process starts. A running process
continues with its already validated immutable content view. A release whose
key is no longer authorized cannot start a new process.

## Runtime ownership and startup

An external deployment action places packs and Content Signing Trust
References in a filesystem. It owns copying, availability, retention, and
removal. A runtime receives the exact role-pack path as immutable launch
configuration; it does not scan a directory, choose the newest file, or try an
alternative. The filesystem adapter remains private to Runtime Package.

Runtime Package validates persistent identity, codec structure, signature,
signer authorization, role, runtime content contract, reciprocal pair binding,
and integrity. Content Admission owns candidate activation state and performs
the remaining complete validation and materialization behind its Sacramento
interface. On success it publishes exactly one immutable identified view for
the process. Simulation, Prediction, and Presentation consume that view and do
not parse packs, verify signatures, access source formats, or inspect
filesystem state.

The Session Authority completes pack validation and materializes every
required resource before publishing readiness or accepting a connection. A
Trainee Client does the same before initiating its connection. Missing input,
an invalid signature, unauthorized signer, wrong role or content contract,
broken pair, malformed structure, integrity failure, missing dependency, or
materialization failure is process-fatal during startup. The process emits a
stable non-sensitive error classification, releases initialized resources,
and exits non-zero; it neither stays partially ready nor tries a predecessor.

After activation, the process uses only its immutable materialized view. It
does not reread, poll, stream, patch, or replace the pack. Changing or removing
the backing file has no effect on the running process and is detected only by
a later start. Content I/O therefore cannot become a Canonical Tick,
Prediction, or Presentation barrier.

## Pair matching and Admission

After a client authenticates the Session Authority and before it presents its
own identity or creates an Admission, the authority identifies the exact
Runtime Content Release, Scenario, and Authority Pack and Client Pack hashes.
The client continues only when its locally activated Client Pack proves the
same pair identity. A mismatch terminates the connection attempt with the
stable content-mismatch outcome before Admission. Neither peer negotiates,
downloads, swaps, or guesses another release.

Every Admission, Training Session state version, deterministic reconstruction
record, result, and applicable evidence identifies the exact Runtime Content
Release. Session-specific roster, identity, Team Position, Loadout selection,
Ready, Intention, and canonical simulated state remain live state rather than
pack overrides.

## One-Scenario, one-session processes

One Session Authority process receives one Authority Pack, serves its one
Scenario, and owns exactly one Training Session over its lifetime. It never
returns to Preparation for a second Training Session and never activates
another Scenario. One Trainee Client process likewise receives one Client Pack
and participates in only that Training Session. Joining another Training
Session or Scenario requires a fresh process with the corresponding pack and
endpoint.

Completion or termination begins orderly shutdown. The authority first fixes
and publishes the terminal result and required reconstruction evidence, ends
Admissions, settles required AUTH audit and bounded Observability work, and
then exits. Unexpected authority loss ends the Training Session. A replacement
process using the same Authority Pack creates a new Training Session and never
restores the prior live state.

Client process loss ends that client's active participation. During Active the
Session Authority applies Technical Removal with cause `Disconnected`; before
Active it ends the Admission and releases preparation state. A new client
process cannot reclaim that Admission or join the existing Training Session.

This process contract deliberately exposes a small orchestration seam: exact
immutable launch configuration, readiness, the connection endpoint, stable
runtime and Training Session identities, terminal results, and process exit.
It does not depend on Kubernetes or another orchestrator. Scheduling,
discovery, autoscaling, volumes, pod shape, physical-host density, redundancy,
and high availability remain later deployment decisions. Multiple independent
Session Authority processes may serve the same Scenario concurrently, with
each process retaining exactly one Training Session containing exactly two
Teams.

## Retention, rollback, and cleanup

Runtimes never create, mutate, or delete packs. Multiple processes may read the
same immutable pack concurrently, while each owns its separate materialized
view and mutable Training Session state. The cooker removes its incomplete
candidates; external deployment policy owns published-pack retention and
cleanup. No retention period, cache bound, or resource ceiling is approved by
this decision.

An operator may start a new process with an older release only by selecting it
explicitly and only while it remains approved, signed by a currently
authorized key for the exact role and content contract, and otherwise valid.
Automatic rollback and fallback are not admitted.

## Representative sequences and failure behavior

A successful cook validates the exact canonical closure, produces both packs
deterministically, creates the processing record and reciprocal bindings,
signs both roles, and publishes one release. A failure before complete pair
publication exposes no usable successor.

A successful authority start receives one explicit Authority Pack path and
trust reference, validates and fully materializes the pack, atomically
publishes its immutable content view, initializes the remaining owners, and
only then reports readiness and accepts connections. A successful client start
does the equivalent for its Client Pack before connecting. Connection then
authenticates the authority, matches the exact pair, and only afterward may
continue toward Admission.

A partial deployment is contained locally. An invalid Authority Pack prevents
that process from becoming ready. An invalid Client Pack prevents that client
from connecting. Two individually valid packs from different releases fail
pair matching before Admission. No failure mutates canonical state, affects an
unrelated Session Authority process, or causes a runtime to select another
pack.

Live file replacement, deletion, or trust-reference rotation cannot alter an
active Training Session because the content view is already materialized and
immutable. Authority loss terminates only its Training Session. Client loss
uses the phase-appropriate Admission end or Technical Removal path. Normal
completion publishes and settles its terminal truth before the ephemeral
process exits.

## Verification and evidence

The Runtime Package and Content Admission interfaces support controlled
missing, stale, corrupt, wrong-role, unauthorized-signer, wrong-contract,
broken-pair, malformed, capacity-exhaustion, materialization-failure, and
process-loss outcomes through test adapters. Verification covers failure
before and after each cooking step, each role signature, pair publication,
runtime validation, immutable-view publication, connection matching, terminal
result publication, and shutdown settling.

Cook, startup, connection, Admission, Training Session, and terminal evidence
correlates the exact gate, processing record, release, Scenario, role-pack
identities and hashes, runtime content contracts, Content Signing Trust
Reference, build, and Training Session without exposing assets. Deterministic
replay compares Sacramento records and digests rather than filesystem paths,
logs, or vendor data. Executable-closure audits continue to prove that source
importers and client-only content dependencies are absent from the authority.

No prototype blocks this decision because it selects semantic ownership,
identity, trust, and lifecycle rather than a signature algorithm, file format,
storage engine, or deployment mechanism. Production admission still requires
cryptographic test vectors, malformed-input and failure-injection evidence,
representative resource evidence for eager materialization, and native
authority/client closure verification.

## Requirements impact

This decision replaces the earlier assumption of a reusable Session Authority
process. Requirements for automatic session repetition, in-process Scenario
selection, retention into another Training Session, and keeping a mismatched
client in Preparation must be aligned with the one-session process and
pre-Admission mismatch result.

The existing rolling availability target for one continuously monitored
Session Authority process is incompatible with intentionally ephemeral
processes. A later deployment decision must define availability of the
capability to start and operate an assigned Session Authority. This ADR does
not invent that measure or choose an orchestrator. Until then, physical-host
placement and density remain governed by the existing acceptance profiles and
dedicated-host constraint.

## Considered options

- Loose independently selected assets were rejected because their aggregate
  identity, compatibility, and provenance could not be proved at Admission or
  replay.
- One monolithic cross-role pack was rejected because it would place
  client-only presentation content in the headless authority closure.
- A persistent authority that changes Scenarios or repeats sessions was
  rejected in favor of one small process that does one assigned job and is
  replaceable by later orchestration.
- Runtime download, streaming, hot replacement, directory scanning, version
  negotiation, and automatic fallback were rejected because they enlarge the
  state and failure surface and weaken exact-content evidence.
- A separate signing system was rejected for the initial baseline in favor of
  cooker-local signing and its explicitly accepted trust limitation.
- Making Simulation, Prediction, or Presentation validate persistent packs was
  rejected because it would duplicate a shallow mechanism-shaped interface
  and leak filesystem and cryptographic knowledge into behavior owners.

## Consequences

The runtime path is small and deterministic: one explicit pack, one validation
and activation, one immutable view, one Scenario, one Training Session, and
one terminal process outcome. Role-specific packs preserve headless closure,
signed pair identity makes compatibility and cross-host matching auditable,
and eager materialization removes content I/O from timing-critical paths. The
process contract is compatible with future orchestration without depending on
it.

The trade-offs are whole-pair recooking for every relevant change, eager
startup resource cost, fresh processes and Admissions for every Training
Session, no live content correction, and an accepted signing-key compromise
risk on the cooker host. Requirements and operational availability semantics
must be updated to reflect ephemeral authority processes.

This decision resolves issue #33 and traces principally to
`REQ-CONTENT-PROCESSING-GATE-001` through `REQ-CONTENT-RETENTION-001`,
`REQ-PROFILE-RECORD-001` through `REQ-PROFILE-CHANGE-HISTORY-001`,
`REQ-INITIAL-START-CONDITIONS-001`, `REQ-READINESS-PRECONDITION-004`,
`REQ-AUTHORITY-SINGLE-SESSION-001` through
`REQ-SESSION-TERMINATION-STATE-001`, `REQ-SERVER-SESSION-001`,
`REQ-AUTHORITY-SCENARIO-BINDING-001`, `REQ-SESSION-SCENARIO-001`,
`REQ-STATE-CONSISTENCY-001`, `CONSTRAINT-MAP-AUTHORING-001`,
`CONSTRAINT-SCENARIO-SEPARATION-001`,
`CONSTRAINT-CONTENT-DISTRIBUTION-001`,
`NON-GOAL-CONTENT-DOWNLOAD-001`, `NON-GOAL-CONTENT-MIGRATION-001`,
`NFR-ACTION-RESPONSE-001`, and `CONSTRAINT-NFR-TEAM-001`.
