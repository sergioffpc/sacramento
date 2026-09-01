#!/usr/bin/env bash
set -euo pipefail

proof_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
repo_root="$(cd "${proof_dir}/../.." && pwd)"
state_root="${SACRAMENTO_CROSS_PROOF_ROOT:-/tmp/sacramento-cpp-baseline-002}"
rootfs="${state_root}/ubuntu-26.04"
llvm_root="${rootfs}/usr/lib/llvm-22"
vctools="${state_root}/sysroot-v18-ms/crt"
winsdk="${state_root}/sysroot-v17-ms/sdk"
vcpkg_root="${state_root}/vcpkg"
sccache_root="${state_root}/tools/sccache-0.16.0/sccache-v0.16.0-x86_64-unknown-linux-musl"
msvc_asan_root="${state_root}/msvc-asan-14.50/Contents/VC/Tools/MSVC/14.50.35717"
compiler_rt_windows_overlay="${state_root}/compiler-rt-windows-overlay"
debian_sysroot="${state_root}/debian-13.6-sysroot"

require_path() {
  if [[ ! -e "$1" ]]; then
    echo "missing prototype input: $1" >&2
    exit 2
  fi
}

preflight() {
  mkdir -p "${compiler_rt_windows_overlay}"
  cp \
    "${msvc_asan_root}/lib/x64/clang_rt.asan_dynamic-x86_64.lib" \
    "${compiler_rt_windows_overlay}/clang_rt.asan_dynamic.lib"
  cp \
    "${msvc_asan_root}/lib/x64/clang_rt.asan_dynamic_runtime_thunk-x86_64.lib" \
    "${compiler_rt_windows_overlay}/clang_rt.asan_dynamic_runtime_thunk.lib"
  command -v bwrap >/dev/null
  for path in \
      "${rootfs}" \
      "${llvm_root}/bin/clang-cl" \
      "${llvm_root}/bin/lld-link" \
      "${rootfs}/usr/bin/cmake" \
      "${rootfs}/usr/bin/ninja" \
      "${sccache_root}/sccache" \
      "${msvc_asan_root}/lib/x64/clang_rt.asan_dynamic-x86_64.lib" \
      "${msvc_asan_root}/lib/x64/stl_asan.lib" \
      "${msvc_asan_root}/bin/Hostx64/x64/clang_rt.asan_dynamic-x86_64.dll" \
      "${vctools}/include" \
      "${winsdk}/include" \
      "${debian_sysroot}/usr/include/c++/14" \
      "${debian_sysroot}/usr/lib/x86_64-linux-gnu/libstdc++.so.6" \
      "${vcpkg_root}/vcpkg"; do
    require_path "${path}"
  done
  echo "preflight: PASS"
}

run_in_build_root() {
  local output_dir="$1"
  shift
  mkdir -p \
    "${output_dir}" \
    "${state_root}/build/container-tmp" \
    "${state_root}/cache/sccache" \
    "${vcpkg_root}/bincache"
  mkdir -p \
    "${rootfs}/cache/sccache" \
    "${rootfs}/opt/sysroot-v18-ms" \
    "${rootfs}/opt/sysroot-v17-ms" \
    "${rootfs}/opt/vcpkg" \
    "${rootfs}/opt/sccache" \
    "${rootfs}/opt/msvc-asan" \
    "${rootfs}/opt/debian-13.6" \
    "${rootfs}/repo" \
    "${rootfs}/usr/lib/llvm-22/lib/clang/22/lib/x86_64-pc-windows-msvc" \
    "${rootfs}/src" \
    "${rootfs}/out"
  bwrap \
    --ro-bind "${rootfs}" / \
    --proc /proc \
    --dev /dev \
    --ro-bind /etc/resolv.conf /etc/resolv.conf \
    --bind "${state_root}/build/container-tmp" /tmp \
    --bind "${state_root}/cache/sccache" /cache/sccache \
    --ro-bind "${state_root}/sysroot-v18-ms" /opt/sysroot-v18-ms \
    --ro-bind "${state_root}/sysroot-v17-ms" /opt/sysroot-v17-ms \
    --bind "${vcpkg_root}" /opt/vcpkg \
    --ro-bind "${sccache_root}" /opt/sccache \
    --ro-bind "${msvc_asan_root}" /opt/msvc-asan \
    --ro-bind "${debian_sysroot}" /opt/debian-13.6 \
    --ro-bind "${compiler_rt_windows_overlay}" /usr/lib/llvm-22/lib/clang/22/lib/x86_64-pc-windows-msvc \
    --ro-bind "${proof_dir}" /src \
    --ro-bind "${repo_root}" /repo \
    --bind "${output_dir}" /out \
    /usr/bin/env -i \
      HOME=/tmp \
      PATH=/opt/sccache:/usr/lib/llvm-22/bin:/usr/bin:/bin \
      SACRAMENTO_LLVM_ROOT=/usr/lib/llvm-22 \
      SACRAMENTO_VCTOOLS_DIR=/opt/sysroot-v18-ms/crt \
      SACRAMENTO_WINSDK_DIR=/opt/sysroot-v17-ms/sdk \
      SACRAMENTO_DEBIAN_SYSROOT=/opt/debian-13.6 \
      SCCACHE_DIR=/cache/sccache \
      VCPKG_ROOT=/opt/vcpkg \
      VCPKG_DEFAULT_BINARY_CACHE=/opt/vcpkg/bincache \
      "$@"
}

validate_root_definitions() {
  run_in_build_root "${state_root}/root-config/debian" \
    /usr/bin/cmake --list-presets -S /repo
  for triplet in x64-debian-cross-clang x64-windows-cross-clang; do
    run_in_build_root "${state_root}/root-config/debian" \
      /usr/bin/cmake -E chdir /repo \
        /opt/vcpkg/vcpkg install \
          --dry-run \
          --x-install-root=/out/vcpkg_installed \
          "--triplet=${triplet}" \
          --overlay-triplets=/repo/triplets
  done
  run_in_build_root "${state_root}/root-config/debian" \
    /usr/bin/cmake \
      --fresh \
      -S /repo \
      -B /out \
      -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_MAKE_PROGRAM=/usr/bin/ninja \
      -DCMAKE_TOOLCHAIN_FILE=/repo/cmake/toolchains/debian-cross-clang.cmake
  run_in_build_root "${state_root}/root-config/windows" \
    /usr/bin/cmake \
      --fresh \
      -S /repo \
      -B /out \
      -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_MAKE_PROGRAM=/usr/bin/ninja \
      -DCMAKE_TOOLCHAIN_FILE=/repo/cmake/toolchains/windows-cross-clang.cmake
  echo "root C++ definitions: PASS"
}

build() {
  build_dir="${state_root}/replay/cmake"
  run_in_build_root "${build_dir}" /opt/sccache/sccache --stop-server || true
  run_in_build_root "${build_dir}" /opt/sccache/sccache --zero-stats
  run_in_build_root "${build_dir}" \
    /usr/bin/cmake \
      --fresh \
      -S /src \
      -B /out \
      -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_MAKE_PROGRAM=/usr/bin/ninja \
      -DCMAKE_C_COMPILER_LAUNCHER=/opt/sccache/sccache \
      -DCMAKE_CXX_COMPILER_LAUNCHER=/opt/sccache/sccache \
      -DCMAKE_TOOLCHAIN_FILE=/opt/vcpkg/scripts/buildsystems/vcpkg.cmake \
      -DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=/src/cmake/toolchains/windows-cross-clang.cmake \
      -DVCPKG_TARGET_TRIPLET=x64-windows-cross-clang \
      -DVCPKG_OVERLAY_TRIPLETS=/src/triplets
  run_in_build_root "${build_dir}" \
    /usr/bin/cmake --build /out --verbose
  local first_app_hash
  local first_app_pdb_hash
  first_app_hash="$(sha256sum "${build_dir}/proof_app.exe" | cut -d ' ' -f 1)"
  first_app_pdb_hash="$(sha256sum "${build_dir}/proof_app.pdb" | cut -d ' ' -f 1)"
  run_in_build_root "${build_dir}" \
    /usr/bin/cmake --build /out --target clean
  run_in_build_root "${build_dir}" \
    /usr/bin/cmake --build /out --verbose
  if [[ "${first_app_hash}" != "$(sha256sum "${build_dir}/proof_app.exe" | cut -d ' ' -f 1)" ]] ||
      [[ "${first_app_pdb_hash}" != "$(sha256sum "${build_dir}/proof_app.pdb" | cut -d ' ' -f 1)" ]]; then
    echo "clean replay did not reproduce the application EXE/PDB" >&2
    exit 1
  fi
  local cache_stats
  cache_stats="$(run_in_build_root "${build_dir}" /opt/sccache/sccache --show-stats)"
  printf '%s\n' "${cache_stats}"
  if ! grep -Eq 'Cache hits[[:space:]]+[1-9][0-9]*' <<<"${cache_stats}"; then
    echo "local compiler cache produced no hits" >&2
    exit 1
  fi
  echo "build: PASS"
}

inspect() {
  local build_dir="${state_root}/replay/cmake"
  require_path "${build_dir}/proof_app.exe"
  require_path "${build_dir}/proof_app.pdb"
  local inspection
  inspection="$(run_in_build_root "${build_dir}" \
    /usr/lib/llvm-22/bin/llvm-readobj \
      --file-headers \
      --coff-debug-directory \
      --coff-load-config \
      /out/proof_app.exe)"
  for required in \
      IMAGE_FILE_MACHINE_AMD64 \
      IMAGE_DLL_CHARACTERISTICS_DYNAMIC_BASE \
      IMAGE_DLL_CHARACTERISTICS_GUARD_CF \
      IMAGE_DLL_CHARACTERISTICS_HIGH_ENTROPY_VA \
      IMAGE_DLL_CHARACTERISTICS_NX_COMPAT \
      CF_FUNCTION_TABLE_PRESENT \
      CF_INSTRUMENTED \
      'Type: CodeView' \
      'Type: Repro'; do
    if ! grep -Fq "${required}" <<<"${inspection}"; then
      echo "missing PE/PDB property: ${required}" >&2
      exit 1
    fi
  done
  printf '%s\n' "${inspection}" | grep -E \
    'Machine:|IMAGE_DLL_CHARACTERISTICS_|CF_FUNCTION_TABLE_PRESENT|CF_INSTRUMENTED|Type: (CodeView|Repro)'
  sha256sum \
    "${build_dir}/proof_app.exe" \
    "${build_dir}/proof_app.pdb" \
    "${build_dir}/proof_tests.exe" \
    "${build_dir}/proof_tests.pdb"
  echo "inspect: PASS"
}

run_windows() {
  command -v wslpath >/dev/null
  local build_dir="${state_root}/replay/cmake"
  local windows_dir="/mnt/c/Temp/sacramento-cross-proof-replay"
  local redist_dir="${state_root}/redist-14.50/Contents/VC/Redist/MSVC/14.50.35710/x64/Microsoft.VC145.CRT"
  require_path "${build_dir}/proof_app.exe"
  require_path "${build_dir}/proof_tests.exe"
  require_path "${redist_dir}/msvcp140.dll"
  mkdir -p "${windows_dir}"
  cp \
    "${build_dir}/proof_app.exe" \
    "${build_dir}/proof_tests.exe" \
    "${redist_dir}/msvcp140.dll" \
    "${redist_dir}/vcruntime140.dll" \
    "${redist_dir}/vcruntime140_1.dll" \
    "${windows_dir}/"
  /mnt/c/Windows/System32/cmd.exe /d /v:on /c \
    "C:\\Temp\\sacramento-cross-proof-replay\\proof_app.exe && C:\\Temp\\sacramento-cross-proof-replay\\proof_tests.exe & set proof_exit=!ERRORLEVEL! & echo EXIT:!proof_exit! & exit /b !proof_exit!"
  echo "windows execution: PASS"
}

compile_asan_probe() {
  local source="$1"
  local output="$2"
  local build_dir="${state_root}/replay/asan"
  run_in_build_root "${build_dir}" \
    /usr/lib/llvm-22/bin/clang-cl \
      --target=x86_64-pc-windows-msvc \
      -imsvc/opt/sysroot-v18-ms/crt/include \
      -imsvc/opt/sysroot-v17-ms/sdk/include/ucrt \
      -imsvc/opt/sysroot-v17-ms/sdk/include/shared \
      -imsvc/opt/sysroot-v17-ms/sdk/include/um \
      -imsvc/opt/sysroot-v17-ms/sdk/include/winrt \
      -imsvc/opt/sysroot-v17-ms/sdk/include/cppwinrt \
      -fuse-ld=lld \
      -fsanitize=address \
      -Xlinker /LIBPATH:/opt/sysroot-v18-ms/crt/lib/x86_64 \
      -Xlinker /LIBPATH:/opt/sysroot-v17-ms/sdk/lib/ucrt/x86_64 \
      -Xlinker /LIBPATH:/opt/sysroot-v17-ms/sdk/lib/um/x86_64 \
      -Xlinker /LIBPATH:/opt/msvc-asan/lib/x64 \
      /std:c++23preview \
      /EHsc \
      /MD \
      /Od \
      /Zi \
      /W4 \
      /WX \
      /permissive- \
      "/Fe/out/${output}.exe" \
      "/Fd/out/${output}.pdb" \
      "/src/${source}"
}

build_asan() {
  local build_dir="${state_root}/replay/asan"
  mkdir -p "${build_dir}"
  compile_asan_probe probes/expected.cc expected_asan
  compile_asan_probe probes/asan_fault.cc asan_fault
  echo "build ASan: PASS"
}

stage_windows_artifacts() {
  local build_dir="${state_root}/replay/cmake"
  local asan_dir="${state_root}/replay/asan"
  local artifact_dir="${state_root}/artifacts/windows"
  local redist_dir="${state_root}/redist-14.50/Contents/VC/Redist/MSVC/14.50.35710/x64/Microsoft.VC145.CRT"
  mkdir -p "${artifact_dir}"
  cp \
    "${build_dir}/proof_app.exe" \
    "${build_dir}/proof_app.pdb" \
    "${build_dir}/proof_tests.exe" \
    "${build_dir}/proof_tests.pdb" \
    "${asan_dir}/expected_asan.exe" \
    "${asan_dir}/expected_asan.pdb" \
    "${asan_dir}/asan_fault.exe" \
    "${asan_dir}/asan_fault.pdb" \
    "${msvc_asan_root}/bin/Hostx64/x64/clang_rt.asan_dynamic-x86_64.dll" \
    "${redist_dir}/msvcp140.dll" \
    "${redist_dir}/vcruntime140.dll" \
    "${redist_dir}/vcruntime140_1.dll" \
    "${artifact_dir}/"
  (
    cd "${artifact_dir}"
    sha256sum \
      proof_app.exe proof_app.pdb proof_tests.exe proof_tests.pdb \
      expected_asan.exe expected_asan.pdb asan_fault.exe asan_fault.pdb \
      clang_rt.asan_dynamic-x86_64.dll \
      msvcp140.dll vcruntime140.dll vcruntime140_1.dll \
      >SHA256SUMS
  )
  echo "stage Windows artifacts: PASS"
}

asan() {
  command -v wslpath >/dev/null
  local build_dir="${state_root}/replay/asan"
  local windows_dir="/mnt/c/Temp/sacramento-cross-proof-asan"
  local redist_dir="${state_root}/redist-14.50/Contents/VC/Redist/MSVC/14.50.35710/x64/Microsoft.VC145.CRT"
  mkdir -p "${windows_dir}"
  build_asan
  cp \
    "${build_dir}/expected_asan.exe" \
    "${build_dir}/asan_fault.exe" \
    "${msvc_asan_root}/bin/Hostx64/x64/clang_rt.asan_dynamic-x86_64.dll" \
    "${redist_dir}/msvcp140.dll" \
    "${redist_dir}/vcruntime140.dll" \
    "${redist_dir}/vcruntime140_1.dll" \
    "${windows_dir}/"
  /mnt/c/Windows/System32/cmd.exe /d /c \
    "set \"ASAN_OPTIONS=exitcode=3\"&& C:\\Temp\\sacramento-cross-proof-asan\\expected_asan.exe"
  set +e
  local asan_output
  asan_output="$(/mnt/c/Windows/System32/cmd.exe /d /c \
    "set \"ASAN_OPTIONS=exitcode=3\"&& C:\\Temp\\sacramento-cross-proof-asan\\asan_fault.exe" 2>&1)"
  local asan_exit=$?
  set -e
  printf '%s\n' "${asan_output}"
  echo "ASan negative exit: ${asan_exit}"
  if [[ ${asan_exit} -eq 0 ]] || ! grep -Fq 'heap-buffer-overflow' <<<"${asan_output}"; then
    echo "Windows ASan negative probe did not fail as expected" >&2
    exit 1
  fi
  echo "asan: PASS"
}

postprocess_debian_symbols() {
  local build_dir="$1"
  for binary in proof_app proof_tests; do
    run_in_build_root "${build_dir}" \
      /usr/lib/llvm-22/bin/llvm-objcopy \
        --only-keep-debug "/out/${binary}" "/out/${binary}.debug"
    run_in_build_root "${build_dir}" \
      /usr/lib/llvm-22/bin/llvm-strip --strip-debug "/out/${binary}"
    run_in_build_root "${build_dir}" \
      /usr/lib/llvm-22/bin/llvm-objcopy \
        "--add-gnu-debuglink=/out/${binary}.debug" "/out/${binary}"
  done
}

build_debian() {
  local build_dir="${state_root}/replay/debian-cmake"
  run_in_build_root "${build_dir}" /opt/sccache/sccache --stop-server || true
  run_in_build_root "${build_dir}" /opt/sccache/sccache --zero-stats
  run_in_build_root "${build_dir}" \
    /usr/bin/cmake \
      --fresh \
      -S /src \
      -B /out \
      -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_MAKE_PROGRAM=/usr/bin/ninja \
      -DCMAKE_C_COMPILER_LAUNCHER=/opt/sccache/sccache \
      -DCMAKE_CXX_COMPILER_LAUNCHER=/opt/sccache/sccache \
      -DCMAKE_TOOLCHAIN_FILE=/opt/vcpkg/scripts/buildsystems/vcpkg.cmake \
      -DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=/src/cmake/toolchains/debian-cross-clang.cmake \
      -DVCPKG_TARGET_TRIPLET=x64-debian-cross-clang \
      -DVCPKG_OVERLAY_TRIPLETS=/src/triplets
  run_in_build_root "${build_dir}" /usr/bin/cmake --build /out --verbose
  postprocess_debian_symbols "${build_dir}"
  local first_app_hash
  local first_debug_hash
  first_app_hash="$(sha256sum "${build_dir}/proof_app" | cut -d ' ' -f 1)"
  first_debug_hash="$(sha256sum "${build_dir}/proof_app.debug" | cut -d ' ' -f 1)"
  run_in_build_root "${build_dir}" /usr/bin/cmake --build /out --target clean
  run_in_build_root "${build_dir}" /usr/bin/cmake --build /out --verbose
  postprocess_debian_symbols "${build_dir}"
  if [[ "${first_app_hash}" != \
      "$(sha256sum "${build_dir}/proof_app" | cut -d ' ' -f 1)" ]] ||
      [[ "${first_debug_hash}" != \
      "$(sha256sum "${build_dir}/proof_app.debug" | cut -d ' ' -f 1)" ]]; then
    echo "Debian clean replay did not reproduce ELF/debug output" >&2
    exit 1
  fi
  local cache_stats
  cache_stats="$(run_in_build_root "${build_dir}" \
    /opt/sccache/sccache --show-stats)"
  printf '%s\n' "${cache_stats}"
  if ! grep -Eq 'Cache hits[[:space:]]+[1-9][0-9]*' <<<"${cache_stats}"; then
    echo "Debian compiler replay produced no local cache hits" >&2
    exit 1
  fi
  echo "Debian build: PASS"
}

inspect_debian() {
  local build_dir="${state_root}/replay/debian-cmake"
  local inspection
  inspection="$(run_in_build_root "${build_dir}" \
    /usr/lib/llvm-22/bin/llvm-readelf \
      --file-header --program-headers --dynamic-table --notes \
      /out/proof_app)"
  for required in \
      'Class:                             ELF64' \
      'Type:                              DYN' \
      'Requesting program interpreter: /lib64/ld-linux-x86-64.so.2' \
      'GNU_RELRO' \
      'BIND_NOW' \
      'Build ID:' \
      'Shared library: [libstdc++.so.6]'; do
    if ! grep -Fq "${required}" <<<"${inspection}"; then
      echo "missing Debian ELF property: ${required}" >&2
      exit 1
    fi
  done
  if ! grep -E 'GNU_STACK.*RW[[:space:]]' <<<"${inspection}" >/dev/null; then
    echo "Debian ELF stack is not explicitly non-executable" >&2
    exit 1
  fi
  printf '%s\n' "${inspection}" | grep -E \
    'Class:|Type:|interpreter:|GNU_RELRO|GNU_STACK|BIND_NOW|Build ID:|Shared library:'
  sha256sum \
    "${build_dir}/proof_app" "${build_dir}/proof_app.debug" \
    "${build_dir}/proof_tests" "${build_dir}/proof_tests.debug"
  echo "Debian inspect: PASS"
}

run_in_debian_target() {
  local output_dir="$1"
  shift
  bwrap \
    --ro-bind "${debian_sysroot}" / \
    --proc /proc \
    --dev /dev \
    --ro-bind "${output_dir}" /tmp \
    --clearenv \
    --setenv HOME /tmp \
    --setenv UBSAN_OPTIONS halt_on_error=1 \
    "$@"
}

run_debian() {
  local build_dir="${state_root}/replay/debian-cmake"
  run_in_debian_target "${build_dir}" /tmp/proof_app
  run_in_debian_target "${build_dir}" /tmp/proof_tests
  echo "Debian execution: PASS"
}

debian_sanitizers() {
  local build_dir="${state_root}/replay/debian-sanitizers"
  mkdir -p "${build_dir}"
  for probe in expected asan_fault ubsan_fault; do
    run_in_build_root "${build_dir}" \
      /usr/lib/llvm-22/bin/clang++ \
        --target=x86_64-linux-gnu \
        --sysroot=/opt/debian-13.6 \
        --gcc-toolchain=/opt/debian-13.6 \
        -fuse-ld=lld \
        -std=c++23 \
        -O1 \
        -g \
        -Wall \
        -Wextra \
        -Wpedantic \
        -Werror \
        -fsanitize=address,undefined \
        -fno-omit-frame-pointer \
        "-ffile-prefix-map=/src=." \
        "-fdebug-prefix-map=/src=." \
        "/src/probes/${probe}.cc" \
        -o "/out/${probe}"
  done
  run_in_debian_target "${build_dir}" /tmp/expected
  set +e
  local sanitizer_output
  sanitizer_output="$(run_in_debian_target \
    "${build_dir}" /tmp/asan_fault 2>&1)"
  local sanitizer_exit=$?
  set -e
  printf '%s\n' "${sanitizer_output}"
  if [[ ${sanitizer_exit} -eq 0 ]] ||
      ! grep -Fq 'heap-buffer-overflow' <<<"${sanitizer_output}"; then
    echo "Debian ASan+UBSan negative probe did not fail as expected" >&2
    exit 1
  fi
  set +e
  local ubsan_output
  ubsan_output="$(run_in_debian_target \
    "${build_dir}" /tmp/ubsan_fault 2>&1)"
  local ubsan_exit=$?
  set -e
  printf '%s\n' "${ubsan_output}"
  if [[ ${ubsan_exit} -eq 0 ]] ||
      ! grep -Fq 'runtime error: signed integer overflow' <<<"${ubsan_output}"; then
    echo "Debian UBSan negative probe did not fail as expected" >&2
    exit 1
  fi
  echo "Debian ASan+UBSan: PASS"
}

stage_debian_artifacts() {
  local build_dir="${state_root}/replay/debian-cmake"
  local sanitizer_dir="${state_root}/replay/debian-sanitizers"
  local artifact_dir="${state_root}/artifacts/debian"
  mkdir -p "${artifact_dir}"
  cp \
    "${build_dir}/proof_app" \
    "${build_dir}/proof_app.debug" \
    "${build_dir}/proof_tests" \
    "${build_dir}/proof_tests.debug" \
    "${sanitizer_dir}/expected" \
    "${sanitizer_dir}/asan_fault" \
    "${sanitizer_dir}/ubsan_fault" \
    "${artifact_dir}/"
  (
    cd "${artifact_dir}"
    sha256sum \
      proof_app proof_app.debug proof_tests proof_tests.debug \
      expected asan_fault ubsan_fault >SHA256SUMS
  )
  echo "Debian package: ${artifact_dir}"
}

debian() {
  build_debian
  inspect_debian
  run_debian
  debian_sanitizers
  stage_debian_artifacts
}

case "${1:-all}" in
  preflight)
    preflight
    ;;
  build)
    preflight
    build
    ;;
  inspect)
    preflight
    inspect
    ;;
  run-windows)
    preflight
    run_windows
    ;;
  asan)
    preflight
    asan
    ;;
  build-asan)
    preflight
    build_asan
    ;;
  package-windows)
    preflight
    stage_windows_artifacts
    ;;
  root-config)
    preflight
    validate_root_definitions
    ;;
  debian)
    preflight
    debian
    ;;
  all)
    preflight
    build
    inspect
    run_windows
    asan
    ;;
  *)
    echo "usage: $0 {preflight|root-config|build|inspect|run-windows|build-asan|package-windows|asan|debian|all}" >&2
    exit 2
    ;;
esac
