# Agent Instructions

Issues: When a task reads, creates, updates, triages, or derives work from an
issue, follow [Issue Tracker](docs/agents/issue-tracker.md). For triage-state
changes, also apply [Triage Labels](docs/agents/triage-labels.md).

Project model: Before interpreting or changing product behavior, canonical
language, requirements, architecture, or verification obligations, follow
[Domain Documentation](docs/agents/domain.md).

Documentation: When adding, removing, renaming, reclassifying, or changing the
canonical ownership of a retained document, update the
[Documentation Inventory](docs/project/training-simulation-documentation-inventory.md)
and run its validator.

C++: Before changing first-party C++, CMake, dependencies, toolchains, builds,
quality gates, or C++ CI, apply the
[C++ Engineering Baseline](docs/standards/cpp-engineering.md).

Git history: When creating commits, branches, pull requests, integrations, or
releases, apply the [Conventional Commit Profile](docs/standards/conventional-commits.md)
and [Git Flow](docs/standards/git-flow.md).
