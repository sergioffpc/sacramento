#!/usr/bin/env python3
"""Capture Falcor 8 coupling relevant to Sacramento's vendor boundary."""

import argparse
import json
from pathlib import Path


def files_containing(root: Path, token: str) -> list[str]:
    matches = []
    for path in root.rglob("*"):
        if not path.is_file():
            continue
        try:
            content = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        if token in content:
            matches.append(path.relative_to(root).as_posix())
    return sorted(matches)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()

    root_cmake = (args.source / "CMakeLists.txt").read_text(encoding="utf-8")
    falcor_cmake = (args.source / "Source/Falcor/CMakeLists.txt").read_text(
        encoding="utf-8"
    )
    external_cmake = (args.source / "external/CMakeLists.txt").read_text(
        encoding="utf-8"
    )
    core_source = args.source / "Source/Falcor"

    pybind_files = files_containing(core_source, "pybind11")
    script_binding_files = files_containing(core_source, "ScriptBindings")
    result = {
        "aftermath": {
            "auto_detected_from_header": (
                "if(EXISTS ${AFTERMATH_DIR}/include/GFSDK_Aftermath.h)"
                in external_cmake
            ),
            "input_present": (
                args.source
                / "external/packman/aftermath/include/GFSDK_Aftermath.h"
            ).is_file(),
        },
        "d3d12_forced_for_windows": (
            "set(FALCOR_HAS_D3D12 ${FALCOR_WINDOWS})" in root_cmake
        ),
        "python": {
            "core_links_embedded_python": "fmt pybind11::embed" in falcor_cmake,
            "pybind11_core_file_count": len(pybind_files),
            "script_bindings_core_file_count": len(script_binding_files),
        },
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(
        json.dumps(result, indent=2, sort_keys=True) + "\n", encoding="utf-8"
    )
    print(json.dumps(result, indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
