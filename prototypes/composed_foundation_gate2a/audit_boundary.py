#!/usr/bin/env python3
"""Audit the Gate 2A Sacramento header and headless ELF boundary."""

import argparse
import json
import re
import subprocess
from pathlib import Path


PUBLIC_VENDOR_PATTERN = re.compile(
    r"\b(?:flecs|physx|Px[A-Z]\w*|Falcor|Vulkan|Slang|SteamAudio|IPL\w*|Assimp|Tracy)\b",
    re.IGNORECASE,
)
CLIENT_LIBRARY_PATTERN = re.compile(
    r"(?:falcor|vulkan|slang|steam.?audio|phonon|assimp|tracy)", re.IGNORECASE
)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--public-root", type=Path, required=True)
    parser.add_argument("--binary", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()

    header_hits = []
    for header in sorted(args.public_root.rglob("*.hpp")):
        for number, line in enumerate(header.read_text(encoding="utf-8").splitlines(), 1):
            if PUBLIC_VENDOR_PATTERN.search(line):
                header_hits.append(f"{header.name}:{number}:{line.strip()}")

    dynamic = subprocess.run(
        ["readelf", "-d", str(args.binary)],
        check=True,
        capture_output=True,
        text=True,
    ).stdout
    needed = re.findall(r"Shared library: \[([^]]+)\]", dynamic)
    forbidden_needed = [name for name in needed if CLIENT_LIBRARY_PATTERN.search(name)]
    result = {
        "format": "sacramento.gate2a-boundary-audit.v1",
        "public_vendor_hits": header_hits,
        "needed_libraries": needed,
        "forbidden_client_libraries": forbidden_needed,
        "public_boundary": "pass" if not header_hits else "fail",
        "headless_dependency_boundary": "pass" if not forbidden_needed else "fail",
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(result, indent=2))
    return 0 if not header_hits and not forbidden_needed else 1


if __name__ == "__main__":
    raise SystemExit(main())
