"""Behavior tests for the throwaway Gate 2B cooker interface."""

from __future__ import annotations

import json
import hashlib
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


PROTOTYPE_ROOT = Path(__file__).resolve().parents[1]
COOKER = PROTOTYPE_ROOT / "cook.py"
FIXTURE = PROTOTYPE_ROOT / "fixtures" / "blender-origin-map.gltf"
RECIPE = PROTOTYPE_ROOT / "fixtures" / "blender-origin-map.recipe.json"
OPENUSD_FIXTURE = PROTOTYPE_ROOT / "fixtures" / "openusd" / "root.usda"


class CookerInterfaceTest(unittest.TestCase):
    def test_missing_native_adapter_has_stable_sacramento_diagnostic(self) -> None:
        with tempfile.TemporaryDirectory() as temporary_directory:
            temporary_root = Path(temporary_directory)
            result = subprocess.run(
                [
                    sys.executable,
                    str(COOKER),
                    "--source",
                    str(FIXTURE),
                    "--recipe",
                    str(RECIPE),
                    "--adapter",
                    str(temporary_root / "missing-assimp-adapter"),
                    "--output",
                    str(temporary_root / "map.sacmap"),
                    "--manifest",
                    str(temporary_root / "map.manifest.json"),
                ],
                check=False,
                capture_output=True,
                text=True,
            )

        self.assertEqual(result.returncode, 2)
        self.assertEqual(result.stdout, "")
        self.assertEqual(
            json.loads(result.stderr),
            {
                "code": "SAC-COOK-ADAPTER-UNAVAILABLE",
                "detail": "native source adapter is unavailable",
            },
        )

    def test_unsupported_source_has_stable_sacramento_diagnostic(self) -> None:
        with tempfile.TemporaryDirectory() as temporary_directory:
            temporary_root = Path(temporary_directory)
            source = temporary_root / "unsupported.txt"
            source.write_text("not a supported Map source", encoding="utf-8")
            recipe = temporary_root / "map.recipe.json"
            recipe.write_text("{}\n", encoding="utf-8")

            result = subprocess.run(
                [
                    sys.executable,
                    str(COOKER),
                    "--source",
                    str(source),
                    "--recipe",
                    str(recipe),
                    "--adapter",
                    str(temporary_root / "unused-adapter.so"),
                    "--output",
                    str(temporary_root / "map.sacmap"),
                    "--manifest",
                    str(temporary_root / "map.manifest.json"),
                ],
                check=False,
                capture_output=True,
                text=True,
            )

        self.assertEqual(result.returncode, 2)
        self.assertEqual(result.stdout, "")
        self.assertEqual(
            json.loads(result.stderr),
            {
                "code": "SAC-COOK-UNSUPPORTED-SOURCE",
                "detail": "source format is not admitted: .txt",
            },
        )

    def test_valid_map_cooks_byte_identically_without_source_schema_leakage(
        self,
    ) -> None:
        adapter = Path(
            os.environ.get(
                "SACRAMENTO_GATE2B_ADAPTER",
                "/tmp/sacramento-gate2b-adapter-not-built.so",
            )
        )
        with tempfile.TemporaryDirectory() as temporary_directory:
            temporary_root = Path(temporary_directory)
            outputs: list[tuple[bytes, bytes, subprocess.CompletedProcess[str]]] = []
            for cook_name in ("a", "b"):
                package = temporary_root / f"map-{cook_name}.sacmap"
                manifest = temporary_root / f"map-{cook_name}.manifest.json"
                result = subprocess.run(
                    [
                        sys.executable,
                        str(COOKER),
                        "--source",
                        str(FIXTURE),
                        "--recipe",
                        str(RECIPE),
                        "--adapter",
                        str(adapter),
                        "--output",
                        str(package),
                        "--manifest",
                        str(manifest),
                    ],
                    check=False,
                    capture_output=True,
                    text=True,
                )
                outputs.append((package.read_bytes(), manifest.read_bytes(), result))

        package_bytes, manifest_bytes, first_result = outputs[0]
        package = json.loads(package_bytes)
        manifest = json.loads(manifest_bytes)
        content_bytes = json.dumps(
            package["content"],
            ensure_ascii=False,
            separators=(",", ":"),
            sort_keys=True,
        ).encode("utf-8")
        banned_tokens = (b"assimp", b"openusd", b".gltf", b"mapsurface")
        observation = {
            "return_codes": [output[2].returncode for output in outputs],
            "stderr": [output[2].stderr for output in outputs],
            "package_equal": outputs[0][0] == outputs[1][0],
            "manifest_equal": outputs[0][1] == outputs[1][1],
            "format": package["format"],
            "version": package["version"],
            "map_id": package["content"]["map_id"],
            "anchor_ids": [anchor["id"] for anchor in package["content"]["anchors"]],
            "material_ids": [
                material["id"] for material in package["content"]["materials"]
            ],
            "mesh_ids": [mesh["id"] for mesh in package["content"]["meshes"]],
            "positions": package["content"]["meshes"][0]["positions"],
            "indices": package["content"]["meshes"][0]["indices"],
            "collider_ids": [
                collider["id"] for collider in package["content"]["colliders"]
            ],
            "content_identity_valid": package["content_identity"]
            == f"sha256:{hashlib.sha256(content_bytes).hexdigest()}",
            "package_identity_valid": manifest["package_identity"]
            == f"sha256:{hashlib.sha256(package_bytes).hexdigest()}",
            "has_banned_token": any(
                token in package_bytes.lower() for token in banned_tokens
            ),
        }
        self.assertEqual(
            observation,
            {
                "return_codes": [0, 0],
                "stderr": ["", ""],
                "package_equal": True,
                "manifest_equal": True,
                "format": "sacramento.map-package",
                "version": 1,
                "map_id": "map.gate2b.training-yard",
                "anchor_ids": ["anchor.spawn.alpha"],
                "material_ids": ["material.concrete"],
                "mesh_ids": ["mesh.training-yard.floor"],
                "positions": [
                    [-1.0, 0.0, -1.0],
                    [1.0, 0.0, -1.0],
                    [1.0, 0.0, 1.0],
                    [-1.0, 0.0, 1.0],
                ],
                "indices": [0, 1, 2, 0, 2, 3],
                "collider_ids": ["collider.training-yard.floor"],
                "content_identity_valid": True,
                "package_identity_valid": True,
                "has_banned_token": False,
            },
        )

    def test_runtime_reader_inspects_only_the_cooked_package(self) -> None:
        adapter = Path(os.environ["SACRAMENTO_GATE2B_ADAPTER"])
        reader = Path(
            os.environ.get(
                "SACRAMENTO_GATE2B_RUNTIME_READER",
                "/tmp/sacramento-gate2b-runtime-reader-not-built",
            )
        )
        with tempfile.TemporaryDirectory() as temporary_directory:
            temporary_root = Path(temporary_directory)
            package = temporary_root / "map.sacmap"
            cook_result = subprocess.run(
                [
                    sys.executable,
                    str(COOKER),
                    "--source",
                    str(FIXTURE),
                    "--recipe",
                    str(RECIPE),
                    "--adapter",
                    str(adapter),
                    "--output",
                    str(package),
                    "--manifest",
                    str(temporary_root / "map.manifest.json"),
                ],
                check=False,
                capture_output=True,
                text=True,
            )
            read_result = subprocess.run(
                [str(reader), str(package)],
                check=False,
                capture_output=True,
                text=True,
            )

        self.assertEqual(cook_result.returncode, 0)
        self.assertEqual(cook_result.stderr, "")
        self.assertEqual(read_result.returncode, 0)
        self.assertEqual(read_result.stderr, "")
        self.assertEqual(
            json.loads(read_result.stdout),
            {
                "format": "sacramento.map-inspection",
                "version": 1,
                "map_id": "map.gate2b.training-yard",
                "anchor_count": 1,
                "material_count": 1,
                "mesh_count": 1,
                "collider_count": 1,
                "vertex_count": 4,
                "triangle_count": 2,
            },
        )

    @unittest.skipUnless(
        os.environ.get("SACRAMENTO_GATE2B_OPENUSD_ADAPTER"),
        "isolated usd-core experiment is not installed",
    )
    def test_openusd_composition_reaches_the_same_runtime_package(self) -> None:
        assimp_adapter = Path(os.environ["SACRAMENTO_GATE2B_ADAPTER"])
        openusd_adapter = Path(os.environ["SACRAMENTO_GATE2B_OPENUSD_ADAPTER"])
        with tempfile.TemporaryDirectory() as temporary_directory:
            temporary_root = Path(temporary_directory)
            packages: list[bytes] = []
            for name, source, adapter in (
                ("assimp", FIXTURE, assimp_adapter),
                ("openusd", OPENUSD_FIXTURE, openusd_adapter),
            ):
                package = temporary_root / f"{name}.sacmap"
                result = subprocess.run(
                    [
                        sys.executable,
                        str(COOKER),
                        "--source",
                        str(source),
                        "--recipe",
                        str(RECIPE),
                        "--adapter",
                        str(adapter),
                        "--output",
                        str(package),
                        "--manifest",
                        str(temporary_root / f"{name}.manifest.json"),
                    ],
                    check=False,
                    capture_output=True,
                    text=True,
                )
                self.assertEqual(result.returncode, 0, result.stderr)
                packages.append(package.read_bytes())

        self.assertEqual(packages[0], packages[1])


if __name__ == "__main__":
    unittest.main()
