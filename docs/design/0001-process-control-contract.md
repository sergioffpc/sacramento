# SDD-0001: Process Control Contract

Status: Candidate successor design; project-owner approval pending

Last meaningful change: 2026-09-05

Purpose: Define the exact process-control, bootstrap, Runtime Launch
Specification, startup, failure, and acceptance contracts shared by Session
Authority and Trainee Client executables.

Review focus: Changed runtime semantics and verification criteria under ADR-0014;
no fixed reviewer count or full-package reread is required for a routine edit.

Owner: Runtime composition.

## Boundary and ownership

The Process Control codec is a deep module whose callers exchange one complete
Sacramento message. It owns framing, deterministic payload encoding,
incremental read assembly, bounded write assembly, schema validation, and
stable codec errors. A native pipe adapter owns handles and partial operating-
system I/O but does not interpret messages. Runtime composition owns lifecycle
policy. Standard output carries Process Control only; Observability and
diagnostics use separate launch-selected adapters.

The interface has no negotiation, fallback, reconnection, supervisor, JSON,
Protobuf, generic CBOR object model, or native platform type. It uses only the
closed deterministic-CBOR schemas below.

## Common codec

`DC-PROCESS-008` incorporates this table and every schema and vector in this
SDD.

| Type | Exact v1 representation |
| --- | --- |
| `uint` | RFC 8949 unsigned integer in shortest encoding. |
| `null` | Exact byte `f6`. |
| `Identity` | NFC UTF-8 text, 1–128 bytes, with no control, slash, backslash, or NUL. |
| `Path` | Portable relative path encoded as NFC UTF-8 text, 1–4,096 bytes. `/` is the only separator; the first byte is not `/`; each segment is nonempty and is neither `.` nor `..`; no segment contains NUL, `\`, or a control character. Resolution is lexical concatenation to the canonical directory containing the owning specification followed by a containment check; escape and symlink traversal are rejected. The resolved host path is never re-encoded into a governed identity. |
| `Endpoint` | NFC UTF-8 text, 1–512 bytes, with no control or whitespace. |
| `Digest` | Exactly 32 SHA-256 bytes. |
| `IdentityList` | Definite array of 1–64 unique identities sorted by encoded bytes. |
| `DestinationList` | Definite array of 0–32 unique paths sorted by encoded bytes. |

Every CBOR value uses RFC 8949 Core Deterministic Encoding: definite lengths,
shortest forms, unsigned map keys in ascending encoded order, and no tag,
float, negative integer, duplicate key, unknown key, trailing byte, or nesting
deeper than eight. Hard encoded limits are 4,072 bytes per Process Control
payload, 8 KiB per Runtime Bootstrap, and 64 KiB per Runtime Launch
Specification.

## Bootstrap and Runtime Launch Specification

The only invocation forms are:

```text
session_authority --bootstrap <bootstrap-path>
trainee_client --bootstrap <bootstrap-path>
```

`<bootstrap-path>` is one absolute host path. Relative paths, an empty path,
more or fewer arguments, and option aliases are rejected before file access.
The executable opens that exact path without search; therefore environment and
current-directory state cannot affect selection. The canonical bootstrap
directory is the parent of the opened file after the host has resolved the
absolute path without following a final symlink. The immutable Runtime
Bootstrap is this closed map:

| Key | Field | Type and rule |
| --- | --- | --- |
| `0` | contract version | `uint`, exactly `1` |
| `1` | Process Execution Identity | `Identity` |
| `2` | Runtime Launch Specification path | `Path`, relative to the canonical bootstrap directory |
| `3` | expected specification identity | `Identity`, equal to launch key `1` |
| `4` | expected specification digest | `Digest`, equal to SHA-256 of launch bytes |

Every Runtime Launch Specification contains:

| Key | Field | Type and rule |
| --- | --- | --- |
| `0` | contract version | `uint`, exactly `1` |
| `1` | specification identity | `Identity` |
| `2` | role | `1` Authority or `2` Client |
| `3` | Process Execution Identity | `Identity`, equal to bootstrap key `1` |
| `4` | Application Release identity | `Identity` |
| `5` | Runtime Content Release identity | `Identity` |
| `6` | role-pack path | `Path` |
| `7` | role-pack identity | `Identity` |
| `8` | role-pack digest | `Digest` |
| `9` | Content Signing Trust Reference path | `Path` |
| `10` | Deployment Compatibility Matrix identity | `Identity` |
| `11` | Approved Profile identities | `IdentityList` |
| `12` | configuration identity | `Identity` |
| `13` | selected endpoint | `Endpoint` |
| `14` | capacity map | Closed map below |
| `15` | AUTH mode | `1` Development or `2` Production |
| `16` | Synthetic Identity map | Role-specific map in Development; `null` in Production |
| `17` | Observability Contract identity | `Identity` |
| `18` | external custody destinations | `DestinationList` |
| `19` | graceful-shutdown bound | `uint` milliseconds, `1..600000` |

Capacity-map keys `0..7` occur exactly once: inbound-control frames,
outbound-control frames, terminal-control frames, control assembled bytes,
Observability bytes, transport bytes, role-private prepared bytes, and retained-
evidence bytes. Frame counts are `1..65535`, terminal frames have minimum `3`,
assembled bytes have minimum `8192`, and byte counts are `1..2^40`. Client
retained-evidence uses `1` as its non-applicable sentinel reservation.

Authority launch maps add keys `20..24`: Training Session identity, Scenario
identity, Session Authority Identity, required-capability-policy IdentityList,
and terminal-settlement destination Path. Client maps add keys `20..25`: target
Training Session identity, expected Session Authority Identity, required-device
IdentityList, required-output IdentityList, retry map, and departure-confirmation
bound `1..600000` ms. Retry keys are maximum attempts `1..16`, initial delay
`0..60000` ms, backoff numerator and denominator `1..16`, and total bound
`1..600000` ms. SDD-0003 defines the sole interpretation of these values.

Development AUTH requires a closed Synthetic Identity map: Authority key `0`
is its Session Authority Synthetic Identity; Client keys `0` and `1` are
Trainee and Client Device Synthetic Identities.

## Frame and payload codec

Every frame has this 24-byte network-byte-order header:

| Offset | Bytes | Field | Exact value or bound |
| ---: | ---: | --- | --- |
| 0 | 4 | magic | ASCII `SACP`, hex `53 41 43 50` |
| 4 | 1 | major | `01` |
| 5 | 1 | minor | `00` |
| 6 | 2 | kind | `0001` ShutdownRequest, `0002` ProcessState, `0003` CommandAcknowledgement |
| 8 | 4 | payload length | `0..4072`, exact following bytes |
| 12 | 8 | correlation | Nonzero for command/acknowledgement; zero for state |
| 20 | 2 | flags | `0000` |
| 22 | 2 | reserved | `0000` |

Maximum frame size is 4,096 bytes. EOF at a frame boundary is channel loss;
EOF within a frame is `TruncatedFrame`. Invalid header, payload, or schema is
`InvalidFrame`. Neither is recoverable on that channel.

`ShutdownRequest` is `{0: reason}`: `1` Requested, `2` Maintenance,
`3` ResourcePressure, or `4` Administrative. `CommandAcknowledgement` is
`{0: disposition}`: `1` Accepted, `2` Duplicate, or `3` RejectedStopping.

`ProcessState` contains every key; inapplicable values are `null`:

| Key | Field | Closed value |
| --- | --- | --- |
| `0` | state | `1` Starting, `2` Ready, `3` NotReady, `4` Stopping, `5` Terminated |
| `1` | role | `1` Authority, `2` Client |
| `2` | Process Execution Identity | `Identity` |
| `3` | launch identity | `Identity` |
| `4` | launch digest | `Digest` |
| `5` | capacity | `0` NotYetReserved, `1` Reserved, `2` Rejected |
| `6` | readiness failure | `null` or `1..10` in the order below |
| `7` | Training Session identity | `null` or `Identity` |
| `8` | endpoint | `null` or `Endpoint` |
| `9` | settlement identity | `null` or `Identity` |
| `10` | terminal reason | `null` or `1..8` in the order below |
| `11` | exit code | `null` or exact projection below |

Readiness codes are, in order, `LaunchSpecificationRejected`,
`CompatibilityRejected`, `InputClosureRejected`, `CapacityRejected`,
`AdapterRejected`, `MaterializationRejected`, `EndpointRejected`,
`ControlChannelRejected`, `StartupInterrupted`, and `InternalFailure`.
Terminal codes are, in order, `WorkCompleted`, `ShutdownRequested`,
`RequiredPeerLost`, `ControlChannelLost`, `RequiredCapabilityLost`,
`CanonicalIntegrityLost`, `SettlementFailed`, and `InternalFailure`.

| Exit | Exact projection |
| ---: | --- |
| `0` | WorkCompleted |
| `10` | ShutdownRequested |
| `20` | Any readiness rejection |
| `30` | RequiredPeerLost or RequiredCapabilityLost |
| `40` | CanonicalIntegrityLost or SettlementFailed |
| `50` | ControlChannelLost |
| `70` | InternalFailure |

Starting requires capacity `0` and null conditional fields. Ready requires
capacity `1`, no failure or terminal fields, and role-applicable session and
endpoint. NotReady permits capacity `0`, `1`, or `2`, requires one readiness
failure, and has no endpoint, terminal reason, settlement, or exit. Stopping
requires capacity `1`, null readiness failure, one terminal reason, and null
exit. Terminated has exactly one of two forms: readiness termination preserves
the NotReady failure and capacity, has null terminal reason and settlement, and
uses exit `20`; runtime termination has null readiness failure, one terminal
reason and its exact exit, and preserves capacity `1`. Authority supplies a
settlement identity only when Preparation committed and settlement produced an
identity; all other cases use null.

## Normative golden vectors

Spaces are non-data. Decode then encode produces identical bytes.

| ID | Exact hexadecimal bytes | Result |
| --- | --- | --- |
| `RBV-001` | `a5000101617002666c61756e636803616c0458200000000000000000000000000000000000000000000000000000000000000000` | Complete bootstrap: process `p`, path `launch`, launch identity `l`, zero digest. |
| `RLV-001` | `b819000101616c020103617004616105617206647061636b0761710858200000000000000000000000000000000000000000000000000000000000000000096574727573740a616d0b8161760c61630d61650ea80001010102030319200004010501060107010f0110a100616811616f1280130114617315616e16616817816179181866736574746c65` | Complete minimal Authority launch map. |
| `RLV-002` | `b81a000101616c020203617004616105617206647061636b0761710858200000000000000000000000000000000000000000000000000000000000000000096574727573740a616d0b8161760c61630d61650ea80001010102030319200004010501060107010f0110a200617401616411616f12801301146173156168168161641781616f1818a500010100020103010401181901` | Complete minimal Client launch map. |
| `PCV-001` | `534143500100000100000003000000000000002a00000000a10001` | ShutdownRequest 42, Requested. |
| `PCV-002` | `534143500100000300000003000000000000002a00000000a10001` | Accepted acknowledgement 42. |
| `PCV-003` | `53414350010000020000003c000000000000000000000000ac0001010102617003616c0458200000000000000000000000000000000000000000000000000000000000000000050006f607f608f609f60af60bf6` | Starting Authority, identities `p` and `l`, zero digest. |
| `PCV-004` | `534143500100000100001000000000000000002a00000000` | Reject length 4,096 before payload allocation. |
| `PCV-005` | `534143500101000100000003000000000000002a00000000a10001` | Reject version mismatch. |
| `PCV-006` | `534143500100000100000004000000000000002a00000000bf0001ff` | Reject indefinite CBOR. |

## State, startup, and failure behavior

Valid state paths are:

```text
ProcessStarting -> ProcessReady -> ProcessStopping -> ProcessTerminated
ProcessStarting -> ProcessNotReady -> ProcessTerminated
ProcessStarting -> ProcessStopping -> ProcessTerminated
```

Both runtimes execute one staging transaction:

1. validate bootstrap and construct control and Observability adapters;
2. validate the launch specification and compatibility;
3. prepare each semantic owner and retain one move-only prepared handle;
4. materialize private resources and every reversible external effect,
   including the nonaccepting Authority endpoint bind;
5. commit prepared owners in dependency order with non-throwing operations;
6. perform the role-specific canonical preparation commit;
7. publish the complete Ready frame; and
8. begin role work, enabling Authority accept or initiating Client connection.

`DC-PROCESS-006` and `DC-PROCESS-011` incorporate the following cancellation
contract. The only pre-commit cancellable adapter operations are complete
immutable-file read-and-hash, role-pack materialization, trust-reference materialization,
private-resource materialization, and nonaccepting endpoint bind. A Client
connection attempt and Authority settlement are cancellable only after Ready
under their role-specific contracts. Each cancellable call either returns one
complete owned result or `Cancelled` with no result or externally visible
partial effect. Owner `prepare` may observe cancellation only while awaiting
one of those injected calls. No cancellation is sampled from the start of step
5 through completion of step 7; an I/O failure is still handled as failure.

Before step 5, failure releases handles and effects in exact reverse order. A
failure in a supposedly infallible commit is `InternalFailure` and a design-
conformance failure; committed state is not rolled back. Cancellation is
sampled only between phases 1–4 and at the listed cancellable operations.
Process bounds use a monotonic clock. Only Authority uses the Operational Clock
for Training Session deadlines.

`DC-PROCESS-014` incorporates the following closed readiness population. A row
naming a list means every identity selected by that finite launch list; an
empty destination list contributes no destination.

| Role | Required population before Ready |
| --- | --- |
| Authority | Process Control and Observability adapters; Runtime Package, Content Admission, Simulation, Scenario, AUTH & Admission, Protocol & Replication, and Session Lifecycle owners; bootstrap and Authority launch views; Application Release, Runtime Content Release, Authority Pack, Deployment Compatibility Matrix, Approved Profile, configuration, Content Signing Trust Reference, Observability Contract, Scenario, Training Session, required-capability-policy, external-custody-destination, and terminal-settlement-destination views; all eight capacity reservations; role-private materialization; nonaccepting endpoint bind; all owner commits; one canonical Preparation commit; complete Ready publication. |
| Client | Process Control and Observability adapters; Runtime Package, Content Admission, Prediction, Presentation/output, Input & Interaction, Protocol & Replication, and AUTH & Admission owners; bootstrap and Client launch views; Application Release, Runtime Content Release, Client Pack, Deployment Compatibility Matrix, Approved Profile, configuration, Content Signing Trust Reference, Observability Contract, target Training Session, expected Session Authority, required-device, required-output, retry, departure-confirmation, and external-custody-destination views; all eight capacity reservations; role-private materialization; all owner commits; one Local Client Preparation commit; complete Ready publication. |

`DC-PROCESS-015` incorporates the following shared-module constraint. Shared
implementation is limited to Process Control framing and payload types,
bootstrap and launch decoding, lifecycle-handle primitives, bounded channel
primitives, and monotonic deadline arithmetic. Its production dependency graph
MUST NOT contain Authority, Client, Content Cooker, Simulation, Scenario, AUTH &
Admission, Prediction, Presentation, or Input & Interaction owner interfaces or
implementations. Apart from decoding the closed role-tagged launch union, it
MUST NOT branch to select, construct, order, start, stop, or mutate a role
owner. A registry or factory indexed by role, owner name, or runtime type is a
service locator and is prohibited.

Primary readiness failure precedence is the code order above. Secondary facts
are bounded diagnostics. Pre-ready control failure cleans up and uses NotReady;
post-ready failure begins bounded non-normal shutdown. The channel is never
reopened or replaced.

## Design commitments

- `DC-PROCESS-001`: both product runtimes MUST expose only the bounded v1
  Process Control interface for external lifecycle control.
- `DC-PROCESS-002`: bootstrap MUST bind exactly one immutable Runtime Launch
  Specification by path, identity, and digest.
- `DC-PROCESS-003`: each runtime MUST follow exactly one closed state path and
  publish each state at most once.
- `DC-PROCESS-004`: a required control-channel failure MUST use the declared
  pre-ready or post-ready containment path without reconnection.
- `DC-PROCESS-005`: each accepted command MUST receive one correlated,
  idempotent acknowledgement from reserved capacity.
- `DC-PROCESS-006`: startup MUST finish reversible preparation and external
  effects before infallible ordered owner commit and readiness.
- `DC-PROCESS-007`: each terminal reason MUST use the exact exit projection.
- `DC-PROCESS-008`: every v1 bootstrap, launch, frame, and payload MUST conform
  byte-for-byte to the codecs and bounds in this SDD.
- `DC-PROCESS-009`: the codec MUST reserve specification-selected inbound,
  outbound, and terminal capacity before readiness without unbounded writes.
- `DC-PROCESS-010`: standard-output publication MUST either complete one whole
  Process Control frame or, after a terminal native write error, invalidate and
  close the channel without publishing its strict prefix as a message.
- `DC-PROCESS-011`: cancellation MUST be observed only at declared boundaries
  using a monotonic timeout source.
- `DC-PROCESS-012`: the composition root MUST inject native adapters without a
  service locator or global role behavior.
- `DC-PROCESS-013`: a decoder MUST reject every unknown, duplicate,
  noncanonical, out-of-range, or trailing input before commit.
- `DC-PROCESS-014`: a partial executable MUST NOT publish `ProcessReady` before
  every real role-applicable dependency and effect is committed.
- `DC-PROCESS-015`: shared implementation MUST NOT become a generic runtime
  framework, service locator, or owner of role behavior.

## Rationale and trade-offs

A fixed header rejects incompatible or oversized input before payload
allocation. Closed deterministic CBOR avoids ABI and textual ambiguity while
remaining inspectable. A checksum was rejected because this local channel has
no recovery path; corruption is terminal. Negotiation and unknown-field
preservation were rejected because compatibility is selected before launch.

Prepared handles concentrate rollback and lifetime behind the production seam.
External effects precede commit so endpoint failure cannot strand committed
owners. Service location was rejected because it hides dependencies and lets
role policy escape its owner.

| Commitments | Rationale allocation |
| --- | --- |
| `DC-PROCESS-001`, `DC-PROCESS-004`, `DC-PROCESS-010` | Preserve one orchestration-neutral, fail-closed control surface. |
| `DC-PROCESS-002`, `DC-PROCESS-008`, `DC-PROCESS-013` | Make selection and representation exact before semantic work. |
| `DC-PROCESS-003`, `DC-PROCESS-007` | Keep lifecycle truth and process projection finite and externally stable. |
| `DC-PROCESS-005`, `DC-PROCESS-009` | Guarantee control progress independently of ordinary output pressure. |
| `DC-PROCESS-006`, `DC-PROCESS-011`, `DC-PROCESS-014` | Confine interruption to reversible work and prohibit premature readiness. |
| `DC-PROCESS-012`, `DC-PROCESS-015` | Keep dependencies explicit and role policy local to its composition. |

## Acceptance criteria

Every applicable case runs for each role and native adapter. Evidence retains
input and output bytes, decoded result, ordered trace, configuration identity,
monotonic timestamps where relevant, process exit, and test-binary identity.

| Criterion | Preconditions and stimulus | Required and prohibited observation |
| --- | --- | --- |
| `DAC-PROCESS-001` | Valid v1 launch; inspect every lifecycle surface. | Only framed inherited control is reachable; no native type or alternate channel. |
| `DAC-PROCESS-002` | Mutate bootstrap path, identity, and digest separately. | Failure 1, NotReady, cleanup, exit 20; no owner prepare or Ready. |
| `DAC-PROCESS-003` | Drive every valid and invalid state edge and both Terminated forms. | Three paths emit once; readiness termination preserves its failure with null terminal reason and exit 20; runtime termination preserves its terminal reason; every other edge, field combination, and duplicate is rejected. |
| `DAC-PROCESS-004` | Inject EOF, corruption, version mismatch, partial positive-progress writes, and a terminal write error after a strict frame prefix immediately before/after Ready. | Partial progress is assembled to one complete frame; terminal error closes and invalidates the stream, the reader discards its strict prefix, and containment is pre-ready rejection or post-ready shutdown as applicable; no prefix is published as a message, no channel reopens, and no committed result is revised. |
| `DAC-PROCESS-005` | Send correlation 42 twice after filling ordinary output. | First is PCV-002; duplicate disposition is 2; reserved output remains available. |
| `DAC-PROCESS-006` | Fail each phase; cancel at every permitted phase boundary and listed cancellable call; inject a conformance-violating throw at each commit. | Reverse cleanup before commit; cancellation is deferred from phase 5 through Ready; conformance violations become InternalFailure without rollback of committed state; no early Ready; one deterministic primary failure. |
| `DAC-PROCESS-007` | Terminate once for every failure and terminal reason. | Every process exit equals the declared projection; no alternate code. |
| `DAC-PROCESS-008` | Round-trip RBV-001, RLV-001..002, PCV-001..006, and payload sizes 0, 4,072, 4,073. | Positive bytes are identical; negative inputs fail before excess allocation. |
| `DAC-PROCESS-009` | Use min/max capacities, fill ordinary queues, request shutdown. | Reservation precedes Ready; overflow is stable; terminal output remains available; no growth. |
| `DAC-PROCESS-010` | In executions without terminal native write failure, emit diagnostics and Observability in every state and force every positive partial-write pattern. Separately reuse the terminal-prefix cases from criterion 4. | Successful stdout parses entirely as v1 frames with no text or trailing byte; partial progress completes its frame; terminal-prefix executions close an invalid stream and expose no prefix to the message consumer. |
| `DAC-PROCESS-011` | Request cancellation at every phase boundary, during every listed cancellable adapter call, and during each noncancellable commit/Ready operation with fake monotonic and changed wall clock. | Cancellation occurs only at a declared point, each cancelled call leaves no partial owned result, phase 5–7 defers it until Ready, and wall clock has no effect. |
| `DAC-PROCESS-012` | Inspect dependencies and substitute each real adapter. | All adapters enter at root; no registry, global owner, or native seam leakage. |
| `DAC-PROCESS-013` | Mutate maps with every prohibited encoding or value. | Rejection occurs before prepare with deterministic classification. |
| `DAC-PROCESS-014` | For each row of the closed readiness table, omit each scalar entry and each member of every selected finite list in turn; fail each listed effect or commit. | No Ready; each case produces NotReady followed by readiness Terminated exit 20, cleanup where reversible, and no role work. Empty optional destination lists add no case. |
| `DAC-PROCESS-015` | Inspect production dependency/symbol graphs and exercise both closed launch variants. | Shared targets contain only the enumerated shared population, no prohibited owner dependency or indexed registry/factory, and no role-policy branch other than decoding the role-tagged launch union. |
