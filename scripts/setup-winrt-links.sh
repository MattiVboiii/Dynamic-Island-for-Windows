#!/usr/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/third_party/winsdk/c/Include/10.0.22621.0/cppwinrt/winrt"
DST="$ROOT/third_party/winrt-case/winrt"
mkdir -p "$DST"

python3 <<'PY'
import pathlib
import re

root = pathlib.Path("/workspace/third_party/winsdk/c/Include/10.0.22621.0/cppwinrt/winrt")
dst = pathlib.Path("/workspace/third_party/winrt-case/winrt")

guard_re = re.compile(r"#ifndef WINRT_([A-Za-z0-9_]+)_H")

def guard_to_include(stem: str) -> str:
    return stem.replace("_", ".") + ".h"

linked = 0
for path in root.rglob("*.h"):
    text = path.read_text(encoding="utf-8", errors="ignore")
    m = guard_re.search(text)
    if not m:
        continue
    pascal_name = guard_to_include(m.group(1))
    rel_parent = path.parent.relative_to(root)
    out_dir = dst / rel_parent
    out_dir.mkdir(parents=True, exist_ok=True)
    for name in (pascal_name, path.name):
        link = out_dir / name
        if link.exists() or link.is_symlink():
            link.unlink()
        link.symlink_to(path.resolve())
        linked += 1

# base.h uses WINRT_BASE_H
base = root / "base.h"
link = dst / "base.h"
if link.exists() or link.is_symlink():
    link.unlink()
link.symlink_to(base.resolve())
linked += 1

print(f"Linked {linked} winrt header aliases under {dst}")
PY
