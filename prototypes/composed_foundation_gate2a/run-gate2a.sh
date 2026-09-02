#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
prototype_root="${repo_root}/prototypes/composed_foundation_gate2a"
toolchain_root="${SACRAMENTO_CPP_TOOLCHAIN_ROOT:-/var/tmp/sacramento-cpp-toolchain}"
gate_root="${SACRAMENTO_GATE2A_ROOT:-/tmp/sacramento-composed-foundation-gate2a}"
rootfs="${toolchain_root}/ubuntu-26.04"
debian_sysroot="${toolchain_root}/debian-13.6-sysroot"
installed_root="${gate_root}/vcpkg-installed"
evidence_root="${gate_root}/evidence"

if [[ "${gate_root}" == "${repo_root}" || "${gate_root}" == "${repo_root}/"* ]]; then
  echo "SACRAMENTO_GATE2A_ROOT must be outside the Git worktree" >&2
  exit 2
fi
if [[ -e "${gate_root}" ]]; then
  echo "Gate 2A output already exists; choose a fresh SACRAMENTO_GATE2A_ROOT" >&2
  exit 2
fi

for command in bwrap cmp file python3 readelf sha256sum; do
  if ! command -v "${command}" >/dev/null; then
    echo "missing host command: ${command}" >&2
    exit 2
  fi
done

SACRAMENTO_CPP_TOOLCHAIN_ROOT="${toolchain_root}" \
  "${repo_root}/scripts/cpp-toolchain-bootstrap.sh" verify

mkdir -p \
  "${evidence_root}" \
  "${gate_root}/tmp" \
  "${gate_root}/vcpkg-buildtrees" \
  "${gate_root}/vcpkg-downloads" \
  "${gate_root}/vcpkg-packages"

run_in_rootfs() {
  bwrap \
    --unshare-user --uid 0 --gid 0 \
    --bind "${rootfs}" / \
    --proc /proc --dev /dev \
    --ro-bind /etc/resolv.conf /etc/resolv.conf \
    --bind "${toolchain_root}" /opt/sacramento-state \
    --ro-bind "${repo_root}" /opt/sacramento-repo \
    --bind "${gate_root}" /srv \
    /usr/bin/env -i \
      HOME=/srv/tmp \
      TMPDIR=/srv/tmp TMP=/srv/tmp TEMP=/srv/tmp \
      PATH=/usr/sbin:/usr/bin:/sbin:/bin \
      CC=/usr/lib/llvm-22/bin/clang \
      CXX=/usr/lib/llvm-22/bin/clang++ \
      SACRAMENTO_LLVM_ROOT=/usr/lib/llvm-22 \
      SACRAMENTO_DEBIAN_SYSROOT=/opt/sacramento-state/debian-13.6-sysroot \
      VCPKG_BINARY_SOURCES=clear \
      VCPKG_DISABLE_METRICS=1 \
      "$@"
}

run_in_rootfs \
  /opt/sacramento-state/vcpkg/vcpkg install \
  --x-manifest-root=/opt/sacramento-repo/prototypes/composed_foundation_gate2a \
  --x-install-root=/srv/vcpkg-installed \
  --x-buildtrees-root=/srv/vcpkg-buildtrees \
  --x-packages-root=/srv/vcpkg-packages \
  --downloads-root=/srv/vcpkg-downloads \
  --overlay-ports=/opt/sacramento-repo/prototypes/composed_foundation_gate2a/ports \
  --overlay-triplets=/opt/sacramento-repo/triplets \
  --triplet=x64-debian-cross-clang \
  --host-triplet=x64-linux \
  | tee "${evidence_root}/vcpkg-install.log"

run_in_rootfs \
  /opt/sacramento-state/vcpkg/vcpkg list \
  --x-install-root=/srv/vcpkg-installed \
  | tee "${evidence_root}/vcpkg-list.txt"

grep -Eq '^flecs:x64-debian-cross-clang[[:space:]]+4\.1\.6[[:space:]]' \
  "${evidence_root}/vcpkg-list.txt"
grep -Eq '^physx:x64-debian-cross-clang[[:space:]]+5\.9\.0[[:space:]]' \
  "${evidence_root}/vcpkg-list.txt"
if grep -Eiq \
  '^(falcor|vulkan|slang|steam.?audio|phonon|assimp|tracy|cuda|optix):' \
  "${evidence_root}/vcpkg-list.txt"; then
  echo "client-only package entered the Gate 2A dependency closure" >&2
  exit 1
fi
if find "${gate_root}/vcpkg-downloads" -type f -iname '*PhysXGpu*' \
  -print -quit | grep -q .; then
  echo "CPU-only PhysX overlay downloaded the optional PhysXGpu blob" >&2
  exit 1
fi
if find "${installed_root}" -type f \
  \( -name 'libPhysXGpu*' -o -name 'PhysXGpu*.dll' \) \
  -print -quit | grep -q .; then
  echo "CPU-only PhysX overlay installed the optional PhysXGpu runtime" >&2
  exit 1
fi
find "${gate_root}/vcpkg-downloads" -maxdepth 1 -type f -printf '%f\n' \
  | LC_ALL=C sort >"${evidence_root}/download-inventory.txt"

configure_build() {
  local build_name="$1"
  run_in_rootfs \
    /usr/bin/cmake \
    -S /opt/sacramento-repo/prototypes/composed_foundation_gate2a \
    -B "/srv/${build_name}" \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_MAKE_PROGRAM=/usr/bin/ninja \
    -DCMAKE_TOOLCHAIN_FILE=/opt/sacramento-state/vcpkg/scripts/buildsystems/vcpkg.cmake \
    -DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=/opt/sacramento-repo/cmake/toolchains/debian-cross-clang.cmake \
    -DVCPKG_TARGET_TRIPLET=x64-debian-cross-clang \
    -DVCPKG_OVERLAY_TRIPLETS=/opt/sacramento-repo/triplets \
    -DVCPKG_INSTALLED_DIR=/srv/vcpkg-installed \
    -DVCPKG_MANIFEST_INSTALL=OFF \
    -DSACRAMENTO_HARDENING=ON \
    -DSACRAMENTO_REPRODUCIBLE=ON \
    | tee "${evidence_root}/${build_name}-configure.log"
}

build_target() {
  local build_name="$1"
  local start_ns end_ns
  start_ns="$(date +%s%N)"
  run_in_rootfs /usr/bin/cmake --build "/srv/${build_name}" --parallel \
    | tee "${evidence_root}/${build_name}-build.log"
  end_ns="$(date +%s%N)"
  printf '%s\n' "$(((end_ns - start_ns) / 1000000))" \
    >"${evidence_root}/${build_name}-build-ms.txt"
}

configure_build build-a
build_target build-a
configure_build build-b
build_target build-b

binary_a="${gate_root}/build-a/sacramento_gate2a_authority"
binary_b="${gate_root}/build-b/sacramento_gate2a_authority"
cmp "${binary_a}" "${binary_b}"

start_ns="$(date +%s%N)"
run_in_rootfs /usr/bin/cmake --build /srv/build-a --parallel \
  | tee "${evidence_root}/incremental-build.log"
end_ns="$(date +%s%N)"
printf '%s\n' "$(((end_ns - start_ns) / 1000000))" \
  >"${evidence_root}/incremental-build-ms.txt"

debian_loader="${debian_sysroot}/lib64/ld-linux-x86-64.so.2"
debian_libraries="${debian_sysroot}/usr/lib/x86_64-linux-gnu:${debian_sysroot}/lib/x86_64-linux-gnu"
scenario="${prototype_root}/scenario/gate2a.scenario"

"${debian_loader}" --library-path "${debian_libraries}" \
  "${binary_a}" "${scenario}" "${gate_root}/trace-a.ndjson" \
  | tee "${gate_root}/result-a.json"
"${debian_loader}" --library-path "${debian_libraries}" \
  "${binary_b}" "${scenario}" "${gate_root}/trace-b.ndjson" \
  | tee "${gate_root}/result-b.json"

cmp "${gate_root}/trace-a.ndjson" "${gate_root}/trace-b.ndjson"
cmp "${gate_root}/result-a.json" "${gate_root}/result-b.json"
test "$(wc -l <"${gate_root}/trace-a.ndjson")" -eq 240
grep -Fq '"ground_contact":true' "${gate_root}/trace-a.ndjson"

python3 "${prototype_root}/audit_boundary.py" \
  --public-root "${prototype_root}/include" \
  --binary "${binary_a}" \
  --output "${evidence_root}/boundary-audit.json"

file "${binary_a}" | tee "${evidence_root}/artifact.txt"
sha256sum "${binary_a}" "${binary_b}" \
  | tee -a "${evidence_root}/artifact.txt"
du -b "${binary_a}" | tee -a "${evidence_root}/artifact.txt"
echo "Gate 2A verdict: PASS"
