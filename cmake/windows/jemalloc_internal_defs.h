#ifndef JEMALLOC_INTERNAL_DEFS_H_
#define JEMALLOC_INTERNAL_DEFS_H_

/*
 * Public allocator namespace.
 *
 * DynastyEngine explicitly calls je_malloc / je_free rather than replacing
 * the process CRT allocator.
 */
#define JEMALLOC_PREFIX "je_"
#define JEMALLOC_CPREFIX "JE_"

/*
 * Avoid collisions when statically linking jemalloc.
 */
#define JEMALLOC_PRIVATE_NAMESPACE je_

/*
 * Windows/MSVC atomics.
 */
#define HAVE_CPU_SPINWAIT 1

#if defined(_M_X64) || defined(_M_IX86)
#  define CPU_SPINWAIT _mm_pause()
#endif

/*
 * x64 Windows virtual addressing.
 */
#define LG_VADDR 48

/*
 * MSVC uses its dedicated atomic implementation.
 */
#undef JEMALLOC_C11_ATOMICS
#undef JEMALLOC_GCC_ATOMIC_ATOMICS
#undef JEMALLOC_GCC_U8_ATOMIC_ATOMICS
#undef JEMALLOC_GCC_SYNC_ATOMICS
#undef JEMALLOC_GCC_U8_SYNC_ATOMICS

/*
 * Windows initialization/thread model.
 */
#define JEMALLOC_THREADED_INIT

/*
 * TLS support.
 */
#define JEMALLOC_TLS

/*
 * Useful allocator functionality.
 */
#define JEMALLOC_STATS
#define JEMALLOC_FILL

/*
 * jemalloc's own profiling is disabled.
 *
 * DynastyEngine uses Tracy for allocation profiling.
 */
#undef JEMALLOC_PROF
#undef JEMALLOC_PROF_LIBUNWIND
#undef JEMALLOC_PROF_LIBGCC
#undef JEMALLOC_PROF_GCC

/*
 * No Unix DSS/sbrk support.
 */
#undef JEMALLOC_DSS

/*
 * Windows VirtualAlloc mappings do not behave like mmap mappings.
 */
#undef JEMALLOC_MAPS_COALESCE

/*
 * Retaining virtual address space is the expected 64-bit Windows behavior.
 */
#define JEMALLOC_RETAIN

/*
 * Fundamental size configuration.
 *
 * Windows LLP64:
 *   int       = 4
 *   long      = 4
 *   long long = 8
 *   intmax_t  = 8
 */
#define LG_SIZEOF_INT        2
#define LG_SIZEOF_LONG       2
#define LG_SIZEOF_LONG_LONG  3
#define LG_SIZEOF_INTMAX_T   3

/*
 * Allocation geometry.
 */
#define LG_QUANTUM 4
#define LG_PAGE    12
#define LG_HUGEPAGE 21

/*
 * Cache-oblivious large allocations.
 */
#define JEMALLOC_CACHE_OBLIVIOUS

/*
 * malloc_conf environment support.
 */
#define JEMALLOC_FORCE_GETENV

/*
 * No POSIX/Linux page APIs.
 */
#undef JEMALLOC_HAVE_MADVISE
#undef JEMALLOC_HAVE_MPROTECT
#undef JEMALLOC_HAVE_POSIX_MADVISE
#undef JEMALLOC_HAVE_PROCESS_MADVISE
#undef JEMALLOC_HAVE_MEMCNTL

/*
 * Windows is little-endian.
 */
#undef JEMALLOC_BIG_ENDIAN

/*
 * No pthreads/dlsym.
 */
#undef JEMALLOC_HAVE_PTHREAD
#undef JEMALLOC_HAVE_DLSYM
#undef JEMALLOC_HAVE_PTHREAD_ATFORK
#undef JEMALLOC_HAVE_PTHREAD_SETNAME_NP
#undef JEMALLOC_HAVE_PTHREAD_GETNAME_NP
#undef JEMALLOC_HAVE_PTHREAD_SET_NAME_NP
#undef JEMALLOC_HAVE_PTHREAD_GET_NAME_NP

/*
 * No Unix background-thread implementation.
 */
#undef JEMALLOC_BACKGROUND_THREAD

/*
 * Static library: no DLL export decoration.
 */
#define JEMALLOC_EXPORT

/*
 * DynastyEngine does not replace malloc/free globally.
 */
#undef JEMALLOC_IS_MALLOC

/*
 * C++ operator-new integration is not built into jemalloc.
 */
#undef JEMALLOC_ENABLE_CXX

/*
 * realloc(ptr, 0) follows modern Windows/Linux free semantics.
 */
#define JEMALLOC_ZERO_REALLOC_DEFAULT_FREE

/* =========================================================================
 * Compiler capabilities
 * ========================================================================= */

#define JEMALLOC_INTERNAL_UNREACHABLE abort

#endif
