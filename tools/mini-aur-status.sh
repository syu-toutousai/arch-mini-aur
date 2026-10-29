#!/usr/bin/env bash
set -euo pipefail

REPO="${REPO:-syu-mini-aur}"

if ! pacman -Sl "$REPO" >/dev/null 2>&1; then
  echo "error: '$REPO' は /etc/pacman.conf に登録されていません。" >&2
  echo "先にリポジトリの追加と 'sudo pacman -Sy' を行ってください。" >&2
  exit 1
fi

echo "== $REPO =="
pacman -Sl "$REPO" | awk '{printf "%-32s %-20s %s\n", $2, $3, ($4=="[installed]" ? "installed" : "")}'

echo
echo "== $REPO からインストール済み =="
pacman -Sl "$REPO" | awk '$4=="[installed]"{print $2, $3}'

echo
echo "== foreign（pacman -Qm） =="
pacman -Qm || true
