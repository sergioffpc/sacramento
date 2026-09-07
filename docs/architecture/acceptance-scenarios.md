# Architecture acceptance examples

Status: Designed, not executed. Owner: Project owner. These examples select
observable behavior for future tests; exact obligations remain in the linked
contracts. No product test or acceptance Pass is claimed here.

| Example | Given / when | Required observable result | Owning contract |
| --- | --- | --- | --- |
| AS-001 Normal session | Valid immutable launch and paired content; permissive development Admission; preparation and Personnel Recovery complete | Readiness follows validation/reservation; canonical progression and completion; Admissions close; evidence is sealed; finite durable receipt precedes clean exit | [Lifecycle](0009-runtime-deployment-contracts.md), [evidence](0008-evidence-and-ephemeral-state.md) |
| AS-002 Rejected startup | Missing/incompatible release, invalid trust/pair, failed materialization or insufficient capacity | No ProcessReady, Admission or partial active content; owned acquisitions are cleaned up and startup reports its stable failure | [Content](0012-runtime-resource-and-role-pack-architecture.md), [deployment](0009-runtime-deployment-contracts.md) |
| AS-003 Client loss | An active Trainee loses its connection | One atomic Technical Removal ends Admission and withdraws associated items with the canonical revision; no injury is invented; remaining participants continue unless a Scenario termination rule applies | [Tick](0005-fixed-step-authoritative-runtime.md), [ownership](0006-runtime-ownership-and-failure.md) |
| AS-004 Authority loss | The authority dies; provisioning starts another process | The ephemeral session terminates; the replacement owns a new session from initial state, not replay restoration; retained evidence remains a different lifetime | [Evidence](0008-evidence-and-ephemeral-state.md) |
| AS-005 Unavailable handoff | External observability/evidence/assessment handoff is unavailable; buffers reach their declared bounds, then recover or exhaust | Each seam preserves its own bounded retry, acknowledgement, backpressure and explicit loss rules; no indefinite Tick wait; loss of mandatory reconstruction capacity terminates; a failed terminal durable receipt cannot yield clean exit | [Handoffs](0009-runtime-deployment-contracts.md), [evidence](0008-evidence-and-ephemeral-state.md) |
| AS-006 Tick boundaries | Inject failure before commit, then independently after commit and before publication | Before: no canonical/time/event advance or partial publication. After: no rollback; complete publication or terminate with technical failure, never a partially authoritative Tick | [Tick](0005-fixed-step-authoritative-runtime.md), [ownership](0006-runtime-ownership-and-failure.md) |
| AS-007 Finite cooker | Valid immutable job; inject failures at capture, gate, packing, signing, durability, release publication and result publication; retry same and conflicting identity | Success publishes both packs plus processing record before job result; incomplete release never activates; identical retry is idempotent; conflict is rejected; ambiguous publication fails and blocks unsafe retry; owned cleanup and terminal exit occur without runtime readiness or Admission | [Cooker](0013-offline-content-cooker-tool.md), [candidate exact design](../design/0004-content-cooker-tool.md) |

For each implemented slice, attach requirement IDs, the relevant `AC-*` claims,
independent expected outcomes, public test names and run evidence in the issue or
test report. Split compound outcomes into separately failing assertions. Include
success and negative boundaries before claiming a scenario is covered.
