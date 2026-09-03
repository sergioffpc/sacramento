# Architecture specification: NVIDIA-oriented foundation

Status: Accepted as a conditional architectural direction; production
dependency admission remains blocked

Purpose: Record the selected narrow technology foundation and its qualification
conditions.

Scope: Initial C++ runtime and cooker technologies, dependency seams, and
production-admission boundaries.

Intended readers: Architects, implementers, build operators, dependency
reviewers, and verification authors.

Prerequisites: ADR-0001, ADR-0002, and the approved functional,
non-functional, toolchain, and verification baselines.

Canonical information owner: Project owner.

Sacramento will own a narrow C++23 foundation whose interfaces use Sacramento
types and whose implementations are composed from qualified third-party
libraries. The Trainee Client is deliberately NVIDIA-oriented: Flecs provides
the ECS, NVIDIA Falcor provides rendering through Vulkan rather than DirectX
12, Slang is the shading language and shader toolchain targeting Vulkan/SPIR-V,
NVIDIA PhysX provides physics, GameNetworkingSockets provides the network
transport, and Steam Audio provides acoustic propagation and spatialization. A
Python 3 cooker uses Assimp only to import source assets and emits versioned
Sacramento runtime formats; Assimp and source-format parsing are not linked into
runtime targets. Tracy provides diagnostic profiling, structured Sacramento
logs provide runtime diagnostics and required observability signals, and
OpenTelemetry is not part of this baseline.

## Interface and dependency rules

- Product modules depend on Sacramento interfaces, not directly on third-party
  interfaces. Public headers, persistent formats, network messages, and ECS
  component schemas do not expose Flecs, Falcor, PhysX,
  GameNetworkingSockets, Steam Audio, Assimp, or Tracy types.
- The Session Authority remains headless on Debian. It uses the shared world,
  authoritative physics, networking, logging, and applicable profiling modules;
  Falcor and client audio are not Session Authority dependencies.
- Falcor is the rendering implementation, not the application framework or
  runtime asset importer. Its scene loading and Python scripting do not define
  Sacramento runtime interfaces. Optional NVIDIA RTX SDKs are admitted
  individually rather than implicitly through Falcor.
- Vulkan is the sole initial production graphics interface, and Slang is the
  sole authored shading language and shader toolchain. DirectX 12 is outside the
  initial baseline. Shader sources and compiled SPIR-V artefacts remain subject
  to Sacramento content identity, versioning, reproducibility, and admission
  rules.
- GameNetworkingSockets is transport only. Sacramento owns message schemas,
  replication, authority, admission, recovery, and gameplay semantics.
- Steam Audio implements acoustic propagation and spatialization only. It does
  not define Blast Overpressure, physical force, or authoritative simulation
  outcomes.
- Tracy instrumentation is compiled and enabled only for an admitted diagnostic
  profile. It is disabled whenever the `CoreOnly` observability level or another
  acceptance profile forbids optional signals. Logging remains available
  independently of Tracy.

## Qualification and admission

This decision selects the stack but does not by itself qualify a release or add
a dependency to a product target. Each exact direct and transitive dependency
version must satisfy the C++ engineering baseline before admission, including
source identity and hash, license review, vulnerability disposition, selected
features, ABI inputs, both applicable Clang platform builds, native runtime
tests, and offline release/acceptance use. C++ dependencies enter product
builds through vcpkg. Falcor's pinned Packman closure is the sole exception: it
is permitted only inside an immutable, integrity-checked, offline vendor
capsule exposed to Sacramento through vcpkg and maintained with the minimum
Vulkan-only patch set. Packman is not a general Sacramento dependency manager
and must not run during offline product builds or acceptance.

The first admitted adapter for each library must demonstrate the smallest
interface needed by a representative Sacramento scenario. Additional library
features remain excluded until a concrete requirement and qualification
evidence justify them. This preserves the leverage and locality of deep
Sacramento modules while containing vendor coupling at their internal seams.

This decision traces to `CONSTRAINT-CPP-VERSION-001`,
`CONSTRAINT-CPP-TOOLCHAIN-001`, `CONSTRAINT-CLIENT-OS-001`,
`CONSTRAINT-AUTHORITY-OS-001`, `CONSTRAINT-PLATFORM-MATRIX-001`,
`PREFERENCE-PLATFORM-PARITY-001`, `REQ-CONTENT-PROCESSING-GATE-001`,
`REQ-CONTENT-PROCESSING-RECORD-001`, `NFR-OBSERVABILITY-CORE-001`, and
`NFR-OBSERVABILITY-INTEGRITY-001`.

## Consequences

Replacing a selected library does not change product-facing interfaces or
stored data by default, but Sacramento does not create speculative adapters:
the selected library is the sole production adapter until a real second
implementation is required. The NVIDIA orientation permits NVIDIA-specific
rendering investment on the Windows client without making rendering a
dependency of the Debian authority or weakening shared-code platform parity.

Gate 2G established conditional viability, not production admission. Its
prototype identities and evidence are retained in
`prototypes/composed_foundation_gate2g/synthesis.json`; every selected item
remains `prototype_evidence_only` until separately admitted. The following five
exceptions block production admission:

- `EXC-FALCOR-VENDOR-CAPSULE`: Sacramento accepts ownership of the immutable
  offline Falcor capsule, its Vulkan-only patches, and its qualification. If
  measured upkeep cannot fit the two-generalist ceiling, Falcor is the first
  selected mechanism to replace; Sacramento's rendering interface and content
  contract remain unchanged.
- `EXC-BUILD-TOOL-VERSIONS`: the engineering baseline and build root must move
  to one sealed CMake 4.4.0 identity, matching the selected pinned vcpkg rather
  than retaining the conflicting CMake 4.2.3 identity. Every retained host
  helper, including GNU Make, must also be identified and sealed.
- `EXC-CROSS-VCPKG-PROFILE`: production admission must provide one supported
  cross-vcpkg profile covering find roots, Release `try_compile`, CRT, C++23,
  and reproducible `clang-cl` path maps.
- `EXC-VENDOR-SUPPORT-MATRIX`: Sacramento accepts responsibility for qualifying
  the selected Clang 22/Debian 13 PhysX and Linux-hosted `clang-cl` Steam Audio
  and Tracy paths even where the vendors do not claim them. Failure to qualify
  a path requires selecting a supported version or replacing that mechanism;
  it does not permit weakening the platform or toolchain constraints.
- `EXC-GNS-CRYPTO-BACKENDS`: the initial foundation uses the platform-native
  split of OpenSSL on Debian and BCrypt on Windows, and both closures require
  independent qualification. These transport crypto mechanisms do not provide
  or replace the Sacramento-owned AUTH Protected Exchange.

The following obligations remain explicitly unproved and therefore cannot be
claimed as consequences of this decision:

- complete Reference Personnel Recovery Scenario vertical replay;
- AUTH, Admission, offline trust, durable audit commit, and Technical Removal;
- Controlled LAN loss, congestion, disconnection, and 16-client stress;
- approved 16.67 ms presentation and 100 ms authoritative-action workloads;
- Representative Evaluator visual and acoustic validity and peak coverage;
- real-time audio/device path, reflections, pathing, and stress behavior;
- live Tracy capture, profiling overhead, and complete production
  observability transport;
- candidate-wide vulnerability disposition, consolidated SBOM, and offline
  dependency reconstruction;
- one patch-version upgrade with measured adapter churn; and
- demonstrated ongoing maintenance within two concurrent human generalists.

Production dependency admission remains blocked until owners and acceptance
evidence exist for all five exceptions and the applicable dependency
qualification obligations. The other unproved obligations remain explicit
product-architecture and acceptance work; this decision neither discharges
them nor makes them all prerequisites for admitting an unrelated dependency.
The mandatory two-generalist ceiling is not traded away by accepting this
direction: if the integrated build, upgrade, qualification, or operational
burden cannot meet it, the responsible implementation mechanism must be
simplified or replaced behind the Sacramento interface.
