# Cross-compile Windows artefacts from Ubuntu with Clang

Status: Accepted

Purpose: Record why Windows C++ artefacts are cross-compiled from a pinned
Ubuntu build root.

Scope: Windows build-host, target-sysroot, linker, and native-test allocation.

Intended readers: Architects, implementers, build operators, and verification
authors.

Prerequisites: ADR-0001 and the approved C++ requirements and engineering
baseline.

Canonical information owner: Project owner.

Sacramento produces its Windows C++ artefacts in a pinned Ubuntu 26.04 LTS
build root using Linux-hosted `clang-cl`, `llvm-lib`, and `lld-link`. The MSVC
STL/CRT and Windows SDK are immutable target-sysroot inputs; they do not make
MSVC `cl.exe` or a Windows-hosted linker part of the build. Windows remains the
mandatory native environment for runtime tests, performance, release signing,
and formal acceptance. This supersedes only ADR-0001's requirement for
`link.exe` and Windows-hosted build processes; its Clang-only decision remains
in force.

## Considered options

- Native Windows `clang-cl` plus `link.exe` was rejected because it requires an
  ambient Windows toolchain and duplicates build-host provisioning.
- GCC/MinGW was rejected because it violates the Clang-only decision and would
  change the target ABI and platform-library profile.
- Wine-based execution was rejected as acceptance evidence because the product
  target is Windows, not Wine.

## Consequences

The Ubuntu build root, LLVM tools, Windows sysroot, ASan runtime, dependency
inputs, and local caches require machine-readable identities and hashes. CI may
build on Ubuntu, but every Windows candidate must execute on native Windows;
performance and formal acceptance remain native-platform gates. Debian remains
a distinct product target and must be proved separately from the same build
definitions.
