# C++ Toolchain Proof Report

Status: Blocked

Baseline: `CPP-ENGINEERING-BASELINE-001`

Prototype branch: `prototype/cpp-toolchain-proof`

Evaluation date: 2026-09-01

## Question and verdict

Question: Can the approved baseline be executed consistently with Clang-only
native Windows and Debian toolchains?

Verdict: Not yet demonstrated. The executable harness and static configuration
exist, but the approved toolchain inputs have not been fully identified or
provisioned and no native Windows or Debian proof runner was available in this
session. First-party production C++ must not yet be admitted.

This is a prototype result, not a change to the approved baseline. The baseline
and compiler decision remain authoritative in:

- `docs/standards/cpp-engineering.md`;
- `docs/adr/0001-use-clang-only-for-cpp.md`.

## Readiness matrix

| Criterion | Implementation or evidence | Windows | Debian | Disposition |
| --- | --- | --- | --- | --- |
| 1. Machine-readable inventories | `config/*.json`; `scripts/proof.py verify` | Exact image, installed component catalogue, `VCToolsVersion`, and artifact hashes unresolved | Exact APT snapshot, OCI digest, dependency identities, and artifact hashes unresolved | Blocked |
| 2. Format, tidy, warnings, hardening, exceptions | `.clang-format`, `.clang-tidy`, `cmake/ProofOptions.cmake`, `config/exceptions.json` | Configured; pinned tools not executed | Configured; pinned tools not executed | Blocked |
| 3. CMake and canonical presets | `CMakeLists.txt`, `CMakePresets.json` | Static inventory passed; configure/build not executed | Static inventory passed; configure/build not executed | Blocked |
| 4. vcpkg manifest and triplets | `vcpkg*.json`, `triplets/`, `cmake/toolchains/` | Defined; dependency resolution not executed | Defined; dependency resolution not executed | Blocked |
| 5. Bootstrap verification | `scripts/proof.py`, `proof.ps1`, `proof.sh` | Native execution unavailable | Native execution unavailable; WSL is intentionally rejected | Blocked |
| 6. Required proof targets | Shared library, app, GoogleTest, benchmark, `fmt`, feature probe, and fuzzer definitions | Source exists; clang-cl build/run unavailable | Source exists; Clang build/run unavailable | Blocked |
| 7. Same local and CI disposition | Local wrappers and `.github/workflows/cpp-toolchain-proof.yml` call the same Python commands | Configured; CI not executed | Configured; CI not executed | Blocked |
| 8. Outstanding exceptions | `config/exceptions.json` | No exceptions recorded | No exceptions recorded | Pass |

## Executed evidence

The following ran successfully in the available WSL2 session:

```text
./scripts/proof.sh static
```

It established that the checked-in JSON is parseable, every canonical platform
preset is represented, the CMake definition rejects non-Clang compilers, and the
clang-tidy configuration has no broad positive check wildcard.

The following ran and returned a blocking disposition as designed:

```text
./scripts/proof.sh verify
```

It identified the host as unsupported WSL2, reported every unresolved inventory
field, and reported the absence of the pinned build tools and `VCPKG_ROOT`.
Generated detail is written below `evidence/` and intentionally remains outside
the primary-source commit.

Static validation also included Python bytecode compilation, Bash syntax, JSON
parsing, and `git diff --check`.

## Operational inputs required next

These are missing operational inputs, not permission to substitute different
versions:

1. complete every `null` value in `config/toolchains.json` and
   `config/dependencies.json` from retained, hash-verified sources;
2. provision the exact native Windows and Debian runner identities;
3. set each runner's `VCPKG_ROOT` to the approved registry commit and ensure the
   exact pinned tool suite is installed;
4. run `verify`, `pr`, `nightly`, `weekly`, and `release` as applicable on the
   native runners;
5. retain both platform evidence and compare local and CI dispositions;
6. add the controlled infrastructure still required for performance,
   acceptance, immutable archives, SBOM/provenance, and signing evidence before
   those gates can pass.

## Baseline observations

No contradiction requiring an immediate baseline correction was demonstrated.
The proof did expose operational choices that the baseline intentionally leaves
to readiness work: exact installer/archive hashes, native image identities,
dependency source identities, controlled runner identities, and locations for
retained sources, CodeQL, signing, and release evidence. Those values must be
closed before the proof can move from `Blocked` to `Pass`.
