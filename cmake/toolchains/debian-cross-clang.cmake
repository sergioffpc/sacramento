set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR x86_64)

foreach(variable IN ITEMS SACRAMENTO_LLVM_ROOT SACRAMENTO_DEBIAN_SYSROOT)
  if(NOT DEFINED ENV{${variable}} OR "$ENV{${variable}}" STREQUAL "")
    message(FATAL_ERROR "${variable} must identify a pinned input")
  endif()
endforeach()

set(CMAKE_SYSROOT "$ENV{SACRAMENTO_DEBIAN_SYSROOT}")
set(CMAKE_C_COMPILER "$ENV{SACRAMENTO_LLVM_ROOT}/bin/clang")
set(CMAKE_CXX_COMPILER "$ENV{SACRAMENTO_LLVM_ROOT}/bin/clang++")
set(CMAKE_LINKER "$ENV{SACRAMENTO_LLVM_ROOT}/bin/ld.lld")
set(CMAKE_AR "$ENV{SACRAMENTO_LLVM_ROOT}/bin/llvm-ar")
set(CMAKE_RANLIB "$ENV{SACRAMENTO_LLVM_ROOT}/bin/llvm-ranlib")
set(CMAKE_OBJCOPY "$ENV{SACRAMENTO_LLVM_ROOT}/bin/llvm-objcopy")
set(CMAKE_STRIP "$ENV{SACRAMENTO_LLVM_ROOT}/bin/llvm-strip")

set(_sacramento_driver_flags
    "--target=x86_64-linux-gnu --gcc-toolchain=$ENV{SACRAMENTO_DEBIAN_SYSROOT}")
set(CMAKE_C_FLAGS_INIT "${_sacramento_driver_flags}")
set(CMAKE_CXX_FLAGS_INIT "${_sacramento_driver_flags}")
set(CMAKE_EXE_LINKER_FLAGS_INIT "-fuse-ld=lld")
set(CMAKE_SHARED_LINKER_FLAGS_INIT "-fuse-ld=lld")
set(CMAKE_MODULE_LINKER_FLAGS_INIT "-fuse-ld=lld")

set(CMAKE_FIND_ROOT_PATH "$ENV{SACRAMENTO_DEBIAN_SYSROOT}")
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE BOTH)

unset(_sacramento_driver_flags)
