cmake_minimum_required(VERSION 4.2.3)

project(sacramento_composed_foundation_gate2f LANGUAGES CXX)

if(NOT WIN32 OR NOT CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  message(FATAL_ERROR "Gate 2F requires the Windows clang-cl toolchain")
endif()
if(NOT DEFINED FALCOR_SDK)
  message(FATAL_ERROR "FALCOR_SDK must identify the retained Gate 1C SDK")
endif()

option(SACRAMENTO_HARDENING "Enable the approved platform hardening" ON)
option(SACRAMENTO_REPRODUCIBLE "Enable reproducible code generation" ON)
set(SACRAMENTO_SANITIZER "" CACHE STRING "Optional sanitizer profile")
set(SACRAMENTO_COVERAGE OFF)
set(SACRAMENTO_ACCEPTANCE ON)

include(${CMAKE_CURRENT_LIST_DIR}/../../cmake/SacramentoOptions.cmake)

# Linux-hosted clang-cl rejects the shared profile's /pathmap spelling. Retain
# the same semantics with clang prefix maps plus /Brepro for this gate.
set(SACRAMENTO_GATE2F_WINDOWS_REPRODUCIBLE OFF)
if(SACRAMENTO_REPRODUCIBLE)
  set(SACRAMENTO_GATE2F_WINDOWS_REPRODUCIBLE ON)
  set(SACRAMENTO_REPRODUCIBLE OFF)
endif()

function(sacramento_gate2f_apply_windows_reproducibility target)
  if(SACRAMENTO_GATE2F_WINDOWS_REPRODUCIBLE)
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

find_package(GameNetworkingSockets CONFIG REQUIRED)
find_package(Flatbuffers CONFIG REQUIRED)
find_package(mysofa CONFIG REQUIRED)
find_package(pffft CONFIG REQUIRED)
find_package(steam-audio CONFIG REQUIRED)
find_path(SACRAMENTO_STEAM_AUDIO_INCLUDE_DIR phonon.h REQUIRED)

set(gate2c_root ${CMAKE_CURRENT_LIST_DIR}/../composed_foundation_gate2c)
set(gate2d_root ${CMAKE_CURRENT_LIST_DIR}/../composed_foundation_gate2d)
set(gate2e_root ${CMAKE_CURRENT_LIST_DIR}/../composed_foundation_gate2e)

add_library(
  sacramento_gate2f_network STATIC
  ${gate2c_root}/src/gns_transport.cpp
  ${gate2c_root}/src/protocol.cpp)
target_include_directories(
  sacramento_gate2f_network PUBLIC ${gate2c_root}/include)
target_link_libraries(
  sacramento_gate2f_network PRIVATE GameNetworkingSockets::static)

add_library(
  sacramento_gate2f_acoustics STATIC
  ${gate2d_root}/src/acoustic_event.cc
  ${gate2d_root}/src/steam_audio_adapter.cc)
target_include_directories(
  sacramento_gate2f_acoustics
  PUBLIC ${gate2d_root}/include
  PRIVATE ${SACRAMENTO_STEAM_AUDIO_INCLUDE_DIR})
target_link_libraries(
  sacramento_gate2f_acoustics PRIVATE unofficial::steam-audio::phonon)

add_library(
  sacramento_gate2f_observability STATIC
  ${gate2e_root}/src/observability.cc)
target_include_directories(
  sacramento_gate2f_observability PUBLIC ${gate2e_root}/include)

add_executable(sacramento_gate2f_rendered_client src/rendered_client.cpp)
target_compile_definitions(
  sacramento_gate2f_rendered_client
  PRIVATE
    FALCOR_HAS_AFTERMATH=1
    FALCOR_HAS_CUDA=0
    FALCOR_HAS_D3D12=0
    FALCOR_HAS_D3D12_AGILITY_SDK=0
    FALCOR_HAS_NVAPI=0
    FALCOR_HAS_VULKAN=1
    FALCOR_ENABLE_ASSERTS=0
    NOMINMAX
    UNICODE
    _CRT_SECURE_NO_WARNINGS
    _UNICODE
    _USE_MATH_DEFINES)
target_include_directories(
  sacramento_gate2f_rendered_client
  SYSTEM PRIVATE "${FALCOR_SDK}/include" "${FALCOR_SDK}/include/Falcor")
target_link_libraries(
  sacramento_gate2f_rendered_client
  PRIVATE
    sacramento_gate2f_network
    sacramento_gate2f_acoustics
    sacramento_gate2f_observability
    "${FALCOR_SDK}/lib/Falcor.lib")
target_link_options(
  sacramento_gate2f_rendered_client
  PRIVATE "/MAP:${CMAKE_BINARY_DIR}/sacramento_gate2f_rendered_client.map")

foreach(target IN ITEMS
    sacramento_gate2f_network
    sacramento_gate2f_acoustics
    sacramento_gate2f_observability
    sacramento_gate2f_rendered_client)
  sacramento_apply_cpp_profile(${target})
  sacramento_gate2f_apply_windows_reproducibility(${target})
endforeach()
sacramento_add_debug_artifact(sacramento_gate2f_rendered_client)

add_custom_command(
  TARGET sacramento_gate2f_rendered_client POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_directory
          "${FALCOR_SDK}/bin"
          "$<TARGET_FILE_DIR:sacramento_gate2f_rendered_client>"
  COMMAND ${CMAKE_COMMAND} -E copy
          "${CMAKE_CURRENT_SOURCE_DIR}/shaders/gate2f.slang"
          "$<TARGET_FILE_DIR:sacramento_gate2f_rendered_client>/shaders/gate2f.slang"
  COMMAND ${CMAKE_COMMAND} -E copy
          "${CMAKE_CURRENT_SOURCE_DIR}/run-smoke.ps1"
          "$<TARGET_FILE_DIR:sacramento_gate2f_rendered_client>/run-smoke.ps1")
