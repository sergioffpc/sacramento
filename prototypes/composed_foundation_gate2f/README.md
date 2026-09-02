# Composed Foundation Gate 2F

This throwaway prototype closes the literal-composition gap left by Gate 2C.
It cross-builds one Windows Desktop Mode process that, in sequence:

1. submits the rendered participant's scripted inputs to the Debian Session
   Authority over GameNetworkingSockets and receives the canonical snapshot;
2. initializes the retained Falcor Vulkan SDK and compiles a Slang program;
3. renders the representative authoritative acoustic event with Steam Audio;
4. writes the rendered participant's structured CoreOnly signal stream.

The operational executable intentionally does not link Tracy. Gate 2E already
proves that diagnostics remain a separate build profile.

## Run

```bash
SACRAMENTO_GATE2F_ROOT=/tmp/sacramento-composed-foundation-gate2f \
  ./prototypes/composed_foundation_gate2f/run-gate2f.sh
```

The script produces two byte-identical Windows builds, a relocatable native
test bundle, dependency and boundary audits, and a native-run checklist. The
native run requires Windows, Vulkan-capable NVIDIA hardware, and a reachable
Gate 2C Debian authority; cross-building alone is not reported as runtime
proof.

When Windows and the Debian authority run across WSL's virtual network, pass
the WSL address explicitly because Windows-to-WSL `localhost` forwarding does
not carry this UDP path:

```powershell
.\run-smoke.ps1 -AuthorityHost 172.21.88.99 -Port 39181 `
  -Script .\rendered.inputs
```
