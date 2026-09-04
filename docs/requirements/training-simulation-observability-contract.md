# Training Simulation Observability Contract

Status: Approved

Approval: Project owner, 2026-09-04

Approved predecessor: `OBS-CONTRACT-003`, project owner, 2026-09-03

Contract version: `OBS-CONTRACT-004`

Purpose: Define the stable signal semantics required to verify automated Training Simulation quality requirements and operational targets in test and production builds.

Scope: Core Desktop Mode and Session Authority observability. Collection technology, transport, storage product, dashboards, and alert-routing implementation are architecture decisions.

Intended readers: Project owner, requirements reviewers, architects, implementers, operators, and verification authors.

Prerequisites: [Training Simulation context](../../CONTEXT.md), [Training Simulation Non-Functional Requirements](training-simulation-non-functional-requirements.md), and [Training Simulation Verification Plan](training-simulation-verification-plan.md).

Canonical information owner and approver: Project owner.

Normative effect: This approved contract is mandatory where referenced by the
approved NFR baseline.

## Common signal envelope

Every core signal record has:

| Field | Meaning |
| --- | --- |
| `contract_version` | Exact approved Observability Contract version |
| `signal_id` | Stable identifier from the core signal catalogue |
| `source_instance_id` | Opaque identifier for one process execution; not a person or device identity |
| `source_sequence` | Strictly increasing unsigned sequence within one source instance and signal stream |
| `monotonic_timestamp_ns` | Source-local monotonic observation time in nanoseconds |
| `reference_timestamp_ns` | Shared-reference observation time in nanoseconds when the signal participates in a cross-machine interval |
| `build_version` | Exact emitting product build |
| `configuration_version` | Exact applicable runtime configuration |
| `profile_versions` | Exact applicable workload, hardware, Map, Acoustic, or other profile versions |
| `runtime_content_release_id` | Exact Runtime Content Release identity when the source is bound to runtime content |
| `session_correlation_id` | Opaque non-personal Training Session correlation identifier when applicable |
| `event_correlation_id` | Opaque non-personal correlation identifier when applicable |

An inapplicable conditional field is absent rather than populated with an invented value. Signal-specific fields are additional to this envelope.

## Core signal catalogue

| Signal identifier | Source | Signal-specific meaning and fields | Primary trace |
| --- | --- | --- | --- |
| `OBS-PROCESS-LIFECYCLE-001` | Desktop Mode or Session Authority process | Lifecycle transition: `Started`, `Stopping`, or `Terminated`; termination classification when known | `NFR-OBSERVABILITY-CORE-001` |
| `OBS-FINAL-IMAGE-001` | Rendered Desktop Mode client | One-second final-image aggregate defined below | `NFR-DESKTOP-SMOOTHNESS-001`, `NFR-DESKTOP-STALL-001` |
| `OBS-ACTION-SUBMITTED-001` | Originating rendered or synthetic client | Script step and event correlation identifying submission of a valid action without its gameplay payload | `NFR-ACTION-RESPONSE-001` |
| `OBS-ACTION-RESULT-RECEIVED-001` | Each rendered or synthetic client | Correlated first authoritative-result receipt | `NFR-ACTION-RESPONSE-001` |
| `OBS-ACTION-RESULT-PRESENTED-001` | Rendered Desktop Mode client | Correlated first authoritative-result presentation | `NFR-ACTION-RESPONSE-001` |
| `OBS-ACOUSTIC-EVENT-INITIATED-001` | Session Authority | Acoustic Profile reference and opaque event correlation without gameplay payload | `NFR-ACOUSTIC-PEAK-001` |
| `OBS-ACOUSTIC-EVENT-PRESENTED-001` | Rendered Desktop Mode client | Correlated acoustic presentation and output-route identifier | `NFR-ACOUSTIC-PEAK-001` |
| `OBS-ADMISSION-STARTED-001` | Session Authority | Opaque attempt correlation and start of initial Admission after the Authentication Act | `NFR-AUTH-ADMISSION-001` |
| `OBS-ADMISSION-TERMINAL-001` | Session Authority | Correlated terminal classification: `Success` or `Denied` | `NFR-AUTH-ADMISSION-001` |
| `OBS-ADMISSION-AUDIT-COMMITTED-001` | Session Authority under the Production Security Baseline | Correlated non-secret AUTH Audit Commit Unit reference; absent under permissive development AUTH | `NFR-AUTH-ADMISSION-001` |
| `OBS-SESSION-LIFECYCLE-001` | Session Authority `Session Lifecycle` owner | Committed Training Session phase transition and Lifecycle Revision | `REQ-AUTHORITY-SINGLE-SESSION-001`, `AC-RUNTIME-003` |
| `OBS-CANONICAL-TICK-COMMITTED-001` | Session Authority `Simulation` owner | Canonical Tick commit and the resulting Composite Confirmed-State Identity | `REQ-STATE-CONSISTENCY-001`, `AC-RUNTIME-001`, `AC-RUNTIME-004` |
| `OBS-TECHNICAL-REMOVAL-001` | Session Authority | Correlated non-personal Technical Removal and canonical state-version transition | `NFR-OBSERVABILITY-CORE-001`, `REQ-TECHNICAL-REMOVAL-003` |
| `OBS-PREDICTION-CORRECTION-001` | Rendered Desktop Mode client `Prediction` owner | Authoritative correction, prediction rollback or reset, and lead-bound freeze disposition | `REQ-CLIENT-TRUST-001`, `REQ-STATE-CONSISTENCY-001`, `AC-RUNTIME-006` |
| `OBS-REPLICATION-ACKNOWLEDGEMENT-001` | Session Authority `Protocol & Replication` owner | Per-client contiguous acknowledgement high-water advance | `REQ-STATE-CONSISTENCY-001`, `AC-DEPLOYMENT-007` |
| `OBS-REPLICATION-RECOVERY-001` | Desktop Mode or Session Authority `Protocol & Replication` owner | Delta-gap or digest-mismatch detection and baseline-resynchronization progress | `REQ-STATE-CONSISTENCY-001`, `AC-RUNTIME-006`, `AC-DEPLOYMENT-007` |
| `OBS-RUNTIME-BOUND-BREACH-001` | Session Authority | Catch-up or overload bound breach and its deterministic canonical disposition | `NFR-ACTION-RESPONSE-001`, `AC-CONCURRENCY-004` |
| `OBS-RECONSTRUCTION-LOSS-001` | Session Authority retained-evidence adapter | Reconstruction-record preservation or export loss classification and affected record range | `REQ-SESSION-EVIDENCE-001` through `REQ-SESSION-EVIDENCE-003`, `AC-RETENTION-005` |
| `OBS-SESSION-EVIDENCE-HANDOFF-001` | Session Authority | Terminal Session Evidence Set completeness and durable-handoff disposition | `NFR-OBSERVABILITY-CORE-001`, `REQ-SESSION-EVIDENCE-004` |
| `OBS-RUNTIME-IDENTITY-001` | Desktop Mode or Session Authority process | Exact Application Release, Runtime Launch Specification, build, configuration, contract, Runtime Content Release, role-pack and Content Signing Trust Reference identities, AUTH mode, applicable profile versions, and observability detail level active at process start | `NFR-OBSERVABILITY-CORE-001`, `CONSTRAINT-NFR-OBSERVABILITY-ACCEPTANCE-001` |
| `OBS-SIGNAL-LOSS-001` | Every core-signal producer or collector | Cumulative lost-or-discarded count by affected signal identifier and loss location | `NFR-OBSERVABILITY-INTEGRITY-001` |
| `OBS-OPERATIONAL-ALERT-001` | Production observability collector | Correlated alert creation for a signal-loss increase | `NFR-OBSERVABILITY-ALERTING-001` |

## Acceptance supporting records

The following records belong to the acceptance environment rather than the continuously enabled product core:

| Record identifier | Required fields and emission rule | Primary trace |
| --- | --- | --- |
| `OBS-LOAD-GENERATOR-CPU-001` | `sample_reference_timestamp_ns` and total `cpu_utilization_percent`; one sample per second throughout each automated acceptance run | `CONSTRAINT-NFR-LOAD-GENERATOR-001` |
| `OBS-LINK-RATE-001` | Opaque endpoint and interface identifiers, `sample_reference_timestamp_ns`, `negotiated_bits_per_second`, duplex state, and link state; initial sample plus every observed change throughout the procedure | `CONSTRAINT-NFR-LAN-001`, `CONSTRAINT-NFR-LOAD-GENERATOR-001` |
| `OBS-REPLAY-OUTCOME-001` | Script version, opaque client slot, expected and completed step counts, first failed or missed step if any, and terminal outcome; exactly once per rendered or synthetic client at run end | `CONSTRAINT-NFR-REPLAY-001` |
| `OBS-CLOCK-OFFSET-001` | Measurement-method version, opaque machine-pair identifiers, measurement-window start and end, and greatest measured absolute offset in nanoseconds; complete coverage of every cross-machine measurement window | `NFR-OBSERVABILITY-TIME-001` |

### Process and observability-health signals

| Signal | Signal-specific fields and cardinality |
| --- | --- |
| `OBS-PROCESS-LIFECYCLE-001` | `lifecycle_state`, exactly `Started`, `Stopping`, or `Terminated`, plus optional `termination_class`, exactly `Clean`, `Unexpected`, or `Unknown`; one `Started`, at most one `Stopping`, and at most one `Terminated` per source instance |
| `OBS-RUNTIME-IDENTITY-001` | `observability_detail_level`, exactly `CoreOnly` or `Diagnostic`, exact `role_pack_id`, `role_pack_hash`, `content_contract_id`, and `content_signing_trust_reference_id`; emitted once immediately after `Started` and before other product signals |
| `OBS-SIGNAL-LOSS-001` | `affected_signal_id`, `loss_location`, exactly `Producer`, `Transport`, or `Collector`, and monotonically increasing `cumulative_lost_or_discarded_count`; emitted on every increase |
| `OBS-OPERATIONAL-ALERT-001` | `trigger_signal_id`, opaque trigger-record correlation, and `alert_created_reference_timestamp_ns`; emitted exactly once for each signal-loss trigger required by `NFR-OBSERVABILITY-ALERTING-001` |
| `OBS-SESSION-LIFECYCLE-001` | `preceding_lifecycle_revision`, `resulting_lifecycle_revision`, and `lifecycle_state`, exactly `Preparation`, `Initial Countdown`, `Active`, `Completed`, `Terminating`, or `Terminal Settling`; emitted exactly once after each lifecycle commit and before its publication. The preceding Lifecycle Revision is absent only for the first `Preparation` commit. |
| `OBS-CANONICAL-TICK-COMMITTED-001` | Unsigned `canonical_tick_index`; `simulated_time_ns`; and the resulting Composite Confirmed-State Identity fields `canonical_state_version`, `simulation_revision`, `scenario_revision`, and `session_lifecycle_revision`; emitted exactly once after the whole Canonical Tick commits and before publication. Nanoseconds are measured from the Training Session simulation epoch, not from an observability clock. |
| `OBS-TECHNICAL-REMOVAL-001` | Opaque `removed_client_slot_id`; `removal_cause`, exactly `Disconnected`; unsigned `canonical_order_index`; `preceding_canonical_state_version`; `resulting_canonical_state_version`; `resulting_session_lifecycle_revision`; and `accepted_at_canonical_tick_index`; emitted exactly once after the atomic Technical Removal becomes visible. Simultaneous removals receive distinct canonical-order indices. This retains and extends `OBS-TECHNICAL-REMOVAL-001`; it does not supersede the identifier. |
| `OBS-PREDICTION-CORRECTION-001` | Opaque `client_slot_id`; `correction_kind`, exactly `AuthoritativeCorrection`, `Rollback`, `Reset`, or `LeadBoundFreeze`; unsigned `preceding_predicted_tick_index`, `resulting_predicted_tick_index`, and `confirmed_tick_index`; `confirmed_canonical_state_version`; and unsigned `discarded_prediction_tick_count`. `freeze_active` is Boolean and is true only for `LeadBoundFreeze`. Emitted once for each completed correction, rollback, or reset and once on each transition into or out of lead-bound freeze. |
| `OBS-REPLICATION-ACKNOWLEDGEMENT-001` | Opaque `client_slot_id` and `replication_stream_id`; unsigned `acknowledgement_high_water_state_version`; and `baseline_id`; emitted once whenever the Session Authority accepts an advance of that client's highest contiguous acknowledged version. Duplicate, stale, and out-of-order acknowledgements emit no record and cannot advance the high-water mark. |
| `OBS-REPLICATION-RECOVERY-001` | Opaque `client_slot_id`, `replication_stream_id`, and `baseline_id`; `recovery_event`, exactly `DeltaGapDetected`, `DigestMismatchDetected`, `BaselineRequested`, `BaselineApplied`, or `BaselineRejected`; `expected_base_state_version`; `observed_state_version`; and `resulting_confirmed_state_version`, present only for `BaselineApplied`. Emitted once for each detection and once for each baseline state transition. No state digest or gameplay data is emitted. |
| `OBS-RUNTIME-BOUND-BREACH-001` | `bound_kind`, exactly `CatchUpTicks`, `CatchUpDuration`, `TickWork`, `TickDuration`, `OwnerQueueRecords`, or `OwnerQueueBytes`; unsigned `observed_value`, `limit_value`, and `value_unit`, exactly `Ticks`, `Nanoseconds`, `Records`, or `Bytes` as prescribed by the launch-bound Runtime Execution Profile; `canonical_disposition`, exactly `CandidateRejected` or `SessionTerminating`; optional `candidate_tick_index`; and `resulting_session_lifecycle_revision` when terminating. Emitted exactly once per detected breach after the owner fixes its disposition. |
| `OBS-RECONSTRUCTION-LOSS-001` | `loss_classification`, exactly `ReservationExhausted`, `BufferedRecordLost`, `ExportAbandoned`, or `AuthorityLossBoundary`; `record_class`, exactly `CanonicalTick`, `Lifecycle`, or `Terminal`; unsigned `first_affected_record_sequence` and `last_affected_record_sequence`; `canonical_disposition`, exactly `CommitPrevented`, `SessionTerminating`, `IncompleteEvidence`, or `AuthorityLost`; and opaque `session_evidence_set_id` when one has been assigned. Emitted exactly once when each maximal contiguous affected range is classified; an unknown end is represented by `last_affected_record_sequence` equal to the greatest sequence known affected, never by an invented complete range. |
| `OBS-SESSION-EVIDENCE-HANDOFF-001` | Opaque `session_evidence_set_id`; `terminal_session_lifecycle_revision`; `completeness`, exactly `Complete` or `Incomplete`; unsigned `classified_loss_range_count`; `handoff_result`, exactly `Durable` or `Failed`; and an opaque non-secret `handoff_receipt_reference` only when durable. Emitted exactly once when the bounded terminal handoff reaches its final disposition and before Session Authority exit. This retains and extends `OBS-SESSION-EVIDENCE-HANDOFF-001`; it does not supersede the identifier. |

Absence of `Stopping` or `Terminated` after an unexpected process loss does not invent a lifecycle transition. Process-launch outcomes, sequence gaps, and loss counters provide the applicable observable failure evidence.

### Runtime-state signal semantics

The Composite Confirmed-State Identity is the exact tuple
`(canonical_state_version, canonical_tick_index, simulation_revision,
scenario_revision, session_lifecycle_revision)` fixed by the authoritative
owners at commit. Equality requires equality of every tuple member. An
observability record copies the tuple only after commit; it cannot create,
advance, acknowledge, validate, or repair it.

`OBS-SESSION-LIFECYCLE-001` revisions are owner revisions, not Canonical Ticks.
`OBS-CANONICAL-TICK-COMMITTED-001.simulated_time_ns` is Simulated Time.
Envelope timestamps are observation times: source-local monotonic observation
time and, only when required for a cross-machine measurement, shared-reference
observation time. Neither is Simulated Time, Operational Clock, presentation
time, or Trusted Identity Time. No signal field may be substituted for one of
those authoritative clocks.

Prediction correction and baseline resynchronization affect only replaceable
client state. A rollback or reset does not roll back a committed Canonical Tick,
restore an Admission, reconnect a client, or resume a Training Session. A
lead-bound freeze stops further client prediction only; confirmed replication
and Presentation of committed views remain eligible. A replication
acknowledgement record reports the authority-owned acknowledgement state after
it advances; observing, collecting, losing, or replaying that record cannot
acknowledge replication.

A runtime-bound breach is classified from the immutable Runtime Execution
Profile. `CandidateRejected` applies only before Canonical Tick commit and does
not advance Simulated Time. `SessionTerminating` applies when canonical
correctness cannot be preserved; the correlated
`OBS-SESSION-LIFECYCLE-001` transition supplies the resulting revision. The
Observability path never requests either disposition and never delays it.

A reconstruction reservation failure before commit uses `CommitPrevented` and
the applicable deterministic termination path. Later asynchronous loss uses
`IncompleteEvidence` without changing a committed canonical outcome.
`AuthorityLossBoundary` never invents a lifecycle transition or complete
record range after process loss. Every classified range is correlated to the
terminal `OBS-SESSION-EVIDENCE-HANDOFF-001` through the same
`session_correlation_id` and, when assigned, `session_evidence_set_id`.

### Per-record collection, privacy, and evidence rules

Every product core record is asynchronously enqueued only after its source
owner has fixed the reported fact. Enqueue, delivery, retry, collector
acknowledgement, loss reporting, storage, and later retrieval are outside every
Canonical Tick and owner commit fence. They cannot act as an authority,
ordering source, Canonical Tick barrier, replication acknowledgement,
persistence receipt, or live-session input.

Correlation scope is exact: `source_instance_id` scopes `source_sequence`;
`session_correlation_id` is present only for one Training Session;
`event_correlation_id` is present only for the one action, acoustic event,
Admission attempt, bound breach, correction, recovery episode, Technical
Removal, reconstruction-loss range, alert trigger, or handoff to which the
record belongs. Client-slot, stream, route, baseline, evidence-set, receipt,
and record identifiers are opaque and unique only for their stated runtime or
session scope. They are neither identity evidence nor reusable proof.

All product core records have privacy classification `Operational,
non-personal`. They contain only the envelope and fields admitted by this
contract. They contain no gameplay payload, world position, state digest,
credential, authentication evidence, reusable proof, Trainee Identity,
Synthetic Identity, identity-bound performance field, or detailed AUTH denial
reason. Acceptance-supporting records have classification `Acceptance,
non-personal` and follow the same prohibitions.

For every required record, an attributable evidence set contains the exact
record, its complete envelope, the single `OBS-RUNTIME-IDENTITY-001` for its
source, all applicable `OBS-SIGNAL-LOSS-001` records and sequence-gap analysis,
and the acceptance-supporting clock record when timestamps cross machines.
The signal's Primary trace names its verification use. Runtime-state claims
also require the matching deterministic reconstruction or immutable published
view; a signal alone never proves canonical correctness. Missing, duplicate,
uncorrelated, out-of-cardinality, version-inconsistent, or prohibited-field
records make the affected obligation `Blocked`, never `Pass`. A no-record
expectation is acceptable only when the verification procedure exercises the
emission condition and supplies attributable negative evidence with complete
loss accounting.

### Final-image signals

`OBS-FINAL-IMAGE-001` is emitted once for each consecutive one-second aggregation window while the rendered client presents final images. It contains:

| Field | Unit and rule |
| --- | --- |
| `aggregation_start_monotonic_ns` | Inclusive source-local window start in nanoseconds |
| `aggregation_duration_ns` | Normally `1,000,000,000` nanoseconds; shorter only for the final window before process termination or when a presentation-area change closes the window |
| `final_image_count` | Number of final images presented in the window |
| `interval_count` | Number of consecutive-final-image intervals whose later image was presented in the window |
| `interval_le_16670000_ns_count` | Number of those intervals no greater than `16,670,000` nanoseconds |
| `maximum_interval_ns` | Greatest interval counted in the window; absent only when `interval_count` is zero |
| `client_presentation_width_px` | Client presentation-area width throughout the window; a change closes the current aggregate and starts another |
| `client_presentation_height_px` | Client presentation-area height throughout the window; a change closes the current aggregate and starts another |

Summing `interval_count` and `interval_le_16670000_ns_count` over an acceptance window yields the population used by `NFR-DESKTOP-SMOOTHNESS-001`. The greatest `maximum_interval_ns` yields the result for `NFR-DESKTOP-STALL-001`.

When per-image detail is enabled, optional `OBS-FINAL-IMAGE-DETAIL-001` records `final_image_sequence`, `interval_ns`, `client_presentation_width_px`, and `client_presentation_height_px` for each presented final image. It does not replace the continuously enabled aggregate.

The supported observability detail levels are `CoreOnly`, containing only the continuously enabled core catalogue, and `Diagnostic`, which may add optional signals. Formal NFR acceptance uses `CoreOnly`; observing an optional signal or another detail-level value during its measurement window invalidates the environment and blocks the run.

### Action-response signals

One opaque `event_correlation_id` is created when a valid scripted action is submitted and is reused only for that action's corresponding authoritative-result signals. The correlation identifier conveys no action payload or Trainee identity.

| Signal | Signal-specific fields and cardinality |
| --- | --- |
| `OBS-ACTION-SUBMITTED-001` | `script_step_id` and opaque `origin_client_slot_id`; emitted exactly once when the valid action is submitted |
| `OBS-ACTION-RESULT-RECEIVED-001` | Opaque `recipient_client_slot_id`; emitted exactly once by each synthetic client for its first receipt of the corresponding authoritative result |
| `OBS-ACTION-RESULT-PRESENTED-001` | Opaque `recipient_client_slot_id` and `final_image_sequence`; emitted exactly once by the rendered client for the first final image in which the corresponding authoritative result is presented |

For each submitted action, `NFR-ACTION-RESPONSE-001` uses the interval from the submission `reference_timestamp_ns` to the presentation timestamp on the rendered client and to the receipt timestamp on every synthetic client. A missing, duplicate, or uncorrelated required signal blocks the affected measurement under `NFR-OBSERVABILITY-INTEGRITY-001`.

### Acoustic-event signals

One opaque `event_correlation_id` is assigned to each acoustic event in the deterministic Stress script and conveys no event content, position, or audio data.

| Signal | Signal-specific fields and cardinality |
| --- | --- |
| `OBS-ACOUSTIC-EVENT-INITIATED-001` | `script_step_id`; emitted exactly once when the Session Authority initiates the scripted acoustic event |
| `OBS-ACOUSTIC-EVENT-PRESENTED-001` | `script_step_id` and opaque `output_route_id`; emitted exactly once when the rendered client first presents the correlated event through the active audio route |

The exact script identifies which 16 steps are weapon sources and which four are explosions. If every initiation is observed, no core signal loss is reported, and a correlated presentation is absent, duplicated, or assigned to another script step, `NFR-ACOUSTIC-PEAK-001` receives `Fail`. When signal loss makes presentation unknowable, the affected result is `Blocked` under `NFR-OBSERVABILITY-INTEGRITY-001`.

### Admission signals

One opaque `event_correlation_id` is created for each initial Admission attempt:
after completion of the Trainee Authentication Act under the Production Security
Baseline, or when the finite permissive development attempt begins. It conveys
no Trainee Identity, Synthetic Identity, credential, authentication evidence,
or detailed denial reason.

Under permissive development AUTH, the runtime emits the start and terminal
signals with its non-production AUTH mode declared by
`OBS-RUNTIME-IDENTITY-001`; it emits no
`OBS-ADMISSION-AUDIT-COMMITTED-001`, and those records cannot satisfy
`NFR-AUTH-ADMISSION-001`. The complete three-signal measurement applies only
under the Production Security Baseline.

| Signal | Signal-specific fields and cardinality |
| --- | --- |
| `OBS-ADMISSION-STARTED-001` | Optional `script_step_id`; emitted exactly once at the NFR measurement start for the attempt |
| `OBS-ADMISSION-TERMINAL-001` | `terminal_result`, exactly `Success` or `Denied`; emitted exactly once when the attempt reaches its terminal result |
| `OBS-ADMISSION-AUDIT-COMMITTED-001` | Opaque non-secret `audit_commit_reference`; emitted exactly once when the attempt's required AUTH Audit Commit Unit completes |

For each attempt, `NFR-AUTH-ADMISSION-001` measures from the start `monotonic_timestamp_ns` to the later of its correlated terminal-result and audit-commit timestamps on the Session Authority. A missing required terminal or commit signal after five seconds, with no reported signal loss, fails that attempt. Signal loss or duplicate or uncorrelated required signals block the affected measurement.

## Data minimization

Core signals contain no gameplay payload, credential, authentication evidence, personal data, or reusable security proof. Opaque correlation identifiers are unique only within the minimum scope and lifetime required for measurement.

## Retention and integrity

Operational retention follows `NFR-OBSERVABILITY-RETENTION-001`. Sequence gaps and `OBS-SIGNAL-LOSS-001` establish signal loss; acceptance and production behavior follows `NFR-OBSERVABILITY-INTEGRITY-001`.

Optional signals emitted in `Diagnostic` mode have no mandatory retention period. Their retention may be selected operationally without changing the retention or availability of any core signal.

Cross-machine interval evidence includes the measured clock-offset record required by `NFR-OBSERVABILITY-TIME-001`.

## Completion rule

Future contract versions are ready for approval when every core signal has exact fields, units, emission conditions, cardinality bounds, correlation scope, privacy classification, verification method, and required evidence, and the project owner approves the exact version.
