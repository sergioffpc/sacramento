# Agent Instructions

Issues: When a task reads, creates, updates, triages, or derives work from an
issue, follow [Issue Tracker](docs/agents/issue-tracker.md). For triage-state
changes, also apply [Triage Labels](docs/agents/triage-labels.md).

Project model: Before interpreting or changing product behavior, canonical
language, requirements, architecture, or verification obligations, follow
[Domain Documentation](docs/agents/domain.md).

Documentation: When changing retained documentation, apply the
[Documentation Policy](docs/project/documentation-policy.md) and run
`python3 scripts/documentation.py check`. File/hash/reference inventories are
generated; do not hand-maintain them or request mechanical reapproval.

Acceptance: When changing behavior or accepting evidence, follow the
[Acceptance Workflow](docs/requirements/training-simulation-verification-plan.md).
Run ordinary tests without pre-registering outputs. When retaining old evidence,
apply the [Evidence Impact Workflow](docs/project/training-simulation-evidence-dependency-inventory.md).

C++: Before changing first-party C++, CMake, dependencies, toolchains, builds,
quality gates, or C++ CI, apply the
[C++ Engineering Baseline](docs/standards/cpp-engineering.md).

Git history: When creating commits, branches, pull requests, integrations, or
releases, apply the [Conventional Commit Profile](docs/standards/conventional-commits.md)
and [Git Flow](docs/standards/git-flow.md).
