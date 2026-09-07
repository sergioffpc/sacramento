# Documentation policy

Status: Active — project owner authorized removal of documentation inventories,
CSV registers, generators and validators on 2026-09-07.
Owner: Project owner. See [ADR-0014](../adr/0014-use-lightweight-executable-documentation.md).

**DOC-MAINTENANCE-001** — Keep one canonical home for each requirement, contract
and decision. Review changed meaning and affected dependencies; Git identifies
revisions. Update affected links and diagrams with the source change.
Documentation inventories, separate CSV registers, generated file/hash/reference
indexes and their validation/approval cycles are retired.

Start at the [architecture overview](../architecture/software-architecture-description.md)
or [requirements guide](../requirements/README.md), then read only the affected
requirement, contract or decision. Research is optional background. Use a short
arc42 overview, C4 structure, selected UML interactions and ADR rationale.
Diagrams explain contracts; they do not add obligations or prove implementation.

Requirements own product behavior, scope and acceptance criteria. Contracts own
interfaces, units, finite limits, ownership, ordering and failure outcomes.
ADRs own significant decisions and their rationale. Keep proposed design,
implementation and executed evidence distinguishable in their owning documents
and change records; no global claim or design-state register is required.
The project owner approves changed meaning, not a mechanically rebuilt package.

Use the [acceptance workflow](../requirements/training-simulation-verification-plan.md)
for tests, measurements, specialist evaluation and conservative evidence reuse.
Removing document validators does not remove product tests, C++ quality gates,
content validation or exact toolchain/content identities. The diagram renderer
remains an authoring aid, not an inventory generator or mandatory CI gate.

Old inventories, migration tables and document-control records remain recoverable
in Git at revision `72456ee`; they are no longer retained working-tree documents.
Keep accepted product evidence immutable and attributable. Check affected links
and read the changed flow before handing off a documentation change; there is no
replacement global inventory or dedicated documentation-validator workflow.
