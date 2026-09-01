#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
prototype_root="${repo_root}/prototypes/composed_foundation_gate1b"
toolchain_root="${SACRAMENTO_CPP_TOOLCHAIN_ROOT:-/var/tmp/sacramento-cpp-toolchain}"
gate_root="${SACRAMENTO_GATE1B_ROOT:-/tmp/sacramento-composed-foundation-gate1b}"
packman_cache="${SACRAMENTO_GATE1B_PACKMAN_CACHE:-${gate_root}/packman-cache}"
rootfs="${toolchain_root}/ubuntu-26.04"
falcor_source="${gate_root}/vendor/falcor"
falcor_build="${gate_root}/build"
evidence_root="${gate_root}/evidence"
falcor_repository="https://github.com/NVIDIAGameWorks/Falcor.git"
falcor_commit="9dc819c162b2070335c65060436041690b7937f8"
patch_file="${prototype_root}/patches/0001-select-packman-by-build-host.patch"
aftermath_url="https://developer.nvidia.com/downloads/assets/tools/secure/nsight-aftermath-sdk/2026_3_0/windows_x64/NVIDIA_Nsight_Aftermath_SDK_2026.3.0.26197-windows_x64.zip"
aftermath_sha256="e38136a60110199559b7365d3ea4ec0cb5588dc2b0f593877d864e0299659a3f"
aftermath_archive="${gate_root}/downloads/aftermath-windows-x64.zip"
aftermath_root="${gate_root}/inputs/aftermath"

if [[ "${gate_root}" == "${repo_root}" || "${gate_root}" == "${repo_root}/"* ]]; then
  echo "SACRAMENTO_GATE1B_ROOT must be outside the Git worktree" >&2
  exit 2
fi

for command in bwrap curl file git ln python3 readlink sha256sum tee; do
  if ! command -v "${command}" >/dev/null; then
    echo "missing host command: ${command}" >&2
    exit 2
  fi
done

SACRAMENTO_CPP_TOOLCHAIN_ROOT="${toolchain_root}" \
  "${repo_root}/scripts/cpp-toolchain-bootstrap.sh" verify

mkdir -p \
  "${gate_root}/vendor" \
  "${gate_root}/downloads" \
  "${gate_root}/inputs" \
  "${packman_cache}" \
  "${evidence_root}" \
  "${gate_root}/home"

if [[ ! -d "${falcor_source}/.git" ]]; then
  git clone \
    --branch 8.0 \
    --depth 1 \
    --recurse-submodules \
    --shallow-submodules \
    "${falcor_repository}" \
    "${falcor_source}"
fi

actual_commit="$(git -C "${falcor_source}" rev-parse HEAD)"
if [[ "${actual_commit}" != "${falcor_commit}" ]]; then
  echo "Falcor commit mismatch: ${actual_commit}" >&2
  exit 1
fi

git -C "${falcor_source}" submodule update --init --recursive

if git -C "${falcor_source}" apply --unidiff-zero --reverse --check \
  "${patch_file}" 2>/dev/null; then
  echo "Packman host-selection patch already applied"
else
  git -C "${falcor_source}" apply --unidiff-zero --check "${patch_file}"
  git -C "${falcor_source}" apply --unidiff-zero "${patch_file}"
fi
git -C "${falcor_source}" diff --check

if [[ ! -f "${aftermath_archive}" ]]; then
  curl \
    --fail \
    --location \
    --proto '=https' \
    --tlsv1.2 \
    --output "${aftermath_archive}.partial" \
    "${aftermath_url}"
  mv "${aftermath_archive}.partial" "${aftermath_archive}"
fi

actual_aftermath_sha256="$(sha256sum "${aftermath_archive}" | cut -d ' ' -f 1)"
if [[ "${actual_aftermath_sha256}" != "${aftermath_sha256}" ]]; then
  echo "Aftermath SDK SHA-256 mismatch: ${actual_aftermath_sha256}" >&2
  exit 1
fi

if [[ ! -f "${aftermath_root}/include/GFSDK_Aftermath.h" ]]; then
  python3 - "${aftermath_archive}" "${aftermath_root}" <<'PY'
import sys
import zipfile
from pathlib import Path

archive = Path(sys.argv[1])
destination = Path(sys.argv[2])
destination.mkdir(parents=True, exist_ok=True)
with zipfile.ZipFile(archive) as package:
    package.extractall(destination)
PY
fi

for aftermath_file in \
  "${aftermath_root}/include/GFSDK_Aftermath.h" \
  "${aftermath_root}/lib/x64/GFSDK_Aftermath_Lib.x64.lib" \
  "${aftermath_root}/lib/x64/GFSDK_Aftermath_Lib.x64.dll"; do
  if [[ ! -f "${aftermath_file}" ]]; then
    echo "Aftermath SDK is missing: ${aftermath_file}" >&2
    exit 1
  fi
done

aftermath_link="${falcor_source}/external/packman/aftermath"
if [[ ! -e "${aftermath_link}" && ! -L "${aftermath_link}" ]]; then
  ln -s ../../../../inputs/aftermath "${aftermath_link}"
fi
if [[ "$(readlink "${aftermath_link}")" != "../../../../inputs/aftermath" ]]; then
  echo "Falcor Aftermath link does not point at the fixed vendor input" >&2
  exit 1
fi

python3 "${prototype_root}/audit_falcor_vendor.py" \
  "${falcor_source}" \
  "${evidence_root}/vendor-coupling.json" \
  | tee "${evidence_root}/vendor-coupling.log"

python3 - "${prototype_root}/vendor.json" "${falcor_source}" <<'PY'
import json
import subprocess
import sys
from pathlib import Path

manifest = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
source = Path(sys.argv[2])
for path, expected in manifest["submodules"].items():
    actual = subprocess.check_output(
        ["git", "-C", str(source / path), "rev-parse", "HEAD"], text=True
    ).strip()
    if actual != expected:
        raise SystemExit(f"submodule mismatch for {path}: {actual}")
PY

run_in_rootfs() {
  bwrap \
    --unshare-user \
    --uid 0 \
    --gid 0 \
    --bind "${rootfs}" / \
    --proc /proc \
    --dev /dev \
    --ro-bind /etc/resolv.conf /etc/resolv.conf \
    --bind "${toolchain_root}" /opt/sacramento-state \
    --ro-bind "${repo_root}" /opt/sacramento-repo \
    --bind "${gate_root}" /srv \
    --bind "${packman_cache}" /srv/packman-cache \
    /usr/bin/env -i \
      HOME=/srv/home \
      TMPDIR=/srv/home \
      TMP=/srv/home \
      TEMP=/srv/home \
      PATH=/usr/sbin:/usr/bin:/sbin:/bin \
      CC=/usr/lib/llvm-22/bin/clang \
      CXX=/usr/lib/llvm-22/bin/clang++ \
      SACRAMENTO_LLVM_ROOT=/usr/lib/llvm-22 \
      SACRAMENTO_VCTOOLS_DIR=/opt/sacramento-state/sysroot-v18-ms/crt \
      SACRAMENTO_WINSDK_DIR=/opt/sacramento-state/sysroot-v18-ms/sdk \
      PM_PACKAGES_ROOT=/srv/packman-cache \
      "$@"
}

run_in_rootfs \
  /srv/vendor/falcor/tools/packman/packman pull \
  /srv/vendor/falcor/dependencies.xml \
  --platform windows-x86_64 \
  2>&1 | tee "${evidence_root}/packman-pull.log"

deps_link="$(readlink "${falcor_source}/external/packman/deps")"
python_link="$(readlink "${falcor_source}/external/packman/python")"
if [[ "${deps_link}" != */falcor_dependencies/f80dd590-windows-x86_64 ||
      "${python_link}" != */python/3.10.11+nv1-windows-x86_64 ]]; then
  echo "Packman linked an unexpected target platform" >&2
  exit 1
fi

{
  printf 'falcor_commit=%s\n' "${actual_commit}"
  printf 'patch_sha256='
  sha256sum "${patch_file}" | cut -d ' ' -f 1
  printf 'dependencies_sha256='
  sha256sum "${falcor_source}/dependencies.xml" | cut -d ' ' -f 1
  printf 'packman_launcher='
  file "${falcor_source}/tools/packman/packman"
  printf 'packman_target=windows-x86_64\n'
  printf 'aftermath_version=2026.3.0.26197\n'
  printf 'aftermath_sha256=%s\n' "${actual_aftermath_sha256}"
  file "${aftermath_root}/lib/x64/GFSDK_Aftermath_Lib.x64.lib"
  file "${aftermath_root}/lib/x64/GFSDK_Aftermath_Lib.x64.dll"
  printf 'falcor_dependencies_link=%s\n' "${deps_link}"
  printf 'python_target_link=%s\n' "${python_link}"
  git -C "${falcor_source}" submodule status
} | tee "${evidence_root}/vendor-identity.log"

set +e
run_in_rootfs \
  /usr/bin/cmake \
  -S /srv/vendor/falcor \
  -B /srv/build \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_MAKE_PROGRAM=/usr/bin/ninja \
  -DCMAKE_TOOLCHAIN_FILE=/opt/sacramento-repo/cmake/toolchains/windows-cross-clang.cmake \
  -DFALCOR_ENABLE_USD=OFF \
  -DFALCOR_USE_SYSTEM_PYTHON=ON \
  -DFALCOR_HAS_D3D12=OFF \
  2>&1 | tee "${evidence_root}/falcor-configure.log"
configure_status=${PIPESTATUS[0]}
set -e

if grep -Fq "packman.cmd" "${evidence_root}/falcor-configure.log" || \
  grep -Fq "Permission denied" "${evidence_root}/falcor-configure.log"; then
  echo "Gate 1B verdict: FAIL (Windows Packman launcher still escaped)" >&2
  exit 1
fi

if ! grep -Fq -- "-- Updating packman dependencies ..." \
  "${evidence_root}/falcor-configure.log"; then
  echo "Gate 1B verdict: FAIL (Falcor did not reach Packman)" >&2
  exit 1
fi

if [[ ${configure_status} -eq 0 ]]; then
  echo "Gate 1B verdict: PASS (Linux Packman and Falcor configure succeeded)"
  exit 0
fi

if grep -Fq "Could NOT find Python" "${evidence_root}/falcor-configure.log"; then
  echo "Gate 1B verdict: PASS (Linux Packman supplied Windows dependencies)"
  echo "Next blocker: Falcor needs separate host and target Python inputs"
  exit 0
fi

echo "Gate 1B verdict: FAIL (unexpected failure after Linux Packman)" >&2
exit 1
