/*
* This file is part of the hexed project
*/

/*
* Header file to determine target OS and CPU architecture
*/

#ifndef __PLATFORM_H__
#define __PLATFORM_H__ 1

// Defines for operatings systems
#if defined(__gnu_linux__) || defined(__linux__)
#define IS_LINUX 1
#else
#define IS_LINUX 0
#endif
#if defined(__APPLE__) && defined(__MACH__)
#define IS_MACOSX 1
#else
#define IS_MACOSX 0
#endif
#if defined(_WIN32) || defined(_WIN64) || defined(__WIN32__) || defined(__WINDOWS__)
#define IS_WINDOWS 1
#else
#define IS_WINDOWS 0
#endif

#if defined(__i386__) || defined(__x86_64__) || defined(__amd64__)
#define __HEXED_ARCH__ "x86"
#define IS_X86 1
#endif

#if !(IS_X86)
#error Unknown architecture
#endif

#endif /* !__PLATFORM_H__ */