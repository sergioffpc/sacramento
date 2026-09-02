#!/usr/bin/env python3
"""Audit the throwaway Gate 2C public and runtime dependency boundaries."""

from __future__ import annotations

import argparse
import json
import pathlib
import re
import subprocess


VENDOR_TOKENS = (
    "GameNetworkingSockets",
    "SteamNetworking",
    "HSteam",
    "protobuf",
    "OpenSSL",
    "absl::",
)


def dynamic_dependencies(binary: pathlib.Path) -> list[str]:
    output = subprocess.run(
        ["readelf", "-d", str(binary)],
        check=True,
        capture_output=True,
        text=True,
    ).stdout
    return sorted(re.findall(r"Shared library: \[(.+?)\]", output))


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--public-root", type=pathlib.Path, required=True)
    parser.add_argument("--source-root", type=pathlib.Path, required=True)
    parser.add_argument("--binary", type=pathlib.Path, action="append", required=True)
    parser.add_argument("--output", type=pathlib.Path, required=True)
    arguments = parser.parse_args()

    public_leaks: list[str] = []
    for path in sorted(arguments.public_root.rglob("*")):
        if not path.is_file():
            continue
        text = path.read_text(encoding="utf-8")
        for token in VENDOR_TOKENS:
            if token in text:
                public_leaks.append(f"{path.name}:{token}")

    source_leaks: list[str] = []
    for path in sorted(arguments.source_root.glob("*.cpp")):
        if path.name == "gns_transport.cpp":
            continue
        text = path.read_text(encoding="utf-8")
        for token in VENDOR_TOKENS:
            if token in text:
                source_leaks.append(f"{path.name}:{token}")

    allowed = {"libstdc++.so.6", "libm.so.6", "libgcc_s.so.1", "libc.so.6"}
    dependencies = {
        path.name: dynamic_dependencies(path) for path in arguments.binary
    }
    unexpected = sorted(
        {dependency for values in dependencies.values() for dependency in values}
        - allowed
    )
    result = {
        "format": "sacramento.gate2c-boundary-audit.v1",
        "status": (
            "pass" if not public_leaks and not source_leaks and not unexpected else "fail"
        ),
        "public_vendor_leaks": public_leaks,
        "vendor_usage_outside_adapter": source_leaks,
        "dynamic_dependencies": dependencies,
        "unexpected_dynamic_dependencies": unexpected,
    }
    arguments.output.write_text(
        json.dumps(result, indent=2, sort_keys=True) + "\n", encoding="utf-8"
    )
    if result["status"] != "pass":
        raise SystemExit(1)


if __name__ == "__main__":
    main()
