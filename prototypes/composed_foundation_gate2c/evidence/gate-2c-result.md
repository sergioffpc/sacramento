# Gate 2C result: network transport and deterministic exchange

Date: 2026-09-02

Status: **PASS** for the scoped Debian transport/determinism seam; **UNPROVED**
for a natively connected Falcor-rendering Windows client.

## Verdict

GameNetworkingSockets 1.6.0 can remain behind a Sacramento-owned transport
adapter while four independent client processes connect over loopback to one
Debian Session Authority. One client declares the rendered-client role and
three declare the synthetic-client role. All use the same Sacramento protocol
and receive the same final canonical snapshot.

The authority waits for complete recorded inputs, orders them by canonical tick
and Sacramento client identity, and then advances 120 integer-state ticks at
60 Hz. Reversing client launch and connection order produced byte-identical
traces, authority results, and per-client results. The exact final digest is
`b30d965287a57f09`.

This proves the transport boundary and deterministic state-exchange design for
the exact Debian binary, loopback topology, reliable message mode, script, and
ordering policy. It does not prove packet-loss behavior, a Controlled LAN,
Windows transport build/runtime, or integration of the already-proven Gate 1C
Falcor renderer with this client process. The rendered-role process is a narrow
networking stand-in, so issue #11's literal rendered-client connection remains
unproved until the two gates are composed.

## Sacramento-owned wire and authority contract

The version-1 wire header is 12 bytes, little endian:

| Field | Width | Meaning |
| --- | ---: | --- |
| magic | 32 bits | `0x53414332` |
| version | 16 bits | `1` |
| message kind | 16 bits | closed values 1 through 4 |
| payload length | 32 bits | exact following byte count, maximum 64 |

Payloads use only declared unsigned/signed integer widths and the closed
Sacramento `ClientRole`. The messages are `Hello`, `CanonicalInput`,
`InputComplete`, and `CanonicalSnapshot`; no native layout, pointer, enum
representation, vendor schema, or floating-point value is serialized. The
probe fixes the 17 bytes of a representative Hello and proves decode
round-trip, unknown-version rejection (`SAC-NET-PROTOCOL-VERSION`), and length
rejection (`SAC-NET-PROTOCOL-LENGTH`).

GameNetworkingSockets handles only connection, reliable payload delivery, and
disconnect notification in `gns_transport.cpp`. Public `protocol.hpp` and
`transport.hpp` expose only Sacramento and standard-library types. The boundary
audit found no GameNetworkingSockets, Steam Networking, Protobuf, OpenSSL, or
Abseil token in public headers or outside the single adapter implementation.

At each tick the authority applies inputs sorted by `(tick, client_id)`, then
hashes protocol version, tick, ascending client identity, role, and signed
integer position in explicit little-endian form using rolling FNV-1a. Socket
handles, connection order, packet arrival order, addresses, wall time, and
vendor objects never enter canonical state or the digest.

## Determinism and timing evidence

Run A launched clients `1,2,3,4`; Run B launched `4,3,2,1`. Both used separately
bound loopback ports and independently created transport connections.

| Observation | Result |
| --- | ---: |
| canonical ticks | 120 |
| canonical tick rate | 60 Hz |
| connected clients | 1 rendered-role + 3 synthetic |
| final aggregate position | 132 mm |
| final digest | `b30d965287a57f09` |
| trace rows / bytes | 120 / 8,170 |
| trace SHA-256 | `9c0a2bc618746f0246472652949421a3ba9c8df3076cd6056c8bf703b4e50c8a` |
| result SHA-256 | `2b016a9744b5eb06c9ac89ae1594ce39ad334a8c83325195fffdb88576ad8c54` |
| Run A simulation / maximum tick lateness | 2,000,160 us / 130 us |
| Run B simulation / maximum tick lateness | 2,000,163 us / 182 us |

The timing values are two observations on the Gate host, not performance
budgets. The authority deliberately runs in real time with `sleep_until`; it
does not test overload policy, missed-tick recovery, long-duration drift, or
production scheduler priority.

## Build and runtime artifacts

Two independent CMake/Ninja build roots produced byte-identical final
executables after the final source update:

| Artifact | Size | SHA-256 | ELF Build ID |
| --- | ---: | --- | --- |
| authority | 10,204,248 bytes | `c1b0981a106e8c2b0146cbe50037deee747d6f6f316c982beac31c96826970d3` | `a2746edc8c4364a39e90f151413a833a6e07265a` |
| client | 10,192,272 bytes | `fd3278822ad7415e73305208417553dea421b57102cd4655b1daf3a9f0566e33` | `0d945b7bbea3d44a12229a042ce859a4c8b24bc3` |
| protocol probe | 21,048 bytes | `df88c13afb83a61d1a408fd654e8a50e3f813f38727f15a191eda472d2e2d5c4` | `3922a150904923c297e8e7f70d70e0b7b3f3eab1` |

The initial clean project builds measured 3,654 ms and 3,652 ms. Those are
single host observations and exclude the dependency build. A fully fresh
vcpkg closure with concurrency capped at eight took 6.5 minutes, dominated by
the host Protobuf build.

Both network executables have only `libstdc++.so.6`, `libm.so.6`,
`libgcc_s.so.1`, and `libc.so.6` as `DT_NEEDED` entries. GameNetworkingSockets,
OpenSSL, Protobuf, Abseil, and utf8-range are linked statically. Flecs, PhysX,
Falcor, Vulkan, Slang, Steam Audio, Assimp, Tracy, CUDA, and OptiX are absent
from the package and ELF closures.

## Dependency and licence closure

The registry is pinned to
`9e593bb18ea69cc5095e012465dcd675a822ed0d`. ICE is disabled; no STUN, TURN, or
WebRTC feature is built.

| Target package | Version | ABI | Licence |
| --- | --- | --- | --- |
| GameNetworkingSockets | 1.6.0 | `e6d76dede607153fa0c849b5186dd095afca16151fd613dee67d1b66bf9f8ced` | BSD-3-Clause |
| OpenSSL | 3.6.3 | `bc812de0dcb930bf731dc35d094a711eb54b334db0aae648d3444a24e83e92d2` | Apache-2.0 |
| Protobuf | 6.33.4#2 | `ea94816d751185243bdc9fd40bd316f4bdcc8e3332fe3779d18a2c3cfe0f5951` | BSD-3-Clause |
| Abseil | 20260107.1#3 | `613b5e35570cf2e6eb95b6bfb82337a0cd802aa4e3adccf8ce70fa06f9133384` | Apache-2.0 |
| utf8-range | 6.33.4 | `6525e918ec49899d597071b12b4231f6c59064acf806f344a50ba822af5c3223` | MIT |

The host closure additionally builds Protobuf, Abseil, and utf8-range plus
`vcpkg-cmake`, `vcpkg-cmake-config`, and `vcpkg-cmake-get-vars`. Every installed
copyright file and download name is hashed/inventoried by the runner.

GameNetworkingSockets is upstream commit
`2cb93a06350bb065db53abdb0d87cf297e0bfd34`; its archive SHA-512 is
`c2deaa3aab42cd840dd13560ca4da40faa375ab846ea15af38d55eb7acc48cfe8cbdbe0c76b9c3484d26f9e1163e36ac1eb73a317e5c19cefe60d0b861d19e06`.
The transitive source archives and refs retained in vcpkg SPDX evidence are:

- OpenSSL `openssl-3.6.3`, SHA-512
  `a89c08101fa1d7e3c09b14f4a90d450bcf336a4f6a3e6e4ea990e4deddcd9ce250472f9114438fd134ff4b47fe93dd47232308567088b2b1c0b2eb50e3b56bdf`;
- Protobuf/utf8-range `v33.4`, SHA-512
  `540059a93721447cf4723bcca06e91c43a4399cb366c05bf84e9d8e2c439f3107ba17803f9d912549b54c471f2dcc4c9fc834145ec441dff31ca24f9a3543aa9`;
  and
- Abseil `20260107.1`, SHA-512
  `f5012885d6b6844a9cf5ed92ad5468b8757db33dfe1364bfb232fff928e06c550c7eb4557f45186a8ac4d18b178df9be267681abab4a6de40823b574afbe9960`.

## Qualification exceptions and limits

- The sealed Ubuntu root does not contain GNU Make. The OpenSSL port requires
  it, so the gate binds the host's GNU Make 4.4.1 after requiring SHA-256
  `27c9f6d806aee15882b01c2c61848f7aa75caa14bc7b6f608ba422f9e46a7d49`.
  Make must become a sealed build-tool input before production admission.
- The repository Debian chainload toolchain replaces `CMAKE_FIND_ROOT_PATH`
  with only the sysroot, hiding vcpkg target packages from `find_library` and
  `find_path`. The gate-local wrapper appends the exact vcpkg target prefix.
  The shared cross-vcpkg composition needs a production correction.
- The pinned vcpkg tool downloads CMake 4.4.0 while the Sacramento consumer
  remains on approved CMake 4.2.3. This is the same bootstrap exception found
  by earlier gates.
- Static GameNetworkingSockets brings a materially larger closure than its
  public transport surface suggests: Protobuf, Abseil, utf8-range, and OpenSSL.
  The two network executables are about 10.2 MB each. This maintenance and
  build-time cost must be included in the final two-generalist assessment.
- Open-source GameNetworkingSockets encryption is transport protection, not
  Sacramento Admission, AUTH Protected Exchange, continuity, authorization,
  audit commit, or identity evidence. None of those are claimed here.
- Only IPv4 loopback, reliable messages, four clients, one short input set, and
  orderly completion are exercised. Malformed authenticated traffic, rate
  limits, fragmentation boundaries, unreliable delivery, loss/reordering,
  congestion, disconnect/reconnect, state restoration, NAT/ICE, IPv6,
  Controlled-LAN behavior, Windows ABI/runtime, and long-duration load remain
  unproved.

## Update procedure and first-party cost

The first-party experiment contains 253 lines in the sole vendor adapter, 175
in the Sacramento codec, 119 public-header lines, and 291 authority/client
driver lines. A dependency update requires:

1. change only the manifest override;
2. inspect the new vcpkg port source ref/hash, features, patches, exported CMake
   targets, direct/transitive versions, licences, ABIs, and download inventory;
3. run the gate from a fresh output root;
4. require byte-identical clean builds and the two reversed-order replay
   results; and
5. keep protocol bytes/digest unchanged unless an intentional Sacramento wire
   version changes them.

No vendor identifier should change outside `gns_transport.cpp` for an ordinary
transport upgrade. A change to `protocol.hpp`, canonical ordering, or digest
rules is a Sacramento protocol change, not a dependency update.

## Reproduction

Run:

```sh
SACRAMENTO_GATE2C_ROOT=/tmp/sacramento-composed-foundation-gate2c-final \
  prototypes/composed_foundation_gate2c/run-gate2c.sh
```

The output root must not already exist. The runner verifies the toolchain,
builds the exact closure, builds twice, probes protocol rejection, launches the
two four-client replays in opposite orders, compares every deterministic
artifact, audits public/vendor and ELF boundaries, and captures hashes,
licences, timings, and inventories. A sandboxed agent must be granted localhost
socket access; the binaries do not contact a non-loopback address.
