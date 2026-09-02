# Isolate runtime owners and bound failure propagation

Status: Accepted

Sacramento runs each Session Authority Runtime, Trainee Client Runtime, and
Content Cooker Runtime as one product process with responsibility-derived
execution domains inside it. Every responsibility module remains the exclusive
writer of its mutable state and resources; runtimes coordinate workflows using
Sacramento commands, outcomes, immutable identified views, and explicit
publication fences without acquiring module state. Work receives finite
capacity before acceptance, waits and failure propagation are closed by
architecture policy, and overload terminates at an admitted bound rather than
weakening the fixed-step authority or inventing a Technical Pause.

This decision implements the ownership and concurrency consequences of
ADR-0004 and ADR-0005. It does not reopen their module decomposition, fixed
240 Hz authoritative Simulation, separate 240 Hz Prediction and 60 Hz
Presentation schedulers, Canonical Tick phases, deterministic Intention order,
continuity model, or prohibition on live Session Authority recovery.

## Process and execution-domain view

An execution domain groups work with a common cadence, blocking policy, and
failure-containment need. It is not a promise of a thread, executor, job system,
or process. One domain may serve more than one module when their invariants
permit it, and no domain gains ownership of the modules it schedules.

| Runtime | Required execution domains |
| --- | --- |
| Session Authority Runtime | Canonical control; Protocol & Replication I/O; AUTH control and durability; asynchronous publication and evidence. |
| Trainee Client Runtime | Protocol and AUTH control; Prediction; visual Presentation; acoustic and device I/O; asynchronous evidence. |
| Content Cooker Runtime | Orchestration and validation; bounded content transformation; content I/O and evidence. |

The Session Authority remains one headless Debian process. Falcor, client
audio, presentation devices, and source-import dependencies remain absent from
its closure. The Trainee Client and Content Cooker are separate processes with
their own failure scopes. External readiness monitors and collectors are
neighboring deployment elements, not owners of Sacramento state.

Additional product processes are not part of the initial architecture. A later
split requires evidence that process isolation provides material containment or
operational value that outweighs its deployment and two-generalist maintenance
cost. The selected shape does not claim process failover or high availability.

## Exclusive ownership view

| Owner | Mutable architecture-level state and resources |
| --- | --- |
| Simulation | Canonical simulated state, Simulated Time, the Canonical Tick transaction, authoritative results, and the deterministic reconstruction record for each Simulation commit. |
| Session Lifecycle | Training Session lifecycle state, Operational Clock deadlines, Ready state, Technical Pause, recovery coordination state, and the deterministic reconstruction record for each lifecycle revision. |
| AUTH & Admission | AUTH Attempts and Operations, Admissions, identity bindings, continuity state, AUTH audit state, durable append ownership, and incomplete-commit recovery metadata. |
| Content Admission | Candidate activation state and the reference to one exact admitted immutable content view. |
| Runtime Package | Persistent schema and codec compatibility state plus resources used to validate or materialize Sacramento packages. |
| Protocol & Replication | Connections, Intention sequences and dispositions, ACK and gap state, Replication Views, delta retention, transport adapters, and publication state. |
| Observability | Signal sequencing, buffering, loss accounting, correlation state, and emission-adapter resources. |
| Prediction | Confirmed and speculative client state, lead and retained history, correction, and reset state. |
| Presentation | Rendering, acoustic, interaction, and device state and resources. |
| Executable runtime | Process lifecycle and transient workflow coordination only, including cancellation roots, opaque prepared outcomes, publication fences, and correlation tokens. |
| Content Cooker Runtime | In addition to process coordination, job-local source-import state and private source-import adapters that never survive as runtime content state. |

A runtime never reads or mutates module-private state. A cache, adapter, worker,
or backing resource belongs to the module that benefits from it. Vendor types,
callbacks, scheduler objects, and resource handles never cross a Sacramento
interface or become an ordering source.

`Simulation` and `Session Lifecycle`, rather than `Observability`, own the
reconstruction records corresponding to their commits. Those immutable records
are replay truth. Their later persistence and transport may be asynchronous;
implementation logs, Observability signals, and network packets do not replace
them.

## Handoffs and view lifetime

Cross-owner interaction uses module-specific Sacramento commands and outcomes
or immutable identified views. A generic event bus, shared mutable store, and
direct state access are not admitted. Each owner serializes its visible commit
order even when it performs private calculations concurrently.

The producer of an immutable view retains ownership of its backing state and
defines a finite validity scope by operation, version, or admitted retention
window. Consumers retain neither mutable references nor vendor handles.
Expiration produces an explicit stale, resynchronization, reset, or terminal
outcome defined by the consuming interface. Shutdown blocks new views, settles
or cancels consumers, and then permits the owner to release the backing
resource; a consumer cannot extend resource lifetime indefinitely.

An accepted command belongs to one explicit workflow lifetime and cancellation
scope. Cancellation is itself a command to the owner. The owner emits exactly
one terminal outcome, and the runtime propagates cancellation only to known
descendants of that workflow. Before its commit point an owner aborts and cleans
up according to its interface. After the commit point cancellation cannot
erase the effect: the workflow completes required publication, performs an
explicitly admitted compensation, or reaches the applicable terminal failure.
A Canonical Tick cannot be cancelled after Intention sealing. AUTH additionally
obeys the AUTH Operation Inventory.

## Scheduling and permitted waits

Sacramento guarantees bounded progress by work class rather than imposing one
global priority order. Under an admitted workload, canonical control,
Operational Clock decisions, required Protocol ingress, and AUTH durable
progress receive protected capacity and cannot starve one another. A started
Canonical Tick is indivisible and is not preempted by work outside its phases.
Committed-result publication progresses immediately without batching behind a
later tick, but remains outside the commit barrier. Prediction and Presentation
keep their independent schedulers. Content I/O, Observability transport, and
diagnostic work use separately bounded or residual capacity.

Synchronous waiting is permitted only for this closed set:

1. a Canonical Tick waits for work belonging to its own atomic phases,
   including required private Simulation and PhysX work;
2. a granting AUTH effect waits for its complete durable AUTH Audit Commit
   Unit;
3. an approved cross-owner atomic workflow waits for its publication fence;
4. startup waits for mandatory validation and resource acquisition;
5. orderly shutdown waits for the bounded settling assigned to each work
   class; and
6. Prediction freezes when it reaches its admitted lead bound.

A Canonical Tick never waits for transport publication, ACK, Presentation,
Observability transport or collection, diagnostics, generic persistence, or
content I/O. Prediction never waits for Presentation. Adding another wait class
is an architectural change requiring evidence; a source-level synchronous call
does not create an exception.

Exact scheduler policies, priorities, sub-budgets, and worker counts remain
design decisions and measured profile inputs rather than consequences of this
ADR.

## Cross-owner atomicity

An operation that needs atomic external visibility uses prepare/commit with a
publication fence. Each owner validates and prepares privately, returning only
an opaque Sacramento outcome. The runtime coordinates the ordering point but
does not inspect the prepared state. Owners commit their own state, and the
composite effect becomes externally visible only after every required commit
completes.

Failure before commit aborts all prepared work. Failure after an irreversible
commit, when complete publication cannot be proved, is terminal in the smallest
scope that still preserves canonical consistency and AUTH integrity.
Compensation is permitted only when separately defined, deterministic, and
incapable of retroactively revoking a canonical or granting effect.

Publication fences are required for:

- successful initial Admission together with its first visibility in
  Preparation;
- continuity success comprising Admission rebind, claim rotation, current
  connection replacement, and the transition to Restoration Window;
- Admission end comprising AUTH and continuity invalidation, current
  connection removal, and Ready, Team Position, and Loadout cleanup;
- the initial transition to Active comprising the Session Lifecycle transition
  and atomic activation of every Trainee's initial Simulation state; and
- completion, termination, or reset when the transition changes state owned by
  more than one module.

The following are deliberately ordered workflows rather than multi-owner
transactions:

- the lifecycle gate and sealed Intention batch are immutable inputs to the
  Simulation-owned Canonical Tick commit;
- a connection loss accepted after a tick begins follows the completed tick
  with a Session Lifecycle transition into Technical Pause;
- Protocol & Replication produces State Restoration evidence and Session
  Lifecycle alone decides the restoration and resume transitions;
- Content Admission activates an immutable content view while process
  readiness remains unpublished during startup; and
- Replication publication, ACK, and Observability egress occur after their
  governing commit.

## AUTH durable execution

AUTH & Admission owns one logical commit order for each AUTH Audit Sequence.
Different AUTH Operations may validate concurrently, but complete AUTH Audit
Commit Units enter the current logical append target in the owner-selected
order. Storage completion order cannot define Sacramento order.

Before accepting an audited operation, AUTH & Admission reserves the ability to
persist its complete commit unit. A granting effect waits for the durable
success of its own unit. Audit-write failure closes the gate to new AUTH
Operations, produces no granting effect, preserves the existing Admissions and
active Training Session, and invokes the required incomplete-commit and cleanup
behavior. Audit recovery has exclusive logical access until it validates the
retained chain, dispositions incomplete artifacts, commits the required
recovery record, and reopens the gate.

This logical ordering does not prescribe a thread, mutex, storage engine,
transaction primitive, or flush call.

## Capacity and backpressure

Every owner admits work only after it can reserve a finite envelope sufficient
to reach exactly one terminal outcome, including the state, evidence, and
mandatory publication under that owner's responsibility. This is a semantic
reservation, not a requirement to allocate every physical byte in advance.
Work that cannot be admitted receives an explicit Sacramento disposition
before its commit point. Accepted work is never discarded merely to create
capacity.

| Handoff | Saturation disposition |
| --- | --- |
| Raw Protocol ingress | Invalid or excess pre-admission traffic may be discarded before it creates Sacramento work. This alone neither changes canonical state nor invents connection loss. |
| AUTH Attempt | Without operation and audit-write capacity, the attempt does not begin and uses the applicable generic denial when a protected response channel remains. |
| Intention ingress | Each Admission has a finite admitted window. An Intention that cannot enter receives an overload disposition bound to its sequence value, so it is neither silently lost nor left as a permanent gap. An accepted Intention remains until its terminal disposition. |
| Sealed Canonical Tick | Work is never dropped, merged, enlarged, or moved to another tick. Failure to remain within admitted catch-up terminates the Training Session. |
| Replication to a slow client | Ordered deltas continue within retention; an irrecoverable gap requests a new confirmed baseline. Failure to resynchronize within connection bounds closes that connection and invokes the normal recovery flow. |
| ACK | Pending high-water state may be replaced by a later high-water state only when its semantics are exactly preserved; Canonical Ticks are not merged. |
| Prediction | Reaching the lead bound freezes Prediction. Missing retained history resets it to a new confirmed baseline. |
| Presentation | Presentation may consume the newest Prediction view and omit intermediate frames or views; it never omits Canonical Ticks from authority. |
| Observability | Emission and transport never block a tick. Core loss is counted and affects acceptance and alerting as specified; optional diagnostics may be discarded. Reconstruction records are not discardable Observability signals. |
| Content Cooker | Saturation or resource failure fails the job without producing a partially deployment-ready package. |

Before Intention sealing, the owners establish capacity for the complete
canonical result, its reconstruction record, and the required publication
references. If global canonical, control, or publication capacity is
temporarily unavailable, the tick does not start and the existing bounded
catch-up rule governs the lag. Exceeding that bound terminates the Training
Session as a technical failure. Overload never creates or extends a Technical
Pause.

Exact values belong to the artifacts that own their evidence:

- the Runtime Timing Profile owns catch-up, Prediction lead and history,
  replication retention, heartbeat and loss detection, and runtime scheduling
  or queue bounds that affect the fixed cadences or 100 ms response target;
- applicable AUTH specifications and profiles own AUTH stage, retry, audit
  reservation, retention, and recovery bounds;
- the approved content-processing gate or profile owns the cooker resource
  envelope; and
- the Observability Contract and applicable deployment configuration own
  signal retention, buffering, and collector behavior.

No non-rate bound is approved without representative hardware and workload
evidence plus the required project-owner approval.

## Failure containment

Every Sacramento failure is classified at the smallest scope that preserves
the approved quality precedence: operation-local, Admission or client-local,
Training-Session-fatal, process-fatal, or explicitly degradable. Uncertainty
about canonical consistency, AUTH audit integrity, ownership, or unique
completion fails closed rather than continuing speculatively.

An owner may repeat or restart private adapter or worker work only before a
visible effect, within the admitted operation bound, and only when it can prove
state integrity, ordering, and exactly one outcome. After commit, only
idempotent publication may be retried. Otherwise the owner converts the
failure to a Sacramento outcome; the runtime never interprets vendor errors.

Loss of mandatory visual, acoustic, input, or output capability during Active
makes that Trainee Client unable to participate. It freezes Prediction, rejects
new gameplay input, and closes its connection in a controlled manner so the
Session Authority applies the ordinary connection-loss and Technical Pause
rules. It neither continues silently nor directly terminates unrelated
processes.

An isolated Protocol connection failure produces the connection-loss outcome
for that Admission. Global loss of Protocol & Replication, loss of its ordering
integrity, or inability to classify connections makes the Session Authority
NotReady and terminates the Training Session after preserving any already
started Canonical Tick. It is not represented as an incidental ordering of
individual disconnections and is not repaired inside a live Training Session.

Observability emission, transport, or collection failure does not by itself
terminate a Training Session. It follows the core-loss, acceptance-blocking,
retention, and alerting rules. Failure to create the complete in-memory
reconstruction record is instead a canonical-path integrity failure: the
affected result remains invisible and the Training Session terminates
deterministically. Persisting or transporting that record remains outside the
tick barrier.

## Startup, shutdown, and process loss

Startup is transactional by runtime composition. A process remains Starting
and externally NotReady while it validates dependencies and initializes owners
in topological order. Readiness becomes Ready only after complete validation.
Failure blocks new work, cancels the start attempt, releases initialized
resources in reverse order, and requires a clean new attempt; there is no
partial readiness or indefinite hidden startup retry.

Orderly shutdown performs this sequence:

1. enter Stopping, report NotReady, and block new work;
2. start no tick whose Intention sealing has not begun, but complete an
   indivisible tick already past that point;
3. cancel unadmitted work and assign terminal outcomes to admitted work;
4. terminate the Training Session and applicable Admissions;
5. settle AUTH Operations under durable-before-effect and incomplete-commit
   rules;
6. attempt bounded drain of committed publication and core Observability;
7. release resources in reverse composition order; and
8. reach Stopped.

A prepared workflow without a begun commit is cancelled. A publication fence
already in progress must settle; inability to prove its integrity invokes the
applicable terminal failure. Shutdown during Technical Pause terminates the
Training Session rather than completing continuity merely to preserve it.

Unexpected process loss has these dispositions:

- Session Authority loss is externally Missing and ends its Admissions and
  nonterminal Training Session. Restart recovers AUTH audit integrity and
  incomplete commits before readiness, but never resumes the live Training
  Session;
- Trainee Client loss invokes connection recovery. A new process on the same
  Client Device may use only the admitted protected continuity state within the
  existing window, and Prediction and Presentation restart from confirmed
  authority state;
- Content Cooker loss fails the identified job and admits no partial output. A
  later run has a new execution record; already completed immutable packages
  remain valid; and
- external monitor or collector loss does not mutate product state. It produces
  Missing readiness, signal-loss, and alert outcomes where applicable.

Absence of Stopping or Terminated evidence after a crash never invents an
orderly transition. Authority loss before a tick commit exposes no result from
that tick. Loss after commit may prevent publication but does not change the
committed reconstruction truth. If recovery cannot locate a commit point with
sufficient evidence, it classifies an integrity failure rather than assuming
success.

## Representative sequences

A normal active tick reserves its complete-result and publication envelope,
closes the lifecycle gate, seals an immutable deterministically ordered
Intention batch, performs the Simulation phases, commits the complete result
and reconstruction record, and exposes immutable Replication Views for
immediate asynchronous publication. Concurrent transport callbacks touch only
private Protocol & Replication state. Inputs accepted after sealing belong to
the next open tick; network arrival and client time never decide their order.

A connection loss accepted before the gate prevents the tick and enters
Technical Pause. A loss accepted after sealing allows the complete tick to
commit, cancels accepted but unsealed Intentions, and then enters Technical
Pause. Prediction returns to the paused confirmed version and freezes.
Successful continuity crosses the durable AUTH gate and the rebind publication
fence before Restoration Window begins. State Restoration and Ready outcomes
then permit the shared Resume Countdown; only the following Canonical Tick
advances Simulated Time. A further loss before Active resumes terminates
immediately.

Under composite overload, each seam applies its local disposition first:
pre-admission rejection, AUTH gate closure, per-client resynchronization or
connection loss, Presentation frame omission, and explicit Observability loss.
Accepted tick work remains intact. Only exhaustion of the global canonical
progress envelope consumes catch-up, and crossing its admitted bound terminates
the Training Session without creating Technical Pause.

## Verification and evidence

Module interfaces must support controlled delay, failure, cancellation, and
capacity-exhaustion outcomes through test adapters. Runtime workflows expose
Sacramento correlation sufficient to distinguish accepted, prepared,
committed, published, and terminal outcomes. Canonical Tick and lifecycle
evidence proves ordering, versions, and absence of partial visibility.
Capacity admission, rejection, saturation, catch-up, and starvation must be
observable without exposing vendor types or sensitive payloads.

Verification injects crashes immediately before and after durable AUTH commit,
each owner commit, and every publication fence. Deterministic replay compares
Sacramento reconstruction records and digests rather than logs or packets.
Executable-closure audits prove that client-only and source-import dependencies
remain absent from the Session Authority.

The governed Observability Contract successor in issue #29 owns the required
core runtime signal schemas. Issue #30 owns alignment of continuity
verification with the complete composite outcome. Neither ticket is
implemented by this decision.

No prototype blocks acceptance of this architecture because it does not select
a mutex, executor, worker count, queue implementation, or persistence
mechanism. Production admission still requires representative evidence for the
240/240/60 Hz cadences, the 100 ms action-response target, saturation behavior,
16 concurrent AUTH Attempts, durable audit commit, audit-write failure, and
recovery before the corresponding bounds or mechanisms can be approved.

## Considered options

- A process per responsibility module was rejected because ownership does not
  require process isolation and the deployment and recovery surface would work
  against the two-generalist ceiling.
- Mandatory AUTH, Protocol, or Observability helper processes were rejected
  without evidence of a containment need; later isolation remains possible
  behind the existing Sacramento interfaces.
- Shared mutable state, ownership transfer, and a runtime-owned transaction
  model were rejected because they contradict ADR-0004 and make private state
  and vendor scheduling part of cross-module correctness.
- One global scheduler priority was rejected because security, lifecycle,
  canonical progress, and publication require independent bounded progress
  rather than mutual starvation.
- Best-effort queues, unbounded growth, and post-acceptance discard were
  rejected because they hide overload and can change authoritative outcomes.
- Blocking transport, persistence, logging, profiling, Presentation, or ACK on
  the Canonical Tick was rejected because it weakens ADR-0005. AUTH
  durable-before-effect remains the deliberate security exception outside the
  Simulation commit.
- Uniform process termination and universal transparent retry were rejected in
  favor of the smallest scope that preserves the affected invariant.

## Consequences

The architecture supplies explicit runtime, ownership, concurrency, lifetime,
backpressure, and failure views while leaving source topology and mechanisms to
design. It contains vendor coupling, prevents asynchronous work from becoming
an accidental tick barrier, and makes saturation and crash behavior
deterministically verifiable.

The cost is explicit coordination state, prepared outcomes, publication fences,
capacity admission, and failure-injection evidence. These mechanisms must
remain deep inside their owning modules and runtimes; exposing them as a
generic concurrency framework would recreate the shallow mechanism-shaped
decomposition rejected by ADR-0004.

This decision resolves issue #31 and traces principally to
`REQ-AUTHORITY-001`, `REQ-CLIENT-TRUST-001`,
`REQ-STATE-CONSISTENCY-001`, `REQ-OPERATIONAL-CLOCK-001` through
`REQ-DEADLINE-ORDER-002`, `REQ-AUTH-ATTEMPT-LIFECYCLE-001`,
`REQ-AUTH-ATTEMPT-SUPERSESSION-001`, `REQ-AUTH-ATTEMPT-CONCURRENCY-001`,
`REQ-AUTH-AUDIT-WRITE-GATE-001`, `REQ-AUTH-AUDIT-COMMIT-001`,
`REQ-AUTH-AUDIT-WRITE-FAILURE-001` through
`REQ-AUTH-AUDIT-WRITE-RECOVERY-001`, `REQ-ADMISSION-ATOMIC-001`,
`REQ-ADMISSION-END-EFFECT-001`, `REQ-SESSION-DISCONNECT-001` through
`REQ-SESSION-RESUME-READY-LOSS-001`, `NFR-ACTION-RESPONSE-001`,
`NFR-AUTH-ADMISSION-001`, `NFR-OBSERVABILITY-CORE-001`,
`NFR-OBSERVABILITY-INTEGRITY-001`, and `CONSTRAINT-NFR-TEAM-001`.
