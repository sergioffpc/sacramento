#!/usr/bin/env bash
set -euo pipefail

proof_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
state_root="${SACRAMENTO_CROSS_PROOF_ROOT:-/tmp/sacramento-cross-proof}"
rootfs="${state_root}/ubuntu-26.04"
llvm_root="${rootfs}/usr/lib/llvm-22"
vctools="${state_root}/sysroot-v18-ms/crt"
winsdk="${state_root}/sysroot-v17-ms/sdk"
vcpkg_root="${state_root}/vcpkg"
sccache_root="${state_root}/tools/sccache-0.16.0/sccache-v0.16.0-x86_64-unknown-linux-musl"
msvc_asan_root="${state_root}/msvc-asan-14.50/Contents/VC/Tools/MSVC/14.50.35717"
compiler_rt_windows_overlay="${state_root}/compiler-rt-windows-overlay"

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
  command -v wslpath >/dev/null
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
    "${state_root}/cache/sccache"
  mkdir -p \
    "${rootfs}/cache/sccache" \
    "${rootfs}/opt/sysroot-v18-ms" \
    "${rootfs}/opt/sysroot-v17-ms" \
    "${rootfs}/opt/vcpkg" \
    "${rootfs}/opt/sccache" \
    "${rootfs}/opt/msvc-asan" \
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
    --ro-bind "${compiler_rt_windows_overlay}" /usr/lib/llvm-22/lib/clang/22/lib/x86_64-pc-windows-msvc \
    --ro-bind "${proof_dir}" /src \
    --bind "${output_dir}" /out \
    /usr/bin/env -i \
      HOME=/tmp \
      PATH=/opt/sccache:/usr/lib/llvm-22/bin:/usr/bin:/bin \
      SACRAMENTO_LLVM_ROOT=/usr/lib/llvm-22 \
      SACRAMENTO_VCTOOLS_DIR=/opt/sysroot-v18-ms/crt \
      SACRAMENTO_WINSDK_DIR=/opt/sysroot-v17-ms/sdk \
      SCCACHE_DIR=/cache/sccache \
      VCPKG_ROOT=/opt/vcpkg \
      VCPKG_DEFAULT_BINARY_CACHE=/opt/vcpkg/bincache \
      "$@"
}

build() {
  build_dir="${state_root}/replay/cmake"
  run_in_build_root "${build_dir}" \
    /usr/bin/cmake \
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
      -Xlinker /LIBPATH:/opt/sysroot-v18-ms/crt/lib/x64 \
      -Xlinker /LIBPATH:/opt/sysroot-v17-ms/sdk/lib/ucrt/x64 \
      -Xlinker /LIBPATH:/opt/sysroot-v17-ms/sdk/lib/um/x64 \
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

asan() {
  local build_dir="${state_root}/replay/asan"
  local windows_dir="/mnt/c/Temp/sacramento-cross-proof-asan"
  local redist_dir="${state_root}/redist-14.50/Contents/VC/Redist/MSVC/14.50.35710/x64/Microsoft.VC145.CRT"
  mkdir -p "${build_dir}" "${windows_dir}"
  compile_asan_probe probes/expected.cc expected_asan
  compile_asan_probe probes/asan_fault.cc asan_fault
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
  all)
    preflight
    build
    inspect
    run_windows
    asan
    ;;
  *)
    echo "usage: $0 {preflight|build|inspect|run-windows|asan|all}" >&2
    exit 2
    ;;
esac
