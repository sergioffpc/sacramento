cmake_minimum_required(VERSION 4.2.3)

project(sacramento_composed_foundation_gate2e LANGUAGES CXX)

if(NOT CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  message(FATAL_ERROR "Gate 2E permits Clang only")
endif()

option(SACRAMENTO_GATE2E_DIAGNOSTIC "Build the Tracy diagnostic profile" OFF)
option(SACRAMENTO_HARDENING "Enable the approved platform hardening" ON)
option(SACRAMENTO_REPRODUCIBLE "Enable reproducible code generation" ON)
set(SACRAMENTO_SANITIZER "" CACHE STRING "Optional sanitizer profile")
set(SACRAMENTO_COVERAGE OFF)
set(SACRAMENTO_ACCEPTANCE ON)

include(${CMAKE_CURRENT_LIST_DIR}/../../cmake/SacramentoOptions.cmake)

# Linux-hosted clang-cl rejects the shared profile's /pathmap spelling. Retain
# the same semantics with clang prefix maps plus /Brepro for this gate.
set(SACRAMENTO_GATE2E_WINDOWS_REPRODUCIBLE OFF)
if(WIN32 AND SACRAMENTO_REPRODUCIBLE)
  set(SACRAMENTO_GATE2E_WINDOWS_REPRODUCIBLE ON)
  set(SACRAMENTO_REPRODUCIBLE OFF)
endif()

function(sacramento_gate2e_apply_windows_reproducibility target)
  if(SACRAMENTO_GATE2E_WINDOWS_REPRODUCIBLE)
    target_compile_options(
      ${target}
      PRIVATE
        /Brepro
        -Wno-unused-command-line-argument
        "/clang:-ffile-prefix-map=${CMAKE_SOURCE_DIR}=."
        "/clang:-fdebug-prefix-map=${CMAKE_SOURCE_DIR}=."
        "/clang:-ffile-prefix-map=${CMAKE_BINARY_DIR}=./build"
        "/clang:-fdebug-prefix-map=${CMAKE_BINARY_DIR}=./build")
    target_link_options(${target} PRIVATE /Brepro)
  endif()
endfunction()

add_library(sacramento_gate2e_observability STATIC src/observability.cc)
target_include_directories(sacramento_gate2e_observability PUBLIC include)
sacramento_apply_cpp_profile(sacramento_gate2e_observability)
sacramento_gate2e_apply_windows_reproducibility(
  sacramento_gate2e_observability)

if(SACRAMENTO_GATE2E_DIAGNOSTIC)
  find_package(Tracy CONFIG REQUIRED)
  add_executable(
    sacramento_gate2e_diagnostic
    src/scenario_main.cc
    src/tracy_profiler_adapter.cc)
  target_link_libraries(
    sacramento_gate2e_diagnostic
    PRIVATE sacramento_gate2e_observability Tracy::TracyClient)
  target_compile_definitions(
    sacramento_gate2e_diagnostic PRIVATE SACRAMENTO_GATE2E_DIAGNOSTIC_BUILD=1)
  set(gate2e_target sacramento_gate2e_diagnostic)
else()
  add_executable(
    sacramento_gate2e_core
    src/scenario_main.cc
    src/core_profiler.cc)
  target_link_libraries(
    sacramento_gate2e_core PRIVATE sacramento_gate2e_observability)
  target_compile_definitions(
    sacramento_gate2e_core PRIVATE SACRAMENTO_GATE2E_DIAGNOSTIC_BUILD=0)
  set(gate2e_target sacramento_gate2e_core)
endif()

sacramento_apply_cpp_profile(${gate2e_target})
sacramento_gate2e_apply_windows_reproducibility(${gate2e_target})
if(WIN32)
  # The harness reads three non-secret process-local settings through the C
  # standard getenv API. UCRT deprecates that API in favor of _dupenv_s even
  # though no mutable buffer is involved here.
  target_compile_definitions(${gate2e_target} PRIVATE _CRT_SECURE_NO_WARNINGS)
endif()
sacramento_add_debug_artifact(${gate2e_target})
