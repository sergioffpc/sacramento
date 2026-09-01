# Windows and Debian cross-target toolchain evidence

Date: 2026-09-01

Baseline under test: `CPP-ENGINEERING-BASELINE-001`

Decision disposition: the proven build-host topology was admitted by
`CPP-ENGINEERING-BASELINE-002` and ADR-0002. Baseline 002 also admits the exact
dependency and Windows sysroot identities proved here.

Verdict: **Windows and Debian cross-compilation plus hermetic bootstrap proven;
formal release gates remain.**

## Results

| Question | Result | Evidence |
| --- | --- | --- |
| Does C++23 `std::expected` work with the MSVC STL sysroot? | Pass | Ubuntu `clang-cl` 22.1.2 compiled `/std:c++23preview`; the PE printed `expected=42` on Windows and returned 0. |
| Can vcpkg build `fmt` and GoogleTest for Windows from a Linux host? | Pass | `fmt` 12.2.0#1 and `gtest` 1.17.0#3 were built as static Windows libraries by the pinned vcpkg registry; two GoogleTests passed on Windows. Baseline 002 admits the resolved versions. |
| Can Linux-hosted LLVM link a PE and execute it through WSL2 interop? | Pass | Linux `lld-link` produced PE32+ x86-64 executables. After app-local CRT deployment, the application and tests executed from `C:\Temp` with exit 0. |
| Do PDB, CFG, ASan, reproducibility, and local caching work? | Pass | Full PDB generated; `llvm-readobj` reported CFG instrumentation/table plus ASLR/NX/high-entropy VA; clean ASan run passed; deliberate heap overflow produced a failing diagnostic; the clean replay produced identical EXE/PDB hashes; sccache 0.16.0 produced three cache hits. |
| Can the same Ubuntu build root produce and test the Debian 13.6 target? | Pass | Clang/LLD produced PIE ELF binaries against the signed, hash-locked Debian sysroot; application and two GoogleTests passed inside the target userspace; ASan and UBSan negative probes failed with the expected diagnostics. |
| Are Debian output and debug symbols reproducible and hardened? | Pass | A clean cache-backed replay reproduced the ELF and detached debug hashes; inspection proved PIE, GNU_RELRO, BIND_NOW, non-executable stack, build ID, and the admitted libstdc++ dependency. |

## Retained result identities

- CMake/vcpkg application SHA-256:
  `e7392752cdd64c09587d1ce62a62571b372f8e90c2e7e48b35dfa29b72473cd9`.
- CMake/vcpkg application PDB SHA-256:
  `9cf94477027ed049120bdebc6414baefb1cc71b60d26ac2a6b1d930483f5bfbf`.
- CMake/vcpkg GoogleTest executable SHA-256:
  `0d5d41749a389c86061617e677940f7b4428bfbfe39b08bf7d1976a4ce4039ac`.
- Deterministically sealed Ubuntu rootfs SHA-256:
  `8859d6259f7f8a419eac79cbe66d3b70e13005dd66a0edfac7f052b30ae627fe`.
- Deterministically sealed Debian 13.6 sysroot SHA-256:
  `7d79897091617e12dc653d019b29d638cb41d983d9e60838576e77e2a10448af`.
- Debian application SHA-256:
  `478ae44d4af1501ab5cbe0abce7e1c1903c319ad2e6cde579af6c1da995b7e74`.
- Debian detached application debug SHA-256:
  `9e0500a44538abfee74527468351a3eff19db0c15a806c6fbaa48bea5668e2a3`.
- ASan negative probe: `heap-buffer-overflow`, with a non-zero Windows exit.

## What the experiment established

The Windows compiler does not need to run on Windows. Ubuntu Linux `clang-cl` can use
the MSVC STL/CRT and Windows SDK as explicit sysroots, while Linux `lld-link`
produces valid PE/PDB output. WSL interop is needed only to execute the result.
This is more hermetic than discovering an ambient Visual Studio installation
and remains Clang-only.

Dynamic CRT linkage (`/MD`) requires app-local or installed redistributable
runtime DLLs. This machine did not have them. Deploying the matching 14.50
`msvcp140.dll`, `vcruntime140.dll`, and `vcruntime140_1.dll` beside the PE made
execution succeed without installing a global Windows toolchain.

Windows ASan additionally requires Microsoft's target runtime and
`stl_asan.lib` from the matching MSVC 14.50 ASan package; Ubuntu's standard
compiler-rt package contains Linux sanitizers and Windows builtins, but not the
Windows ASan dynamic runtime.

## Baseline corrections resolved from the proof

1. ADR-0002 and baseline 002 admit Linux-hosted `clang-cl`, `llvm-lib`, and
   `lld-link` for the Windows target.
2. Baseline 002 admits GoogleTest 1.17.0#3, the version resolved by the pinned
   vcpkg commit and the current official GoogleTest release.
3. Baseline 002 admits Windows SDK family 10.0.26100 through the exact xwin VS17
   package version 10.0.26100.15.
4. Baseline 002 explicitly admits the retained VS18 CRT plus VS17 SDK manifest
   composition and requires both identities and hashes.

## Remaining readiness blockers

1. This focused experiment does not prove release signing, native Windows and
   Debian performance, or formal acceptance.

## Decision disposition

`CPP-ENGINEERING-BASELINE-002` and ADR-0002 adopt the validated build topology
and:

- allows Ubuntu-LTS-hosted Windows cross-compilation with `lld-link`;
- retains native Windows runtime/performance/acceptance gates;
- admits the resolved GoogleTest and Windows SDK versions;
- require the Ubuntu image, APT snapshot, Visual Studio manifests, Microsoft
  packages, LLVM Linux tools, LLVM Windows runtimes, and app-local CRT files to
  be pinned; and
- require the Debian product target to use the separately pinned and sealed
  sysroot proved by the same checked-in build definitions.

The architectural correction and reproducible bootstrap are approved.
Production C++ remains inadmissible until the remaining readiness gates pass.

## CI gate boundary

`../../.github/workflows/windows-cross-compile-proof.yml` operationalizes the proven
boundary. An explicit Ubuntu 26.04 hosted job materializes the locked toolchain,
builds and inspects PE/PDB and ELF/debug output, executes Debian tests and
ASan+UBSan gates, and publishes hash manifests. A controlled Windows 11 runner
verifies every hash, runs the application and GoogleTests, runs the clean ASan
probe, and requires the negative probe to fail with `heap-buffer-overflow`.
The PowerShell runtime gate was also replayed successfully from NTFS during the
experiment; execution directly from the WSL UNC share is deliberately unsupported.

## Promoted root definitions

The approved `.clang-format`, `.clang-tidy`, CMake project and target policy,
canonical presets, vcpkg manifests, project triplets, cross-toolchains,
machine-readable locks, and bootstrap now live at the repository root. The
The permanent suite under `../../tests/toolchain` delegates to those root
definitions. CI validates every
preset, resolves both vcpkg target graphs in dry-run mode, and configures the
root project with Debian Clang and Windows clang-cl before exercising the binary
gates.
