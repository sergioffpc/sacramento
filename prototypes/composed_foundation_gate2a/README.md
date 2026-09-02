# PROTOTYPE: Debian authoritative core boundary

Question: Can the Debian Session Authority advance one fixed-tick PhysX
interaction through Flecs while its canonical state and digest remain entirely
Sacramento-owned and client-only dependencies remain absent?

This is throwaway Gate 2A evidence on `prototype/composed-foundation-spine`.
It must not merge into `develop`.

Run:

```sh
prototypes/composed_foundation_gate2a/run-gate2a.sh
```

The runner installs the pinned Flecs and PhysX ports into an isolated vcpkg
root, builds the headless authority twice with the approved Debian
cross-toolchain, compares the ELF files, executes the recorded scenario twice
against the pinned Debian runtime, and compares the complete canonical traces.
It also audits the public header and ELF dependencies for vendor leakage.
The Gate-local PhysX overlay builds release/static Linux x64 CPU support only;
it neither downloads nor installs NVIDIA's optional prebuilt PhysXGpu runtime.

Acceptance requires:

- 240 fixed ticks at 60 Hz;
- a PhysX sphere/plane interaction observed in the canonical trace;
- byte-identical traces and result documents across two executions;
- byte-identical authority ELF files across two clean build directories;
- no Flecs or PhysX types in the Sacramento public header; and
- no Falcor, Vulkan, Slang, Steam Audio, Assimp, or Tracy dependency in the
  headless authority ELF or target vcpkg dependency closure; and
- no PhysXGpu blob in the download inventory or installed tree.
