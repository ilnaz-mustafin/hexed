/*
* This file is part of the hexed project
*/

/*
* Header file for OS checking
*/

#include "platform.h"

#if defined(__linux__)
#define __HEXED_OS__ "Linux"
#elif defined(__APPLE__) && defined(__MACH__)
#define __HEXED_OS__ "Darwin"
#elif defined(__MINGW32__)
#define __HEXED_OS__ "MinGW"
#endif
__HEXED_OS__