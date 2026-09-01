cmake_minimum_required(VERSION 4.2.3)

project(
  sacramento
  VERSION 0.1.0
  DESCRIPTION "Sacramento multiplayer training simulation"
  LANGUAGES CXX)

if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  message(FATAL_ERROR "Sacramento permits Clang only")
endif()

get_filename_component(sacramento_compiler_name "${CMAKE_CXX_COMPILER}" NAME)
if(sacramento_compiler_name MATCHES "^(cl|gcc|g\\+\\+)(\\.exe)?$")
  message(FATAL_ERROR "MSVC cl.exe and GCC/G++ are prohibited")
endif()
unset(sacramento_compiler_name)

set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

option(SACRAMENTO_HARDENING "Enable the approved platform hardening" OFF)
option(SACRAMENTO_COVERAGE "Enable LLVM source-based coverage" OFF)
option(SACRAMENTO_FUZZING "Enable libFuzzer targets" OFF)
option(SACRAMENTO_REPRODUCIBLE "Enable reproducible code generation" OFF)
option(SACRAMENTO_ACCEPTANCE "Enable acceptance observability" OFF)
set(SACRAMENTO_SANITIZER "" CACHE STRING "asan-ubsan, asan, or tsan")
set_property(
  CACHE SACRAMENTO_SANITIZER
  PROPERTY STRINGS "" asan-ubsan asan tsan)

include(CTest)
include(cmake/SacramentoOptions.cmake)

# Production modules are added here only after their architecture and applicable
# readiness gates are approved. The root project intentionally contains no
# throwaway prototype targets.
