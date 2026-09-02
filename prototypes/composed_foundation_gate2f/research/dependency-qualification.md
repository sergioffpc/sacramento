# Gate 2F dependency qualification

## GameNetworkingSockets Windows crypto backend

- Upstream: ValveSoftware/GameNetworkingSockets commit
  `2cb93a06350bb065db53abdb0d87cf297e0bfd34` (release 1.6.0).
- Baseline vcpkg port: always selects OpenSSL. Its Windows OpenSSL port invokes
  `cmd.exe`, which is not available in the admitted Linux-hosted clang-cl
  environment.
- Upstream alternative: `USE_CRYPTO=BCrypt`, explicitly supported only on
  Windows and checked against the target SDK during configure.
- Gate-local decision: retain the exact upstream GNS source and build static,
  with `USE_CRYPTO=BCrypt`, ICE disabled, and the dynamic MSVC CRT. Remove the
  now-unused OpenSSL package edge.
- Boundary impact: BCrypt is a Windows platform service and remains behind the
  Sacramento-owned transport boundary inherited from Gate 2C.
- Scope: prototype-only overlay; it is evidence for the final dependency
  decision, not an approved production port.
