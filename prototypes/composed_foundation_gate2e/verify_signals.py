#!/usr/bin/env python3
"""Verify Gate 2E OBS-CONTRACT-001 structure and profile separation."""

from __future__ import annotations

import argparse
import json
from pathlib import Path


CORE_SIGNALS = {
    "OBS-PROCESS-LIFECYCLE-001",
    "OBS-RUNTIME-IDENTITY-001",
    "OBS-ACTION-SUBMITTED-001",
    "OBS-ACTION-RESULT-RECEIVED-001",
    "OBS-ACTION-RESULT-PRESENTED-001",
    "OBS-ACOUSTIC-EVENT-INITIATED-001",
    "OBS-ACOUSTIC-EVENT-PRESENTED-001",
}
OPTIONAL_SIGNAL = "OBS-GATE2E-DIAGNOSTIC-MARKER-001"
FORBIDDEN_KEYS = {
    "gameplay_payload",
    "credential",
    "authentication_evidence",
    "personal_data",
}
ROLES = ("authority", "rendered", "synthetic")


def load(path: Path) -> list[dict[str, object]]:
    return [json.loads(line) for line in path.read_text(encoding="utf-8").splitlines()]


def normalized_core(records: list[dict[str, object]]) -> list[dict[str, object]]:
    result = []
    for record in records:
        if record["signal_id"] not in CORE_SIGNALS:
            continue
        item = dict(record)
        item.pop("source_instance_id")
        item.pop("source_sequence")
        if item["signal_id"] == "OBS-RUNTIME-IDENTITY-001":
            item.pop("observability_detail_level")
        result.append(item)
    return result


def verify_stream(records: list[dict[str, object]], detail: str) -> None:
    assert records
    assert [item["source_sequence"] for item in records] == list(
        range(1, len(records) + 1)
    )
    assert records[0]["signal_id"] == "OBS-PROCESS-LIFECYCLE-001"
    assert records[0]["lifecycle_state"] == "Started"
    assert records[1]["signal_id"] == "OBS-RUNTIME-IDENTITY-001"
    assert records[1]["observability_detail_level"] == detail
    assert records[-2]["lifecycle_state"] == "Stopping"
    assert records[-1]["lifecycle_state"] == "Terminated"
    for record in records:
        assert record["contract_version"] == "OBS-CONTRACT-001"
        assert record["build_version"] == "gate2e-prototype-build-001"
        assert record["configuration_version"] == "gate2e-observability-config-001"
        assert not (FORBIDDEN_KEYS & record.keys())
    optional_count = sum(item["signal_id"] == OPTIONAL_SIGNAL for item in records)
    assert optional_count == (1 if detail == "Diagnostic" else 0)
    if detail == "CoreOnly":
        assert all(item["signal_id"] in CORE_SIGNALS for item in records)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()

    streams: dict[tuple[str, str], list[dict[str, object]]] = {}
    for detail_slug, detail_name in (("core", "CoreOnly"), ("diagnostic", "Diagnostic")):
        for role in ROLES:
            records = load(args.root / f"{detail_slug}-{role}.ndjson")
            verify_stream(records, detail_name)
            streams[(detail_slug, role)] = records

    for role in ROLES:
        assert normalized_core(streams[("core", role)]) == normalized_core(
            streams[("diagnostic", role)]
        )

    action_ids = {
        item["event_correlation_id"]
        for records in streams.values()
        for item in records
        if str(item["signal_id"]).startswith("OBS-ACTION-")
    }
    acoustic_ids = {
        item["event_correlation_id"]
        for records in streams.values()
        for item in records
        if str(item["signal_id"]).startswith("OBS-ACOUSTIC-")
    }
    assert action_ids == {"action-gate2e-017"}
    assert acoustic_ids == {"acoustic-gate2e-045"}
    assert action_ids.isdisjoint(acoustic_ids)

    summary = {
        "status": "pass",
        "contract_version": "OBS-CONTRACT-001",
        "core_only_optional_signals": 0,
        "diagnostic_optional_signals": 3,
        "core_semantics_equal": True,
        "action_correlation": "pass",
        "acoustic_correlation": "pass",
        "sensitive_fields": 0,
    }
    args.output.write_text(json.dumps(summary, sort_keys=True) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
