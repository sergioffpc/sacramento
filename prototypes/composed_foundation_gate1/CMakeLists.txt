cmake_minimum_required(VERSION 4.2.3)

project(
  sacramento_composed_foundation_gate1
  LANGUAGES CXX)

find_package(VulkanHeaders CONFIG REQUIRED)

if(NOT DEFINED SACRAMENTO_GATE1_SHADER_SHA256 OR
   SACRAMENTO_GATE1_SHADER_SHA256 STREQUAL "")
  message(FATAL_ERROR "SACRAMENTO_GATE1_SHADER_SHA256 is required")
endif()

add_executable(sacramento_gate1_vulkan_probe src/vulkan_probe.cpp)
target_compile_features(sacramento_gate1_vulkan_probe PRIVATE cxx_std_23)
target_compile_definitions(
  sacramento_gate1_vulkan_probe
  PRIVATE
    SACRAMENTO_GATE1_SHADER_SHA256="${SACRAMENTO_GATE1_SHADER_SHA256}")
target_link_libraries(sacramento_gate1_vulkan_probe PRIVATE Vulkan::Headers)
