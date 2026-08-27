#!/usr/bin/env python3
"""Validate a commit message against the repository commit profile."""

from __future__ import annotations

import pathlib
import re
import sys


_ALLOWED_TYPES = (
    "build",
    "chore",
    "ci",
    "docs",
    "feat",
    "fix",
    "perf",
    "refactor",
    "revert",
    "style",
    "test",
)
_HEADER_PATTERN = re.compile(
    rf"^(?P<type>{'|'.join(_ALLOWED_TYPES)})"
    r"(?:\((?P<scope>[a-z0-9]+(?:-[a-z0-9]+)*)\))?"
    r"(?P<breaking>!)?: (?P<description>\S.*)$"
)
_FOOTER_PATTERN = re.compile(
    r"^(?:[A-Za-z0-9]+(?:-[A-Za-z0-9]+)*)(?:: | #)\S.*$"
)
_BREAKING_FOOTER_PATTERN = re.compile(r"^BREAKING CHANGE: \S.*$")


def validate_message(message: str) -> list[str]:
    """Returns validation errors for message in deterministic order."""
    errors: list[str] = []
    lines = message.rstrip("\n").splitlines()
    if not lines or not lines[0]:
        return ["commit message must contain a non-empty header"]

    if not _HEADER_PATTERN.fullmatch(lines[0]):
        errors.append(
            "header must match "
            "<type>[optional scope][optional !]: <description>"
        )

    if len(lines) > 1 and lines[1] != "":
        errors.append("body or footers must begin after one blank line")

    for line_number, line in enumerate(lines[2:], start=3):
        if not line:
            continue
        if line.startswith("BREAKING CHANGE"):
            if not _BREAKING_FOOTER_PATTERN.fullmatch(line):
                errors.append(
                    f"line {line_number}: malformed BREAKING CHANGE footer"
                )
            continue
        if re.match(r"^[A-Za-z0-9-]+(?:: | #)", line):
            if not _FOOTER_PATTERN.fullmatch(line):
                errors.append(f"line {line_number}: malformed footer")

    return errors


def main(argv: list[str]) -> int:
    """Validates the message file named by argv and returns a process code."""
    if len(argv) != 2:
        print(f"usage: {argv[0]} COMMIT_MESSAGE_FILE", file=sys.stderr)
        return 2

    message_path = pathlib.Path(argv[1])
    try:
        message = message_path.read_text(encoding="utf-8")
    except (OSError, UnicodeError) as error:
        print(f"cannot read commit message: {error}", file=sys.stderr)
        return 2

    errors = validate_message(message)
    for error in errors:
        print(f"invalid conventional commit: {error}", file=sys.stderr)
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
