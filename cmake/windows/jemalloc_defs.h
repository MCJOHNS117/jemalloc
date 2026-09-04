#pragma once

/*
 * DynastyEngine Windows/MSVC jemalloc configuration.
 *
 * This configuration intentionally targets:
 *   - Windows
 *   - MSVC
 *   - x64
 *   - static jemalloc
 *   - explicit je_* API
 */

#define JEMALLOC_CONFIG_ENV
#define JEMALLOC_CONFIG_FILE

#define JEMALLOC_INFALLIBLE_NEW 0

#ifdef _WIN64
#  define LG_SIZEOF_PTR 3
#else
#  error "DynastyEngine's jemalloc CMake build currently supports x64 only."
#endif
