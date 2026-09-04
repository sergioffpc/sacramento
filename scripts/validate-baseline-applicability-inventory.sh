#!/bin/sh

set -eu

repository_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
inventory_path="${repository_root}/docs/requirements/training-simulation-baseline-applicability-inventory.csv"
scratch_path=$(mktemp -d)
trap 'rm -rf -- "${scratch_path}"' EXIT HUP INT TERM

expected_header='sequence,requirement_identifier,disposition,milestone_or_justification,responsible_owner'

check_hash() {
    source_path=$1
    expected_hash=$2
    actual_hash=$(sha256sum "${repository_root}/${source_path}" | awk '{print $1}')
    if [ "${actual_hash}" != "${expected_hash}" ]; then
        echo "source changed: ${source_path}; create and reconcile a successor to BAI-002" >&2
        exit 1
    fi
}

append_registry() {
    source_path=$1
    source_version=$2
    source_hash=$3
    extract_identifiers "${source_path}" exclude_ambiguities | \
        awk -v path="${source_path}" -v version="${source_version}" \
            -v hash="${source_hash}" '
            {print $1 "\t" path "\t" version "\t" hash}
        ' >> "${scratch_path}/registry"
}

extract_identifiers() {
    source_path=$1
    ambiguity_policy=$2
    awk -v ambiguity_policy="${ambiguity_policy}" '
        match($0, /^(- )?\*\*([A-Z][A-Z0-9-]+-[0-9][0-9][0-9])\*\*/, parts) {
            if (ambiguity_policy == "include_ambiguities" || parts[2] !~ /^AMBIGUITY-/) {
                print parts[2]
            }
        }
    ' "${repository_root}/${source_path}"
}

cat > "${scratch_path}/sources" <<'EOF'
docs/requirements/training-simulation-initial-requirements.md|Development Baseline; candidate documentation-control amendment|706938fbe3cb4ee616cd882e5981c3c9f519357a19114e4c48a6827e518fe574|registry
docs/requirements/training-simulation-non-functional-requirements.md|NFR-BASELINE-001; approved 2026-09-01; amended 2026-09-03|8a024d6b7538f04e19df6dcae66c68160b2b6b474423d5d52f43a9fbee6ae092|registry
docs/requirements/training-simulation-observability-contract.md|OBS-CONTRACT-003; approved 2026-09-01|45c5392ca799388eac588ad54a5aa9e980ff4261de3b2b90fa0ba524f4a1f592|supporting
docs/requirements/training-simulation-performance-assessment-requirements.md|PERF-BASELINE-001; approved 2026-09-01; amended 2026-09-03|4d036de0500b7d0161dcf988fc40c2c0a53f9cfc69288c7c2c9f805755df01f9|registry
docs/requirements/training-simulation-performance-profile-engagement-target-001.md|ENGAGEMENT-TARGET-001; approved 2026-09-01|cc5f2fb21b692452d7fa12e34d05bfd83baded1eaf325f3c7bb754a79baae493|registry
docs/requirements/training-simulation-reference-hardware-profiles.md|RHP-SET-001; approved 2026-09-01|074dc42d25cf44800198b4207b8b90a2897ebe7109dadab4c3766e3cbc644095|supporting
docs/requirements/training-simulation-verification-plan.md|Candidate normalized assignment amendment|aa366423a0f6f6a469765491ee2c2d822b7c7eb8f977f9efe20ae62caa09e59e|registry
docs/requirements/training-simulation-baseline-applicability.md|BAI-CONTROL-002; approved 2026-09-03|b2f6cd0f18e75cb25908a288163f357131beae0c7c6514da6ce41fdbb459c636|supporting
EOF

while IFS='|' read -r source_path source_version source_hash source_role
do
    check_hash "${source_path}" "${source_hash}"
    basename "${source_path}" >> "${scratch_path}/expected-markdown"
    if [ "${source_role}" = registry ]; then
        append_registry "${source_path}" "${source_version}" "${source_hash}"
    fi
done < "${scratch_path}/sources"

find "${repository_root}/docs/requirements" -maxdepth 1 -type f -name '*.md' \
    -printf '%f\n' | sort > "${scratch_path}/actual-markdown"
sort -o "${scratch_path}/expected-markdown" "${scratch_path}/expected-markdown"
if ! cmp -s "${scratch_path}/expected-markdown" "${scratch_path}/actual-markdown"; then
    echo 'requirement-source population changed; reconcile a successor to BAI-002' >&2
    diff -u "${scratch_path}/expected-markdown" "${scratch_path}/actual-markdown" >&2 || true
    exit 1
fi

awk -F ',' -v expected_header="${expected_header}" '
    NR == FNR {
        split($0, registry, "\t")
        expected_path[registry[1]] = registry[2]
        expected_version[registry[1]] = registry[3]
        expected_hash[registry[1]] = registry[4]
        expected_count++
        next
    }
    FNR == 1 {
        if ($0 != expected_header) {
            print "invalid inventory header" > "/dev/stderr"
            failed = 1
        }
        next
    }
    {
        if (NF != 5) {
            print "inventory line " FNR ": expected 5 comma-free fields, found " NF > "/dev/stderr"
            failed = 1
            next
        }
        identifier = $2
        if (!(identifier in expected_path)) {
            print "unexpected or non-normative identifier: " identifier > "/dev/stderr"
            failed = 1
        }
        if (seen[identifier]++) {
            print "duplicate identifier: " identifier > "/dev/stderr"
            failed = 1
        }
        if ($1 != FNR - 1) {
            print "invalid sequence at " identifier > "/dev/stderr"
            failed = 1
        }
        if ($3 != "Included" && $3 != "Future" && $3 != "Not Applicable") {
            print "invalid disposition: " identifier > "/dev/stderr"
            failed = 1
        }
        if ($3 == "Included" && $4 != "Development Baseline") {
            print "invalid Included baseline: " identifier > "/dev/stderr"
            failed = 1
        }
        if ($3 == "Future" && ($4 == "" || $4 == "Development Baseline")) {
            print "missing future milestone: " identifier > "/dev/stderr"
            failed = 1
        }
        if ($3 == "Not Applicable" && $4 != "Approved objective scope exclusion recorded by " identifier) {
            print "missing objective justification: " identifier > "/dev/stderr"
            failed = 1
        }
        if ($5 == "" || $5 ~ /Named future baseline owner/) {
            print "missing responsible owner: " identifier > "/dev/stderr"
            failed = 1
        }
        dispositions[$3]++
    }
    END {
        for (identifier in expected_path) {
            if (!(identifier in seen)) {
                print "missing identifier: " identifier > "/dev/stderr"
                failed = 1
            }
        }
        if (length(seen) != expected_count || dispositions["Included"] != 928 || dispositions["Future"] != 201 || dispositions["Not Applicable"] != 19) {
            print "inventory population or disposition totals changed" > "/dev/stderr"
            failed = 1
        }
        exit failed
    }
' "${scratch_path}/registry" "${inventory_path}"

awk -F '\t' '
    $1 == "REQ-AUTH-SUBJECT-001" {security = 1}
    $1 == "REQ-AUTH-ATTEMPT-CANCEL-001" {security = 1}
    security {print $1 "|Production Security Baseline"}
    $1 == "REQ-AUTH-EXCHANGE-006" {security = 0}
    $1 == "REQ-AUTH-TRANSIENT-DATA-003" {security = 0}
' "${scratch_path}/registry" > "${scratch_path}/future-ranges"

cat > "${scratch_path}/future-explicit" <<'EOF'
DEFERRED-AAR-001|After-Action Review Baseline
DEFERRED-INSTRUCTOR-001|Instructor Capability Baseline
DEFERRED-LIGHTING-001|Dynamic Environment Baseline
DEFERRED-LOCOMOTION-001|Extended Locomotion Baseline
DEFERRED-MELEE-RESTRAINT-001|Melee Restraint Baseline
DEFERRED-NFR-AUTHORITY-CAPABILITY-AVAILABILITY-001|Platform Operations Baseline
DEFERRED-PLATFORM-OPERATIONS-001|Platform Operations Baseline
DEFERRED-PRODUCTION-SECURITY-001|Production Security Baseline
DEFERRED-RADIO-ADVANCED-001|Advanced Radio Baseline
DEFERRED-RECOVERY-SUBJECT-001|Autonomous Recovery Subject Baseline
DEFERRED-SCENARIO-001|Sabotage Scenario Baseline
DEFERRED-STRUCTURAL-COLLAPSE-001|Structural Collapse Baseline
DEFERRED-VR-DEVICE-001|Standalone Virtual-Reality Device Baseline
NFR-AUTH-ADMISSION-001|Production Security Baseline
NFR-OBSERVABILITY-ALERTING-001|Platform Operations Baseline
NFR-OBSERVABILITY-RETENTION-001|Platform Operations Baseline
PERF-AVAILABILITY-001|Production Security Baseline
PROCESS-MODE-EQUIVALENCE-COVERAGE-001|First Virtual-Reality Mode Baseline
PROCESS-MODE-EQUIVALENCE-COVERAGE-002|First Virtual-Reality Mode Baseline
PROCESS-MODE-EQUIVALENCE-COVERAGE-003|First Virtual-Reality Mode Baseline
PROCESS-MODE-EQUIVALENCE-COVERAGE-004|First Virtual-Reality Mode Baseline
PROCESS-MODE-EQUIVALENCE-COVERAGE-005|First Virtual-Reality Mode Baseline
PROCESS-MODE-EQUIVALENCE-TOLERANCE-001|First Virtual-Reality Mode Baseline
PROCESS-MODE-EQUIVALENCE-TOLERANCE-002|First Virtual-Reality Mode Baseline
PROCESS-MODE-EQUIVALENCE-TOLERANCE-003|First Virtual-Reality Mode Baseline
REQ-ADMISSION-PRECONDITION-001|Production Security Baseline
REQ-DOOR-INPUT-PARITY-001|First Virtual-Reality Mode Baseline
REQ-DOOR-INPUT-VR-001|First Virtual-Reality Mode Baseline
REQ-ENVIRONMENT-MANIPULATION-PARITY-001|First Virtual-Reality Mode Baseline
REQ-ENVIRONMENT-MANIPULATION-VR-001|First Virtual-Reality Mode Baseline
REQ-HAND-SIGNAL-INPUT-VR-001|First Virtual-Reality Mode Baseline
REQ-HAND-SIGNAL-PARITY-001|First Virtual-Reality Mode Baseline
REQ-LOCOMOTION-MODE-PARITY-001|First Virtual-Reality Mode Baseline
REQ-MELEE-INPUT-PARITY-001|First Virtual-Reality Mode Baseline
REQ-MELEE-INPUT-VR-001|First Virtual-Reality Mode Baseline
REQ-MIXED-MODE-001|First Virtual-Reality Mode Baseline
REQ-MODE-PARITY-001|First Virtual-Reality Mode Baseline
REQ-MODE-PARITY-002|First Virtual-Reality Mode Baseline
REQ-NAVIGATION-PARITY-001|First Virtual-Reality Mode Baseline
REQ-THROWN-DEVICE-INPUT-VR-001|First Virtual-Reality Mode Baseline
REQ-THROWN-DEVICE-PARITY-001|First Virtual-Reality Mode Baseline
REQ-VR-BASELINE-SCOPE-002|First Virtual-Reality Mode Baseline
REQ-VR-INPUT-001|First Virtual-Reality Mode Baseline
REQ-VR-INPUT-002|First Virtual-Reality Mode Baseline
REQ-VR-OPTIONAL-001|First Virtual-Reality Mode Baseline
REQ-WINDOW-INPUT-PARITY-001|First Virtual-Reality Mode Baseline
REQ-WINDOW-INPUT-VR-001|First Virtual-Reality Mode Baseline
EOF

cat "${scratch_path}/future-ranges" "${scratch_path}/future-explicit" | \
    sort > "${scratch_path}/expected-future"

awk -F ',' 'NR > 1 && $3 == "Future" {print $2 "|" $4}' \
    "${inventory_path}" | sort > "${scratch_path}/actual-future"

if ! cmp -s "${scratch_path}/expected-future" "${scratch_path}/actual-future"; then
    echo 'future classification or milestone differs from approved BAI-002 policy' >&2
    diff -u "${scratch_path}/expected-future" "${scratch_path}/actual-future" >&2 || true
    exit 1
fi

awk -F '\t' '$1 ~ /^NON-GOAL-/ {print $1 "|Approved objective scope exclusion recorded by " $1}' \
    "${scratch_path}/registry" | sort > "${scratch_path}/expected-not-applicable"
awk -F ',' 'NR > 1 && $3 == "Not Applicable" {print $2 "|" $4}' \
    "${inventory_path}" | sort > "${scratch_path}/actual-not-applicable"
if ! cmp -s "${scratch_path}/expected-not-applicable" "${scratch_path}/actual-not-applicable"; then
    echo 'Not Applicable classification or justification differs from approved BAI-002 policy' >&2
    diff -u "${scratch_path}/expected-not-applicable" "${scratch_path}/actual-not-applicable" >&2 || true
    exit 1
fi

echo 'Baseline applicability inventory valid: BAI-002: 1148 entries; Included=928, Future=201, Not Applicable=19'
