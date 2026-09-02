include(${CMAKE_ROOT}/Modules/SelectLibraryConfigurations.cmake)

if(TARGET unofficial::omniverse-physx-sdk::sdk)
    return()
endif()

get_filename_component(_physx_prefix "${CMAKE_CURRENT_LIST_FILE}" DIRECTORY)
get_filename_component(_physx_prefix "${_physx_prefix}" DIRECTORY)
get_filename_component(_physx_prefix "${_physx_prefix}" DIRECTORY)
set(_physx_lib_dir "${_physx_prefix}/lib")

find_library(_physx_main
    NAMES PhysX_static_64
    PATHS "${_physx_lib_dir}"
    NO_DEFAULT_PATH
    NO_CMAKE_FIND_ROOT_PATH
    REQUIRED
)
add_library(unofficial::omniverse-physx-sdk::sdk UNKNOWN IMPORTED)
set_target_properties(unofficial::omniverse-physx-sdk::sdk PROPERTIES
    IMPORTED_LOCATION "${_physx_main}"
    INTERFACE_INCLUDE_DIRECTORIES "${_physx_prefix}/include/physx"
)

set(_physx_components
    PhysXExtensions
    PhysXPvdSDK
    PhysXCommon
    PhysXFoundation
)
foreach(_component IN LISTS _physx_components)
    unset(_physx_component_library)
    find_library(_physx_component_library
        NAMES "${_component}_static_64"
        PATHS "${_physx_lib_dir}"
        NO_DEFAULT_PATH
        NO_CMAKE_FIND_ROOT_PATH
        REQUIRED
        NO_CACHE
    )
    add_library("unofficial::omniverse-physx-sdk::${_component}" UNKNOWN IMPORTED)
    set_target_properties("unofficial::omniverse-physx-sdk::${_component}" PROPERTIES
        IMPORTED_LOCATION "${_physx_component_library}"
    )
    set_property(TARGET unofficial::omniverse-physx-sdk::sdk APPEND PROPERTY
        INTERFACE_LINK_LIBRARIES "unofficial::omniverse-physx-sdk::${_component}"
    )
endforeach()
