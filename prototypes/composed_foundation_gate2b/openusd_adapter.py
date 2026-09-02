#!/usr/bin/env python3
"""Isolated OpenUSD 26.08 experiment behind the Gate 2B import seam."""

from __future__ import annotations

import json
from pathlib import Path
import sys

from pxr import Usd, UsdGeom


def _reject(detail: str) -> int:
    json.dump({"code": "SAC-COOK-MALFORMED-SOURCE", "detail": detail}, sys.stderr)
    sys.stderr.write("\n")
    return 2


def _triangulate(counts: list[int], source_indices: list[int]) -> list[int]:
    result: list[int] = []
    offset = 0
    for count in counts:
        if count < 3:
            raise ValueError("OpenUSD mesh contains a face with fewer than three vertices")
        face = source_indices[offset : offset + count]
        for index in range(1, count - 1):
            result.extend((face[0], face[index], face[index + 1]))
        offset += count
    if offset != len(source_indices):
        raise ValueError("OpenUSD mesh topology is inconsistent")
    return result


def main() -> int:
    if len(sys.argv) != 2:
        return _reject("OpenUSD adapter expects one source path")
    source = Path(sys.argv[1])
    try:
        stage = Usd.Stage.Open(str(source), load=Usd.Stage.LoadNone)
        if stage is None:
            return _reject("OpenUSD could not open the root layer")
        root = stage.GetRootLayer()
        yard = stage.GetPrimAtPath("/World/TrainingYard")
        if len(root.subLayerPaths) != 1 or len(stage.GetUsedLayers()) < 3:
            return _reject("OpenUSD layer composition was not exercised")
        if not yard or not yard.HasAuthoredReferences() or not yard.HasAuthoredPayloads():
            return _reject("OpenUSD references and payloads were not composed")
        variants = yard.GetVariantSets()
        if "surface" not in variants.GetNames() or variants.GetVariantSelection("surface") != "concrete":
            return _reject("OpenUSD variant selection was not composed")
        if yard.GetAttribute("sacramento:layerEvidence").Get() != "set-dressing":
            return _reject("OpenUSD sublayer opinion was not composed")

        stage.Load("/World/TrainingYard")
        mesh_prim = stage.GetPrimAtPath("/World/TrainingYard/MapSurface")
        anchor_prim = stage.GetPrimAtPath("/World/TrainingYard/AnchorSpawnAlpha")
        mesh = UsdGeom.Mesh(mesh_prim)
        anchor = UsdGeom.Xformable(anchor_prim)
        if not mesh or not anchor or not mesh_prim.IsLoaded() or not anchor_prim.IsLoaded():
            return _reject("OpenUSD required payload was not loaded")

        positions = [[float(axis) for axis in point] for point in mesh.GetPointsAttr().Get()]
        indices = _triangulate(
            [int(count) for count in mesh.GetFaceVertexCountsAttr().Get()],
            [int(index) for index in mesh.GetFaceVertexIndicesAttr().Get()],
        )
        translation = [
            float(axis) for axis in anchor.GetLocalTransformation().ExtractTranslation()
        ]
        material = yard.GetAttribute("sacramento:material").Get()
        if material != "Concrete":
            return _reject("OpenUSD material variant did not resolve")
    except (RuntimeError, ValueError) as exc:
        return _reject(str(exc))

    json.dump(
        {
            "format": "sacramento.map-import",
            "version": 1,
            "nodes": [
                {"name": "MapSurface", "translation": [0.0, 0.0, 0.0]},
                {"name": "AnchorSpawnAlpha", "translation": translation},
            ],
            "materials": [{"name": material}],
            "meshes": [
                {
                    "source_node": "MapSurface",
                    "positions": positions,
                    "indices": indices,
                }
            ],
        },
        sys.stdout,
        ensure_ascii=False,
        separators=(",", ":"),
        sort_keys=True,
    )
    sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
