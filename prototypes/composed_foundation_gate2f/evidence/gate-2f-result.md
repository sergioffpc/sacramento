# Gate 2F result: literal rendered-client composition

Date: 2026-09-02

Cross-build status: **PASS**.

Native Windows/NVIDIA status: **PASS**.

## Verdict

One Windows Desktop Mode process literally composes the selected client-side
foundation behind Sacramento-owned seams. It receives a canonical snapshot
from the retained Debian Session Authority through GameNetworkingSockets,
creates a Falcor Vulkan device and Slang compute program, renders the
representative authoritative acoustic event through Steam Audio, and writes
the rendered participant's `CoreOnly` structured signal stream.

The accepted native run reported:

```json
{"status":"pass","composition":"literal","network":"GameNetworkingSockets","tick":120,"digest":"78cdbfce9a4619fa","renderer":"Falcor","api":"Vulkan","adapter":"NVIDIA GeForce RTX 5070 Ti","audio":"Steam Audio","pcm_fnv1a_64":"795bf250473883b0","observability_detail_level":"CoreOnly","tracy_linked":false}
```

The authority independently reported protocol version 1, one rendered client,
120 ticks at 60 Hz, aggregate position 32 mm, and the same digest. Its trace
contains exactly 120 records.

## Build and dependency evidence

- Two independently configured Windows builds are byte-identical.
- Executable: 8,834,048 bytes; SHA-256
  `488483465e893c8fcd4454b0070591ba9ee82331d0da8cd8ef82849d4194c8df`.
- Retained Windows dependency closure: 66,933,618 bytes.
- Relocatable native bundle: 227,361,891 bytes, including the Falcor runtime
  shader tree and required CRT/runtime DLLs.
- GNS is fixed at 1.6.0; Steam Audio is fixed at 4.8.1; Falcor is consumed from
  the immutable Gate 1C SDK.
- The link-map audit finds Falcor imports, static GameNetworkingSockets input,
  static Steam Audio input, and Sacramento observability in the same PE.
- The PE imports `Falcor.dll` and Windows platform libraries including
  `bcrypt.dll`; it does not import GNS, Steam Audio, Tracy, or OpenTelemetry
  DLLs.
- Tracy is absent from both the vcpkg closure and operational symbols. Gate 2E
  remains the separate diagnostic-profile proof.

The vcpkg baseline's OpenSSL Windows port requires `cmd.exe`, which the
Linux-hosted clang-cl environment intentionally lacks. GNS 1.6.0 natively
supports BCrypt on Windows, so the gate-local overlay retains the exact GNS
commit, selects `USE_CRYPTO=BCrypt`, disables unused ICE, and removes OpenSSL.
This is a prototype packaging exception to carry into the final dependency
decision, not a production port approval.

To update GNS, change its manifest override plus the overlay `REF` and SHA-512,
then rerun the gate from a fresh output root. To update Steam Audio, update the
Gate 2D overlay and Gate 2F manifest override together. Falcor updates must
first produce a new immutable Gate 1C SDK and then be supplied through
`SACRAMENTO_FALCOR_SDK`.

## Native evidence

The accepted Windows run used the WSL address rather than `127.0.0.1`. WSL's
Windows-to-Linux localhost forwarding did not carry the GNS UDP path: the first
attempt timed out without a `Hello`. The transport interface already accepted
a host argument, but its implementation rejected non-loopback addresses. It
now parses any explicit IP literal with the GNS parser. The rebuilt Gate 2C
Debian binaries remained byte-identical and their loopback regression retained
digest `78cdbfce9a4619fa`.

Native artifacts:

- stereo PCM: 10,816 bytes; SHA-256
  `d9f023aa5735603f8adaec7dace7a8e8279d1b482ce3c9442724768db9b6c060`;
- seven-record `OBS-CONTRACT-001` stream: 3,534 bytes; SHA-256
  `56ba2fc8a10b8ac92c3e9a1ed65ad615068bd1fb79b9a5b1d96a3e37440c6767`;
- authority result SHA-256:
  `6ab10b95da29d71ba4fbc463d49f886d0425ae1c9b0b1efe4f9887d678c86457`.

The structured stream includes runtime identity, action submission/result
presentation correlation, acoustic-event presentation correlation, and clean
lifecycle termination. Falcor emitted only its expected warning that Aftermath
on Vulkan supports basic crash dumps.

## Scope and remaining proof

Gate 2F closes the native/literal gaps left by Gates 2C, 2D, and 2E for the
rendered client. It deliberately reuses their minimal interactions rather than
adding production behavior.

It does not prove controlled-LAN loss/recovery, production admission/security,
real-time mixer/device behavior, Steam Audio reflections/pathing, sustained
frame performance, or a live Tracy capture. The native composition used one
rendered participant; Gate 2C separately proves one rendered role plus three
synthetic participants and launch-order-independent canonical output. The
overall architecture-driver and exception synthesis for issue #11 remains the
next gate.
