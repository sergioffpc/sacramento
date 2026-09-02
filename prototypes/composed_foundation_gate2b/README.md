# PROTOTYPE: cooker-owned Map asset seam

Question: Can a Python 3 cooker import one Blender-origin Map fixture through
Assimp, normalize it to a Sacramento-owned intermediate representation, and
emit a deterministic, versioned Sacramento runtime package without exposing a
source importer, source path, DCC schema, or vendor type to runtime targets?

This is throwaway Gate 2B evidence on
`prototype/composed-foundation-spine`. It must not merge into `develop`.

OpenUSD is evaluated only after the Assimp path passes. It is a candidate
cooker-only frontend behind the same intermediate representation, not a
selected runtime or baseline dependency.

## Run

From the repository root, use fresh output roots outside the worktree:

```sh
SACRAMENTO_GATE2B_ROOT=/tmp/sacramento-gate2b-final \
  prototypes/composed_foundation_gate2b/run-gate2b.sh
SACRAMENTO_GATE2B_ROOT=/tmp/sacramento-gate2b-final \
  prototypes/composed_foundation_gate2b/run-openusd-experiment.sh
```

The first command builds the Assimp 6.0.5 overlay, two native adapter/runtime
reader builds, the public-interface tests, and two clean cooks. The second
command is deliberately ordered after that pass: it downloads the exact
`usd-core 26.8` wheel, verifies its hash and native closure, exercises the
composition fixture, and compares its cooked bytes with the Assimp result.

## Acceptance contract

- cook one Blender-origin Map fixture with one stable Sacramento anchor, one
  material and shader identity, render geometry, collision geometry, package
  format version, and content-integrity identity;
- keep Assimp inside the Python 3 cooker process and behind a Sacramento-owned
  adapter interface;
- keep Assimp, OpenUSD, Python, source formats, DCC schemas, and source paths
  out of the Sacramento runtime package and runtime consumer;
- produce byte-identical packages and manifests from two clean cooks;
- load and inspect the package with a minimal C++23 runtime consumer;
- reject malformed or unsupported input with a stable Sacramento diagnostic;
- inventory exact dependency/source/licence identities, package size, clean
  cook time, update procedure, and platform limits; and
- evaluate current OpenUSD composition semantics and record either
  `optional cooker frontend` or `defer`, with evidence.

## Confirmed test seams

Issue #22 fixes the public behavior, so tests cross only these two seams:

1. `cook.py`: source fixture plus Sacramento recipe in; cooked package,
   manifest, stable diagnostic, and process result out.
2. `sacramento_gate2b_runtime_reader`: cooked package in; Sacramento-owned
   inspection result and process result out.

The Assimp and possible OpenUSD adapters are internal seams. Their vendor
objects are normalized before reaching either confirmed interface, and they
are tested through `cook.py`, not through vendor-facing test interfaces.

## Result

The representative Assimp path passes. The isolated OpenUSD composition path
also passes and produces the same package bytes, supporting the gate-local
disposition `optional cooker frontend`. See
[`evidence/gate-2b-result.md`](evidence/gate-2b-result.md) for the measured
result and limitations. This does not admit OpenUSD into ADR-0003 or any
runtime target.
