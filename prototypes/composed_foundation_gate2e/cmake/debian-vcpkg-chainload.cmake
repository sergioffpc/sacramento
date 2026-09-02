include("${CMAKE_CURRENT_LIST_DIR}/../../../cmake/toolchains/debian-cross-clang.cmake")

if(DEFINED VCPKG_INSTALLED_DIR)
  list(APPEND CMAKE_FIND_ROOT_PATH
       "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}")
endif()
