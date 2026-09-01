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

### Environment setup

The supported developer environment is WSL2 with Ubuntu 26.04 LTS. A native
Ubuntu 26.04 host can build both targets, but Windows executables must still be
copied to and executed on Windows. Install the small set of host commands used
to materialize the isolated build root:

```sh
sudo apt-get update
sudo apt-get install --yes bubblewrap coreutils curl dpkg git gpgv python3 tar
```

From the repository root, select a new state directory. Keeping downloaded
toolchains outside the Git worktree avoids multi-gigabyte generated content in
the repository:

```sh
export SACRAMENTO_CPP_TOOLCHAIN_ROOT=/var/tmp/sacramento-cpp-baseline-002
```

The bootstrap requires at least 12 GiB free. Avoid `/tmp` on WSL installations
where it is backed by a size-limited `tmpfs`; `/var/tmp` uses the distribution's
persistent filesystem by default.

If HTTPS is intercepted by the local network, identify the host CA bundle used
only for download transport:

```sh
export SACRAMENTO_BOOTSTRAP_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
```

Materialize and verify the complete Ubuntu build root, Windows sysroot, Debian
sysroot, LLVM tools, vcpkg registry, and local compiler cache:

```sh
scripts/cpp-toolchain-bootstrap.sh install
scripts/cpp-toolchain-bootstrap.sh verify
```

The install command invokes xwin with explicit Microsoft license acceptance.
Run it only after accepting the applicable Microsoft licensing terms. Every
download, repository manifest, package and derived sysroot remains verified by
the checked-in signatures and cryptographic hashes.

`verify` is deliberately read-only. If it reports an incompatible state from an
older baseline, select a new empty directory through
`SACRAMENTO_CPP_TOOLCHAIN_ROOT` and run `install`; do not reuse or mutate the old
rootfs.

Optionally verify the deterministic Ubuntu and Debian archives:

```sh
scripts/cpp-toolchain-bootstrap.sh seal
```

### Build

The repository does not yet contain production engine targets. Build commands
will be added here when the first approved engine module is introduced. The
checked-in `CMakePresets.json`, toolchain files and dependency manifest already
define the future Debian and Windows build profiles.

### Run

There is currently no engine executable to run. Runtime instructions for the
Debian target and for Windows execution from WSL2 will be added with the first
production executable. Exploratory prototype binaries are intentionally not
retained in the repository.

## Contribution workflow

The repository uses Git Flow with `main` as the release branch and `develop`
as the integration branch. All commit messages follow the repository's
Conventional Commit profile and all integrated commits must be signed. See
[Git Flow](docs/standards/git-flow.md) for branch and integration rules.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE).
