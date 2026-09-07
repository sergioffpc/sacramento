# Architecture specification: cross-cutting architecture and verification

Status: Accepted architecture decision; implementation,
evidence, and baseline acceptance remain incomplete

Approval: Project owner, 2026-09-03

Latest approved amendment: Autonomous Participant decomposition trace, project owner, 2026-09-04

Purpose: Define the remaining cross-cutting contracts, architecture-level
verification strategy and evidence-impact behavior for the Development Baseline.

Owner: Project owner

Sacramento closes its Development Baseline architecture decisions without
claiming that the decided architecture is implemented, verified, production
secure, operationally available, or accepted as a product baseline.
Cross-cutting behavior remains behind the interface of the responsibility
module that owns its meaning. Runtime compositions coordinate whole-process
ordering and aggregate lifecycle outcomes but do not become a generic
configuration, error, resource, testing, or evidence module.

Architecture verification is cumulative: static closure, interface and adapter
contract tests, native executable closure, and a small set of representative
success and failure sequences each answer different questions. Architecture
claims and evidence dependencies are explicit so a future change cannot retain
evidence merely because no reviewer happened to notice an unstated coupling.

## Decision and baseline status

Accepted architecture is not implemented or accepted product behavior. Decision,
scope, realization and evidence remain independent facts in their owning
contracts and change records; there is no global Architecture Claim register.
Current Development Baseline contracts remain unimplemented with blocked product
evidence. Autonomous Participants, production security and platform operations
remain future. ADR-0014 supersedes the old administrative controls only.

## Responsibility-owned cross-cutting seams

There is no cross-cutting manager. The deletion test for each proposed module
or seam remains whether its removal would force meaningful complexity back
into several callers. A seam exists for demonstrated variation, failure
injection, or independently governed ownership, not to wrap each mechanism.

### Immutable configuration

Every execution-affecting value belongs to an immutable, identified view
selected by the Runtime Launch Specification, Runtime Content Release, or
applicable Approved Profile. Each responsibility module validates its own
portion and publishes nothing until that portion is complete. Runtime
composition verifies the complete selection and compatibility before `ProcessReady`.

After readiness, a module cannot discover a newest version, consult mutable
defaults, reinterpret the process environment, or read another module's
private configuration. A configuration change applies only to a later process
execution. Configuration identities cross seams; native environment, file, and
vendor representations remain private to adapters.

### Stable outcomes and diagnostics

An interface failure crosses its seam as a stable Sacramento outcome that
identifies the responsible operation, failure category, affected scope, and
whether that contract permits retry. Expected denial, invalid input, capacity
rejection, dependency unavailability, invariant failure, and process-fatal
failure remain distinguishable.

Native exceptions, error codes, device messages, transport details, and
security-sensitive diagnostics remain inside the adapter and governed
Observability. Runtime composition maps stable outcomes to the established
readiness, lifecycle, Training Session, and exit classifications. It cannot
invent domain meaning, broaden failure scope, or expose a native mechanism.

### Resource lifetime and cleanup

The module that exclusively owns mutable state also owns the lifetime of its
associated resources and private adapters. Acquisition follows declared
dependency order. A resource or immutable view becomes visible only after its
complete validation and applicable capacity reservation. Shutdown releases in
reverse dependency order within the admitted bound.

Cross-owner movement uses an immutable handoff or an explicit ownership
transfer with one source and one recipient. Cleanup failure cannot resurrect
live state, extend a Training Session, roll back a committed Canonical Tick, or
turn an uncommitted outcome into a committed one. Forced process loss discards
live resources; retained candidates remain governed only by their proved
commit points and ADR-0008.

### Security applicability

`AUTH & Admission` retains one Sacramento interface with mode-applicable
lifecycles and stable outcomes. Every configuration, adapter, operation, and
evidence record declares its mode. The Development Baseline adapter accepts
only launch-declared Synthetic Identities, produces no Canonical Identity Key,
and emits only explicitly unauthenticated test evidence.

Production-only fields and effects are absent in permissive mode rather than
populated with invented values. No permissive result satisfies authentication,
authorization, protected exchange, durable AUTH audit, revocation,
authenticated evidence custody, operational trust, Formal Assessment,
Leaderboard, or another Production Security Baseline obligation.

## Test interfaces and contract surfaces

Test adapters occupy only real seams or points requiring controlled variation
or failure injection: clocks, deterministic randomness, capacity, devices,
transport, immutable-artifact access, persistence, external custody,
Observability emission, and mode-applicable identity behavior. Tests receive
explicit profiles, clock observations, input sequences, and seeds through the
same Sacramento interfaces used by ordinary callers.

Every production, development, and test adapter at one seam runs the same
interface contract suite. Adapter-specific qualification adds evidence but
cannot replace that suite. A public test-only bypass, test-only mutation of
another owner's state, or assertion against private vendor state violates the
seam. Internal seams may support a module's own tests without becoming part of
its external interface.

Contract tests cover, where applicable:

- accepted inputs, closed rejections, stable outcomes, and retry rules;
- immutable configuration and exact version binding;
- ownership, publication, capacity, commit, and release ordering;
- cancellation, timeout, process-loss, exhaustion, and cleanup behavior;
- idempotent identity, acknowledgement, retry, and duplicate handling;
- absence of native platform, vendor, orchestrator, or test-only types; and
- evidence-hook cardinality, correlation, minimization, and explicit loss.

## Architecture-level verification

The verification layers accumulate:

| Layer | Question answered | Minimum surface |
| --- | --- | --- |
| Static closure | Is every claim explicit, applicable, owned, traced, and structurally consistent? | Architecture Claim records, views, dependency rules, inventories, compatibility declarations, and prohibited-dependency checks |
| Interface contract | Does each adapter preserve the Sacramento seam under success and controlled failure? | Shared adapter contract suites and owner-interface tests |
| Native executable closure | Can each executable run from only its declared immutable closure on its admitted target? | Windows Trainee Client, Debian Session Authority, and admitted offline tools; Content Cooker native closure waits for platform admission |
| Representative sequences | Do independently valid seams compose into the required end-to-end outcomes? | Reference Personnel Recovery success and the smallest set of architecture-dominating failures |

Static inspection cannot prove executable closure. A contract suite cannot
prove native packaging or whole-runtime composition. A demonstration cannot
replace exhaustive contract negatives or obligation-level evidence.

Native executable closure runs each role on its applicable native platform
using only the exact Application Release, declared immutable artifacts, and
approved dependencies. It covers startup, readiness, representative contract
exercise, shutdown, and negative cases for missing, unexpected, incompatible,
or undeclared dependencies. Build-graph or directory inspection is supporting
evidence, never the execution result.

The required representative sequence set is:

1. complete launch, permissive development Admission, Preparation, active
   Reference Personnel Recovery behavior, completion, durable terminal
   evidence receipt, and clean exit;
2. startup rejection before `ProcessReady` for an invalid or incompatible launch,
   content, profile, capacity, adapter, or destination;
3. loss of one client connection causing only that Trainee's Technical Removal;
4. Session Authority loss followed by a new process and new Training Session
   without restoration or continuity;
5. external-handoff unavailability through finite buffering, retry, recovery,
   explicit loss, reconstruction-capacity exhaustion, and terminal-receipt
   failure; and
6. rejection of a candidate Canonical Tick before commitment and failure after
   commitment, preserving atomicity and the smallest safe termination scope.

Other failures are variations in contract suites unless they expose a distinct
cross-module ordering or ownership decision. The sequences do not establish
complete functional coverage.

## Evidence hooks and change impact

An applicable seam makes the following attributable when required by its
verification surface: stable operation identity; owning module and adapter;
process, Training Session, Admission, event, and Canonical Tick correlations;
exact Application Release, runtime content, configuration, profile, and
contract versions; start and terminal result; stable outcome and affected
scope; capacity or reservation; commit and publication points; causal
correlation; and loss or incompleteness.

These are semantic hooks, not a requirement to emit every field in every
production signal. The Observability Contract selects the continuously enabled
core subset. Test harnesses, retained records, and acceptance environments own
their other applicable evidence while preserving data minimization,
sensitivity, identity, cardinality, and loss rules. A runtime hook reports a
fact; it never calculates or assigns verification `Pass`.

Evidence impact follows `VERIFY-CHANGE-001`: inspect actual dependencies,
including transitive effects, and rerun affected or uncertain results. Retain a
result only with reproducible obligation-level invariance reasoning. Direct links
and search help discovery, but absence of a reference never proves independence.
ADR-0014 removes inventory control, not conservative impact analysis.

## Architecture references

The [ADR index](../adr/README.md) links decisions to their exact contracts.
Those sources own responsibilities, required behavior and verification surfaces.
Former `AC-*` mappings are historical references recoverable at Git revision
`72456ee`; no global claim table or state CSV is maintained. Resource and cooker
contracts retain their local obligation labels for existing references.

## Software Architecture Description view set

The [architecture entry point](software-architecture-description.md) uses tailored
arc42 sections, C4 context/container diagrams and selected UML sequences. Detailed
contracts remain linked. Git preserves former view mappings; current changes link
directly to relevant sections. There is no fixed view count or repeated control table.

## Product closure boundary

ADR-0014 removes document inventories and their checks. Requirements and contracts
retain scope, design meaning and acceptance criteria; documentation changes cannot
approve a product baseline or prove dependency completeness.

Dependency qualification, reference workloads and deterministic replay artifacts,
unpopulated profiles/catalogues, product realization and native evidence remain
explicit blockers. Production security and platform operations remain future.

## Considered options and consequences

A generic cross-cutting framework would centralize unrelated meaning and weaken
responsibility ownership. Runtime hooks cannot assign Pass, and accepted decisions
cannot imply realization. Representative composition sequences complement local
contract variations; an exhaustive narrative catalogue adds duplication.

ADR-0014 changes the administrative trade-off: indexes are generated, and uncertain
impact requires conservative reruns instead of claiming a complete manually
approved graph. This preserves locality and traceability while reducing solo
maintenance. The original inventory rationale remains in Git history.

## Trace

Product contracts retain the Architecture Claim traces above. Current documentary
controls are `DOC-MAINTENANCE-001` and `VERIFY-CHANGE-001`; replaced process
identifiers have explicit dispositions in the migration map. Runtime, content,
persistence, deployment and Observability requirements are unchanged.
