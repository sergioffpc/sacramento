# PROTOTYPE: Windows and Debian cross-compilation from WSL2

Status: Throwaway operational proof

Question: Can an Ubuntu LTS build environment running under WSL2 use only
Linux-hosted Clang processes to produce hardened Windows and Debian binaries
for Sacramento?

The answer is **yes**. See
[`PROOF_REPORT.md`](PROOF_REPORT.md) for the evidence and blockers. This is not
production engine code. Its build-host decision was subsequently admitted by
[`CPP-ENGINEERING-BASELINE-002`](../../docs/standards/cpp-engineering.md) and
[ADR-0002](../../docs/adr/0002-cross-compile-windows-from-ubuntu-with-clang.md).

## Proven topology

```text
Windows 11
  -> WSL2, Ubuntu 26.04.1 LTS (orchestration only)
    -> pinned Ubuntu 26.04 LTS rootfs
      -> Ubuntu Linux clang-cl 22.1.2
      -> Ubuntu Linux llvm-lib 22.1.2
      -> Ubuntu Linux lld-link 22.1.2
      -> hash-pinned sccache 0.16.0 with local-only storage
      -> MSVC STL/CRT 14.50 + Windows SDK sysroots
        -> x86-64 PE/PDB
          -> execution and GoogleTest on Windows through WSL interop
      -> hash-locked Debian 13.6 target sysroot
        -> x86-64 ELF + detached debug symbols
          -> tests and ASan+UBSan in the Debian target userspace
```

No `cl.exe`, Windows-hosted Clang, GCC, or G++ process participates in the
Windows target build. Native platform libraries remain inputs, just as
libstdc++ is a platform-library input to a Linux Clang build.

## Replay

The proof intentionally keeps multi-gigabyte licensed/downloaded inputs outside
Git. Materialize and verify the hash-locked state at
`/tmp/sacramento-cross-proof` with:

```bash
./scripts/bootstrap.sh install
./scripts/bootstrap.sh verify
```

The install command delegates to the promoted root bootstrap and uses the
immutable Ubuntu APT snapshot declared in `../../config/cpp/bootstrap-lock.json`.
It fails closed if a download, package version,
manifest, tool, or registry identity differs. To generate a deterministic
Ubuntu rootfs and Debian sysroot archives and their derived SHA-256 values, run
`./scripts/bootstrap.sh seal`.
Networks that intercept TLS may set `SACRAMENTO_BOOTSTRAP_CA_BUNDLE` to an
explicit host CA bundle. This changes transport trust only; hashes, APT
signatures, the snapshot, and admitted versions still decide input identity.

Then run the operational proof:

```bash
./scripts/proof.sh all
./scripts/proof.sh debian
```

Override the state directory with `SACRAMENTO_CROSS_PROOF_ROOT`. The script
performs preflight validation, configures and builds with CMake/vcpkg, proves a
local compiler-cache hit and deterministic clean replay, inspects PE hardening,
executes the application/tests on Windows, and runs positive and negative
Windows ASan probes. The Debian command proves deterministic ELF/debug output,
local cache hits, PIE/RELRO/NOW/non-executable-stack hardening, native target
userspace tests, and positive/negative ASan+UBSan behavior.

The checked-in CI workflow splits the same gates at the platform boundary. Its
explicit `ubuntu-26.04` job runs the Windows build/package gates and the full
Debian proof; the controlled Windows runner downloads the Windows package and
runs `scripts/run-windows.ps1` from native storage. No compiler runs in the
Windows job, and no Windows executable runs in the Ubuntu job.

Materializing the Microsoft sysroot with xwin requires acceptance of the
Microsoft license. The owner accepted it for this prototype on 2026-09-01.
Future automation must retain an explicit license-acceptance step.

## Boundaries

- Ubuntu 26.04 LTS is both the WSL family and candidate hermetic **build root**.
  The rootfs isolates and pins the package set without requiring host `sudo`.
- Windows remains the runtime, release, performance, and formal-acceptance
  platform for Windows artefacts.
- Debian 13.6 remains the product target; the prototype builds it from a
  separately signed and hash-locked target sysroot, then executes its gates
  inside that target userspace.
- APT is restricted to the locked Ubuntu snapshot. Minimal checked-in Visual
  Studio channel locks point to content-addressed Microsoft product manifests,
  so mutable channel aliases are not build inputs.
