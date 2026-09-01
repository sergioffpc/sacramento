# PROTOTYPE: Linux-built Falcor Vulkan vendor

Question: Can a pinned, vendored Falcor 8.0 use its Linux Packman launcher to
materialize Windows dependencies and produce a Windows Falcor SDK while
Sacramento cross-compiles from Ubuntu?

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
stages it at the location where Falcor enables `FALCOR_HAS_AFTERMATH`, configures
Vulkan-only Falcor, and builds `Falcor.dll`.

The default scratch directory is
`/tmp/sacramento-composed-foundation-gate1b`. Override it with
`SACRAMENTO_GATE1B_ROOT`. Packman cache, downloaded SDK inputs, and Falcor all
remain below that scratch directory's `vendor/` subtree.

## Boundary under test

Packman is confined to the generated `vendor/falcor` tree. A future production
shape would publish an immutable Falcor SDK and expose that SDK to Sacramento
through vcpkg; no Sacramento product target would execute or configure Packman.

Packman is an implementation detail of the vendor-build capsule: Sacramento
product targets never invoke it and consume only the resulting immutable SDK.
Admission still requires the ADR-0003 exception and a hash-complete mirror.

## Success criterion

The experiment passes when all of these are true:

1. the vendored source and submodule commits match `vendor.json`;
2. the patch selects the Packman launcher from `CMAKE_HOST_WIN32` while keeping
   the package platform selected from the target;
3. the Linux launcher pulls and links the `windows-x86_64` dependency set;
4. configure reports Vulkan and Aftermath on, with D3D12, NVAPI, CUDA, and
   OptiX off;
5. the Linux-hosted build produces a Windows x64 `Falcor.dll`.

## Selected optional features

The Sacramento candidate enables Vulkan, Slang, Aftermath, and Falcor's internal
Python dependency; it disables D3D12, CUDA, OptiX, and NVAPI. Cross-compilation
uses host Python for build tools and vendored Windows Python for target headers
and libraries. Python is not part of Sacramento's public API.
