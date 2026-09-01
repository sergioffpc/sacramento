# PROTOTYPE: Falcor vendor with Linux-hosted Packman

Question: Can a pinned, vendored Falcor 8.0 use its Linux Packman launcher to
materialize Windows dependencies while Sacramento cross-compiles from Ubuntu?

This is throwaway Gate 1B evidence. It is not a production dependency port and
must not merge into `develop`.

## Run

From the repository root:

```sh
prototypes/composed_foundation_gate1b/run-gate1b.sh
```

The runner verifies Sacramento's sealed toolchain, clones the exact Falcor 8.0
commit with its exact submodules, applies the versioned patch, runs the Linux
Packman launcher with `windows-x86_64`, and attempts Falcor's Windows configure
with Sacramento's Ubuntu-hosted `clang-cl` toolchain. It also downloads the
official Windows x64 Nsight Aftermath SDK, verifies its exact SHA-256, and
stages it at the location where Falcor enables `FALCOR_HAS_AFTERMATH`.

The default scratch directory is
`/tmp/sacramento-composed-foundation-gate1b`. Override it with
`SACRAMENTO_GATE1B_ROOT`. A Packman cache can be reused with
`SACRAMENTO_GATE1B_PACKMAN_CACHE`.

## Boundary under test

Packman is confined to the generated `vendor/falcor` tree. A future production
shape would publish an immutable Falcor SDK and expose that SDK to Sacramento
through vcpkg; no Sacramento product target would execute or configure Packman.

This experiment conflicts with ADR-0003's literal current rule that a
dependency's package manager must not become a second Sacramento dependency
manager. Passing Gate 1B proves only that a narrowly scoped vendor-build
exception is technically possible. The project owner must approve that policy
change before admission.

## Success criterion

The experiment passes when all of these are true:

1. the vendored source and submodule commits match `vendor.json`;
2. the patch selects the Packman launcher from `CMAKE_HOST_WIN32` while keeping
   the package platform selected from the target;
3. the Linux launcher pulls and links the `windows-x86_64` dependency set;
4. Falcor configure advances beyond the former `packman.cmd: Permission
   denied` boundary.

Completing the Falcor build is deliberately a later gate. The result identifies
the next host/target incompatibility instead of hiding it.

## Selected optional features

The Sacramento candidate enables Vulkan and Aftermath and disables CUDA,
OptiX, and NVAPI. Python is also excluded from the desired SDK. Falcor 8 does
not currently make Python optional: its core library links `pybind11::embed`
and 87 core source files reference pybind11. Removing Python therefore needs a
separate, broad source-decoupling decision rather than a misleading CMake-only
toggle.
