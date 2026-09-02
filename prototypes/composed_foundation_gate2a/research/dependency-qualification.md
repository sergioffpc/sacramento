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
| NVIDIA PhysX | registry source `5.5.0#1`; Sacramento overlay `5.5.0#2` | tag `106.4-physx-5.5.0`, commit `dd587fedd79836442a4117164ea8c46685453c34` | Viable for a CPU rigid-body prototype through the Gate-local overlay, with the toolchain exceptions below. |

The exact baseline entries are in the [pinned vcpkg registry](https://github.com/microsoft/vcpkg/blob/9e593bb18ea69cc5095e012465dcd675a822ed0d/versions/baseline.json).
The tag identities are independently visible in the [Flecs release](https://github.com/SanderMertens/flecs/releases/tag/v4.1.6),
[Flecs commit](https://github.com/SanderMertens/flecs/commit/fb55f3c25660425cfe1bc4cf5e6bff8b3f18a9b8),
[PhysX tag reference](https://github.com/NVIDIA-Omniverse/PhysX/tree/dd587fedd79836442a4117164ea8c46685453c34),
and the registry port definitions for [Flecs](https://github.com/microsoft/vcpkg/tree/9e593bb18ea69cc5095e012465dcd675a822ed0d/ports/flecs)
and [PhysX](https://github.com/microsoft/vcpkg/tree/9e593bb18ea69cc5095e012465dcd675a822ed0d/ports/physx).

Declare both direct dependencies in the Gate 2A manifest and use exact
overrides for `flecs 4.1.6#0` and the overlay `physx 5.5.0#2`. A vcpkg baseline normally
provides a version floor, whereas an override forces the selected version;
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

The pinned port downloads `106.4-physx-5.5.0` with archive SHA-512
`93ad438db81e9dc095741c837c0e797b56b35d6b77c7d1b1367b11bcbcb4ee1b8ff2affc27624d06829ac5e979f08d506fe727851fc383724e6633b775752d82`.
For Linux x64 it disables snippets and OmniPVD runtime and maps the triplet's
linkage to `PX_GENERATE_STATIC_LIBRARIES`. The generated consumer package is
`unofficial-omniverse-physx-sdk`; its broad `unofficial::omniverse-physx-sdk::sdk`
target includes core, Foundation, Common, Extensions, PVD, Character,
Cooking, and Vehicle libraries. These are properties of the exact
[vcpkg port and generated config](https://github.com/microsoft/vcpkg/tree/9e593bb18ea69cc5095e012465dcd675a822ed0d/ports/physx),
not an NVIDIA-supported CMake consumer package.

The port declares only host helpers `vcpkg-cmake@2024-04-23#0`,
`vcpkg-cmake-config@2026-07-21#0`, and
`vcpkg-cmake-get-vars@2025-05-29#0`. A static Linux consumer also needs the
system libraries `pthread` and `dl`, as shown by NVIDIA's exact
[PhysX 5.5 build instructions](https://nvidia-omniverse.github.io/PhysX/physx/5.5.0/docs/BuildingWithPhysX.html#building-and-linking-against-physx).

The upstream 5.5 Linux profile supports x86-64 Clang, glibc 2.31 or newer, and
lists Clang 10, 14, and 18 on Ubuntu 20.04, 22.04, and 24.04 respectively.
NVIDIA's exact [Linux platform readme](https://github.com/NVIDIA-Omniverse/PhysX/blob/dd587fedd79836442a4117164ea8c46685453c34/physx/documentation/platformreadme/linux/README_LINUX.md)
does not claim Clang 22 or Debian 13 support. Therefore the Gate 2A clean build,
warnings, sanitizers, and native Debian execution are required compatibility
evidence; they must not be described as upstream-supported.

The stock vcpkg port is explicitly marked as not officially supported by
NVIDIA. It also unconditionally downloads the Linux PhysXGpu package with
SHA-512
`4728bd0c37f1c931e31b1aa3354d45f157ca4930199840cb98524f02fa0422f7e6f72dce860111c6494b0bde8944a758e9dd8940d7015057e528d4db98d6bd0c`,
even if the consumer never copies or loads its optional target. Gate 2A
therefore uses a `5.5.0#2` Sacramento overlay which removes that download and
copy block, supports only static release Linux x64, and proves that no GPU
library enters the download inventory, installed tree, or Session Authority
runtime. This overlay is prototype evidence and still requires the independent
production-admission review defined by ADR-0003.

PhysX 5.5 source is [BSD-3-Clause](https://github.com/NVIDIA-Omniverse/PhysX/blob/dd587fedd79836442a4117164ea8c46685453c34/LICENSE.md).
That top-level license would not replace review of the separately downloaded
GPU package and every notice it contains if a future port enabled that optional
binary input; Gate 2A deliberately does not download it.

## Fixed-tick replay and determinism boundary

PhysX does not promise general or cross-platform determinism. For rigid bodies
and articulations, release 5.5 documents identical results only for the same
platform and PhysX build when the application recreates a new scene with the
same API-call sequence, uses the same time-stepping scheme, and returns the same
simulation-callback responses. Different platforms, hardware floating-point
behavior, compilers, optimization modes, settings, or call sequences can
diverge. Non-rigid actors are not covered. See the exact
[PhysX 5.5 determinism contract](https://nvidia-omniverse.github.io/PhysX/physx/5.5.0/docs/API.html#determinism).

`PxSceneFlag::eENABLE_ENHANCED_DETERMINISM` reduces unrelated-island changes
caused by actor insertion/removal, with a performance cost, but still requires
all the preceding conditions. A fixed `PxScene::simulate(step)` followed by
blocking `fetchResults(true)` is the documented fixed-step pattern; variable
steps can change behavior. See [enhanced determinism](https://nvidia-omniverse.github.io/PhysX/physx/5.5.0/docs/API.html#enhanced-determinism)
and the [simulation loop](https://nvidia-omniverse.github.io/PhysX/physx/5.5.0/docs/Simulation.html#the-simulation-loop).

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
- PhysX is ready to test only as CPU rigid-body simulation. Passing Gate 2A
  qualifies that exact prototype composition, not Clang 22 as upstream-supported
  and not the optional GPU package.
- The final binary/load audit must show no Falcor, Slang, Steam Audio, PhysXGpu,
  CUDA, or other client-only/optional runtime dependency.
- A repeated Sacramento-owned digest proves reproducibility only within the
  captured Debian platform, binary, configuration, and input identity.
