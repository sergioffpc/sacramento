# Gate 2A result: Debian authoritative core boundary

Date: 2026-09-02

Status: **PASS** for the prototype gate with PhysX 5.9.0.

## Verdict

The pinned Debian authority prototype composes Flecs 4.1.6 with a CPU-only
NVIDIA PhysX 5.9.0 overlay, advances a representative sphere/plane interaction
for 240 fixed 60 Hz ticks, and publishes only Sacramento-owned canonical state.
Two clean builds produced byte-identical ELF files. Two fresh executions
produced byte-identical traces and result documents.

This proves repeatability for this exact binary, platform, configuration, call
order, and input. It does not claim cross-platform or general PhysX lockstep.

## Immutable inputs and outputs

- vcpkg registry: `9e593bb18ea69cc5095e012465dcd675a822ed0d`
- Flecs: `4.1.6`, upstream commit
  `fb55f3c25660425cfe1bc4cf5e6bff8b3f18a9b8`
- PhysX: `5.9.0` Sacramento overlay, upstream tag
  `110.1-omni-and-physx-5.9.0`, commit
  `517a0073715120e114ee055b63b26c95e00d9039`
- PhysX source archive SHA-512:
  `e67ad62489d1e85fbe2f1ddabb26486331e3f8041950a47c765c96acd8e28eaeeda8430cab5098792e924973dec025b431194da67b420e14510b9c29de4d531d`
- Compiler: Clang 22.1.2
- target runtime/sysroot: Debian 13.6 x86-64
- ELF SHA-256, both clean builds:
  `625fd7d34edfe5398ca636f034ae2b51502d37ff58b00d44ab96ecf079a0750e`
- ELF size: 5,889,576 bytes
- ELF Build ID: `f13d5d9fbdf3db7f204590667db75b1d5b2c0e89`
- canonical trace SHA-256:
  `64d34ee702944f5edda377654060e03f92b3a741d0a23be74d660c166e2eceae`
- result SHA-256:
  `06d1691f5bcbb234273093ed1e22d8768f2fde808ae41673773d03e641309aaa`

The canonical trace and result hashes are unchanged from the superseded PhysX
5.5.0 Gate baseline, while the rebuilt ELF identity correctly changed.

The trace contains exactly 240 newline-delimited snapshots and is 30,693
bytes. Its final snapshot is:

```json
{"tick":240,"body_id":1,"position_um":[1,500000,0],"velocity_um_s":[0,0,0],"ground_contact":true,"digest":"6d55184739dd6b19"}
```

## Authority and replay contract

The scene uses a zero-worker CPU dispatcher, TGS solver, enhanced determinism,
a fixed `1 / 60` second step, blocking `fetchResults(true)`, and a fixed actor
creation/insertion order. PhysX output is quantized to integer micrometres at
each completed tick and stored as Sacramento component types in Flecs.

The rolling FNV-1a digest serializes the scenario format, tick, stable
Sacramento body ID, canonical transform, canonical velocity, and contact flag
in explicit little-endian integer form. It never hashes Flecs storage, PhysX
objects, pointers, or native floating-point bytes.

## Dependency boundary

The public-header audit found zero Flecs, PhysX, Falcor, Vulkan, Slang, Steam
Audio, Assimp, or Tracy types. PhysX is confined behind the private
`SessionAuthorityPrototype::Impl` boundary.

The target vcpkg closure contains only Flecs, the Sacramento PhysX overlay, and
the two host-only vcpkg CMake helpers. The overlay downloaded only the PhysX
source archive; it did not download, build, or install PhysXGpu or CUDA
runtime code. Its consumer target links only PhysX core, Extensions, PvdSDK,
Common, and Foundation; Cooking, Character, Vehicle, and Vehicle2 are not on
the link line.

The authority ELF has exactly these `DT_NEEDED` entries:

- `libstdc++.so.6`
- `libm.so.6`
- `libgcc_s.so.1`
- `libc.so.6`

No Falcor, Vulkan, Slang, Steam Audio/phonon, Assimp, Tracy, CUDA, OptiX, or
PhysXGpu runtime is linked or loaded.

## Qualification exceptions

PhysX 5.9 does not claim support for Clang 22 or Debian 13. The overlay keeps
upstream `-Werror -Weverything` and suppresses only three Clang 22 diagnostics:
`-Wmissing-include-dirs`, `-Wnrvo`, and `-Wformat-signedness`. GPU project
generation is explicitly disabled and upstream defines `DISABLE_CUDA_PHYSX`;
all other vendor warnings remain fatal.

The pinned vcpkg executable required and downloaded CMake 4.4.0 although the
repository's consumer policy baseline is CMake 4.2.3. This is a build-tool
bootstrap exception to resolve before production admission; the Sacramento
consumer project continues to declare 4.2.3.

Clean consumer build times were 4,139 ms and 4,146 ms. The measured follow-up
build took 4,240 ms and rebuilt the two translation units, so it is recorded as
tooling evidence rather than a no-op incremental-build claim. Performance was
not an acceptance condition for Gate 2A.

Flecs' default addon footprint and bundled third-party notices remain
qualification debt. Neither dependency is admitted for production by this
throwaway prototype.
