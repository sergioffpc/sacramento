# Gate 2B result: cooker-owned Map asset seam

## Verdict

**Assimp path: pass for the representative x86-64 Linux fixture.** Python
3.14.4 invokes a Sacramento-owned C++23 executable linked statically with
Assimp 6.0.5. The executable returns `sacramento.map-import` version 1; only
that Sacramento-owned interchange reaches the Python packaging logic.

The resulting `sacramento.map-package` version 1 contains the stable Map,
anchor, material/shader, render geometry, collision geometry, and content
identity required by issue #22. Neither package nor manifest contains an
importer name, source suffix/path, DCC schema, USD construct, or vendor type.

The 38,120-byte C++23 runtime reader consumes only the cooked package. Its ELF
closure is `libstdc++`, `libm`, `libgcc_s`, and `libc`; no Assimp, Python,
OpenUSD, source-format, or DCC dependency is present.

## Determinism and measurements

Two fresh CMake/Ninja build roots produced byte-identical executables. Two
fresh cook output roots produced byte-identical packages and manifests:

| Artifact | Size | SHA-256 |
| --- | ---: | --- |
| Assimp adapter | 1,615,176 bytes | `67906acbccb942e3a75eae56ce4714d881c56089cb5f50d05777d08103a1a1d6` |
| Runtime reader | 38,120 bytes | `eb305b83e35d845e29baa6a0bbc2e499f8191da9dd236d47d8f3bbb1727c9870` |
| Map package | 635 bytes | `14b1f2847195635dcf615cce510a15004288ae24176d479d61184aa1f965e5d9` |
| Manifest | 235 bytes | `c21f1c85d8f5a48709de7e77e28c887dac7529896436fbede1d67477495e7f1c` |

The package records content identity
`sha256:1849d21148d23e4ad2da81e4ddbec5d7fbd636b00e4c9b087bc14db0589c2c46`.
Clean project builds measured 2,349 ms and 2,303 ms; clean cooks measured 62
ms each. These are single observations on the Gate host, not performance
budgets.

The runtime reader observed one anchor, one material, one render mesh, one
triangle-mesh collider, four vertices, and two triangles. Public-interface
tests also proved byte identity, content/package identity verification,
source-schema absence, a missing-adapter diagnostic, and unsupported-source
rejection. Stable failures use `SAC-COOK-*` identifiers.

## Assimp dependency closure

The gate-local overlay pins Assimp tag `v6.0.5`, commit
`392a658f9c271be965271f45e7521a1b80ea4392`, and source-archive SHA-512
`57326194bf3a8e2ae793c739878231067fdd6d031531e910d4d20fc8a673eacf48f75e11bd21ca2e6421682f78585d445bffb647bdcb52e01b2cd4d3ff0e2c62`.
The pinned registry's `build_fixes.patch` applied cleanly. Exporters, tools,
tests, Draco, VRML, all non-glTF importers, Assimp's tinyusdz USD importer, and
Cineware remain off.

Actual target packages and ABIs were:

| Package | Version | ABI |
| --- | --- | --- |
| assimp | 6.0.5 | `921452ffa86068bf448bdffae956ab6361daa269ae1135a2532f1df790256a1b` |
| jhasse-poly2tri | 2023-12-27#2 | `b46865c7bfb9474037e5a60ec8b1c74c3cfc2b0067565b32a7eb021fa3c5abe3` |
| kubazip | 0.3.14 | `d673a490bdbf0f666d4f3a32c25ce60d24a50dc68634aefb8eb3c9abd3d58c02` |
| minizip | 1.3.2 | `6be82807c0c3504eed9e2e44242464f6fe5b02d4bb2e1ad22a743cf810114eb6` |
| polyclipping | 6.4.2#13 | `31f83e285905dc0afcd3c177afb5d25a9c8d66e4ca0cf91bab507169ef040b3f` |
| pugixml | 1.16 | `cade919f87c9e96a6a127a5868ade6cbe96a4f8dcca50fd023b967fce36cb63b` |
| rapidjson | 2025-02-26 | `f7c5bf5482d998105e4b171c4ab0de660c5882219c0db64ae747fff3a9ad0416` |
| stb | 2024-07-29#1 | `46b43a2c0e16b99006670b225e7093ac7034c83425fe77bb4159d1582056ffe9` |
| utfcpp | 4.1.1 | `5fd3ee227c5352818f3763ae30d31f6a057278b1ce737b24952ea3f854a348b0` |
| zlib | 1.3.2#1 | `cc0bbdeb2833f64b20fd7dd093301af2a2d7ea005f0a4712e99b8c3d4368286b` |

Host helpers were `vcpkg-cmake 2024-04-23`, `vcpkg-cmake-config
2026-07-21`, and `vcpkg-cmake-get-vars 2025-05-29`; their ABIs are retained by
the gate script's install log. Installed licences resolve to BSD-3-Clause,
MIT, Zlib, BSL-1.0, and `MIT OR CC-PDDC`, with each installed copyright file
hashed by the gate script. The vcpkg tool downloaded CMake 4.4.0 for port
builds; the Sacramento project itself configured with its pinned CMake 4.2.3.

## OpenUSD disposition

**Optional cooker frontend.** The isolated fixture uses a root layer and
sublayer, an external reference, an explicitly selected material variant, and
a deferred payload. The `usd-core 26.8` adapter opens the complete stage,
checks each composition mechanism, explicitly loads the required payload, and
translates the composed result into `sacramento.map-import` version 1. It
produced the exact same 635 package bytes and 235 manifest bytes as Assimp.

The tested official wheel was
`usd_core-26.8-cp314-none-manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl`:

- SHA-256: `114f39723ccfc9a269cfdf6a7b80fec53aa96530806e510a6cccfd577401a07c`
- compressed size: 29,575,839 bytes
- extracted size: 217,370,102 bytes
- licence metadata: `LicenseRef-TOST-1.0`
- Python constraint: `>=3.9, <3.15`
- native inventory: 31 extension/shared-library files; bundled `libusd_ms` and
  `libtbb`, plus the normal GNU/Linux C/C++/thread/dynamic-loader libraries;
  no unresolved ELF dependency under the wheel's bundled-library path
- measured composed-adapter time: 184 ms

This finding does not admit OpenUSD into ADR-0003. It establishes that an
optional cooker-only adapter can earn its seam for a composition-heavy Map
workflow. Production admission still requires owner approval and the full
platform, packaging, licence/NOTICE, vulnerability, ABI, offline, and authoring
tool qualification described in the research snapshot. OpenUSD remains absent
from the runtime reader and cooked artifacts.

## Reproduction and limitations

Run, in order:

```sh
SACRAMENTO_GATE2B_ROOT=/tmp/sacramento-gate2b-final \
  prototypes/composed_foundation_gate2b/run-gate2b.sh
SACRAMENTO_GATE2B_ROOT=/tmp/sacramento-gate2b-final \
  prototypes/composed_foundation_gate2b/run-openusd-experiment.sh
```

The executable proof is limited to one Blender-origin glTF 2.0 fixture and one
composition-equivalent USDA fixture on an x86-64 Ubuntu 26.04/Clang 22 cooker
host. It does not qualify direct `.blend`, additional import formats, texture
assets, animation, broad material networks, Windows/macOS cooker hosts,
free-threaded Python, Nucleus/live Omniverse connectivity, USD Physics, or
production dependency admission. The runtime package is a throwaway JSON
format used to prove the seam, not an admitted production serialization.
