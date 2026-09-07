# Agent Instructions

Issues: When a task reads, creates, updates, triages, or derives work from an
issue, follow [Issue Tracker](docs/agents/issue-tracker.md). For triage-state
changes, also apply [Triage Labels](docs/agents/triage-labels.md).

Project model: Before interpreting or changing product behavior, canonical
language, requirements, architecture, or verification obligations, follow
[Domain Documentation](docs/agents/domain.md).

Documentation: When changing documentation, follow the
[Documentation Policy](docs/project/documentation-policy.md). Update affected
canonical sources and links; Git records revisions.

Acceptance: When changing behavior or accepting evidence, follow the
[Acceptance Workflow](docs/requirements/training-simulation-verification-plan.md).
The workflow also governs conservative re-testing and reuse of accepted evidence.

C++: Before changing first-party C++, CMake, dependencies, toolchains, builds,
quality gates, or C++ CI, apply the
[C++ Engineering Baseline](docs/standards/cpp-engineering.md).

Git history: When creating commits, branches, pull requests, integrations, or
releases, apply the [Conventional Commit Profile](docs/standards/conventional-commits.md)
and [Git Flow](docs/standards/git-flow.md).
