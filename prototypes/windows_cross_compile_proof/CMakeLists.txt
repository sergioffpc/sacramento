cmake_minimum_required(VERSION 4.2.3)

project(sacramento_windows_cross_proof LANGUAGES CXX)

include(CTest)

find_package(fmt CONFIG REQUIRED)
find_package(GTest CONFIG REQUIRED)

add_library(proof_core STATIC
  src/proof_core.cc
)
target_include_directories(proof_core PUBLIC include)
target_compile_features(proof_core PUBLIC cxx_std_23)
set_target_properties(proof_core PROPERTIES
  CXX_EXTENSIONS NO
  CXX_STANDARD_REQUIRED YES
)
target_link_libraries(proof_core PUBLIC fmt::fmt)

add_executable(proof_app src/main.cc)
target_link_libraries(proof_app PRIVATE proof_core)

add_executable(proof_tests tests/proof_core_test.cc)
target_link_libraries(proof_tests PRIVATE proof_core GTest::gtest_main)
add_test(NAME proof.expected_and_fmt COMMAND proof_tests)

foreach(target IN ITEMS proof_core proof_app proof_tests)
  target_compile_options(${target} PRIVATE
    /W4
    /WX
    /permissive-
    /Zc:__cplusplus
    /GS
    /guard:cf
    /Zi
    /Brepro
  )
endforeach()

foreach(target IN ITEMS proof_app proof_tests)
  target_link_options(${target} PRIVATE
    /GUARD:CF
    /DYNAMICBASE
    /NXCOMPAT
    /HIGHENTROPYVA
    /DEBUG:FULL
    /BREPRO
  )
endforeach()
