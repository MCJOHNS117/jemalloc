# =============================================================================
# jemalloc generated headers
#
# Windows/MSVC CMake implementation for the DynastyEngine jemalloc fork.
# =============================================================================

function(jemalloc_generate_headers output_root)

    set(JEMALLOC_OUTPUT_DIR
        "${output_root}/include/jemalloc")

    set(JEMALLOC_INTERNAL_OUTPUT_DIR
        "${JEMALLOC_OUTPUT_DIR}/internal")

    file(MAKE_DIRECTORY
        "${JEMALLOC_OUTPUT_DIR}"
        "${JEMALLOC_INTERNAL_OUTPUT_DIR}"
    )

    # =========================================================================
    # Internal preamble
    # =========================================================================
    
    # We are not using a suffixed install name.
    set(install_suffix "")
    
    # Keep jemalloc's internal symbols under the je_ namespace.
    set(private_namespace "je_")
    
    configure_file(
        "${CMAKE_CURRENT_SOURCE_DIR}/include/jemalloc/internal/jemalloc_preamble.h.in"
        "${JEMALLOC_INTERNAL_OUTPUT_DIR}/jemalloc_preamble.h"
        @ONLY
    )

    # =========================================================================
    # Version
    #
    # The normal jemalloc configure system derives this from git describe.
    # Do the same, but fall back to the project version when building through
    # FetchContent or from an archive without Git metadata.
    # =========================================================================

    set(jemalloc_version "")
    set(jemalloc_version_major "${PROJECT_VERSION_MAJOR}")
    set(jemalloc_version_minor "${PROJECT_VERSION_MINOR}")
    set(jemalloc_version_bugfix "${PROJECT_VERSION_PATCH}")
    set(jemalloc_version_nrev "0")
    set(jemalloc_version_gid "0000000000000000000000000000000000000000")

    find_package(Git QUIET)

    if(GIT_FOUND)
        execute_process(
            COMMAND
                "${GIT_EXECUTABLE}"
                describe
                --long
                --always
                --dirty
            WORKING_DIRECTORY
                "${CMAKE_CURRENT_SOURCE_DIR}"
            OUTPUT_VARIABLE
                JEMALLOC_GIT_DESCRIBE
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET
            RESULT_VARIABLE
                JEMALLOC_GIT_RESULT
        )

        if(JEMALLOC_GIT_RESULT EQUAL 0)
            set(jemalloc_version
                "${JEMALLOC_GIT_DESCRIBE}")
        endif()
    endif()

    if(jemalloc_version STREQUAL "")
        set(jemalloc_version
            "${PROJECT_VERSION}")
    endif()

    # Git describe normally looks like:
    #
    #   5.3.0-12-gabcdef...
    #
    # Extract the revision count and SHA when available.
    string(REGEX MATCH
        "^([0-9]+)\\.([0-9]+)\\.([0-9]+)-([0-9]+)-g([0-9a-fA-F]+)"
        JEMALLOC_VERSION_MATCH
        "${jemalloc_version}"
    )

    if(JEMALLOC_VERSION_MATCH)
        set(jemalloc_version_major
            "${CMAKE_MATCH_1}")

        set(jemalloc_version_minor
            "${CMAKE_MATCH_2}")

        set(jemalloc_version_bugfix
            "${CMAKE_MATCH_3}")

        set(jemalloc_version_nrev
            "${CMAKE_MATCH_4}")

        set(jemalloc_version_gid
            "${CMAKE_MATCH_5}")
    endif()

    # jemalloc_macros.h.in expects this token to be usable as an identifier.
    string(REGEX REPLACE
        "[^A-Za-z0-9_]"
        "_"
        jemalloc_version_gid_ident
        "${jemalloc_version_gid}"
    )

    # =========================================================================
    # Platform configuration
    # =========================================================================

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

    # =========================================================================
    # Public template headers
    # =========================================================================

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


# =============================================================================
# Generate rename/mangle headers directly from jemalloc_protos.h.in.
#
# Upstream configure creates public_symbols.txt first and then feeds that file
# through shell scripts. For this Windows CMake build, parsing @je_@ symbols
# directly gives us the same canonical public API set without requiring Bash,
# awk, sed, or an intermediate generated file.
# =============================================================================

function(jemalloc_generate_symbol_headers output_root)

    set(JEMALLOC_OUTPUT_DIR
        "${output_root}/include/jemalloc")

    set(JEMALLOC_PROTOS_TEMPLATE
        "${CMAKE_CURRENT_SOURCE_DIR}/include/jemalloc/jemalloc_protos.h.in")

    file(READ
        "${JEMALLOC_PROTOS_TEMPLATE}"
        JEMALLOC_PROTOS_CONTENT
    )

    # Find every @je_@<symbol> occurrence.
    string(REGEX MATCHALL
        "@je_@[A-Za-z_][A-Za-z0-9_]*"
        JEMALLOC_SYMBOL_MATCHES
        "${JEMALLOC_PROTOS_CONTENT}"
    )

    set(JEMALLOC_PUBLIC_SYMBOLS)

    foreach(symbol_match IN LISTS JEMALLOC_SYMBOL_MATCHES)

        string(REPLACE
            "@je_@"
            ""
            symbol
            "${symbol_match}"
        )

        list(APPEND
            JEMALLOC_PUBLIC_SYMBOLS
            "${symbol}"
        )

    endforeach()

    list(REMOVE_DUPLICATES
        JEMALLOC_PUBLIC_SYMBOLS)

    list(SORT
        JEMALLOC_PUBLIC_SYMBOLS)

    if(NOT JEMALLOC_PUBLIC_SYMBOLS)
        message(FATAL_ERROR
            "Unable to discover jemalloc public symbols from "
            "${JEMALLOC_PROTOS_TEMPLATE}.")
    endif()

    message(STATUS
        "jemalloc: discovered public symbols: ${JEMALLOC_PUBLIC_SYMBOLS}")

    # =========================================================================
    # jemalloc_rename.h
    #
    # We deliberately retain the je_ namespace. DynastyEngine calls je_malloc,
    # je_free, etc. explicitly rather than replacing the CRT allocator.
    # =========================================================================

    set(RENAME_CONTENT
"/*
 * Generated by CMake.
 *
 * DynastyEngine keeps jemalloc's je_ namespace explicit.
 */
#ifndef JEMALLOC_RENAME_H_
#define JEMALLOC_RENAME_H_

#ifndef JEMALLOC_NO_RENAME
")

    foreach(symbol IN LISTS JEMALLOC_PUBLIC_SYMBOLS)

        string(APPEND
            RENAME_CONTENT
            "#  define je_${symbol} je_${symbol}\n"
        )

    endforeach()

    string(APPEND
        RENAME_CONTENT
"#endif

#endif /* JEMALLOC_RENAME_H_ */
")

    file(WRITE
        "${JEMALLOC_OUTPUT_DIR}/jemalloc_rename.h"
        "${RENAME_CONTENT}"
    )

    # =========================================================================
    # jemalloc_mangle.h
    # =========================================================================

    set(MANGLE_CONTENT
"/*
 * Generated by CMake.
 */
#ifndef JEMALLOC_MANGLE_H_
#define JEMALLOC_MANGLE_H_

#ifdef JEMALLOC_MANGLE
#  ifndef JEMALLOC_NO_DEMANGLE
#    define JEMALLOC_NO_DEMANGLE
#  endif
")

    foreach(symbol IN LISTS JEMALLOC_PUBLIC_SYMBOLS)

        string(APPEND
            MANGLE_CONTENT
            "#  define ${symbol} je_${symbol}\n"
        )

    endforeach()

    string(APPEND
        MANGLE_CONTENT
"#endif

#ifndef JEMALLOC_NO_DEMANGLE
")

    foreach(symbol IN LISTS JEMALLOC_PUBLIC_SYMBOLS)

        string(APPEND
            MANGLE_CONTENT
            "#  undef je_${symbol}\n"
        )

    endforeach()

    string(APPEND
        MANGLE_CONTENT
"#endif

#endif /* JEMALLOC_MANGLE_H_ */
")

    file(WRITE
        "${JEMALLOC_OUTPUT_DIR}/jemalloc_mangle.h"
        "${MANGLE_CONTENT}"
    )

endfunction()


# =============================================================================
# Generate the final public jemalloc.h.
#
# Upstream's jemalloc.sh concatenates these generated headers in exactly this
# order.
# =============================================================================

function(jemalloc_generate_public_header output_root)

    set(JEMALLOC_OUTPUT_DIR
        "${output_root}/include/jemalloc")

    set(JEMALLOC_HEADER_CONTENT
"#ifndef JEMALLOC_H_
#define JEMALLOC_H_

")

    foreach(header
        jemalloc_defs.h
        jemalloc_rename.h
        jemalloc_macros.h
        jemalloc_protos.h
        jemalloc_typedefs.h
        jemalloc_mangle.h
    )

        set(HEADER_PATH
            "${JEMALLOC_OUTPUT_DIR}/${header}")

        if(NOT EXISTS "${HEADER_PATH}")
            message(FATAL_ERROR
                "Required generated jemalloc header does not exist: "
                "${HEADER_PATH}")
        endif()

        file(READ
            "${HEADER_PATH}"
            HEADER_CONTENT
        )

        string(APPEND
            JEMALLOC_HEADER_CONTENT
            "${HEADER_CONTENT}\n"
        )

    endforeach()

    string(APPEND
        JEMALLOC_HEADER_CONTENT
"
#endif /* JEMALLOC_H_ */
")

    file(WRITE
        "${JEMALLOC_OUTPUT_DIR}/jemalloc.h"
        "${JEMALLOC_HEADER_CONTENT}"
    )

endfunction()
