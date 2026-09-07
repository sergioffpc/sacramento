# Use lightweight architecture documentation and executable acceptance examples

Status: Accepted — project owner authorized issue #61 on 2026-09-07.

Two requirement clauses receive administrative amendments: `REQ-ACCESS-BASELINE-SCOPE-003`
moves scope approval to semantic changes used for baseline acceptance, not every
ordinary test; `REQ-VR-BASELINE-SCOPE-001` retains the same Desktop/VR future boundary
but uses actual transitive dependencies instead of an approved global graph.
No product behavior, applicability row, evaluator qualification or acceptance
threshold is changed by these amendments. Prior wording is retained at revision
`29d37ca` in Git.

`PROCESS-AUTONOMOUS-ACCEPTANCE-001` receives the same administrative clarification:
the future baseline still requires complete accepted scope, profiles and evidence,
but generated artifact/reference indexes are not separately approved packages.

Sacramento has one human developer. The cost of reading, maintaining and
approving parallel descriptions, versioned inventories and pre-registered
verification records has exceeded their value. We use one arc42 architecture
entry point, C4 structural views, selected UML sequences and existing ADRs.
Precise contracts remain linked references; behavioral acceptance examples move
towards executable tests as real product increments are implemented.

This decision supersedes the documentation-control and evidence-administration
parts of ADR-0010, including mandatory nine-view metadata, recursive inventory
approval, pre-registration before ordinary tests, and separate full-package
design reviews for routine edits. It preserves ADR-0010's responsibility owners,
contract tests, native execution and representative integration checks. The
[documentation policy](../project/documentation-policy.md) and
[verification workflow](../requirements/training-simulation-verification-plan.md)
own the replacement rules and their explicit migration dispositions.

Git history supplies document revisions; generated indexes supply navigation
and trace discovery. Review follows the affected requirement, contract and
diagram. Semantic changes are reviewed in the issue or pull request; mechanical
edits do not trigger additional inventory approvals. Accepted decisions,
candidate designs, implementation and test results remain separate facts.

The trade-off is less administrative evidence and greater reliance on readable
contracts, executable checks and conservative re-testing when impact is unclear.
Diagrams do not prove behavior, and TDD does not prove training suitability.
Product requirements, exact content/toolchain integrity, existing evidence
retention and explicitly required specialist evaluation are preserved.

Decision and authority: [issue #61](https://github.com/sergioffpc/sacramento/issues/61).
Research: [C4, arc42, ADRs and UML](../research/c4-arc42-architecture-documentation.md).
