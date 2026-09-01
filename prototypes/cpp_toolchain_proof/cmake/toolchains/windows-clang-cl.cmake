set(CMAKE_C_COMPILER clang-cl CACHE FILEPATH "Clang-cl C compiler")
set(CMAKE_CXX_COMPILER clang-cl CACHE FILEPATH "Clang-cl C++ compiler")
set(CMAKE_LINKER link CACHE FILEPATH "Native Windows linker")
set(CMAKE_MSVC_RUNTIME_LIBRARY
    "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL"
    CACHE STRING "Dynamic MSVC runtime")
