cmake_minimum_required(VERSION 4.2.3)

project(sacramento_composed_foundation_gate2d LANGUAGES CXX)

if(NOT CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  message(FATAL_ERROR "Gate 2D permits Clang only")
endif()

option(SACRAMENTO_HARDENING "Enable the approved platform hardening" ON)
option(SACRAMENTO_REPRODUCIBLE "Enable reproducible code generation" ON)
set(SACRAMENTO_SANITIZER "" CACHE STRING "Optional sanitizer profile")
set(SACRAMENTO_COVERAGE OFF)
set(SACRAMENTO_ACCEPTANCE ON)

include(${CMAKE_CURRENT_LIST_DIR}/../../cmake/SacramentoOptions.cmake)

set(SACRAMENTO_GATE2D_WINDOWS_REPRODUCIBLE OFF)
if(WIN32 AND SACRAMENTO_REPRODUCIBLE)
  set(SACRAMENTO_GATE2D_WINDOWS_REPRODUCIBLE ON)
  set(SACRAMENTO_REPRODUCIBLE OFF)
endif()

function(sacramento_gate2d_apply_windows_reproducibility target)
  if(SACRAMENTO_GATE2D_WINDOWS_REPRODUCIBLE)
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

add_library(sacramento_gate2d_event STATIC src/acoustic_event.cc)
target_include_directories(sacramento_gate2d_event PUBLIC include)
sacramento_apply_cpp_profile(sacramento_gate2d_event)
sacramento_gate2d_apply_windows_reproducibility(sacramento_gate2d_event)

add_executable(sacramento_gate2d_authority src/authority_main.cc)
target_link_libraries(sacramento_gate2d_authority PRIVATE sacramento_gate2d_event)
sacramento_apply_cpp_profile(sacramento_gate2d_authority)
sacramento_gate2d_apply_windows_reproducibility(sacramento_gate2d_authority)
sacramento_add_debug_artifact(sacramento_gate2d_authority)

# The pinned steam-audio vcpkg config exports these target names but omits the
# corresponding find_dependency calls. Import them explicitly before loading
# the vendor config; this is a gate-local packaging exception.
find_package(Flatbuffers CONFIG REQUIRED)
find_package(mysofa CONFIG REQUIRED)
find_package(pffft CONFIG REQUIRED)
find_package(steam-audio CONFIG REQUIRED)
find_path(SACRAMENTO_STEAM_AUDIO_INCLUDE_DIR phonon.h REQUIRED)
add_executable(
  sacramento_gate2d_client
  src/client_main.cc
  src/steam_audio_adapter.cc)
target_include_directories(
  sacramento_gate2d_client
  PRIVATE ${SACRAMENTO_STEAM_AUDIO_INCLUDE_DIR})
target_link_libraries(
  sacramento_gate2d_client
  PRIVATE
    sacramento_gate2d_event
    unofficial::steam-audio::phonon)
sacramento_apply_cpp_profile(sacramento_gate2d_client)
sacramento_gate2d_apply_windows_reproducibility(sacramento_gate2d_client)
sacramento_add_debug_artifact(sacramento_gate2d_client)
