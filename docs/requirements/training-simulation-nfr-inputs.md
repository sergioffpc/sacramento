# Training Simulation NFR Interview Inputs

Status: Captured inputs; not an approved NFR specification

Purpose: Preserve accepted quality targets from the initial interview for a later, separate NFR document.

Scope: Non-normative quality, performance, hardware, availability, maintainability, and documentation inputs awaiting a separate NFR process.

Intended readers: Project owner, NFR authors, architects, designers, implementers, and verification authors.

Prerequisites: [Training Simulation Initial Requirements](training-simulation-initial-requirements.md) and [Training Simulation context](../../CONTEXT.md).

Canonical information owner: Project owner.

Normative effect: None until reviewed and approved in the NFR flow.

## Table of contents

- [Presentation performance](#presentation-performance)
- [Visual fidelity verification](#visual-fidelity-verification)
- [Acoustic verification](#acoustic-verification)
- [Network quality](#network-quality)
- [Authentication quality](#authentication-quality)
- [Hardware profiles](#hardware-profiles)
- [Availability](#availability)
- [Maintainability and documentation quality](#maintainability-and-documentation-quality)
- [Deliberately unspecified NFRs](#deliberately-unspecified-nfrs)
- [NFR-document entry condition](#nfr-document-entry-condition)

## Presentation performance

- Desktop candidate: 2560 × 1440 at 60 FPS on a versioned high-end consumer Reference Hardware Profile.
- Desktop frame-time candidates: 99% at or below 16.67 ms; 99.9% at or below 33.33 ms; no continuous client stall above 100 ms.
- Virtual-reality candidate: native configured headset resolution at 90 Hz on a separate high-end consumer profile, without counting synthesized or reprojected frames.
- VR frame-time candidates: 99% at or below 11.11 ms; 99.9% at or below 22.22 ms; no continuous client stall above 50 ms.

## Visual fidelity verification

- Candidate goal: enable correct perception of people, equipment, materials, distance, cover, and lighting for tactical decisions.
- Prefer recognition and tactical interpretation over subjective photorealism.
- Use controlled tasks covering people, posture, equipment, materials, cover, occlusion, distance, and lighting.
- Candidate evaluator group: at least five Representative Evaluators with recent relevant experience.
- Candidate pass criteria: 90% overall, no category below 80%, and no recurring safe-cover/exposure inversion.
- Candidate distances: 10, 25, 50, 100, and 150 metres across indoor, outdoor, and lighting-transition contexts.
- Visual tests use the fixed reference lighting and transitions defined by the functional requirements draft.

## Acoustic verification

- Candidate blind localization test: eight horizontal sectors of 45 degrees; above/level/below; indoor/outdoor where applicable.
- Candidate pass threshold: 90% correct in Desktop Mode and Virtual-Reality Mode.
- Candidate peak workload: 16 active weapon sources and four explosions initiated in one second, without loss of tactically relevant events.

## Network quality

- Accepted physical medium candidate: wired 1 Gbit/s Ethernet LAN.
- Degraded profile candidate: 50 ms RTT, 10 ms jitter, and 1% packet loss.
- Candidate behavior under degraded profile: no divergent canonical state, false disconnect, or silently lost acknowledged action.
- Candidate authority latency: 99% of valid actions produce authoritative results at all clients within 100 ms after Session Authority receipt, excluding intentional Acoustic Propagation delay.

## Authentication quality

- Define the maximum permitted uncertainty of Trusted Identity Time on Trainee client and Session Authority hosts when validating Offline-Verifiable Identity Evidence.
- Define the measurement method, reference time basis, holdover conditions for an isolated LAN, and the behavior when the permitted uncertainty cannot be established.
- Define maximum AUTH attempt and stage durations, supported concurrent-attempt load, retry rate, resource ceilings, and any non-identity-locking backoff behavior.
- Define measurable security-strength criteria for AUTH Protected Exchange confidentiality, integrity, peer binding, challenge uniqueness, authenticator control, stored claim protection, and audit integrity without selecting those mechanisms in the functional requirements.
- Define the permitted externally observable timing variation among failures mapped to the same AUTH Denial Category.
- Define AUTH Audit Record and checkpoint write throughput, retained-volume capacity, recovery-time, and external checkpoint-collection latency targets.

## Hardware profiles

- Maintain separate versioned Reference Hardware Profiles for Desktop Mode, Virtual-Reality Mode, and Session Authority.
- Profiles identify exact hardware, drivers, operating system, display or headset conditions, and runtime settings.
- Desktop and VR candidates use reproducible high-end consumer hardware rather than specialized workstations.
- Session Authority candidate uses a dedicated high-end consumer x86-64 machine rather than enterprise server hardware.

## Availability

- Candidate goal: keep the Session Authority continuously available for preparation and execution outside declared exclusions.
- Session Authority process candidate: operate 24/7 with 99.999% availability over a rolling 365-day window while host, operating system, power, and LAN remain healthy.
- Declared maintenance is excluded. No maximum maintenance duration or notice period was defined.
- Infrastructure redundancy, failover, power redundancy, and network high availability are out of the current scope.
- Automatic process recovery after failure was asked but not answered and remains open for the NFR interview.

## Maintainability and documentation quality

- Permanent software team constraint: no more than two human generalists supported by AI agents; specialists may review.
- Prefer bounded changes that require minimal system-wide context.
- Persistent project language: English.
- One purpose and one canonical information owner per document; use explicit prerequisites and pointers rather than duplication.
- Validate critical requirements through independent restatement and proposed verification.

## Deliberately unspecified NFRs

- No content-export, import, rebuild, or local iteration-time target.
- No financial limit or budget assumption.
- No delivery deadline.
- No planned-maintenance duration limit.

## NFR-document entry condition

Before treating any item above as normative, assign a stable requirement ID, define its measurement environment and evidence, resolve conflicts, and obtain explicit approval in the separate NFR interview.
