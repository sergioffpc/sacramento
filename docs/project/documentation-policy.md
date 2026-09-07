# Documentation policy

**DOC-MAINTENANCE-001** — Retained documentation MUST have one identifiable
purpose, owner and status, stable requirement/claim/design traces where normative,
and working links to canonical sources. Architecture uses a tailored arc42 entry
point with C4/UML views and ADRs; no fixed view count, repeated control table or
mandatory Table of Contents is required. Git and generated indexes identify exact
document versions. Review MUST cover changed meaning and affected dependants,
not mechanically reapprove every inventory. An unresolved internal design choice,
ambiguous behavior or missing ownership/lifetime/order/failure/verification
contract blocks acceptance of that design, not unrelated work. Proposed design
and unrun evidence MUST remain explicit.

Status: Active — issue #61 authorized by the project owner, 2026-09-07.

This policy, adopted by [ADR-0014](../adr/0014-use-lightweight-executable-documentation.md),
governs documentation maintenance. It replaces the former inventory approval
process. Product behavior and acceptance thresholds remain owned by requirements.

## Read and change only what the task needs

Start at the [architecture overview](../architecture/software-architecture-description.md)
or [requirements guide](../requirements/README.md). Follow the affected contract,
decision or acceptance example. Research is optional background, not a prerequisite.
Each meaning has one canonical home; indexes and diagrams refer to it.

The architecture uses a tailored arc42 outline, C4 context/container/deployment
views and selected UML interaction/state views. Use components only when they
explain a real boundary. Keep the overview around 1,500 words, with details linked
on demand. A single status block identifies the described baseline. Titles,
paths and the reading guide establish purpose and audience; repeated per-view
control tables and mechanically maintained tables of contents are unnecessary.

## Review decisions at the affected boundary

For each change, state its purpose, affected requirements/decisions, observable
consequences, checks run and remaining uncertainty in the issue or pull request.
Review the affected sections and downstream consumers. Significant product or
architecture changes require an explicit owner decision; routine wording,
links, diagram layout and generated indexes follow normal change review without
separate approvals. Record a new ADR only for a significant decision with a
durable rationale. Retain earlier ADRs and mark only the superseded decision.

Requirements keep stable identifiers. Precise interfaces, units, finite limits,
ownership, ordering, integrity and failure outcomes remain in their owning
contract. A diagram is an explanatory view of those contracts. Proposed design
text remains proposed until accepted; a format change does not implement it.

## Generate administration; retain useful decisions

`python3 scripts/documentation.py check` validates retained paths, links,
identifiers, applicability, acceptance selectors and diagram provenance.
`python3 scripts/documentation.py generate` writes disposable document, artifact
and reference indexes under `build/docs/`. These are derived views, not semantic
approval or evidence of conformance. Source paths and content digests identify
working-tree revisions; Git identifies integrated revisions. There are no
recursive self-hashes or separate version approvals for these indexes.

The applicability CSV retains explicit Included/Future/Not Applicable decisions.
The Architecture Claim and Design Commitment registers retain decisions and
traces; their generated supporting indexes do not grant implementation or Pass.
Retired process identifiers remain in the migration map so old references are
resolvable. Exact content releases, source inputs and C++ toolchains retain their
own integrity rules; this policy changes document administration only.

## Verify the change and preserve history

Use the [verification workflow](../requirements/training-simulation-verification-plan.md)
for behavioral checks and evidence reuse. Missing dependency information means
rerun the relevant suite or broader checks, not assume an old result still holds.
No pre-registration or inventory approval is needed to run a test or validator.
Keep accepted evidence immutable under its existing retention obligation.

When retiring prose, preserve every normative meaning in its destination or
record the explicit policy change in the [migration map](documentation-migration.csv).
Historical versions remain recoverable in Git. Update links and agent routing
in the same change. Check the overview in an actual reading/update walkthrough;
word count and renderer success alone do not establish usefulness or correctness.
