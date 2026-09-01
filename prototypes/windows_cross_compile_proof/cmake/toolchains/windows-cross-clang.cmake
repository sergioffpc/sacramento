set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR AMD64)

foreach(variable IN ITEMS
    SACRAMENTO_LLVM_ROOT
    SACRAMENTO_VCTOOLS_DIR
    SACRAMENTO_WINSDK_DIR)
  if(NOT DEFINED ENV{${variable}} OR "$ENV{${variable}}" STREQUAL "")
    message(FATAL_ERROR "${variable} must identify a pinned prototype input")
  endif()
endforeach()

set(CMAKE_C_COMPILER "$ENV{SACRAMENTO_LLVM_ROOT}/bin/clang-cl")
set(CMAKE_CXX_COMPILER "$ENV{SACRAMENTO_LLVM_ROOT}/bin/clang-cl")
set(CMAKE_LINKER "$ENV{SACRAMENTO_LLVM_ROOT}/bin/lld-link")
set(CMAKE_AR "$ENV{SACRAMENTO_LLVM_ROOT}/bin/llvm-lib")
set(CMAKE_RC_COMPILER "$ENV{SACRAMENTO_LLVM_ROOT}/bin/llvm-rc")
set(CMAKE_MT "$ENV{SACRAMENTO_LLVM_ROOT}/bin/llvm-mt")

set(_sacramento_driver_flags
  "--target=x86_64-pc-windows-msvc -imsvc$ENV{SACRAMENTO_VCTOOLS_DIR}/include -imsvc$ENV{SACRAMENTO_WINSDK_DIR}/include/ucrt -imsvc$ENV{SACRAMENTO_WINSDK_DIR}/include/shared -imsvc$ENV{SACRAMENTO_WINSDK_DIR}/include/um -imsvc$ENV{SACRAMENTO_WINSDK_DIR}/include/winrt -imsvc$ENV{SACRAMENTO_WINSDK_DIR}/include/cppwinrt -fuse-ld=lld")
set(CMAKE_C_FLAGS_INIT "${_sacramento_driver_flags}")
set(CMAKE_CXX_FLAGS_INIT "${_sacramento_driver_flags}")
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreadedDLL")

# CMake invokes lld-link directly for MSVC-style toolchains, so the library
# search paths discovered by clang-cl must also be supplied to CMake's linker
# rule. The xwin splats deliberately remain separate and auditable.
set(_sacramento_linker_flags
  "/LIBPATH:$ENV{SACRAMENTO_VCTOOLS_DIR}/lib/x64 /LIBPATH:$ENV{SACRAMENTO_WINSDK_DIR}/lib/ucrt/x64 /LIBPATH:$ENV{SACRAMENTO_WINSDK_DIR}/lib/um/x64")
set(CMAKE_EXE_LINKER_FLAGS_INIT "${_sacramento_linker_flags}")
set(CMAKE_SHARED_LINKER_FLAGS_INIT "${_sacramento_linker_flags}")
set(CMAKE_MODULE_LINKER_FLAGS_INIT "${_sacramento_linker_flags}")

unset(_sacramento_driver_flags)
unset(_sacramento_linker_flags)
