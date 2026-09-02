#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
prototype_root="${repo_root}/prototypes/composed_foundation_gate2c"
toolchain_root="${SACRAMENTO_CPP_TOOLCHAIN_ROOT:-/var/tmp/sacramento-cpp-toolchain}"
gate_root="${SACRAMENTO_GATE2C_ROOT:-/tmp/sacramento-composed-foundation-gate2c}"
rootfs="${toolchain_root}/ubuntu-26.04"
debian_sysroot="${toolchain_root}/debian-13.6-sysroot"
installed_root="${gate_root}/vcpkg-installed"
evidence_root="${gate_root}/evidence"

if [[ "${gate_root}" == "${repo_root}" || "${gate_root}" == "${repo_root}/"* ]]; then
  echo "SACRAMENTO_GATE2C_ROOT must be outside the Git worktree" >&2
  exit 2
fi
if [[ -e "${gate_root}" ]]; then
  echo "Gate 2C output already exists; choose a fresh SACRAMENTO_GATE2C_ROOT" >&2
  exit 2
fi

for command in bwrap cmp file make python3 readelf rg sha256sum; do
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
  "${gate_root}/tools" \
  "${gate_root}/vcpkg-buildtrees" \
  "${gate_root}/vcpkg-downloads" \
  "${gate_root}/vcpkg-packages"

make_sha256="$(sha256sum "$(command -v make)" | cut -d' ' -f1)"
if [[ "${make_sha256}" != \
      "27c9f6d806aee15882b01c2c61848f7aa75caa14bc7b6f608ba422f9e46a7d49" ]]; then
  echo "Gate 2C requires the recorded GNU Make 4.4.1 host tool" >&2
  exit 2
fi
cp "$(command -v make)" "${gate_root}/tools/make"
make --version | sed -n '1,2p' >"${evidence_root}/make-version.txt"
sha256sum "${gate_root}/tools/make" >>"${evidence_root}/make-version.txt"

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
      PATH=/srv/tools:/usr/sbin:/usr/bin:/sbin:/bin \
      CC=/usr/lib/llvm-22/bin/clang \
      CXX=/usr/lib/llvm-22/bin/clang++ \
      SACRAMENTO_LLVM_ROOT=/usr/lib/llvm-22 \
      SACRAMENTO_DEBIAN_SYSROOT=/opt/sacramento-state/debian-13.6-sysroot \
      VCPKG_BINARY_SOURCES=clear \
      VCPKG_DISABLE_METRICS=1 \
      VCPKG_MAX_CONCURRENCY=8 \
      "$@"
}

run_in_rootfs \
  /opt/sacramento-state/vcpkg/vcpkg install \
  --x-manifest-root=/opt/sacramento-repo/prototypes/composed_foundation_gate2c \
  --x-install-root=/srv/vcpkg-installed \
  --x-buildtrees-root=/srv/vcpkg-buildtrees \
  --x-packages-root=/srv/vcpkg-packages \
  --downloads-root=/srv/vcpkg-downloads \
  --overlay-triplets=/opt/sacramento-repo/prototypes/composed_foundation_gate2c/triplets \
  --triplet=x64-debian-cross-clang \
  --host-triplet=x64-linux \
  | tee "${evidence_root}/vcpkg-install.log"

run_in_rootfs \
  /opt/sacramento-state/vcpkg/vcpkg list \
  --x-install-root=/srv/vcpkg-installed \
  | tee "${evidence_root}/vcpkg-list.txt"

for package in abseil gamenetworkingsockets openssl protobuf utf8-range; do
  grep -Eq "^${package}:x64-debian-cross-clang[[:space:]]" \
    "${evidence_root}/vcpkg-list.txt"
done
if grep -Eiq \
  '^(flecs|physx|falcor|vulkan|slang|steam.?audio|phonon|assimp|tracy|cuda|optix):' \
  "${evidence_root}/vcpkg-list.txt"; then
  echo "unrelated package entered the Gate 2C dependency closure" >&2
  exit 1
fi

find "${installed_root}" -path '*/share/*/copyright' -type f -print0 \
  | LC_ALL=C sort -z \
  | xargs -0 sha256sum >"${evidence_root}/licence-hashes.txt"
find "${gate_root}/vcpkg-downloads" -maxdepth 1 -type f -printf '%f\n' \
  | LC_ALL=C sort >"${evidence_root}/download-inventory.txt"

configure_build() {
  local build_name="$1"
  run_in_rootfs \
    /usr/bin/cmake \
    -S /opt/sacramento-repo/prototypes/composed_foundation_gate2c \
    -B "/srv/${build_name}" \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_MAKE_PROGRAM=/usr/bin/ninja \
    -DCMAKE_TOOLCHAIN_FILE=/opt/sacramento-state/vcpkg/scripts/buildsystems/vcpkg.cmake \
    -DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=/opt/sacramento-repo/prototypes/composed_foundation_gate2c/cmake/debian-vcpkg-chainload.cmake \
    -DVCPKG_TARGET_TRIPLET=x64-debian-cross-clang \
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

for binary in authority client protocol_probe; do
  cmp "${gate_root}/build-a/sacramento_gate2c_${binary}" \
      "${gate_root}/build-b/sacramento_gate2c_${binary}"
done

debian_loader="${debian_sysroot}/lib64/ld-linux-x86-64.so.2"
debian_libraries="${debian_sysroot}/usr/lib/x86_64-linux-gnu:${debian_sysroot}/lib/x86_64-linux-gnu"

"${debian_loader}" --library-path "${debian_libraries}" \
  "${gate_root}/build-a/sacramento_gate2c_protocol_probe" \
  | tee "${evidence_root}/protocol-probe.json"

run_scenario() {
  local run_name="$1"
  local requested_port="$2"
  shift 2
  local run_root="${gate_root}/${run_name}"
  mkdir -p "${run_root}"
    "${debian_loader}" --library-path "${debian_libraries}" \
    "${gate_root}/build-a/sacramento_gate2c_authority" \
    "${requested_port}" 4 "${run_root}/trace.ndjson" \
    "${run_root}/result.json" \
    >"${run_root}/authority.log" 2>&1 &
  local authority_pid="$!"
  local port=""
  for _ in $(seq 1 250); do
    port="$(sed -n 's/.*"port":\([0-9]*\).*/\1/p' \
      "${run_root}/authority.log" | head -n 1)"
    if [[ -n "${port}" ]]; then
      break
    fi
    if ! kill -0 "${authority_pid}" 2>/dev/null; then
      cat "${run_root}/authority.log" >&2
      return 1
    fi
    sleep 0.02
  done
  if [[ -z "${port}" ]]; then
    echo "authority did not publish its bound port" >&2
    return 1
  fi

  local client_pids=()
  local id role
  for id in "$@"; do
    role=synthetic
    if [[ "${id}" == 1 ]]; then
      role=rendered
    fi
    "${debian_loader}" --library-path "${debian_libraries}" \
      "${gate_root}/build-a/sacramento_gate2c_client" \
      "${port}" "${id}" "${role}" \
      "${prototype_root}/scenario/client-${id}.inputs" \
      >"${run_root}/client-${id}.json" 2>&1 &
    client_pids+=("$!")
  done
  for client_pid in "${client_pids[@]}"; do
    wait "${client_pid}"
  done
  wait "${authority_pid}"
}

run_scenario run-a 39181 1 2 3 4
run_scenario run-b 39182 4 3 2 1

cmp "${gate_root}/run-a/trace.ndjson" "${gate_root}/run-b/trace.ndjson"
cmp "${gate_root}/run-a/result.json" "${gate_root}/run-b/result.json"
for id in 1 2 3 4; do
  cmp "${gate_root}/run-a/client-${id}.json" \
      "${gate_root}/run-b/client-${id}.json"
done
test "$(wc -l <"${gate_root}/run-a/trace.ndjson")" -eq 120

python3 "${prototype_root}/audit_boundary.py" \
  --public-root "${prototype_root}/include" \
  --source-root "${prototype_root}/src" \
  --binary "${gate_root}/build-a/sacramento_gate2c_authority" \
  --binary "${gate_root}/build-a/sacramento_gate2c_client" \
  --output "${evidence_root}/boundary-audit.json"

file \
  "${gate_root}/build-a/sacramento_gate2c_authority" \
  "${gate_root}/build-a/sacramento_gate2c_client" \
  | tee "${evidence_root}/artifacts.txt"
sha256sum \
  "${gate_root}/build-a/sacramento_gate2c_authority" \
  "${gate_root}/build-b/sacramento_gate2c_authority" \
  "${gate_root}/build-a/sacramento_gate2c_client" \
  "${gate_root}/build-b/sacramento_gate2c_client" \
  "${gate_root}/run-a/trace.ndjson" \
  "${gate_root}/run-a/result.json" \
  | tee -a "${evidence_root}/artifacts.txt"
du -b \
  "${gate_root}/build-a/sacramento_gate2c_authority" \
  "${gate_root}/build-a/sacramento_gate2c_client" \
  | tee -a "${evidence_root}/artifacts.txt"

if rg -n '\[DEBUG''-' "${prototype_root}"; then
  echo "temporary diagnostics remain in Gate 2C" >&2
  exit 1
fi

echo "Gate 2C verdict: PASS"
