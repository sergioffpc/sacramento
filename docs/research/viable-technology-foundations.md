# Viable Technology Foundations for the Initial Training Simulation

Research date: 2026-09-01

## Table of contents

- [Executive finding](#executive-finding)
- [Evaluation boundary](#evaluation-boundary)
- [Non-negotiable feasibility gates](#non-negotiable-feasibility-gates)
- [Strategy landscape](#strategy-landscape)
- [Candidate assessment](#candidate-assessment)
- [Cross-cutting gaps no foundation closes](#cross-cutting-gaps-no-foundation-closes)
- [Evidence required before selection](#evidence-required-before-selection)
- [Decision implications](#decision-implications)
- [Primary sources](#primary-sources)

## Executive finding

Three strategies remain distinguishable, but they are not equally ready for a
selection decision:

1. A **narrow Sacramento-owned foundation composed from qualified libraries**
   is feasible under the approved build topology. SDL 3, bgfx, Jolt Physics,
   GameNetworkingSockets, Steam Audio, Assimp, and OpenTelemetry C++ demonstrate
   that permissively licensed, Windows-and-Linux-capable building blocks exist.
   They do not form an engine by themselves, and every one remains subject to
   pinning, licence review, cross-build proof, performance measurement, and an
   adapter that keeps canonical domain rules under Sacramento ownership.
2. **Godot 4.7.2 used as a replaceable client/runtime shell**, with the
   authoritative Sacramento core outside Godot's object model and connected
   through GDExtension's C ABI, is conditionally feasible. Godot directly
   supports Windows, Linux, dedicated headless exports, and C++ extensions, but
   its official Linux-to-Windows engine cross-build uses MinGW rather than the
   approved MSVC ABI/sysroot. A source-integrated Godot fork therefore conflicts
   with ADR-0002 unless the decision changes; a stock runtime plus separately
   cross-built GDExtension needs a runnable ABI and packaging proof.
3. **Unreal Engine 5.8 and O3DE 26.05 as integrated whole-engine foundations**
   are not viable under the current baseline without explicit exceptions or
   new proof. Both offer authoritative multiplayer and dedicated-server
   machinery, but their supported build paths do not match Sacramento's
   Linux-hosted Windows `clang-cl` topology. Unreal additionally requires an
   Epic licence decision and defaults to C++20/UE coding idioms; O3DE officially
   supports Visual Studio on Windows and brings a broad third-party/licence and
   maintenance surface.

A from-scratch renderer, physics engine, spatial-acoustics engine, transport,
and content stack is not a credible fourth strategy for two generalists. The
viable project-specific interpretation is a small authoritative core plus
qualified external libraries behind Sacramento-owned seams.

This is a landscape result, not a winner. The architecture-driver set must
first establish weighted decision criteria, and two executable proofs are
needed: one for the composed foundation and one for Godot as an isolated shell.

## Evaluation boundary

The comparison treats the **Training Simulation** as the product boundary and
the **Simulation Engine** as its need-specific internal foundation. It evaluates
the first Desktop Mode and Session Authority baseline only. Virtual-Reality
Mode matters only where an early choice would make a later input or rendering
adapter prohibitively difficult.

The Reference Personnel Recovery Scenario is the end-to-end thread. A
foundation must be capable of carrying its Map and Scenario through offline
admission, loading one canonical state on the Session Authority, accepting
Trainee actions, advancing authoritative simulated time, publishing results to
all clients, presenting tactically valid visual and acoustic output, retaining
AUTH and operational records, and replaying the same admitted input script for
verification.

No external engine's marketing claim is treated as evidence that Sacramento's
Approved Profiles, catalogues, authority rules, timing, or verification
obligations are satisfied.

## Non-negotiable feasibility gates

### Build and platform gate

First-party production code must be standard C++23. ADR-0001 requires Clang on
both product targets, and ADR-0002 requires Windows C++ artefacts to be produced
from the pinned Ubuntu build root using Linux-hosted `clang-cl`, the MSVC
STL/CRT and Windows SDK sysroot, and `lld-link`. Native Windows remains the
runtime, performance, signing, and acceptance gate. A candidate is not feasible
merely because it can produce some Windows and Linux binary.

This gate permits a prebuilt third-party runtime only if dependency governance
accepts it and every first-party binary can still be built, identified, tested,
and packaged by the approved topology. Any engine modification that requires
rebuilding the Windows runtime with MinGW, MSVC, or a Windows-hosted build is an
architecture exception, not routine integration.

### Runtime and verification gate

The Session Authority owns canonical state and serves at most 16 Trainees on a
dedicated Debian 13 host over a Controlled LAN. Under the Stress profile, 99%
of valid actions must reach their first authoritative result at every client
within 100 ms. The rendered Desktop Mode client must keep 99% of final-image
intervals within 16.67 ms and every interval within 100 ms. Acceptance replays
must use an exact deterministic action script and exact build, configuration,
content, and profile identities.

The gate therefore requires explicit fixed simulation time, deterministic
ordering at canonical seams, versioned serialization, a headless authority,
independent client presentation, and instrumentation that survives production
builds. General-purpose engine replay or replication is useful infrastructure,
but it is not automatically Sacramento deterministic replay.

### Fidelity and content gate

Rendering, physical effects, ballistics, injury, Fire, Obscurants, and Acoustic
Propagation are governed by admitted profiles and catalogues rather than engine
defaults. Blender is the canonical graphical authoring environment for Map
geometry, materials, lighting, collision definitions, anchors, and regions.
Runtime hosts must not require Blender, required content is installed before
connection, and matching identifiers, formats, and integrity are confirmed
before `Ready`.

A candidate must allow an automated Blender-to-admitted-runtime pipeline and
must let Sacramento replace, constrain, or bypass default physics, acoustic,
networking, and content behavior. An engine editor may assist inspection or
configuration, but it cannot silently become the canonical graphical Map or
Scenario editor.

### Security, observability, and maintenance gate

Identity, Admission, continuity, and AUTH audit integrity are offline-first
product responsibilities. Core observability signals must exist continuously
in test and production, avoid sensitive/gameplay payloads, preserve exact
timestamp and correlation semantics, and support the approved retention and
alerting obligations. No candidate examined supplies those domain semantics.

Ongoing first-party engineering and maintenance is limited to two concurrent
generalists. Dependency count alone is therefore a poor proxy for cost: a whole
engine has one top-level version but a large upgrade and integration surface;
a composition has several versions but can keep each adapter narrow. Selection
must compare measured upgrade work, build time, patch burden, diagnostics, and
the amount of Sacramento logic coupled to vendor object models.

## Strategy landscape

| Strategy | Baseline feasibility | Main leverage | Main liability |
| --- | --- | --- | --- |
| Narrow Sacramento core plus libraries | Feasible, pending two-platform proof | Exact authority, determinism, data, and verification seams; direct fit with approved CMake/Clang topology | Sacramento must integrate rendering, physics, audio, networking, resources, lifecycle, and tooling |
| Existing engine as isolated shell | Conditionally feasible with Godot | Mature renderer, input, resource lifecycle, import and headless runtime while the domain core stays portable | ABI, packaging, timing, editor bypass, duplicated world representation, and engine-upgrade proof |
| Existing engine as architecture | Baseline conflict for Unreal/O3DE | Maximum integrated tooling, rendering, physics, assets, profiling, and multiplayer infrastructure | Build/licence exceptions, engine-native object model, large maintenance surface, difficult deterministic evidence |
| From-scratch complete engine | Not credible for this baseline | Maximum control | Reimplements multiple specialist systems under a two-generalist limit |

The key distinction is ownership. Sacramento must own the canonical state
model, admission rules, profile application, event ordering, serialization,
content admission, and acceptance signal meanings in every strategy. The
candidate may own presentation and commodity mechanisms only through explicit
adapters.

## Candidate assessment

### Composed project-specific foundation

The following is a feasibility palette, not a proposed dependency lock:

| Concern | Current primary-source evidence | Consequence for Sacramento |
| --- | --- | --- |
| Window, input, devices, basic audio and platform access | SDL 3 is written in C, works natively with C++, officially supports Windows and Linux, and uses the zlib licence. It exposes low-level audio, input and graphics-hardware access rather than a full engine. [SDL overview](https://wiki.libsdl.org/SDL3/FrontPage), [platform list](https://wiki.libsdl.org/SDL3/README-platforms), [licensing](https://wiki.libsdl.org/SDL3/FAQLicensing) | Strong platform adapter candidate; it does not solve renderer architecture, spatial acoustics, canonical input ordering, or headless authority lifecycle. |
| Rendering abstraction | bgfx describes itself as a "Bring Your Own Engine/Framework" rendering library, supports Direct3D 12 and Vulkan, Windows and Linux, and Clang 11+. It uses BSD-2-Clause terms. [bgfx repository](https://github.com/bkaradzic/bgfx) | Plausible replaceable renderer seam. Visual validity, lighting/profile fidelity, shader pipeline, capture, and 16.67 ms evidence remain Sacramento work. Its maintainer offers no support or maintenance guarantee, so upgrade ownership must be budgeted. [maintainer statement](https://github.com/bkaradzic/bgfx/discussions/2708) |
| Rigid-body physics and collision | Jolt supports Windows and Linux, Clang 16+, C++17, CMake integration, and the MIT licence. Its cross-platform deterministic option claims tested determinism across compilers, OSes and architectures with an approximately 8% cost, but documents non-deterministic broad-phase queries and strict same-source/define conditions. [Jolt repository](https://github.com/jrouwe/JoltPhysics), [architecture and determinism](https://github.com/jrouwe/JoltPhysics/blob/master/Docs/Architecture.md) | A serious candidate for bounded physical behavior, not proof of Sacramento determinism. Query ordering, multithreading, floating-point policy, profile tolerances, rollback/state capture, and authoritative-only execution need a dedicated proof. |
| Network transport | GameNetworkingSockets supplies reliable and unreliable messages over UDP, fragmentation, per-packet encryption and cross-platform C/C++ APIs under BSD-3-Clause, but explicitly omits entity serialization, delta encoding, and compression. [GameNetworkingSockets repository](https://github.com/ValveSoftware/GameNetworkingSockets) | Suitable transport candidate behind a protocol seam. Sacramento must still own peer authentication/binding, Admission, schemas, replication policy, rate/order rules, continuity, failure handling, and audit commits. Built-in encryption is not an AUTH architecture. |
| Spatial audio and propagation | Steam Audio 4.8.1 is Apache-2.0, supports Windows and Linux, exposes a C API, HRTF binaural rendering, occlusion, reflections, pathing and baked propagation, and documents custom-engine integration. [repository](https://github.com/ValveSoftware/steam-audio), [C API](https://valvesoftware.github.io/steam-audio/doc/capi/index.html), [integration](https://valvesoftware.github.io/steam-audio/doc/capi/integration.html) | The closest identified component to the Acoustic Propagation shape. Its official compiler table names Visual Studio on Windows and GCC on Linux, so the distributed binaries and source build must undergo ABI/toolchain review. Acoustic Profile timing, authoritative arrival, omission limits, material coverage and Stress performance still require proof. |
| Content import | Assimp 6.0.5 uses CMake, exposes C and C++ APIs, imports glTF 2.0 and many other formats, and uses modified BSD-3-Clause terms. It deprecates direct `.blend` import because that undocumented format is too costly to maintain. [repository](https://github.com/assimp/assimp), [format status](https://github.com/assimp/assimp/blob/master/doc/Fileformats.md), [licence](https://github.com/assimp/assimp/blob/master/LICENSE) | Supports the required separation: Blender exports a documented interchange artifact, then a Sacramento tool validates and cooks it. It does not preserve Sacramento anchors, regions, materials, catalogues or integrity by default; schema and round-trip fixtures remain first-party work. |
| Operational signals | OpenTelemetry C++ reports stable traces, metrics, and logs. [C++ status](https://opentelemetry.io/docs/languages/cpp/), [overall status](https://opentelemetry.io/status/) | A viable transport/SDK candidate for operational signals. Sacramento must own the versioned Observability Contract, loss accounting, local buffering, retention, alerting, clock evidence, and Controlled-LAN deployment. |

This palette covers commodity mechanisms while leaving a deliberately small
Sacramento foundation responsible for:

- canonical state, fixed simulated time, event ordering and deterministic
  replay;
- schema-versioned client protocol and stable serialization;
- Profile and catalogue evaluation, content admission and integrity;
- identity, Admission, continuity and AUTH audit commit semantics;
- renderer/physics/acoustics/network adapters and lifecycle;
- acceptance instrumentation and evidence correlation; and
- separate Windows Client and Debian Session Authority compositions.

That responsibility is substantial but aligned with the product's unusual
requirements. The main unknown is whether two generalists can sustain the
integration surface. A vertical proof must measure build, upgrade, debugging
and operational work as well as frame/tick performance.

### Godot 4.7.2 as an isolated shell

Godot 4.7.2 is the current supported stable release as of the research date.
[Godot release archive](https://godotengine.org/download/archive/) The engine is
MIT-licensed, exports Windows and Linux projects, and can run an export template
as a dedicated server using the headless display server and dummy audio driver.
Dedicated export can strip client-only textures and materials.
[Dedicated-server export](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_dedicated_servers.html)

Godot provides two relevant native integration modes. A source module has deep
engine access but requires rebuilding the engine. GDExtension loads a native
shared library through a Godot-specific C ABI without rebuilding Godot;
official guidance says extension libraries may use any C++ version or compiler
brand/version because of that bridge.
[godot-cpp comparison](https://docs.godotengine.org/en/4.7/tutorials/scripting/cpp/about_godot_cpp.html),
[language interoperability](https://docs.godotengine.org/en/4.7/getting_started/step_by_step/scripting_languages.html)

The C ABI is the only promising baseline-preserving seam. Godot's official
Linux/macOS-to-Windows source build uses MinGW-w64 or MinGW-LLVM, which does not
match ADR-0002's MSVC ABI/sysroot. [Godot Windows compilation](https://docs.godotengine.org/en/4.7/engine_details/development/compiling/compiling_for_windows.html)
The Debian source build supports Clang, but the docs still recommend GCC for
production because official builds exercise it more rigorously.
[Godot Linux compilation](https://docs.godotengine.org/en/4.7/engine_details/development/compiling/compiling_for_linuxbsd.html)

Consequently:

- a custom Godot fork or source module is not baseline-compatible;
- a pinned stock Godot runtime plus an independently built Sacramento
  GDExtension remains plausible;
- the canonical simulation must not depend on Godot SceneTree traversal,
  dictionary/hash iteration, implicit physics ordering, wall time, or frame
  callbacks;
- Godot's fixed physics tick and render interpolation may serve presentation,
  but its own guidance says multiplayer timing may need custom interpolation;
  [physics interpolation](https://docs.godotengine.org/en/4.7/tutorials/physics/interpolation/physics_interpolation_introduction.html)
- Map import must be automated from Blender and prevent the Godot editor from
  becoming a second graphical source of truth; and
- native extension crash containment, sanitizers, symbols, package identity,
  headless operation and engine upgrades require evidence.

This is a **client-shell candidate**, not evidence for placing canonical domain
state inside Godot. It is attractive only if the shell removes more rendering,
input, resource and packaging burden than the adapter and upgrade seam adds.

### Unreal Engine 5.8

Unreal 5.8 is current as of June 2026. It supplies an authoritative server model,
replication, headless dedicated-server targets, rendering, Chaos physics,
profiling, replay, content pipelines and mature client tooling.
[release](https://www.unrealengine.com/news/unreal-engine-5-8-is-now-available),
[networking model](https://dev.epicgames.com/documentation/unreal-engine/networking-overview-for-unreal-engine),
[dedicated server](https://dev.epicgames.com/documentation/unreal-engine/setting-up-dedicated-servers-in-unreal-engine),
[physics](https://dev.epicgames.com/documentation/unreal-engine/physics-in-unreal-engine)

Those capabilities do not close the baseline gates:

- Unreal supports Clang for Windows, but its supported workflow is
  Windows-hosted and still selects MSVC toolchain inputs. Its Linux
  cross-compilation workflow runs from Windows to Linux, not from Linux to
  Windows. [Windows Clang](https://dev.epicgames.com/documentation/en-us/unreal-engine/use-clang-to-build-microsoft-platforms-in-unreal-engine),
  [Linux requirements](https://dev.epicgames.com/documentation/unreal-engine/linux-development-requirements-for-unreal-engine)
- Unreal defaults to and requires at least C++20, uses its own coding and
  container idioms, and does not establish that a complete first-party module
  can use the exact Sacramento C++23/style/toolchain profile.
  [Epic C++ standard](https://dev.epicgames.com/documentation/unreal-engine/epic-cplusplus-coding-standard-for-unreal-engine)
- Its replication docs describe client-side visual, audio and physics systems
  as separate approximate simulations; Sacramento still needs exact canonical
  results and profile-governed presentation evidence.
  [networking overview](https://dev.epicgames.com/documentation/unreal-engine/networking-overview-for-unreal-engine)
- Dedicated servers require a C++ project and source build, expanding the
  patch/build burden. [dedicated-server prerequisites](https://dev.epicgames.com/documentation/unreal-engine/setting-up-dedicated-servers-in-unreal-engine)
- The current EULA governs access, seats and distribution. This is a
  source-available/commercial dependency that requires the project's specific
  approval before selection. [Unreal Engine EULA](https://www.unrealengine.com/eula/unreal)

Unreal is therefore a technically capable counterfactual, not a
baseline-compatible candidate. Reopening it would require an explicit decision
to change the build topology and approve commercial/source-available terms,
followed by a proof of C++23 module isolation, Debian 13 server packaging,
Blender-only Map authority, deterministic acceptance replay and two-person
upgrade cost.

### Open 3D Engine 26.05

O3DE 26.05 is current as of May 2026. It offers client, server and unified
launchers; its dedicated server disables rendering and audio; its Multiplayer
Gem supports entity-based asynchronous networking and separate client/server
logic; and it has a CMake-based Gem model and asset pipeline.
[release status](https://docs.o3de.org/docs/release-notes/),
[runtime concepts](https://docs.o3de.org/docs/welcome-guide/key-concepts/),
[client/server separation](https://docs.o3de.org/docs/user-guide/networking/multiplayer/code_separation/),
[multiplayer framework](https://docs.o3de.org/docs/user-guide/networking/multiplayer/)

O3DE's default licence is Apache-2.0 with an MIT option, but its own licence
notice warns that third-party materials have separate terms, including some
copyleft components such as Qt under LGPLv3. Every enabled Gem and package
would need inventory and approval. [O3DE licence](https://github.com/o3de/o3de/blob/development/LICENSE.txt)

The primary blocker is build compatibility. O3DE's supported compiler table
lists Visual Studio for Windows and Clang/LLVM for Linux, while Sacramento
requires the same Ubuntu-hosted Clang architecture to produce Windows and
Debian product artefacts. [supported toolchains](https://docs.o3de.org/docs/user-guide/build/configure-and-build/)
The documented source build also needs roughly 100 GB and two GB of RAM per
build thread before project-specific assets and caches, which is a concrete
maintenance/CI cost. [system requirements](https://docs.o3de.org/docs/welcome-guide/requirements/)

O3DE is therefore not baseline-compatible as an integrated engine. An
unsupported Windows `clang-cl` port could be researched, but maintaining such
a port would undermine the two-generalist constraint unless upstream formally
supports it. Its feature breadth does not justify a prototype until the project
owner deliberately reopens the toolchain decision.

## Cross-cutting gaps no foundation closes

Every surviving strategy still needs architectural decisions for:

- **Authority and time:** one canonical event model, fixed simulated-time
  progression, total ordering, overload behavior, rollback/recovery boundaries,
  and client interpolation that cannot alter authoritative outcomes.
- **State and protocol:** versioned canonical serialization, relevance and
  replication rules, content/profile identity, compatibility, reconnect state,
  and deterministic acceptance replay independent of packet timing.
- **Physical evidence:** which outcomes use profile tables, analytic models,
  collision/rigid-body libraries, or bounded stochastic sampling; where
  floating-point tolerances apply; and what exact state is retained for replay.
- **Acoustic authority:** whether the Session Authority publishes source/path
  events or resolved receiver outputs, how arrival time is represented, and how
  clients render HRTF/reflection results without violating authoritative order.
- **Content admission:** one versioned intermediate format from Blender,
  deterministic cook and validation, stable Map-owned identities, dependency
  closure, install manifests, and no runtime/editor dependency.
- **AUTH and persistence:** process boundaries, secret/data inventory,
  protected exchanges, audit commit atomicity, checkpoints, offline trust data,
  expiry and crash recovery.
- **Observability:** local signal buffering, loss accounting, clock-offset
  evidence, collection and retention on a Controlled LAN, external readiness,
  and production/acceptance parity.
- **Failure containment:** renderer/audio/device loss, malformed content or
  packets, stalled workers, persistence failure, shutdown, and restart without
  corrupting canonical or audit state.

These are the reasons selection must be architecture-led. Choosing an engine
first would merely hide them inside defaults that do not carry Sacramento's
requirement identifiers or verification semantics.

## Evidence required before selection

### Proof A: composed-foundation spine

Build a throwaway, non-production vertical slice using the approved root CMake
and toolchains. It should:

1. cross-build one Windows Desktop Mode shell and one Debian headless Session
   Authority from Ubuntu;
2. load one cooked Blender-origin Map fragment with a stable anchor, material,
   collision and content-integrity identity;
3. connect one rendered and multiple synthetic clients through a versioned
   protocol;
4. advance a fixed canonical tick, apply one representative action and one
   physical interaction, and reproduce a state digest from a recorded script;
5. present one spatial sound with an authoritative arrival timestamp;
6. emit the applicable core observability identities and correlations; and
7. report build size/time, adapter code, update steps, frame/tick timing and
   unsupported toolchain patches.

The proof should test only the smallest candidate set needed to answer the
foundation question. It must not become retained production architecture.

### Proof B: Godot shell seam

Using pinned Godot 4.7.2 stock export templates, prove that an independently
cross-built C++23 GDExtension using the approved Windows `clang-cl` sysroot and
Debian Clang profile can:

1. load and execute on native Windows and Debian without rebuilding Godot;
2. keep canonical state in one engine-independent library with no SceneTree or
   Godot container types at its public boundary;
3. run the Debian export headlessly and keep client-only dependencies absent;
4. drive Windows rendering and audio from immutable canonical snapshots while
   preserving fixed tick/render separation;
5. import the same Blender-origin fixture without manual graphical edits in the
   Godot editor;
6. produce symbols, sanitizer evidence, crash diagnostics and exact package
   identities; and
7. upgrade to the next pinned Godot patch with measured adapter changes.

Failure of the approved cross-build/ABI step eliminates this candidate without
requiring a larger prototype.

### Selection evidence

After the architecture-driver set is approved, score both proofs against:

- training validity and safety, security/audit integrity, canonical consistency
  and recovery in the approved quality order;
- the 100 ms authoritative-response and 16.67/100 ms presentation thresholds;
- deterministic replay and obligation-level observability;
- Blender-only graphical Map authority and offline content admission;
- exact Windows/Debian build, packaging and native acceptance paths;
- first-party lines and modules coupled to the candidate;
- clean-build and incremental-build cost;
- one patch-version upgrade effort and dependency/licence inventory size; and
- credible ongoing operation by two generalists.

Do not combine best results from different candidates. Each candidate must
complete one coherent end-to-end slice with its actual dependency graph.

## Decision implications

The research narrows the next decision frontier:

1. Resolve the architecture-driver ticket and turn its requirements into a
   weighted, traceable selection rubric.
2. Run the composed-foundation and Godot-shell proofs in parallel after that
   rubric fixes their acceptance observations.
3. Select between those two strategies using the proof records. Record the
   chosen ownership boundary, rejected alternative, dependency policy,
   consequences and upgrade trigger as architecture decisions.
4. Do not prototype Unreal or O3DE unless the project owner first decides that
   changing ADR-0002 and, for Unreal, approving commercial/source-available
   terms is an acceptable possibility.
5. After foundation selection, open dependent decisions for authoritative
   runtime/state, concurrency, content/data, AUTH/persistence, deployment,
   observability and verification seams. The foundation does not decide those
   automatically.

## Primary sources

All external factual claims above link to the owner of the relevant software:
official project documentation, official repositories, release records,
licences, or source-maintainer statements. Sources were checked on
2026-09-01. Version-specific claims refer to Godot 4.7.2, Unreal Engine 5.8,
O3DE 26.05, Steam Audio 4.8.1, and Assimp 6.0.5 as current on that date.
