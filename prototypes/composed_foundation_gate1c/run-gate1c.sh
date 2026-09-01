#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
prototype_root="${repo_root}/prototypes/composed_foundation_gate1c"
gate1b_root="${SACRAMENTO_GATE1B_ROOT:-/tmp/sacramento-composed-foundation-gate1b}"
gate_root="${SACRAMENTO_GATE1C_ROOT:-/tmp/sacramento-composed-foundation-gate1c}"
toolchain_root="${SACRAMENTO_CPP_TOOLCHAIN_ROOT:-/var/tmp/sacramento-cpp-toolchain}"
source_root="${gate1b_root}/vendor/falcor"
build_root="${gate1b_root}/build"
packman_cache="${SACRAMENTO_GATE1B_PACKMAN_CACHE:-${gate1b_root}/vendor/packman-cache}"
aftermath_root="${SACRAMENTO_GATE1B_AFTERMATH_ROOT:-${gate1b_root}/vendor/inputs/aftermath}"
sdk_root="${gate_root}/falcor-sdk"
sdk_archive="${gate_root}/falcor-sdk.zip"
smoke_build="${gate_root}/smoke-build"
redist_root="${toolchain_root}/redist-14.50/Contents/VC/Redist/MSVC/14.50.35710/x64/Microsoft.VC145.CRT"

if [[ "${gate_root}" == "${repo_root}" || "${gate_root}" == "${repo_root}/"* ]]; then
  echo "SACRAMENTO_GATE1C_ROOT must be outside the Git worktree" >&2
  exit 2
fi
if [[ -e "${sdk_root}" || -e "${sdk_archive}" ]]; then
  echo "Gate 1C output already exists; choose a fresh SACRAMENTO_GATE1C_ROOT" >&2
  exit 2
fi

for required in \
  "${source_root}/CMakeLists.txt" \
  "${build_root}/bin/Falcor.dll" \
  "${build_root}/Source/Falcor/Falcor.lib" \
  "${packman_cache}" \
  "${aftermath_root}/lib/x64/GFSDK_Aftermath_Lib.x64.dll" \
  "${redist_root}/msvcp140.dll"; do
  if [[ ! -e "${required}" ]]; then
    echo "missing Gate 1C input: ${required}" >&2
    exit 2
  fi
done

mkdir -p "${gate_root}" "${smoke_build}"
python3 "${prototype_root}/package_falcor_sdk.py" \
  --source "${source_root}" \
  --build "${build_root}" \
  --packman-cache "${packman_cache}" \
  --aftermath "${aftermath_root}" \
  --redist "${redist_root}" \
  --output "${sdk_root}" \
  --archive "${sdk_archive}" \
  | tee "${gate_root}/sdk-result.json"

for shader in \
  "${sdk_root}/bin/shaders/Core/API/BlitReduction.3d.slang" \
  "${sdk_root}/bin/shaders/Utils/Math/MathHelpers.slang"; do
  if [[ ! -f "${shader}" ]]; then
    echo "missing packaged Falcor runtime shader: ${shader}" >&2
    exit 2
  fi
done

rootfs="${toolchain_root}/ubuntu-26.04"
bwrap \
  --unshare-user --uid 0 --gid 0 \
  --bind "${rootfs}" / \
  --proc /proc --dev /dev \
  --tmpfs /srv \
  --bind "${toolchain_root}" /opt/sacramento-state \
  --ro-bind "${repo_root}" /opt/sacramento-repo \
  --bind "${gate_root}" /srv/gate1c \
  /usr/bin/env -i \
    HOME=/srv/gate1c \
    TMPDIR=/srv/gate1c \
    TMP=/srv/gate1c \
    TEMP=/srv/gate1c \
    PATH=/usr/sbin:/usr/bin:/sbin:/bin \
    SACRAMENTO_LLVM_ROOT=/usr/lib/llvm-22 \
    SACRAMENTO_VCTOOLS_DIR=/opt/sacramento-state/sysroot-v18-ms/crt \
    SACRAMENTO_WINSDK_DIR=/opt/sacramento-state/sysroot-v18-ms/sdk \
    /usr/bin/cmake \
      -S /opt/sacramento-repo/prototypes/composed_foundation_gate1c/smoke \
      -B /srv/gate1c/smoke-build \
      -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_TOOLCHAIN_FILE=/opt/sacramento-repo/cmake/toolchains/windows-cross-clang.cmake \
      -DFALCOR_SDK=/srv/gate1c/falcor-sdk

bwrap \
  --unshare-user --uid 0 --gid 0 \
  --bind "${rootfs}" / \
  --proc /proc --dev /dev \
  --tmpfs /srv \
  --bind "${toolchain_root}" /opt/sacramento-state \
  --ro-bind "${repo_root}" /opt/sacramento-repo \
  --bind "${gate_root}" /srv/gate1c \
  /usr/bin/env -i \
    HOME=/srv/gate1c \
    TMPDIR=/srv/gate1c \
    TMP=/srv/gate1c \
    TEMP=/srv/gate1c \
    PATH=/usr/sbin:/usr/bin:/sbin:/bin \
    SACRAMENTO_LLVM_ROOT=/usr/lib/llvm-22 \
    SACRAMENTO_VCTOOLS_DIR=/opt/sacramento-state/sysroot-v18-ms/crt \
    SACRAMENTO_WINSDK_DIR=/opt/sacramento-state/sysroot-v18-ms/sdk \
    /usr/bin/cmake --build /srv/gate1c/smoke-build --parallel

file "${smoke_build}/falcor_vulkan_smoke.exe" \
  | tee "${gate_root}/smoke-artifact.txt"
sha256sum "${smoke_build}/falcor_vulkan_smoke.exe" \
  | tee -a "${gate_root}/smoke-artifact.txt"
for shader in \
  "${smoke_build}/shaders/Core/API/BlitReduction.3d.slang" \
  "${smoke_build}/shaders/gate1c.slang"; do
  if [[ ! -f "${shader}" ]]; then
    echo "missing smoke runtime shader: ${shader}" >&2
    exit 2
  fi
done
echo "Gate 1C build verdict: PASS; native Windows/NVIDIA execution pending"
