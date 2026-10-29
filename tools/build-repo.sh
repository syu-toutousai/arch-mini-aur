#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_DIR="${REPO_DIR:-$ROOT/repo}"
export PACKAGER="${PACKAGER:-syu-toutousai <167145022+syu-toutousai@users.noreply.github.com>}"

for d in "$ROOT"/pkgs/*/; do
  echo "==> build: $(basename "$d")"
  ( cd "$d" && makepkg -f --nodeps )
done

rm -rf "$REPO_DIR"
mkdir -p "$REPO_DIR"
cp "$ROOT"/pkgs/*/*.pkg.tar.zst "$REPO_DIR"/

(
  cd "$REPO_DIR"
  repo-add syu-mini-aur.db.tar.gz ./*.pkg.tar.zst
  cp --remove-destination syu-mini-aur.db.tar.gz syu-mini-aur.db
  cp --remove-destination syu-mini-aur.files.tar.gz syu-mini-aur.files
)

echo
echo "未署名の staging repo: $REPO_DIR"
echo "署名と公開: tools/sign-and-publish.sh <tag>"
