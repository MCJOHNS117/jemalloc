function(jemalloc_generate_headers output_root)

    set(JEMALLOC_OUTPUT_DIR
        "${output_root}/include/jemalloc")

    set(JEMALLOC_INTERNAL_OUTPUT_DIR
        "${JEMALLOC_OUTPUT_DIR}/internal")

    file(MAKE_DIRECTORY
        "${JEMALLOC_OUTPUT_DIR}"
        "${JEMALLOC_INTERNAL_OUTPUT_DIR}"
    )

    # -------------------------------------------------------------------------
    # Platform configuration headers
    # -------------------------------------------------------------------------

    configure_file(
        "${CMAKE_CURRENT_SOURCE_DIR}/cmake/windows/jemalloc_defs.h"
        "${JEMALLOC_OUTPUT_DIR}/jemalloc_defs.h"
        COPYONLY
    )

    configure_file(
        "${CMAKE_CURRENT_SOURCE_DIR}/cmake/windows/jemalloc_internal_defs.h"
        "${JEMALLOC_INTERNAL_OUTPUT_DIR}/jemalloc_internal_defs.h"
        COPYONLY
    )

    # -------------------------------------------------------------------------
    # Version information
    # -------------------------------------------------------------------------

    file(READ
        "${CMAKE_CURRENT_SOURCE_DIR}/VERSION"
        JEMALLOC_VERSION_RAW
    )

    string(STRIP
        "${JEMALLOC_VERSION_RAW}"
        JEMALLOC_VERSION_RAW
    )

    string(REGEX MATCH
        "^([0-9]+)\\.([0-9]+)\\.([0-9]+)"
        JEMALLOC_VERSION_MATCH
        "${JEMALLOC_VERSION_RAW}"
    )

    if(NOT JEMALLOC_VERSION_MATCH)
        message(FATAL_ERROR
            "Unable to parse jemalloc VERSION: ${JEMALLOC_VERSION_RAW}")
    endif()

    set(jemalloc_version
        "${JEMALLOC_VERSION_RAW}")

    set(jemalloc_version_major
        "${CMAKE_MATCH_1}")

    set(jemalloc_version_minor
        "${CMAKE_MATCH_2}")

    set(jemalloc_version_bugfix
        "${CMAKE_MATCH_3}")

    set(jemalloc_version_nrev 0)
    set(jemalloc_version_gid 0000000000000000000000000000000000000000)

    # -------------------------------------------------------------------------
    # Public generated headers
    # -------------------------------------------------------------------------

    configure_file(
        "${CMAKE_CURRENT_SOURCE_DIR}/include/jemalloc/jemalloc_macros.h.in"
        "${JEMALLOC_OUTPUT_DIR}/jemalloc_macros.h"
        @ONLY
    )

    configure_file(
        "${CMAKE_CURRENT_SOURCE_DIR}/include/jemalloc/jemalloc_protos.h.in"
        "${JEMALLOC_OUTPUT_DIR}/jemalloc_protos.h"
        @ONLY
    )

    configure_file(
        "${CMAKE_CURRENT_SOURCE_DIR}/include/jemalloc/jemalloc_typedefs.h.in"
        "${JEMALLOC_OUTPUT_DIR}/jemalloc_typedefs.h"
        @ONLY
    )

endfunction()
