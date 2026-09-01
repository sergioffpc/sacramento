#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
prototype_root="${repo_root}/prototypes/composed_foundation_gate1"
toolchain_root="${SACRAMENTO_CPP_TOOLCHAIN_ROOT:-/var/tmp/sacramento-cpp-toolchain}"
gate_root="${SACRAMENTO_GATE1_ROOT:-/tmp/sacramento-composed-foundation-gate1}"
rootfs="${toolchain_root}/ubuntu-26.04"
evidence_root="${gate_root}/evidence"
falcor_source="${gate_root}/falcor-8.0"
falcor_archive="${gate_root}/downloads/falcor-8.0.tar.gz"
falcor_sha256="681acb541ca02c819e42919ab26214263c9a9254f7876871d420120e1a4b7899"

if [[ "${gate_root}" == "${repo_root}" || "${gate_root}" == "${repo_root}/"* ]]; then
  echo "SACRAMENTO_GATE1_ROOT must be outside the Git worktree" >&2
  exit 2
fi

for command in bwrap curl python3 sha256sum tar; do
  if ! command -v "${command}" >/dev/null; then
    echo "missing host command: ${command}" >&2
    exit 2
  fi
done

SACRAMENTO_CPP_TOOLCHAIN_ROOT="${toolchain_root}" \
  "${repo_root}/scripts/cpp-toolchain-bootstrap.sh" verify

mkdir -p \
  "${evidence_root}" \
  "${gate_root}/downloads" \
  "${gate_root}/tmp" \
  "${gate_root}/vcpkg-buildtrees" \
  "${gate_root}/vcpkg-downloads" \
  "${gate_root}/vcpkg-installed" \
  "${gate_root}/vcpkg-packages"

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
    /usr/bin/env -i \
      HOME=/srv/tmp \
      TMPDIR=/srv/tmp \
      TMP=/srv/tmp \
      TEMP=/srv/tmp \
      PATH=/usr/sbin:/usr/bin:/sbin:/bin \
      CC=/usr/lib/llvm-22/bin/clang \
      CXX=/usr/lib/llvm-22/bin/clang++ \
      SACRAMENTO_LLVM_ROOT=/usr/lib/llvm-22 \
      SACRAMENTO_VCTOOLS_DIR=/opt/sacramento-state/sysroot-v18-ms/crt \
      SACRAMENTO_WINSDK_DIR=/opt/sacramento-state/sysroot-v18-ms/sdk \
      VCPKG_BINARY_SOURCES=clear \
      VCPKG_DISABLE_METRICS=1 \
      "$@"
}

run_in_rootfs \
  /opt/sacramento-state/vcpkg/vcpkg install \
  --x-manifest-root=/opt/sacramento-repo/prototypes/composed_foundation_gate1 \
  --x-install-root=/srv/vcpkg-installed \
  --x-buildtrees-root=/srv/vcpkg-buildtrees \
  --x-packages-root=/srv/vcpkg-packages \
  --downloads-root=/srv/vcpkg-downloads \
  --overlay-ports=/opt/sacramento-repo/prototypes/composed_foundation_gate1/ports \
  --overlay-triplets=/opt/sacramento-repo/triplets \
  --triplet=x64-windows-cross-clang \
  --host-triplet=x64-linux \
  | tee "${evidence_root}/vcpkg-install.log"

slangc="${gate_root}/vcpkg-installed/x64-linux/tools/sacramento-slang-host/bin/slangc"
shader_source="${prototype_root}/shaders/gate1.cs.slang"
shader_a="${gate_root}/gate1-a.spv"
shader_b="${gate_root}/gate1-b.spv"

"${slangc}" "${shader_source}" \
  -target spirv \
  -profile glsl_460 \
  -entry computeMain \
  -stage compute \
  -o "${shader_a}"
"${slangc}" "${shader_source}" \
  -target spirv \
  -profile glsl_460 \
  -entry computeMain \
  -stage compute \
  -o "${shader_b}"
cmp "${shader_a}" "${shader_b}"

shader_sha256="$(sha256sum "${shader_a}" | cut -d ' ' -f 1)"
{
  "${slangc}" -version
  printf '\n'
  sha256sum "${shader_a}" "${shader_b}"
} | tee "${evidence_root}/slang-spirv.log"

run_in_rootfs \
  /usr/bin/cmake \
  -S /opt/sacramento-repo/prototypes/composed_foundation_gate1 \
  -B /srv/windows-probe-build \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_MAKE_PROGRAM=/usr/bin/ninja \
  -DCMAKE_TOOLCHAIN_FILE=/opt/sacramento-state/vcpkg/scripts/buildsystems/vcpkg.cmake \
  -DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=/opt/sacramento-repo/cmake/toolchains/windows-cross-clang.cmake \
  -DVCPKG_TARGET_TRIPLET=x64-windows-cross-clang \
  -DVCPKG_OVERLAY_TRIPLETS=/opt/sacramento-repo/triplets \
  -DVCPKG_INSTALLED_DIR=/srv/vcpkg-installed \
  -DVCPKG_MANIFEST_INSTALL=OFF \
  -DSACRAMENTO_GATE1_SHADER_SHA256="${shader_sha256}" \
  | tee "${evidence_root}/windows-configure.log"
run_in_rootfs \
  /usr/bin/cmake --build /srv/windows-probe-build --verbose \
  | tee "${evidence_root}/windows-build.log"
sha256sum "${gate_root}/windows-probe-build/sacramento_gate1_vulkan_probe.exe" \
  | tee "${evidence_root}/windows-probe-sha256.log"

if [[ ! -f "${falcor_archive}" ]]; then
  curl \
    --fail \
    --location \
    --proto '=https' \
    --tlsv1.2 \
    --output "${falcor_archive}.partial" \
    https://api.github.com/repos/NVIDIAGameWorks/Falcor/tarball/8.0
  mv "${falcor_archive}.partial" "${falcor_archive}"
fi

actual_falcor_sha256="$(sha256sum "${falcor_archive}" | cut -d ' ' -f 1)"
if [[ "${actual_falcor_sha256}" != "${falcor_sha256}" ]]; then
  echo "Falcor source SHA-256 mismatch: ${actual_falcor_sha256}" >&2
  exit 1
fi

if [[ ! -f "${falcor_source}/CMakeLists.txt" ]]; then
  mkdir -p "${falcor_source}"
  tar -xzf "${falcor_archive}" -C "${falcor_source}" --strip-components=1
fi

set +e
python3 "${prototype_root}/audit_falcor.py" \
  "${falcor_source}" "${evidence_root}/falcor-policy.json" \
  >"${evidence_root}/falcor-policy.log" 2>&1
audit_status=$?
set -e
if [[ ${audit_status} -ne 1 ]]; then
  echo "Falcor policy audit returned unexpected status ${audit_status}" >&2
  exit 1
fi

# The release archive excludes git submodule contents. This empty file bypasses
# only Falcor's configure-time `git submodule update`; configure reaches the
# Packman invocation before any submodule target is consumed.
mkdir -p "${falcor_source}/external/pybind11"
touch "${falcor_source}/external/pybind11/CMakeLists.txt"

set +e
run_in_rootfs \
  /usr/bin/cmake \
  -S /srv/falcor-8.0 \
  -B /srv/falcor-cross-build \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_MAKE_PROGRAM=/usr/bin/ninja \
  -DCMAKE_TOOLCHAIN_FILE=/opt/sacramento-repo/cmake/toolchains/windows-cross-clang.cmake \
  -DFALCOR_ENABLE_USD=OFF \
  -DFALCOR_USE_SYSTEM_PYTHON=ON \
  -DFALCOR_HAS_D3D12=OFF \
  >"${evidence_root}/falcor-configure.log" 2>&1
falcor_status=$?
set -e

if [[ ${falcor_status} -eq 0 ]]; then
  echo "Unexpected result: Falcor configured without the recorded blockers" >&2
  exit 1
fi
if ! grep -Fq "Updating packman dependencies" \
    "${evidence_root}/falcor-configure.log"; then
  echo "Falcor did not fail at the expected Packman boundary" >&2
  exit 1
fi

cat "${evidence_root}/falcor-policy.log"
tail -n 20 "${evidence_root}/falcor-configure.log"
echo "Gate 1 verdict: FAIL (Falcor 8.0 violates vcpkg-only and Vulkan-only policies)"
exit 1
