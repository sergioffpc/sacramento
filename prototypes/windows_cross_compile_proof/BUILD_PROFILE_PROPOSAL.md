# Candidate build profile: Ubuntu LTS under WSL2

Status: Prototype proposal; not normative

## Host and target separation

| Layer | Candidate rule |
| --- | --- |
| Physical/runtime host | Windows 11 with WSL2; exact Windows build recorded |
| Interactive WSL distro | Ubuntu 26.04 LTS; orchestration layer |
| Hermetic build root | Ubuntu 26.04 LTS OCI/rootfs with distribution-native packages plus the baseline-pinned sccache release, pinned by digest after materialization |
| Windows target | `x86_64-pc-windows-msvc`, MSVC STL/CRT 14.50, pinned Windows SDK, `/MD` |
| Target processes | Ubuntu LLVM 22.1.2 only: `clang-cl`, `clang-scan-deps`, `llvm-lib`, `lld-link`, LLVM inspection tools |
| Compiler cache | Official hash-pinned sccache 0.16.0, local storage only |
| Windows execution | Copy the PE and app-local runtimes to an NTFS path, then execute via WSL interop |
| Debian target | Retained as a separate product target/profile; not replaced by Ubuntu |
| Acceptance | Native on the exact Windows and Debian acceptance environments |
| GitHub-hosted jobs | Explicit `ubuntu-26.04`; never the moving `ubuntu-latest` alias |

The installed WSL distro observed during the proof was Ubuntu 26.04.1 LTS on
kernel `6.18.33.2-microsoft-standard-WSL2`. The generic upstream LLVM 22.1.8
bundle was rejected because its `lld-link` expects the older `libxml2.so.2` ABI.
The candidate profile instead uses Ubuntu's LLVM 22.1.2 packages, built against
Ubuntu 26.04's `libxml2.so.16`. No compatibility symlink or Ubuntu 24.04 layer is
used. The active cache is the baseline-pinned official sccache 0.16.0 release;
no distribution sccache package is installed in the sealed build root.

## Required profile changes

- Replace the rule that Windows outputs must be produced by Windows processes
  with a rule that the target ABI/sysroot is Windows while the admitted build
  processes may be Linux-hosted LLVM.
- Replace `link.exe` with pinned `lld-link` for the hermetic Windows build lane.
- Treat xwin as a sysroot materializer, not as an unpinned live dependency.
- Retain and hash the xwin manifests and every selected Microsoft payload.
- Add the matching LLVM Windows compiler-rt runtime and MSVC ASan package to the
  Windows sanitizer profile.
- Define app-local CRT deployment for tests and packaged artefacts, or install a
  separately pinned redistributable in controlled runtime images.
- Make Ubuntu LTS a build environment only. Do not add Ubuntu as a third product
  or acceptance platform.

## Readiness gates added by this profile

1. Reject any process named `cl.exe`, `gcc`, or `g++` in retained build traces.
2. Verify the PE machine, imports, PDB/Repro debug entries, CFG load config,
   ASLR, NX, and high-entropy VA from final binaries.
3. Execute application and GoogleTest binaries on Windows, not under Wine.
4. Run a clean ASan test and a negative instrumentation self-test.
5. Build twice in distinct clean directories and compare EXE/PDB hashes.
6. Run native performance and formal-acceptance gates on Windows independently
   of the cross-build environment.
