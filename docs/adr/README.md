# Architecture decisions

Start with the [architecture overview](../architecture/software-architecture-description.md).
Read a decision for its rationale and its linked contract for exact behavior.
Accepted decisions do not imply implementation or passing evidence.

| Decision | Subject |
| --- | --- |
| [0001](0001-use-clang-only-for-cpp.md) | Clang-only C++ toolchain |
| [0002](0002-cross-compile-windows-from-ubuntu-with-clang.md) | Windows cross-build and native execution |
| [0003](0003-adopt-nvidia-oriented-foundation.md) | Conditional dependency foundation |
| [0004](0004-decompose-by-canonical-responsibility.md) | Responsibility-oriented modules |
| [0005](0005-use-fixed-step-authoritative-runtime.md) | Fixed-step authoritative runtime |
| [0006](0006-isolate-runtime-owners-and-bound-failure.md) | Ownership, concurrency and bounded failure |
| [0007](0007-use-signed-scenario-bound-runtime-content-releases.md) | Paired immutable signed content |
| [0008](0008-retain-evidence-outside-ephemeral-session-state.md) | Evidence outside ephemeral session state |
| [0009](0009-expose-orchestration-neutral-runtime-deployment-contracts.md) | Orchestration-neutral runtime contracts |
| [0010](0010-close-cross-cutting-architecture-and-verification.md) | Cross-cutting ownership and verification; administrative policy superseded by 0014 |
| [0011](0011-establish-memory-accounting-and-allocation-boundaries.md) | Memory accounting and lifetime boundaries |
| [0012](0012-establish-runtime-resource-and-role-pack-architecture.md) | Exact Runtime Resource and role-pack contracts |
| [0013](0013-separate-offline-content-cooking-from-runtime-lifecycle.md) | Finite offline Content Cooker Tool |
| [0014](0014-use-lightweight-executable-documentation.md) | Lightweight arc42/C4/UML, ADRs and incremental acceptance |
