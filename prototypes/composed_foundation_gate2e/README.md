# Composed foundation Gate 2E: observability and Tracy separation

This throwaway prototype asks whether Sacramento can emit the applicable
`OBS-CONTRACT-001` runtime identities and action/acoustic correlations as
structured NDJSON while keeping Tracy confined to a diagnostic-only adapter.

The gate builds separate `CoreOnly` and `Diagnostic` executables. The
`CoreOnly` binary neither links Tracy nor emits optional signals. The
`Diagnostic` binary preserves the same core semantics, adds one optional
diagnostic marker, and invokes Tracy only through the private adapter.
OpenTelemetry is not used.

Run the complete proof from a fresh output root:

```sh
SACRAMENTO_GATE2E_ROOT=/tmp/sacramento-composed-foundation-gate2e \
  prototypes/composed_foundation_gate2e/run-gate2e.sh
```

This evidence belongs only on `prototype/composed-foundation-spine`; it is not
production implementation and must not merge into `develop`.
