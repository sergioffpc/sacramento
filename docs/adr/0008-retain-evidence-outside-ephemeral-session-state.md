# Retain evidence outside ephemeral session state

Status: Accepted

Approval: Project owner, 2026-09-03

Purpose: Define the architecture-level trust, persistence, retention, recovery, and Technical Removal boundaries for the initial baseline.

Scope: Live session state, AUTH audit, reconstruction and terminal evidence, Observability, performance assessment, verification evidence, runtime artifacts, and their trust and custody seams; concrete storage, cryptography, orchestration, and deployment topology remain outside this decision.

Canonical information owner: Project owner

Intended readers: Architects, designers, implementers, security reviewers, verification authors, operators, Qualified Specialists, and Representative Evaluators.

Prerequisites: `CONTEXT.md`, ADR-0004 through ADR-0007, and the approved functional, non-functional, observability, performance-assessment, and verification baselines.

Sacramento keeps all live Training Session state inside its one ephemeral
Session Authority process, removes a Trainee irreversibly when that Trainee's
connection is lost, and never restores a Training Session. Security audit,
Session Evidence Sets, operational signals, performance assessments, and
project evidence cross separate, immutable persistence seams owned by the
module that defines their meaning. Trust is independently provisioned and
scoped by role and contract. This favors a small failure model and auditable
retained truth over client reconnection, generic persistence, or one shared
trust and storage subsystem.

This decision amends ADR-0004 by adding `Trainee Performance Assessment Module` as a
responsibility module, supersedes ADR-0005's Technical Pause and client
continuity model, supersedes ADR-0006's continuity workflows and related
failure dispositions, and supersedes ADR-0007's client-continuity exception.
Their unaffected decomposition, fixed-step, ownership, concurrency, content,
and one-session-process decisions remain accepted.

## Ownership and persistence seams

Semantic authority remains with the responsibility owner. Persistence is a
private adapter at that owner's seam, not a generic module and not an
alternative source of domain truth.

| Data class | Semantic owner | Persistence and commit boundary | Retention and deletion authority |
| --- | --- | --- | --- |
| Live Admission, identity bindings, roster, Ready, Team Position, Loadout, lifecycle, and canonical Simulation state | `AUTH & Admission`, `Session Lifecycle`, or `Simulation`, according to the state meaning | Process memory only; visible through the existing owner commit and publication fences | The owner removes it at the applicable Admission end, Technical Removal, terminal transition, or process loss; it is never restored |
| AUTH Audit Records, integrity references, incomplete commits, and AUTH Audit Sequence state | `AUTH & Admission` | One host-scoped durable append order; a granting AUTH effect waits for its complete AUTH Audit Commit Unit | The creating AUTH Audit Policy authorizes exact finite expiry; no other runtime or repository may delete or reinterpret it |
| AUTH Audit Checkpoints | `AUTH & Admission` for meaning; external host environment for custody | Separately collectable immutable handoff outside the storage holding the covered sequence | External custody must retain every checkpoint needed to validate a retained extent; disposition must not conceal unauthorized local deletion |
| Canonical Tick reconstruction records | `Simulation` | Created atomically with the Canonical Tick in reserved memory, then handed off asynchronously; persistence never blocks a tick | Retained indefinitely in the Session Evidence Set; this baseline authorizes no deletion |
| Lifecycle reconstruction records and terminal result | `Session Lifecycle` | Created with the governing lifecycle commit; final manifest and terminal result require a durable, verifiable handoff during terminal settling for a clean exit | Retained indefinitely in the Session Evidence Set; this baseline authorizes no deletion |
| Core operational signals | `Observability` | Immutable sequenced asynchronous handoff with explicit acknowledgement, retry, and loss semantics | The Observability operational administrator retains them for at least 30 days after collection and may dispose of them afterward only under the project-owner-approved operational retention policy |
| Optional diagnostic signals | `Observability` | Best-effort asynchronous handoff when enabled | The Observability operational administrator may omit or delete them under the project-owner-approved operational retention policy without changing core-signal obligations |
| Trainee performance events, results, approvals, corrections, and history | `Trainee Performance Assessment Module` | Durable owner commit through a private adapter; Session Authority supplies immutable authoritative event inputs without sharing storage | Retained indefinitely under the performance baseline; this baseline authorizes no deletion |
| Formal verification evidence and acceptance histories | The evidence owner named by the applicable Verification Plan assignment; the project owner is final approval authority | Immutable external verification repository, outside runtime decision paths | Retained indefinitely and never silently overwritten; this baseline authorizes no deletion |
| Runtime Content Releases and their processing, signing, compatibility, activation, and rollback histories | `Runtime Package` owns package identity and representation; `Content Admission` owns validation and activation decisions | Immutable external publication and independently provisioned activation | The external artifact custodian may delete only with project-owner approval of evidence that no process or retained audit, replay, result, assessment, or verification record depends on the artifact |
| Identity Validation Packages, trust references, Approved Profiles, catalogues, and their approval histories | `AUTH & Admission` owns identity-package runtime meaning; `Content Admission` owns runtime validation and activation; the project owner owns approval disposition | Immutable external publication and independently provisioned activation | The external artifact custodian may delete only with project-owner approval of evidence that no process or retained record depends on the artifact or its interpretation |

`Trainee Performance Assessment Module` is a deep module owning identity-bound
performance evidence, metrics, Training Feedback, proposed and approved Formal
Assessments, Leaderboards, access decisions, corrections, and retained
history. It never owns canonical Simulation state and never participates in a
Canonical Tick. General reconstruction and Observability remain non-personal;
only this module associates admitted performance events with Trainee Identity.
Its deployment location is not selected here.

## Connection loss and Technical Removal

There is no client reconnection, Session Continuity Claim, Device Continuity
Proof, State Restoration, Technical Pause, restoration window, or resume
countdown in the initial baseline.

Before active simulation, confirmed connection loss or explicit departure ends
the Admission, releases its preparation state, and cancels an active initial
countdown through the ordinary readiness rule. The departed client cannot
rejoin that Training Session after active simulation starts.

During active simulation, Protocol & Replication reports connection loss only
after applying the exact Runtime Timing Profile. The runtime then coordinates
one publication fence across the state owners. `AUTH & Admission` ends the
Admission and identity binding; `Session Lifecycle` records `Technical
Removal` with cause `Disconnected`; and `Simulation` removes the Trainee from
participation, collision, communication, action, and presentation and assigns
`Withdrawn` to every associated physical item. No partial removal is visible.
The next Canonical Tick proceeds with the remaining Trainees.

Technical Removal is not Fatal, injury, incapacity, voluntary tactical action,
or task error. Valid performance evidence committed before removal remains
valid; a metric needing later missing evidence is invalid rather than
estimated. Every Scenario declares the result when a Team has no participating
Trainee. The Reference Personnel Recovery Scenario assigns defeat to that
Team. Removal of one Trainee does not otherwise terminate the Training Session.

Client process restart always requires a new process and new initial Admission
and is possible only before active simulation. A Session Authority process
loss still terminates its Training Session and Admissions; a replacement
process begins a new Training Session from its Scenario's initial state.

## Trust bootstrap, rotation, and compromise

Four trust domains remain separate:

- Content Signing Trust References authorize only exact content-signing roles
  and runtime content contracts.
- Package Trust References authorize only exact Identity Validation Package
  roles and releases.
- the Identity Authority and declared issuers govern identity evidence,
  Authorization Assertions, Offline Revocation Status, and authenticators;
  and
- administrative custody trust authenticates audit checkpoints, evidence
  destinations, and durable handoff receipts without gaining authority to
  sign content, packages, or identities.

Every root is provisioned independently of the artifact it validates. No pack,
package, retained record, peer, live network lookup, or repository establishes
its own trust root. Secret and identity-bearing data is restricted to its
declared role and purpose. A project-owner-approved closed recipient-and-field
matrix governs Session Evidence Set creation, handoff, retention, and retrieval.
All handoffs authenticate the destination and protect required confidentiality
and integrity without prescribing algorithms, stores, or transports.

Trust and package rotation atomically changes what later process starts may
activate. A running process continues with its already validated immutable
content and Identity Validation Package views. Revocation prevents a new start
or Admission under the revoked material but does not revalidate or remove an
existing Admission. This replaces the prior global mutable `current package`
rule, which could not coexist cleanly with multiple independent ephemeral
authorities.

A compromised content or package signer requires new trust references and new
artifacts for later processes. Lost AUTH audit integrity closes the gate to new
AUTH Operations but does not remove existing Admissions; recovery must bind an
authenticated discontinuity to the last provable state. A compromised evidence
destination or receipt cannot prove terminal handoff. A compromise never
retroactively invents certainty about historical artifacts; unprovable scope
is recorded as uncertainty or discontinuity.

## Commit, export, and recovery

Every durable owner prepares a non-visible candidate and atomically publishes
one stable commit identity. Exports repeat idempotently by that identity. On
startup or administrative recovery, each artifact is classified as committed,
incomplete, or corrupt from retained evidence; absence or ambiguity never
means success.

AUTH recovery has exclusive logical access to its host-scoped append target.
It validates sequence continuity, dispositions incomplete candidates, commits
the required recovery record, and only then opens the AUTH gate. It never
restores an Admission.

A Session Evidence Set binds its Training Session, Scenario, Runtime Content
Release, build, configuration, complete committed Canonical Tick and lifecycle
record ranges, terminal result, provenance, and either completeness or an
explicit loss boundary. Active-session handoff uses separately reserved
capacity. When capacity cannot preserve a complete accepted reconstruction
record, the current tick exposes no result and the Training Session terminates
as a canonical-path integrity failure rather than waiting for persistence.

Orderly terminal settling completes any begun tick, fixes the terminal result,
closes Admissions, constructs the immutable final Session Evidence Set
manifest, obtains the configured durable handoff receipt, settles required
AUTH audit and bounded core Observability work, and exits. Failure to obtain a
valid receipt within the admitted bound produces a non-clean process result
and leaves only immutable material eligible for later export or loss
classification. Recovery may complete that export but cannot resume the
Training Session.

Operational signals use source identities and monotonic sequences. A collector
acknowledges immutable records; producers retry within finite separate buffers.
Buffer exhaustion or unrecoverable delivery failure creates the applicable
sequence gap and loss signal. Neither transport, acknowledgement, collection,
nor retention can block Canonical Tick, Prediction, or Presentation.

## Failure containment and verification

Uncertainty about canonical commit, AUTH audit integrity, Technical Removal,
terminal result, or durable handoff fails closed in the smallest scope that
preserves higher-ranked qualities. One client loss removes only that Trainee;
loss of a whole Session Authority terminates only its Training Session;
collector loss does not mutate product state; and one corrupt retained class
does not grant authority over another.

Architecture verification injects loss immediately before and after every
commit and handoff point. It proves Admission grant-before-audit rejection,
host audit recovery, Technical Removal atomicity, continued ticks with the
remaining roster, last-Trainee Scenario disposition, absence of continuity
state, reconstruction ordering and loss classification, terminal receipt
gating, idempotent retry, trust-domain separation, rotation behavior,
authorized- and unauthorized-recipient confidentiality cases, retention
boundaries, and executable closure. No prototype
blocks this semantic decision; concrete mechanisms require their own test
vectors and failure evidence before production admission.

## Considered options and consequences

Client reconnection through Technical Pause was rejected because its claims,
proofs, windows, restoration catalogue, lifecycle states, audit combinations,
and client persistence imposed disproportionate baseline complexity. Treating
disconnection as Fatal was rejected because a technical failure must not
fabricate simulated injury or contaminate tactical and assessment evidence.
One generic persistence module and one shared trust root were rejected because
they would erase semantic ownership and enlarge compromise scope.

The resulting live runtime is smaller: one Admission connection, irreversible
Technical Removal, continued fixed-step Simulation, terminal evidence, and
process exit. The costs are no recovery from transient client failure, smaller
Teams after disconnection, explicit `Withdrawn` item disposition, permanent
retained evidence growth, and a new persistent performance-assessment seam.
Exact storage engines, schemas, cryptographic algorithms, secret managers,
collectors, process placement, orchestration, and deployment topology remain
design or later deployment decisions.

This decision resolves issue #35 and traces principally to `SCOPE-AUTH-001`,
`REQ-SESSION-DISCONNECT-001` through `REQ-TECHNICAL-REMOVAL-006`,
`REQ-AUTH-AUDIT-WRITE-GATE-001` through
`REQ-AUTH-AUDIT-WRITE-RECOVERY-001`, `REQ-AUTHORITY-SINGLE-SESSION-001`
through `REQ-SESSION-TERMINATION-STATE-001`,
`NFR-OBSERVABILITY-CORE-001` through
`NFR-OBSERVABILITY-ALERTING-001`, `PERF-IDENTITY-001` through
`PERF-AVAILABILITY-001`, `PROCESS-EVIDENCE-RETENTION-001`, and
`CONSTRAINT-NFR-TEAM-001`.
