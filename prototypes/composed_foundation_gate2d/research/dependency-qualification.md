# Steam Audio 4.8.1 dependency qualification

Status: qualified for a narrow, CPU-only, offline C API prototype; not yet a
runtime/product acceptance.

This note qualifies the exact Steam Audio dependency available at the
repository's pinned vcpkg registry commit for the acoustic seam of issue #11.
It uses only Valve, Microsoft/vcpkg, and dependency-owner sources. Statements
labelled **inference** are conclusions drawn from those primary interfaces,
not claims made verbatim by Valve.

## Decision

Steam Audio 4.8.1 is viable for a Gate 2D proof that:

- builds the library from source through the pinned vcpkg registry;
- uses the C API from a private adapter;
- constructs a small scene with acoustic materials, one source, and one
  listener;
- runs direct-path simulation on the CPU without OpenCL or a GPU;
- processes generated PCM buffers offline, including HRTF binaural output;
- records quantitative, tolerance-based evidence and the installed native
  library closure.

The implemented narrow gate deliberately leaves reflection and pathing
simulation unproved. They remain candidates for a broader qualification, but
the representative issue #11 event needs only the direct geometry/material
path. The gate must not claim that Steam Audio supplies an authoritative sound-event
arrival timestamp. The normal simulator returns filter/effect parameters, not
an event time. It also must not claim bitwise deterministic reflection output,
production performance, real-time mixer safety, or Windows/Linux runtime
parity without separate evidence.

## Exact identity and integrity

| Item | Pinned identity | Integrity evidence |
| --- | --- | --- |
| Upstream source | tag [`v4.8.1`](https://github.com/ValveSoftware/steam-audio/tree/v4.8.1), lightweight tag target commit [`0da18255cca520771f363ee01f100572b39a308e`](https://github.com/ValveSoftware/steam-audio/commit/0da18255cca520771f363ee01f100572b39a308e) | Valve's [Git ref API](https://api.github.com/repos/ValveSoftware/steam-audio/git/ref/tags/v4.8.1) owns the full tag-to-commit mapping. |
| Upstream C API SDK release | [`steamaudio_4.8.1.zip`](https://github.com/ValveSoftware/steam-audio/releases/download/v4.8.1/steamaudio_4.8.1.zip), released 2026-02-11 | SHA-256 `4a0aa5ec1176f38f0b0993a37c2259d9e86f27e22d5e24f83ec4c3cb9a1d5449`, size `181171027`, published in Valve's [release API metadata](https://api.github.com/repos/ValveSoftware/steam-audio/releases/tags/v4.8.1). |
| vcpkg registry | commit [`9e593bb18ea69cc5095e012465dcd675a822ed0d`](https://github.com/microsoft/vcpkg/tree/9e593bb18ea69cc5095e012465dcd675a822ed0d) | The exact [baseline](https://github.com/microsoft/vcpkg/blob/9e593bb18ea69cc5095e012465dcd675a822ed0d/versions/baseline.json) selects `steam-audio` `4.8.1#0`; its [version database entry](https://github.com/microsoft/vcpkg/blob/9e593bb18ea69cc5095e012465dcd675a822ed0d/versions/s-/steam-audio.json) pins port git-tree `c70954b4a0f45b8e49288658f31385095eb6f152`. |
| vcpkg source archive | Valve tag `v4.8.1` | The exact [portfile](https://github.com/microsoft/vcpkg/blob/9e593bb18ea69cc5095e012465dcd675a822ed0d/ports/steam-audio/portfile.cmake) requires SHA-512 `d1f99fcaa8be41c06f87dbc565e505f6817d0e745f9a582135198c946b1020feebe363dfc35670644af1611b38e7a3204588ff0e5df3c0d9c34c3ce5bb4d0f21`. |

The gate should consume the vcpkg source build, not silently substitute the
prebuilt SDK zip. The release hash above is useful for provenance comparison,
but the registry port has its own source-archive hash and patches.

## License and dependency closure

Steam Audio source is [Apache License 2.0](https://github.com/ValveSoftware/steam-audio/blob/v4.8.1/LICENSE.md).
The pinned vcpkg [manifest](https://github.com/microsoft/vcpkg/blob/9e593bb18ea69cc5095e012465dcd675a822ed0d/ports/steam-audio/vcpkg.json)
also declares `Apache-2.0`, excludes UWP, declares no selectable features, and
has these target dependencies:

| Package in the pinned baseline | Link form forced/allowed by its port | License metadata / notice |
| --- | --- | --- |
| `flatbuffers` `25.12.19#0` (plus host `flatc`) | target library is static-only | Apache-2.0 in its [manifest](https://github.com/microsoft/vcpkg/blob/9e593bb18ea69cc5095e012465dcd675a822ed0d/ports/flatbuffers/vcpkg.json); static-only in its [portfile](https://github.com/microsoft/vcpkg/blob/9e593bb18ea69cc5095e012465dcd675a822ed0d/ports/flatbuffers/portfile.cmake). |
| `pffft` `1.0.0#0` | static-only | vcpkg's manifest has a null SPDX field, so use the upstream notice reproduced in Valve's [`THIRDPARTY.md`](https://github.com/ValveSoftware/steam-audio/blob/v4.8.1/core/THIRDPARTY.md#pffft); the conditions are BSD-style attribution/non-endorsement. Static-only is explicit in the [portfile](https://github.com/microsoft/vcpkg/blob/9e593bb18ea69cc5095e012465dcd675a822ed0d/ports/pffft/portfile.cmake). |
| `libmysofa` `1.3.4#1` | follows the selected triplet's library linkage | BSD-3-Clause and a target dependency on `zlib` in its [manifest](https://github.com/microsoft/vcpkg/blob/9e593bb18ea69cc5095e012465dcd675a822ed0d/ports/libmysofa/vcpkg.json); linkage selection is in its [portfile](https://github.com/microsoft/vcpkg/blob/9e593bb18ea69cc5095e012465dcd675a822ed0d/ports/libmysofa/portfile.cmake). |
| `zlib` `1.3.2#1` | follows the selected triplet | Zlib license in its [manifest](https://github.com/microsoft/vcpkg/blob/9e593bb18ea69cc5095e012465dcd675a822ed0d/ports/zlib/vcpkg.json). |

The Steam Audio third-party notice also names IPP, FFTS, Embree, Radeon Rays,
TrueAudio Next, the CIPIC HRTF database, and Google's Spherical Harmonics
library, with their terms in Valve's
[`core/THIRDPARTY.md`](https://github.com/ValveSoftware/steam-audio/blob/v4.8.1/core/THIRDPARTY.md).
For this port configuration, IPP, FFTS, Embree, Radeon Rays, and TrueAudio Next
are explicitly disabled. The port's copyright install step deliberately
includes Valve's `LICENSE.md` and `core/THIRDPARTY.md`, and notes that CIPIC and
Google Spherical Harmonics components may still be used; therefore the gate
must preserve the installed `share/steam-audio/copyright` in distribution
evidence. This is license-notice qualification, not legal advice.

### Expected runtime artifacts

The port exports
`unofficial::steam-audio::phonon` through its
[`usage`](https://github.com/microsoft/vcpkg/blob/9e593bb18ea69cc5095e012465dcd675a822ed0d/ports/steam-audio/usage)
file. Its vcpkg patch links `phonon` to FlatBuffers, PFFFT, and MySOFA and
installs the public C headers and library; see
[`use-vcpkg-deps.patch`](https://github.com/microsoft/vcpkg/blob/9e593bb18ea69cc5095e012465dcd675a822ed0d/ports/steam-audio/use-vcpkg-deps.patch).

- With a dynamic-library triplet, FlatBuffers and PFFFT are still static-only,
  while `phonon` and MySOFA may be shared and MySOFA may bring a shared zlib.
  On Windows this normally means application-local `phonon.dll`, MySOFA, and
  zlib DLLs plus the triplet-selected MSVC runtime; on Linux it normally means
  `libphonon.so`, MySOFA, zlib, the C++ runtime, and system libraries.
- With a static-library triplet, the package libraries can be folded into the
  final executable, subject to the selected CRT/runtime policy.

Those lists are **expected closures, not acceptance evidence**. The exact
filenames and system dependencies vary by triplet. The prototype must record
the installed `bin`/`lib` set and inspect the final binary (`dumpbin
/DEPENDENTS` on Windows or `readelf -d`/`ldd` on Linux). It must copy every
non-system runtime dependency and the installed copyright notices.

## C API and custom-engine integration

Valve describes the SDK as a C library intended for custom engines,
middleware, and DAWs; the public surface is callable from any language that
can call C functions ([C API overview](https://valvesoftware.github.io/steam-audio/doc/capi/index.html)).
The custom-engine integration guide explicitly assigns engine ownership of
object lifetimes, scene/material export, thread placement, direct/indirect
mixing, and the handoff of simulation results into the audio mixer
([integration guide](https://valvesoftware.github.io/steam-audio/doc/capi/integration.html)).
This is a suitable deep boundary: Sacramento owns coordinates, lifetime,
scheduling, and evidence; a private adapter owns all `IPL*` handles and calls.

The supported integration path is:

1. Create `IPLContext` and fixed `IPLAudioSettings`.
   `STEAMAUDIO_VERSION` for 4.8.1 is `0x00040801` (`264193`), generated as
   `(major << 16) | (minor << 8) | patch`; `iplContextCreate` receives this
   compile-time version for compatibility checking
   ([version template](https://github.com/ValveSoftware/steam-audio/blob/v4.8.1/core/src/core/phonon_version.h.in)).
2. Create an `IPL_SCENETYPE_DEFAULT` scene, an `IPLStaticMesh`, triangles,
   material indices, and `IPLMaterial` values; add and commit the mesh. Scene
   geometry and the three-band absorption/transmission plus scattering model
   are defined in the [Scene API](https://valvesoftware.github.io/steam-audio/doc/capi/scene.html).
   Version 4.8.1 also documents `iplStaticMeshSetMaterial` in that API.
3. Create one simulator with `IPL_SIMULATIONFLAGS_DIRECT`, default CPU scene
   type, bounded direct-simulation inputs, and an explicit thread count. A
   broader reflection proof would additionally configure bounded
   rays/bounces/duration/order.
4. Set the scene and commit it. Create an `IPLSource` with the direct flag, add
   it, and commit. Set source coordinates/direct options with
   `iplSourceSetInputs`; set listener coordinates and reflection budget with
   `iplSimulatorSetSharedInputs`.
5. Run `iplSimulatorRunDirect`, then retrieve `IPLSimulationOutputs` with
   `iplSourceGetOutputs`. The Simulation API owns this complete
   source/listener/direct path
   ([reference](https://valvesoftware.github.io/steam-audio/doc/capi/simulation.html),
   [worked guide](https://valvesoftware.github.io/steam-audio/doc/capi/guide.html#simulation)).
6. Apply `outputs.direct` with `IPLDirectEffect`. Direct parameters cover
   distance attenuation, three-band air absorption, directivity, occlusion,
   and three-band transmission
   ([Direct Effect API](https://valvesoftware.github.io/steam-audio/doc/capi/direct-effect.html)).
7. Create the built-in `IPLHRTF` once, spatialize the direct mono signal with
   `IPLBinauralEffect`, and retain both stereo channels. The effect takes a
   listener-relative unit direction and outputs stereo
   ([Binaural Effect API](https://valvesoftware.github.io/steam-audio/doc/capi/binaural-effect.html)).
8. A broader qualification may apply `outputs.reflections` with a convolution
   `IPLReflectionEffect`; it
   produces Ambisonics, which must then be decoded (binaurally or to a speaker
   layout). The reflection IR handle returned by the normal simulator is
   intentionally opaque
   ([Reflection Effect API](https://valvesoftware.github.io/steam-audio/doc/capi/reflections-effect.html)).

No audio device is required for this sequence. Valve's getting-started sample
is itself a command-line tool that reads PCM, applies effects, and writes PCM
([Getting Started](https://valvesoftware.github.io/steam-audio/doc/capi/getting-started.html)).
The gate can generate an impulse/tone in memory and write hashes and energy
metrics instead of integrating an audio backend.

There is no persistent listener handle in this path: the listener is the
`IPLCoordinateSpace3 listener` snapshot in `IPLSimulationSharedInputs`, while a
source is an `IPLSource` with per-run `IPLSimulationInputs`. Sacramento must
therefore own listener identity, history, and snapshot timing.

## Threading and update constraints

The public contracts imply a deliberate two-domain design:

- `iplSceneCommit` cannot run concurrently with simulation. Simulator scene
  changes, probe changes, and `iplSimulatorCommit` cannot occur while any
  simulation is running
  ([Scene API](https://valvesoftware.github.io/steam-audio/doc/capi/scene.html#c.iplSceneCommit),
  [Simulation API](https://valvesoftware.github.io/steam-audio/doc/capi/simulation.html#c.iplSimulatorCommit)).
- Direct simulation must not run on the audio processing thread when occlusion
  or transmission is enabled. Reflection and pathing simulation are CPU
  intensive and should run on a separate thread so they block neither the
  audio thread nor the main update thread
  ([Simulation API](https://valvesoftware.github.io/steam-audio/doc/capi/simulation.html#c.iplSimulatorRunDirect)).
- `iplSimulatorSetSharedInputs` and `iplSourceSetInputs` may be called from
  separate direct and reflection simulation threads without synchronization
  when each call uses disjoint simulation flags; this is stated in the
  versioned [public header](https://github.com/ValveSoftware/steam-audio/blob/v4.8.1/core/src/core/phonon.h#L4175-L4190).
- The engine must implement the simulation-to-mixer handoff. Valve calls this
  the most crucial custom integration concern
  ([integration guide](https://valvesoftware.github.io/steam-audio/doc/capi/integration.html#audio-engine-integration)).
- `iplHRTFCreate` is relatively expensive and is not thread-safe; create HRTFs
  at initialization, not from the mixer callback
  ([HRTF API](https://valvesoftware.github.io/steam-audio/doc/capi/hrtf.html#c.iplHRTFCreate)).

For the gate, keep scene mutation and simulation sequential, run reflection
simulation on a worker, and process already-captured parameters offline. A
future real-time integration needs a bounded, lock-free or otherwise
audio-safe snapshot handoff; this prototype does not prove that design.

## Authoritative arrival timestamp limitation

Steam Audio 4.8.1 does **not** expose a source-event emission timestamp or a
scalar, authoritative propagation-arrival timestamp through the normal
simulator API:

- `IPLSimulationOutputs` contains only `IPLDirectEffectParams`,
  `IPLReflectionEffectParams`, and `IPLPathEffectParams`; see the exact
  [4.8.1 header](https://github.com/ValveSoftware/steam-audio/blob/v4.8.1/core/src/core/phonon.h#L4104-L4114).
- `IPLDirectEffectParams` contains gains/EQ/occlusion/transmission but no delay
  or timestamp
  ([4.8.1 header](https://github.com/ValveSoftware/steam-audio/blob/v4.8.1/core/src/core/phonon.h#L2321-L2345)).
- `IPLBinauralEffectParams::peakDelays` are left/right-ear HRTF peak delays,
  not world propagation time
  ([Binaural Effect API](https://valvesoftware.github.io/steam-audio/doc/capi/binaural-effect.html#c.IPLBinauralEffectParams)).
- The normal reflection result carries an opaque `IPLReflectionEffectIR` that
  records reflected energy over samples for filtering, but its handle is only
  passed to the reflection effect. The separately exposed advanced
  `IPLImpulseResponse` data API is inspectable, but that does not turn the
  normal simulator result into a semantic event timestamp
  ([Reflection Effect API](https://valvesoftware.github.io/steam-audio/doc/capi/reflections-effect.html),
  [Impulse Response API](https://valvesoftware.github.io/steam-audio/doc/capi/impulse-response.html)).
- `IPLReflectionEffectParams::delay` is specifically the number of samples
  after which the *parametric part* starts in hybrid reverb; it is not a
  source-to-listener delay or event timestamp
  ([4.8.1 header](https://github.com/ValveSoftware/steam-audio/blob/v4.8.1/core/src/core/phonon.h#L2494-L2533)).

**Inference:** any network/gameplay-authoritative arrival instant must remain
Sacramento-owned (for example, an explicit emission tick plus a documented
propagation model). Finding a first non-zero rendered sample would be a
renderer observation with threshold, frame, and HRTF/convolution latency—not
an authoritative timestamp. Gate 2D may prove audible delay/energy in offline
PCM, but must not feed that measurement back into authoritative simulation.

## Platform and build qualification

Valve documents prebuilt SDK support for Windows 7+ x86/x64 and Linux x86/x64
(tested on Ubuntu 18.04), with Visual Studio 2015+ on Windows and GCC 4.8+ plus
glibc 2.19+ on Linux
([Getting Started requirements](https://valvesoftware.github.io/steam-audio/doc/capi/getting-started.html#requirements)).
The source build documentation is slightly broader/older in its minimums:
CMake 3.17+, Python 3.4+, Visual Studio 2013+, or g++ 4.8+ and glibc 2.19+
([Build Instructions](https://valvesoftware.github.io/steam-audio/doc/capi/build-instructions.html#requirements)).

Important bounds:

- Valve documents native builds per platform. The official build script lists
  VS 2013/2015/2017/2019 and GCC-based Linux; it does not document a supported
  Linux-to-Windows cross build or clang-cl as an upstream guarantee.
- The pinned vcpkg port applies a Windows ARM64/Clang-related patch and accepts
  non-UWP targets, but the gate should qualify only the exact triplets it
  actually builds. For the current foundation question, native Linux x64 and
  the repository's established Windows x64 cross/toolchain path require
  independent evidence.
- The release zip contains prebuilt `phonon.dll`/`libphonon.so`, while vcpkg
  compiles the tag from source with its own dependency substitutions and
  patches. These are not interchangeable proof artifacts.

## CPU-only/offline limitations and acceptance criteria

The pinned port turns off tests, interactive tests, samples, benchmarks, AVX,
IPP, FFTS, Embree, Radeon Rays, and TrueAudio Next in its
[`portfile.cmake`](https://github.com/microsoft/vcpkg/blob/9e593bb18ea69cc5095e012465dcd675a822ed0d/ports/steam-audio/portfile.cmake).
It therefore uses open-source PFFFT, the built-in CPU ray tracer, and non-TAN
CPU reflection processing. This is a clean no-GPU seam: OpenCL devices are
only required for Radeon Rays or TAN
([Simulation settings](https://valvesoftware.github.io/steam-audio/doc/capi/simulation.html#c.IPLSimulationSettings)).

Consequences:

- Valve says IPP is optional but recommended to match the performance of its
  shipped release binaries; the vcpkg gate cannot claim release-binary or
  production performance
  ([closed-source dependency note](https://valvesoftware.github.io/steam-audio/doc/capi/build-instructions.html#closed-source-dependencies)).
- Reflection accuracy and cost trade with ray count, bounces, IR duration,
  Ambisonic order, sources, and threads. Reflection simulation is explicitly
  CPU-intensive. Use a tiny fixed scene and bounded settings.
- Parametric reverb is cheaper but cannot render individual echoes; use CPU
  convolution if the proof needs observable indirect arrival structure
  ([Reflection Effect types](https://valvesoftware.github.io/steam-audio/doc/capi/reflections-effect.html#c.IPLReflectionEffectType)).
- The API documents no random-seed control or bitwise reproducibility contract
  for ray-traced reflections. **Inference:** accept physically meaningful
  inequalities/tolerances (occluded direct energy lower than clear; reflective
  room tail energy above an absorptive case; left/right binaural response
  changes with direction), not byte equality across machines or thread counts.
- Because the port disables upstream tests and samples, a successful package
  build alone proves nothing about the required paths. The gate executable
  must call the scene/material, direct simulation, reflection simulation,
  direct effect, HRTF/binaural effect, reflection effect, and decode paths.
- Offline *execution* is viable once the binaries and data are present: the C
  API is local and processes caller-owned PCM buffers. A fresh vcpkg *build*
  is not inherently offline because the recipe fetches Steam Audio and its
  dependencies. A sealed-build claim requires a populated binary/source cache
  or mirror and a separate no-network rebuild; it is outside dependency
  qualification alone.

Recommended Gate 2D evidence:

1. exact registry/source identities and hashes above;
2. clean Linux x64 and Windows x64 builds through the pinned registry path;
3. log the compile-time `STEAMAUDIO_VERSION`, require successful context
   creation, and hash the loaded library against the exact build output.
   Context creation alone proves only API compatibility: the 4.8.1
   implementation accepts the same major and a caller minor no newer than the
   library, and ignores the patch component in this check
   ([implementation](https://github.com/ValveSoftware/steam-audio/blob/v4.8.1/core/src/core/api_context.cpp#L29-L36));
4. clear versus occluded direct metrics, plus a material-dependent reflection
   tail metric using fixed geometry and tolerances;
5. non-identical, finite left/right binaural PCM for an off-axis source;
6. finite non-zero indirect PCM after Ambisonic decode;
7. wall-clock simulation time recorded as evidence, not a production budget;
8. native dependency inspection and bundled license/notice inventory;
9. explicit `UNPROVED` statements for authoritative arrival timestamps,
   deterministic reflection bytes, real-time audio-thread handoff,
   production-scale performance, and deployment outside exercised triplets.
