#!/usr/bin/env python3
"""Audit Gate 2D's public, source, and Session Authority boundaries."""

from __future__ import annotations

import argparse
import json
import pathlib
import re
import subprocess


VENDOR_TOKENS = ("IPL", "phonon", "SteamAudio", "steam_audio")
ALLOWED_NEEDED = {"libstdc++.so.6", "libm.so.6", "libgcc_s.so.1", "libc.so.6"}


def command_output(command: list[str]) -> str:
    return subprocess.run(
        command, check=True, capture_output=True, text=True
    ).stdout


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--public-root", type=pathlib.Path, required=True)
    parser.add_argument("--source-root", type=pathlib.Path, required=True)
    parser.add_argument("--authority", type=pathlib.Path, required=True)
    parser.add_argument("--client", type=pathlib.Path, required=True)
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
    for path in sorted(arguments.source_root.glob("*.cc")):
        if path.name == "steam_audio_adapter.cc":
            continue
        text = path.read_text(encoding="utf-8")
        for token in VENDOR_TOKENS:
            if token in text:
                source_leaks.append(f"{path.name}:{token}")

    authority_dynamic = command_output(["readelf", "-d", str(arguments.authority)])
    authority_needed = sorted(
        re.findall(r"Shared library: \[(.+?)\]", authority_dynamic)
    )
    unexpected_needed = sorted(set(authority_needed) - ALLOWED_NEEDED)
    authority_symbols = command_output(["nm", "-C", str(arguments.authority)])
    authority_vendor_symbols = sorted(
        line for line in authority_symbols.splitlines() if re.search(r"\bipl[A-Z]", line)
    )
    client_symbols = command_output(["nm", "-C", str(arguments.client)])
    client_adapter_exercised = "iplContextCreate" in client_symbols

    result = {
        "format": "sacramento.gate2d-boundary-audit.v1",
        "status": "pass",
        "public_vendor_leaks": public_leaks,
        "vendor_usage_outside_adapter": source_leaks,
        "authority_needed_libraries": authority_needed,
        "authority_unexpected_needed_libraries": unexpected_needed,
        "authority_vendor_symbols": authority_vendor_symbols,
        "client_contains_steam_audio_calls": client_adapter_exercised,
    }
    if (
        public_leaks
        or source_leaks
        or unexpected_needed
        or authority_vendor_symbols
        or not client_adapter_exercised
    ):
        result["status"] = "fail"

    arguments.output.parent.mkdir(parents=True, exist_ok=True)
    arguments.output.write_text(
        json.dumps(result, indent=2, sort_keys=True) + "\n", encoding="utf-8"
    )
    print(json.dumps(result, indent=2, sort_keys=True))
    if result["status"] != "pass":
        raise SystemExit(1)


if __name__ == "__main__":
    main()
