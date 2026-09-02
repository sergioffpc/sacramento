vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO ValveSoftware/GameNetworkingSockets
  REF "2cb93a06350bb065db53abdb0d87cf297e0bfd34"
  SHA512 c2deaa3aab42cd840dd13560ca4da40faa375ab846ea15af38d55eb7acc48cfe8cbdbe0c76b9c3484d26f9e1163e36ac1eb73a317e5c19cefe60d0b861d19e06
  HEAD_REF master)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DUSE_CRYPTO=BCrypt
    -DENABLE_ICE=OFF
    -DBUILD_STATIC_LIB=ON
    -DBUILD_SHARED_LIB=OFF
    -DMSVC_CRT_STATIC=OFF
    -DBUILD_TESTS=OFF
    -DBUILD_EXAMPLES=OFF
    -DBUILD_TOOLS=OFF)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/GameNetworkingSockets")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_copy_pdbs()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
