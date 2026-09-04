# C++ Engineering Baseline

Status: Approved decision; executable configuration update pending

Approval: Project owner, 2026-09-04

Review: Completed and confirmed by the project owner, 2026-09-04

Baseline identifier: `CPP-ENGINEERING-BASELINE-004`

Supersedes: `CPP-ENGINEERING-BASELINE-003`

Purpose: Define the complete first-party C++ engineering rules, toolchain,
build, dependency, verification, hardening, and release-quality baseline for
the Training Simulation and Simulation Engine.

Scope: Every first-party C++ source, header, test, benchmark, fuzzer, generated
source producer, CMake definition, dependency declaration, C++ build, and C++
release or acceptance artefact.

Intended readers: Project owner, architects, implementers, reviewers,
verification authors, build operators, and release operators.

Prerequisites: [Training Simulation context](../../CONTEXT.md),
[initial requirements](../requirements/training-simulation-initial-requirements.md),
[non-functional requirements](../requirements/training-simulation-non-functional-requirements.md),
[reference hardware profiles](../requirements/training-simulation-reference-hardware-profiles.md),
[verification plan](../requirements/training-simulation-verification-plan.md),
[C++ engineering research](../research/cpp-engineering-toolchain-and-quality-guidance.md),
[Clang-only ADR](../adr/0001-use-clang-only-for-cpp.md),
[Ubuntu Windows cross-compilation ADR](../adr/0002-cross-compile-windows-from-ubuntu-with-clang.md).

Canonical information owner and approver: Project owner.

Normative effect: This document is the Project C++ Style Profile, C++ toolchain
profile, build policy, and automatic-quality-gate policy required by the initial
requirements. Its approval records engineering decisions. Toolchain readiness
and the admission gates for real product targets are described in
[Readiness and change control](#readiness-and-change-control).

Operational readiness note: the current machine-readable C++ configuration
artifacts still identify `CPP-ENGINEERING-BASELINE-003`. This documentation-only
decision does not update them. `CPP-ENGINEERING-BASELINE-004` is not
operationally ready until those artifacts and their applicable gates implement
and verify the Measured Real-Time Hot Loop rule.

## Table of contents

- [Normative language and precedence](#normative-language-and-precedence)
- [Baseline stack](#baseline-stack)
- [Toolchain inventory](#toolchain-inventory)
- [Language and portability](#language-and-portability)
- [Project C++ Style Profile](#project-c-style-profile)
- [Build system](#build-system)
- [Dependencies](#dependencies)
- [Tests, fuzzing, coverage, and performance](#tests-fuzzing-coverage-and-performance)
- [Diagnostics and static analysis](#diagnostics-and-static-analysis)
- [Sanitizers and hardening](#sanitizers-and-hardening)
- [Continuous integration and quality gates](#continuous-integration-and-quality-gates)
- [Reproducibility and release evidence](#reproducibility-and-release-evidence)
- [Bootstrap and developer workflow](#bootstrap-and-developer-workflow)
- [Exceptions](#exceptions)
- [Requirement traceability](#requirement-traceability)
- [Readiness and change control](#readiness-and-change-control)

## Normative language and precedence

`MUST`, `MUST NOT`, `SHOULD`, `SHOULD NOT`, and `MAY` are normative. When rules
conflict, apply this precedence:

1. approved Sacramento requirements and canonical domain vocabulary;
2. this baseline and its current approved exception records;
3. repository-owned executable configurations;
4. formatter output for formatting it controls.

The Google C++ Style Guide informed this profile but is not normative. Every
adopted rule is stated here; a live external guide is never required to determine
compliance. C++ Core Guidelines checks are used only where this profile adopts
the underlying rule.

First-party code is code owned and maintained by this project. Third-party and
generated files MUST be listed in explicit inventories before exclusion from a
first-party gate. A diagnostic in first-party code remains first-party even when
it involves a third-party API.

## Baseline stack

| Concern | Approved decision |
| --- | --- |
| Language | Strict standard C++23 with an approved feature allowlist |
| Compiler | Clang only: Linux-hosted clang-cl for the Windows target and Clang for the Debian target |
| Build host | Hash-pinned Ubuntu 26.04 LTS build root |
| Build definition | Target-based CMake |
| Build executor | Ninja single-config |
| Build interface | Checked-in CMake configure, build, test, and workflow presets |
| Compiler cache | Local sccache only |
| Dependencies | vcpkg manifest mode with local binary cache only |
| Unit/component/integration tests | GoogleTest and limited GoogleMock through CTest |
| Microbenchmarks | Google Benchmark |
| Fuzzing | libFuzzer, primarily on Debian |
| Formatting and analysis | clang-format, clang-tidy, Clang diagnostics, CodeQL |
| Dynamic correctness | ASan, UBSan, TSan, and conditionally MSan |
| Coverage | Clang source-based line, region, and branch coverage |
| Editor integration | clangd; no mandatory editor or IDE |

Clang-only means no build, test, warning, performance, or acceptance lane invokes
MSVC `cl.exe` or GCC/G++. The Windows target uses Linux-hosted `clang-cl`,
`llvm-lib`, and `lld-link` with the MSVC STL/CRT and Windows SDK as target-sysroot
inputs. The Debian target uses Clang, libstdc++, and its admitted target sysroot.
Native Windows and Debian processes execute, measure, and formally accept their
respective product artefacts.

## Toolchain inventory

The following versions are exact baseline inputs unless a row explicitly calls
for an installation identity to be completed before operational readiness.

| Input | Approved version or identity |
| --- | --- |
| Build root | Ubuntu 26.04 LTS Canonical OCI rootfs; final derived image digest and immutable APT snapshot required before operational readiness |
| LLVM suite | Ubuntu 26.04 package version 22.1.2: Clang, clang-cl, clang-format, clang-tidy, clangd, llvm-cov, llvm-profdata, llvm-symbolizer, compiler-rt, LLD, and libFuzzer |
| CMake | Ubuntu 26.04 package version 4.2.3; both minimum and executed version |
| Ninja | 1.13.2 |
| sccache | 0.16.0 |
| Windows SDK | Family 10.0.26100; xwin VS17 package version 10.0.26100.15 |
| MSVC platform components | CRT selector 14.50.18.0 and package 14.50.35735 from xwin VS18; ASan package 14.50.35734 with content 14.50.35717; CRT redistributable package 14.50.35719 with content 14.50.35710 |
| Windows acceptance OS | Windows 11 Pro 25H2 and exact build/driver state in `RHP-DESKTOP-001` |
| Debian | Debian 13.6 `trixie`; exact APT snapshot, signed repository metadata, package hashes, and derived sysroot digest MUST be recorded before operational readiness |
| Debian C++ library | libstdc++ 14.2.0-19 |
| Debian assembler/linker | binutils 2.44-3 |
| vcpkg registry | Release `2026.07.29`, commit `9e593bb18ea69cc5095e012465dcd675a822ed0d` |
| vcpkg tool | 2026-07-27 |
| GoogleTest/GoogleMock | 1.17.0#3 through vcpkg |
| Google Benchmark | 1.9.5 through vcpkg |
| CodeQL Action | 4.37.9, commit `cdf488f595d80d6e07e03d4674febd5ab45fa938` |
| CodeQL bundle/CLI | 2.26.4 |

Primary version evidence: [Ubuntu 26.04 rootfs](https://partner-images.canonical.com/oci/resolute/current/),
[LLVM](https://packages.ubuntu.com/resolute/clang-22),
[CMake](https://packages.ubuntu.com/resolute/cmake),
[Ninja 1.13.2](https://github.com/ninja-build/ninja/releases/tag/v1.13.2),
[sccache 0.16.0](https://github.com/mozilla/sccache/releases/tag/v0.16.0),
[Windows SDK](https://learn.microsoft.com/en-us/windows/apps/windows-sdk/downloads),
[MSVC toolset lifecycle](https://learn.microsoft.com/en-us/cpp/overview/compiler-versions),
[Debian 13](https://www.debian.org/releases/trixie/),
[Debian libstdc++](https://packages.debian.org/trixie/libstdc++6),
[Debian binutils](https://packages.debian.org/trixie/binutils),
[vcpkg 2026.07.29](https://github.com/microsoft/vcpkg/releases/tag/2026.07.29),
[vcpkg tool](https://github.com/microsoft/vcpkg-tool/releases/tag/2026-07-27),
[GoogleTest 1.17.0](https://github.com/google/googletest/releases/tag/v1.17.0),
[Google Benchmark 1.9.5](https://github.com/google/benchmark/releases/tag/v1.9.5),
[CodeQL Action 4.37.9](https://github.com/github/codeql-action/releases/tag/v4.37.9),
and [CodeQL CLI 2.26.4](https://github.com/github/codeql-cli-binaries/releases/tag/v2.26.4).

Every installer, archive, package, OCI image, action, bootstrap asset, and tool
binary MUST have its source, full version/build identity, and cryptographic hash
recorded in a machine-readable inventory. Finding a name on `PATH` is not proof
of identity. LLVM components from different releases MUST NOT be mixed.

The build root obtains LLVM 22.1.2 from an exact preserved Ubuntu 26.04 package
snapshot. The Windows and Debian targets MUST NOT discover an ambient compiler,
linker, standard library, or SDK. Release builds use preserved material without
contacting a live repository. The machine-readable inventory binds the derived
build-root digest to every installed package and external tool.

The Windows sysroot deliberately composes CRT inputs from the retained VS18
manifest with SDK inputs from the retained VS17 manifest because neither
manifest contains both admitted families. The inventory MUST bind each source
manifest, package manifest, payload, selector, and materialized sysroot. A live
Visual Studio channel response is never a build input.

## Language and portability

Every first-party production target MUST declare C++23, require that standard,
and disable extensions:

```cmake
target_compile_features(target PUBLIC cxx_std_23)
set_target_properties(target PROPERTIES
  CXX_STANDARD 23
  CXX_STANDARD_REQUIRED YES
  CXX_EXTENSIONS NO)
```

The effective Debian command MUST select `-std=c++23`. LLVM 22.1.2 exposes the
corresponding clang-cl mode as `/std:c++23preview`; Windows MUST select that mode
and MUST NOT select `/std:c++latest`. Despite the switch name, only approved
standard C++23 features from the project allowlist may be used. Neither platform
may select a GNU dialect, post-C++23 mode, experimental header, or vendor language
extension. Platform attributes and APIs MAY appear only behind narrow adapters;
their public first-party interfaces MUST use standard types or project types.

### C++23 feature allowlist

The language mode does not imply that every C++23 feature is admitted. A
versioned allowlist MUST identify each used language or standard-library feature
and its feature-test macro where one exists. A feature MUST be available in both
sealed target profiles:

- Linux-hosted clang-cl 22.1.2 with the pinned MSVC STL/CRT and Windows SDK;
- Clang 22.1.2 with the pinned Debian 13.6 target sysroot.

The locked compiler and standard-library identities establish availability; no
standalone feature-probe target is retained. Use of an admitted feature is
validated by compiling and testing the real product targets that use it. Code
MUST NOT depend on a feature absent from the current allowlist. Updating the
allowlist changes this baseline and requires the normal approval process.

### Determinism and representation

The Session Authority is the source of canonical state. The same authority
build, inputs, ordering, seed, and initial state MUST produce the same logical
outcome. Cross-platform or cross-library floating-point bit equality is not
required.

Serialization and protocols MUST declare widths, signedness, units, encoding,
byte order, versioning, validation, and unknown-version behavior. They MUST NOT
serialize native object layout, padding, pointers, native enum representation,
addresses, locale-dependent values, or unordered-container iteration order.

Where exact equality is required, use an integer representation, fixed-point
model, or explicit quantization. Floating-point reductions and iteration order
that affect canonical outcomes MUST be stable. Random algorithms, seeds, and
consumption order MUST be explicit. `fast-math` and equivalent assumptions are
prohibited in canonical state, physics, ballistics, scoring, timing, security,
and validation.

## Project C++ Style Profile

### Explicit deviations and applicability

This profile deliberately differs from the Google guide in these respects:

- it targets C++23 rather than Google's current C++20 baseline, but only through
  the two-platform feature allowlist;
- exceptions are permitted internally under the boundary and hot-path rules
  below rather than prohibited project-wide;
- RTTI is permitted outside measured hot paths, while central interfaces remain
  independent of it;
- expected failures use C++23 `std::expected` directly;
- allocation is measured and budgeted rather than prohibited globally; and
- the repository's pinned formatter, linter, warning profiles, requirements, and
  exception records decide compliance when an external Google recommendation
  would differ.

All rules in this section apply to first-party production, test, benchmark, and
fuzzer C++. Generated and third-party source is excluded only through the
inventories defined in [Normative language and precedence](#normative-language-and-precedence).
Build definitions, generators, scripts, and release artefacts are governed by
their dedicated sections rather than by C++ naming rules.

### Files and naming

- Source uses English identifiers and comments and canonical Sacramento domain
  terms.
- C++ source and header filenames use lowercase `snake_case` and conventional
  extensions `.cc` and `.h`.
- Types, concepts, aliases, template parameters, and functions use `PascalCase`;
  compile-time or immutable named constants use `kPascalCase`.
- Variables, data members, parameters, namespaces, and non-type template
  parameters use `snake_case`.
- Private data members end in one underscore, for example `state_`.
- Macros use uppercase `SACRAMENTO_PREFIXED_NAMES`; new unprefixed macros are
  prohibited.
- Names MUST describe domain meaning, units, or responsibility. Type encodings,
  Hungarian notation, ambiguous abbreviations, and names distinguished only by
  case are prohibited.

### Formatting

- The repository's pinned clang-format 22.1.2 configuration is authoritative.
- The style is based on Google formatting with an 80-column normal limit.
- Spaces, indentation, brace placement, wrapping, pointer/reference alignment,
  include grouping, and include sorting are determined solely by that config.
- Covered files MUST produce no change when formatted by the pinned invocation.
- Manual alignment that conflicts with formatter output is prohibited.
- Formatting MUST NOT be disabled without an approved, scoped exception.

### Headers and includes

- Headers MUST be self-contained and compile when included first.
- Each header uses a unique project-path-derived include guard: uppercase the
  repository-relative path, replace every non-alphanumeric character with one
  underscore, prefix `SACRAMENTO_`, and add a trailing underscore. For example,
  `src/simulation/state.h` becomes `SACRAMENTO_SRC_SIMULATION_STATE_H_`.
  `#pragma once` MUST NOT be the sole guard.
- Include what the file uses; do not rely on transitive includes.
- Include order is related header, C system headers, C++ standard headers,
  third-party headers, then project headers, with groups separated as configured.
- Forward declarations MAY reduce coupling only when ownership, completeness,
  and destruction requirements remain correct.
- Public headers MUST NOT expose implementation-only or concrete third-party
  types.
- Third-party include directories SHOULD be system includes. This MUST NOT hide
  misuse diagnosed in first-party code.

### Types, ownership, and lifetime

- Prefer values, immutability, RAII, and the Rule of Zero.
- Raw pointers and references are non-owning. Ownership MUST be expressed by a
  value, container, or smart pointer.
- `std::unique_ptr` is the default dynamic exclusive owner.
- `std::shared_ptr` requires genuinely shared lifetime; it MUST NOT be introduced
  merely to avoid deciding ownership. Cycles MUST be prevented explicitly.
- `std::span` and `std::string_view` are permitted only while the source lifetime
  is proven. They MUST NOT outlive, silently rebind, or obscure their owner.
- Invalid states SHOULD be unrepresentable through domain value types, closed
  enums, validated factories, and explicit state transitions.
- Unions, placement construction, manual lifetime management, and pointer
  arithmetic are confined to reviewed low-level modules with documented
  invariants and dedicated tests.
- APIs without bounds and unbounded C string functions are prohibited. Prefer
  containers, spans, bounded formatting, and algorithms.

### Functions and APIs

- Interfaces MUST state ownership, lifetime, units, ordering, thread-safety,
  blocking behavior, and failure behavior where those properties are not evident
  from types.
- Keep interfaces narrow and place behavior behind module boundaries. Do not
  expose third-party implementation choices.
- Mark results `[[nodiscard]]` when ignoring an error, state transition,
  resource, or validation result is unsafe.
- Use `noexcept` only when the complete call chain satisfies it. Destructors and
  move operations SHOULD be `noexcept` when their behavior permits.
- Default arguments MUST NOT hide expensive work, ownership transfer, I/O, or
  time-dependent behavior.
- Output parameters are discouraged; return a value, struct, or
  `std::expected`. A necessary output parameter MUST be visibly mutable.
- A public binary ABI is not promised. Exported symbols are explicit, hidden by
  default on Debian, and controlled by export/import declarations on Windows.
  Export lists MUST be verified from final binaries.

### Errors, exceptions, and assertions

- Expected runtime, parsing, validation, and dependency failures use
  `std::expected<T, E>` directly.
- `E` is a closed error type specific to a domain or subsystem. Free-form strings
  and open metadata bags MUST NOT be programmatic error categories.
- Diagnostics are separate from programmatic decisions and MUST NOT disclose
  secrets.
- Exceptions MAY be used internally but MUST NOT cross a thread entry, C ABI,
  plugin, process, or subsystem boundary. They MUST NOT be normal control flow in
  frame, simulation tick, or audio paths.
- RTTI MAY be used outside measured hot paths. Central interfaces MUST NOT depend
  on RTTI.
- Development assertions MAY be removed in release, MUST have no side effects,
  and represent programmer errors only.
- Always-on checks protect canonical state, security, persistence, and evidence.
  Their failure disposition and observability MUST be defined.
- Invalid external input MUST return an error; it MUST NOT rely on assertions.
- Behavior required for correctness MUST NOT disappear with debug configuration.

### Numeric behavior, casts, and units

- Narrowing, signed/unsigned, floating/integer, shadowing, and format diagnostics
  are errors.
- An explicit cast MUST document real intent; a cast used only to silence a
  diagnostic is prohibited.
- Prefer brace initialization when it detects narrowing without obscuring the
  intended construction.
- Units, clock domains, coordinate spaces, tolerances, and ranges MUST be encoded
  in types or stated at the interface. Bare numbers MUST NOT cross boundaries
  when their unit is ambiguous.
- C-style casts and function-style casts for conversion are prohibited. Use the
  narrowest applicable named C++ cast.
- `reinterpret_cast` is confined to reviewed low-level or interoperability code.

### Concurrency

- Minimize shared mutable state. Prefer immutable messages, ownership transfer,
  and partitioned state.
- A mutex MUST be visibly associated with the data it protects. Locks use scoped
  RAII guards.
- Multiple-lock ordering MUST be documented and mechanically expressed where
  possible.
- `std::atomic` defaults to sequential consistency. A weaker memory order needs
  a local explanation of the happens-before argument and dedicated tests.
- Lock-free code requires measured benefit and a specific correctness review.
- `volatile` MUST NOT be used for inter-thread synchronization.
- Shared-state modules use portable project macros for Clang Thread Safety
  Analysis and run under TSan in the applicable gate.

### Macros and compile-time mechanisms

- Prefer language constructs, constants, inline functions, templates, and
  concepts over macros.
- A necessary macro is project-prefixed, has the smallest scope, does not depend
  on argument side effects, and is undefined after temporary local use.
- Conditional compilation is confined to platform adapters or generated
  configuration. It MUST NOT create unverified product behavior.
- Template and concept diagnostics SHOULD expose the failed domain constraint,
  not only an implementation detail.
- C++ modules are prohibited in this baseline.

### Performance rules

- Profile before optimizing and measure against an approved workload.
- Dynamic allocation is not globally prohibited. Relevant paths MUST instrument
  allocation count and volume and receive subsystem budgets when evidence makes
  them necessary.
- After `Ready`, a Measured Real-Time Hot Loop MUST NOT allocate from the
  general-purpose heap, grow allocator backing storage, or use an upstream
  fallback that does either. Required capacity MUST be reserved before the loop.
  Allocation from a previously provisioned bounded scratch arena or pool MAY
  occur only when it cannot grow or fall back to the general-purpose heap.
- Outside Measured Real-Time Hot Loops, implementations MUST minimize
  general-purpose heap allocation by measuring count and volume and removing
  unjustified churn; this rule does not impose an unmeasurable global
  zero-allocation target.
- Arenas, pools, custom allocators, and `std::pmr` require a measured problem and
  MUST preserve explicit ownership.
- `-march=native` and equivalent host-derived code generation are prohibited.
  CPU targets are explicit build inputs.
- Initial release builds use conventional optimization with debug information.
  ThinLTO and PGO are disabled until an approved benchmark demonstrates benefit,
  correctness is unchanged, and reproducibility remains satisfied.
- A local microbenchmark improvement MUST NOT override an end-to-end regression.

### Manual review obligations

Every C++ pull request includes a short risk-based checklist. Applicable rows
cover ownership/lifetime, concurrency/order/blocking, units/clocks/tolerances,
failure boundaries, determinism/serialization, allocation/performance, input
security, tests/requirements/evidence, and exceptions/suppressions. Each row is
answered or marked not applicable; omission is not an answer.

### Style enforcement map

| Rule family | Automatic enforcement | Required human review |
| --- | --- | --- |
| Formatting and include order | clang-format check | Only an approved formatter exception |
| Naming and basic declarations | clang-tidy naming and readability checks | Domain meaning and clarity |
| Header self-containment and dependencies | Compile header-first tests and selected clang-tidy checks | Boundary and coupling quality |
| Ownership and lifetime | Compiler and selected clang-tidy checks | Owner, escape, aliasing, and view lifetime |
| Numeric conversions and format safety | Pinned compiler warnings and clang-tidy | Units, tolerance, and intentional conversion |
| Errors, exceptions, and assertions | Compiler, clang-tidy, tests, and exception validator | Correct failure boundary and disclosure |
| Concurrency | Thread Safety Analysis, TSan, and tests | Lock order, blocking, and happens-before argument |
| Portability and C++23 | Strict modes and real target builds on both platforms | Platform-adapter boundary |
| Determinism and serialization | Repeated/differential tests and schema checks | Canonical ordering, quantization, and version behavior |
| Performance and allocations | Instrumentation, benchmarks, and NFR gates | Workload validity and trade-off with correctness |
| Third-party/generated classification | Inventory and generated-file checks | Provenance and exclusion scope |

## Build system

CMake 4.2.3 is the only build definition and Ninja 1.13.2 single-config is the
only executor. `CMakePresets.json` is the canonical interface. Developer-only
values MAY live in ignored `CMakeUserPresets.json`, but MUST NOT change a gate's
semantics.

- Every cohesive module is a target.
- Sources are explicit; globbing source lists is prohibited.
- Include directories, compile definitions, options, features, link options, and
  dependencies are target-scoped with deliberate `PRIVATE`, `PUBLIC`, or
  `INTERFACE` visibility.
- Directory-global first-party warnings, includes, definitions, and link flags
  are prohibited.
- Generated output exists only in the build tree.
- Tests link the same production libraries; test-only reimplementations of
  production behavior are prohibited.
- `compile_commands.json` is generated for Clang tools and clangd.
- CMake developer warnings and invalid presets fail configuration.
- Repository CMake files are first-party code. Format/lint tooling MUST use the
  pinned versions admitted by this baseline; configure/build tests remain
  mandatory for every real target.
- Handwritten Ninja files and maintained Visual Studio project files are
  prohibited.

Canonical presets are `dev`, `debug`, `release`, `asan-ubsan`, `asan-windows`,
`tsan`, `coverage`, `fuzz`, `acceptance`, and `reproducible`. Platform-specific
variants use inheritance without changing these meanings. A new preset requires
a documented purpose, exact flags, and a gate.

`dev` uses moderate optimization (`/O1` or `-O1`), debug information, and
development assertions. `debug` uses `/Od` or `-O0`, full debugging, and
development assertions. `release` uses `/O2` or `-O2`, is hardened and
unsanitized, and retains separate full debug information. `acceptance` uses the
same code-generation and hardening semantics as release plus production-parity
observability. Instrumented presets remain separate because sanitizer and
coverage combinations have compatibility and performance constraints.

PCH and unity builds are disabled in the canonical path. A measured local-only
accelerator MAY use them, but CI always includes a clean ordinary build and the
accelerator MUST NOT change output semantics. C++ modules remain prohibited.

## Dependencies

vcpkg is the only C++ dependency manager. `vcpkg.json`,
`vcpkg-configuration.json`, project triplets, and the exact registry commit are
versioned. FetchContent, git submodules as package managers, implicit system
package discovery, and a second package manager are prohibited.

The Windows triplet uses clang-cl, dynamic MSVC CRT (`/MD`, and `/MDd` only for
compatible debug builds), and static third-party libraries by default. Mixing
`/MD` and `/MT` across C++ boundaries is prohibited. The Debian triplet uses
Clang, libstdc++, and static third-party libraries by default. Platform system
libraries remain dynamic where required. A dynamic third-party library requires
a documented license, plugin-boundary, security-update, or size reason.

Every direct and transitive dependency records origin, version, source hash,
license, selected features, ABI inputs, vulnerability disposition, and consumer.
Unused and duplicate dependencies MUST be removed. Permissive MIT-compatible
licenses follow normal review; copyleft, source-available, commercial, or other
restrictive terms require explicit approval before introduction. Existence in
vcpkg is not license approval.

Vulnerability alerts and dependency-update pull requests MAY be automated.
Auto-merge is prohibited. Major-version, ABI, baseline, license, and registry
changes receive explicit review and the complete applicable gates.

Normal development MAY obtain hash-verified sources. Release and acceptance
MUST NOT access the network. Exact source archives are retained in a controlled,
immutable artefact store, identified by repository metadata, included in release
retention, and used to prepopulate a local source cache.

sccache 0.16.0 and vcpkg binary caching are local only. Remote or shared compiler
and binary caches are prohibited. Each cache is an optimization, never evidence.
Periodic and release-candidate builds start without either cache.

## Tests, fuzzing, coverage, and performance

GoogleTest 1.17.0#3 and CTest are the canonical test stack. GoogleMock is used only
when a behavior-rich fake cannot provide a clearer boundary. Tests are classified
as unit, component, integration, determinism/serialization, system, performance,
or formal acceptance. A test name and retained output MUST identify the behavior
or obligation it verifies.

Unit and component tests are hermetic: no Internet, uncontrolled wall clock,
unrecorded randomness, implicit machine state, or order dependence. Clocks,
randomness, filesystem, and external boundaries are injectable. Seeds and failing
inputs are fixed or recorded. Integration dependencies are local and versioned.
Hardware-, LAN-, and service-dependent tests live in explicit suites.

Retries that turn a failure into success are prohibited. The first failure fails
the gate. A flaky, disabled, or quarantined test is a defect and requires an
approved exception with owner and expiry. Performance variance uses an approved
statistical method, never retries until favorable.

Clang source-based coverage records line, region, and branch coverage in
merge/nightly. There is no global percentage target. Coverage locates gaps and
does not replace behavior, requirement traceability, fuzzing, or acceptance.
Critical state transitions, boundaries, and invariants receive explicit coverage
expectations; a numeric module threshold requires a verifiable rationale.

libFuzzer targets every untrusted byte or sequence boundary, including network
messages, serialization, assets, profiles, catalogues, identity packages, and
state-machine actions. Run libFuzzer with the matching LLVM 22.1.2 runtime and
ASan+UBSan on Debian. Minimal corpora, dictionaries, seeds, and minimized crashes
are retained. Every fixed crash becomes a permanent regression test.

Fuzz budgets are up to 60 seconds per affected target on a pull request,
15 minutes per target nightly, and one hour weekly for high-risk targets. Manual
long campaigns precede releases or follow critical changes. Budgets MAY change
when target count or cost is measured and the baseline is revised.

Google Benchmark 1.9.5 measures algorithms and allocators and emits structured
JSON for controlled evidence. Hosted-runner results are trends only. A benchmark
blocks only on controlled hardware with an approved workload, sampling method,
tolerance, and threshold. Product NFR and acceptance results outrank
microbenchmarks.

## Diagnostics and static analysis

All first-party diagnostics are errors. Third-party diagnostics are isolated and
MUST NOT suppress a diagnostic whose source is first-party code.

The clang-cl profile starts from `/W4 /WX /permissive- /Zc:__cplusplus` and adds
pinned Clang diagnostics for conversion, sign conversion, shadowing, narrowing,
format mismatch, undefined macro use, implicit fallthrough, non-virtual
destruction, and unsafe buffer behavior where available. The Debian Clang profile
starts from `-Wall -Wextra -Wpedantic -Werror` and admits the corresponding
explicit diagnostics. `-Weverything` is prohibited because new LLVM diagnostics
would otherwise change the baseline implicitly.

The repository `.clang-tidy` MUST begin from no checks and list every enabled
check explicitly for LLVM 22.1.2; broad positive wildcards that make a future
tool update silently enable checks are prohibited. Its admitted checks cover
Clang Static Analyzer, bug-prone behavior, CERT rules adopted here, concurrency,
performance, portability, enforceable Google rules, and enforceable C++ Core
Guidelines rules. Magic-number, identifier-length, and other checks that
contradict this profile or produce no actionable signal remain unselected; any
negative override to an admitted group is explicit. The config-validation
invocation and all diagnostics are blocking.

Pull requests run clang-tidy on affected translation units. Merge/nightly runs
the complete project because diff filtering can miss diagnostics emitted outside
changed lines. CodeQL uses the pinned Action and bundle, invokes an explicit
CMake build, and is blocking when available for the repository. Shared-state
modules use Clang Thread Safety Analysis through portable project macros.

clang-format, clang-tidy, warnings, CodeQL, sanitizer, coverage, dependency, and
exception-validation invocations MUST be checked-in scripts called identically
by local gates and CI. An editor diagnostic is advisory until the canonical gate
emits it.

## Sanitizers and hardening

Debian pull requests run ASan+UBSan. Windows pull requests run compatible
representative tests under clang-cl ASan; incompatible features or runtime
options MUST be recorded, not silently skipped. TSan runs separately in
merge/nightly. MSan runs periodically only when the program, standard library,
and complete linked dependency graph are instrumented. LSan runs with ASan where
supported. Sanitizer runtimes MUST NOT ship in production.

Any reproducible sanitizer diagnostic fails its gate. Sanitizers are not combined
when LLVM documents incompatible instrumentation. A suppression requires the
same approved exception record as every other automatic-check exception.

Windows-target clang-cl release hardening includes compiler `/GS /guard:cf` and
linker `/GUARD:CF /DYNAMICBASE /NXCOMPAT /HIGHENTROPYVA`. Debian Clang release hardening
includes `-fstack-protector-strong`, `-fstack-clash-protection`,
`-D_FORTIFY_SOURCE=3`, and `-fPIE`, with linker
`-pie -Wl,-z,relro,-z,now,-z,noexecstack`. The exact generated command is
retained as evidence.

Every selected protection MUST be verified from the final binary and benchmarked
on the reference workload. Hardening is mandatory by default. Removal requires an
approved, minimal, expiring exception recording the security risk, measured
performance impact, and alternatives.

## Continuous integration and quality gates

GitHub Actions is a thin orchestrator over checked-in scripts and presets.
External Actions use full immutable commit SHAs and minimum explicit permissions.
Hosted runners perform correctness and analysis. Controlled/self-hosted machines
perform blocking performance, release reproducibility, and formal acceptance.

| Gate | Blocking work |
| --- | --- |
| Pre-push | Format; configure; primary platform build; affected clang-tidy, tests, determinism, and serialization checks |
| Pull request | Parallel Windows-target clang-cl and Debian-target Clang builds; native tests; affected clang-tidy; Debian ASan+UBSan; representative Windows ASan; short affected fuzzing; dependency, license, exception, and generated-file validation |
| Merge/nightly | Full clang-tidy; CodeQL; TSan; feasible MSan; coverage; 15-minute fuzzing; clean uncached non-unity builds; repeated determinism; benchmark trends |
| Weekly | One-hour high-risk fuzz campaigns, dependency/vulnerability audit, and toolchain-availability review |
| Release candidate | Exact Windows-target clang-cl and Debian-target Clang release builds; hardening verification; regression corpora; two clean reproducible builds per platform; SBOM, provenance, license/vulnerability disposition, symbols, hashes, and signatures |
| Formal acceptance | Exact admitted hardware, OS, drivers, build, configuration, content, workload, production-parity observability, and every obligation-level disposition |

Pull-request blocking work has a 15-minute target and runs in parallel. If it
exceeds the target, optimize or partition work without silently removing required
coverage. Hosted runners MUST NOT decide performance.

Required checks protect integration branches. Direct integration without a pull
request and normal administrative bypass are prohibited. The integrated commit
MUST be the checked commit. Emergency bypass requires an approved exception,
retained evidence, owner, and expiring follow-up.

Git hooks MAY invoke the canonical pre-push workflow but are optional convenience.
CI is authoritative. Every failure message SHOULD state the exact local command
that reproduces it.

## Reproducibility and release evidence

Each release candidate is built twice from identical inputs in new isolated
workspaces. Artefacts from the same platform and complete toolchain MUST be
bit-for-bit identical. Windows and Debian artefacts need not match each other.

The build fixes source commit, subdirectory state, dependency graph and archives,
compiler and tools, standard library, linker, SDK/sysroot, environment image,
locale, timezone, archive order, file permissions, source-derived timestamp, and
configuration. It removes hostnames, random identifiers, wall-clock timestamps,
and absolute source/build paths through supported prefix mapping. A hash mismatch
blocks the release until corrected or covered by an approved release exception.

Windows and Debian reproducibility use the same Ubuntu 26.04 build-root image
pinned by digest, with separate immutable target sysroots and profiles. This
isolates builds but is not a deployment or performance environment. Runtime,
performance, release-signing, and acceptance gates run natively on the relevant
reference system.

Every release candidate generates an SPDX SBOM for the complete dependency graph
and provenance linking commit, toolchain, presets, dependencies, workflow, and
artefacts. Incomplete dependency data fails the release. Binary and symbol hashes
are published with the release evidence.

The first public release and every later release require code and artefact
signing. Windows binaries use native code signing. Debian artefacts, SBOM, hashes,
and provenance receive a verifiable signature. Keys MUST NOT exist in the
repository or ordinary runners; an authorized release environment owns signing,
access, rotation, and revocation.

Published binaries, debug symbols, SBOM, provenance, source archives,
configurations, and diagnostic logs are retained for the supported lifetime and
a later period defined by the product support policy. Sensitive artefacts use
controlled access. Indefinite retention is not promised by this baseline.

## Bootstrap and developer workflow

A machine-readable inventory is the single source for versions, hashes, and
installation identities. Shared Python implements validation. Thin PowerShell and
Bash wrappers prepare or locate Python and invoke that logic on Windows and
Debian; they MUST NOT duplicate version policy.

Bootstrap provides a read-only `verify` mode and an explicit `install` mode.
Install describes intended changes and verifies every download. Local and CI
consume the same inventory. The separately approved Project Python Toolchain and
Style Profiles govern these first-party scripts before they are admitted.

WSL2 MAY orchestrate the pinned Ubuntu 26.04 build root. Windows outputs are
produced by Linux-hosted Clang/LLVM processes using immutable Windows target
inputs; Debian outputs use a separate immutable Debian target sysroot. WSL and
Ubuntu are build environments, not additional product platforms. Windows and
Debian runtime, performance, release, and acceptance gates run natively.

clangd 22.1.2 is the supported language server. Editors and IDEs are optional and
non-normative.

## Exceptions

Every exception to style, formatting, lint, warnings, sanitizer, test, fuzz,
hardening, dependency, reproducibility, or gate policy MUST record:

- exact rule and diagnostic;
- smallest affected scope;
- technical rationale and risk;
- alternative considered;
- owner and approver;
- creation date; and
- mandatory review or expiry condition.

An inline suppression without a current record fails acceptance. A disabled or
quarantined test, sanitizer ignore, warning disable, hardening reduction, or
release mismatch is an exception even if its tool uses different terminology.

## Requirement traceability

| Approved input | Controlling baseline content |
| --- | --- |
| `CONSTRAINT-LANGUAGE-001` | English and canonical terminology under Files and naming |
| `CONSTRAINT-CPP-VERSION-001` | Language and portability, strict modes, and C++23 feature allowlist |
| `CONSTRAINT-CPP-STYLE-001` | Complete Project C++ Style Profile and explicit deviations/applicability |
| `CONSTRAINT-CPP-FORMAT-001` | Formatting rules, pinned LLVM version, executable-config readiness, and format gates |
| `CONSTRAINT-CPP-LINT-001` | Diagnostics and static analysis, pinned LLVM version, and executable-config readiness |
| `CONSTRAINT-CPP-TOOLCHAIN-001` | Toolchain inventory, bootstrap, presets, CI, and reproducibility |
| `PROCESS-CPP-STYLE-EXCEPTION-001` | Exceptions |
| `PROCESS-CPP-STYLE-GATE-001` | Continuous integration and quality gates |
| `CONSTRAINT-CLIENT-OS-001` | Windows toolchain inventory and formal-acceptance gate |
| `CONSTRAINT-AUTHORITY-OS-001` | Debian toolchain inventory and formal-acceptance gate |
| `CONSTRAINT-PLATFORM-MATRIX-001` | Two Clang platform profiles and Clang-only ADR |
| `PREFERENCE-PLATFORM-PARITY-001` | Shared CMake definition, presets, style, tests, and feature allowlist |
| `CONSTRAINT-NFR-REPLAY-001` | Determinism rules and determinism/serialization test gates |
| `NFR-OBSERVABILITY-BUILD-PARITY-001` | Acceptance preset and production-parity observability gates |
| `CONSTRAINT-NFR-TEAM-001` | One compiler family, one build definition, one dependency manager, one test stack, and automated layered gates |

## Readiness and change control

This baseline is approved because its engineering decisions are closed. The
toolchain is operationally ready to admit first-party production C++ when all of
the following exist and pass:

1. machine-readable toolchain, installer, package, and hash inventories;
2. pinned `.clang-format`, `.clang-tidy`, warning, hardening, and exception
   configurations that map this complete profile;
3. CMake project and every canonical preset;
4. vcpkg manifest, configuration, and both project triplets;
5. bootstrap verification of the Ubuntu build root and both immutable target
   sysroots; and
6. documented outstanding exceptions, if any.

For `CPP-ENGINEERING-BASELINE-004`, the machine-readable configurations and
gates must additionally identify this successor and detect general-purpose heap
allocation, backing-storage growth, and upstream fallback in every declared
Measured Real-Time Hot Loop. Until then, readiness remains pending without
weakening the approved rule.

The sealed toolchain establishes the identity, integrity, and admitted
capabilities of the build environment. Standalone prototype, proof, or fixture
targets MUST NOT be retained as readiness evidence.

Each real production target MUST introduce its applicable build, test, analysis,
sanitizer, hardening, reproducibility, and native-runtime gates in the same change
that introduces the target. Those gates validate product code; the toolchain seal
does not waive them. A gate that requires a product artefact becomes blocking
when the first relevant artefact exists, rather than requiring artificial code
before product development begins.

Toolchains and dependencies never update automatically. They are reviewed at
least quarterly and in response to critical security issues. An update occurs in
an isolated pull request, verifies the complete bootstrap and all gates
applicable to existing real product targets, and creates a newly identified
baseline version. Dependency bots MAY propose but MUST NOT merge changes.
