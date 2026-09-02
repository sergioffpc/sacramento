#!/usr/bin/env python3
"""Audit the Sacramento/Tracy and CoreOnly binary boundaries."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import subprocess


VENDOR_TOKENS = ("tracy", "Tracy", "___tracy")


def contains_vendor_token(root: Path) -> list[str]:
    hits: list[str] = []
    for path in sorted(root.rglob("*")):
        if not path.is_file():
            continue
        text = path.read_text(encoding="utf-8")
        if any(token in text for token in VENDOR_TOKENS):
            hits.append(str(path))
    return hits


def symbols(path: Path) -> str:
    result = subprocess.run(
        ["nm", "-C", str(path)], check=True, capture_output=True, text=True
    )
    return result.stdout


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--public-root", required=True, type=Path)
    parser.add_argument("--core", required=True, type=Path)
    parser.add_argument("--diagnostic", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()

    public_hits = contains_vendor_token(args.public_root)
    core_symbols = symbols(args.core)
    diagnostic_symbols = symbols(args.diagnostic)
    core_vendor_symbols = [line for line in core_symbols.splitlines() if "tracy" in line.lower()]
    diagnostic_vendor_symbols = [
        line for line in diagnostic_symbols.splitlines() if "tracy" in line.lower()
    ]
    report = {
        "status": "pass",
        "public_vendor_token_hits": public_hits,
        "core_tracy_symbol_count": len(core_vendor_symbols),
        "diagnostic_tracy_symbol_count": len(diagnostic_vendor_symbols),
    }
    if public_hits or core_vendor_symbols or not diagnostic_vendor_symbols:
        report["status"] = "fail"
    args.output.write_text(json.dumps(report, sort_keys=True) + "\n", encoding="utf-8")
    if report["status"] != "pass":
        raise SystemExit("Gate 2E boundary audit failed")


if __name__ == "__main__":
    main()
