#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
prototype_root="${repo_root}/prototypes/composed_foundation_gate2b"
toolchain_root="${SACRAMENTO_CPP_TOOLCHAIN_ROOT:-/var/tmp/sacramento-cpp-toolchain}"
gate_root="${SACRAMENTO_GATE2B_ROOT:-/tmp/sacramento-composed-foundation-gate2b}"
rootfs="${toolchain_root}/ubuntu-26.04"
installed_root="${gate_root}/vcpkg-installed"
evidence_root="${gate_root}/evidence"

if [[ "${gate_root}" == "${repo_root}" || "${gate_root}" == "${repo_root}/"* ]]; then
  echo "SACRAMENTO_GATE2B_ROOT must be outside the Git worktree" >&2
  exit 2
fi
if [[ -e "${gate_root}" ]]; then
  echo "Gate 2B output already exists; choose a fresh SACRAMENTO_GATE2B_ROOT" >&2
  exit 2
fi

for command in bwrap cmp file ldd python3 readelf rg sha256sum sha512sum; do
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
      VCPKG_BINARY_SOURCES=clear \
      VCPKG_DISABLE_METRICS=1 \
      "$@"
}

run_in_rootfs \
  /opt/sacramento-state/vcpkg/vcpkg install \
  --x-manifest-root=/opt/sacramento-repo/prototypes/composed_foundation_gate2b \
  --x-install-root=/srv/vcpkg-installed \
  --x-buildtrees-root=/srv/vcpkg-buildtrees \
  --x-packages-root=/srv/vcpkg-packages \
  --downloads-root=/srv/vcpkg-downloads \
  --overlay-ports=/opt/sacramento-repo/prototypes/composed_foundation_gate2b/ports \
  --triplet=x64-linux \
  --host-triplet=x64-linux \
  | tee "${evidence_root}/vcpkg-install.log"

run_in_rootfs \
  /opt/sacramento-state/vcpkg/vcpkg list \
  --x-install-root=/srv/vcpkg-installed \
  | tee "${evidence_root}/vcpkg-list.txt"
rg '^assimp:x64-linux[[:space:]]+6\.0\.5[[:space:]]' \
  "${evidence_root}/vcpkg-list.txt"
if rg -i '^(openusd|usd|python):' "${evidence_root}/vcpkg-list.txt"; then
  echo "OpenUSD or Python entered the Assimp adapter dependency closure" >&2
  exit 1
fi

find "${gate_root}/vcpkg-downloads" -maxdepth 1 -type f -print0 \
  | LC_ALL=C sort -z \
  | xargs -0 sha512sum >"${evidence_root}/download-sha512.txt"
find "${installed_root}/x64-linux/share" -type f -name copyright -print0 \
  | LC_ALL=C sort -z \
  | xargs -0 sha256sum >"${evidence_root}/installed-licence-sha256.txt"

configure_build() {
  local build_name="$1"
  run_in_rootfs \
    /usr/bin/cmake \
    -S /opt/sacramento-repo/prototypes/composed_foundation_gate2b \
    -B "/srv/${build_name}" \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_MAKE_PROGRAM=/usr/bin/ninja \
    -DCMAKE_TOOLCHAIN_FILE=/opt/sacramento-state/vcpkg/scripts/buildsystems/vcpkg.cmake \
    -DVCPKG_TARGET_TRIPLET=x64-linux \
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

adapter_a="${gate_root}/build-a/sacramento_gate2b_assimp_adapter"
adapter_b="${gate_root}/build-b/sacramento_gate2b_assimp_adapter"
reader_a="${gate_root}/build-a/sacramento_gate2b_runtime_reader"
reader_b="${gate_root}/build-b/sacramento_gate2b_runtime_reader"
cmp "${adapter_a}" "${adapter_b}"
cmp "${reader_a}" "${reader_b}"

run_in_rootfs \
  /usr/bin/env \
  SACRAMENTO_GATE2B_ADAPTER=/srv/build-a/sacramento_gate2b_assimp_adapter \
  SACRAMENTO_GATE2B_RUNTIME_READER=/srv/build-a/sacramento_gate2b_runtime_reader \
  /usr/bin/python3 -m unittest discover \
  -s /opt/sacramento-repo/prototypes/composed_foundation_gate2b/tests -v \
  | tee "${evidence_root}/tests.log"

for cook_name in cook-a cook-b; do
  mkdir "${gate_root}/${cook_name}"
  start_ns="$(date +%s%N)"
  run_in_rootfs \
    /usr/bin/python3 /opt/sacramento-repo/prototypes/composed_foundation_gate2b/cook.py \
    --source /opt/sacramento-repo/prototypes/composed_foundation_gate2b/fixtures/blender-origin-map.gltf \
    --recipe /opt/sacramento-repo/prototypes/composed_foundation_gate2b/fixtures/blender-origin-map.recipe.json \
    --adapter "/srv/build-${cook_name#cook-}/sacramento_gate2b_assimp_adapter" \
    --output "/srv/${cook_name}/training-yard.sacmap" \
    --manifest "/srv/${cook_name}/training-yard.manifest.json"
  end_ns="$(date +%s%N)"
  printf '%s\n' "$(((end_ns - start_ns) / 1000000))" \
    >"${evidence_root}/${cook_name}-ms.txt"
done

cmp "${gate_root}/cook-a/training-yard.sacmap" \
  "${gate_root}/cook-b/training-yard.sacmap"
cmp "${gate_root}/cook-a/training-yard.manifest.json" \
  "${gate_root}/cook-b/training-yard.manifest.json"

run_in_rootfs \
  /srv/build-a/sacramento_gate2b_runtime_reader \
  /srv/cook-a/training-yard.sacmap \
  | tee "${evidence_root}/runtime-inspection.json"

{
  /usr/bin/python3 --version
  file "${adapter_a}" "${reader_a}"
  sha256sum "${adapter_a}" "${adapter_b}" "${reader_a}" "${reader_b}" \
    "${gate_root}/cook-a/training-yard.sacmap" \
    "${gate_root}/cook-b/training-yard.sacmap" \
    "${gate_root}/cook-a/training-yard.manifest.json" \
    "${gate_root}/cook-b/training-yard.manifest.json"
  du -b "${adapter_a}" "${reader_a}" \
    "${gate_root}/cook-a/training-yard.sacmap" \
    "${gate_root}/cook-a/training-yard.manifest.json"
} >"${evidence_root}/artifact-inventory.txt"

ldd "${adapter_a}" >"${evidence_root}/adapter-ldd.txt"
ldd "${reader_a}" >"${evidence_root}/runtime-reader-ldd.txt"
readelf -d "${adapter_a}" >"${evidence_root}/adapter-dynamic.txt"
readelf -d "${reader_a}" >"${evidence_root}/runtime-reader-dynamic.txt"
if rg -i 'assimp|openusd|usd|python|gltf|blender' \
  "${evidence_root}/runtime-reader-ldd.txt" \
  "${evidence_root}/runtime-reader-dynamic.txt"; then
  echo "source-tool dependency entered the runtime reader" >&2
  exit 1
fi

echo "Gate 2B Assimp path verdict: PASS"
