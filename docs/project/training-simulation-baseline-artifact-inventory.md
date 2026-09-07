# Baseline artifact index

Status: Active generated-index policy under ADR-0014. Owner: Project owner.
The index helps find governed sources and their traces; it cannot approve a
product baseline or infer implementation from an accepted document.

Canonical facts remain in exactly one source:

- [Applicability decisions](../requirements/training-simulation-baseline-applicability-inventory.csv): Included, Future or Not Applicable, with owner and milestone/justification.
- [Architecture Claim register](training-simulation-architecture-claim-traces.csv): governing source, exact requirement relations and independent states.
- [Design Commitment register](../design/training-simulation-design-commitments.csv): governing SDD, exact requirement/claim/view relations and independent states.
- Requirements, ADRs and contracts: their actual normative text; Git identifies the revision.
- Test/CI reports retained for acceptance: executed inputs, outputs and dispositions, never an inferred Pass from file existence.

`python3 scripts/documentation.py generate` derives `build/docs/artifacts.csv`
and `references.csv` from these sources. They are disposable navigation, not a
second manually maintained authority. `python3 scripts/documentation.py check`
checks populations, source paths, traces and state values without frozen source
hash constants or recursive inventory approvals.

The former `BART-*` lookup is retained only in
[history](../research/legacy-document-control/training-simulation-baseline-artifacts.csv).
Current Architecture Claims point directly to their canonical source paths.
Retired process IDs resolve through the [migration map](documentation-migration.csv).
