#pragma once

#ifndef __cpp_lib_coroutine
#define __cpp_lib_coroutine 201902L
#endif

#ifndef _MSC_VER
#define __pragma(...)
#endif

#include <windows.h>
#include <cstdarg>

#ifndef WH_MOD_ID
#define WH_MOD_ID L"dynamic-island-for-windows"
#endif

inline void Wh_Log(const wchar_t*, ...) {}
inline int Wh_GetIntSetting(const wchar_t*) { return 0; }
inline PCWSTR Wh_GetStringSetting(const wchar_t*) { return L""; }
inline void Wh_FreeStringSetting(PCWSTR) {}
inline int Wh_GetIntValue(const wchar_t*, int def) { return def; }
inline size_t Wh_GetStringValue(const wchar_t*, PWSTR buffer, size_t bufferChars) {
    if (buffer && bufferChars > 0) {
        buffer[0] = L'\0';
    }
    return 0;
}
inline void Wh_SetIntValue(const wchar_t*, int) {}
inline void Wh_SetStringValue(const wchar_t*, PCWSTR) {}
inline BOOL Wh_SetFunctionHook(void*, void*, void**) { return TRUE; }
