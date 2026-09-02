cmake_minimum_required(VERSION 4.2.3)

project(sacramento_composed_foundation_gate2a LANGUAGES CXX)

if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  message(FATAL_ERROR "Gate 2A permits Clang only")
endif()

option(SACRAMENTO_HARDENING "Enable the approved platform hardening" ON)
option(SACRAMENTO_REPRODUCIBLE "Enable reproducible code generation" ON)
set(SACRAMENTO_SANITIZER "" CACHE STRING "Optional sanitizer profile")
set(SACRAMENTO_COVERAGE OFF)
set(SACRAMENTO_ACCEPTANCE ON)

include(${CMAKE_CURRENT_LIST_DIR}/../../cmake/SacramentoOptions.cmake)

find_package(flecs CONFIG REQUIRED)
find_package(unofficial-omniverse-physx-sdk CONFIG REQUIRED)

add_executable(
  sacramento_gate2a_authority
  src/authority.cpp
  src/main.cpp)
target_include_directories(
  sacramento_gate2a_authority
  PUBLIC include)
target_link_libraries(
  sacramento_gate2a_authority
  PRIVATE
    $<IF:$<TARGET_EXISTS:flecs::flecs>,flecs::flecs,flecs::flecs_static>
    unofficial::omniverse-physx-sdk::sdk)
sacramento_apply_cpp_profile(sacramento_gate2a_authority)
sacramento_add_debug_artifact(sacramento_gate2a_authority)
