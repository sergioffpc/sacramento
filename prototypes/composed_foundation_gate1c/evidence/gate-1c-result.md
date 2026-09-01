# Gate 1C result: immutable Falcor SDK and native smoke handoff

Date: 2026-09-02

Build and packaging status: **PASS**.

Native Windows/NVIDIA execution status: **PASS**.

## Verdict

The pinned Gate 1B Falcor build can be reduced to a deterministic SDK capsule
and a deterministic Windows smoke bundle without requiring Packman in a
Sacramento consumer build. The Linux host packaged the SDK and cross-built the
Vulkan/Slang/Aftermath smoke twice from clean output roots. Both runs produced
identical SDK archives and executables.

The corrected bundle then ran natively on Windows with an NVIDIA GeForce RTX
5070 Ti. Falcor selected Vulkan, created the Slang compute program, reported
the NVIDIA adapter, and kept Aftermath enabled. Gate 1C therefore passes both
the reproducible Linux build/handoff proof and the native Windows acceptance.

## Immutable outputs

- Falcor commit: `9dc819c162b2070335c65060436041690b7937f8`
- SDK archive SHA-256:
  `3a8de2ff7f90408062c8b069636f47d0a506fb09694cbf97204fa310e09036b3`
- SDK archive size: 128,400,221 bytes
- SDK archive entries: 12,376
- Manifest payload entries: 12,375, plus `manifest.json`
- Smoke executable SHA-256:
  `b19d8e54d64bc620d33a3f5b3e52258c67b37ac932622f4f77a14e3f3cca3027`
- Smoke format: PE32+ console executable, Windows x86-64

The executable initially differed only in the PE `TimeDateStamp`. Linking with
`/Brepro` removed that nondeterminism. After adding the required deployment
shader tree, clean runs 10 and 11 passed bytewise `cmp` for both
`falcor-sdk.zip` and `falcor_vulkan_smoke.exe`.

## Feature contract

The SDK manifest records this exact feature selection:

- Vulkan: enabled
- Slang: enabled
- Aftermath: enabled
- D3D12: disabled
- NVAPI: disabled
- CUDA: disabled
- OptiX: disabled
- Python: retained as an internal Falcor dependency

The smoke source explicitly selects `Falcor::Device::Type::Vulkan`, enables
Aftermath, and creates a `ComputePass` from `gate1c.slang`.

## Provenance and Packman containment

`vendor-inputs.json` records:

- `dependencies.xml` SHA-256:
  `cb8600eb1287ad912628d29f69ef889acaf7f65e87ade72cfccf5ad04007364f`
- 13 linked Packman packages
- 51,991 Packman input files with path, size, and SHA-256
- 12 Aftermath input files with path, size, and SHA-256

The SDK contains the selected headers, `Falcor.lib`, `Falcor.dll`, runtime DLLs,
licences, shader data, and Falcor's internal Python runtime. Packman is used only
to materialize the vendored Falcor build inputs; neither the SDK consumer nor
the smoke CMake build invokes Packman.

Archive integrity passed `python3 -m zipfile --test`. The SDK and smoke bundle
both contain `Falcor.dll`, `GFSDK_Aftermath_Lib.x64.dll`, and the 257 Falcor
deployment shaders. The smoke bundle adds `shaders/gate1c.slang` and
`run-smoke.ps1`.

## Native attempt 1 and packaging correction

The first Windows/NVIDIA run reached Falcor Vulkan device construction and
reported the expected limitation that Aftermath on Vulkan produces basic crash
dumps. It then failed because
`shaders/Core/API/BlitReduction.3d.slang` was absent from the handoff bundle.

Falcor deployment mode searches for shaders under the `shaders` directory next
to the executable. The packager had copied shader sources only into the SDK
include tree. The corrected packager now copies the build's complete
`bin/shaders` deployment tree to the SDK; the smoke build copies that tree next
to the executable and places the prototype shader at
`shaders/gate1c.slang`. The runner has explicit assertions for both the failing
Falcor shader path and the prototype shader path, so this packaging regression
now fails on Linux before native handoff.

The two `Attempt to access invalid address.` messages observed before the
missing-shader exception did not recur in the captured corrected run.

## Native attempt 2 and acceptance

The run11 smoke bundle was copied from WSL storage to a fresh local Windows
temporary directory. Both required shader paths existed and the executable
identity matched the expected SHA-256 before execution. Running:

```powershell
.\run-smoke.ps1
```

returned:

```json
{"status":"pass","api":"Vulkan","adapter":"NVIDIA GeForce RTX 5070 Ti","slang_program":"gate1c.slang","aftermath":true}
```

This satisfies every wrapper assertion: zero exit status, Vulkan API, explicit
NVIDIA adapter, successful Slang program creation, and Aftermath enabled. Gate
1C is complete.
