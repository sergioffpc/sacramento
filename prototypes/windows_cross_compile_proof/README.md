# PROTOTYPE: Windows cross-compilation from WSL2

Status: Throwaway operational proof

Question: Can an Ubuntu LTS build environment running under WSL2 use only
Linux-hosted Clang processes to produce and test hardened Windows binaries for
Sacramento?

The answer is **yes, with baseline corrections required**. See
[`PROOF_REPORT.md`](PROOF_REPORT.md) for the evidence and blockers. This is not
production engine code and does not silently amend
[`CPP-ENGINEERING-BASELINE-001`](../../docs/standards/cpp-engineering.md).

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
```

No `cl.exe`, Windows-hosted Clang, GCC, or G++ process participates in the
Windows target build. Native platform libraries remain inputs, just as
libstdc++ is a platform-library input to a Linux Clang build.

## Replay

The proof intentionally keeps multi-gigabyte licensed/downloaded inputs outside
Git. With the materialized state described in `config/toolchains.json` at
`/tmp/sacramento-cross-proof`, run:

```bash
./scripts/proof.sh all
```

Override the state directory with `SACRAMENTO_CROSS_PROOF_ROOT`. The script
performs preflight validation, configures and builds with CMake/vcpkg, proves a
local compiler-cache hit and deterministic clean replay, inspects PE hardening,
executes the application/tests on Windows, and runs positive and negative
Windows ASan probes.

Materializing the Microsoft sysroot with xwin requires acceptance of the
Microsoft license. The owner accepted it for this prototype on 2026-09-01.
Future automation must retain an explicit license-acceptance step.

## Boundaries

- Ubuntu 26.04 LTS is both the WSL family and candidate hermetic **build root**.
  The rootfs isolates and pins the package set without requiring host `sudo`.
- Windows remains the runtime, release, performance, and formal-acceptance
  platform for Windows artefacts.
- Debian remains a product target. This prototype does not replace its target
  profile or re-prove the Debian artefact.
- The live APT archive and live Visual Studio channel manifests used during
  exploration are not yet release-grade immutable inputs.
