#!/usr/bin/env python3
"""Generate the deterministic verification-assignment CSV inventory."""

from __future__ import annotations

import hashlib
import os
import pathlib
import re


VERIFICATION_PLAN = pathlib.Path(
    "docs/requirements/training-simulation-verification-plan.md"
)
SOURCES = (
    pathlib.Path(
        "docs/requirements/training-simulation-initial-requirements.md"
    ),
    pathlib.Path(
        "docs/requirements/training-simulation-autonomous-participant-requirements.md"
    ),
    VERIFICATION_PLAN,
)
OUTPUT = pathlib.Path(
    "docs/requirements/"
    "training-simulation-verification-assignment-inventory.csv"
)
IDENTIFIER_PATTERN = r"[A-Z][A-Z0-9-]+-[0-9]{3}"
DEFINITION_RE = re.compile(rf"^(?:- )?\*\*({IDENTIFIER_PATTERN})\*\*")
RANGE_RE = re.compile(
    rf"`({IDENTIFIER_PATTERN})` through `({IDENTIFIER_PATTERN})`"
)
SELECTOR_RE = re.compile(rf"`({IDENTIFIER_PATTERN})`")
ASSIGNMENT_RE = re.compile(
    r"^\| (`.*?) \| (.*?) \| (.*?) \| (.*?) \| (.*?) \| (.*?) \|$"
)
METHOD_ORDER = (
    "Inspection",
    "Automated Test",
    "Analysis",
    "Representative Evaluation",
    "Demonstration",
)
HEADER = (
    "inventory_version",
    "sequence",
    "source_document",
    "identifier",
    "matching_assignment_rows",
    "evidence_owners",
)


def sha256(value: bytes) -> str:
    """Returns the hexadecimal SHA-256 digest of value."""
    return hashlib.sha256(value).hexdigest()


def unique_values(values: list[str]) -> list[str]:
    """Returns meaningful values once each while preserving input order."""
    result: list[str] = []
    seen: set[str] = set()
    for value in values:
        if not value or value == "None" or value in seen:
            continue
        seen.add(value)
        result.append(value)
    return result


def methods_in(value: str) -> list[str]:
    """Returns verification methods found in value in canonical order."""
    return [method for method in METHOD_ORDER if method in value]


def quote_csv_field(value: object) -> str:
    """Returns one always-quoted RFC-style CSV field."""
    return f'"{str(value).replace(chr(34), chr(34) * 2)}"'


def main() -> None:
    """Reads canonical documents, validates assignments, and writes the CSV."""
    content_bytes: dict[pathlib.Path, bytes] = {}
    content: dict[pathlib.Path, str] = {}
    source_hash: dict[pathlib.Path, str] = {}
    index: dict[str, int] = {}
    definition_source: dict[str, pathlib.Path] = {}
    identifiers: list[str] = []

    for source in SOURCES:
        try:
            raw_content = source.read_bytes()
        except OSError as error:
            raise SystemExit(f"Cannot read {source}: {error}") from error
        try:
            source_content = raw_content.decode("utf-8")
        except UnicodeDecodeError as error:
            raise SystemExit(
                f"Cannot decode {source} as UTF-8: {error}"
            ) from error

        content_bytes[source] = raw_content
        content[source] = source_content
        source_hash[source] = sha256(raw_content)

        for line in source_content.splitlines():
            match = DEFINITION_RE.match(line)
            if not match:
                continue
            identifier = match.group(1)
            if identifier in index:
                raise SystemExit(f"Duplicate definition: {identifier}")
            index[identifier] = len(identifiers)
            definition_source[identifier] = source
            identifiers.append(identifier)

    inventory_material = b"\0".join(content_bytes[source] for source in SOURCES)
    inventory_version = sha256(inventory_material)

    rows: list[dict[str, str]] = []
    in_assignments = False
    for line in content[VERIFICATION_PLAN].splitlines():
        if line == "## Requirement assignments":
            in_assignments = True
            continue
        if in_assignments and line.startswith("## "):
            break
        if not in_assignments:
            continue
        match = ASSIGNMENT_RE.match(line)
        if not match:
            continue
        rows.append(
            {
                "selector": match.group(1),
                "required": match.group(2),
                "supporting": match.group(3),
                "evidence": match.group(4),
                "owner": match.group(5),
                "approver": match.group(6),
            }
        )
    if not rows:
        raise SystemExit("No assignment rows found")

    matches: dict[str, list[int]] = {}
    for row_index, row in enumerate(rows):
        selector = row["selector"]
        selected: set[str] = set()
        for range_match in RANGE_RE.finditer(selector):
            first, last = range_match.groups()
            if first not in index:
                raise SystemExit(f"Unknown range endpoint: {first}")
            if last not in index:
                raise SystemExit(f"Unknown range endpoint: {last}")
            if index[first] > index[last]:
                raise SystemExit(f"Reversed range: {first} through {last}")
            selected.update(identifiers[index[first] : index[last] + 1])
        for identifier_match in SELECTOR_RE.finditer(selector):
            identifier = identifier_match.group(1)
            if identifier not in index:
                raise SystemExit(
                    f"Unknown identifier in assignment: {identifier}"
                )
            selected.add(identifier)
        for identifier in selected:
            matches.setdefault(identifier, []).append(row_index)

    output_lines = [",".join(quote_csv_field(column) for column in HEADER)]
    for position, identifier in enumerate(identifiers):
        matching = matches.get(identifier, [])
        if not matching:
            raise SystemExit(f"Uncovered identifier: {identifier}")

        required = unique_values(
            [
                method
                for row_index in matching
                for method in methods_in(rows[row_index]["required"])
            ]
        )
        supporting = unique_values(
            [
                method
                for row_index in matching
                for method in methods_in(rows[row_index]["supporting"])
            ]
        )
        if not required:
            raise SystemExit(f"No Required method: {identifier}")

        row_ids = [f"AR-{row_index + 1:03d}" for row_index in matching]
        representative_rows = [
            row_index
            for row_index in matching
            if "Representative Evaluation" in rows[row_index]["required"]
        ]
        representative_row_ids = [
            f"AR-{row_index + 1:03d}" for row_index in representative_rows
        ]
        owners = unique_values(
            [rows[row_index]["owner"] for row_index in matching]
        )
        approvers = unique_values(
            [rows[row_index]["approver"] for row_index in matching]
        )

        defaults = (
            "Inspection="
            + ("Accumulated" if "Inspection" in required else "Not Applicable"),
            "Automated Test="
            + (
                "Accumulated"
                if "Automated Test" in required
                else "Not Applicable"
            ),
            "Analysis="
            + ("Accumulated" if "Analysis" in required else "Not Applicable"),
            "Representative Evaluation="
            + (
                "Accumulated"
                if "Representative Evaluation" in required
                else "Not Applicable"
            ),
            "Demonstration="
            + (
                "Accumulated as Supporting"
                if "Demonstration" in supporting
                else "Not Applicable"
            ),
        )

        if identifier.startswith("AMBIGUITY-"):
            entry_kind = "Ambiguity metadata"
            applicability = "Not Applicable — Metadata"
            representative_evidence = "None"
            rationale = (
                "This entry records an ambiguity-review disposition and "
                "contains no product or process obligation."
            )
            scope = "No obligation keys."
        elif "Representative Evaluation" in required:
            entry_kind = "Stable requirement or process entry"
            applicability = "Required Within Identifier"
            if not representative_row_ids:
                message = (
                    "Representative Evaluation method has no source row: "
                    f"{identifier}"
                )
                raise SystemExit(message)
            representative_evidence = ";".join(representative_row_ids)
            rationale = (
                "At least one obligation depends on the human-perception, "
                "tactical-adequacy, credible-military-behavior, or "
                "training-validity evidence required by "
                + ";".join(representative_row_ids)
                + "."
            )
            scope = (
                "Before procedure approval, enumerate stable obligation keys "
                "and record Representative Evaluation as Required only for "
                "the dependent obligations; retain objective obligations "
                "separately."
            )
        else:
            entry_kind = "Stable requirement or process entry"
            applicability = "Not Required for Identifier"
            representative_evidence = "None"
            rationale = (
                "The objective criteria and reproducible technical evidence "
                "assigned by "
                + ";".join(row_ids)
                + " are sufficient; military subject matter alone does not "
                "require Representative Evaluation."
            )
            scope = (
                "Before procedure approval, enumerate stable obligation keys "
                "and confirm this objective-sufficiency decision for each key."
            )

        record = (
            inventory_version,
            position + 1,
            definition_source[identifier],
            identifier,
            ";".join(row_ids),
            ";".join(owners),
        )
        output_lines.append(
            ",".join(quote_csv_field(value) for value in record)
        )

    temporary = OUTPUT.with_name(f"{OUTPUT.name}.tmp")
    try:
        temporary.write_text("\n".join(output_lines) + "\n", encoding="utf-8")
        os.replace(temporary, OUTPUT)
    except OSError as error:
        raise SystemExit(f"Cannot replace {OUTPUT}: {error}") from error

    print(
        f"Generated {OUTPUT} with {len(identifiers)} entries "
        f"from {len(rows)} assignment rows."
    )


if __name__ == "__main__":
    main()
