#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
prototype_root="${repo_root}/prototypes/composed_foundation_gate2f"
toolchain_root="${SACRAMENTO_CPP_TOOLCHAIN_ROOT:-/var/tmp/sacramento-cpp-toolchain}"
gate_root="${SACRAMENTO_GATE2F_ROOT:-/tmp/sacramento-composed-foundation-gate2f}"
falcor_sdk="${SACRAMENTO_FALCOR_SDK:-/tmp/sacramento-falcor-gate1c-run11/falcor-sdk}"
rootfs="${toolchain_root}/ubuntu-26.04"
evidence_root="${gate_root}/evidence"

if [[ "${gate_root}" == "${repo_root}" || "${gate_root}" == "${repo_root}/"* ]]; then
  echo "SACRAMENTO_GATE2F_ROOT must be outside the Git worktree" >&2
  exit 2
fi
if [[ -e "${gate_root}" && "${SACRAMENTO_GATE2F_RESUME:-0}" != 1 ]]; then
  echo "Gate 2F output already exists; choose a fresh root" >&2
  exit 2
fi
for required in \
  "${falcor_sdk}/include/Falcor/Core/API/Device.h" \
  "${falcor_sdk}/lib/Falcor.lib" \
  "${falcor_sdk}/bin/Falcor.dll"; do
  if [[ ! -f "${required}" ]]; then
    echo "missing retained Gate 1C SDK input: ${required}" >&2
    exit 2
  fi
done
for command in bwrap cmp file make python3 sha256sum strings; do
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
  "${gate_root}/downloads" \
  "${gate_root}/windows-buildtrees" \
  "${gate_root}/windows-installed" \
  "${gate_root}/windows-packages" \
  "${gate_root}/falcor-sdk" \
  "${gate_root}/native-bundle"

run_in_rootfs() {
  bwrap \
    --unshare-user --uid 0 --gid 0 \
    --bind "${rootfs}" / \
    --proc /proc --dev /dev \
    --ro-bind /etc/resolv.conf /etc/resolv.conf \
    --bind "${toolchain_root}" /opt/sacramento-state \
    --ro-bind "${repo_root}" /opt/sacramento-repo \
    --bind "${gate_root}" /srv \
    --dir /srv/host-tools \
    --ro-bind /usr/bin/make /srv/host-tools/make \
    --ro-bind "${falcor_sdk}" /srv/falcor-sdk \
    /usr/bin/env -i \
      HOME=/srv/tmp \
      TMPDIR=/srv/tmp TMP=/srv/tmp TEMP=/srv/tmp \
      PATH=/srv/host-tools:/usr/sbin:/usr/bin:/sbin:/bin \
      CC=/usr/lib/llvm-22/bin/clang \
      CXX=/usr/lib/llvm-22/bin/clang++ \
      SACRAMENTO_LLVM_ROOT=/usr/lib/llvm-22 \
      SACRAMENTO_VCTOOLS_DIR=/opt/sacramento-state/sysroot-v18-ms/crt \
      SACRAMENTO_WINSDK_DIR=/opt/sacramento-state/sysroot-v18-ms/sdk \
      VCPKG_BINARY_SOURCES=clear \
      VCPKG_DISABLE_METRICS=1 \
      VCPKG_MAX_CONCURRENCY=8 \
      "$@"
}

install_start_ns="$(date +%s%N)"
run_in_rootfs \
  /opt/sacramento-state/vcpkg/vcpkg install \
  --x-manifest-root=/opt/sacramento-repo/prototypes/composed_foundation_gate2f \
  --x-install-root=/srv/windows-installed \
  --x-buildtrees-root=/srv/windows-buildtrees \
  --x-packages-root=/srv/windows-packages \
  --downloads-root=/srv/downloads \
  --overlay-ports=/opt/sacramento-repo/prototypes/composed_foundation_gate2f/ports \
  --overlay-ports=/opt/sacramento-repo/prototypes/composed_foundation_gate2d/ports \
  --overlay-triplets=/opt/sacramento-repo/prototypes/composed_foundation_gate2f/triplets \
  --triplet=x64-windows-cross-clang \
  --host-triplet=x64-linux \
  | tee "${evidence_root}/vcpkg-windows-install.log"
install_end_ns="$(date +%s%N)"
printf '%s\n' "$(((install_end_ns - install_start_ns) / 1000000))" \
  >"${evidence_root}/vcpkg-windows-install-ms.txt"
run_in_rootfs \
  /opt/sacramento-state/vcpkg/vcpkg list \
  --x-install-root=/srv/windows-installed \
  | tee "${evidence_root}/vcpkg-windows-list.txt"

configure_build() {
  local suffix="$1"
  run_in_rootfs \
    /usr/bin/cmake \
    -S /opt/sacramento-repo/prototypes/composed_foundation_gate2f \
    -B "/srv/windows-build-${suffix}" \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_MAKE_PROGRAM=/usr/bin/ninja \
    -DCMAKE_TOOLCHAIN_FILE=/opt/sacramento-state/vcpkg/scripts/buildsystems/vcpkg.cmake \
    -DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=/opt/sacramento-repo/prototypes/composed_foundation_gate2f/cmake/windows-vcpkg-chainload.cmake \
    -DVCPKG_TARGET_TRIPLET=x64-windows-cross-clang \
    -DVCPKG_INSTALLED_DIR=/srv/windows-installed \
    -DVCPKG_MANIFEST_INSTALL=OFF \
    -DFALCOR_SDK=/srv/falcor-sdk \
    -DSACRAMENTO_HARDENING=ON \
    -DSACRAMENTO_REPRODUCIBLE=ON \
    | tee "${evidence_root}/windows-build-${suffix}-configure.log"
}

build_project() {
  local suffix="$1"
  local start_ns end_ns
  start_ns="$(date +%s%N)"
  run_in_rootfs \
    /usr/bin/cmake --build "/srv/windows-build-${suffix}" --parallel 8 \
    | tee "${evidence_root}/windows-build-${suffix}.log"
  end_ns="$(date +%s%N)"
  printf '%s\n' "$(((end_ns - start_ns) / 1000000))" \
    >"${evidence_root}/windows-build-${suffix}-ms.txt"
}

for suffix in a b; do
  configure_build "${suffix}"
  build_project "${suffix}"
done

executable_name=sacramento_gate2f_rendered_client.exe
cmp \
  "${gate_root}/windows-build-a/${executable_name}" \
  "${gate_root}/windows-build-b/${executable_name}"
sha256sum \
  "${gate_root}/windows-build-a/${executable_name}" \
  "${gate_root}/windows-build-b/${executable_name}" \
  >"${evidence_root}/reproducible-sha256.txt"
file "${gate_root}/windows-build-a/${executable_name}" \
  >"${evidence_root}/artifact-type.txt"
run_in_rootfs \
  /usr/lib/llvm-22/bin/llvm-readobj --coff-imports \
  "/srv/windows-build-a/${executable_name}" \
  >"${evidence_root}/windows-imports.txt"
grep -q 'Name: Falcor.dll' "${evidence_root}/windows-imports.txt"
grep -q 'Name: bcrypt.dll' "${evidence_root}/windows-imports.txt"

python3 "${prototype_root}/audit_composition.py" \
  --map "${gate_root}/windows-build-a/sacramento_gate2f_rendered_client.map" \
  --vcpkg-list "${evidence_root}/vcpkg-windows-list.txt" \
  --output "${evidence_root}/composition-audit.json"
if strings "${gate_root}/windows-build-a/${executable_name}" \
  | rg -i 'TracyClient|___tracy|TracyMessage|ZoneScoped'; then
  echo "Tracy entered the Gate 2F operational executable" >&2
  exit 1
fi

cp -a "${gate_root}/windows-build-a/." "${gate_root}/native-bundle/"
cp "${repo_root}/prototypes/composed_foundation_gate2c/scenario/client-1.inputs" \
  "${gate_root}/native-bundle/rendered.inputs"
find "${gate_root}/native-bundle" -type f -printf '%P\n' \
  | LC_ALL=C sort >"${evidence_root}/native-bundle-inventory.txt"
find "${gate_root}/native-bundle" -type f -print0 \
  | LC_ALL=C sort -z | xargs -0 sha256sum \
  | sed "s#${gate_root}/native-bundle/##" \
  >"${evidence_root}/native-bundle-sha256.txt"

printf '%s\n' \
  'Gate 2F cross-build verdict: PASS' \
  'Native acceptance remains required:' \
  '1. Start the retained Gate 2C Debian authority with two clients expected.' \
  '2. Start one retained Gate 2C synthetic client.' \
  '3. On Windows/NVIDIA, run:' \
  '   .\run-smoke.ps1 -AuthorityHost <authority-ip> -Port <authority-port> -Script .\rendered.inputs' \
  '4. Retain stdout, rendered-client.pcm, rendered-client.ndjson, and authority result.' \
  '5. Accept only literal composition output with Vulkan/Falcor, Steam Audio,' \
  '   GameNetworkingSockets, CoreOnly observability, and tracy_linked=false.' \
  >"${evidence_root}/native-run-required.txt"

echo "Gate 2F cross-build verdict: PASS; native Windows composition pending"
