#!/usr/bin/env python3
"""Validate the effective Evidence Dependency Inventory graph."""

from __future__ import annotations

import csv
import hashlib
import pathlib
import re
import subprocess
import sys
from collections import Counter, defaultdict, deque
from dataclasses import dataclass
from enum import StrEnum


ROOT = pathlib.Path(__file__).resolve().parents[1]
CONTROL = ROOT / "docs/project/training-simulation-evidence-dependency-inventory.md"
NODES = ROOT / "docs/project/training-simulation-evidence-dependency-nodes.csv"
RELATIONS = ROOT / "docs/project/training-simulation-evidence-dependency-relations.csv"
CASES = ROOT / "docs/project/training-simulation-evidence-impact-cases.csv"
BART_CONTROL = ROOT / "docs/project/training-simulation-baseline-artifact-inventory.md"
BART_ARTIFACTS = ROOT / "docs/project/training-simulation-baseline-artifacts.csv"
CLAIMS = ROOT / "docs/project/training-simulation-architecture-claim-traces.csv"
BAI_CONTROL = ROOT / "docs/requirements/training-simulation-baseline-applicability.md"
BAI = ROOT / "docs/requirements/training-simulation-baseline-applicability-inventory.csv"
DOCINV = ROOT / "docs/project/training-simulation-documentation-inventory.md"
SAD = ROOT / "docs/architecture/software-architecture-description.md"
DESIGN_COMMITMENTS = ROOT / "docs/design/training-simulation-design-commitments.csv"

PACKAGE = (CONTROL, NODES, RELATIONS, CASES)
NODE_HEADER = [
    "sequence", "node_identifier", "node_class", "source_identity",
    "exact_version", "canonical_location", "registration_state",
    "responsible_owner", "classification_basis",
]
RELATION_HEADER = [
    "sequence", "relation_identifier", "source_node_identifier",
    "target_node_identifier", "relation_type", "classification_basis",
]
CASE_HEADER = [
    "sequence", "case_identifier", "case_class", "start_node_identifier",
    "target_node_identifier", "injected_condition", "expected_disposition",
    "expected_path_count", "rule_basis",
]
BART_HEADER = [
    "sequence", "artifact_identifier", "artifact_class", "exact_version",
    "canonical_location", "baseline_status", "responsible_owner",
    "trace_disposition", "requirement_traces", "trace_basis",
]
CLAIM_HEADER = [
    "sequence", "architecture_claim_key", "governing_artifact_identifier",
    "decision_state", "baseline_applicability", "realization_state",
    "evidence_state", "claim_disposition", "requirement_trace_relations",
]
BAI_HEADER = [
    "sequence", "requirement_identifier", "disposition",
    "milestone_or_justification", "responsible_owner",
]
DESIGN_HEADER = [
    "sequence", "design_commitment_id", "governing_sdd", "decision_state",
    "applicability_state", "realization_state", "evidence_state",
    "disposition", "requirement_traces", "architecture_claim_traces",
    "sad_view_traces", "responsible_owner", "verification_approach",
]


class NodeClass(StrEnum):
    REQUIREMENT = "Requirement Identifier"
    OBLIGATION = "Obligation Key"
    COMPONENT = "Product Component"
    CONFIGURATION = "Configuration Item"
    SCENARIO = "Scenario"
    MAP = "Map"
    CONTENT = "Content Item"
    PROFILE = "Approved Profile"
    PROCEDURE = "Verification Procedure"
    INPUT = "Input Data Set"
    ENVIRONMENT = "Verification Environment"
    EVIDENCE = "Evidence Record"
    CLAIM = "Architecture Claim"
    VIEW = "Software Architecture Description View"
    SDD = "Software Design Document"
    COMMITMENT = "Design Commitment"
    ARTIFACT = "Governed Artifact"


class RelationType(StrEnum):
    GOVERNS = "governs"
    DEFINES = "defines"
    DEPENDS = "depends-on"
    MAPS = "maps-to"
    INPUT = "input-to"
    VERIFIES = "verified-by"
    PRODUCES = "produces"
    SUPPORTS_APPROVAL = "supports-approval"


class CaseClass(StrEnum):
    DIRECT = "Direct"
    TRANSITIVE = "Transitive"
    MULTIPLE = "Multiple Path"
    ABSENT = "Absent Path"
    STALE = "Stale"
    UNCLASSIFIED = "Unclassified"
    UNCERTAIN = "Uncertain"
    INVARIANCE = "Obligation Invariance"
    SUCCESSOR = "Inventory Successor"


class InjectedCondition(StrEnum):
    NONE = "None"
    STALE = "Source exact version differs from BARTINV-008"
    UNCLASSIFIED = "Relation type is empty"
    MISSING_RELATION = "Known validator input relation is removed"
    INVARIANCE = "Reproducible analysis retains exact obligation-level criterion and Pass"
    PREDECESSOR = "Retained analysis names predecessor EDI-005"


class Disposition(StrEnum):
    AFFECTED = "Affected — reverification required"
    REEVALUATE = "Affected — re-evaluation required"
    NO_PATH = "Unaffected — no approved path"
    INVARIANT = "Unaffected — owner approval required"


NODE_CLASSES = {item.value for item in NodeClass}
EMPTY_CLASSES = {"Obligation Key", "Scenario", "Map", "Content Item", "Approved Profile"}
RELATION_TYPES = {item.value for item in RelationType}
PACKAGE_DIGEST_RE = re.compile(r"[0-9a-f]{64}")
SHA256_RE = re.compile(r"sha256:[0-9a-f]{64}")
EDI_ID_RE = re.compile(r"EDI-(?:PC|VIEW|ENV|PROC|EVID|DATA)-[0-9]{3}")
RELATION_ID_RE = re.compile(r"EDI-REL-[0-9]{3}")
CASE_ID_RE = re.compile(r"EDI-CASE-[A-Z]+-[0-9]{3}")


@dataclass(frozen=True)
class Node:
    identifier: str
    node_class: NodeClass
    exact_version: str
    location: str


@dataclass(frozen=True)
class Edge:
    identifier: str
    source: str
    target: str
    relation_type: RelationType


def read_text(path: pathlib.Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except (OSError, UnicodeError) as error:
        raise SystemExit(f"cannot read {path.relative_to(ROOT)}: {error}") from error


def read_csv(path: pathlib.Path) -> tuple[list[str], list[list[str]]]:
    try:
        with path.open(encoding="utf-8", newline="") as source:
            rows = list(csv.reader(source))
    except (OSError, UnicodeError, csv.Error) as error:
        raise SystemExit(f"cannot read {path.relative_to(ROOT)}: {error}") from error
    return (rows[0], rows[1:]) if rows else ([], [])


def extract_unique_match(
    pattern: str, text: str, label: str, errors: list[str]
) -> str:
    values = re.findall(pattern, text, flags=re.MULTILINE)
    if len(values) != 1:
        errors.append(f"{label}: expected exactly one value")
        return ""
    return values[0]


def validated_rows(
    path: pathlib.Path, expected_header: list[str], label: str, errors: list[str]
) -> list[list[str]]:
    """Return rows after validating the common CSV shape and sequence."""
    header, rows = read_csv(path)
    if header != expected_header:
        errors.append(f"{label}: invalid header")
    valid: list[list[str]] = []
    for sequence, row in enumerate(rows, start=1):
        if len(row) != len(expected_header):
            errors.append(f"{label}:{sequence + 1}: invalid column count")
            continue
        if row[0] != str(sequence):
            errors.append(f"{label}:{sequence + 1}: invalid sequence")
        valid.append(row)
    return valid


def validate_controls(errors: list[str]) -> str:
    edi = read_text(CONTROL)
    bart = read_text(BART_CONTROL)
    bai = read_text(BAI_CONTROL)
    docinv = read_text(DOCINV)
    version = extract_unique_match(r"^Inventory version: `([^`]+)`$", edi, "EDI version", errors)
    digest = extract_unique_match(r"^Package SHA-256: `([^`]+)`$", edi, "EDI digest", errors)
    bart_version = extract_unique_match(r"^Inventory version: `([^`]+)`$", bart, "BART version", errors)
    bart_digest = extract_unique_match(r"^Package SHA-256: `([^`]+)`$", bart, "BART digest", errors)
    bai_version = extract_unique_match(r"^Inventory version: `([^`]+)`$", bai, "BAI version", errors)
    doc_version = extract_unique_match(r"^Inventory version: `([^`]+)`$", docinv, "DOCINV version", errors)
    if version != "EDI-006":
        errors.append("EDI control: expected EDI-006")
    if bart_version != "BARTINV-008":
        errors.append("EDI control: expected BARTINV-008")
    if bai_version != "BAI-005":
        errors.append("EDI control: expected BAI-005")
    if doc_version != "DOCINV-011":
        errors.append("EDI control: expected DOCINV-011")
    expected_bart_identity = f"BARTINV-008@sha256:{bart_digest}"
    if expected_bart_identity not in edi:
        errors.append("EDI control: stale Baseline Artifact Inventory identity")
    if not PACKAGE_DIGEST_RE.fullmatch(digest):
        errors.append("EDI control: invalid package SHA-256")
        digest = "0" * 64
    placeholder = b"0" * 64
    calculated = hashlib.sha256()
    for path in sorted(PACKAGE):
        content = path.read_bytes()
        content = content.replace(digest.encode(), placeholder)
        if PACKAGE_DIGEST_RE.fullmatch(bart_digest):
            content = content.replace(bart_digest.encode(), placeholder)
        relative = path.relative_to(ROOT).as_posix().encode()
        calculated.update(relative)
        calculated.update(b"\0")
        calculated.update(content)
        calculated.update(b"\0")
    if calculated.hexdigest() != digest:
        errors.append("EDI control: stale package SHA-256")
    statuses = re.findall(r"^Status: (.+)$", edi, flags=re.MULTILINE)
    approvals = re.findall(r"^Approved package SHA-256: `([^`]+)`$", edi, flags=re.MULTILINE)
    if statuses == ["Approved"]:
        if approvals != [digest]:
            errors.append("EDI control: approved package SHA-256 mismatch")
    elif approvals:
        errors.append("EDI control: candidate inventory has approval digest")
    return version


def artifact_node_class(artifact_class: str, location: str) -> NodeClass:
    if artifact_class == "Implementation":
        return NodeClass.CONFIGURATION
    if artifact_class != "Verification":
        if artifact_class == "Design" and re.fullmatch(
            r"docs/design/[0-9]{4}-.+\.md", location
        ):
            return NodeClass.SDD
        return NodeClass.ARTIFACT
    if location.startswith(("scripts/", ".github/workflows/", ".githooks/")):
        return NodeClass.PROCEDURE
    if location.endswith(".csv") or location.startswith((".clang-",)):
        return NodeClass.INPUT
    return NodeClass.ARTIFACT


def import_nodes(errors: list[str]) -> tuple[dict[str, Node], list[Edge]]:
    nodes: dict[str, Node] = {}
    edges: list[Edge] = []
    bai_rows = validated_rows(BAI, BAI_HEADER, "BAI", errors)
    for row in bai_rows:
        identifier = row[1]
        if identifier in nodes:
            errors.append(f"effective nodes: duplicate {identifier}")
        nodes[identifier] = Node(
            identifier,
            NodeClass.REQUIREMENT,
            "BAI-005",
            BAI.relative_to(ROOT).as_posix(),
        )

    bart_rows = validated_rows(BART_ARTIFACTS, BART_HEADER, "BART", errors)
    artifacts: set[str] = set()
    for row in bart_rows:
        identifier, artifact_class, exact_version, location = row[1:5]
        artifacts.add(identifier)
        if identifier in nodes:
            errors.append(f"effective nodes: duplicate {identifier}")
        nodes[identifier] = Node(identifier, artifact_node_class(artifact_class, location), exact_version, location)
        for requirement in row[8].split(";") if row[8] else []:
            edge_id = f"EDI-DERIVED-BART-{identifier}-{requirement}"
            edges.append(Edge(edge_id, requirement, identifier, RelationType.GOVERNS))

    claim_rows = validated_rows(CLAIMS, CLAIM_HEADER, "claim register", errors)
    claim_prefix_views = {
        "AC-TOOLCHAIN-": "EDI-VIEW-003", "AC-FOUNDATION-": "EDI-VIEW-003",
        "AC-DECOMPOSITION-": "EDI-VIEW-003", "AC-RUNTIME-": "EDI-VIEW-004",
        "AC-CONCURRENCY-": "EDI-VIEW-005", "AC-CONTENT-": "EDI-VIEW-006",
        "AC-MEMORY-": "EDI-VIEW-007", "AC-RESOURCE-": "EDI-VIEW-006",
        "AC-RETENTION-": "EDI-VIEW-006", "AC-DEPLOYMENT-": "EDI-VIEW-002",
        "AC-CROSSCUTTING-": "EDI-VIEW-007", "AC-TOOLING-": "EDI-VIEW-006",
    }
    for row in claim_rows:
        claim, artifact = row[1], row[2]
        if artifact not in artifacts:
            errors.append(f"claim register:{claim}: unknown governing artifact")
        nodes[claim] = Node(
            claim,
            NodeClass.CLAIM,
            "BARTINV-008",
            CLAIMS.relative_to(ROOT).as_posix(),
        )
        edges.append(
            Edge(
                f"EDI-DERIVED-CLAIM-ARTIFACT-{claim}",
                artifact,
                claim,
                RelationType.DEFINES,
            )
        )
        for relation in row[8].split(";"):
            _, separator, requirement = relation.partition(":")
            if not separator or requirement not in nodes:
                errors.append(f"claim register:{claim}: unknown requirement relation")
                continue
            edges.append(
                Edge(
                    f"EDI-DERIVED-CLAIM-REQ-{claim}-{requirement}",
                    requirement,
                    claim,
                    RelationType.GOVERNS,
                )
            )
        matched = [view for prefix, view in claim_prefix_views.items() if claim.startswith(prefix)]
        if len(matched) != 1:
            errors.append(f"claim register:{claim}: no unique SAD view mapping")
        else:
            edges.append(
                Edge(
                    f"EDI-DERIVED-CLAIM-VIEW-{claim}",
                    claim,
                    matched[0],
                    RelationType.MAPS,
                )
            )
        edges.append(
            Edge(
                f"EDI-DERIVED-CLAIM-VERIFY-{claim}",
                claim,
                "EDI-VIEW-008",
                RelationType.MAPS,
            )
        )
    design_rows = validated_rows(
        DESIGN_COMMITMENTS, DESIGN_HEADER, "design commitments", errors
    )
    sdd_artifacts = {
        "SDD-0001": "BART-DES-016",
        "SDD-0002": "BART-DES-017",
        "SDD-0003": "BART-DES-018",
        "SDD-0004": "BART-DES-019",
    }
    for row in design_rows:
        commitment, sdd = row[1], row[2]
        nodes[commitment] = Node(
            commitment,
            NodeClass.COMMITMENT,
            "SDB-001",
            DESIGN_COMMITMENTS.relative_to(ROOT).as_posix(),
        )
        target = sdd_artifacts.get(sdd)
        if target is None or target not in nodes:
            errors.append(f"design commitments:{commitment}: unknown governing SDD")
        else:
            edges.append(Edge(
                f"EDI-DERIVED-DC-SDD-{commitment}", commitment, target,
                RelationType.MAPS,
            ))
        for requirement in row[8].split("|"):
            if requirement not in nodes:
                errors.append(f"design commitments:{commitment}: unknown requirement")
            else:
                edges.append(Edge(
                    f"EDI-DERIVED-DC-REQ-{commitment}-{requirement}",
                    requirement, commitment, RelationType.GOVERNS,
                ))
        for claim in row[9].split("|"):
            if claim not in nodes:
                errors.append(f"design commitments:{commitment}: unknown claim")
            else:
                edges.append(Edge(
                    f"EDI-DERIVED-DC-CLAIM-{commitment}-{claim}",
                    claim, commitment, RelationType.GOVERNS,
                ))
        for view in row[10].split("|"):
            edges.append(Edge(
                f"EDI-DERIVED-DC-VIEW-{commitment}-{view}",
                view, commitment, RelationType.GOVERNS,
            ))
    return nodes, edges


def supplemental_nodes(nodes: dict[str, Node], errors: list[str]) -> None:
    rows = validated_rows(NODES, NODE_HEADER, "supplemental nodes", errors)
    expected_component_sources = {
        *(f"ARCHSPEC-0004:{name}" for name in (
            "Simulation", "Scenario", "Session Lifecycle", "AUTH & Admission", "Runtime Package",
            "Content Admission", "Protocol & Replication", "Observability",
            "Trainee Performance Assessment Module", "Prediction", "Presentation",
            "Input & Interaction", "Session Authority Runtime", "Trainee Client Runtime",
            "Content Cooker Tool", "Administrative Tools", "Synthetic Client Runtime",
        )),
    }
    expected_view_sources = {
        f"SAD-003:EDI-VIEW-{number:03d}" for number in range(1, 10)
    }
    actual_sources: set[str] = set()
    for row in rows:
        identifier, node_class, source, exact_version, location = row[1:6]
        if EDI_ID_RE.fullmatch(identifier) is None:
            errors.append(f"supplemental nodes:{identifier}: invalid identifier")
        if identifier in nodes:
            errors.append(f"effective nodes: duplicate {identifier}")
        if node_class not in NODE_CLASSES:
            errors.append(f"supplemental nodes:{identifier}: invalid class")
            parsed_class = NodeClass.ARTIFACT
        else:
            parsed_class = NodeClass(node_class)
        if row[6] not in {"Current", "Planned"} or not row[7] or not row[8]:
            errors.append(f"supplemental nodes:{identifier}: incomplete classification")
        nodes[identifier] = Node(identifier, parsed_class, exact_version, location)
        if source.startswith(("ARCHSPEC-0004:", "SAD-003:")):
            actual_sources.add(source)
        if parsed_class == NodeClass.VIEW:
            expected_fragment = f"#edi-view-{int(identifier[-3:]):03d}-"
            if (
                row[6] != "Current"
                or SHA256_RE.fullmatch(exact_version) is None
                or not location.startswith(
                    "docs/architecture/software-architecture-description.md"
                )
                or expected_fragment not in location
            ):
                errors.append(
                    f"supplemental nodes:{identifier}: invalid SAD realization"
                )
    if actual_sources != expected_component_sources | expected_view_sources:
        errors.append("supplemental nodes: component or SAD view population mismatch")
    evidence = sorted(identifier for identifier, node in nodes.items() if node.node_class == "Evidence Record")
    if evidence != [f"EDI-EVID-{number:03d}" for number in range(1, 14)]:
        errors.append("supplemental nodes: planned evidence population mismatch")


def canonical_review_diff(raw_diff: bytes) -> bytes:
    """Normalize recursive digests and approval-only lines in a review diff."""
    normalized: list[bytes] = []
    markdown = False
    for line in raw_diff.splitlines(keepends=True):
        if line.startswith(b"+++ "):
            markdown = line.startswith(b"+++ b/") and line.rstrip().endswith(b".md")
        if line.startswith(b"index "):
            continue
        changed = line.startswith((b"+", b"-")) and not line.startswith((b"+++", b"---"))
        if changed and markdown:
            if re.match(rb"^[+-]Approved package SHA-256:", line):
                continue
            line = re.sub(
                rb"^([+-](?:Status|Approval):) .+(\r?\n)$",
                rb"\1 <approval-state>\2",
                line,
            )
            if re.match(rb"^[+-]\| `DOC-[0-9]{3}` \|", line):
                line = re.sub(
                    rb"\| (?:Candidate|Approved)[^|]*\|(\r?\n)$",
                    rb"| <approval-state> |\1",
                    line,
                )
            line = re.sub(
                rb"\b(?:Candidate|Approved) (`(?:DOCINV|BARTINV|EDI|SAD)-[0-9]{3})",
                rb"Controlled \1",
                line,
            )
            line = re.sub(
                rb"\b(?:candidate|approved) (Baseline Artifact Inventory|Evidence Dependency Inventory)",
                rb"controlled \1",
                line,
            )
            line = re.sub(
                rb"\b(?:candidate|approved) (\[(?:Baseline Artifact|Documentation) Inventory successor)",
                rb"controlled \1",
                line,
            )
            line = re.sub(rb"imports (?:candidate|approved)", b"imports controlled", line)
            line = re.sub(
                rb"(?:exact-version )?approval (?:remains pending|was granted(?: by the project owner)?(?: on [0-9]{4}-[0-9]{2}-[0-9]{2})?)",
                b"exact-version approval <state>",
                line,
            )
        normalized.append(line)
    return re.sub(rb"[0-9a-f]{64}", b"0" * 64, b"".join(normalized))


def validate_review_inputs(nodes: dict[str, Node], errors: list[str]) -> None:
    """Bind review nodes to exact issue content and the current staged diff."""
    diff_node = nodes.get("EDI-DATA-001")
    issue_node = nodes.get("EDI-DATA-002")
    if diff_node is None or not SHA256_RE.fullmatch(diff_node.exact_version):
        errors.append("review inputs: fixed staged diff lacks an exact SHA-256")
    if issue_node is None or not SHA256_RE.fullmatch(issue_node.exact_version):
        errors.append("review inputs: issue 53 lacks an exact body SHA-256")
    result = subprocess.run(
        ["git", "diff", "--cached", "--binary"],
        cwd=ROOT,
        check=True,
        capture_output=True,
    )
    if result.stdout and diff_node is not None:
        actual = "sha256:" + hashlib.sha256(
            canonical_review_diff(result.stdout)
        ).hexdigest()
        if actual != diff_node.exact_version:
            errors.append("review inputs: stale fixed staged diff SHA-256")


def explicit_edges(nodes: dict[str, Node], edges: list[Edge], errors: list[str]) -> None:
    rows = validated_rows(RELATIONS, RELATION_HEADER, "supplemental relations", errors)
    for row in rows:
        identifier, source, target, relation_type, basis = row[1:]
        if RELATION_ID_RE.fullmatch(identifier) is None:
            errors.append(f"supplemental relations:{identifier}: invalid identifier")
        if source not in nodes or target not in nodes:
            errors.append(f"supplemental relations:{identifier}: unknown endpoint")
        if relation_type not in RELATION_TYPES or not basis:
            errors.append(f"supplemental relations:{identifier}: incomplete classification")
            parsed_type = RelationType.DEPENDS
        else:
            parsed_type = RelationType(relation_type)
        edges.append(Edge(identifier, source, target, parsed_type))


def declared_claim_view_mappings(
    claims: set[str], errors: list[str]
) -> set[tuple[str, str]]:
    """Expand the SAD's controlled claim expressions into exact graph edges."""
    text = SAD.read_text(encoding="utf-8")
    headings = list(re.finditer(r"^## `(?P<view>EDI-VIEW-\d{3})`:", text, re.MULTILINE))
    if [match.group("view") for match in headings] != [
        f"EDI-VIEW-{number:03d}" for number in range(1, 10)
    ]:
        errors.append("SAD mappings: expected ordered view population missing")
        return set()

    mappings: set[tuple[str, str]] = set()
    range_pattern = re.compile(r"`(AC-[A-Z]+-)(\d{3})` through `(AC-[A-Z]+-)(\d{3})`")
    for index, heading in enumerate(headings):
        end = headings[index + 1].start() if index + 1 < len(headings) else len(text)
        section = text[heading.end():end]
        row = re.search(r"^\| Architecture Claim mappings \| (?P<value>.+) \|$", section, re.MULTILINE)
        if row is None:
            errors.append(f"SAD mappings:{heading.group('view')}: mapping field missing")
            continue
        value = row.group("value")
        declared: set[str] = set(re.findall(r"`(AC-[A-Z]+-\d{3})`", value))
        for start_prefix, start_number, end_prefix, end_number in range_pattern.findall(value):
            if start_prefix != end_prefix or int(start_number) > int(end_number):
                errors.append(f"SAD mappings:{heading.group('view')}: invalid claim range")
                continue
            declared.update(
                f"{start_prefix}{number:03d}"
                for number in range(int(start_number), int(end_number) + 1)
            )
        for prefix in re.findall(r"`(AC-[A-Z]+-)\*`", value):
            declared.update(claim for claim in claims if claim.startswith(prefix))
        if "`AC-*`" in value:
            declared.update(claims)
        unknown = declared - claims
        if unknown:
            errors.append(
                f"SAD mappings:{heading.group('view')}: unknown claims {sorted(unknown)}"
            )
        mappings.update(
            (claim, heading.group("view")) for claim in declared if claim in claims
        )
    return mappings


def validate_graph(nodes: dict[str, Node], edges: list[Edge], errors: list[str]) -> None:
    edge_ids = [edge.identifier for edge in edges]
    if len(edge_ids) != len(set(edge_ids)):
        errors.append("effective relations: duplicate identifier")
    pairs = [(edge.source, edge.target, edge.relation_type) for edge in edges]
    if len(pairs) != len(set(pairs)):
        errors.append("effective relations: duplicate typed edge")
    for edge in edges:
        if edge.source not in nodes or edge.target not in nodes:
            errors.append(f"effective relations:{edge.identifier}: unknown endpoint")
    counts = Counter(node.node_class for node in nodes.values())
    missing = NODE_CLASSES - EMPTY_CLASSES - set(counts)
    if missing:
        errors.append(f"effective nodes: missing nonempty classes {sorted(missing)}")
    for empty in EMPTY_CLASSES:
        if counts[empty] != 0:
            errors.append(f"effective nodes: {empty} must match closed zero population")
    sad = nodes.get("BART-ARC-024")
    expected_views = {f"EDI-VIEW-{number:03d}" for number in range(1, 10)}
    realized_views = {
        edge.target
        for edge in edges
        if edge.source == "BART-ARC-024"
        and edge.relation_type == RelationType.DEFINES
    }
    if sad is None or realized_views != expected_views:
        errors.append("effective relations: SAD view realization mismatch")
    elif any(nodes[view].exact_version != sad.exact_version for view in expected_views):
        errors.append("effective nodes: SAD view exact version mismatch")
    claims = {
        identifier for identifier, node in nodes.items()
        if node.node_class == NodeClass.CLAIM
    }
    declared_mappings = declared_claim_view_mappings(claims, errors)
    registered_mappings = {
        (edge.source, edge.target)
        for edge in edges
        if edge.relation_type == RelationType.MAPS
        and edge.source in claims
        and edge.target in expected_views
    }
    if registered_mappings != declared_mappings:
        missing = sorted(declared_mappings - registered_mappings)
        extra = sorted(registered_mappings - declared_mappings)
        errors.append(
            "effective relations: SAD claim-to-view mapping mismatch "
            f"(missing={missing}, extra={extra})"
        )
    produced = {
        edge.target for edge in edges
        if edge.relation_type == RelationType.PRODUCES
    }
    expected_evidence = {f"EDI-EVID-{number:03d}" for number in range(1, 14)}
    if produced & expected_evidence != expected_evidence:
        errors.append("effective relations: every planned evidence record needs a producer")
    validator_inputs = {
        edge.source for edge in edges
        if edge.target == "BART-VER-022"
        and edge.relation_type == RelationType.INPUT
    }
    required_inputs = {
        "BART-VER-018", "BART-VER-019", "BART-VER-020", "BART-VER-021",
        "BART-VER-008", "BART-VER-006", "BART-VER-010", "BART-VER-007",
        "BART-VER-011", "BART-VER-009", "EDI-ENV-001",
    }
    if validator_inputs != required_inputs:
        errors.append("effective relations: validator input closure mismatch")
    procedures = {
        identifier for identifier, node in nodes.items()
        if node.node_class == NodeClass.PROCEDURE
    }
    consumers = {
        edge.target for edge in edges
        if edge.relation_type in {
            RelationType.INPUT,
            RelationType.DEPENDS,
            RelationType.SUPPORTS_APPROVAL,
        }
    }
    producers = {
        edge.source for edge in edges
        if edge.relation_type == RelationType.PRODUCES
    }
    if procedures - consumers:
        errors.append(
            f"effective relations: procedures lack declared inputs or dependencies "
            f"{sorted(procedures - consumers)}"
        )
    if procedures - producers:
        errors.append(
            f"effective relations: procedures lack pre-registered outputs "
            f"{sorted(procedures - producers)}"
        )


def adjacency(edges: list[Edge]) -> dict[str, list[str]]:
    """Build one directed adjacency map for impact traversal."""
    graph: dict[str, list[str]] = defaultdict(list)
    for edge in edges:
        graph[edge.source].append(edge.target)
    return graph


def path_count(
    graph: dict[str, list[str]], start: str, target: str, limit: int = 1000
) -> int:
    count = 0
    queue: deque[tuple[str, frozenset[str]]] = deque([(start, frozenset({start}))])
    while queue and count < limit:
        node, visited = queue.popleft()
        for successor in graph[node]:
            if successor in visited:
                continue
            if successor == target:
                count += 1
            else:
                queue.append((successor, visited | {successor}))
    return count


def shortest_distance(
    graph: dict[str, list[str]], start: str, target: str
) -> int | None:
    """Return the shortest directed edge count, or None when no path exists."""
    queue: deque[tuple[str, int]] = deque([(start, 0)])
    visited = {start}
    while queue:
        node, distance = queue.popleft()
        for successor in graph[node]:
            if successor == target:
                return distance + 1
            if successor not in visited:
                visited.add(successor)
                queue.append((successor, distance + 1))
    return None


def classify_case(
    edges: list[Edge],
    graph: dict[str, list[str]],
    start: str,
    target: str,
    injected: InjectedCondition,
) -> tuple[Disposition, int]:
    """Inject one registered test condition and calculate its disposition."""
    if injected in {InjectedCondition.STALE, InjectedCondition.UNCLASSIFIED}:
        return Disposition.AFFECTED, -1
    if injected == InjectedCondition.MISSING_RELATION:
        filtered = [
            edge for edge in edges
            if not (edge.source == start and edge.target == "BART-VER-022")
        ]
        remaining_paths = path_count(adjacency(filtered), start, target)
        return Disposition.AFFECTED, remaining_paths
    if injected == InjectedCondition.PREDECESSOR:
        return Disposition.REEVALUATE, -1
    paths = path_count(graph, start, target)
    if injected == InjectedCondition.INVARIANCE:
        if paths == 0:
            return Disposition.AFFECTED, paths
        return Disposition.INVARIANT, paths
    if paths == 0:
        return Disposition.NO_PATH, paths
    return Disposition.AFFECTED, paths


def validate_cases(nodes: dict[str, Node], edges: list[Edge], errors: list[str]) -> None:
    rows = validated_rows(CASES, CASE_HEADER, "impact cases", errors)
    required_classes = set(CaseClass)
    seen_classes: set[CaseClass] = set()
    graph = adjacency(edges)
    for row in rows:
        if CASE_ID_RE.fullmatch(row[1]) is None:
            errors.append(f"impact cases:{row[0]}: invalid identity")
        raw_class, start, target, raw_injected, raw_disposition, expected_paths, basis = row[2:]
        try:
            case_class = CaseClass(raw_class)
            injected = InjectedCondition(raw_injected)
            disposition = Disposition(raw_disposition)
        except ValueError as error:
            errors.append(f"impact cases:{row[1]}: unknown controlled value: {error}")
            continue
        seen_classes.add(case_class)
        if start not in nodes or target not in nodes or not basis:
            errors.append(f"impact cases:{row[1]}: incomplete or unknown endpoint")
            continue
        calculated_disposition, calculated_paths = classify_case(
            edges, graph, start, target, injected
        )
        distance = shortest_distance(graph, start, target)
        if calculated_disposition != disposition:
            errors.append(f"impact cases:{row[1]}: calculated disposition differs")
        if case_class == CaseClass.DIRECT and distance != 1:
            errors.append(f"impact cases:{row[1]}: expected one direct edge")
        elif case_class == CaseClass.TRANSITIVE and (distance is None or distance < 2):
            errors.append(f"impact cases:{row[1]}: expected a transitive path")
        elif case_class == CaseClass.MULTIPLE and calculated_paths < 2:
            errors.append(f"impact cases:{row[1]}: multiple paths absent")
        elif case_class == CaseClass.ABSENT and calculated_paths != 0:
            errors.append(f"impact cases:{row[1]}: expected absent path")
        elif case_class == CaseClass.INVARIANCE and calculated_paths < 1:
            errors.append(f"impact cases:{row[1]}: invariance case needs a path")
        if (
            expected_paths.isdigit()
            and case_class != CaseClass.MULTIPLE
            and calculated_paths != int(expected_paths)
        ):
            errors.append(f"impact cases:{row[1]}: unexpected path count")
        if case_class in {
            CaseClass.STALE,
            CaseClass.UNCLASSIFIED,
            CaseClass.UNCERTAIN,
            CaseClass.SUCCESSOR,
        }:
            if injected == InjectedCondition.NONE or not disposition.startswith("Affected"):
                errors.append(f"impact cases:{row[1]}: conservative fault disposition missing")
        if case_class == CaseClass.ABSENT and disposition != Disposition.NO_PATH:
            errors.append(f"impact cases:{row[1]}: invalid no-path disposition")
        if case_class == CaseClass.INVARIANCE and disposition != Disposition.INVARIANT:
            errors.append(f"impact cases:{row[1]}: invalid invariance disposition")
    if seen_classes != required_classes:
        errors.append("impact cases: required case population mismatch")


def main() -> int:
    errors: list[str] = []
    version = validate_controls(errors)
    nodes, edges = import_nodes(errors)
    supplemental_nodes(nodes, errors)
    validate_review_inputs(nodes, errors)
    explicit_edges(nodes, edges, errors)
    validate_graph(nodes, edges, errors)
    validate_cases(nodes, edges, errors)
    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        print(f"evidence dependency inventory validation failed: {len(errors)} error(s)", file=sys.stderr)
        return 1
    counts = Counter(node.node_class for node in nodes.values())
    nonzero = "; ".join(f"{name}={counts[name]}" for name in sorted(counts))
    print(f"Evidence dependency inventory valid: {version}: {len(nodes)} nodes; {len(edges)} relations; {nonzero}")
    print("Impact cases valid: 10 cases; conservative uncertainty and successor re-evaluation enforced")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
