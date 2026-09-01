# PROTOTYPE: immutable Falcor SDK and native smoke handoff

Question: Can the Gate 1B Falcor build be reduced to one hash-addressed SDK
capsule and one Windows-native Vulkan/Slang/Aftermath smoke executable without
letting Packman enter a Sacramento product build?

This is throwaway Gate 1C evidence on the prototype branch. It must not merge
into `develop`.

Run after Gate 1B:

```sh
prototypes/composed_foundation_gate1c/run-gate1c.sh
```

The runner packages headers, import libraries, runtime DLLs, licences, Python,
and shader data from the pinned vendor capsule; hashes every packaged file;
creates a deterministic archive; and cross-builds `falcor_vulkan_smoke.exe`.
The executable explicitly requests Vulkan, enables Aftermath, and asks Falcor
to compile `gate1c.slang` through Slang. The smoke link uses `/Brepro` so two
clean builds from the same capsule produce the same PE executable.

Native execution remains a separate Windows/NVIDIA gate, as required by
ADR-0002. Copy the generated `smoke-build` directory to a native Windows
machine and run from that directory:

```powershell
.\run-smoke.ps1
```

A pass prints a JSON object containing `status: "pass"`, `api: "Vulkan"`, and
the selected NVIDIA adapter. The PowerShell acceptance wrapper rejects a process
failure, a non-Vulkan API, missing Aftermath, an empty adapter, or failure to
compile the Slang program.
