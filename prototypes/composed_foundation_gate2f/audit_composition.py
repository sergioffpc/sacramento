#!/usr/bin/env python3
"""Audit the Gate 2F link map and operational dependency boundary."""

import argparse
import json
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--map", required=True, dest="map_path", type=Path)
    parser.add_argument("--vcpkg-list", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    arguments = parser.parse_args()

    link_map = arguments.map_path.read_text(encoding="utf-8", errors="replace")
    installed = arguments.vcpkg_list.read_text(encoding="utf-8")
    expected_link_inputs = {
        "Falcor": "Falcor:Falcor.dll",
        "GameNetworkingSockets": "GameNetworkingSockets",
        "Steam Audio": "phonon",
        "Sacramento observability": "observability.cc",
    }
    link_findings = {
        name: token.lower() in link_map.lower()
        for name, token in expected_link_inputs.items()
    }
    package_findings = {
        "gamenetworkingsockets-1.6.0": (
            "gamenetworkingsockets:" in installed and "1.6.0" in installed
        ),
        "steam-audio-4.8.1": (
            "steam-audio:" in installed and "4.8.1" in installed
        ),
        "tracy-absent": "tracy:" not in installed.lower(),
    }
    passed = all(link_findings.values()) and all(package_findings.values())
    result = {
        "status": "pass" if passed else "fail",
        "link_inputs": link_findings,
        "operational_packages": package_findings,
        "claim": "one Windows process links all client-side foundation seams",
    }
    arguments.output.write_text(
        json.dumps(result, indent=2, sort_keys=True) + "\n", encoding="utf-8"
    )
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
