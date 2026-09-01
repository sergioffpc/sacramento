cmake_minimum_required(VERSION 4.2.3)

project(sacramento_cross_proof LANGUAGES CXX)

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

if(WIN32)
  foreach(target IN ITEMS proof_core proof_app proof_tests)
    target_compile_options(${target} PRIVATE
      /W4 /WX /permissive- /Zc:__cplusplus /GS /guard:cf /Zi /Brepro
    )
  endforeach()

  foreach(target IN ITEMS proof_app proof_tests)
    target_link_options(${target} PRIVATE
      /GUARD:CF /DYNAMICBASE /NXCOMPAT /HIGHENTROPYVA /DEBUG:FULL /BREPRO
    )
  endforeach()
else()
  foreach(target IN ITEMS proof_core proof_app proof_tests)
    target_compile_options(${target} PRIVATE
      -Wall -Wextra -Wpedantic -Werror -Wconversion -Wsign-conversion
      -Wshadow -Wformat=2 -Wundef -Wimplicit-fallthrough
      -Wnon-virtual-dtor -Wunsafe-buffer-usage
      -fstack-protector-strong -fstack-clash-protection
      -D_FORTIFY_SOURCE=3 -g
      "-ffile-prefix-map=${CMAKE_SOURCE_DIR}=."
      "-fdebug-prefix-map=${CMAKE_SOURCE_DIR}=."
      "-ffile-prefix-map=${CMAKE_BINARY_DIR}=./build"
      "-fdebug-prefix-map=${CMAKE_BINARY_DIR}=./build"
    )
  endforeach()

  foreach(target IN ITEMS proof_app proof_tests)
    target_compile_options(${target} PRIVATE -fPIE)
    target_link_options(${target} PRIVATE
      -pie LINKER:-z,relro LINKER:-z,now LINKER:-z,noexecstack
      LINKER:--build-id=sha1
    )
  endforeach()
endif()
