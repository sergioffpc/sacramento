#!/usr/bin/env bash
set -euo pipefail

proof_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
lock_file="${proof_dir}/config/bootstrap-lock.json"
state_root="${SACRAMENTO_CROSS_PROOF_ROOT:-/tmp/sacramento-cross-proof}"
downloads="${state_root}/downloads"
rootfs="${state_root}/ubuntu-26.04"
transport_ca_bundle="${SACRAMENTO_BOOTSTRAP_CA_BUNDLE:-}"

json_value() {
  python3 -c '
import json
import sys

value = json.load(open(sys.argv[1], encoding="utf-8"))
for component in sys.argv[2].split("."):
    value = value[component]
print(value)
' "${lock_file}" "$1"
}

require_command() {
  if ! command -v "$1" >/dev/null; then
    echo "missing host command: $1" >&2
    exit 2
  fi
}

verify_sha256() {
  local path="$1"
  local expected="$2"
  local actual
  actual="$(sha256sum "${path}" | cut -d ' ' -f 1)"
  if [[ "${actual}" != "${expected}" ]]; then
    echo "SHA-256 mismatch for ${path}: ${actual}" >&2
    exit 1
  fi
}

download_locked() {
  local name="$1"
  local url="$2"
  local expected="$3"
  local destination="${downloads}/${name}"
  mkdir -p "${downloads}"
  if [[ ! -f "${destination}" ]]; then
    curl --fail --location --proto '=https' --tlsv1.2 \
      --output "${destination}.partial" "${url}"
    mv "${destination}.partial" "${destination}"
  fi
  verify_sha256 "${destination}" "${expected}"
  printf '%s\n' "${destination}"
}

extract_zip() {
  python3 -c '
import sys
import zipfile

with zipfile.ZipFile(sys.argv[1]) as archive:
    archive.extractall(sys.argv[2])
' "$1" "$2"
}

run_in_rootfs() {
  local -a transport_bind=()
  local -a transport_environment=()
  if [[ -n "${transport_ca_bundle}" ]]; then
    transport_bind=(--ro-bind "${transport_ca_bundle}" /run/bootstrap-ca.crt)
    transport_environment=(
      SSL_CERT_FILE=/run/bootstrap-ca.crt
      GIT_SSL_CAINFO=/run/bootstrap-ca.crt
    )
  fi
  bwrap \
    --unshare-user \
    --uid 0 \
    --gid 0 \
    --bind "${rootfs}" / \
    --proc /proc \
    --dev /dev \
    --ro-bind /etc/resolv.conf /etc/resolv.conf \
    --bind "${state_root}" /opt/sacramento-state \
    --ro-bind "${proof_dir}" /opt/sacramento-proof \
    "${transport_bind[@]}" \
    /usr/bin/env -i \
      HOME=/root \
      PATH=/usr/sbin:/usr/bin:/sbin:/bin \
      DEBIAN_FRONTEND=noninteractive \
      "${transport_environment[@]}" \
      "$@"
}

seed_rootfs_trust_store() {
  local ca_archive
  if [[ -f "${rootfs}/etc/ssl/certs/ca-certificates.crt" ]]; then
    return
  fi
  ca_archive="$(download_locked \
    ca-certificates-seed.deb \
    "$(json_value ubuntu.ca_seed.url)" \
    "$(json_value ubuntu.ca_seed.sha256)")"
  dpkg-deb -x "${ca_archive}" "${rootfs}"
  mkdir -p "${rootfs}/etc/ssl/certs"
  find "${rootfs}/usr/share/ca-certificates/mozilla" \
    -type f -name '*.crt' -print0 \
    | sort -z \
    | xargs -0 cat >"${rootfs}/etc/ssl/certs/ca-certificates.crt"
}

install_rootfs() {
  local archive
  local snapshot
  local -a apt_ca_options=()
  archive="$(download_locked \
    ubuntu-resolute-oci-amd64-root.tar.gz \
    "$(json_value ubuntu.rootfs.url)" \
    "$(json_value ubuntu.rootfs.sha256)")"
  snapshot="$(json_value ubuntu.snapshot)"
  if ! grep -Fq "/${snapshot}/" \
      "${proof_dir}/config/ubuntu-snapshot.sources"; then
    echo "APT snapshot source does not match bootstrap lock" >&2
    exit 1
  fi
  if [[ -n "${transport_ca_bundle}" ]]; then
    apt_ca_options=(-o Acquire::https::CaInfo=/run/bootstrap-ca.crt)
  fi
  if [[ ! -x "${rootfs}/usr/bin/apt-get" ]]; then
    mkdir -p "${rootfs}"
    tar -xzf "${archive}" -C "${rootfs}"
  fi
  seed_rootfs_trust_store
  mapfile -t package_specs < <(python3 -c '
import json
import sys

packages = json.load(open(sys.argv[1], encoding="utf-8"))["ubuntu"]["packages"]
for name, version in sorted(packages.items()):
    print(f"{name}={version}")
' "${lock_file}")
  run_in_rootfs /usr/bin/apt-get \
    "${apt_ca_options[@]}" \
    -o APT::Sandbox::User=root \
    -o Dir::Etc::sourcelist=/opt/sacramento-proof/config/ubuntu-snapshot.sources \
    -o Dir::Etc::sourceparts=- \
    -o APT::Update::Error-Mode=any \
    update
  run_in_rootfs /usr/bin/apt-get \
    "${apt_ca_options[@]}" \
    -o APT::Sandbox::User=root \
    -o Dir::Etc::sourcelist=/opt/sacramento-proof/config/ubuntu-snapshot.sources \
    -o Dir::Etc::sourceparts=- \
    --yes \
    --no-install-recommends \
    install "${package_specs[@]}"
}

install_tool_archives() {
  local sccache_archive
  local xwin_archive
  sccache_archive="$(download_locked \
    sccache-0.16.0.tar.gz \
    "$(json_value tools.sccache.url)" \
    "$(json_value tools.sccache.archive_sha256)")"
  xwin_archive="$(download_locked \
    xwin-0.10.0.tar.gz \
    "$(json_value tools.xwin.url)" \
    "$(json_value tools.xwin.archive_sha256)")"
  if [[ ! -x "${state_root}/tools/sccache-0.16.0/sccache-v0.16.0-x86_64-unknown-linux-musl/sccache" ]]; then
    mkdir -p "${state_root}/tools/sccache-0.16.0"
    tar -xzf "${sccache_archive}" -C "${state_root}/tools/sccache-0.16.0"
  fi
  if [[ ! -x "${state_root}/tools/xwin-0.10.0-x86_64-unknown-linux-musl/xwin" ]]; then
    mkdir -p "${state_root}/tools"
    tar -xzf "${xwin_archive}" -C "${state_root}/tools"
  fi
}

install_windows_inputs() {
  local xwin
  local vs18_manifest
  local vs17_manifest
  local asan_archive
  local redist_archive
  xwin="${state_root}/tools/xwin-0.10.0-x86_64-unknown-linux-musl/xwin"
  vs18_manifest="${proof_dir}/$(json_value windows.vs18_manifest.path)"
  vs17_manifest="${proof_dir}/$(json_value windows.vs17_manifest.path)"
  verify_sha256 \
    "${vs18_manifest}" "$(json_value windows.vs18_manifest.sha256)"
  verify_sha256 \
    "${vs17_manifest}" "$(json_value windows.vs17_manifest.sha256)"
  if [[ ! -d "${state_root}/sysroot-v18-ms/crt/include" ]]; then
    "${xwin}" \
      --accept-license \
      --cache-dir "${state_root}/xwin-cache-v18" \
      --manifest "${vs18_manifest}" \
      --crt-version "$(json_value windows.vs18_manifest.crt_selector)" \
      --sdk-version "$(json_value windows.vs18_manifest.sdk_selector)" \
      splat --output "${state_root}/sysroot-v18-ms"
  fi
  if [[ ! -d "${state_root}/sysroot-v17-ms/sdk/include" ]]; then
    "${xwin}" \
      --accept-license \
      --cache-dir "${state_root}/xwin-cache-v17" \
      --manifest "${vs17_manifest}" \
      --crt-version "$(json_value windows.vs17_manifest.crt_selector)" \
      --sdk-version "$(json_value windows.vs17_manifest.sdk_selector)" \
      splat --output "${state_root}/sysroot-v17-ms"
  fi
  asan_archive="$(download_locked \
    Microsoft.VC.14.50.18.0.ASAN.X64.base.vsix \
    "$(json_value windows.asan.url)" \
    "$(json_value windows.asan.sha256)")"
  redist_archive="$(download_locked \
    Microsoft.VC.14.50.18.0.CRT.Redist.X64.base.vsix \
    "$(json_value windows.redist.url)" \
    "$(json_value windows.redist.sha256)")"
  if [[ ! -d "${state_root}/msvc-asan-14.50/Contents" ]]; then
    mkdir -p "${state_root}/msvc-asan-14.50"
    extract_zip "${asan_archive}" "${state_root}/msvc-asan-14.50"
  fi
  if [[ ! -d "${state_root}/redist-14.50/Contents" ]]; then
    mkdir -p "${state_root}/redist-14.50"
    extract_zip "${redist_archive}" "${state_root}/redist-14.50"
  fi
}

install_vcpkg() {
  local commit
  local rootfs_vcpkg=/opt/sacramento-state/vcpkg
  commit="$(json_value tools.vcpkg.commit)"
  if [[ ! -d "${state_root}/vcpkg/.git" ]]; then
    run_in_rootfs /usr/bin/git clone --filter=blob:none \
      "$(json_value tools.vcpkg.repository)" "${rootfs_vcpkg}"
  fi
  run_in_rootfs /usr/bin/git -C "${rootfs_vcpkg}" \
    fetch --depth 1 origin "${commit}"
  run_in_rootfs /usr/bin/git -C "${rootfs_vcpkg}" \
    checkout --detach "${commit}"
  run_in_rootfs "${rootfs_vcpkg}/bootstrap-vcpkg.sh" -disableMetrics
}

verify_packages() {
  while IFS=$'\t' read -r name expected; do
    local actual
    actual="$(run_in_rootfs /usr/bin/dpkg-query -W -f='${Version}' "${name}")"
    if [[ "${actual}" != "${expected}" ]]; then
      echo "package mismatch: ${name} expected ${expected}, found ${actual}" >&2
      exit 1
    fi
  done < <(python3 -c '
import json
import sys

packages = json.load(open(sys.argv[1], encoding="utf-8"))["ubuntu"]["packages"]
for name, version in sorted(packages.items()):
    print(f"{name}\t{version}")
' "${lock_file}")
}

verify() {
  local vs18_manifest="${proof_dir}/$(json_value windows.vs18_manifest.path)"
  local vs17_manifest="${proof_dir}/$(json_value windows.vs17_manifest.path)"
  test -x "${rootfs}/usr/lib/llvm-22/bin/clang-cl"
  test -x "${rootfs}/usr/lib/llvm-22/bin/lld-link"
  test -d "${state_root}/sysroot-v18-ms/crt/include"
  test -d "${state_root}/sysroot-v17-ms/sdk/include"
  test -x "${state_root}/vcpkg/vcpkg"
  verify_packages
  verify_sha256 \
    "${vs18_manifest}" "$(json_value windows.vs18_manifest.sha256)"
  verify_sha256 \
    "${vs17_manifest}" "$(json_value windows.vs17_manifest.sha256)"
  verify_sha256 \
    "${downloads}/Microsoft.VC.14.50.18.0.ASAN.X64.base.vsix" \
    "$(json_value windows.asan.sha256)"
  verify_sha256 \
    "${downloads}/Microsoft.VC.14.50.18.0.CRT.Redist.X64.base.vsix" \
    "$(json_value windows.redist.sha256)"
  verify_sha256 \
    "${state_root}/tools/sccache-0.16.0/sccache-v0.16.0-x86_64-unknown-linux-musl/sccache" \
    "$(json_value tools.sccache.binary_sha256)"
  verify_sha256 \
    "${state_root}/tools/xwin-0.10.0-x86_64-unknown-linux-musl/xwin" \
    "$(json_value tools.xwin.binary_sha256)"
  verify_sha256 \
    "${state_root}/vcpkg/vcpkg" \
    "$(json_value tools.vcpkg.binary_sha256)"
  if [[ "$(git -C "${state_root}/vcpkg" rev-parse HEAD)" != \
      "$(json_value tools.vcpkg.commit)" ]]; then
    echo "vcpkg registry commit mismatch" >&2
    exit 1
  fi
  echo "bootstrap verify: PASS"
}

seal() {
  verify
  mkdir -p "${state_root}/sealed"
  tar \
    --sort=name \
    --mtime='UTC 1970-01-01' \
    --owner=0 \
    --group=0 \
    --numeric-owner \
    --exclude='./tmp/*' \
    --exclude='./run/*' \
    --exclude='./var/cache/apt/*' \
    --exclude='./var/lib/apt/lists/*' \
    --exclude='./var/log/*' \
    -C "${rootfs}" \
    -cf "${state_root}/sealed/ubuntu-26.04-rootfs.tar" .
  local sealed_archive="${state_root}/sealed/ubuntu-26.04-rootfs.tar"
  local expected
  expected="$(json_value ubuntu.derived_rootfs_sha256)"
  verify_sha256 "${sealed_archive}" "${expected}"
  sha256sum "${sealed_archive}"
}

case "${1:-verify}" in
  install)
    require_command bwrap
    require_command curl
    require_command dpkg-deb
    require_command git
    require_command python3
    require_command sha256sum
    require_command tar
    install_rootfs
    install_tool_archives
    install_windows_inputs
    install_vcpkg
    verify
    ;;
  verify)
    require_command bwrap
    require_command python3
    require_command sha256sum
    verify
    ;;
  seal)
    require_command bwrap
    require_command python3
    require_command sha256sum
    require_command tar
    seal
    ;;
  *)
    echo "usage: $0 {install|verify|seal}" >&2
    exit 2
    ;;
esac
