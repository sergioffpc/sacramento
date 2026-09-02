#!/usr/bin/env python3
"""Throwaway Gate 2B Sacramento Map cooker."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import sys


ADMITTED_SOURCE_SUFFIXES = frozenset({".glb", ".gltf"})


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


def main() -> int:
    arguments = _parse_arguments()
    source_suffix = arguments.source.suffix.lower()
    if source_suffix not in ADMITTED_SOURCE_SUFFIXES:
        return _reject(
            "SAC-COOK-UNSUPPORTED-SOURCE",
            f"source format is not admitted: {source_suffix or '<none>'}",
        )

    try:
        source = json.loads(arguments.source.read_text(encoding="utf-8"))
        recipe = json.loads(arguments.recipe.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        return _reject("SAC-COOK-MALFORMED-SOURCE", f"cannot read source or recipe: {exc}")

    if recipe.get("package_format_version") != 1:
        return _reject("SAC-COOK-UNSUPPORTED-VERSION", "package_format_version must be 1")
    nodes = {node.get("name") for node in source.get("nodes", [])}
    materials = {material.get("name") for material in source.get("materials", [])}
    for anchor in recipe.get("anchors", []):
        if anchor.get("source_node") not in nodes:
            return _reject("SAC-COOK-MISSING-NODE", f"anchor source node is absent: {anchor.get('source_node')}")
    for material in recipe.get("materials", []):
        if material.get("source_material") not in materials:
            return _reject("SAC-COOK-MISSING-MATERIAL", f"material source is absent: {material.get('source_material')}")

    content = {
        "map_id": recipe["map_id"],
        "anchors": [{"id": a["id"]} for a in recipe["anchors"]],
        "materials": [{"id": m["id"], "shader_id": m["shader_id"]} for m in recipe["materials"]],
        "meshes": [{"id": m["id"], "material_id": m["material_id"]} for m in recipe["meshes"]],
        "colliders": [{"id": c["id"], "mesh_id": c["mesh_id"], "type": c["type"]} for c in recipe["colliders"]],
    }
    canonical = json.dumps(content, ensure_ascii=False, separators=(",", ":"), sort_keys=True).encode()
    package = {"format": "sacramento.map-package", "version": 1,
               "content": content, "content_identity": "sha256:" + __import__('hashlib').sha256(canonical).hexdigest()}
    package_bytes = json.dumps(package, ensure_ascii=False, separators=(",", ":"), sort_keys=True).encode() + b"\n"
    manifest = {"format": "sacramento.map-manifest", "version": 1,
                "package_identity": "sha256:" + __import__('hashlib').sha256(package_bytes).hexdigest(),
                "content_identity": package["content_identity"]}
    try:
        arguments.output.parent.mkdir(parents=True, exist_ok=True)
        arguments.manifest.parent.mkdir(parents=True, exist_ok=True)
        arguments.output.write_bytes(package_bytes)
        arguments.manifest.write_text(json.dumps(manifest, sort_keys=True, separators=(",", ":")) + "\n", encoding="utf-8")
    except OSError as exc:
        return _reject("SAC-COOK-OUTPUT-ERROR", str(exc))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
