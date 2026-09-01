#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
lock_file="${repo_root}/config/cpp/bootstrap-lock.json"
debian_lock_file="${repo_root}/config/cpp/debian-sysroot-lock.json"
state_root="${SACRAMENTO_CPP_TOOLCHAIN_ROOT:-/var/tmp/sacramento-cpp-baseline-002}"
downloads="${state_root}/downloads"
rootfs="${state_root}/ubuntu-26.04"
debian_sysroot="${state_root}/debian-13.6-sysroot"
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

debian_json_value() {
  python3 -c '
import json
import sys

value = json.load(open(sys.argv[1], encoding="utf-8"))
for component in sys.argv[2].split("."):
    value = value[component]
print(value)
' "${debian_lock_file}" "$1"
}

require_command() {
  if ! command -v "$1" >/dev/null; then
    echo "missing host command: $1" >&2
    exit 2
  fi
}

require_install_space() {
  local minimum_bytes=$((12 * 1024 * 1024 * 1024))
  local available_bytes
  mkdir -p "${state_root}"
  available_bytes="$(df --output=avail --block-size=1 "${state_root}" | tail -n 1)"
  if (( available_bytes < minimum_bytes )); then
    echo "insufficient space for toolchain bootstrap at ${state_root}" >&2
    echo "at least 12 GiB free is required; found $((available_bytes / 1024 / 1024 / 1024)) GiB" >&2
    echo "set SACRAMENTO_CPP_TOOLCHAIN_ROOT to a filesystem with sufficient space" >&2
    exit 1
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
    --ro-bind "${repo_root}" /opt/sacramento-repo \
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
      "${repo_root}/config/cpp/ubuntu-snapshot.sources"; then
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
    -o Dir::Etc::sourcelist=/opt/sacramento-repo/config/cpp/ubuntu-snapshot.sources \
    -o Dir::Etc::sourceparts=- \
    -o APT::Update::Error-Mode=any \
    update
  run_in_rootfs /usr/bin/apt-get \
    "${apt_ca_options[@]}" \
    -o APT::Sandbox::User=root \
    -o Dir::Etc::sourcelist=/opt/sacramento-repo/config/cpp/ubuntu-snapshot.sources \
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
  vs18_manifest="${repo_root}/$(json_value windows.vs18_manifest.path)"
  vs17_manifest="${repo_root}/$(json_value windows.vs17_manifest.path)"
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

install_debian_inputs() {
  local repository
  local inrelease
  local packages_index
  repository="$(debian_json_value repository)"
  inrelease="$(download_locked \
    debian-13.6-InRelease \
    "${repository}/dists/trixie/InRelease" \
    "$(debian_json_value inrelease_sha256)")"
  packages_index="$(download_locked \
    debian-13.6-Packages.xz \
    "${repository}/dists/trixie/main/binary-amd64/Packages.xz" \
    "$(debian_json_value packages_index_sha256)")"
  mkdir -p \
    "${debian_sysroot}" \
    "${debian_sysroot}/dev" \
    "${debian_sysroot}/proc" \
    "${debian_sysroot}/tmp"
  while IFS=$'\t' read -r name version path expected; do
    local archive
    archive="$(download_locked \
      "debian-${name}.deb" \
      "${repository}/${path}" \
      "${expected}")"
    if [[ "$(dpkg-deb --field "${archive}" Package)" != "${name}" ]] ||
        [[ "$(dpkg-deb --field "${archive}" Version)" != "${version}" ]]; then
      echo "Debian package metadata mismatch: ${name}" >&2
      exit 1
    fi
    dpkg-deb -x "${archive}" "${debian_sysroot}"
  done < <(python3 -c '
import json
import sys

packages = json.load(open(sys.argv[1], encoding="utf-8"))["packages"]
for name, (version, path, digest) in sorted(packages.items()):
    print(f"{name}\t{version}\t{path}\t{digest}")
' "${debian_lock_file}")
  if [[ ! -e "${debian_sysroot}/lib" ]]; then
    ln -s usr/lib "${debian_sysroot}/lib"
  fi
  if [[ ! -e "${debian_sysroot}/lib64" ]]; then
    ln -s usr/lib64 "${debian_sysroot}/lib64"
  fi
  gpgv \
    --keyring "${debian_sysroot}/usr/share/keyrings/debian-archive-keyring.gpg" \
    "${inrelease}"
  verify_sha256 "${packages_index}" \
    "$(debian_json_value packages_index_sha256)"
}

verify_debian_inputs() {
  test -e "${debian_sysroot}/lib64/ld-linux-x86-64.so.2"
  test -e "${debian_sysroot}/usr/include/c++/14/version"
  test -e "${debian_sysroot}/usr/lib/x86_64-linux-gnu/libstdc++.so.6"
  test -x "${debian_sysroot}/usr/bin/x86_64-linux-gnu-ld.bfd"
  verify_sha256 "${downloads}/debian-13.6-InRelease" \
    "$(debian_json_value inrelease_sha256)"
  verify_sha256 "${downloads}/debian-13.6-Packages.xz" \
    "$(debian_json_value packages_index_sha256)"
  while IFS=$'\t' read -r name version expected; do
    local archive="${downloads}/debian-${name}.deb"
    verify_sha256 "${archive}" "${expected}"
    if [[ "$(dpkg-deb --field "${archive}" Version)" != "${version}" ]]; then
      echo "Debian package version mismatch: ${name}" >&2
      exit 1
    fi
  done < <(python3 -c '
import json
import sys

packages = json.load(open(sys.argv[1], encoding="utf-8"))["packages"]
for name, (version, _, digest) in sorted(packages.items()):
    print(f"{name}\t{version}\t{digest}")
' "${debian_lock_file}")
  gpgv \
    --keyring "${debian_sysroot}/usr/share/keyrings/debian-archive-keyring.gpg" \
    "${downloads}/debian-13.6-InRelease" >/dev/null
}

verify_packages() {
  while IFS=$'\t' read -r name expected; do
    local actual
    if ! actual="$(run_in_rootfs \
        /usr/bin/dpkg-query -W -f='${Version}' "${name}" 2>/dev/null)"; then
      echo "bootstrap state is incompatible: missing Ubuntu package ${name}" >&2
      echo "materialize a fresh state with a new SACRAMENTO_CPP_TOOLCHAIN_ROOT" >&2
      exit 1
    fi
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
  local vs18_manifest="${repo_root}/$(json_value windows.vs18_manifest.path)"
  local vs17_manifest="${repo_root}/$(json_value windows.vs17_manifest.path)"
  if [[ ! -x "${rootfs}/usr/lib/llvm-22/bin/clang-cl" ]]; then
    echo "bootstrap state is not materialized at ${state_root}" >&2
    echo "run scripts/cpp-toolchain-bootstrap.sh install first" >&2
    exit 1
  fi
  test -x "${rootfs}/usr/lib/llvm-22/bin/clang-cl"
  test -x "${rootfs}/usr/lib/llvm-22/bin/lld-link"
  test -d "${state_root}/sysroot-v18-ms/crt/include"
  test -d "${state_root}/sysroot-v17-ms/sdk/include"
  test -x "${state_root}/vcpkg/vcpkg"
  verify_packages
  verify_debian_inputs
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
    --exclude='./cache' \
    --exclude='./out' \
    --exclude='./repo' \
    --exclude='./src' \
    --exclude='./opt/debian-13.6' \
    --exclude='./opt/msvc-asan' \
    --exclude='./opt/sacramento-proof' \
    --exclude='./opt/sacramento-repo' \
    --exclude='./opt/sacramento-state' \
    --exclude='./opt/sccache' \
    --exclude='./opt/sysroot-v17-ms' \
    --exclude='./opt/sysroot-v18-ms' \
    --exclude='./opt/vcpkg' \
    --exclude='./usr/lib/llvm-22/lib/clang/22/lib/x86_64-pc-windows-msvc' \
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

  tar \
    --sort=name \
    --mtime='UTC 1970-01-01' \
    --owner=0 \
    --group=0 \
    --numeric-owner \
    --exclude='./tmp/*' \
    -C "${debian_sysroot}" \
    -cf "${state_root}/sealed/debian-13.6-sysroot.tar" .
  sealed_archive="${state_root}/sealed/debian-13.6-sysroot.tar"
  expected="$(debian_json_value derived_sysroot_sha256)"
  verify_sha256 "${sealed_archive}" "${expected}"
  sha256sum "${sealed_archive}"
}

case "${1:-verify}" in
  install)
    require_command bwrap
    require_command curl
    require_command dpkg-deb
    require_command git
    require_command gpgv
    require_command python3
    require_command sha256sum
    require_command tar
    require_install_space
    install_rootfs
    install_tool_archives
    install_windows_inputs
    install_vcpkg
    install_debian_inputs
    verify
    ;;
  verify)
    require_command bwrap
    require_command dpkg-deb
    require_command gpgv
    require_command python3
    require_command sha256sum
    verify
    ;;
  seal)
    require_command bwrap
    require_command dpkg-deb
    require_command gpgv
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
