# Establish responsibility-owned memory accounting and allocation boundaries

Status: Accepted

Approval: Project owner, 2026-09-04

Purpose: Record the CPU and GPU memory accounting, allocation, budget, and
failure-boundary decision.

Scope: Real-time Trainee Client and Session Authority runtime memory.

Intended readers: Architects, designers, implementers, performance engineers,
and verification authors.

Prerequisites: ADR-0003 through ADR-0010 and the approved C++ engineering,
non-functional, observability, and verification baselines.

Canonical information owner: Project owner.

## Decision

The Trainee Client Runtime and Session Authority Runtime use a small Sacramento
memory-resource seam whose accounting keeps semantic owner, lifetime domain,
and concrete resource as separate dimensions. CPU requested, allocator
capacity, process private commit, process resident memory, and GPU usage and
budget remain distinct quantities. Asynchronous work carries an explicit
Memory Resource Context, and every lifetime domain has an explicit release
fence.

The first implementation increment provides bounded, non-recursive visibility
only. Cheap counters remain active in test and production builds without
changing the approved `CoreOnly` Observability catalogue; allocation events,
addresses, source locations, callstacks, and detailed profiling remain
Diagnostic. Memory budgets are immutable launch-selected configuration owned
by the responsibility module whose resources they govern. Specialized CPU or
GPU allocators require representative native evidence and no library is
selected by this decision. After `ProcessReady`, a Measured Real-Time Hot Loop never
reaches the general-purpose heap, grows backing storage, or uses a fallback
that does either; any permitted scratch or pool allocation is already
provisioned and bounded.

## Rationale and consequences

Separating accounting from allocation policy preserves the canonical module
decomposition and exposes retained or unattributed memory without pretending
that one number means “memory used.” A Sacramento seam prevents PMR, operating
system, graphics API, allocator, and CRT choices from becoming module
contracts. Explicit propagation and fences preserve attribution and lifetime
under asynchronous scheduling and GPU execution.

This choice adds stable counter, snapshot, budget, failure, and benchmark
contracts. It deliberately defers numeric budgets, headroom, thresholds,
allocator specialization, general-heap replacement, GPU suballocator choice,
and final soak duration until measurements justify them. The detailed
quantities, domains, failure matrix, evidence gates, alternatives, and traces
are in the [memory architecture specification](../architecture/0011-memory-accounting-and-allocation.md).
