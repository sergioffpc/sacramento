# Composed Foundation Gate 1 Prototype

Status: Throwaway architecture prototype for issue #11

Question: Can Falcor 8.0 provide a Vulkan-only Windows rendering path, with
Slang 2024.1.34 producing SPIR-V, through Sacramento's pinned vcpkg and
Linux-hosted `clang-cl` toolchain without Packman, DirectX 12, or configure-time
downloads?

Run from the repository root:

```sh
SACRAMENTO_CPP_TOOLCHAIN_ROOT=/var/tmp/sacramento-cpp-toolchain \
  prototypes/composed_foundation_gate1/run-gate1.sh
```

The runner writes all generated files beneath
`/tmp/sacramento-composed-foundation-gate1` by default. Override that location
with `SACRAMENTO_GATE1_ROOT`; it must identify a disposable directory outside
the Git worktree.

The prototype performs four independently reported checks:

1. installs the pinned Vulkan headers and the matching Slang host compiler
   through vcpkg, using only the repository overlay port and registry baseline;
2. compiles the same Slang shader twice and requires byte-identical SPIR-V;
3. cross-builds a Windows C++23 probe with Vulkan headers using the approved
   Clang/MSVC-ABI toolchain; and
4. configures the exact Falcor 8.0 source with D3D12 explicitly disabled and
   records whether the configure remains offline and Vulkan-only.

The first three checks may pass while the fourth fails. That is a valid gate
result: it distinguishes a viable Vulkan/Slang/toolchain base from a Falcor
integration that violates the selected dependency and graphics policies.

Generated logs and hashes are retained in the disposable root's `evidence/`
directory. The checked-in [result](evidence/gate-1-result.md) records the exact
run used for the Wayfinder decision.
