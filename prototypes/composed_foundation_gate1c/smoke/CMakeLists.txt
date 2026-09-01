cmake_minimum_required(VERSION 3.25)
project(falcor_vulkan_smoke LANGUAGES CXX)

if(NOT DEFINED FALCOR_SDK)
    message(FATAL_ERROR "FALCOR_SDK must identify the packaged SDK")
endif()

add_executable(falcor_vulkan_smoke main.cpp)
target_compile_features(falcor_vulkan_smoke PRIVATE cxx_std_23)
target_compile_definitions(falcor_vulkan_smoke PRIVATE
    FALCOR_HAS_AFTERMATH=1
    FALCOR_HAS_CUDA=0
    FALCOR_HAS_D3D12=0
    FALCOR_HAS_D3D12_AGILITY_SDK=0
    FALCOR_HAS_NVAPI=0
    FALCOR_HAS_VULKAN=1
    NOMINMAX
    UNICODE
    _UNICODE
    _USE_MATH_DEFINES
)
target_include_directories(falcor_vulkan_smoke PRIVATE
    "${FALCOR_SDK}/include"
    "${FALCOR_SDK}/include/Falcor"
)
target_link_libraries(falcor_vulkan_smoke PRIVATE "${FALCOR_SDK}/lib/Falcor.lib")
target_link_options(falcor_vulkan_smoke PRIVATE /Brepro)

add_custom_command(TARGET falcor_vulkan_smoke POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        "${FALCOR_SDK}/bin" "$<TARGET_FILE_DIR:falcor_vulkan_smoke>"
    COMMAND ${CMAKE_COMMAND} -E copy
        "${CMAKE_CURRENT_SOURCE_DIR}/gate1c.slang"
        "$<TARGET_FILE_DIR:falcor_vulkan_smoke>/shaders/gate1c.slang"
    COMMAND ${CMAKE_COMMAND} -E copy
        "${CMAKE_CURRENT_SOURCE_DIR}/run-smoke.ps1"
        "$<TARGET_FILE_DIR:falcor_vulkan_smoke>/run-smoke.ps1"
)
