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
- [Contribution workflow](#contribution-workflow)
- [License](#license)

## Documentation

- [Domain language](CONTEXT.md)
- [Initial requirements](docs/requirements/training-simulation-initial-requirements.md)
- [Verification plan](docs/requirements/training-simulation-verification-plan.md)
- [NFR interview inputs](docs/requirements/training-simulation-nfr-inputs.md)
- [Research guidance](docs/research/initial-goals-requirements-and-constraints-guidance.md)
- [Conventional Commit Profile](docs/standards/conventional-commits.md)
- [Git Flow](docs/standards/git-flow.md)

## Verification inventory

The verification-assignment CSV is generated from the requirements and
verification plan. Regenerate it with:

```sh
python3 scripts/generate-verification-assignment-inventory.py
```

Do not edit the generated CSV manually.

## Development constraints

Production code targets standard C++20. First-party Python is reserved for
repository automation, build, content-pipeline, verification, and maintenance
scripts. The canonical constraints and acceptance gates are defined in the
initial requirements.

## Contribution workflow

The repository uses Git Flow with `main` as the release branch and `develop`
as the integration branch. All commit messages follow the repository's
Conventional Commit profile and all integrated commits must be signed. See
[Git Flow](docs/standards/git-flow.md) for branch and integration rules.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE).
