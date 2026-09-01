# PROTOTYPE: C++ Toolchain Proof

Status: Throwaway verification harness

Question: Can `CPP-ENGINEERING-BASELINE-001` be executed consistently with
Clang-only native Windows and Debian toolchains?

This directory is not production engine code. It exists only on the
`prototype/cpp-toolchain-proof` branch and must not be merged into an integration
branch. The normative decisions remain in
[`docs/standards/cpp-engineering.md`](../../docs/standards/cpp-engineering.md).

## Run

On a provisioned Debian proof runner:

```bash
./scripts/proof.sh verify
./scripts/proof.sh pr
```

On a provisioned native Windows proof runner:

```powershell
.\scripts\proof.ps1 verify
.\scripts\proof.ps1 pr
```

Both wrappers invoke the same `scripts/proof.py` implementation. Generated
builds and evidence stay below this prototype directory and are ignored by Git.

The runner must provide the exact tools and environment recorded in
`config/toolchains.json`. Set `VCPKG_ROOT` to the pinned vcpkg checkout. A
verification failure is evidence; do not replace a pinned input silently.

## Outputs

- `evidence/readiness.json`: machine-readable readiness result;
- `evidence/readiness.md`: human-readable readiness matrix;
- `evidence/commands/`: captured commands and output;
- `evidence/artifacts/`: hashes and binary inspection output.

The prototype may report `Blocked` when a native runner or exact retained input
is unavailable. Only an all-pass result on both native platforms can admit
first-party production C++.
