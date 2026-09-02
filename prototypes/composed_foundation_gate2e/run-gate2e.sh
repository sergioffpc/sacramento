#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
prototype_root="${repo_root}/prototypes/composed_foundation_gate2e"
toolchain_root="${SACRAMENTO_CPP_TOOLCHAIN_ROOT:-/var/tmp/sacramento-cpp-toolchain}"
gate_root="${SACRAMENTO_GATE2E_ROOT:-/tmp/sacramento-composed-foundation-gate2e}"
rootfs="${toolchain_root}/ubuntu-26.04"
debian_sysroot="${toolchain_root}/debian-13.6-sysroot"
evidence_root="${gate_root}/evidence"

if [[ "${gate_root}" == "${repo_root}" || "${gate_root}" == "${repo_root}/"* ]]; then
  echo "SACRAMENTO_GATE2E_ROOT must be outside the Git worktree" >&2
  exit 2
fi
if [[ -e "${gate_root}" ]]; then
  echo "Gate 2E output already exists; choose a fresh root" >&2
  exit 2
fi
for command in bwrap cmp du file nm python3 readelf sha256sum; do
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
  "${gate_root}/windows-packages" \
  "${gate_root}/runs"

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
    --x-manifest-root=/opt/sacramento-repo/prototypes/composed_foundation_gate2e \
    --x-install-root="/srv/${platform}-installed" \
    --x-buildtrees-root="/srv/${platform}-buildtrees" \
    --x-packages-root="/srv/${platform}-packages" \
    --downloads-root=/srv/downloads \
    --overlay-triplets=/opt/sacramento-repo/prototypes/composed_foundation_gate2e/triplets \
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
  grep -Eq '^tracy:.*[[:space:]]+0\.13\.1[[:space:]]' \
    "${evidence_root}/vcpkg-${platform}-list.txt"
done

find "${gate_root}/downloads" -maxdepth 1 -type f -printf '%f\n' \
  | LC_ALL=C sort >"${evidence_root}/download-inventory.txt"
find "${gate_root}" -path '*/share/*/copyright' -type f -print0 \
  | LC_ALL=C sort -z \
  | xargs -0 sha256sum \
  | sed "s#${gate_root}/##" \
  >"${evidence_root}/copyright-sha256.txt"

configure_build() {
  local platform="$1"
  local profile="$2"
  local suffix="$3"
  local build_name="${platform}-${profile}-build-${suffix}"
  local toolchain
  local diagnostic=OFF
  local extra_arguments=()
  if [[ "${platform}" == debian ]]; then
    toolchain=/opt/sacramento-repo/cmake/toolchains/debian-cross-clang.cmake
  else
    toolchain=/opt/sacramento-repo/cmake/toolchains/windows-cross-clang.cmake
  fi
  if [[ "${profile}" == diagnostic ]]; then
    diagnostic=ON
    toolchain=/opt/sacramento-state/vcpkg/scripts/buildsystems/vcpkg.cmake
    extra_arguments+=(
      -DVCPKG_CHAINLOAD_TOOLCHAIN_FILE="/opt/sacramento-repo/prototypes/composed_foundation_gate2e/cmake/${platform}-vcpkg-chainload.cmake"
      -DVCPKG_TARGET_TRIPLET="x64-${platform}-cross-clang"
      -DVCPKG_INSTALLED_DIR="/srv/${platform}-installed"
      -DVCPKG_MANIFEST_INSTALL=OFF)
  fi
  run_in_rootfs \
    /usr/bin/cmake \
    -S /opt/sacramento-repo/prototypes/composed_foundation_gate2e \
    -B "/srv/${build_name}" \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_MAKE_PROGRAM=/usr/bin/ninja \
    -DCMAKE_TOOLCHAIN_FILE="${toolchain}" \
    -DSACRAMENTO_GATE2E_DIAGNOSTIC="${diagnostic}" \
    -DSACRAMENTO_HARDENING=ON \
    -DSACRAMENTO_REPRODUCIBLE=ON \
    "${extra_arguments[@]}" \
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

for platform in debian windows; do
  for profile in core diagnostic; do
    for suffix in a b; do
      configure_build "${platform}" "${profile}" "${suffix}"
      build_project "${platform}-${profile}-build-${suffix}"
    done
  done
done

for platform in debian windows; do
  extension=""
  if [[ "${platform}" == windows ]]; then extension=.exe; fi
  for profile in core diagnostic; do
    cmp \
      "${gate_root}/${platform}-${profile}-build-a/sacramento_gate2e_${profile}${extension}" \
      "${gate_root}/${platform}-${profile}-build-b/sacramento_gate2e_${profile}${extension}"
  done
done

incremental_start_ns="$(date +%s%N)"
run_in_rootfs /usr/bin/cmake --build /srv/debian-diagnostic-build-a --parallel 8 \
  | tee "${evidence_root}/debian-diagnostic-incremental-build.log"
incremental_end_ns="$(date +%s%N)"
printf '%s\n' "$(((incremental_end_ns - incremental_start_ns) / 1000000))" \
  >"${evidence_root}/debian-diagnostic-incremental-build-ms.txt"

debian_loader="${debian_sysroot}/lib64/ld-linux-x86-64.so.2"
debian_libraries="${debian_sysroot}/usr/lib/x86_64-linux-gnu:${debian_sysroot}/lib/x86_64-linux-gnu"
for profile in core diagnostic; do
  detail=CoreOnly
  if [[ "${profile}" == diagnostic ]]; then detail=Diagnostic; fi
  for role in authority rendered synthetic; do
    SACRAMENTO_GATE2E_ROLE="${role}" \
    SACRAMENTO_GATE2E_DETAIL="${detail}" \
    SACRAMENTO_GATE2E_OUTPUT="${gate_root}/runs/${profile}-${role}.ndjson" \
      "${debian_loader}" --library-path "${debian_libraries}" \
      "${gate_root}/debian-${profile}-build-a/sacramento_gate2e_${profile}" \
      >"${gate_root}/runs/${profile}-${role}.json" \
      2>"${gate_root}/runs/${profile}-${role}.stderr"
  done
done

python3 "${prototype_root}/verify_signals.py" \
  --root "${gate_root}/runs" \
  --output "${evidence_root}/signal-verification.json"
python3 "${prototype_root}/audit_boundary.py" \
  --public-root "${prototype_root}/include" \
  --core "${gate_root}/debian-core-build-a/sacramento_gate2e_core" \
  --diagnostic "${gate_root}/debian-diagnostic-build-a/sacramento_gate2e_diagnostic" \
  --output "${evidence_root}/boundary-audit.json"

if rg -n 'opentelemetry|OpenTelemetry' \
  "${prototype_root}/include" "${prototype_root}/src" "${gate_root}/runs"; then
  echo "OpenTelemetry entered the Gate 2E implementation or signals" >&2
  exit 1
fi

readelf -d "${gate_root}/debian-core-build-a/sacramento_gate2e_core" \
  >"${evidence_root}/debian-core-dynamic.txt"
readelf -d "${gate_root}/debian-diagnostic-build-a/sacramento_gate2e_diagnostic" \
  >"${evidence_root}/debian-diagnostic-dynamic.txt"
file \
  "${gate_root}/debian-core-build-a/sacramento_gate2e_core" \
  "${gate_root}/debian-diagnostic-build-a/sacramento_gate2e_diagnostic" \
  "${gate_root}/windows-core-build-a/sacramento_gate2e_core.exe" \
  "${gate_root}/windows-diagnostic-build-a/sacramento_gate2e_diagnostic.exe" \
  | tee "${evidence_root}/artifacts.txt"
sha256sum \
  "${gate_root}/debian-core-build-a/sacramento_gate2e_core" \
  "${gate_root}/debian-diagnostic-build-a/sacramento_gate2e_diagnostic" \
  "${gate_root}/windows-core-build-a/sacramento_gate2e_core.exe" \
  "${gate_root}/windows-diagnostic-build-a/sacramento_gate2e_diagnostic.exe" \
  "${evidence_root}/signal-verification.json" \
  | tee -a "${evidence_root}/artifacts.txt"
du -b \
  "${gate_root}/debian-core-build-a/sacramento_gate2e_core" \
  "${gate_root}/debian-diagnostic-build-a/sacramento_gate2e_diagnostic" \
  "${gate_root}/windows-core-build-a/sacramento_gate2e_core.exe" \
  "${gate_root}/windows-diagnostic-build-a/sacramento_gate2e_diagnostic.exe" \
  | tee -a "${evidence_root}/artifacts.txt"
du -sb \
  "${gate_root}/debian-installed/x64-debian-cross-clang" \
  "${gate_root}/windows-installed/x64-windows-cross-clang" \
  | tee "${evidence_root}/installed-size.txt"
wc -l \
  "${prototype_root}/src/observability.cc" \
  "${prototype_root}/src/tracy_profiler_adapter.cc" \
  "${prototype_root}/include/sacramento/gate2e/observability.h" \
  >"${evidence_root}/first-party-lines.txt"

echo "Gate 2E verdict: PASS for OBS-CONTRACT-001 core semantics and Tracy profile separation"
