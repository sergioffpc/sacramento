# Training Simulation Reference Hardware Profiles

Status: Approved

Approval: Project owner, 2026-09-01

Profile-set version: `RHP-SET-001`

Purpose: Define the exact hardware and platform configurations used to verify the initial Training Simulation baseline.

Scope: Desktop Mode and Session Authority Reference Hardware Profiles. Virtual-Reality Mode belongs to a later baseline.

Intended readers: Project owner, requirements reviewers, architects, implementers, and verification authors.

Prerequisites: [Training Simulation context](../../CONTEXT.md), [Training Simulation Initial Requirements](training-simulation-initial-requirements.md), and [Training Simulation Non-Functional Requirements](training-simulation-non-functional-requirements.md).

Canonical information owner and approver: Project owner.

Normative effect: `RHP-DESKTOP-001` and `RHP-AUTHORITY-001` are the approved reference configurations for the initial NFR baseline.

## Table of contents

- [Desktop Mode profile](#desktop-mode-profile)
- [Session Authority profile](#session-authority-profile)
- [Completion rule](#completion-rule)

## Desktop Mode profile

Profile identifier: `RHP-DESKTOP-001`

| Field | Exact value or status |
| --- | --- |
| Role | Desktop Mode Trainee client |
| System | Lenovo ThinkStation P620 |
| Processor | AMD Ryzen Threadripper PRO 3975WX; 32 cores, 64 threads, 3.50 GHz base frequency |
| Memory | 128 GB usable; module-level composition is not fixed by this profile |
| Graphics | NVIDIA GeForce RTX 5070 Ti, 16 GB, VBIOS 98.03.58.00.92 |
| Storage | 2 × Verbatim Vi3000 NVMe SSD, 1,024,209,543,168 bytes each, healthy; Training Simulation runtime and content on `C:` |
| Network interface | Physical `Ethernet` interface using a Marvell AQtion 10-Gigabit network adapter with an active 1-gigabit-per-second negotiated link; Hyper-V/WSL and Bluetooth adapters are excluded from the Controlled LAN acceptance path |
| Operating system | Windows 11 Pro 25H2, 64-bit, build 26200.9168; Windows Feature Experience Pack 1000.26100.344.0 |
| Graphics driver | NVIDIA 576.88 |
| Display | LG HDR DQHD 49-inch ultrawide, EDID `GSM9E7B`, connected through DisplayPort; Windows reports an active 5120 × 1440 output at 60 Hz, supporting the required window with a 2048 × 1080-pixel client presentation area |
| Audio output | Sony WH-1000XM4 headphones connected through Bluetooth as stereo output only, with the headset microphone unused and Windows spatial sound disabled |
| Test-run evidence | BIOS and firmware versions, input devices, Windows power mode, active background services, application build, application configuration, and measured resource state; recorded for each acceptance run but not fixed by this profile |

## Session Authority profile

Profile identifier: `RHP-AUTHORITY-001`

| Field | Exact value or status |
| --- | --- |
| Role | Dedicated Session Authority |
| System | Dell PowerEdge R630 |
| Processor | 2 × Intel Xeon E5-2690 v4 at 2.60 GHz; 14 cores and 28 threads per socket, 28 cores and 56 threads total |
| Memory | 256 GB as 8 × 32 GB DDR4 multi-bit ECC modules at 2133 MT/s configured speed; part number M386A4G40DM0-CPB; occupied slots A1–A4 and B1–B4 |
| Storage and controller | One 930.5 GiB logical disk exposed by a Dell PERC H330 Mini based on the Broadcom/LSI MegaRAID SAS-3 3008; physical-drive composition and RAID level are outside this profile |
| Network interface | 2 × Intel 82599ES 10-Gigabit SFI/SFP+ ports and 2 × Intel I350 Gigabit ports; active `eno1` maps to PCI 01:00.0 and one Intel 82599ES port, with an active 1-gigabit-per-second full-duplex negotiated link; physical medium is not fixed by this profile |
| Operating system | Debian GNU/Linux 13.6 (`trixie`) amd64, kernel 6.12.105+deb13-amd64 |
| Test-run evidence | BIOS and firmware versions, Debian configuration, active services, application build, application configuration, and measured resource state; recorded for each acceptance run but not fixed by this profile |

## Completion rule

A future profile definition is ready for approval when every fixed field required by `REQ-PLATFORM-ACCEPTANCE-PROFILE-001` has one reproducible value, every variable configuration field to be captured as test-run evidence is identified, and the project owner approves the exact profile version. Approval defines the acceptance target; an implemented product/profile combination receives `Pass` only after its complete acceptance procedure succeeds.
