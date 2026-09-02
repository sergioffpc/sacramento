# Gate 2A dependency qualification: Flecs and NVIDIA PhysX

Status: Prototype qualification, 2026-09-02

Purpose: Select exact candidates for the Debian Session Authority proof and
record the limits that the Gate 2A evidence must test. This note does not admit
either dependency for production; admission remains subject to the complete
checks required by [ADR-0003](../../../docs/adr/0003-adopt-nvidia-oriented-foundation.md).

## Decision

Use the repository's existing vcpkg registry commit
`9e593bb18ea69cc5095e012465dcd675a822ed0d` with these exact candidates:

| Dependency | Registry version | Upstream identity | Gate 2A disposition |
| --- | --- | --- | --- |
| Flecs | `4.1.6#0`; port tree `6e13da0e6d446c34fef059953b4a947f04af748d` | tag `v4.1.6`, commit `fb55f3c25660425cfe1bc4cf5e6bff8b3f18a9b8` | Viable as a static Debian/Clang dependency. |
| NVIDIA PhysX | registry source `5.5.0#1`; Sacramento overlay `5.9.0` | tag `110.1-omni-and-physx-5.9.0`, commit `517a0073715120e114ee055b63b26c95e00d9039` | Viable for a CPU rigid-body prototype through the Gate-local overlay, with the toolchain exceptions below. |

The exact baseline entries are in the [pinned vcpkg registry](https://github.com/microsoft/vcpkg/blob/9e593bb18ea69cc5095e012465dcd675a822ed0d/versions/baseline.json).
The tag identities are independently visible in the [Flecs release](https://github.com/SanderMertens/flecs/releases/tag/v4.1.6),
[Flecs commit](https://github.com/SanderMertens/flecs/commit/fb55f3c25660425cfe1bc4cf5e6bff8b3f18a9b8),
[PhysX 5.9 release](https://github.com/NVIDIA-Omniverse/PhysX/releases/tag/110.1-omni-and-physx-5.9.0)
and [immutable commit](https://github.com/NVIDIA-Omniverse/PhysX/commit/517a0073715120e114ee055b63b26c95e00d9039),
and the registry port definitions for [Flecs](https://github.com/microsoft/vcpkg/tree/9e593bb18ea69cc5095e012465dcd675a822ed0d/ports/flecs)
and [PhysX](https://github.com/microsoft/vcpkg/tree/9e593bb18ea69cc5095e012465dcd675a822ed0d/ports/physx).

Declare both direct dependencies in the Gate 2A manifest and use exact
overrides for `flecs 4.1.6#0` and the overlay `physx 5.9.0`. A vcpkg baseline
normally provides a version floor, whereas an override forces the selected version;
Microsoft documents those semantics in the [vcpkg versioning reference](https://learn.microsoft.com/en-us/vcpkg/users/versioning#overrides).

## Flecs qualification

The pinned port downloads `v4.1.6` with archive SHA-512
`a2843d72a4a7f7577e047eac60d492c8a6677dae404d9ec6a23a498f5d37f745897a0892a3a5ef7b66de5c5f862e55cf9ae6b50dc33d0bd7a674707ca93f2b30`.
It maps the static Gate 2A triplet to `FLECS_STATIC=TRUE` and
`FLECS_SHARED=FALSE`, installs a CMake config, and exposes
`flecs::flecs`/`flecs::flecs_static`. Consume it with
`find_package(flecs CONFIG REQUIRED)` and link the static target. These facts
come from the exact [vcpkg portfile](https://github.com/microsoft/vcpkg/blob/9e593bb18ea69cc5095e012465dcd675a822ed0d/ports/flecs/portfile.cmake)
and [upstream CMake definition](https://github.com/SanderMertens/flecs/blob/fb55f3c25660425cfe1bc4cf5e6bff8b3f18a9b8/CMakeLists.txt).

Upstream documents Linux builds with Clang, a C/gnu99 library implementation,
C++17 or newer for C++ consumers, and Linux system links `rt`, `pthread`, and
`m`; this is compatible in principle with Sacramento's C++23 consumer and must
still be proved with the pinned Clang 22.1.2/Debian 13.6 sysroot. See
[Building Flecs](https://github.com/SanderMertens/flecs/blob/fb55f3c25660425cfe1bc4cf5e6bff8b3f18a9b8/docs/BuildingFlecs.md).

The target dependency graph has no other vcpkg libraries. Its only declared
transitives are host build helpers `vcpkg-cmake@2024-04-23#0` and
`vcpkg-cmake-config@2026-07-21#0`. The stock port does not select addons, so it
builds the upstream default addon set. Flecs documents `FLECS_CUSTOM_BUILD` and
the `FLECS_NO_*` switches for a narrower future build in
[Building Flecs](https://github.com/SanderMertens/flecs/blob/fb55f3c25660425cfe1bc4cf5e6bff8b3f18a9b8/docs/BuildingFlecs.md#custom-builds).
Gate 2A may retain the stock static port, but its evidence must record this
larger footprint.

Flecs' top-level license is [MIT](https://github.com/SanderMertens/flecs/blob/fb55f3c25660425cfe1bc4cf5e6bff8b3f18a9b8/LICENSE).
The vcpkg manifest deliberately records the SPDX field as `null`, and its
installed copyright additionally identifies bundled EmbeddableWebServer
(BSD-2-Clause), wyhash (Unlicense/public domain), and stm32tpl float-formatting
notices. Preserve and review the installed copyright rather than reporting the
package as MIT-only; the exact notice is in the [pinned portfile](https://github.com/microsoft/vcpkg/blob/9e593bb18ea69cc5095e012465dcd675a822ed0d/ports/flecs/portfile.cmake#L38-L45).

## PhysX qualification

The official `110.1-omni-and-physx-5.9.0` release resolves to commit
`517a0073715120e114ee055b63b26c95e00d9039`. Its GitHub source archive is
11,231,673 bytes with SHA-512
`e67ad62489d1e85fbe2f1ddabb26486331e3f8041950a47c765c96acd8e28eaeeda8430cab5098792e924973dec025b431194da67b420e14510b9c29de4d531d`
(calculated from the [official tag archive](https://github.com/NVIDIA-Omniverse/PhysX/archive/refs/tags/110.1-omni-and-physx-5.9.0.tar.gz)).
PhysX 5.9.0 is newer than the registry's `5.5.0#1`, so Gate 2A consumes it
through an exact Sacramento overlay instead of misrepresenting the registry
version.

PhysX 5.9 adds a top-level CMake build with install/export support and the
`PhysX::physx_lib` aggregate, while preserving the legacy
`physx/compiler/public` entry point used by the overlay. The top-level build
defaults `PX_GENERATE_GPU_PROJECTS` to `ON`; a CPU-only integration must set it
to `OFF` before `project()` so CUDA is not enabled. The legacy entry point
defaults GPU projects, snippets, and OmniPVD runtime to `OFF`. See the exact
[top-level CMake definition](https://github.com/NVIDIA-Omniverse/PhysX/blob/517a0073715120e114ee055b63b26c95e00d9039/physx/CMakeLists.txt#L29-L104)
and [legacy CMake entry point](https://github.com/NVIDIA-Omniverse/PhysX/blob/517a0073715120e114ee055b63b26c95e00d9039/physx/compiler/public/CMakeLists.txt#L28-L105).

The Gate overlay builds only static release Linux x64 and explicitly sets
`PX_BUILDSNIPPETS=OFF`, `PX_BUILDPVDRUNTIME=OFF`,
`PX_GENERATE_GPU_PROJECTS=OFF`, `PX_GENERATE_GPU_PROJECTS_ONLY=OFF`, and
`PX_GENERATE_STATIC_LIBRARIES=TRUE`. It exposes the existing
`unofficial::omniverse-physx-sdk::sdk` consumer seam and links only core,
Extensions, PvdSDK, Common, and Foundation. Its only vcpkg transitives are the
host helpers `vcpkg-cmake@2024-04-23#0` and
`vcpkg-cmake-config@2026-07-21#0`; a static Linux consumer additionally uses
the system `pthread` and `dl` libraries.

The upstream 5.9 Linux profile requires CMake 3.21, Python 3.5, curl, and glibc
2.31 or newer. CUDA Toolkit 12.8 is explicitly unnecessary for CPU-only builds.
The supported x86-64 matrix lists Ubuntu 22.04/Clang 14 and Ubuntu
24.04/Clang 18, with C++14 tested. NVIDIA's exact
[5.9 Linux platform readme](https://github.com/NVIDIA-Omniverse/PhysX/blob/517a0073715120e114ee055b63b26c95e00d9039/physx/documentation/platformreadme/linux/README_LINUX.md)
does not claim Clang 22 or Debian 13 support. Gate 2A's clean build, warning
patch, native execution, and repeatability evidence therefore prove only the
captured Sacramento toolchain combination; they are not upstream support.

The old registry port's unconditional prebuilt PhysXGpu download is not part of
the 5.9 overlay. Although the upstream `generate_projects.sh` still invokes
Packman and the upstream readme still warns that this route can download binary
content, the overlay bypasses that script, calls CMake directly, and disables
GPU project generation. In the 5.9 CMake source, CUDA discovery and the
PhysXGpu subdirectory are guarded by `PX_GENERATE_GPU_PROJECTS`; when disabled,
the targets export `DISABLE_CUDA_PHYSX`. See the [GPU build guards](https://github.com/NVIDIA-Omniverse/PhysX/blob/517a0073715120e114ee055b63b26c95e00d9039/physx/CMakeLists.txt#L77-L103)
and [upstream Packman launcher](https://github.com/NVIDIA-Omniverse/PhysX/blob/517a0073715120e114ee055b63b26c95e00d9039/physx/generate_projects.sh).
No PhysXGpu archive, CUDA compilation, or GPU runtime belongs to the Gate 2A
dependency closure.

PhysX 5.9 source is [BSD-3-Clause](https://github.com/NVIDIA-Omniverse/PhysX/blob/517a0073715120e114ee055b63b26c95e00d9039/LICENSE.md).
The [SDK readme](https://github.com/NVIDIA-Omniverse/PhysX/blob/517a0073715120e114ee055b63b26c95e00d9039/physx/README.md#acknowledgements)
also identifies CMake, LLVM metadata tooling, VsWhere, Freeglut, Mesa/OpenGL,
RapidJSON, and GLEW notices for optional tooling and snippet paths. The
CPU-only direct-CMake closure must record their exclusion and install the root
BSD notice; enabling Packman, snippets, metadata generation, OmniPVD, or GPU
projects would require a new transitive-license review.

## Fixed-tick replay and determinism boundary

PhysX does not promise general or cross-platform determinism. The exact 5.9
header promises limited determinism only for an exact scene whose actors are
created in the same order and simulated with the same time-stepping scheme.
`PxSceneFlag::eENABLE_ENHANCED_DETERMINISM` additionally isolates existing
actors from non-interacting actor additions, but still requires consistent
insertion order, a newly created scene, and consistent stepping; it costs
performance and is explicitly unsupported on GPU. See the exact
[5.9 scene-flag contract](https://github.com/NVIDIA-Omniverse/PhysX/blob/517a0073715120e114ee055b63b26c95e00d9039/physx/include/PxSceneDesc.h#L241-L262).
The 5.9 changelog also records fixes for enhanced determinism with differing
solver iteration counts and the CPU TGS solver, so upgrading releases can
change outcomes and requires a new baseline. See the
[5.9 changelog](https://github.com/NVIDIA-Omniverse/PhysX/blob/517a0073715120e114ee055b63b26c95e00d9039/physx/CHANGELOG.md#L342-L343).

Consequently, Gate 2A must fix and record the PhysX build/configuration, CPU
architecture, scene flags, solver, timestep, actor creation/insertion order,
callback inputs, and initial state; create a fresh scene for each replay; avoid
GPU and non-rigid simulation; and enable enhanced determinism. Any Flecs-driven
commands entering PhysX must be sorted by a stable Sacramento-owned entity ID,
not by incidental ECS storage/query order.

The replay digest must serialize only Sacramento-owned state at the completed
tick boundary, ordered by stable Sacramento IDs and with an explicit byte order
and float representation. It must not serialize `Px*` or Flecs storage. An exact
digest match is a same-platform/same-build repeatability proof only; it is not
evidence of Windows/Debian or arbitrary-machine lockstep.

## Update procedure

1. In an isolated dependency PR, select released upstream tags and resolve each
   tag to its immutable commit. Review release notes, licenses, bundled notices,
   vulnerability disposition, features, source archives, and all separately
   downloaded binary packages.
2. Prefer a version already curated in an official vcpkg registry. Inspect the
   new port tree and hashes. Run `vcpkg x-update-baseline --dry-run`, then update
   `vcpkg-configuration.json` and `config/cpp/bootstrap-lock.json` together;
   Microsoft documents the command in [x-update-baseline](https://learn.microsoft.com/en-us/vcpkg/commands/update-baseline).
   Keep exact direct-dependency overrides in the gate manifest.
3. If a required narrow build is not represented by the registry port, maintain
   a Sacramento overlay port with immutable `REF`, `SHA512`, explicit switches,
   patches, installed notices, and a port-version bump. The official
   [`vcpkg_from_github`](https://learn.microsoft.com/en-us/vcpkg/maintainers/functions/vcpkg_from_github)
   contract requires both a stable ref and archive hash.
4. Re-run clean uncached static builds with the pinned Clang/Debian triplet,
   sanitizer and warning checks, native Debian execution, dependency/link/load
   audits, license/SBOM generation, two-build reproducibility, and repeated
   replay digests. A PhysX update also re-baselines representative physical
   outcomes because determinism is scoped to one PhysX release and build.

## Gate 2A acceptance implications

- Flecs is ready to test through the pinned stock port; its all-addon footprint
  and bundled notices remain recorded qualification debt.
- PhysX 5.9.0 is qualified for this Gate only as CPU rigid-body simulation
  through the exact overlay. Passing Gate 2A does not make Clang 22 or Debian 13
  upstream-supported and does not qualify optional GPU, Packman, or CUDA paths.
- The final binary/load audit must show no Falcor, Slang, Steam Audio, PhysXGpu,
  CUDA, or other client-only/optional runtime dependency.
- A repeated Sacramento-owned digest proves reproducibility only within the
  captured Debian platform, binary, configuration, and input identity.
