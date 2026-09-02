# Sacramento qualification overlay: Linux x64, static, release, CPU-only.
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NVIDIA-Omniverse/PhysX
    REF 110.1-omni-and-physx-5.9.0
    SHA512 e67ad62489d1e85fbe2f1ddabb26486331e3f8041950a47c765c96acd8e28eaeeda8430cab5098792e924973dec025b431194da67b420e14510b9c29de4d531d
    HEAD_REF main
    PATCHES clang22-warnings.patch
)

if(NOT VCPKG_TARGET_IS_LINUX OR NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    message(FATAL_ERROR "Sacramento PhysX overlay supports Linux x64 only")
endif()
if(NOT VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    message(FATAL_ERROR "Sacramento PhysX overlay requires static linkage")
endif()

set(PHYSX_ROOT_DIR "${SOURCE_PATH}/physx")
vcpkg_cmake_configure(
    SOURCE_PATH "${PHYSX_ROOT_DIR}/compiler/public"
    OPTIONS
        -DCMAKE_TOOLCHAIN_FILE=${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}
        -DTARGET_BUILD_PLATFORM=linux
        -DPX_OUTPUT_ARCH=x86
        -DPX_BUILDSNIPPETS=OFF
        -DPX_BUILDPVDRUNTIME=OFF
        -DPX_GENERATE_GPU_PROJECTS=OFF
        -DPX_GENERATE_GPU_PROJECTS_ONLY=OFF
        -DPX_GENERATE_STATIC_LIBRARIES=TRUE
        -DPHYSX_ROOT_DIR=${PHYSX_ROOT_DIR}
        -DPX_OUTPUT_LIB_DIR=${PHYSX_ROOT_DIR}
        -DPX_OUTPUT_BIN_DIR=${PHYSX_ROOT_DIR}
        -DCMAKE_INSTALL_PREFIX=${PHYSX_ROOT_DIR}/install/linux/PhysX
    DISABLE_PARALLEL_CONFIGURE
    MAYBE_UNUSED_VARIABLES
        PX_OUTPUT_ARCH
        PX_GENERATE_GPU_PROJECTS
        PX_GENERATE_GPU_PROJECTS_ONLY
)
vcpkg_cmake_install()

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib")
file(GLOB_RECURSE PHYSX_LIBRARIES
    LIST_DIRECTORIES false
    "${PHYSX_ROOT_DIR}/bin/*/release/*${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}"
)
file(COPY ${PHYSX_LIBRARIES} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include")
file(RENAME "${PHYSX_ROOT_DIR}/include" "${PHYSX_ROOT_DIR}/physx")
file(COPY "${PHYSX_ROOT_DIR}/physx" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/unofficial-omniverse-physx-sdk-config.cmake"
    "${CURRENT_PACKAGES_DIR}/share/unofficial-omniverse-physx-sdk/unofficial-omniverse-physx-sdk-config.cmake"
    COPYONLY
)
vcpkg_cmake_config_fixup(
    PACKAGE_NAME unofficial-omniverse-physx-sdk
    CONFIG_PATH share/unofficial-omniverse-physx-sdk
)
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/source"
)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
