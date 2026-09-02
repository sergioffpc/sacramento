#!/usr/bin/env python3
"""Throwaway Gate 2B Sacramento Map cooker."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys


ADMITTED_SOURCE_SUFFIXES = frozenset(
    {".glb", ".gltf", ".usd", ".usda", ".usdc"}
)


def _parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", required=True, type=Path)
    parser.add_argument("--recipe", required=True, type=Path)
    parser.add_argument("--adapter", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--manifest", required=True, type=Path)
    return parser.parse_args()


def _reject(code: str, detail: str) -> int:
    json.dump({"code": code, "detail": detail}, sys.stderr, sort_keys=True)
    sys.stderr.write("\n")
    return 2


def _load_source_interchange(
    adapter: Path, source: Path
) -> tuple[dict[str, object] | None, int | None]:
    adapter_environment = {"PATH": os.defpath}
    if python_path := os.environ.get("SACRAMENTO_GATE2B_ADAPTER_PYTHONPATH"):
        adapter_environment["PYTHONPATH"] = python_path
    try:
        result = subprocess.run(
            [str(adapter), str(source)],
            check=False,
            capture_output=True,
            text=True,
            env=adapter_environment,
        )
    except OSError:
        return None, _reject(
            "SAC-COOK-ADAPTER-UNAVAILABLE", "native source adapter is unavailable"
        )

    if result.returncode != 0:
        try:
            diagnostic = json.loads(result.stderr)
        except json.JSONDecodeError:
            diagnostic = None
        if (
            isinstance(diagnostic, dict)
            and isinstance(diagnostic.get("code"), str)
            and diagnostic["code"].startswith("SAC-COOK-")
            and isinstance(diagnostic.get("detail"), str)
        ):
            return None, _reject(diagnostic["code"], diagnostic["detail"])
        return None, _reject(
            "SAC-COOK-ADAPTER-FAILED", "native source adapter rejected the source"
        )

    try:
        interchange = json.loads(result.stdout)
    except json.JSONDecodeError:
        return None, _reject(
            "SAC-COOK-ADAPTER-PROTOCOL", "native source adapter returned invalid interchange"
        )
    if (
        not isinstance(interchange, dict)
        or interchange.get("format") != "sacramento.map-import"
        or interchange.get("version") != 1
    ):
        return None, _reject(
            "SAC-COOK-ADAPTER-PROTOCOL", "native source adapter returned unsupported interchange"
        )
    return interchange, None


def main() -> int:
    arguments = _parse_arguments()
    source_suffix = arguments.source.suffix.lower()
    if source_suffix not in ADMITTED_SOURCE_SUFFIXES:
        return _reject(
            "SAC-COOK-UNSUPPORTED-SOURCE",
            f"source format is not admitted: {source_suffix or '<none>'}",
        )

    interchange, failure = _load_source_interchange(
        arguments.adapter, arguments.source
    )
    if failure is not None:
        return failure

    try:
        recipe = json.loads(arguments.recipe.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        return _reject("SAC-COOK-MALFORMED-RECIPE", f"cannot read recipe: {exc}")

    if recipe.get("package_format_version") != 1:
        return _reject("SAC-COOK-UNSUPPORTED-VERSION", "package_format_version must be 1")
    assert interchange is not None
    nodes = {node.get("name"): node for node in interchange.get("nodes", [])}
    materials = {
        material.get("name"): material for material in interchange.get("materials", [])
    }
    meshes = {mesh.get("source_node"): mesh for mesh in interchange.get("meshes", [])}
    for anchor in recipe.get("anchors", []):
        if anchor.get("source_node") not in nodes:
            return _reject(
                "SAC-COOK-MISSING-NODE",
                f"anchor source node is absent: {anchor.get('source_node')}",
            )
    for material in recipe.get("materials", []):
        if material.get("source_material") not in materials:
            return _reject(
                "SAC-COOK-MISSING-MATERIAL",
                f"material source is absent: {material.get('source_material')}",
            )
    for mesh in recipe.get("meshes", []):
        if mesh.get("source_node") not in meshes:
            return _reject(
                "SAC-COOK-MISSING-MESH",
                f"mesh source is absent: {mesh.get('source_node')}",
            )

    content = {
        "map_id": recipe["map_id"],
        "anchors": [
            {
                "id": anchor["id"],
                "translation": [
                    float(axis)
                    for axis in nodes[anchor["source_node"]]["translation"]
                ],
            }
            for anchor in recipe["anchors"]
        ],
        "materials": [
            {"id": material["id"], "shader_id": material["shader_id"]}
            for material in recipe["materials"]
        ],
        "meshes": [
            {
                "id": mesh["id"],
                "material_id": mesh["material_id"],
                "positions": [
                    [float(axis) for axis in position]
                    for position in meshes[mesh["source_node"]]["positions"]
                ],
                "indices": [
                    int(index) for index in meshes[mesh["source_node"]]["indices"]
                ],
            }
            for mesh in recipe["meshes"]
        ],
        "colliders": [
            {
                "id": collider["id"],
                "mesh_id": collider["mesh_id"],
                "type": collider["type"],
            }
            for collider in recipe["colliders"]
        ],
    }
    canonical = json.dumps(
        content, ensure_ascii=False, separators=(",", ":"), sort_keys=True
    ).encode()
    package = {
        "format": "sacramento.map-package",
        "version": 1,
        "content": content,
        "content_identity": "sha256:" + hashlib.sha256(canonical).hexdigest(),
    }
    package_bytes = (
        json.dumps(
            package, ensure_ascii=False, separators=(",", ":"), sort_keys=True
        ).encode()
        + b"\n"
    )
    manifest = {
        "format": "sacramento.map-manifest",
        "version": 1,
        "package_identity": "sha256:" + hashlib.sha256(package_bytes).hexdigest(),
        "content_identity": package["content_identity"],
    }
    try:
        arguments.output.parent.mkdir(parents=True, exist_ok=True)
        arguments.manifest.parent.mkdir(parents=True, exist_ok=True)
        arguments.output.write_bytes(package_bytes)
        arguments.manifest.write_text(
            json.dumps(manifest, sort_keys=True, separators=(",", ":")) + "\n",
            encoding="utf-8",
        )
    except OSError as exc:
        return _reject("SAC-COOK-OUTPUT-ERROR", str(exc))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
