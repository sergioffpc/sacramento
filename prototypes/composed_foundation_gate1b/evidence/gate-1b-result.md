# Gate 1B result: Linux Packman for vendored Falcor

Date: 2026-09-01

## Verdict

**PASS for the question under test.** A Linux-hosted Packman launcher can pull
and link Falcor 8.0's `windows-x86_64` dependency set while Falcor is configured
as a Windows target from Sacramento's sealed Ubuntu build root.

This is not a pass for the complete Falcor build. Configure advanced beyond the
former `packman.cmd: Permission denied` boundary and then stopped at Falcor's
Python discovery, which does not separate build-host Python from Windows-target
Python.

## Fixed inputs

| Input | Identity |
|---|---|
| Falcor | tag `8.0`, commit `9dc819c162b2070335c65060436041690b7937f8` |
| Vendor manifest | `vendor.json`, including six exact submodule commits |
| Packman launcher | Linux shell launcher, Packman `7.23.2` |
| Packman package target | `windows-x86_64` |
| Nsight Aftermath | `2026.3.0.26197`, official Windows x64 archive |
| Aftermath SHA-256 | `e38136a60110199559b7365d3ea4ec0cb5588dc2b0f593877d864e0299659a3f` |
| Patch SHA-256 | `b535e154422780e643ac3500d25a48cbd0ac4c79de01df9d86c590bb3c7c3acf` |
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
| Complete Falcor configure | Blocked | `FindPython` could not provide the interpreter and development inputs required for the Windows target from the Linux host. |
| Vulkan-only policy | Not retested | Falcor still forces D3D12 on Windows; this experiment intentionally changed only Packman launcher selection. |

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

## Python exclusion result

The project owner confirmed that Sacramento does not need Python in Falcor.
Falcor 8 does not offer that feature boundary: the main `Falcor` library links
`pybind11::embed`, 87 files in `Source/Falcor` reference pybind11, and 73 core
files reference `ScriptBindings`. Disabling only the `FalcorPython` extension
does not remove the embedded interpreter from the core.

A no-Python Falcor 8 therefore requires a broad source fork or a materially
smaller extraction of Falcor, not a small packaging patch. The prototype does
not claim that maintenance burden has been accepted.

## Next boundary

The owner must decide whether to accept a broad no-Python Falcor fork or retain
Python as an internal Falcor implementation dependency that Sacramento does not
expose. Aftermath is selected and its input is staged, but compilation cannot
confirm `FALCOR_HAS_AFTERMATH=ON` until that Python boundary is resolved. The
independent Vulkan-only patch also remains required.
