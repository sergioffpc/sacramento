if(NOT VCPKG_TARGET_IS_LINUX OR NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
  message(FATAL_ERROR "sacramento-slang-host supports only Linux x64 hosts")
endif()

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_download_distfile(
  ARCHIVE
  URLS
    "https://github.com/shader-slang/slang/releases/download/v2024.1.34/slang-2024.1.34-linux-x86_64-glibc-2.17.tar.gz"
  FILENAME "slang-2024.1.34-linux-x86_64-glibc-2.17.tar.gz"
  SHA512
    7402815214a1fb933c41803af1ff6436cd9bc72afdcd28ad488bf52407450b057078156a6421bf9d5a88f1d7e15f54f305f20beaea7d0b035a453ffc5255214f)

vcpkg_extract_source_archive(
  SOURCE_PATH
  ARCHIVE "${ARCHIVE}"
  NO_REMOVE_ONE_LEVEL)

file(
  INSTALL "${SOURCE_PATH}/bin/slangc"
  DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")
file(
  CHMOD "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/slangc"
  PERMISSIONS
    OWNER_READ OWNER_WRITE OWNER_EXECUTE
    GROUP_READ GROUP_EXECUTE
    WORLD_READ WORLD_EXECUTE)
file(
  INSTALL "${SOURCE_PATH}/lib/"
  DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
