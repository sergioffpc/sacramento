# Gate 2B cooker dependency qualification

Status: Research snapshot, not dependency admission

Research date: 2026-09-02

Scope: Assimp as the selected cooker-only source importer and OpenUSD as an
unselected cooker-only candidate. All factual claims below are traced to
upstream release records, source, documentation, package metadata, or the
repository-pinned vcpkg registry. No runtime target may acquire either
dependency through this qualification.

## Conclusions

1. Gate 2B should use **Assimp 6.0.5**, tag `v6.0.5`, commit
   `392a658f9c271be965271f45e7521a1b80ea4392`, released 2026-04-30. This is
   the current stable upstream release, but Sacramento's pinned vcpkg registry
   contains only `assimp 6.0.4#3`. Gate 2B therefore needs a gate-local vcpkg
   overlay for 6.0.5 or an explicit decision to test the older registry port;
   silently calling 6.0.4 current is not acceptable. See the [6.0.5 release],
   [exact commit], [pinned Assimp manifest], and [pinned Assimp portfile].
2. Do not use PyAssimp or another Python wrapper as the qualified boundary.
   Upstream calls PyAssimp incomplete, says Python 3 support is not well tested,
   and makes it load an independently installed shared library through
   `ctypes`. Instead build a small Sacramento-owned C++ executable against
   Assimp through vcpkg. Python 3 should invoke it as a subprocess and consume
   a Sacramento-owned, versioned interchange result. The stock `assimp` CLI is
   also unsuitable as that boundary: its text dumps are explicitly unstable
   and not an intermediate format, while the pinned vcpkg port disables the
   tools. See [PyAssimp's upstream status], [Assimp command documentation], and
   the [C/C++ import API].
3. The Blender-origin fixture should be exported from Blender to a documented
   interchange format, preferably glTF 2.0/GLB. Direct `.blend` import is
   deprecated upstream because the format is undocumented and too costly to
   maintain. Gate acceptance must be based on the Sacramento result, not on a
   claim that every listed Assimp format has equivalent fidelity. See the
   [6.0.5 format matrix].
4. The current OpenUSD release is **26.08**, tag `v26.08`, signed-tag target
   commit `ee47c679abde5b467a7b6a41f3b2285564a4222e`, released 2026-07-20.
   The official Python distribution is `usd-core 26.8`. It is a viable isolated
   experiment for composition, but it is not dependency admission: it contains
   core libraries only, has no imaging or optional plugins, and enters as a
   wheel rather than through vcpkg. See the [26.08 release],
   [exact OpenUSD commit], [26.08 documentation], and
   [official usd-core metadata].
5. Sacramento's pinned vcpkg registry contains `usd 26.5#1`, not 26.08; that
   port is dynamic-only and explicitly disables Python. A production admission
   of OpenUSD 26.08 with Python would therefore require a qualified custom vcpkg
   port or a project-owner-approved dependency-policy change. Upstream's
   `build_usd.py` downloads and builds dependencies itself, so it cannot become
   a second dependency manager under ADR-0003. See the [pinned USD manifest],
   [pinned USD portfile], and [upstream build script].
6. Native USD composition materially can help multi-author, reusable Map
   authoring and Omniverse interchange. Gate 2B exercised the official
   `usd-core 26.8` wheel in isolation with layers, references, variants, and a
   payload, then translated the composed result into the same Sacramento-owned
   intermediate representation and exact cooked bytes as Assimp. This supports
   **optional cooker frontend** for the gate, not baseline admission. USD prim
   paths, layers, schemas, material networks, and Physics schemas remain behind
   the adapter seam. See the [Gate 2B result].

[6.0.5 release]: https://github.com/assimp/assimp/releases/tag/v6.0.5
[exact commit]: https://github.com/assimp/assimp/commit/392a658f9c271be965271f45e7521a1b80ea4392
[pinned Assimp manifest]: https://github.com/microsoft/vcpkg/blob/9e593bb18ea69cc5095e012465dcd675a822ed0d/ports/assimp/vcpkg.json
[pinned Assimp portfile]: https://github.com/microsoft/vcpkg/blob/9e593bb18ea69cc5095e012465dcd675a822ed0d/ports/assimp/portfile.cmake
[PyAssimp's upstream status]: https://github.com/assimp/assimp/blob/v6.0.5/port/PyAssimp/README.md
[Assimp command documentation]: https://github.com/assimp/assimp/blob/v6.0.5/doc/dox_cmd.h
[C/C++ import API]: https://github.com/assimp/assimp/blob/v6.0.5/include/assimp/cimport.h
[6.0.5 format matrix]: https://github.com/assimp/assimp/blob/v6.0.5/doc/Fileformats.md
[26.08 release]: https://github.com/PixarAnimationStudios/OpenUSD/releases/tag/v26.08
[exact OpenUSD commit]: https://github.com/PixarAnimationStudios/OpenUSD/commit/ee47c679abde5b467a7b6a41f3b2285564a4222e
[26.08 documentation]: https://openusd.org/release/
[official usd-core metadata]: https://pypi.org/pypi/usd-core/26.8/json
[pinned USD manifest]: https://github.com/microsoft/vcpkg/blob/9e593bb18ea69cc5095e012465dcd675a822ed0d/ports/usd/vcpkg.json
[pinned USD portfile]: https://github.com/microsoft/vcpkg/blob/9e593bb18ea69cc5095e012465dcd675a822ed0d/ports/usd/portfile.cmake
[upstream build script]: https://github.com/PixarAnimationStudios/OpenUSD/blob/v26.08/build_scripts/build_usd.py
[Gate 2B result]: ../evidence/gate-2b-result.md

## Assimp 6.0.5

### Identity and license

The release identity is the lightweight Git tag `v6.0.5` at full commit
`392a658f9c271be965271f45e7521a1b80ea4392`. Admission evidence must retain the
source archive hash in addition to the tag and commit; a moving branch or a
package version alone is not a source identity.

Assimp is BSD-3-Clause. Its repository `LICENSE` also carries the notices for
code shipped in the source tree and excludes `test/models-nonbsd`, whose models
have individual terms. The gate must not package those test models. PyAssimp has
a separate ISC license, but it is not selected. See the [Assimp 6.0.5 license]
and [PyAssimp license].

[Assimp 6.0.5 license]: https://github.com/assimp/assimp/blob/v6.0.5/LICENSE
[PyAssimp license]: https://github.com/assimp/assimp/blob/v6.0.5/port/PyAssimp/LICENSE

### Qualified Python 3 integration

Use this process boundary:

```text
Python 3 cooker orchestration
  -> subprocess with fixed arguments and controlled environment
  -> Sacramento Assimp adapter executable
  -> libassimp 6.0.5 from a pinned vcpkg overlay
  -> Sacramento-owned versioned interchange result
  -> deterministic Sacramento cooked package
```

The executable should use Assimp's C++ API or stable C API internally, convert
only the fields required by the representative fixture, and return stable
Sacramento diagnostic identifiers. It must not emit `aiScene`, `assbin`, an
Assimp text dump, or serialized Assimp structs. Python owns orchestration and
deterministic packaging; C++ owns the narrow native-library interaction. This
keeps the native dependency in vcpkg and avoids a second native ABI definition
in Python.

The rejected alternatives are evidence-based:

- Upstream PyAssimp is a `ctypes` wrapper, requires a separately discoverable
  dynamic library, says Python 3 is not well tested, and says many Assimp
  features are missing. A Python-package version therefore does not close the
  native ABI or library-search problem.
- `assimp dump` text is expressly unstable and not intended as an intermediate
  format. `assbin` is still an Assimp-owned persistent format and would leak the
  vendor boundary. The pinned vcpkg recipe sets
  `ASSIMP_BUILD_ASSIMP_TOOLS=OFF` in any case.
- A third-party wrapper would add an independently versioned binding, license,
  ABI mapping, and release cadence without reducing the required qualification
  of libassimp itself.

### Features, formats, and limits

Assimp 6.0.5 requires CMake, C++17, and C99. Upstream supports building shared
or static libraries and can disable exporters, individual importers, tests,
tools, Draco, USD, and the non-free Cineware/C4D importer. Gate 2B should build
the smallest import-only configuration: tests and tools off for the package,
exporters off, Draco off unless the fixture proves it is needed, Assimp's USD
importer off, and Cineware off. The representative adapter tests remain
Sacramento tests. See [Assimp build instructions] and [6.0.5 CMake options].

Assimp's optional USD importer is not OpenUSD: it uses a patched, pinned
`tinyusdz` source acquired through CMake `FetchContent`. Enabling it would add a
different USD implementation and an uncontrolled download path, so the Assimp
overlay must keep `ASSIMP_BUILD_USD_IMPORTER=OFF`; the separate OpenUSD
experiment owns USD evaluation. See the [Assimp importer source closure].

[Assimp build instructions]: https://github.com/assimp/assimp/blob/v6.0.5/Build.md
[6.0.5 CMake options]: https://github.com/assimp/assimp/blob/v6.0.5/CMakeLists.txt
[Assimp importer source closure]: https://github.com/assimp/assimp/blob/v6.0.5/code/CMakeLists.txt

The upstream matrix lists more than forty import formats, including glTF
1.0/2.0 and GLB, FBX, Collada, OBJ, PLY, STL, 3MF, IFC-STEP, USD, and deprecated
BLEND. It also identifies C4D as dependent on non-free code. Export support is
not symmetrical: glTF export is partial and FBX/3MF export is experimental.
Gate 2B only qualifies the exact importer and feature subset exercised by its
fixtures; the list is not a Sacramento support promise.

Upstream documents Windows, Linux, and macOS use, including x86/x64, but states
that big-endian systems are not officially supported. Its MinGW cross-build
guidance is community/untested guidance, not evidence for Sacramento's
Clang/clang-cl matrix. The gate must record which cooker hosts are applicable
and prove every applicable native adapter build; a successful Linux host build
must not be reported as Windows qualification. See [Assimp platform notes].

[Assimp platform notes]: https://github.com/assimp/assimp/blob/v6.0.5/doc/dox.h

### vcpkg closure at the Sacramento baseline

The registry commit fixed by Sacramento is
`9e593bb18ea69cc5095e012465dcd675a822ed0d` (vcpkg release 2026.07.29). Its
Assimp recipe is `6.0.4#3`, not 6.0.5, disables tools, tests, VRML, and bundled
zlib, and exposes Draco only as an opt-in feature. With no features, the
registry-declared closure is:

| Package | Pinned version | Registry-declared license | Role |
| --- | --- | --- | --- |
| `assimp` | `6.0.4#3` | BSD-3-Clause | Direct library; must be replaced by a 6.0.5 gate-local overlay |
| `jhasse-poly2tri` | `2023-12-27#2` | BSD-3-Clause | Target transitive |
| `kubazip` | `0.3.14` | MIT | Target transitive |
| `minizip` | `1.3.2` | Zlib | Target transitive |
| `polyclipping` | `6.4.2#13` | BSL-1.0 | Target transitive |
| `pugixml` | `1.16` | MIT | Target transitive |
| `rapidjson` | `2025-02-26` | MIT | Target transitive |
| `stb` | `2024-07-29#1` | MIT OR CC-PDDC | Target transitive |
| `utfcpp` | `4.1.1` | BSL-1.0 | Target transitive |
| `zlib` | `1.3.2#1` | Zlib | Target transitive |
| `vcpkg-cmake` | `2024-04-23` | MIT | Host-only build helper |
| `vcpkg-cmake-config` | `2026-07-21` | MIT | Host-only build helper |

These are recipe declarations, not final admission evidence. The 6.0.5 overlay
must start from this exact port, update the source identity and hash, revalidate
its patch and options, and record the actual `vcpkg list`, package ABI values,
installed copyright files, downloaded source hashes, and linkage. Enabling
Draco adds `draco` and its closure and therefore requires a separate review.
The [pinned registry port tree] is the authoritative package recipe snapshot.

[pinned registry port tree]: https://github.com/microsoft/vcpkg/tree/9e593bb18ea69cc5095e012465dcd675a822ed0d/ports

### Assimp update procedure

1. Compare the latest non-draft, non-prerelease upstream release with the
   version in Sacramento's pinned vcpkg registry. Record release date, tag,
   full commit, tag/signature status, archive hash, and release notes.
2. Prefer an exact curated registry version. Do not advance the repository-wide
   vcpkg baseline inside a prototype merely to obtain one package. If the
   registry lags, copy its port and patches into the gate-local overlay, update
   only the exact source version/hash, and document every recipe difference.
3. Re-evaluate importer/exporter switches and the complete vcpkg graph. Review
   every installed copyright file and any new vendored directory; do not infer
   transitive licenses from the Assimp license.
4. Build from empty download, buildtree, package, and installed roots with the
   pinned Sacramento toolchain. Capture package ABIs and verify offline replay.
5. Re-run malformed-input tests and a representative corpus for every admitted
   source format. Compare hierarchy, transforms, axis/unit conversion, mesh
   topology, normals/tangents, UVs, materials, texture references, collision
   metadata, stable anchors, and deterministic Sacramento output. A new Assimp
   version is not admitted merely because it compiles.

## OpenUSD 26.08

### Identity, license, and distributions

The exact release is annotated tag `v26.08`, tag object
`cb5613f6da7c61b56fe86dbe8cc1cbe9f0d84ef1`, which resolves to commit
`ee47c679abde5b467a7b6a41f3b2285564a4222e`. OpenUSD 26.08 is licensed under
the Tomorrow Open Source Technology License 1.0 (TOST-1.0), derived from Apache
2.0 but with a different section 6, plus the third-party notices collected in
the release `LICENSE.txt`. This must be reviewed as TOST-1.0, not recorded as
plain Apache-2.0, and distribution must also retain the upstream `NOTICE.txt`.
See the [OpenUSD 26.08 license] and [OpenUSD 26.08 notice].

[OpenUSD 26.08 license]: https://github.com/PixarAnimationStudios/OpenUSD/blob/v26.08/LICENSE.txt
[OpenUSD 26.08 notice]: https://github.com/PixarAnimationStudios/OpenUSD/blob/v26.08/NOTICE.txt

The official `usd-core 26.8` Python package is the narrowest viable Gate 2B
experiment:

- it is published by Pixar Animation Studios for CPython 3.9 through 3.14 and
  declares `Python >=3.9,<3.15`;
- it publishes wheels only, with no source distribution and no Python
  `Requires-Dist` dependencies;
- platforms are Windows x86-64, manylinux x86-64 with glibc 2.27/2.28
  compatibility tags, and macOS 10.15+ universal2;
- the CPython 3.14 manylinux wheel is 29,575,839 bytes with SHA-256
  `114f39723ccfc9a269cfdf6a7b80fec53aa96530806e510a6cccfd577401a07c`;
  a different selected interpreter/platform requires its own filename and hash;
- it includes core USD libraries, but explicitly excludes imaging, optional
  plugins, and the full-distribution viewer surface.

Before use, Gate 2B must select and record the exact CPython build, wheel
filename, hash, extracted native-library inventory, bundled notices, ELF
dependencies, and package size. `Requires-Dist: null` closes only Python-level
dependencies; it does not prove the wheel's native or system-library closure.
The wheel filenames use a `none` ABI component despite containing extension
modules. Upstream issue [OpenUSD #4149] reports crashes with free-threaded
CPython for similarly tagged official wheels, so the experiment must use a
conventional GIL-enabled CPython build and reject free-threaded Python until
upstream resolves and Gate evidence requalifies it.

[OpenUSD #4149]: https://github.com/PixarAnimationStudios/OpenUSD/issues/4149

### Source-build closure and platform constraints

Upstream describes compiler, CMake, and TBB as the required core build
dependencies; Python is required for the bindings. Imaging adds OpenSubdiv;
usdview adds PySide2/PySide6 and PyOpenGL; MaterialX, OpenImageIO, OpenColorIO,
OSL, Ptex, Embree, Alembic, Draco, HDF5, Vulkan, and other plugins are optional.
They are unnecessary for the composition-only Gate experiment and must remain
off. See [OpenUSD build overview], [advanced build options], and the [tested
version matrix].

Those features must be disabled explicitly in a source build. Upstream's
default `build_usd.py` invocation builds core, Imaging, and USD Imaging, and
MaterialX is enabled by default in that script; it is not a lean cooker closure.

[OpenUSD build overview]: https://github.com/PixarAnimationStudios/OpenUSD/blob/v26.08/README.md
[advanced build options]: https://github.com/PixarAnimationStudios/OpenUSD/blob/v26.08/BUILDING.md
[tested version matrix]: https://github.com/PixarAnimationStudios/OpenUSD/blob/v26.08/VERSIONS.md

The upstream tested matrix for 26.08 is AlmaLinux 9.5/gcc 11.5, macOS
15.4.1/Apple clang 16, and Windows 11/Visual Studio 2022 17.14, with Python
3.9.x. It lists legacy TBB 2020.3 and oneTBB 2021.9. Those are upstream test
inputs, not proof for Sacramento's Ubuntu 26.04/Clang 22 or cross-compiled
Windows configuration.

Upstream supports Linux, macOS, and Windows and also documents iOS, visionOS,
and WebAssembly builds. The latter have important limits: iOS/visionOS builds
do not support Python bindings or command-line tools; Windows ARM64EC is not
supported and usdview is unavailable on Windows ARM64; WebAssembly is static
monolithic and has no command tools. The official Python wheels narrow the
actual experiment further to CPython on x86-64 Linux/Windows or universal2
macOS.

Sacramento's pinned vcpkg `usd 26.5#1` port:

- supports neither x86, Android, nor Windows ARM;
- permits dynamic linkage only;
- disables Python, tools, tests, examples, tutorials, imaging, and optional
  plugins in its base configuration;
- declares target dependencies `tbb 2023.1.0` (Apache-2.0) and
  `zlib 1.3.2#1` (Zlib), plus MIT-licensed host helpers
  `vcpkg-cmake 2024-04-23` and `vcpkg-cmake-config 2026-07-21`;
- carries several packaging patches, including a TBB 2023 task-API patch.

Consequently, changing that port to 26.08 and enabling Python is not a mechanical
version bump. Its patches, dynamic-library/plugin layout, CPython ABI, TBB
version, zlib linkage, plugin metadata, installed resources, and both applicable
platforms need fresh proof. Running upstream `build_usd.py` would be easier but
would download/build its own selected dependencies (for example TBB/oneTBB and
optional component closures), contrary to the vcpkg-only rule.

For source content, `PXR_PREFER_SAFETY_OVER_SPEED=ON` is mandatory. The official
[GHSA-8878-wr6v-j5cm advisory] states that the Crate bounds-checking fix is in
26.08 and later but is compiled out when that option is off. The pinned vcpkg
port already sets it on; a custom port must preserve and verify it.

[GHSA-8878-wr6v-j5cm advisory]: https://github.com/PixarAnimationStudios/OpenUSD/security/advisories/GHSA-8878-wr6v-j5cm

### Composition semantics relevant to Map authoring

OpenUSD's value is composition, not merely another mesh parser. A `UsdStage` is
the composed scenegraph formed from layer stacks and composition arcs, with
predictable strength ordering of authored opinions. See [OpenUSD introduction],
[composition glossary], and [referencing tutorial].

[OpenUSD introduction]: https://openusd.org/release/intro.html
[composition glossary]: https://openusd.org/release/glossary.html
[referencing tutorial]: https://openusd.org/release/tut_referencing_layers.html

| Construct | Authoring value for a Sacramento Map | Cooker obligation |
| --- | --- | --- |
| Layers and sublayers | Separate base assembly, set dressing, materials, lighting, collision annotations, and per-author overrides without destructively rewriting source assets. Stronger layers can override weaker opinions. | Open the intended root Stage and evaluate the complete ordered layer stack. Reject missing or muted required layers. Translate the final composed values; do not copy layer identifiers into the runtime package. |
| References | Reuse a versioned prop or assembly and place it repeatedly while retaining an asset boundary and non-destructive overrides. References introduce another prim hierarchy into the referencing namespace. | Resolve every external asset and validate the resulting composed prims. Preserve Sacramento stable-anchor identity explicitly; never substitute a USD prim path or asset path for it. |
| Variant sets | Author controlled alternatives such as material, geometry/LOD, collision, damaged state, or Map configuration, with a selected alternative contributing opinions. | Require an explicit, admissible selection where Sacramento semantics need one. Cook the selected result and record source provenance separately; never defer runtime gameplay configuration to a USD variant. |
| Payloads | Keep large geometry or reusable Map sections selectively unloaded during interactive authoring while leaving lightweight asset interfaces and variant choices available. | Load all payloads required by the selected cook, fail closed on unresolved assets, and prove the Stage is complete before translation. Payload load state is an authoring concern, not a runtime-package feature. |

The terminal Sacramento package is exactly the case where destructive
composition flattening is conceptually acceptable: it is a derived delivery
artifact, not a source-authoring layer. The implementation should nevertheless
translate the composed Stage through Sacramento types rather than persist a
flattened USD file. That preserves the deep cooker/runtime seam and ensures
source paths, USD namespaces, and vendor schemas cannot become persistent
runtime interfaces.

USD Physics is source description only in this experiment. If inspected, its
values must be validated and translated into Sacramento-owned collision and
physical descriptions before any PhysX consumer sees them. No USD schema object
or token may become a PhysX or ECS interface.

### Omniverse interchange relevance

NVIDIA describes Omniverse connectors as translators between a DCC's native
data and OpenUSD primitives. Nucleus adds storage, access control, versioning,
and collaborative/live synchronization; Omniverse resolver/file-format plugins
are needed for `omniverse://` URLs and live layers. Core OpenUSD alone therefore
provides file-based USD interchange, not Nucleus connectivity or live
collaboration. See [Connector architecture] and [Nucleus architecture].

[Connector architecture]: https://docs.omniverse.nvidia.com/connect/latest/developing-connectors.html
[Nucleus architecture]: https://docs.omniverse.nvidia.com/nucleus/latest/architecture.html

For Map authoring, the credible benefit is a file-based hand-off from multiple
DCC/Omniverse tools into a composition-preserving source Stage, followed by a
fully offline Sacramento cook. Connector coverage is tool/version specific and
must be smoke-tested with the actual authoring applications. MDL is an NVIDIA
material representation, not universal material interchange; a portable source
workflow should exercise `UsdPreviewSurface` and explicitly translate only the
admitted material subset. See the [Omniverse format guidance], [MDL referencing
guidance], and [connector catalog].

[Omniverse format guidance]: https://docs.omniverse.nvidia.com/usd/latest/common/formats.html
[MDL referencing guidance]: https://docs.omniverse.nvidia.com/usd/latest/technical_reference/referencing_mdl.html
[connector catalog]: https://docs.omniverse.nvidia.com/connect/latest/catalog.html

NVIDIA's current scalable-asset guidance recommends referenceable asset
interface layers, anchored/relocatable asset paths, lightweight metadata and
variants above payloads, and heavy content behind payloads. Its examples show
that this structure improves large-scene authoring and selective loading, but
also note that payloads can complicate navigability and that layers are always
opened and composed. These trade-offs are meaningful only when Gate 2B uses a
multi-layer, referenced fixture rather than a single monolithic USD export. See
the [NVIDIA asset-structure principles] and [Omniverse variant workflow].

[NVIDIA asset-structure principles]: https://docs.omniverse.nvidia.com/usd/latest/learn-openusd/independent/asset-structure-principles.html
[Omniverse variant workflow]: https://docs.omniverse.nvidia.com/workflows/latest/variant-workflows.html

### OpenUSD update procedure

1. Pin the latest stable release tag, signed-tag target commit, source archive
   hash, TOST license revision, and all third-party notices. Treat a license
   change as an admission event.
2. For the isolated Python experiment, select one exact conventional CPython
   build and one official wheel. Retain its URL and SHA-256 in the offline
   source inventory; install without dependency resolution; inventory and
   license-check every native file and system dependency inside it.
3. For any later vcpkg admission, create a 26.08 overlay from the exact pinned
   `usd 26.5#1` port. Rebase every patch deliberately, add only the Python/core
   surface required by the cooker, keep imaging and plugins off, preserve
   `PXR_PREFER_SAFETY_OVER_SPEED=ON`, and capture the resulting vcpkg graph and
   ABIs. Never invoke `build_usd.py` as a package manager in a Sacramento build.
4. From fresh roots, test the exact Clang host/target matrix that applies to the
   cooker. Verify plugin/resource discovery, relocatability, offline replay,
   and the absence of OpenUSD from every Trainee Client and Session Authority
   binary and package.
5. Re-run composition fixtures covering ordered layers, references, variants,
   payload load/unload, missing assets, asset-relative resolution, `upAxis`,
   `metersPerUnit`, material translation, stable anchors, malformed input, and
   deterministic Sacramento output. Smoke-test actual Omniverse/DCC exports.
6. Run the release's validation and diff tools where available, but compare the
   Sacramento intermediate representation and cooked bytes as the acceptance
   authority. For obsolete Crate files, upstream prescribes rewriting with
   `usdcat` or `usdupdatecrate --update`; if the current release can no longer
   read the file, use an older supporting OpenUSD release as a controlled bridge.
   See the [OpenUSD FAQ].

[OpenUSD FAQ]: https://openusd.org/release/usdfaq.html

## Gate execution

The executable gate closed the research questions for its representative
x86-64 Linux cooker host. Exact hashes, package ABIs, dependency closure,
licences, build/cook measurements, package identities, runtime link audit, and
the OpenUSD disposition are retained in the [Gate 2B result] and reproducible
through its linked scripts. These results do not admit either dependency for
other hosts or amend ADR-0003.
