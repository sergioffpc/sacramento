# Windows cross-compilation proof report

Date: 2026-09-01

Baseline under test: `CPP-ENGINEERING-BASELINE-001`

Verdict: **Cross-compilation proven; baseline correction required before
operational approval.**

## Results

| Question | Result | Evidence |
| --- | --- | --- |
| Does C++23 `std::expected` work with the MSVC STL sysroot? | Pass | Ubuntu `clang-cl` 22.1.2 compiled `/std:c++23preview`; the PE printed `expected=42` on Windows and returned 0. |
| Can vcpkg build `fmt` and GoogleTest for Windows from a Linux host? | Pass with version blocker | `fmt` 12.2.0 and `gtest` 1.17.0 were built as static Windows libraries by the pinned vcpkg registry; two GoogleTests passed on Windows. The registry does not contain the baseline's GoogleTest 1.18.0. |
| Can Linux-hosted LLVM link a PE and execute it through WSL2 interop? | Pass | Linux `lld-link` produced PE32+ x86-64 executables. After app-local CRT deployment, the application and tests executed from `C:\Temp` with exit 0. |
| Do PDB, CFG, ASan, reproducibility, and local caching work? | Pass | Full PDB generated; `llvm-readobj` reported CFG instrumentation/table plus ASLR/NX/high-entropy VA; clean ASan run passed; deliberate heap overflow produced a failing diagnostic; the clean replay produced identical EXE/PDB hashes; sccache 0.16.0 produced three cache hits. |

## Retained result identities

- CMake/vcpkg application SHA-256:
  `99efadd2991c980dc3488b212b9b87a6e1e8e4b53035d81861a6362af0b873c0`.
- CMake/vcpkg application PDB SHA-256:
  `a9d97c006ad455655a92eadf1abdd9ece7992c7813c639ff501c7a72d2fca09c`.
- CMake/vcpkg GoogleTest executable SHA-256:
  `9acaf6886f20c21b18d1f68f4ba19366d5c80f4051fb92f81f04570d174b69f1`.
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

## Baseline blockers exposed by the proof

1. The approved baseline mandates Windows-hosted `clang-cl`, `link.exe`, and
   Windows processes. The proven path uses Linux-hosted `clang-cl`, `llvm-lib`,
   and `lld-link`; adopting it requires a new ADR/baseline revision.
2. The pinned vcpkg commit
   `9e593bb18ea69cc5095e012465dcd675a822ed0d` resolves GoogleTest 1.17.0#3,
   not the approved 1.18.0.
3. xwin's Visual Studio v17 manifest identifies the selected SDK as
   10.0.26100.15, not the approved 10.0.26100.9169 identity.
4. CRT 14.50 and SDK 10.0.26100 cannot be selected together from one current
   xwin manifest. The proof composes the CRT directory from manifest v18 and the
   SDK directory from manifest v17. This works but both manifests must become
   retained immutable inputs.
5. The Ubuntu rootfs started from a hash-pinned Canonical OCI archive, but its
   APT packages came from live Resolute repositories. An immutable APT snapshot or
   a final derived OCI digest is still required.
6. This focused experiment does not re-prove the Debian target, release signing,
   native Windows performance, or formal acceptance.

## Recommended decision

Adopt the candidate build topology in `BUILD_PROFILE_PROPOSAL.md`, then create a
formally reviewed successor to `CPP-ENGINEERING-BASELINE-001` that:

- allows Ubuntu-LTS-hosted Windows cross-compilation with `lld-link`;
- retains native Windows runtime/performance/acceptance gates;
- resolves the GoogleTest and Windows SDK version contradictions;
- pins the Ubuntu image, APT snapshot, Visual Studio manifests, Microsoft
  packages, LLVM Linux tools, LLVM Windows runtimes, and app-local CRT files;
- separately proves the Debian product target from the same checked-in build
  definitions.

Until those changes are approved, this prototype is positive technical evidence
but does not admit production C++ under the current readiness clause.
