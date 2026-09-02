# Gate 2D result: client Acoustic Propagation

Date: 2026-09-02

Verdict: **PASS for native Debian execution and Windows cross-build; native
Windows execution remains UNPROVED.**

## Question and answer

Can Steam Audio 4.8.1 process a representative Acoustic Propagation event
behind Sacramento-owned types, preserve a Sacramento-authoritative arrival
timestamp, and remain absent from the Debian Session Authority?

Yes, within the direct, CPU-only, offline scope exercised here. The authority
emitted `sacramento.acoustic-event.v1`; the private client adapter constructed
a wall mesh and material, ran Steam Audio distance attenuation, raycast
occlusion and transmission, and applied its built-in HRTF to produce stereo
PCM. No `IPL*`, `phonon`, or vendor-named error type crossed the public API.

## Observed event

The fixture placed the source 12 m from the listener with a wall at 6 m and
350-per-mille three-band transmission. Sacramento calculated the arrival from
an exact 343,000 mm/s propagation model:

| Observation | Value |
| --- | ---: |
| Initiated timestamp | 4,000,000,000 ns |
| Authoritative arrival timestamp | 4,034,985,423 ns |
| Scheduled 48 kHz sample | 1,680 |
| First rendered non-zero sample | 1,936 |
| First rendered non-zero timestamp | 4,040,333,333 ns |
| Distance attenuation | 83 per mille |
| Direct occlusion | 0 per mille |
| Low-band transmission | 350 per mille |
| Left/right absolute energy | 53,010 / 265,291 |
| Left/right HRTF peak delay | 1,167 / 542 us |
| PCM FNV-1a | `795bf250473883b0` |

The first non-zero sample includes renderer/HRTF frame latency and is only a
presentation observation. It does not replace or feed back into the
Sacramento-owned authoritative timestamp.

## Build and repeatability evidence

The gate used Clang 22.1.2, CMake 4.4.0 as acquired by the pinned vcpkg tool,
and the repository's verified Debian 13.6 and Windows SDK/MSVC sysroots. Two
fresh build directories per target produced byte-identical authority and
client binaries. Two native Debian executions produced identical event files,
JSON observations, and PCM.

| Artifact | Bytes | SHA-256 |
| --- | ---: | --- |
| Debian authority | 20,336 | `bf95e4cafd7c760b940ee336e3de4bad942c65a122de299a36f21316fd420571` |
| Debian client | 6,646,592 | `7302cabd5dccb271179310a47122477aa6ab0ddb35315de4395fb7fcac6fe982` |
| Windows authority | 30,720 | `d449328829489f62f6749f281d94d278d8b284b6c67a6abd22799accc727fe0b` |
| Windows client | 6,584,832 | `a9fa0625bd2cbe930426bfd26a49c314ef302e9dc5a9228c6a5bfe3f2dc1b1d5` |
| Event fixture | — | `d8abf5e78dcbf948d6561326ad248f527b561a8923c9aff2382b17bc6a8c093d` |
| Debian PCM | — | `d9f023aa5735603f8adaec7dace7a8e8279d1b482ce3c9442724768db9b6c060` |

Dependency installation took 71,446 ms for Debian and 56,187 ms for Windows.
Fresh application builds took 2,048–2,200 ms; the measured no-change Debian
build took 2,071 ms. Client processing took 39,126 us and 38,697 us in the two
runs. The complete gate took 142,800 ms. These timings are smoke evidence, not
production performance claims.

The Windows client is a PE32+ x86-64 executable. Its import table contains the
approved dynamic MSVC runtime and Windows system libraries, but no Steam Audio,
MySOFA, zlib, FlatBuffers, or PFFFT DLL. The retained native bundle contains
the client, exact event, PowerShell smoke runner, and Steam Audio notice.

## Dependency and boundary result

The vcpkg registry baseline is
`9e593bb18ea69cc5095e012465dcd675a822ed0d`. It selected Steam Audio 4.8.1
(port tree `c70954b4a0f45b8e49288658f31385095eb6f152`, upstream tag commit
`0da18255cca520771f363ee01f100572b39a308e`) plus FlatBuffers 25.12.19,
libmysofa 1.3.4#1, PFFFT 1.0.0, and zlib 1.3.2#1. The source archive SHA-512 is
recorded by the pinned port and every downloaded archive and installed
copyright file was hashed by the runner. Declared/installed notices cover
Apache-2.0, BSD-3-Clause, MIT, and Zlib terms.

The boundary audit passed:

- the public header and non-adapter sources contain no vendor tokens;
- only `steam_audio_adapter.cc` uses Steam Audio;
- the authority has no Steam Audio symbols and needs only libc, libm,
  libgcc_s, and libstdc++;
- the client contains the expected Steam Audio calls.

The adapter adds 364 first-party lines; event serialization/scheduling and the
public header add another 260 lines.

## Gate-local integration exceptions

The proof uncovered constraints that must be resolved or deliberately carried
into a production profile:

1. The vcpkg Steam Audio export omits dependency discovery and include paths.
   The consumer explicitly discovers FlatBuffers, MySOFA, PFFFT, and
   `phonon.h` before importing `unofficial::steam-audio::phonon`.
2. The official port keys CRT policy from `VCPKG_TARGET_IS_WINDOWS`, which is
   false in Sacramento's external clang-cl triplet. The overlay wraps the
   exact pinned port and restores the approved `/MD` policy; the final cache
   records `MultiThreadedDLL` and Steam Audio's static-runtime option is off.
3. Windows `try_compile` otherwise requests the unavailable debug CRT. The
   chainload selects Release for compiler probes.
4. The shared reproducibility profile emits `/pathmap`, which Linux-hosted
   clang-cl misinterprets as a file. This gate uses `/Brepro` plus Clang file
   and debug prefix maps.
5. CMake supplies a Clang C++23 mode while the shared profile also supplies
   `/std:c++23preview`. The gate suppresses only clang-cl's unused-command-line
   diagnostic; C++23 remains active and warnings remain errors.
6. The pinned vcpkg executable currently acquires CMake 4.4.0 even though the
   repository bootstrap profile pins CMake 4.2.3.

## What this does not prove

This gate does not qualify reflections, pathing, baking, a real-time/audio-safe
mixer handoff, native audio devices, concurrent event stress, perceptual
localization, production performance, native Windows runtime behavior, or a
Falcor-rendered client composition. Steam Audio does not define Blast
Overpressure or canonical simulation time. Controlled-LAN networking is not
part of this client-only acoustic seam.

Issue #11 therefore remains open for the remaining composed-foundation work,
observability/Tracy proof, and final dependency/profile synthesis.

## Reproduction

From the repository root, with the approved toolchain already bootstrapped:

```sh
SACRAMENTO_GATE2D_ROOT=/tmp/sacramento-composed-foundation-gate2d \
  prototypes/composed_foundation_gate2d/run-gate2d.sh
```

The accepted raw evidence and Windows native bundle for this run are retained
at `/tmp/sacramento-composed-foundation-gate2d-final` on the build host.
