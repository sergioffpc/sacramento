# Gate 1B result: Linux Packman for vendored Falcor

Date: 2026-09-01

## Verdict

**PASS.** A Linux-hosted Packman launcher pulled Falcor 8.0's
`windows-x86_64` dependencies and Sacramento's sealed Ubuntu toolchain produced
a Windows x64 `Falcor.dll` (10,142,208 bytes, SHA-256
`bb24ee40043525f5f27698c8ffc9b1092b7493616bb699848c0e1476476b2ccd`). The
verified configuration was Vulkan-only with Slang and Aftermath enabled.

## Fixed inputs

| Input | Identity |
|---|---|
| Falcor | tag `8.0`, commit `9dc819c162b2070335c65060436041690b7937f8` |
| Vendor manifest | `vendor.json`, including six exact submodule commits |
| Packman launcher | Linux shell launcher, Packman `7.23.2` |
| Packman package target | `windows-x86_64` |
| Nsight Aftermath | `2026.3.0.26197`, official Windows x64 archive |
| Aftermath SHA-256 | `e38136a60110199559b7365d3ea4ec0cb5588dc2b0f593877d864e0299659a3f` |
| Patches | Three versioned patches under `patches/`; the runner records each SHA-256. |
| Falcor dependency manifest SHA-256 | `cb8600eb1287ad912628d29f69ef889acaf7f65e87ade72cfccf5ad04007364f` |
| Compiler | Ubuntu-hosted Clang/clang-cl `22.1.2`, MSVC-like command line |

## Observed results

| Check | Result | Evidence |
|---|---|---|
| Sealed Sacramento toolchain | Pass | `cpp-toolchain-bootstrap.sh verify` returned `PASS`. |
| Exact Falcor and submodules | Pass | The runner checked the main commit and every submodule against `vendor.json`. |
| Patch applies to pristine Falcor 8.0 | Pass | `git apply --check` and `git diff --check` passed. |
| Linux Packman launcher | Pass | The selected launcher was a Bourne-Again shell script, not `packman.cmd`. |
| Windows dependency selection | Pass | Packman linked `falcor_dependencies/f80dd590-windows-x86_64` and Windows Python `3.10.11+nv1-windows-x86_64`. |
| Former permission boundary | Pass | Falcor printed `Updating packman dependencies` without invoking `packman.cmd` or reporting `Permission denied`. |
| Windows cross compiler | Pass | C and C++ compiler identification completed with clang-cl `22.1.2`. |
| Aftermath vendor input | Pass | The official archive hash, Windows x64 import library, DLL, and headers were verified and staged at `external/packman/aftermath`. |
| Host/target Python split | Pass | Host Python ran build tools; Packman's Windows Python supplied target headers and import library. |
| Vulkan-only policy | Pass | `FALCOR_HAS_VULKAN=ON`; D3D12, PIX, Agility SDK, and NVAPI were off. |
| Aftermath | Pass | `FALCOR_HAS_AFTERMATH=ON` compiled into the target. |
| Falcor build | Pass | The Linux host linked a PE32+ x86-64 `Falcor.dll` of 10,142,208 bytes. |

## Patch behavior

The patch separates two decisions that upstream Falcor couples:

```text
launcher       := build host  → Linux Packman
package target := CMake target → windows-x86_64
```

This is sufficient for Packman to materialize the Windows dependency bundle.
No Windows runner or Wine was required.

## Cost and admission concerns

- The populated Packman cache occupied approximately `4.4 GiB`; the extracted
  `falcor_dependencies` package alone reported approximately `2.626 GiB`.
- Falcor's Packman launcher bootstraps its Python and Packman module from an
  `http://bootstrap.packman.nvidia.com` URL. The prototype did not establish
  cryptographic identity or offline reconstruction for those bootstrap inputs.
- `dependencies.xml` fixes package versions but does not contain Sacramento-
  owned hashes for every fetched package. Immutable mirroring or a generated
  hash inventory remains necessary before qualification.
- Allowing Packman inside the vendor-build capsule contradicts the literal
  dependency-manager rule in proposed ADR-0003. It needs an explicit owner-
  approved exception. Sacramento product builds would still consume only the
  resulting immutable SDK through vcpkg.

## Python boundary

Python is accepted as an internal Falcor dependency. The patch separates the
host interpreter from the Windows target development package. Sacramento does
not expose Python through its rendering interface.

## Next boundary

Package the built headers, import libraries, DLLs, Slang runtime, and Aftermath
runtime as one immutable Falcor SDK, inventory every Packman input by hash, then
exercise a minimal Vulkan device and shader smoke test on Windows/NVIDIA.
