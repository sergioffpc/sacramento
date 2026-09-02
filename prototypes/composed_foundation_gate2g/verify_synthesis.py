#!/usr/bin/env python3
"""Verify that the final foundation synthesis is complete and evidence-linked."""

import argparse
import json
from collections import Counter
from pathlib import Path


REQUIRED_ISSUE_EVIDENCE = {
    "windows_debian_build",
    "rendering_shader_path",
    "authority_dependency_boundary",
    "map_content_pipeline",
    "network_determinism",
    "physics_interaction",
    "acoustic_propagation",
    "observability_profiles",
    "dependency_qualification",
    "vendor_type_containment",
}
REQUIRED_DRIVER_GROUPS = {
    "product_boundary",
    "authority_topology_time",
    "physical_composition",
    "content_lifecycle",
    "trust_offline_auth",
    "deployment_toolchain",
    "runtime_qualities",
    "observability_verification",
}
REQUIRED_SELECTION_DIMENSIONS = {
    "validity_safety_security_consistency_recovery",
    "latency_presentation_thresholds",
    "deterministic_replay_observability",
    "blender_offline_content",
    "platform_build_package_runtime",
    "first_party_coupling",
    "build_cost",
    "upgrade_dependency_licence",
    "two_generalist_maintenance",
}
REQUIRED_FOUNDATION = {
    "Flecs",
    "Falcor",
    "Slang",
    "PhysX",
    "GameNetworkingSockets",
    "Steam Audio",
    "Assimp",
    "Tracy",
    "Sacramento structured logging",
}
REQUIRED_EXCEPTIONS = {
    "EXC-FALCOR-VENDOR-CAPSULE",
    "EXC-BUILD-TOOL-VERSIONS",
    "EXC-CROSS-VCPKG-PROFILE",
    "EXC-VENDOR-SUPPORT-MATRIX",
    "EXC-GNS-CRYPTO-BACKENDS",
}
ALLOWED_DISPOSITIONS = {
    "pass",
    "pass_with_exceptions",
    "partial",
    "unproved",
    "owner_decision",
}


def keyed(items: list[dict[str, object]]) -> set[str]:
    return {str(item["id"]) for item in items}


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--synthesis", required=True, type=Path)
    parser.add_argument("--report", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    arguments = parser.parse_args()

    repository = Path(__file__).resolve().parents[2]
    synthesis = json.loads(arguments.synthesis.read_text(encoding="utf-8"))
    report = arguments.report.read_text(encoding="utf-8")
    errors: list[str] = []

    expected_sets = (
        ("issue_evidence", REQUIRED_ISSUE_EVIDENCE),
        ("architecture_drivers", REQUIRED_DRIVER_GROUPS),
        ("selection_dimensions", REQUIRED_SELECTION_DIMENSIONS),
    )
    all_rows: list[dict[str, object]] = []
    for field, required in expected_sets:
        rows = synthesis.get(field, [])
        if keyed(rows) != required:
            errors.append(f"{field} identifiers do not match the required set")
        all_rows.extend(rows)

    for row in all_rows:
        disposition = row.get("disposition")
        if disposition not in ALLOWED_DISPOSITIONS:
            errors.append(f"invalid disposition for {row.get('id')}: {disposition}")
        if not row.get("finding"):
            errors.append(f"missing finding for {row.get('id')}")
        evidence = row.get("evidence", [])
        if not evidence:
            errors.append(f"missing evidence for {row.get('id')}")
        for relative_value in evidence:
            relative = Path(str(relative_value))
            if relative.is_absolute() or not (repository / relative).is_file():
                errors.append(f"invalid evidence path for {row.get('id')}: {relative}")
        if str(row.get("id")) not in report:
            errors.append(f"report omits identifier {row.get('id')}")

    foundation = synthesis.get("selected_foundation", [])
    names = {str(item["name"]) for item in foundation}
    if names != REQUIRED_FOUNDATION:
        errors.append("selected foundation does not match issue #11")
    for item in foundation:
        if item.get("admission") != "prototype_evidence_only":
            errors.append(f"dependency incorrectly admitted: {item.get('name')}")
        if str(item.get("name")) not in report:
            errors.append(f"report omits foundation item {item.get('name')}")

    if synthesis.get("verdict") != "conditionally_viable":
        errors.append("verdict must remain conditionally_viable")
    if synthesis.get("production_admission") != "blocked":
        errors.append("production admission must remain blocked")
    exceptions = synthesis.get("exceptions", [])
    if keyed(exceptions) != REQUIRED_EXCEPTIONS:
        errors.append("exception identifiers do not match the required set")
    for exception in exceptions:
        identifier = str(exception.get("id"))
        if not exception.get("production_admission_blocking"):
            errors.append(f"exception is not admission-blocking: {identifier}")
        if not exception.get("summary"):
            errors.append(f"exception has no summary: {identifier}")
        if identifier not in report:
            errors.append(f"report omits exception {identifier}")
    unproved = synthesis.get("unproved", [])
    if not exceptions or not unproved:
        errors.append("exceptions and unproved obligations must be explicit")
    for obligation in unproved:
        if str(obligation) not in report:
            errors.append(f"report omits unproved obligation: {obligation}")
    if "Issue #13" not in str(synthesis.get("next_decision")):
        errors.append("next decision must point to issue #13")

    counts = Counter(str(row.get("disposition")) for row in all_rows)
    result = {
        "status": "fail" if errors else "pass",
        "verdict": synthesis.get("verdict"),
        "production_admission": synthesis.get("production_admission"),
        "rows": len(all_rows),
        "dispositions": dict(sorted(counts.items())),
        "foundation_items": len(foundation),
        "exceptions": len(exceptions),
        "unproved_obligations": len(unproved),
        "errors": errors,
    }
    arguments.output.write_text(
        json.dumps(result, indent=2, sort_keys=True) + "\n", encoding="utf-8"
    )
    print(json.dumps(result, sort_keys=True))
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
