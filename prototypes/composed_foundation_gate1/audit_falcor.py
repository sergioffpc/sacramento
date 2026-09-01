#!/usr/bin/env python3
"""Report Falcor 8.0 policy blockers without modifying its source."""

import argparse
import json
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()

    cmake = (args.source / "CMakeLists.txt").read_text(encoding="utf-8")
    dependencies = (args.source / "dependencies.xml").read_text(
        encoding="utf-8")

    packman_configure = (
        "execute_process(\n"
        "    COMMAND ${PACKMAN} pull ${CMAKE_SOURCE_DIR}/dependencies.xml"
        in cmake)
    d3d12_forced_on_windows = (
        "set(FALCOR_HAS_D3D12 ${FALCOR_WINDOWS})" in cmake)
    matching_slang = (
        '<package name="slang" version="2024.1.34"' in dependencies)

    result = {
        "falcor": {
            "version": "8.0",
            "commit": "9dc819c162b2070335c65060436041690b7937f8",
            "source_sha256": (
                "681acb541ca02c819e42919ab26214263c9a9254f7876871d420120e1a4b7899"),
        },
        "slang_version_matches_manifest": matching_slang,
        "configure_invokes_packman": packman_configure,
        "windows_forces_d3d12": d3d12_forced_on_windows,
        "selected_policy": {
            "dependency_manager": "vcpkg only",
            "graphics_interface": "Vulkan only",
        },
        "verdict": (
            "fail"
            if packman_configure or d3d12_forced_on_windows
            else "pass"),
    }

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(
        json.dumps(result, indent=2, sort_keys=True) + "\n",
        encoding="utf-8")
    print(json.dumps(result, indent=2, sort_keys=True))
    return 1 if result["verdict"] == "fail" else 0


if __name__ == "__main__":
    raise SystemExit(main())
