# Baseline applicability

Status: Existing product scope dispositions preserved; documentation-policy
successor authorized under ADR-0014. Prior candidate product/source amendments
remain candidate; this reform does not approve them. Owner: Project owner.

The [CSV](training-simulation-baseline-applicability-inventory.csv) is the canonical
per-identifier decision: `Included` in the Development Baseline, `Future` at a
named milestone, or `Not Applicable` with justification. No requirement may be
omitted to make a baseline appear complete. Scope changes need explicit owner
decisions; mechanical source hash changes do not require another approval cycle.

The reform preserves every product disposition, owner and milestone. Retired
administrative identifiers remain in the CSV as `Not Applicable`, with an explicit
[replacement](../project/documentation-migration.csv); new lightweight process
rules are `Included`. History is retained, not silently renumbered or erased.

Run `python3 scripts/documentation.py check` to reconcile unique definitions,
retired-ID dispositions and exact population. Run `generate` for current source
hashes and totals in `build/docs/`. The prior frozen-hash control is retained as
[reference history](../research/legacy-document-control/baseline-applicability-control.txt).
