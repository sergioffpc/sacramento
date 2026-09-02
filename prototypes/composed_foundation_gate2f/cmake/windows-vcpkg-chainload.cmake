include("${CMAKE_CURRENT_LIST_DIR}/../../../cmake/toolchains/windows-cross-clang.cmake")

set(CMAKE_TRY_COMPILE_CONFIGURATION Release)
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreadedDLL" CACHE STRING "" FORCE)
