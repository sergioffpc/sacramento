# Sacramento

Sacramento is a multiplayer armed-forces training simulation focused on
realistic team exercises, authoritative simulation, and desktop-first access
with optional virtual reality.

The repository is currently in requirements definition. It does not yet
contain a selected software architecture or production implementation.

## Table of contents

- [Documentation](#documentation)
- [Verification inventory](#verification-inventory)
- [Development constraints](#development-constraints)
- [C++ build baseline](#c-build-baseline)
- [Contribution workflow](#contribution-workflow)
- [License](#license)

## Documentation

- [Domain language](CONTEXT.md)
- [Initial requirements](docs/requirements/training-simulation-initial-requirements.md)
- [Non-functional requirements](docs/requirements/training-simulation-non-functional-requirements.md)
- [Reference hardware profiles](docs/requirements/training-simulation-reference-hardware-profiles.md)
- [Observability contract](docs/requirements/training-simulation-observability-contract.md)
- [Trainee Performance Assessment requirements](docs/requirements/training-simulation-performance-assessment-requirements.md)
- [Engagement Target performance profile](docs/requirements/training-simulation-performance-profile-engagement-target-001.md)
- [Verification plan](docs/requirements/training-simulation-verification-plan.md)
- [Research guidance](docs/research/initial-goals-requirements-and-constraints-guidance.md)
- [C++ engineering research](docs/research/cpp-engineering-toolchain-and-quality-guidance.md)
- [C++ Engineering Baseline](docs/standards/cpp-engineering.md)
- [Conventional Commit Profile](docs/standards/conventional-commits.md)
- [Git Flow](docs/standards/git-flow.md)

## Verification inventory

The verification-assignment CSV is generated from the approved functional
requirements and their verification plan. Regenerate it with:

```sh
python3 scripts/generate-verification-assignment-inventory.py
```

Do not edit the generated CSV manually.

## Development constraints

Production code targets standard C++23. First-party Python is reserved for
repository automation, build, content-pipeline, verification, and maintenance
scripts. The canonical constraints and acceptance gates are defined in the
initial requirements.

## C++ build baseline

The approved Clang-only engineering configuration now lives at the repository
root. `CMakePresets.json` is the canonical interface for Debian and Windows
targets; `.clang-format`, `.clang-tidy`, the CMake target policy, vcpkg
manifests, project triplets, and cross-toolchain files are shared by all future
production modules.

The toolchains execute inside the pinned Ubuntu 26.04 build root materialized by
the canonical bootstrap. Materialize or read-only verify it with:

```sh
scripts/cpp-toolchain-bootstrap.sh install
scripts/cpp-toolchain-bootstrap.sh verify
```

Inspect the available profiles with:

```sh
cmake --list-presets
```

The proof and CI consume these root definitions, so a change cannot bypass the
Windows and Debian gates. The throwaway proof targets remain under `prototypes/`
and are not production engine code.

## Contribution workflow

The repository uses Git Flow with `main` as the release branch and `develop`
as the integration branch. All commit messages follow the repository's
Conventional Commit profile and all integrated commits must be signed. See
[Git Flow](docs/standards/git-flow.md) for branch and integration rules.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE).
