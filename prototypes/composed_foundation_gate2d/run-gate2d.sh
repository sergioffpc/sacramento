#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
prototype_root="${repo_root}/prototypes/composed_foundation_gate2d"
toolchain_root="${SACRAMENTO_CPP_TOOLCHAIN_ROOT:-/var/tmp/sacramento-cpp-toolchain}"
gate_root="${SACRAMENTO_GATE2D_ROOT:-/tmp/sacramento-composed-foundation-gate2d}"
rootfs="${toolchain_root}/ubuntu-26.04"
debian_sysroot="${toolchain_root}/debian-13.6-sysroot"
evidence_root="${gate_root}/evidence"
gate_start_ns="$(date +%s%N)"

if [[ "${gate_root}" == "${repo_root}" || "${gate_root}" == "${repo_root}/"* ]]; then
  echo "SACRAMENTO_GATE2D_ROOT must be outside the Git worktree" >&2
  exit 2
fi
if [[ -e "${gate_root}" ]]; then
  echo "Gate 2D output already exists; choose a fresh root" >&2
  exit 2
fi
for command in bwrap cmp file nm python3 readelf sha256sum; do
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
  "${gate_root}/debian-buildtrees" \
  "${gate_root}/debian-installed" \
  "${gate_root}/debian-packages" \
  "${gate_root}/windows-buildtrees" \
  "${gate_root}/windows-installed" \
  "${gate_root}/windows-packages"

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
      SACRAMENTO_VCTOOLS_DIR=/opt/sacramento-state/sysroot-v18-ms/crt \
      SACRAMENTO_WINSDK_DIR=/opt/sacramento-state/sysroot-v18-ms/sdk \
      VCPKG_BINARY_SOURCES=clear \
      VCPKG_DISABLE_METRICS=1 \
      VCPKG_MAX_CONCURRENCY=8 \
      "$@"
}

install_platform() {
  local platform="$1"
  local triplet="$2"
  local start_ns end_ns
  start_ns="$(date +%s%N)"
  run_in_rootfs \
    /opt/sacramento-state/vcpkg/vcpkg install \
    --x-manifest-root=/opt/sacramento-repo/prototypes/composed_foundation_gate2d \
    --x-install-root="/srv/${platform}-installed" \
    --x-buildtrees-root="/srv/${platform}-buildtrees" \
    --x-packages-root="/srv/${platform}-packages" \
    --downloads-root=/srv/downloads \
    --overlay-ports=/opt/sacramento-repo/prototypes/composed_foundation_gate2d/ports \
    --overlay-triplets=/opt/sacramento-repo/prototypes/composed_foundation_gate2d/triplets \
    --triplet="${triplet}" \
    --host-triplet=x64-linux \
    | tee "${evidence_root}/vcpkg-${platform}-install.log"
  end_ns="$(date +%s%N)"
  printf '%s\n' "$(((end_ns - start_ns) / 1000000))" \
    >"${evidence_root}/vcpkg-${platform}-install-ms.txt"
  run_in_rootfs \
    /opt/sacramento-state/vcpkg/vcpkg list \
    --x-install-root="/srv/${platform}-installed" \
    | tee "${evidence_root}/vcpkg-${platform}-list.txt"
}

install_platform debian x64-debian-cross-clang
install_platform windows x64-windows-cross-clang

for platform in debian windows; do
  grep -Eq '^steam-audio:.*[[:space:]]+4\.8\.1[[:space:]]' \
    "${evidence_root}/vcpkg-${platform}-list.txt"
  grep -Eq '^flatbuffers:.*[[:space:]]+25\.12\.19[[:space:]]' \
    "${evidence_root}/vcpkg-${platform}-list.txt"
  grep -Eq '^libmysofa:.*[[:space:]]+1\.3\.4#1[[:space:]]' \
    "${evidence_root}/vcpkg-${platform}-list.txt"
  grep -Eq '^pffft:.*[[:space:]]+1\.0\.0[[:space:]]' \
    "${evidence_root}/vcpkg-${platform}-list.txt"
  grep -Eq '^zlib:.*[[:space:]]+1\.3\.2#1[[:space:]]' \
    "${evidence_root}/vcpkg-${platform}-list.txt"
done

find "${gate_root}/downloads" -maxdepth 1 -type f -printf '%f\n' \
  | LC_ALL=C sort >"${evidence_root}/download-inventory.txt"
find "${gate_root}/downloads" -maxdepth 1 -type f -print0 \
  | LC_ALL=C sort -z \
  | xargs -0 sha256sum \
  | sed "s#${gate_root}/downloads/##" \
  >"${evidence_root}/download-sha256.txt"
find "${gate_root}" -path '*/share/*/copyright' -type f -print0 \
  | LC_ALL=C sort -z \
  | xargs -0 sha256sum \
  | sed "s#${gate_root}/##" \
  >"${evidence_root}/copyright-sha256.txt"

configure_debian() {
  local build_name="$1"
  run_in_rootfs \
    /usr/bin/cmake \
    -S /opt/sacramento-repo/prototypes/composed_foundation_gate2d \
    -B "/srv/${build_name}" \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_MAKE_PROGRAM=/usr/bin/ninja \
    -DCMAKE_TOOLCHAIN_FILE=/opt/sacramento-state/vcpkg/scripts/buildsystems/vcpkg.cmake \
    -DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=/opt/sacramento-repo/prototypes/composed_foundation_gate2d/cmake/debian-vcpkg-chainload.cmake \
    -DVCPKG_TARGET_TRIPLET=x64-debian-cross-clang \
    -DVCPKG_INSTALLED_DIR=/srv/debian-installed \
    -DVCPKG_MANIFEST_INSTALL=OFF \
    -DSACRAMENTO_HARDENING=ON \
    -DSACRAMENTO_REPRODUCIBLE=ON \
    | tee "${evidence_root}/${build_name}-configure.log"
}

configure_windows() {
  local build_name="$1"
  run_in_rootfs \
    /usr/bin/cmake \
    -S /opt/sacramento-repo/prototypes/composed_foundation_gate2d \
    -B "/srv/${build_name}" \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_MAKE_PROGRAM=/usr/bin/ninja \
    -DCMAKE_TOOLCHAIN_FILE=/opt/sacramento-state/vcpkg/scripts/buildsystems/vcpkg.cmake \
    -DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=/opt/sacramento-repo/prototypes/composed_foundation_gate2d/cmake/windows-vcpkg-chainload.cmake \
    -DVCPKG_TARGET_TRIPLET=x64-windows-cross-clang \
    -DVCPKG_INSTALLED_DIR=/srv/windows-installed \
    -DVCPKG_MANIFEST_INSTALL=OFF \
    -DSACRAMENTO_HARDENING=ON \
    -DSACRAMENTO_REPRODUCIBLE=ON \
    | tee "${evidence_root}/${build_name}-configure.log"
}

build_project() {
  local build_name="$1"
  local start_ns end_ns
  start_ns="$(date +%s%N)"
  run_in_rootfs /usr/bin/cmake --build "/srv/${build_name}" --parallel 8 \
    | tee "${evidence_root}/${build_name}-build.log"
  end_ns="$(date +%s%N)"
  printf '%s\n' "$(((end_ns - start_ns) / 1000000))" \
    >"${evidence_root}/${build_name}-build-ms.txt"
}

for build_name in debian-build-a debian-build-b; do
  configure_debian "${build_name}"
  build_project "${build_name}"
done
for build_name in windows-build-a windows-build-b; do
  configure_windows "${build_name}"
  build_project "${build_name}"
done

cmp "${gate_root}/debian-build-a/sacramento_gate2d_authority" \
    "${gate_root}/debian-build-b/sacramento_gate2d_authority"
cmp "${gate_root}/debian-build-a/sacramento_gate2d_client" \
    "${gate_root}/debian-build-b/sacramento_gate2d_client"
cmp "${gate_root}/windows-build-a/sacramento_gate2d_authority.exe" \
    "${gate_root}/windows-build-b/sacramento_gate2d_authority.exe"
cmp "${gate_root}/windows-build-a/sacramento_gate2d_client.exe" \
    "${gate_root}/windows-build-b/sacramento_gate2d_client.exe"

incremental_start_ns="$(date +%s%N)"
run_in_rootfs /usr/bin/cmake --build /srv/debian-build-a --parallel 8 \
  | tee "${evidence_root}/debian-incremental-build.log"
incremental_end_ns="$(date +%s%N)"
printf '%s\n' "$(((incremental_end_ns - incremental_start_ns) / 1000000))" \
  >"${evidence_root}/debian-incremental-build-ms.txt"

debian_loader="${debian_sysroot}/lib64/ld-linux-x86-64.so.2"
debian_libraries="${debian_sysroot}/usr/lib/x86_64-linux-gnu:${debian_sysroot}/lib/x86_64-linux-gnu"
for suffix in a b; do
  build_root="${gate_root}/debian-build-${suffix}"
  "${debian_loader}" --library-path "${debian_libraries}" \
    "${build_root}/sacramento_gate2d_authority" \
    "${gate_root}/event-${suffix}.txt" \
    | tee "${gate_root}/authority-${suffix}.json"
  render_start_ns="$(date +%s%N)"
  "${debian_loader}" --library-path "${debian_libraries}" \
    "${build_root}/sacramento_gate2d_client" \
    "${gate_root}/event-${suffix}.txt" \
    "${gate_root}/output-${suffix}.pcm" \
    | tee "${gate_root}/client-${suffix}.json"
  render_end_ns="$(date +%s%N)"
  printf '%s\n' "$(((render_end_ns - render_start_ns) / 1000))" \
    >"${evidence_root}/client-${suffix}-runtime-us.txt"
done

cmp "${gate_root}/event-a.txt" "${gate_root}/event-b.txt"
cmp "${gate_root}/authority-a.json" "${gate_root}/authority-b.json"
cmp "${gate_root}/client-a.json" "${gate_root}/client-b.json"
cmp "${gate_root}/output-a.pcm" "${gate_root}/output-b.pcm"

python3 - "${gate_root}/authority-a.json" "${gate_root}/client-a.json" <<'PY'
import json
import pathlib
import sys

authority_lines = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8").splitlines()
client_lines = pathlib.Path(sys.argv[2]).read_text(encoding="utf-8").splitlines()
if len(authority_lines) != 1 or len(client_lines) != 1:
    raise SystemExit("Steam Audio emitted unexpected diagnostics")
authority = json.loads(authority_lines[0])
client = json.loads(client_lines[0])
assert authority["status"] == "pass"
assert client["status"] == "pass"
assert authority["event_correlation_id"] == client["event_correlation_id"]
assert authority["authoritative_arrival_timestamp_ns"] == 4_034_985_423
assert client["authoritative_arrival_timestamp_ns"] == 4_034_985_423
assert client["scheduled_arrival_sample"] == 1_680
assert client["first_nonzero_sample"] >= client["scheduled_arrival_sample"]
assert client["distance_attenuation_per_mille"] == 83
assert client["direct_occlusion_per_mille"] == 0
assert client["low_band_transmission_per_mille"] == 350
assert client["left_absolute_energy"] > 0
assert client["right_absolute_energy"] > client["left_absolute_energy"]
PY

python3 "${prototype_root}/audit_boundary.py" \
  --public-root "${prototype_root}/include" \
  --source-root "${prototype_root}/src" \
  --authority "${gate_root}/debian-build-a/sacramento_gate2d_authority" \
  --client "${gate_root}/debian-build-a/sacramento_gate2d_client" \
  --output "${evidence_root}/boundary-audit.json"

run_in_rootfs /usr/lib/llvm-22/bin/llvm-objdump -p \
  /srv/windows-build-a/sacramento_gate2d_client.exe \
  >"${evidence_root}/windows-client-pe.txt"
if grep -Eiq 'DLL Name:.*(phonon|mysofa|zlib|flatbuffers|pffft)' \
  "${evidence_root}/windows-client-pe.txt"; then
  echo "Windows client acquired an unexpected vendor DLL dependency" >&2
  exit 1
fi

mkdir -p "${gate_root}/windows-native-bundle/licenses"
cp "${gate_root}/windows-build-a/sacramento_gate2d_client.exe" \
   "${gate_root}/windows-native-bundle/"
cp "${gate_root}/event-a.txt" "${gate_root}/windows-native-bundle/event.txt"
cp "${prototype_root}/run-smoke.ps1" "${gate_root}/windows-native-bundle/"
cp "${gate_root}/windows-installed/x64-windows-cross-clang/share/steam-audio/copyright" \
   "${gate_root}/windows-native-bundle/licenses/steam-audio.txt"

file \
  "${gate_root}/debian-build-a/sacramento_gate2d_authority" \
  "${gate_root}/debian-build-a/sacramento_gate2d_client" \
  "${gate_root}/windows-build-a/sacramento_gate2d_authority.exe" \
  "${gate_root}/windows-build-a/sacramento_gate2d_client.exe" \
  | tee "${evidence_root}/artifacts.txt"
sha256sum \
  "${gate_root}/debian-build-a/sacramento_gate2d_authority" \
  "${gate_root}/debian-build-a/sacramento_gate2d_client" \
  "${gate_root}/windows-build-a/sacramento_gate2d_authority.exe" \
  "${gate_root}/windows-build-a/sacramento_gate2d_client.exe" \
  "${gate_root}/event-a.txt" \
  "${gate_root}/output-a.pcm" \
  | tee -a "${evidence_root}/artifacts.txt"
du -b \
  "${gate_root}/debian-build-a/sacramento_gate2d_authority" \
  "${gate_root}/debian-build-a/sacramento_gate2d_client" \
  "${gate_root}/windows-build-a/sacramento_gate2d_authority.exe" \
  "${gate_root}/windows-build-a/sacramento_gate2d_client.exe" \
  "${gate_root}/windows-native-bundle" \
  | tee -a "${evidence_root}/artifacts.txt"
wc -l \
  "${prototype_root}/src/steam_audio_adapter.cc" \
  "${prototype_root}/src/acoustic_event.cc" \
  "${prototype_root}/include/sacramento/gate2d/acoustics.h" \
  >"${evidence_root}/first-party-lines.txt"

gate_end_ns="$(date +%s%N)"
printf '%s\n' "$(((gate_end_ns - gate_start_ns) / 1000000))" \
  >"${evidence_root}/gate-runtime-ms.txt"
echo "Gate 2D verdict: PASS for Debian native and Windows cross-build; native Windows runtime remains UNPROVED"
