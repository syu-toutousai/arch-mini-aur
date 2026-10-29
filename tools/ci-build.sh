#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PACKAGER="${PACKAGER:-syu-toutousai <167145022+syu-toutousai@users.noreply.github.com>}"

for d in "$ROOT"/pkgs/*/; do
  echo "==> build: $(basename "$d")"
  ( cd "$d" && makepkg -s --noconfirm )
done
