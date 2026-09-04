#!/usr/bin/env python3
"""Validate the Baseline Artifact Inventory against its declared sources."""

from __future__ import annotations

import csv
import dataclasses
import hashlib
import pathlib
import re
import sys


ROOT = pathlib.Path(__file__).resolve().parents[1]
CONTROL = ROOT / "docs/project/training-simulation-baseline-artifact-inventory.md"
ARTIFACTS = ROOT / "docs/project/training-simulation-baseline-artifacts.csv"
CLAIMS = ROOT / "docs/project/training-simulation-architecture-claim-traces.csv"
APPLICABILITY = (
    ROOT
    / "docs/requirements/training-simulation-baseline-applicability-inventory.csv"
)
CLAIM_SOURCE = (
    ROOT / "docs/architecture/0010-cross-cutting-architecture-and-verification.md"
)
EVIDENCE_CONTROL = (
    ROOT / "docs/project/training-simulation-evidence-dependency-inventory.md"
)

INVENTORY_PACKAGE = {
    CONTROL.relative_to(ROOT).as_posix(),
    ARTIFACTS.relative_to(ROOT).as_posix(),
    CLAIMS.relative_to(ROOT).as_posix(),
}
EVIDENCE_PACKAGE = {
    "docs/project/training-simulation-evidence-dependency-inventory.md",
    "docs/project/training-simulation-evidence-dependency-nodes.csv",
    "docs/project/training-simulation-evidence-dependency-relations.csv",
    "docs/project/training-simulation-evidence-impact-cases.csv",
}
ARTIFACT_HEADER = [
    "sequence",
    "artifact_identifier",
    "artifact_class",
    "exact_version",
    "canonical_location",
    "baseline_status",
    "responsible_owner",
    "trace_disposition",
    "requirement_traces",
    "trace_basis",
]
CLAIM_HEADER = [
    "sequence",
    "architecture_claim_key",
    "governing_artifact_identifier",
    "decision_state",
    "baseline_applicability",
    "realization_state",
    "evidence_state",
    "claim_disposition",
    "requirement_trace_relations",
]
CLASS_CODES = {
    "Architecture": "ARC",
    "Design": "DES",
    "Implementation": "IMP",
    "Verification": "VER",
}
STATUSES = {"Included", "Future", "Not Applicable"}
DISPOSITIONS = {"Satisfies", "Intentional Deferral", "Not Applicable"}
REQUIREMENT_RE = re.compile(r"[A-Z][A-Z0-9-]+-[0-9]{3}")
ARTIFACT_RE = re.compile(r"BART-(ARC|DES|IMP|VER)-([0-9]{3})")
CLAIM_RE = re.compile(r"AC-[A-Z0-9-]+-[0-9]{3}")
SHA256_RE = re.compile(r"sha256:[0-9a-f]{64}")
PACKAGE_DIGEST_RE = re.compile(r"[0-9a-f]{64}")
SOURCE_ROW_RE = re.compile(
    r"^\| `(?P<selector>[^`]+)` \| "
    r"`(?P<class>Architecture|Design|Implementation|Verification)` \|"
)


@dataclasses.dataclass(frozen=True)
class Artifact:
    sequence: str
    identifier: str
    artifact_class: str
    exact_version: str
    location: str
    baseline_status: str
    owner: str
    disposition: str
    traces: str
    basis: str


@dataclasses.dataclass(frozen=True)
class ClaimTrace:
    sequence: str
    claim_key: str
    artifact_identifier: str
    decision_state: str
    baseline_applicability: str
    realization_state: str
    evidence_state: str
    disposition: str
    relations: str


def read_csv(path: pathlib.Path) -> tuple[list[str], list[list[str]]]:
    """Read one UTF-8 CSV and return its header and data rows."""
    try:
        with path.open(encoding="utf-8", newline="") as source:
            reader = csv.reader(source)
            rows = list(reader)
    except (OSError, UnicodeError, csv.Error) as error:
        raise SystemExit(f"cannot read {path.relative_to(ROOT)}: {error}") from error
    if not rows:
        return [], []
    return rows[0], rows[1:]


def authoritative_population(
    control_text: str, errors: list[str]
) -> dict[str, str]:
    """Resolve the canonical per-class source selectors declared by control."""
    population: dict[str, str] = {}
    selectors = [
        match.groupdict()
        for line in control_text.splitlines()
        if (match := SOURCE_ROW_RE.match(line)) is not None
    ]
    if not selectors:
        errors.append("inventory control: no authoritative source selectors")
    for source in selectors:
        selector = source["selector"]
        artifact_class = source["class"]
        matches = sorted(
            path.relative_to(ROOT).as_posix()
            for path in ROOT.glob(selector)
            if path.is_file()
        )
        if not matches:
            errors.append(f"inventory control: selector matched nothing: {selector}")
        for location in matches:
            if location in population:
                errors.append(
                    f"inventory control: overlapping selectors for {location}"
                )
            else:
                population[location] = artifact_class
    return population


def applicability_registry(
    errors: list[str],
) -> tuple[list[str], dict[str, str]]:
    """Return the ordered exact requirement identifiers and dispositions."""
    header, rows = read_csv(APPLICABILITY)
    expected = [
        "sequence",
        "requirement_identifier",
        "disposition",
        "milestone_or_justification",
        "responsible_owner",
    ]
    if header != expected:
        errors.append("applicability inventory: invalid header")
        return [], {}
    ordered: list[str] = []
    dispositions: dict[str, str] = {}
    for line_number, row in enumerate(rows, start=2):
        if len(row) != len(expected):
            errors.append(
                f"applicability inventory:{line_number}: invalid column count"
            )
            continue
        identifier = row[1]
        if identifier in dispositions:
            errors.append(f"applicability inventory: duplicate {identifier}")
        ordered.append(identifier)
        dispositions[identifier] = row[2]
    return ordered, dispositions


def parse_artifacts(errors: list[str]) -> list[Artifact]:
    """Parse the artifact register."""
    header, rows = read_csv(ARTIFACTS)
    if header != ARTIFACT_HEADER:
        errors.append("artifact register: invalid header")
        return []
    artifacts: list[Artifact] = []
    for line_number, row in enumerate(rows, start=2):
        if len(row) != len(ARTIFACT_HEADER):
            errors.append(
                f"artifact register:{line_number}: expected "
                f"{len(ARTIFACT_HEADER)} columns, found {len(row)}"
            )
            continue
        artifacts.append(Artifact(*row))
    if not artifacts:
        errors.append("artifact register: no artifact rows")
    return artifacts


def split_traces(value: str, label: str, errors: list[str]) -> list[str]:
    """Parse an exact semicolon-separated requirement trace list."""
    if not value:
        return []
    traces = value.split(";")
    if any(not REQUIREMENT_RE.fullmatch(trace) for trace in traces):
        errors.append(f"{label}: trace must contain only exact identifiers")
    if len(traces) != len(set(traces)):
        errors.append(f"{label}: duplicate requirement trace")
    return traces


def split_trace_relations(
    value: str, label: str, errors: list[str]
) -> list[tuple[str, str]]:
    """Parse exact per-requirement Architecture Claim relations."""
    if not value:
        errors.append(f"{label}: missing requirement trace relations")
        return []
    relations: list[tuple[str, str]] = []
    for entry in value.split(";"):
        disposition, separator, identifier = entry.partition(":")
        if (
            not separator
            or disposition not in DISPOSITIONS
            or REQUIREMENT_RE.fullmatch(identifier) is None
        ):
            errors.append(f"{label}: invalid requirement trace relation")
            continue
        relations.append((disposition, identifier))
    identifiers = [identifier for _, identifier in relations]
    if len(identifiers) != len(set(identifiers)):
        errors.append(f"{label}: duplicate requirement trace relation")
    return relations


def file_sha256(path: pathlib.Path) -> str:
    """Return one exact lowercase SHA-256 artifact version."""
    digest = hashlib.sha256()
    try:
        with path.open("rb") as source:
            for chunk in iter(lambda: source.read(1024 * 1024), b""):
                digest.update(chunk)
    except OSError as error:
        raise SystemExit(f"cannot hash {path.relative_to(ROOT)}: {error}") from error
    return f"sha256:{digest.hexdigest()}"


def evidence_package_identity(errors: list[str]) -> str:
    """Return the exact external Evidence Dependency Inventory identity."""
    try:
        text = EVIDENCE_CONTROL.read_text(encoding="utf-8")
    except (OSError, UnicodeError) as error:
        raise SystemExit(f"cannot read evidence inventory control: {error}") from error
    versions = re.findall(r"^Inventory version: `([^`]+)`$", text, re.MULTILINE)
    digests = re.findall(r"^Package SHA-256: `([^`]+)`$", text, re.MULTILINE)
    if versions != ["EDI-001"] or len(digests) != 1:
        errors.append("evidence inventory control: invalid package identity")
        return "INVALID"
    if PACKAGE_DIGEST_RE.fullmatch(digests[0]) is None:
        errors.append("evidence inventory control: invalid package SHA-256")
        return "INVALID"
    return f"EDI-001@sha256:{digests[0]}"


def validate_artifacts(
    artifacts: list[Artifact],
    dispositions: dict[str, str],
    population: dict[str, str],
    package_identity: str,
    evidence_identity: str,
    errors: list[str],
) -> dict[str, Artifact]:
    """Validate artifact identities, metadata, versions, traces, and coverage."""
    by_identifier: dict[str, Artifact] = {}
    by_location: dict[str, Artifact] = {}
    class_numbers: dict[str, list[int]] = {name: [] for name in CLASS_CODES}

    for expected_sequence, artifact in enumerate(artifacts, start=1):
        label = f"artifact register:{artifact.identifier or expected_sequence}"
        if artifact.sequence != str(expected_sequence):
            errors.append(f"{label}: invalid sequence")
        match = ARTIFACT_RE.fullmatch(artifact.identifier)
        if match is None:
            errors.append(f"{label}: invalid stable artifact identifier")
        elif artifact.artifact_class in CLASS_CODES:
            if match.group(1) != CLASS_CODES[artifact.artifact_class]:
                errors.append(f"{label}: identifier class does not match class")
            class_numbers[artifact.artifact_class].append(int(match.group(2)))
        if artifact.identifier in by_identifier:
            errors.append(f"{label}: duplicate artifact identifier")
        else:
            by_identifier[artifact.identifier] = artifact
        if artifact.location in by_location:
            errors.append(f"{label}: duplicate canonical location")
        else:
            by_location[artifact.location] = artifact
        if artifact.artifact_class not in CLASS_CODES:
            errors.append(f"{label}: invalid artifact class")
        elif population.get(artifact.location) not in {
            None,
            artifact.artifact_class,
        }:
            errors.append(f"{label}: class differs from authoritative selector")
        if artifact.baseline_status not in STATUSES:
            errors.append(f"{label}: invalid baseline status")
        if not artifact.owner:
            errors.append(f"{label}: missing responsible owner")
        if artifact.disposition not in DISPOSITIONS:
            errors.append(f"{label}: invalid trace disposition")
        if not artifact.basis:
            errors.append(f"{label}: missing trace basis")

        path = pathlib.PurePosixPath(artifact.location)
        if path.is_absolute() or ".." in path.parts:
            errors.append(f"{label}: canonical location must be repository-relative")
        elif artifact.location in INVENTORY_PACKAGE:
            if artifact.exact_version != package_identity:
                errors.append(f"{label}: inventory-package version mismatch")
        elif artifact.location in EVIDENCE_PACKAGE:
            if artifact.exact_version != evidence_identity:
                errors.append(f"{label}: evidence-package version mismatch")
        elif not SHA256_RE.fullmatch(artifact.exact_version):
            errors.append(f"{label}: invalid exact SHA-256 version")
        elif (ROOT / path).is_file():
            actual_version = file_sha256(ROOT / path)
            if actual_version != artifact.exact_version:
                errors.append(f"{label}: stale exact version for {artifact.location}")

        traces = split_traces(artifact.traces, label, errors)
        for trace in traces:
            if trace not in dispositions:
                errors.append(f"{label}: unknown requirement trace {trace}")
        if artifact.disposition == "Satisfies":
            if artifact.baseline_status != "Included":
                errors.append(f"{label}: Satisfies requires Included status")
            if not traces:
                errors.append(f"{label}: Satisfies requires an exact trace")
            for trace in traces:
                if dispositions.get(trace) != "Included":
                    errors.append(f"{label}: satisfied trace is not Included: {trace}")
        elif artifact.disposition == "Intentional Deferral":
            if artifact.baseline_status != "Future":
                errors.append(
                    f"{label}: Intentional Deferral requires Future status"
                )
            if not traces:
                errors.append(f"{label}: Intentional Deferral requires an exact trace")
            for trace in traces:
                if dispositions.get(trace) != "Future":
                    errors.append(f"{label}: deferred trace is not Future: {trace}")
        elif artifact.disposition == "Not Applicable":
            if artifact.baseline_status != "Not Applicable":
                errors.append(
                    f"{label}: Not Applicable disposition requires matching status"
                )
            if traces:
                errors.append(
                    f"{label}: Not Applicable uses its objective basis, not traces"
                )

    for artifact_class, numbers in class_numbers.items():
        if numbers != sorted(numbers):
            errors.append(
                f"artifact register: {artifact_class} identifiers must remain ordered"
            )

    actual_population = set(population)
    recorded_population = set(by_location)
    for location in sorted(actual_population - recorded_population):
        errors.append(f"artifact register: unregistered artifact: {location}")
    for location in sorted(recorded_population - actual_population):
        errors.append(f"artifact register: stale artifact: {location}")
    return by_identifier


def expand_requirement_trace(
    trace_cell: str,
    ordered_requirements: list[str],
    errors: list[str],
    claim_key: str,
) -> list[str]:
    """Expand a canonical claim's exact identifiers, including ordered ranges."""
    identifiers = REQUIREMENT_RE.findall(trace_cell)
    if " through " not in trace_cell:
        return identifiers
    if len(identifiers) != 2:
        errors.append(f"claim source:{claim_key}: unsupported requirement range")
        return identifiers
    try:
        first = ordered_requirements.index(identifiers[0])
        last = ordered_requirements.index(identifiers[1])
    except ValueError:
        errors.append(f"claim source:{claim_key}: unknown requirement range bound")
        return identifiers
    if first > last:
        errors.append(f"claim source:{claim_key}: reversed requirement range")
        return identifiers
    return ordered_requirements[first : last + 1]


def canonical_claims(
    ordered_requirements: list[str], errors: list[str]
) -> list[tuple[str, str, tuple[str, str, str, str, str], list[str]]]:
    """Read the canonical Architecture Claim register."""
    try:
        lines = CLAIM_SOURCE.read_text(encoding="utf-8").splitlines()
    except (OSError, UnicodeError) as error:
        raise SystemExit(f"cannot read claim source: {error}") from error
    claims: list[
        tuple[str, str, tuple[str, str, str, str, str], list[str]]
    ] = []
    for line in lines:
        if not line.startswith("| `AC-"):
            continue
        cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
        if len(cells) != 6:
            errors.append("claim source: invalid Architecture Claim row")
            continue
        claim_match = CLAIM_RE.search(cells[0])
        governing_match = re.search(r"(ADR|ARCHSPEC)-([0-9]{4})", cells[1])
        profile_match = re.fullmatch(r"`([DF])`", cells[5])
        if claim_match is None or governing_match is None or profile_match is None:
            errors.append(
                "claim source: missing claim, governing artifact, or state profile"
            )
            continue
        claim_key = claim_match.group(0)
        requirements = expand_requirement_trace(
            cells[2], ordered_requirements, errors, claim_key
        )
        profiles = {
            "D": (
                "Accepted",
                "Included",
                "Not Implemented",
                "Blocked",
                "Satisfies",
            ),
            "F": (
                "Deferred",
                "Future",
                "Not Implemented",
                "Blocked",
                "Intentional Deferral",
            ),
        }
        claims.append(
            (
                claim_key,
                governing_match.group(0),
                profiles[profile_match.group(1)],
                requirements,
            )
        )
    if not claims:
        errors.append("claim source: no Architecture Claims found")
    return claims


def governing_artifact(
    governing_identity: str,
    artifacts: dict[str, Artifact],
) -> str | None:
    """Resolve one ADR or ARCHSPEC identity to its registered artifact."""
    prefix, number = governing_identity.split("-", maxsplit=1)
    directory = "docs/adr" if prefix == "ADR" else "docs/architecture"
    path_prefix = f"{directory}/{number}-"
    matches = [
        artifact.identifier
        for artifact in artifacts.values()
        if artifact.location.startswith(path_prefix)
    ]
    return matches[0] if len(matches) == 1 else None


def parse_claim_traces(errors: list[str]) -> list[ClaimTrace]:
    """Parse the Architecture Claim trace register."""
    header, rows = read_csv(CLAIMS)
    if header != CLAIM_HEADER:
        errors.append("claim register: invalid header")
        return []
    claims: list[ClaimTrace] = []
    for line_number, row in enumerate(rows, start=2):
        if len(row) != len(CLAIM_HEADER):
            errors.append(
                f"claim register:{line_number}: expected {len(CLAIM_HEADER)} "
                f"columns, found {len(row)}"
            )
            continue
        claims.append(ClaimTrace(*row))
    if not claims:
        errors.append("claim register: no Architecture Claim rows")
    return claims


def validate_claim_traces(
    recorded: list[ClaimTrace],
    expected: list[
        tuple[str, str, tuple[str, str, str, str, str], list[str]]
    ],
    artifacts: dict[str, Artifact],
    dispositions: dict[str, str],
    errors: list[str],
) -> None:
    """Validate exact claim coverage, governing artifacts, and requirements."""
    if len(recorded) != len(expected):
        errors.append("claim register: Architecture Claim population mismatch")
    seen: set[str] = set()
    for sequence, (actual, canonical) in enumerate(zip(recorded, expected), start=1):
        claim_key, governing_identity, expected_state, expected_traces = canonical
        label = f"claim register:{actual.claim_key or sequence}"
        if actual.sequence != str(sequence):
            errors.append(f"{label}: invalid sequence")
        if not CLAIM_RE.fullmatch(actual.claim_key):
            errors.append(f"{label}: invalid Architecture Claim key")
        if actual.claim_key in seen:
            errors.append(f"{label}: duplicate Architecture Claim key")
        seen.add(actual.claim_key)
        if actual.claim_key != claim_key:
            errors.append(f"{label}: claim order or identity differs from source")
        expected_artifact = governing_artifact(governing_identity, artifacts)
        if expected_artifact is None:
            errors.append(f"{label}: governing artifact is missing or ambiguous")
        elif actual.artifact_identifier != expected_artifact:
            errors.append(f"{label}: incorrect governing artifact")
        elif artifacts[expected_artifact].artifact_class != "Architecture":
            errors.append(f"{label}: governing artifact is not Architecture")
        actual_state = (
            actual.decision_state,
            actual.baseline_applicability,
            actual.realization_state,
            actual.evidence_state,
            actual.disposition,
        )
        if actual_state != expected_state:
            errors.append(f"{label}: state or trace disposition differs from source")
        relations = split_trace_relations(actual.relations, label, errors)
        traces = [identifier for _, identifier in relations]
        if traces != expected_traces:
            errors.append(f"{label}: exact requirement traces differ from source")
        expected_relations = {
            "Included": "Satisfies",
            "Future": "Intentional Deferral",
            "Not Applicable": "Not Applicable",
        }
        for relation, trace in relations:
            applicability = dispositions.get(trace)
            if applicability is None:
                errors.append(f"{label}: unknown requirement trace {trace}")
            elif relation != expected_relations[applicability]:
                errors.append(
                    f"{label}: trace disposition differs from BAI-002: {trace}"
                )
    expected_keys = {claim[0] for claim in expected}
    for missing in sorted(expected_keys - seen):
        errors.append(f"claim register: missing Architecture Claim {missing}")
    for unexpected in sorted(seen - expected_keys):
        errors.append(f"claim register: unexpected Architecture Claim {unexpected}")


def package_sha256(recorded_digest: str) -> str:
    """Hash the canonicalized paths and contents of the inventory package."""
    digest = hashlib.sha256()
    placeholder = b"0" * 64
    for location in sorted(INVENTORY_PACKAGE):
        path = ROOT / location
        try:
            content = path.read_bytes()
        except OSError as error:
            raise SystemExit(f"cannot hash inventory package: {error}") from error
        content = content.replace(recorded_digest.encode(), placeholder)
        digest.update(location.encode())
        digest.update(b"\0")
        digest.update(content)
        digest.update(b"\0")
    return digest.hexdigest()


def validate_control(errors: list[str]) -> tuple[str, str, str]:
    """Return and validate the control text and exact package identity."""
    try:
        text = CONTROL.read_text(encoding="utf-8")
    except (OSError, UnicodeError) as error:
        raise SystemExit(f"cannot read inventory control: {error}") from error
    versions = re.findall(r"^Inventory version: `([^`]+)`$", text, re.MULTILINE)
    digests = re.findall(r"^Package SHA-256: `([^`]+)`$", text, re.MULTILINE)
    statuses = re.findall(r"^Status: (.+)$", text, re.MULTILINE)
    approved_digests = re.findall(
        r"^Approved package SHA-256: `([^`]+)`$", text, re.MULTILINE
    )
    if len(versions) != 1 or re.fullmatch(r"BARTINV-[0-9]{3}", versions[0]) is None:
        errors.append("inventory control: invalid inventory version")
        inventory_version = "INVALID"
    else:
        inventory_version = versions[0]
    if len(digests) != 1 or PACKAGE_DIGEST_RE.fullmatch(digests[0]) is None:
        errors.append("inventory control: invalid package SHA-256")
        recorded_digest = "0" * 64
    else:
        recorded_digest = digests[0]
    if statuses == ["Approved"]:
        if approved_digests != [recorded_digest]:
            errors.append("inventory control: approved package SHA-256 mismatch")
    elif approved_digests:
        errors.append("inventory control: unapproved inventory has approval digest")
    actual_digest = package_sha256(recorded_digest)
    if actual_digest != recorded_digest:
        errors.append("inventory control: stale package SHA-256")
    identity = f"{inventory_version}@sha256:{recorded_digest}"
    return text, inventory_version, identity


def main() -> int:
    """Validate the complete inventory package and report every finding."""
    errors: list[str] = []
    control_text, inventory_version, package_identity = validate_control(errors)
    evidence_identity = evidence_package_identity(errors)
    population = authoritative_population(control_text, errors)
    ordered_requirements, dispositions = applicability_registry(errors)
    artifacts = parse_artifacts(errors)
    artifact_by_identifier = validate_artifacts(
        artifacts,
        dispositions,
        population,
        package_identity,
        evidence_identity,
        errors,
    )
    expected_claims = canonical_claims(ordered_requirements, errors)
    claim_traces = parse_claim_traces(errors)
    validate_claim_traces(
        claim_traces,
        expected_claims,
        artifact_by_identifier,
        dispositions,
        errors,
    )
    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1
    class_counts = {
        artifact_class: sum(
            artifact.artifact_class == artifact_class for artifact in artifacts
        )
        for artifact_class in CLASS_CODES
    }
    counts = "; ".join(
        f"{artifact_class}={count}"
        for artifact_class, count in class_counts.items()
    )
    print(
        f"Baseline artifact inventory valid: {inventory_version}: "
        f"{len(artifacts)} artifacts; {len(claim_traces)} claims; {counts}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
