# Gate 1 Result

Status: Fail

Execution date: 2026-09-01

Command:

```sh
SACRAMENTO_CPP_TOOLCHAIN_ROOT=/var/tmp/sacramento-cpp-toolchain \
SACRAMENTO_GATE1_ROOT=/tmp/sacramento-composed-foundation-gate1-run \
  prototypes/composed_foundation_gate1/run-gate1.sh
```

## Verdict

The Vulkan, Slang, SPIR-V, C++23, Clang, MSVC-ABI, and Windows cross-build
sub-proofs pass. Falcor 8.0 fails the selected foundation gate because its
upstream configure requires Packman and forces DirectX 12 on Windows. Falcor
8.0 therefore cannot be admitted under the current vcpkg-only and Vulkan-only
policies without a maintained Sacramento packaging/build-system fork.

## Inputs

| Input | Exact identity |
| --- | --- |
| Sacramento toolchain | `bootstrap verify: PASS`; Clang/LLVM 22.1.2; Windows VS 18 CRT `14.50.18.0`; Windows SDK `10.0.28000` |
| vcpkg registry | `9e593bb18ea69cc5095e012465dcd675a822ed0d` |
| Falcor | Release `8.0`; commit `9dc819c162b2070335c65060436041690b7937f8`; source SHA-256 `681acb541ca02c819e42919ab26214263c9a9254f7876871d420120e1a4b7899` |
| Slang host compiler | `2024.1.34`; Linux x86-64 glibc 2.17 archive SHA-256 `97dfe279bf384b5c4e162c69cf8d6655d528988d31258b674841b7af0525d25c` |
| Vulkan headers | `1.4.350.1` from the pinned vcpkg registry |

Slang `2024.1.34` is not an arbitrary upgrade: it is the exact version named
by Falcor 8.0's `dependencies.xml`.

## Results

| Check | Disposition | Evidence |
| --- | --- | --- |
| Sealed toolchain identity | Pass | Bootstrap signature, package, sysroot, tool and registry verification completed before the run. |
| Slang through a vcpkg overlay port | Pass | `sacramento-slang-host:x64-linux@2024.1.34` installed with package ABI `59c0c6177214d7773369c847bdc97e1b50aa0e834c82c385ad00b5f3ce828323`. |
| Deterministic Slang to SPIR-V compile | Pass | Two independent compilations produced identical 172-byte artefacts with SHA-256 `a714b3659acb59ae4c30594a02ae0f0989bfd1aeb7a933ce983ddb6af9936969` and SPIR-V magic `0x07230203`. |
| Vulkan headers through vcpkg | Pass | `vulkan-headers:x64-windows-cross-clang@1.4.350.1` configured, built, installed and consumed as `Vulkan::Headers`. |
| Windows C++23 cross-build | Pass | Linux-hosted `clang-cl` 22.1.2 compiled and `lld-link` linked `sacramento_gate1_vulkan_probe.exe`; binary size 9,728 bytes and SHA-256 `8e6c64d5adf6d4d60d57745d975a05469b87fa71ae34b80896d7762b856fc686`. No DirectX header or library is part of this probe. Native Windows execution is outside this packaging gate and remains unproved. |
| Falcor configure through the approved cross-toolchain | Fail | Compiler and ABI checks pass, then upstream CMake executes Windows `tools/packman/packman.cmd` on the Ubuntu host and terminates with `permission denied`. This is a configure-time network/dependency-manager action. |
| Vulkan-only Falcor configuration | Fail | Falcor 8.0 executes `set(FALCOR_HAS_D3D12 ${FALCOR_WINDOWS})` after cache processing, overriding `-DFALCOR_HAS_D3D12=OFF`. Its Windows build therefore includes the D3D12 path. |
| Approved CMake-only tool identity | Exception Required | On the first clean vcpkg install, the pinned registry required and downloaded CMake 4.4.0 because the approved rootfs contains CMake 4.2.3. The downloaded archive SHA-256 is `3864eb649b4466ae126a64bbde1657adad78efbbaa068bf38201de5cf1b5349f`. This mismatch exists independently of Falcor and must be reconciled before dependency admission. |

## Interpretation

The test does not show that Vulkan, Slang, or Sacramento's Windows cross-build
topology is infeasible; all three pass their isolated sub-proofs. It shows that
the selected Falcor release is not a narrow vcpkg-composed Vulkan-only library.
Its CMake interface embeds a second dependency manager, consumes a large
prebuilt dependency bundle, and makes D3D12 part of every Windows build.

Making Falcor 8.0 comply would require Sacramento to replace its dependency
acquisition and imported-target definitions, port its direct and transitive
dependencies individually, disable and maintain the D3D12 source selection,
and repeat that work on every upgrade. That is a material fork and maintenance
commitment, not a small adapter or ordinary overlay port.

## Decision required

Before the prototype proceeds to Gate 2, the project owner must choose one of
these directions in issue #13:

1. retain vcpkg-only and Vulkan-only, and replace Falcor;
2. authorize a maintained Sacramento Falcor fork and measure its two-generalist
   maintenance cost; or
3. relax the dependency-manager and/or Vulkan-only decisions through an
   explicit architecture and engineering-baseline change.

Generated build trees, downloads, packages, binaries, and verbose logs remain
outside the Git worktree under the execution root. The branch retains the
harness, source identities, digest evidence, exact dispositions, and decision
consequence needed to reproduce and review the result.
