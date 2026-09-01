include_guard(GLOBAL)

function(sacramento_apply_cpp_profile target)
  get_target_property(target_type "${target}" TYPE)
  set_target_properties(
    "${target}"
    PROPERTIES CXX_STANDARD 23 CXX_STANDARD_REQUIRED YES CXX_EXTENSIONS NO)

  if(WIN32)
    target_compile_options(
      "${target}"
      PRIVATE /W4 /WX /permissive- /Zc:__cplusplus /std:c++23preview
              -Wconversion -Wsign-conversion -Wshadow -Wformat=2 -Wundef
              -Wimplicit-fallthrough -Wnon-virtual-dtor
              -Wunsafe-buffer-usage)
    target_compile_options(
      "${target}"
      PRIVATE "$<$<CONFIG:Debug>:/Od>" "$<$<CONFIG:RelWithDebInfo>:/O1>"
              "$<$<CONFIG:Release>:/O2>" "$<$<CONFIG:Release>:/Zi>")
  else()
    target_compile_options(
      "${target}"
      PRIVATE -Wall -Wextra -Wpedantic -Werror -Wconversion
              -Wsign-conversion -Wshadow -Wformat=2 -Wundef
              -Wimplicit-fallthrough -Wnon-virtual-dtor
              -Wunsafe-buffer-usage)
    target_compile_options(
      "${target}"
      PRIVATE "$<$<CONFIG:Debug>:-O0>" "$<$<CONFIG:RelWithDebInfo>:-O1>"
              "$<$<CONFIG:Release>:-O2>" "$<$<CONFIG:Release>:-g>")
  endif()

  if(SACRAMENTO_SANITIZER STREQUAL "asan-ubsan")
    if(WIN32)
      message(FATAL_ERROR "The asan-ubsan profile is Debian-only")
    endif()
    target_compile_options(
      "${target}" PRIVATE -fsanitize=address,undefined
                          -fno-omit-frame-pointer)
    target_link_options("${target}" PRIVATE -fsanitize=address,undefined)
  elseif(SACRAMENTO_SANITIZER STREQUAL "asan")
    target_compile_options(
      "${target}" PRIVATE -fsanitize=address -fno-omit-frame-pointer)
    target_link_options("${target}" PRIVATE -fsanitize=address)
  elseif(SACRAMENTO_SANITIZER STREQUAL "tsan")
    if(WIN32)
      message(FATAL_ERROR "The tsan profile is Debian-only")
    endif()
    target_compile_options(
      "${target}" PRIVATE -fsanitize=thread -fno-omit-frame-pointer)
    target_link_options("${target}" PRIVATE -fsanitize=thread)
  elseif(NOT SACRAMENTO_SANITIZER STREQUAL "")
    message(FATAL_ERROR "Unknown SACRAMENTO_SANITIZER value")
  endif()

  if(SACRAMENTO_COVERAGE)
    if(WIN32)
      message(FATAL_ERROR "The coverage profile is Debian-only")
    endif()
    target_compile_options(
      "${target}" PRIVATE -fprofile-instr-generate -fcoverage-mapping)
    target_link_options("${target}" PRIVATE -fprofile-instr-generate)
  endif()

  if(SACRAMENTO_HARDENING)
    if(WIN32)
      target_compile_options("${target}" PRIVATE /GS /guard:cf)
      target_link_options(
        "${target}"
        PRIVATE /GUARD:CF /DYNAMICBASE /NXCOMPAT /HIGHENTROPYVA)
    else()
      target_compile_options(
        "${target}"
        PRIVATE -fstack-protector-strong -fstack-clash-protection
                -D_FORTIFY_SOURCE=3)
      target_link_options(
        "${target}"
        PRIVATE LINKER:-z,relro LINKER:-z,now LINKER:-z,noexecstack)
      if(target_type STREQUAL "EXECUTABLE")
        target_compile_options("${target}" PRIVATE -fPIE)
        target_link_options("${target}" PRIVATE -pie)
      endif()
    endif()
  endif()

  if(SACRAMENTO_REPRODUCIBLE)
    if(WIN32)
      target_compile_options(
        "${target}" PRIVATE "/pathmap:${CMAKE_SOURCE_DIR}=." /Brepro)
      target_link_options("${target}" PRIVATE /Brepro)
    else()
      target_compile_options(
        "${target}"
        PRIVATE "-ffile-prefix-map=${CMAKE_SOURCE_DIR}=."
                "-fdebug-prefix-map=${CMAKE_SOURCE_DIR}=."
                "-ffile-prefix-map=${CMAKE_BINARY_DIR}=./build"
                "-fdebug-prefix-map=${CMAKE_BINARY_DIR}=./build")
      target_link_options("${target}" PRIVATE LINKER:--build-id=sha1)
    endif()
  endif()

  if(SACRAMENTO_ACCEPTANCE)
    target_compile_definitions(
      "${target}" PRIVATE SACRAMENTO_ACCEPTANCE_OBSERVABILITY=1)
  endif()
endfunction()

function(sacramento_add_debug_artifact target)
  if(CMAKE_BUILD_TYPE STREQUAL "Release" AND NOT WIN32)
    add_custom_command(
      TARGET "${target}"
      POST_BUILD
      COMMAND "${CMAKE_OBJCOPY}" --only-keep-debug "$<TARGET_FILE:${target}>"
              "$<TARGET_FILE:${target}>.debug"
      COMMAND "${CMAKE_STRIP}" --strip-debug "$<TARGET_FILE:${target}>"
      COMMAND "${CMAKE_OBJCOPY}"
              "--add-gnu-debuglink=$<TARGET_FILE:${target}>.debug"
              "$<TARGET_FILE:${target}>"
      VERBATIM)
  endif()
endfunction()
