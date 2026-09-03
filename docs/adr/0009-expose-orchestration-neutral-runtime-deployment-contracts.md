# Expose orchestration-neutral runtime deployment contracts

Status: Accepted

Approval: Project owner, 2026-09-03

Purpose: Define the platform abstraction, deployable units, immutable launch,
placement, packaging, compatibility, supervision, failure, and verification
contracts of the initial Training Simulation runtime without selecting its
production orchestration or security infrastructure.

Scope: Windows Trainee Client and Debian Session Authority runtime allocation,
platform seams, Application Releases, launch and readiness, Controlled LAN
connection, external operational handoffs, update and rollback, shutdown, and
architecture-level verification. Kubernetes resources, infrastructure high
availability, production security mechanisms, credentials, storage products,
and concrete package formats remain outside this decision.

Canonical information owner: Project owner

Intended readers: Architects, designers, implementers, verification authors,
operators, security reviewers, and infrastructure owners.

Prerequisites: `CONTEXT.md`, ADR-0003 through ADR-0008, and the approved
functional, non-functional, observability, performance-assessment, reference
hardware, and verification baselines.

Sacramento exposes small, immutable process contracts and leaves process
scheduling to external infrastructure. A Session Authority remains one
ephemeral process for one Training Session. Its loss terminates only that
Training Session, and replacement always starts a new Training Session. The
future infrastructure is responsible for keeping the capability to launch new
Session Authorities available; this decision defines neither Kubernetes nor a
capability-availability target.

Production authentication, authorization, protected exchange, durable AUTH
audit, revocation, and operational trust move to a separately approved
`Production Security Baseline`. The Development Baseline preserves the
`AUTH & Admission` seam through an explicitly non-production permissive adapter.
It does not claim that Synthetic Identity or unconditional authorization is
security.

## Deployment context and allocation

The initial runtime has four deployable-unit classes:

| Deployable unit | Allocation and lifetime | Responsibility |
| --- | --- | --- |
| `Session Authority Runtime` | One headless Debian process for exactly one Scenario and one Training Session | Composes the authoritative modules, publishes one endpoint after readiness, settles terminal truth, and exits |
| `Trainee Client Runtime` | One Windows process for exactly one Training Session | Materializes one Client Pack, connects to one assigned endpoint, submits Intentions, predicts, and presents |
| `Content Cooker Runtime` | One offline process per cooking job, outside the operational Controlled LAN | Produces one complete Runtime Content Release or no usable successor |
| Administrative Tool Runtimes | Offline, invoked on demand | Perform approved content, profile, catalogue, trust-package, provisioning, and recovery operations |

The Trainee Performance Assessment Module and the custody recipients for AUTH
Audit Checkpoints, Session Evidence Sets, and Observability remain neighboring
systems. This decision defines only Sacramento's seams and failure semantics;
their physical placement, replication, products, and availability belong to
later baselines.

The accepted deployment connects Windows Trainee stations and dedicated Debian
authority hosts through the Controlled LAN. No Trainee Client may be co-located
on an authority host. The initial acceptance allocation admits one active
Session Authority per `RHP-AUTHORITY-001` host. The architecture does not
prohibit greater future density, but a later Deployment Profile must prove
independent resource reservations, endpoints and artifact paths, no overcommit,
isolation, and every applicable workload before admitting it.

```text
Deployment/allocation view — initial acceptance

Windows Trainee station [0..16]       Dedicated Debian authority host [1]
  Trainee Client Runtime  --------->    Session Authority Runtime [0..1 active]
  exact assigned endpoint  Controlled   one Scenario / one Training Session
                           LAN
                              asynchronous, contract-specific handoffs
                                           |
                                           v
                              External custody and assessment seams
                              (placement selected by later baselines)
```

Arrows denote connection or immutable handoff, never shared ownership. Bracketed
numbers are allocation cardinalities for one accepted deployment, not process
autoscaling rules.

## Platform seams and dependency direction

There is no generic `Platform` module. A platform capability is a private seam
of the responsibility module that benefits from it. The runtime composition
supplies adapters; canonical modules see Sacramento results and types only.

| Owner | Private platform or mechanism seams |
| --- | --- |
| `Simulation` | Flecs and PhysX, deterministic numeric and scheduling capabilities |
| `Session Lifecycle` | Operational Clock and process-termination observation |
| `AUTH & Admission` | Trusted Identity Time, identity, cryptography, AUTH audit persistence, and later security adapters |
| `Runtime Package` | Immutable-artifact filesystem access |
| `Protocol & Replication` | Sockets and GameNetworkingSockets transport |
| `Presentation` | Vulkan/Falcor, Steam Audio, and output devices |
| `Input & Interaction` | Keyboard, mouse, microphone, and later Virtual-Reality devices |
| `Observability` | Measurement clocks, emission, finite buffering, and collector transport |
| Runtime composition | Process environment, shutdown request, readiness publication, and exit classification |

Windows, Debian, NVIDIA, device, filesystem, transport, and orchestrator types
remain inside their adapters. Each adapter converts native failures into stable
Sacramento outcomes. No adapter may mutate another owner's state, and no
platform callback may alter canonical state directly. A seam is introduced only
for demonstrated variation or controlled failure injection, not to wrap every
operating-system call.

## Immutable launch and readiness

Every runtime receives exactly one Runtime Launch Specification. It identifies
the exact role-applicable:

- Application Release and configuration;
- Authority Pack or Client Pack and Content Signing Trust Reference;
- Runtime Execution Profile, Runtime Timing Profile, and other applicable
  Approved Profiles;
- Identity Validation Package and trust when the Production Security Baseline
  applies;
- AUTH mode and Synthetic Identities when the non-production permissive adapter
  applies;
- endpoint, capacities, Observability Contract and detail level; and
- enabled external handoff contracts and destinations.

The specification references artifacts and destinations; it is not a container
for bulk content or secrets. External provisioning places complete immutable
Application Releases, packs, profiles, trust material, and configuration before
process start. A runtime neither scans directories nor chooses a newest version,
downloads content, reads mutable defaults, or tries an alternative.

Startup is all or nothing:

```text
Process start
  -> parse and identify the Runtime Launch Specification
  -> validate role, Application Release, compatibility, content and profiles
  -> validate capacities and every required adapter and destination
  -> recover only the runtime owner's retained candidates, when applicable
  -> materialize one immutable runtime view
  -> authority: bind the exact endpoint
  -> publish Ready and the endpoint
  -> accept connection or begin the assigned client connection
```

Before `Ready`, the externally visible state is `Starting`. Any failed
precondition produces `Not Ready`, one stable non-sensitive failure
classification, cleanup, and a non-zero exit. A partially initialized authority
accepts no connection or Admission and never enters Preparation. A client
materializes its content and required devices before connecting.

All destinations mandatory for an execution are validated before readiness.
Their later unavailability follows their separate nonblocking and terminal
semantics; it does not turn partial startup into readiness.

## Connection and infrastructure contract

External infrastructure assigns an exact Session Authority endpoint to each
Trainee Client through its Runtime Launch Specification. There is no broadcast,
multicast, server list, directory scan, client-side selection, or endpoint
fallback. Under the Production Security Baseline the client additionally binds
the expected Session Authority Identity before disclosing its own evidence. The
permissive adapter uses the same connection and Admission seam with declared
Synthetic Identities for the Trainee, Client Device, and Session Authority
identity classes.

The orchestration-neutral external process contract contains only:

- immutable launch-specification and process-execution identities;
- `Starting`, `Ready`, `Not Ready`, `Stopping`, and `Terminated` states;
- the endpoint, published only with `Ready`;
- reserved-capacity disposition;
- runtime and Training Session identities;
- stable readiness, terminal-settlement, and exit classifications; and
- graceful-shutdown request and bounded termination observation.

Sacramento provides no resident launcher or supervisor. A test harness, an
operator-controlled executor, or later infrastructure may exercise the same
contract. Kubernetes may implement the contract later, but no canonical module
depends on Kubernetes concepts.

A replacement process always receives a new process-execution identity and
creates a new Training Session from the Scenario's initial state. It cannot
resume an Admission, reuse live state, infer success from retained evidence, or
adopt the previous process's endpoint identity as continuity proof.

## Packaging, compatibility, update, and rollback

An Application Release contains one complete executable runtime and dependency
closure for one exact role and platform. It remains separate from the Runtime
Content Release and Runtime Launch Specification. A concrete Windows installer,
Debian archive, container image, filesystem layout, and distribution mechanism
remain design or infrastructure choices.

The Deployment Compatibility Matrix admits exact combinations of:

- client and authority Application Releases;
- Protocol & Replication contract;
- Runtime Content Release and both role-specific content contracts;
- Runtime Launch Specification contract;
- Observability Contract; and
- applicable external-integration contracts.

Client and authority builds need not have the same identity, but their exact
combination must be present in the approved matrix. There are no compatible
version ranges, runtime migration, translation, or dynamic version negotiation.
An absent combination fails before Admission.

Installation and candidate validation occur outside runtime processes.
Activation atomically changes the complete selection available to future
launches and never patches an active process. A failed candidate activation
leaves the preceding selection unchanged. Rollback explicitly selects a
preceding approved and compatible Application Release and Runtime Content
Release for a new process. Automatic downgrade, patch-in-place, session
migration, and startup fallback are prohibited.

## External handoffs and failure containment

ADR-0008's semantic ownership remains unchanged. Each external integration has
its own adapter, identity, capacity, acknowledgement, retry, loss, failure, and
mode-applicable trust contract. Co-location by later infrastructure cannot merge storage,
credentials, trust, authorization, or semantic ownership.

- Observability uses finite buffering, idempotent acknowledgement, retry, and
  explicit loss accounting.
- Trainee performance events use stable identities and idempotent delivery;
  assessment may become lagging, incomplete, or invalid without feeding back
  into Simulation.
- Future AUTH Audit Checkpoint delivery does not block Canonical Ticks; lost
  audit integrity may close later AUTH Operations when the Production Security
  Baseline applies.
- ordinary Session Evidence Set export is asynchronous and uses separately
  reserved capacity.
- inability to preserve a complete reconstruction record prevents publication
  of that candidate tick and terminates the Training Session as a canonical-path
  integrity failure.
- terminal settlement requires its durable Session Evidence Set receipt for a
  clean exit; failure within the bound produces a non-clean exit and never
  extends or restores the Training Session.

One Trainee Client loss affects only that Trainee through the phase-applicable
Admission end or Technical Removal. One Session Authority loss terminates only
its Training Session; other authority processes and the ability of external
infrastructure to launch new ones remain independent. Availability of that
launch capability, infrastructure redundancy, scheduling, failover, cluster
topology, power, network high availability, hardening, secrets, and operational
credentials belong to a future `Platform Operations Baseline`.

## Shutdown

A graceful external shutdown request starts non-normal Training Session
termination. The authority stops new ingress, finishes any begun Canonical Tick,
fixes the applicable terminal result, closes Admissions, seals the Session
Evidence Set, attempts its durable receipt within the admitted bound, settles
applicable AUTH audit and bounded core Observability, releases live state, and
exits. The Trainee Client stops new intentions, releases its local materialized
state and devices, and exits.

Forced process loss discards all live state. Retained artifacts are classified
only from proved commit points. A later administrative recovery may complete an
idempotent export but cannot reconstruct the Training Session.

```text
Graceful authority shutdown
  shutdown requested
  -> stop new ingress
  -> finish a begun Canonical Tick, if any
  -> fix the non-normal terminal result
  -> close Admissions
  -> seal the Session Evidence Set
  -> obtain the durable receipt or reach its bound
  -> settle mode-applicable AUTH audit and bounded core Observability
  -> release live state
  -> publish Terminated and the exit classification
```

Representative authority loss and replacement follows a different sequence:

```text
Authority process becomes unobservable
  -> its endpoint is no longer Ready
  -> its Training Session and Admissions end without restoration
  -> retained candidates remain only at proved commit points
  -> other Session Authorities and Training Sessions continue unchanged
  -> external infrastructure may submit a fresh Runtime Launch Specification
  -> a replacement process creates a new Training Session from initial state
```

Representative external-handoff failure preserves canonical progress:

```text
External destination becomes unavailable
  -> the owning adapter retains records within its independent finite capacity
  -> Canonical Ticks continue without waiting for delivery
  -> retries reuse each record's stable identity
  -> recovery acknowledges the same records idempotently
  -> exhaustion emits the applicable loss or incomplete classification
  -> only reconstruction-capacity exhaustion terminates before a candidate tick
  -> only missing terminal evidence receipt changes clean exit to non-clean
```

## Non-production AUTH adapter and future security

The Development Baseline may compose one permissive `AUTH & Admission`
adapter that unconditionally grants the declared permissions to Synthetic
Identities for the Trainee, Client Device, and Session Authority identity
classes supplied by immutable launch configuration. It still exercises finite
attempt, decision, Admission, lifecycle, correlation, ordering, and failure
interfaces. Each granting decision and its non-durable, mode-marked audit test
event precede the visible Admission or other granting effect. Failure to emit
that event prevents the effect. Its records are test evidence only, are
explicitly marked unauthenticated, and cannot support production, Formal
Assessment, Leaderboard, or a security claim.

The permissive adapter does not implement authentication, identity proof,
protected exchange, revocation, durable-before-effect AUTH audit, audit
recovery, operational trust, or authenticated evidence custody. Production
admission remains blocked until the separately approved Production Security
Baseline supplies and qualifies those adapters without changing the canonical
module interface.

This applicability amendment supersedes ADR-0004, ADR-0006, and ADR-0008 only
where they describe production-security mechanisms as obligations of the
Development Baseline. Their ownership, persistence seams, trust-domain
separation, failure containment, ephemeral live state, Technical Removal, and
non-restoration decisions remain accepted as constraints on the future secure
adapter.

## Verification

The process interface is the architecture-level test surface. Verification can
observe exact launch and execution identities, lifecycle states, endpoint
publication, capacity disposition, Training Session identity, terminal receipt,
and exit classification. Test adapters inject failures immediately before and
after validation, activation, readiness, connection, owner commits, handoffs,
and shutdown transitions.

Required architecture cases cover incomplete or mutated launch input; missing,
wrong, corrupt, or incompatible application, content, trust, or profile input;
failure around readiness; refusal of a second session; wrong endpoint and
incompatible peers; isolated client loss; isolated authority loss; replacement
as a new session; every external-integration loss and recovery; buffer
exhaustion, idempotent retry, and loss accounting; graceful and forced shutdown
at each lifecycle phase; update and rollback affecting only future processes;
Synthetic Identity evidence exclusion; native executable closure; and absence of OS,
vendor, or orchestrator types from canonical interfaces.

Isolation fixtures may run multiple authority processes concurrently, although
the initial Reference Hardware acceptance admits only one active process per
host. No prototype or external research blocks this semantic decision. Concrete
package, orchestration, storage, and security mechanisms require focused
evidence when selected.

## Considered options and consequences

A Sacramento launcher was rejected because it would duplicate scheduling and
supervision that external infrastructure already owns. Runtime discovery and
automatic fallback were rejected because they enlarge mutable launch state and
make exact compatibility unauditable. A generic Platform module was rejected as
a shallow interface that would mix unrelated clocks, devices, filesystems,
transports, and lifecycle behavior. Infrastructure redundancy inside this
decision was rejected because it would couple canonical runtime architecture to
an unselected platform and exceed the present two-generalist operating scope.

The result is a small runtime contract that can later be hosted by Kubernetes
without making Kubernetes part of Sacramento. It makes individual Training
Session loss explicit while permitting infrastructure-level resilience for new
launches. The costs are no automatic runtime fallback, explicit compatibility
administration, full pre-start validation, one-authority-per-host acceptance
until further evidence, and deliberate deferral of production security and
availability claims.

This decision resolves issue #37 and traces principally to
`REQ-AUTHORITY-SINGLE-SESSION-001` through
`REQ-SESSION-TERMINATION-STATE-001`, `REQ-CONTENT-RELEASE-001` through
`REQ-CONTENT-RETENTION-001`, `REQ-PLATFORM-ACCEPTANCE-PROFILE-001` through
`CONSTRAINT-AUDIO-DEVICE-001`, `NFR-OBSERVABILITY-CORE-001` through
`NFR-OBSERVABILITY-ALERTING-001`,
`DEFERRED-NFR-AUTHORITY-CAPABILITY-AVAILABILITY-001`,
`PERF-PERSISTENCE-001`, `PERF-AVAILABILITY-001`, and
`CONSTRAINT-NFR-TEAM-001`. Production-security requirements retain their exact
identifiers but move to the Production Security Baseline; capability
availability moves to the Platform Operations Baseline.
