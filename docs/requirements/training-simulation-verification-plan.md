# Acceptance workflow

Status: Active — documentary process replaced by
[ADR-0014](../adr/0014-use-lightweight-executable-documentation.md).
Owner: Project owner. This stable path now owns the lightweight acceptance
workflow; separate verification/validation plans and full-package approval are
not required for an ordinary increment.

## Work one behavior at a time

1. Select requirement IDs in the issue; query `python3 scripts/documentation.py requirement REQ-STATE-CONSISTENCY-001`.
2. Write a success example and relevant negative/boundary examples. State the expected observable outcome before implementation.
3. For deterministic behavior, write a failing test at the public seam, implement the smallest passing slice, then refactor with green tests.
4. Run affected contract/integration/native checks and required measurements or qualified evaluation. Attach the command, tested revision and results.
5. Review changed behavior and evidence in the issue/PR. Update affected requirements, contracts, diagrams or ADRs, not every catalogue.

For example, active client loss must cause Technical Removal, end Admission and
withdraw associated items without inventing injury. A test observes these public
outcomes and canonical revisions; it does not calculate its expected result using
the same implementation it tests.

## Acceptance rules

**VERIFY-EXAMPLES-001** — Every covered requirement MUST identify independently
fail-able clauses with stable test/example keys, positive and relevant negative
or boundary outcomes, and expected results justified by the requirement, an
independent reference model or approved data. A test or issue MAY own this
information; no duplicate procedure document is required. Material ambiguity
MUST be resolved at the canonical source before accepting the affected behavior.

**VERIFY-METHOD-001** — Deterministic transitions MUST use automated tests;
structural constraints MUST be inspected; physical outcomes MUST also use analysis
against versioned Approved Profiles. Required methods and evidence explicitly
assigned by the [catalogue](training-simulation-acceptance-examples.csv) or owning
requirement MUST accumulate. Demonstrations support complete flows but cannot
replace objective checks. Military validity, tactical adequacy or perception that
objective evidence cannot establish MUST use
[qualified Representative Evaluation](domain-evaluation.md); uncertainty requires
that evaluation. A documented owner-approved exception MAY remove only an
objectively inapplicable default, never an explicitly required method.
NFR/assessment catalogues retain their own assignments. Apply each method to the
clauses governed by its criteria; an objective clause does not require subjective
evaluation merely because another clause shares its requirement identifier.

**VERIFY-RESULT-001** — Each clause and Required method MUST receive an attributable
`Pass`, `Fail` or `Blocked` result. A requirement is `Pass` only when every normative
clause and Required method passes; any failure yields `Fail`, otherwise a missing,
unrun or blocked clause yields `Blocked`. Supporting evidence cannot compensate
for a missing Required result. Grouped tests MUST preserve separate results. A
planned example or accepted design is not a passing execution.

**VERIFY-CONTEXT-001** — Evidence submitted for acceptance MUST retain requirement
and clause keys, product/source revision, applicable Scenario/Map/content/profile
identities, procedure/test and input versions, environment/hardware/configuration,
execution time, executor, raw results and deviations. Test/CI output and a small
manifest MAY provide this; values MUST NOT be recopied into manual inventories.

**VERIFY-CHANGE-001** — Changes that can affect an accepted result MUST cause rerun
against the changed baseline. An unchanged result MAY be retained only with
recorded reproducible reasoning showing invariant obligation-level acceptance,
including transitive dependencies. Missing or uncertain dependency information
MUST mean affected, never unaffected. Ordinary tests need no pre-registered output,
approved global graph or inventory-version cycle.

**VERIFY-DEVIATION-001** — A changed test procedure MUST preserve exact obligations,
acceptance criteria, Required methods/evidence, controlled conditions, boundary
cases and attributable results. Unplanned deviations block affected acceptance
until reproducible element-by-element coverage is demonstrated and the owner
accepts it; otherwise rerun. Never adjust a tolerance after seeing results to make
a failure pass. Acceptance-meaning changes require an explicit requirement
decision, not a procedural exception.

**VERIFY-RETENTION-001** — Accepted and superseded acceptance evidence MUST remain
immutable, retained indefinitely and attributable to its original inputs and
decision. This reform authorizes no deletion or overwrite of accepted evidence.
Ephemeral diagnostic runs MUST NOT be cited as accepted evidence without retaining
the required record.

**VERIFY-ACCEPTANCE-001** — The implementation team MUST produce technical evidence;
qualified evaluators MUST produce required domain judgments. The project owner
accepts or rejects the changed increment and evidence; owner approval MUST NOT
replace required specialist evidence. Unchanged catalogue entries need no repeat
approval. This workflow cannot imply approval of a complete product baseline.

## Scope and baseline acceptance

**PROCESS-BASELINE-MANDATORY-001** — A baseline MUST NOT be approved unless every included `MUST` and `MUST NOT` obligation has an accepted `Pass` disposition and none has a `Blocked` disposition.

**PROCESS-BASELINE-PREFERENCE-001** — A `SHOULD` or `SHOULD NOT` obligation that does not have an accepted `Pass` disposition MUST have an explicitly justified project-owner-approved exception before baseline approval.

**PROCESS-BASELINE-PERMISSION-001** — A `MAY` obligation MUST receive implementation verification only when the permitted capability is included in the candidate baseline; omission of the capability MUST NOT constitute failure.

**PROCESS-BASELINE-SCOPE-001** — Non-goals and deferred capabilities MUST be inspected to confirm that baseline approval does not treat them as required or claim them as accepted capabilities.

Production-security assignments remain Future. The permissive development adapter
cannot pass them. Current examples have no product execution evidence.
The [migration map](../project/documentation-migration.csv) records retired process
IDs and replacements; [historical findings](../research/verification-ambiguity-history.csv)
are reference history, not new mandatory reviews.
