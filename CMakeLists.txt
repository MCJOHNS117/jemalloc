cmake_minimum_required(VERSION 3.24)

project(
    jemalloc
    VERSION 5.3.0
    LANGUAGES C
)

if(NOT WIN32)
    message(FATAL_ERROR
        "This CMake build currently targets Windows only.")
endif()

if(NOT MSVC)
    message(FATAL_ERROR
        "This CMake build currently targets MSVC only.")
endif()

if(NOT CMAKE_SIZEOF_VOID_P EQUAL 8)
    message(FATAL_ERROR
        "This CMake build currently targets x64 only.")
endif()

include(GNUInstallDirs)

option(
    JEMALLOC_BUILD_TESTS
    "Build jemalloc tests."
    OFF
)

option(
    JEMALLOC_INSTALL
    "Install jemalloc."
    ON
)

# =============================================================================
# Generated headers
# =============================================================================

include(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/JemallocGenerateHeaders.cmake"
)

set(
    JEMALLOC_GENERATED_ROOT
    "${CMAKE_CURRENT_BINARY_DIR}/generated"
)

jemalloc_generate_headers(
    "${JEMALLOC_GENERATED_ROOT}"
)

jemalloc_generate_symbol_headers(
    "${JEMALLOC_GENERATED_ROOT}"
)

jemalloc_generate_public_header(
    "${JEMALLOC_GENERATED_ROOT}"
)

# =============================================================================
# Sources
# =============================================================================

set(
    JEMALLOC_SOURCES

    src/arena.c
    src/arenas_management.c
    src/background_thread.c
    src/base.c
    src/bin.c
    src/bin_info.c
    src/bitmap.c
    src/buf_writer.c
    src/cache_bin.c
    src/ckh.c
    src/conf.c
    src/counter.c
    src/ctl.c
    src/decay.c
    src/div.c
    src/ecache.c
    src/edata.c
    src/edata_cache.c
    src/ehooks.c
    src/emap.c
    src/eset.c
    src/exp_grow.c
    src/extent.c
    src/extent_dss.c
    src/extent_mmap.c
    src/fxp.c
    src/hook.c
    src/hpa.c
    src/hpa_central.c
    src/hpa_hooks.c
    src/hpa_utils.c
    src/hpdata.c
    src/inspect.c
    src/jemalloc.c
    src/jemalloc_fork.c
    src/jemalloc_init.c
    src/large.c
    src/log.c
    src/malloc_dispatch.c
    src/malloc_io.c
    src/mutex.c
    src/nstime.c
    src/pa.c
    src/pa_extra.c
    src/pac.c
    src/pages.c
    src/peak_event.c
    src/prof.c
    src/prof_data.c
    src/prof_log.c
    src/prof_recent.c
    src/prof_stats.c
    src/prof_sys.c
    src/psset.c
    src/rtree.c
    src/safety_check.c
    src/san.c
    src/san_bump.c
    src/sc.c
    src/sec.c
    src/stats.c
    src/sz.c
    src/tcache.c
    src/test_hooks.c
    src/thread_event.c
    src/thread_event_registry.c
    src/ticker.c
    src/tsd.c
    src/util.c
    src/witness.c
)

add_library(
    jemalloc
    STATIC
        ${JEMALLOC_SOURCES}
)

add_library(
    jemalloc::jemalloc
    ALIAS
    jemalloc
)

target_include_directories(
    jemalloc
    PUBLIC
        $<BUILD_INTERFACE:${JEMALLOC_GENERATED_ROOT}/include>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
    PRIVATE
        "${CMAKE_CURRENT_SOURCE_DIR}/include"
        "${CMAKE_CURRENT_SOURCE_DIR}/include/msvc_compat"
)

target_compile_definitions(
    jemalloc
    PRIVATE
        _REENTRANT
        _LIB
        JEMALLOC_EXPORT=
        JEMALLOC_NO_PRIVATE_NAMESPACE
        WIN32_LEAN_AND_MEAN
        NOMINMAX
        _CRT_SECURE_NO_WARNINGS
)

target_compile_options(
    jemalloc
    PRIVATE
        /W3
        /wd4090
        /wd4146
        /wd4267
        /wd4334
)

target_compile_definitions(
    jemalloc
    PRIVATE
        $<$<CONFIG:Debug>:JEMALLOC_DEBUG>
)

set_target_properties(
    jemalloc
    PROPERTIES
        OUTPUT_NAME jemalloc
        DEBUG_POSTFIX ""
)

set_property(
    TARGET jemalloc
    PROPERTY
    MSVC_RUNTIME_LIBRARY
        "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL"
)

if(JEMALLOC_INSTALL)

    install(
        TARGETS jemalloc
        EXPORT jemallocTargets
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    )

    install(
        FILES
            "${JEMALLOC_GENERATED_ROOT}/include/jemalloc/jemalloc.h"
        DESTINATION
            "${CMAKE_INSTALL_INCLUDEDIR}/jemalloc"
    )

    install(
        EXPORT jemallocTargets
        FILE jemallocTargets.cmake
        NAMESPACE jemalloc::
        DESTINATION
            "${CMAKE_INSTALL_LIBDIR}/cmake/jemalloc"
    )

endif()
