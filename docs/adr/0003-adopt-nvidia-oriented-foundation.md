# Adopt a narrow NVIDIA-oriented Sacramento foundation

Status: Proposed pending the composed-foundation prototype in issue #11

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
tests, and offline release/acceptance use. C++ dependencies, including any
custom packaging required by Falcor or an NVIDIA SDK, enter through vcpkg; a
dependency's own downloader or package manager must not become a second
Sacramento dependency manager.

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
