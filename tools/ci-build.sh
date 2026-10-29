#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PACKAGER="${PACKAGER:-syu-toutousai <167145022+syu-toutousai@users.noreply.github.com>}"

ORDER=(
  lib32-libtirpc
  lib32-libnsl
  lib32-libraw1394
  lib32-libiec61883
  lib32-libtheora
  lib32-speex
  lib32-libshout
  lib32-popt
  lib32-libdv
  lib32-audit
  lib32-pam
  lib32-polkit
  lib32-pcsclite
  lib32-taglib
  lib32-wavpack
)

build_one() {
  local name="$1" d="$ROOT/pkgs/$name"
  local extra=()
  if [ -f "$d/.local-only" ]; then
    echo "==> skip local-only: $name"
    return 0
  fi
  case "$name" in
    lib32-polkit|lib32-pcsclite) extra+=(--nocheck) ;;
  esac
  echo "==> build: $name"
  ( cd "$d" && makepkg -s --noconfirm "${extra[@]}" )
  local pkgs=()
  while IFS= read -r -d '' p; do pkgs+=("$p"); done \
    < <(find "$d" -maxdepth 1 -name '*.pkg.tar.zst' ! -name '*-debug-*' -print0)
  if [ "${#pkgs[@]}" -gt 0 ]; then
    sudo pacman -U --noconfirm --needed "${pkgs[@]}"
  fi
}

declare -A built=()
for name in "${ORDER[@]}"; do
  [ -d "$ROOT/pkgs/$name" ] || continue
  build_one "$name"
  built["$name"]=1
done

for d in "$ROOT"/pkgs/*/; do
  name="$(basename "$d")"
  [ -n "${built[$name]:-}" ] && continue
  build_one "$name"
done
