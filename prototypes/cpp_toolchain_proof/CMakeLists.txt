cmake_minimum_required(VERSION 4.4.2)

project(
  sacramento_cpp_toolchain_proof
  VERSION 0.1.0
  DESCRIPTION "Throwaway proof for CPP-ENGINEERING-BASELINE-001"
  LANGUAGES CXX)

if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  message(FATAL_ERROR "The proof permits Clang only")
endif()

get_filename_component(compiler_name "${CMAKE_CXX_COMPILER}" NAME)
if(compiler_name MATCHES "^(cl|gcc|g\\+\\+)(\\.exe)?$")
  message(FATAL_ERROR "MSVC cl.exe and GCC/G++ are prohibited")
endif()

set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

option(SACRAMENTO_PROOF_HARDENING "Enable baseline hardening" OFF)
option(SACRAMENTO_PROOF_COVERAGE "Enable source-based coverage" OFF)
option(SACRAMENTO_PROOF_FUZZING "Build the libFuzzer target" OFF)
option(SACRAMENTO_PROOF_REPRODUCIBLE "Enable reproducible code generation" OFF)
option(SACRAMENTO_PROOF_ACCEPTANCE "Enable acceptance observability" OFF)
set(SACRAMENTO_PROOF_SANITIZER "" CACHE STRING "asan-ubsan, asan, or tsan")

find_package(fmt CONFIG REQUIRED)

include(cmake/ProofOptions.cmake)

add_library(sacramento_proof_core SHARED src/proof_core.cc)
target_compile_features(sacramento_proof_core PUBLIC cxx_std_23)
target_include_directories(
  sacramento_proof_core
  PUBLIC "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>")
target_link_libraries(sacramento_proof_core PRIVATE fmt::fmt)
target_compile_definitions(
  sacramento_proof_core
  PRIVATE SACRAMENTO_PROOF_BUILDING_LIBRARY)
set_target_properties(
  sacramento_proof_core
  PROPERTIES CXX_VISIBILITY_PRESET hidden VISIBILITY_INLINES_HIDDEN YES)
sacramento_apply_proof_options(sacramento_proof_core)
sacramento_add_debug_artifact(sacramento_proof_core)

add_executable(sacramento_proof_app src/main.cc)
target_compile_features(sacramento_proof_app PRIVATE cxx_std_23)
target_link_libraries(sacramento_proof_app PRIVATE sacramento_proof_core)
sacramento_apply_proof_options(sacramento_proof_app)
sacramento_add_debug_artifact(sacramento_proof_app)

include(CTest)
if(BUILD_TESTING)
  find_package(GTest CONFIG REQUIRED)
  find_package(benchmark CONFIG REQUIRED)
  add_executable(sacramento_proof_tests tests/proof_core_test.cc)
  target_compile_features(sacramento_proof_tests PRIVATE cxx_std_23)
  target_link_libraries(
    sacramento_proof_tests
    PRIVATE sacramento_proof_core GTest::gtest_main)
  sacramento_apply_proof_options(sacramento_proof_tests)
  include(GoogleTest)
  gtest_discover_tests(sacramento_proof_tests)

  add_executable(sacramento_proof_benchmark tests/proof_benchmark.cc)
  target_compile_features(sacramento_proof_benchmark PRIVATE cxx_std_23)
  target_link_libraries(
    sacramento_proof_benchmark
    PRIVATE sacramento_proof_core benchmark::benchmark_main)
  sacramento_apply_proof_options(sacramento_proof_benchmark)
endif()

add_executable(cpp23_feature_probe probes/cpp23_features.cc)
target_compile_features(cpp23_feature_probe PRIVATE cxx_std_23)
sacramento_apply_proof_options(cpp23_feature_probe)
add_test(NAME cpp23_feature_probe COMMAND cpp23_feature_probe)

if(SACRAMENTO_PROOF_FUZZING)
  if(WIN32)
    message(FATAL_ERROR "The libFuzzer proof target is Debian-only")
  endif()
  add_executable(proof_parser_fuzz fuzz/proof_parser_fuzz.cc)
  target_compile_features(proof_parser_fuzz PRIVATE cxx_std_23)
  target_link_libraries(proof_parser_fuzz PRIVATE sacramento_proof_core)
  target_compile_options(
    proof_parser_fuzz PRIVATE -fsanitize=fuzzer,address,undefined)
  target_link_options(
    proof_parser_fuzz PRIVATE -fsanitize=fuzzer,address,undefined)
endif()
