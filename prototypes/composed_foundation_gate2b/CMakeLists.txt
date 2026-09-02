cmake_minimum_required(VERSION 4.2.3)

project(sacramento_composed_foundation_gate2b LANGUAGES CXX)

if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  message(FATAL_ERROR "Gate 2B permits Clang only")
endif()

option(SACRAMENTO_HARDENING "Enable the approved platform hardening" ON)
option(SACRAMENTO_REPRODUCIBLE "Enable reproducible code generation" ON)
set(SACRAMENTO_SANITIZER "" CACHE STRING "Optional sanitizer profile")
set(SACRAMENTO_COVERAGE OFF)
set(SACRAMENTO_ACCEPTANCE ON)

include(${CMAKE_CURRENT_LIST_DIR}/../../cmake/SacramentoOptions.cmake)

find_package(assimp CONFIG REQUIRED)
find_package(RapidJSON CONFIG REQUIRED)

add_executable(sacramento_gate2b_assimp_adapter src/assimp_adapter.cpp)
target_link_libraries(sacramento_gate2b_assimp_adapter PRIVATE assimp::assimp)
sacramento_apply_cpp_profile(sacramento_gate2b_assimp_adapter)
# Assimp's indexed C arrays require operations diagnosed by this experimental
# Clang warning. They remain contained inside this adapter implementation.
target_compile_options(
  sacramento_gate2b_assimp_adapter PRIVATE -Wno-unsafe-buffer-usage)
sacramento_add_debug_artifact(sacramento_gate2b_assimp_adapter)

add_executable(sacramento_gate2b_runtime_reader src/runtime_reader.cpp)
target_link_libraries(sacramento_gate2b_runtime_reader PRIVATE RapidJSON)
sacramento_apply_cpp_profile(sacramento_gate2b_runtime_reader)
sacramento_add_debug_artifact(sacramento_gate2b_runtime_reader)
