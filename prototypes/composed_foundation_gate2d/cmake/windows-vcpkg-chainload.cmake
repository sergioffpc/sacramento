include("${CMAKE_CURRENT_LIST_DIR}/../../../cmake/toolchains/windows-cross-clang.cmake")

# Release-only vcpkg ports still use try_compile during configure. Bind those
# probes to the admitted release CRT because the sealed sysroot intentionally
# contains no msvcrtd.lib.
set(CMAKE_TRY_COMPILE_CONFIGURATION Release)
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreadedDLL" CACHE STRING "" FORCE)
