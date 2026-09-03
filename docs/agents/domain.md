# Domain Documentation

Use this workflow before interpreting or changing product behavior, canonical
language, requirements, architecture, or verification obligations.

## Locate

1. Search for every affected term and stable identifier. Prefer the defining
   Markdown section over a CSV occurrence or cross-reference.
2. Read the document control block and the defining section for each affected
   branch. Expand to the whole document when the task spans the whole baseline.

   | Branch | Canonical source |
   | --- | --- |
   | Product roles, sessions, scenarios, represented actions, entities, or outcomes | `CONTEXT.md` |
   | Runtime, identity, packaging, timing, or deployment terminology | `docs/glossary/technical.md` |
   | Baselines, profiles, catalogues, inventories, evidence roles, or project controls | `docs/glossary/governance.md` |
   | Functional, process, scope, constraint, non-goal, or deferred entry | `docs/requirements/training-simulation-initial-requirements.md` |
   | Cross-cutting quality requirement | `docs/requirements/training-simulation-non-functional-requirements.md` |
   | Observability signal or collection contract | `docs/requirements/training-simulation-observability-contract.md` |
   | Performance assessment or engagement target | The matching performance requirement or profile under `docs/requirements/` |
   | Reference hardware | `docs/requirements/training-simulation-reference-hardware-profiles.md` |
   | Verification method, assignment, evidence, or acceptance | `docs/requirements/training-simulation-verification-plan.md` |
   | Baseline applicability disposition | `docs/requirements/training-simulation-baseline-applicability.md` and its linked CSV |
   | Architectural decision | The relevant concise file under `docs/adr/` |
   | Detailed architectural contract or trace | The ADR-linked file under `docs/architecture/` |

3. Limit reading to the branches involved. For architecture, read the ADR first
   and disclose its detailed specification when the task reaches its contracts,
   consequences, traces, or unresolved evidence.
4. Treat `docs/research/` as historical input. Resolve conflicts in favor of
   the canonical source identified by the Documentation Inventory.

## Apply

- Use canonical terms exactly, including capitalization, in issues,
  specifications, hypotheses, tests, designs, and implementation.
- Use the stable identifier when asserting, changing, or verifying a governed
  requirement, profile, decision, or claim.
- Preserve each source's status: the approved baseline remains authoritative
  until its candidate successor is approved.
- Use the verification-assignment CSV as an index into its source requirements
  and plan. Interpret the applicability CSV together with its Markdown control
  document.
- Treat an absent concept as a possible model gap. Name the gap instead of
  introducing an unreviewed synonym.
- Surface a conflict with an accepted ADR before proposing a successor; keep
  the accepted decision authoritative until that successor is approved.

## Completion criteria

The interpretation is complete when every affected term and stable identifier
has one identified canonical source and status, proposed wording uses that
source's language, and every conflict or missing concept is recorded as a
visible gap rather than resolved by assumption.
