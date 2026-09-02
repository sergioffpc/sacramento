include(
  "${CMAKE_CURRENT_LIST_DIR}/../../../cmake/toolchains/debian-cross-clang.cmake")

if(DEFINED VCPKG_INSTALLED_DIR)
  set(_sacramento_vcpkg_installed_dir "${VCPKG_INSTALLED_DIR}")
elseif(DEFINED _VCPKG_INSTALLED_DIR)
  set(_sacramento_vcpkg_installed_dir "${_VCPKG_INSTALLED_DIR}")
endif()

if(DEFINED _sacramento_vcpkg_installed_dir AND
   DEFINED VCPKG_TARGET_TRIPLET)
  list(
    APPEND CMAKE_FIND_ROOT_PATH
    "${_sacramento_vcpkg_installed_dir}/${VCPKG_TARGET_TRIPLET}")
endif()

unset(_sacramento_vcpkg_installed_dir)
