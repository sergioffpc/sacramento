# Gate 2E result: observability and Tracy separation

Date: 2026-09-02

Verdict: **PASS for native Debian structured-signal execution and Debian/Windows
profile separation; native Windows execution and a live Tracy capture remain
UNPROVED.**

## Question and answer

Can Sacramento emit the applicable `OBS-CONTRACT-001` build, configuration,
content, action, and acoustic identities as structured logs while keeping Tracy
diagnostic instrumentation absent from `CoreOnly`?

Yes, for the narrow deterministic scenario exercised here. One Sacramento
writer emitted separate Session Authority, rendered-client, and synthetic-client
NDJSON streams. The diagnostic build invoked a private Tracy adapter and added
one optional marker per process. The `CoreOnly` build did not link Tracy and
emitted only core-catalogue identifiers. OpenTelemetry is absent.

## Signal evidence

Every record contains the common envelope required by `OBS-CONTRACT-001`, with:

- contract `OBS-CONTRACT-001`;
- build `gate2e-prototype-build-001`;
- configuration `gate2e-observability-config-001`;
- profile `RWP-GATE2E-001` and the Gate 2B content identity
  `sha256:1849d21148d23e4ad2da81e4ddbec5d7fbd636b00e4c9b087bc14db0589c2c46`;
- a strictly increasing source-local sequence; and
- conditional session, event, and reference-time fields only where applicable.

The scenario exercised:

| Source | Applicable core signals |
| --- | --- |
| Session Authority | lifecycle, runtime identity, acoustic initiation |
| Rendered client | lifecycle, runtime identity, action submission/result presentation, acoustic presentation |
| Synthetic client | lifecycle, runtime identity, authoritative-result receipt |

The verifier proved one action correlation (`action-gate2e-017`) across
submission and both result forms, and one disjoint acoustic correlation
(`acoustic-gate2e-045`) across initiation and presentation. It found no gameplay
payload, credential, authentication evidence, or personal-data fields.

After removing process-instance, sequence, detail-level, and optional records,
the `CoreOnly` and `Diagnostic` core streams are structurally identical. The
three `CoreOnly` streams contain zero optional signals; the diagnostic streams
contain exactly three `OBS-GATE2E-DIAGNOSTIC-MARKER-001` records in total.

## Tracy and dependency boundary

Tracy is pinned through vcpkg registry
`9e593bb18ea69cc5095e012465dcd675a822ed0d` at version 0.13.1 with no default
features. The exact source archive is `wolfpld-tracy-v0.13.1.tar.gz`, SHA-512
`18c0c589a1d97d0760958c8ab00ba2135bc602fd359d48445b5d8ed76e5b08742d818bb8f835b599149030f455e553a92db86fb7bae049b47820e4401cf9f935`,
under BSD-3-Clause terms. Host-only vcpkg helpers are `vcpkg-cmake` 2024-04-23
and `vcpkg-cmake-config` 2026-07-21; the target closure also contains the empty
`pthreads` meta-package 3.0.0#14.

The public Sacramento header has no Tracy token or type. Only
`tracy_profiler_adapter.cc` includes the vendor header. Symbol inspection found
zero Tracy symbols in the Debian `CoreOnly` executable and 527 matching symbols
in the diagnostic executable. Both Debian binaries require only `libstdc++`,
`libm`, `libgcc_s`, and `libc` dynamically; Tracy is static. No OpenTelemetry
token appears in implementation sources, public headers, or emitted streams.

Installed target-package size was 3,619,920 bytes for Debian and 3,329,702 bytes
for Windows.

## Build and reproducibility evidence

Two fresh build directories for each platform/profile pair produced
byte-identical executables:

| Artifact | Bytes | SHA-256 |
| --- | ---: | --- |
| Debian `CoreOnly` | 17,016 | `6e26f0e31026a6c6863f70afe9ffa025cc36452ccbb0e78a19c8a063af6906fb` |
| Debian `Diagnostic` | 411,120 | `13d0abcfcd0beec149a4a7c2f106d9469995f5588acf78e827d22c56bbf85058` |
| Windows `CoreOnly` | 35,328 | `2e040a9619a4dd1bc111c428ecf5b686768a42fde571584600593845220dc4e9` |
| Windows `Diagnostic` | 142,848 | `cb94e413205aedc7fc6a57a1655e8ca1fdee9e24097889564289cfc80cb81872` |

Tracy dependency installation took 13,727 ms for Debian and 11,701 ms for
Windows. Fresh application builds took 1,639–1,955 ms. A no-change Debian
diagnostic build took 1,962 ms; bubblewrap startup dominates these small
measurements. All six Debian process/profile executions returned `pass` without
stderr output. These are build-host smoke measurements, not product budgets.

The first-party seam contains 156 lines in the Sacramento writer, 14 in the
sole Tracy adapter, and 33 in the public interface.

## Gate-local integration exceptions

1. The pinned vcpkg executable acquires CMake 4.4.0 to build Tracy while the
   Sacramento target build remains on approved CMake 4.2.3. The downloaded CMake
   archive SHA-512 is
   `3df4aaa128a438ed48dcac7065fd355ff538eed8f394491298d0db63a891d671da247c8fa262e4fa6bf99429d630abab317d5a0248168fe203d1ca4978dab4da`.
2. Tracy 0.13.1 does not declare a C++ standard for `TracyClient`. With the
   pinned clang-cl 22.1.2/MSVC STL, its atomic pointer copy-initialization fails
   in the compiler default mode. The gate-local Windows chainload selects the
   approved `/std:c++23preview` mode; the unchanged upstream source then builds
   in Debug and Release. A production dependency profile must own this setting.
3. The shared Windows reproducibility profile emits `/pathmap`, which
   Linux-hosted clang-cl misinterprets as a file. This gate uses `/Brepro` and
   Clang file/debug prefix maps, matching earlier prototype gates.
4. The Windows harness defines `_CRT_SECURE_NO_WARNINGS` only for the executable
   that reads three non-secret environment variables with standard `getenv`.
   This suppresses UCRT's platform-specific `_dupenv_s` recommendation; it does
   not suppress a Sacramento safety check or affect product behavior.

## What this does not prove

This gate does not implement or qualify a collector, local buffering, signal
loss accounting, alert routing, retention, clock-offset measurement, a
Controlled-LAN transport, or full catalogue coverage. It does not capture a
Tracy trace with a live profiler, measure Tracy overhead, run either Windows
binary natively, or prove a runtime switch between separately built profiles.
The fixed timestamps and fixture identities are deterministic prototype inputs,
not clock or production-identity implementations.

Issue #11 therefore remains open for native/literal composition gaps and the
overall foundation/dependency synthesis before issue #13 can make the formal
foundation choice.

## Dependency update procedure

1. Change only the Tracy override in `vcpkg.json`.
2. Inspect the new port source version/hash, patches, features, licence,
   transitive packages, ABI values, and download inventory.
3. Run this gate from a fresh output root on both target triplets.
4. Require byte-identical pairs for all four binaries, zero Tracy symbols and
   optional signals in `CoreOnly`, Tracy symbols in `Diagnostic`, and identical
   normalized core semantics.
5. Re-run native Debian and Windows profile executions; retain a live capture
   when that native diagnostic acceptance step is admitted.

## Reproduction

From the repository root, with the approved toolchain already bootstrapped:

```sh
SACRAMENTO_GATE2E_ROOT=/tmp/sacramento-composed-foundation-gate2e \
  prototypes/composed_foundation_gate2e/run-gate2e.sh
```

The output root must not already exist. Accepted raw evidence for this run is
retained at `/tmp/sacramento-composed-foundation-gate2e-review4` on the build
host.
