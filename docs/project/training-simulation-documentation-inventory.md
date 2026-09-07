# Documentation inventory

Status: Active generated-index policy under [ADR-0014](../adr/0014-use-lightweight-executable-documentation.md).
Owner: Project owner. This page owns document classification and navigation;
the file population is derived, not a manually approved table.

| Location | Information owner / role |
| --- | --- |
| `CONTEXT.md`, `docs/glossary/` | Canonical product, technical and governance terminology |
| `docs/requirements/` | Canonical requirements, applicability decisions and acceptance criteria; README is navigation |
| `docs/architecture/` | Architecture entry point, exact contracts and explanatory generated diagrams |
| `docs/adr/` | Decision history; README is navigation |
| `docs/design/` | Detailed candidate/accepted design and Design Commitment states as explicitly recorded |
| `docs/project/` | Documentation policy, canonical claim states and historical migration dispositions; file/hash/reference listings are generated |
| `docs/standards/` | Engineering and contribution policy |
| `AGENTS.md`, `docs/agents/`, `.agents/skills/`, `README.md` | Conditional navigation and agent workflow, not product requirements |
| `docs/research/` | Non-canonical reference/history, never an implicit acceptance gate |
| `build/docs/` | Disposable generated indexes, not another information authority |

Project owner is the information owner unless a canonical source names a different
responsibility owner. A document states its purpose through its title/opening and
its own status when normative; repeated audience/prerequisite/control tables are
unnecessary. Links do not transfer normative ownership to a summary or diagram.

Run `python3 scripts/documentation.py check` after retained-document changes.
Run `python3 scripts/documentation.py generate` to create the exact retained-path,
format, role and SHA-256 inventory plus artifact/reference indexes in `build/docs/`.
Only generated data changes mechanically; semantic ownership changes require a
decision under the [documentation policy](documentation-policy.md).

Former manually maintained populations and their evidence records are preserved
as immutable [reference history](../research/legacy-document-control/README.md).
