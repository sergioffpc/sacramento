include("${CMAKE_CURRENT_LIST_DIR}/../../../cmake/toolchains/windows-cross-clang.cmake")

# Tracy 0.13.1 does not declare a C++ language level for TracyClient. The
# pinned clang-cl/MSVC STL combination rejects its atomic pointer
# copy-initialization in the compiler default mode; the approved C++23 mode
# compiles the unchanged upstream source.
string(APPEND CMAKE_CXX_FLAGS_INIT " /std:c++23preview")

set(CMAKE_TRY_COMPILE_CONFIGURATION Release)
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreadedDLL" CACHE STRING "" FORCE)
