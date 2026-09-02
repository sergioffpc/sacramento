# The pinned port tests VCPKG_TARGET_IS_WINDOWS before translating the triplet's
# CRT linkage to STEAMAUDIO_STATIC_RUNTIME. That helper is false for Sacramento's
# external clang-cl triplet even though CMAKE_SYSTEM_NAME is Windows.
if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Windows")
  set(VCPKG_TARGET_IS_WINDOWS TRUE)
endif()

set(SACRAMENTO_GATE2D_OVERLAY_PORT_DIR "${CURRENT_PORT_DIR}")
set(CURRENT_PORT_DIR "${VCPKG_ROOT_DIR}/ports/steam-audio")
include("${VCPKG_ROOT_DIR}/ports/steam-audio/portfile.cmake")
set(CURRENT_PORT_DIR "${SACRAMENTO_GATE2D_OVERLAY_PORT_DIR}")
unset(SACRAMENTO_GATE2D_OVERLAY_PORT_DIR)
