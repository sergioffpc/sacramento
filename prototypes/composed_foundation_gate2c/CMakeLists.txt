cmake_minimum_required(VERSION 4.2.3)

project(sacramento_composed_foundation_gate2c LANGUAGES CXX)

if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  message(FATAL_ERROR "Gate 2C permits Clang only")
endif()

option(SACRAMENTO_HARDENING "Enable the approved platform hardening" ON)
option(SACRAMENTO_REPRODUCIBLE "Enable reproducible code generation" ON)
set(SACRAMENTO_SANITIZER "" CACHE STRING "Optional sanitizer profile")
set(SACRAMENTO_COVERAGE OFF)
set(SACRAMENTO_ACCEPTANCE ON)

include(${CMAKE_CURRENT_LIST_DIR}/../../cmake/SacramentoOptions.cmake)

find_package(GameNetworkingSockets CONFIG REQUIRED)

add_library(
  sacramento_gate2c_network STATIC
  src/gns_transport.cpp
  src/protocol.cpp)
target_include_directories(sacramento_gate2c_network PUBLIC include)
target_link_libraries(
  sacramento_gate2c_network PRIVATE GameNetworkingSockets::static)
sacramento_apply_cpp_profile(sacramento_gate2c_network)

add_executable(sacramento_gate2c_authority src/authority_main.cpp)
target_link_libraries(sacramento_gate2c_authority PRIVATE sacramento_gate2c_network)
sacramento_apply_cpp_profile(sacramento_gate2c_authority)
sacramento_add_debug_artifact(sacramento_gate2c_authority)

add_executable(sacramento_gate2c_client src/client_main.cpp)
target_link_libraries(sacramento_gate2c_client PRIVATE sacramento_gate2c_network)
sacramento_apply_cpp_profile(sacramento_gate2c_client)
sacramento_add_debug_artifact(sacramento_gate2c_client)

add_executable(sacramento_gate2c_protocol_probe src/protocol_probe.cpp)
target_link_libraries(
  sacramento_gate2c_protocol_probe PRIVATE sacramento_gate2c_network)
sacramento_apply_cpp_profile(sacramento_gate2c_protocol_probe)
sacramento_add_debug_artifact(sacramento_gate2c_protocol_probe)
