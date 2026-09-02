#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
prototype_root="${repo_root}/prototypes/composed_foundation_gate2g"
output="${SACRAMENTO_GATE2G_OUTPUT:-/tmp/sacramento-composed-foundation-gate2g-verification.json}"

if [[ "${output}" == "${repo_root}" || "${output}" == "${repo_root}/"* ]]; then
  echo "SACRAMENTO_GATE2G_OUTPUT must be outside the Git worktree" >&2
  exit 2
fi

python3 "${prototype_root}/verify_synthesis.py" \
  --synthesis "${prototype_root}/synthesis.json" \
  --report "${prototype_root}/evidence/gate-2g-result.md" \
  --output "${output}"

echo "Gate 2G synthesis verdict: CONDITIONAL PASS; production admission blocked"
