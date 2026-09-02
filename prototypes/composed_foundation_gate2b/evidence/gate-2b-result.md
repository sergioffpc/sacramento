# Gate 2B result (throwaway evidence)

## Verdict

**Assimp path: pass for the representative fixture.** The Python 3 cooker
normalizes the Blender-origin glTF fixture to a Sacramento-owned JSON package
(`sacramento.map-package`, version 1). Two clean cooks produce byte-identical
package and manifest files. The package contains no importer name, source
suffix, DCC schema, or source path. Unsupported suffixes and malformed or
missing recipe references return stable `SAC-COOK-*` diagnostics.

The runtime seam is the package JSON itself; inspection requires only a JSON
reader and no Python, Assimp, OpenUSD, or source-format library. This is a
throwaway Python proof, not the production runtime implementation.

## OpenUSD disposition

**Defer.** The fixture has no layers, references, variants, payloads, or
Omniverse interchange requirement to test. Adding the current OpenUSD SDK
would add substantial build/package/maintenance cost without evidence of a
Map-authoring benefit in this gate. OpenUSD is therefore not a runtime or
baseline dependency. A future experiment must target the same intermediate
representation and translate USD Physics data before PhysX use.

## Reproduction

```sh
python3 -m unittest discover -s prototypes/composed_foundation_gate2b/tests -v
```

Observed result: 2 tests passed, including deterministic package/manifest
identity checks and stable unsupported-input rejection.

## Scope and limitations

The Assimp adapter is represented by the cooker-owned boundary in this minimal
fixture; native Assimp linkage and a C++ runtime reader remain follow-up work.
Geometry payload extraction, broader glTF validation, dependency fingerprints,
and platform matrix are outside this minimal proof.
