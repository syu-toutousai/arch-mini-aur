#!/usr/bin/env bash
set -euo pipefail

DIR="${1:-repo}"
cd "$DIR"

gpg --verify syu-mini-aur.db.sig syu-mini-aur.db

shopt -s nullglob
for pkg in ./*.pkg.tar.zst; do
  gpg --verify "$pkg.sig" "$pkg"
done

echo "署名検証 OK: $DIR"
