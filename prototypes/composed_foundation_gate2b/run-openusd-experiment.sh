#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
prototype_root="${repo_root}/prototypes/composed_foundation_gate2b"
gate_root="${SACRAMENTO_GATE2B_ROOT:-/tmp/sacramento-composed-foundation-gate2b}"
experiment_root="${gate_root}/openusd-experiment"
evidence_root="${gate_root}/evidence"
wheel_name="usd_core-26.8-cp314-none-manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl"
wheel_sha256="114f39723ccfc9a269cfdf6a7b80fec53aa96530806e510a6cccfd577401a07c"
wheel_url="https://files.pythonhosted.org/packages/4f/ce/76e0476d04c387cbf435f11aafb36ff4f79345215d7b9dbb677a7a1efa11/${wheel_name}"

if [[ ! -x "${gate_root}/build-a/sacramento_gate2b_assimp_adapter" ||
      ! -f "${gate_root}/cook-a/training-yard.sacmap" ]]; then
  echo "run the passing Assimp Gate 2B path before the OpenUSD experiment" >&2
  exit 2
fi
if [[ -e "${experiment_root}" ]]; then
  echo "OpenUSD experiment output already exists; choose a fresh Gate 2B root" >&2
  exit 2
fi
if [[ "$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')" != "3.14" ]]; then
  echo "the pinned experiment wheel requires conventional CPython 3.14" >&2
  exit 2
fi

mkdir -p "${experiment_root}/site-packages" "${experiment_root}/cook"
curl -fL "${wheel_url}" -o "${experiment_root}/${wheel_name}"
printf '%s  %s\n' "${wheel_sha256}" "${experiment_root}/${wheel_name}" \
  | sha256sum --check
python3 -m zipfile -e "${experiment_root}/${wheel_name}" \
  "${experiment_root}/site-packages"

site_packages="${experiment_root}/site-packages"
metadata="${site_packages}/usd_core-26.8.dist-info/METADATA"
licence="${site_packages}/usd_core-26.8.dist-info/licenses/LICENSE.txt"
rg '^Version: 26\.8$' "${metadata}"
rg '^License: LicenseRef-TOST-1\.0$' "${metadata}"
rg '^Requires-Python: >=3\.9, <3\.15$' "${metadata}"
test -f "${licence}"

find "${site_packages}" -type f -print0 \
  | LC_ALL=C sort -z \
  | xargs -0 sha256sum >"${evidence_root}/openusd-installed-sha256.txt"
find "${site_packages}" -type f -name '*.so' -print \
  | LC_ALL=C sort >"${evidence_root}/openusd-native-files.txt"
while IFS= read -r native_file; do
  printf '%s\n' "${native_file}"
  LD_LIBRARY_PATH="${site_packages}/usd_core.libs" ldd "${native_file}"
done <"${evidence_root}/openusd-native-files.txt" \
  >"${evidence_root}/openusd-native-ldd.txt"
if rg 'not found' "${evidence_root}/openusd-native-ldd.txt"; then
  echo "usd-core wheel has an unresolved native dependency" >&2
  exit 1
fi

start_ns="$(date +%s%N)"
PYTHONPATH="${site_packages}" \
  python3 "${prototype_root}/openusd_adapter.py" \
  "${prototype_root}/fixtures/openusd/root.usda" \
  >"${evidence_root}/openusd-interchange.json"
end_ns="$(date +%s%N)"
printf '%s\n' "$(((end_ns - start_ns) / 1000000))" \
  >"${evidence_root}/openusd-adapter-ms.txt"

SACRAMENTO_GATE2B_ADAPTER_PYTHONPATH="${site_packages}" \
  python3 "${prototype_root}/cook.py" \
  --source "${prototype_root}/fixtures/openusd/root.usda" \
  --recipe "${prototype_root}/fixtures/blender-origin-map.recipe.json" \
  --adapter "${prototype_root}/openusd_adapter.py" \
  --output "${experiment_root}/cook/training-yard.sacmap" \
  --manifest "${experiment_root}/cook/training-yard.manifest.json"

cmp "${gate_root}/cook-a/training-yard.sacmap" \
  "${experiment_root}/cook/training-yard.sacmap"
cmp "${gate_root}/cook-a/training-yard.manifest.json" \
  "${experiment_root}/cook/training-yard.manifest.json"
"${gate_root}/build-a/sacramento_gate2b_runtime_reader" \
  "${experiment_root}/cook/training-yard.sacmap" \
  >"${evidence_root}/openusd-runtime-inspection.json"
cmp "${evidence_root}/runtime-inspection.json" \
  "${evidence_root}/openusd-runtime-inspection.json"

SACRAMENTO_GATE2B_ADAPTER="${gate_root}/build-a/sacramento_gate2b_assimp_adapter" \
SACRAMENTO_GATE2B_RUNTIME_READER="${gate_root}/build-a/sacramento_gate2b_runtime_reader" \
SACRAMENTO_GATE2B_OPENUSD_ADAPTER="${prototype_root}/openusd_adapter.py" \
SACRAMENTO_GATE2B_ADAPTER_PYTHONPATH="${site_packages}" \
  python3 -m unittest discover -s "${prototype_root}/tests" -v \
  >"${evidence_root}/openusd-tests.log" 2>&1

if rg -a -i 'openusd|usd|\.usd[ac]?|pxr|prim|variant|payload|sublayer' \
  "${experiment_root}/cook/training-yard.sacmap" \
  "${experiment_root}/cook/training-yard.manifest.json"; then
  echo "OpenUSD authoring schema entered the runtime package" >&2
  exit 1
fi

{
  python3 --version
  sha256sum "${experiment_root}/${wheel_name}" \
    "${experiment_root}/cook/training-yard.sacmap" \
    "${experiment_root}/cook/training-yard.manifest.json" \
    "${metadata}" "${licence}"
  du -b "${experiment_root}/${wheel_name}" \
    "${experiment_root}/cook/training-yard.sacmap" \
    "${experiment_root}/cook/training-yard.manifest.json"
  du -sb "${site_packages}"
} >"${evidence_root}/openusd-artifact-inventory.txt"

echo "Gate 2B OpenUSD disposition: optional cooker frontend"
