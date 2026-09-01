# Windows cross-compilation proof report

Date: 2026-09-01

Baseline under test: `CPP-ENGINEERING-BASELINE-001`

Decision disposition: the proven build-host topology was admitted by
`CPP-ENGINEERING-BASELINE-002` and ADR-0002. Baseline 002 also admits the exact
dependency and Windows sysroot identities proved here.

Verdict: **Windows cross-compilation and hermetic bootstrap proven; Debian and
formal release gates remain.**

## Results

| Question | Result | Evidence |
| --- | --- | --- |
| Does C++23 `std::expected` work with the MSVC STL sysroot? | Pass | Ubuntu `clang-cl` 22.1.2 compiled `/std:c++23preview`; the PE printed `expected=42` on Windows and returned 0. |
| Can vcpkg build `fmt` and GoogleTest for Windows from a Linux host? | Pass | `fmt` 12.2.0#1 and `gtest` 1.17.0#3 were built as static Windows libraries by the pinned vcpkg registry; two GoogleTests passed on Windows. Baseline 002 admits the resolved versions. |
| Can Linux-hosted LLVM link a PE and execute it through WSL2 interop? | Pass | Linux `lld-link` produced PE32+ x86-64 executables. After app-local CRT deployment, the application and tests executed from `C:\Temp` with exit 0. |
| Do PDB, CFG, ASan, reproducibility, and local caching work? | Pass | Full PDB generated; `llvm-readobj` reported CFG instrumentation/table plus ASLR/NX/high-entropy VA; clean ASan run passed; deliberate heap overflow produced a failing diagnostic; the clean replay produced identical EXE/PDB hashes; sccache 0.16.0 produced three cache hits. |

## Retained result identities

- CMake/vcpkg application SHA-256:
  `e7392752cdd64c09587d1ce62a62571b372f8e90c2e7e48b35dfa29b72473cd9`.
- CMake/vcpkg application PDB SHA-256:
  `9cf94477027ed049120bdebc6414baefb1cc71b60d26ac2a6b1d930483f5bfbf`.
- CMake/vcpkg GoogleTest executable SHA-256:
  `0d5d41749a389c86061617e677940f7b4428bfbfe39b08bf7d1976a4ce4039ac`.
- Deterministically sealed Ubuntu rootfs SHA-256:
  `133bc81769f824392d4bc7b4ed79c232635b0afa1cafcf5b4fa4e7981336246e`.
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

1. This focused experiment does not re-prove the Debian target, release signing,
   native Windows performance, or formal acceptance.

## Decision disposition

`CPP-ENGINEERING-BASELINE-002` and ADR-0002 adopt the candidate build topology
in `BUILD_PROFILE_PROPOSAL.md` and:

- allows Ubuntu-LTS-hosted Windows cross-compilation with `lld-link`;
- retains native Windows runtime/performance/acceptance gates;
- admits the resolved GoogleTest and Windows SDK versions;
- require the Ubuntu image, APT snapshot, Visual Studio manifests, Microsoft
  packages, LLVM Linux tools, LLVM Windows runtimes, and app-local CRT files to
  be pinned; and
- require a separate proof of the Debian product target from the same checked-in
  build definitions.

The architectural correction and reproducible bootstrap are approved.
Production C++ remains inadmissible until the remaining readiness gates pass.

## CI gate boundary

`.github/workflows/windows-cross-compile-proof.yml` operationalizes the proven
boundary. An explicit Ubuntu 26.04 hosted job materializes the locked toolchain,
builds and inspects PE/PDB output, compiles both ASan probes, and publishes a
hash manifest with the native-runtime package. A controlled Windows 11 runner
verifies every hash, runs the application and GoogleTests, runs the clean ASan
probe, and requires the negative probe to fail with `heap-buffer-overflow`.
The PowerShell runtime gate was also replayed successfully from NTFS during the
prototype; execution directly from the WSL UNC share is deliberately unsupported.
