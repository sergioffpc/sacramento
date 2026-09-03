# Adopt a narrow NVIDIA-oriented Sacramento foundation

Status: Accepted as a conditional architectural direction; production dependency admission remains blocked

Purpose: Record the selected technology foundation and its principal trade-off.

Scope: Initial C++ runtime and cooker technologies.

Intended readers: Architects, implementers, and dependency reviewers.

Prerequisites: ADR-0001 and ADR-0002.

Canonical information owner: Project owner.

## Decision

Sacramento owns C++23 interfaces backed by Flecs, Falcor over Vulkan, Slang,
PhysX, GameNetworkingSockets, and Steam Audio. Assimp is confined to the Python
cooker; Tracy is diagnostic only. Vendor types do not cross Sacramento
interfaces, persistent formats, or network contracts.

The selection is conditional: every dependency and adapter still requires
qualification on the applicable Clang platforms before production admission.

## Rationale and consequences

The stack provides a focused foundation without making the headless Debian
authority depend on client rendering or audio. Sacramento accepts the cost of
qualifying unsupported vendor/toolchain combinations and the offline Falcor
vendor capsule; mechanisms that exceed the two-generalist maintenance ceiling
must be replaced behind the same interfaces.

The complete interface rules, qualification gates, exceptions, unproved
obligations, traces, and replacement conditions are canonical in the
[foundation architecture specification](../architecture/0003-nvidia-oriented-foundation.md).
