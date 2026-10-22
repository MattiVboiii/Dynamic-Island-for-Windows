#!/usr/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/dynamic-island-for-windows.wh.cpp"
SDK="$ROOT/third_party/winsdk/c/Include/10.0.22621.0"
WINRT="$ROOT/third_party/winrt-case"
WINRT_SDK="$SDK/cppwinrt"
STUB="$ROOT/scripts/wh_mod_stub.h"

if [[ ! -f "$WINRT_SDK/winrt/base.h" ]]; then
  echo "Missing C++/WinRT headers at $WINRT_SDK (extract Microsoft.Windows.SDK.Cpp nuget)." >&2
  exit 1
fi
if [[ ! -f "$WINRT/winrt/base.h" ]]; then
  "$ROOT/scripts/setup-winrt-links.sh"
fi

CXX="${CXX:-x86_64-w64-mingw32-g++}"
OUT="${1:-/tmp/dynamic-island-for-windows.o}"

LIBS=(
  -lole32 -loleaut32 -lshcore -ld2d1 -ldwrite -ldwmapi -lgdi32 -luser32 -lshell32
  -lruntimeobject -lwindowscodecs -lavrt -lsetupapi -lwinhttp -lpdh -lwinmm -liphlpapi
)

# Use MinGW's Windows/UCRT headers; only pull C++/WinRT projections from the SDK nuget.
set +e
"$CXX" -std=c++23 -fcoroutines -c "$SRC" -o "$OUT" \
  -include "$STUB" \
  -I"$WINRT" \
  -I"$WINRT_SDK" \
  -DWINVER=0x0A00 -D_WIN32_WINNT=0x0A00 \
  -DNTDDI_VERSION=0x0A000000 \
  -D__cpp_lib_coroutines=202002L \
  -D__cpp_lib_coroutine=201902L \
  -DUNICODE -D_UNICODE \
  -DDYNAMIC_ISLAND_CROSS_COMPILE=1 \
  -Wno-unknown-pragmas -Wno-unused-function -fpermissive -fms-extensions \
  "${LIBS[@]}"
status=$?
set -e
if [[ $status -ne 0 ]]; then
  echo "Compile failed (exit $status)." >&2
  exit "$status"
fi

echo "Compiled object: $OUT"
