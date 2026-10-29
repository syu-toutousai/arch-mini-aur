#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KEY_FILE="$ROOT/keys/syu-mini-aur.asc"
REPO_NAME="syu-mini-aur"
SERVER="https://github.com/syu-toutousai/arch-mini-aur/releases/latest/download"
CONF="/etc/pacman.conf"

if [ "$(id -u)" -ne 0 ]; then
  echo "root で実行してください: sudo $0" >&2
  exit 1
fi
if [ ! -f "$KEY_FILE" ]; then
  echo "公開鍵がありません: $KEY_FILE" >&2
  exit 1
fi

BACKUP="${CONF}.bak.${REPO_NAME}.$(date +%Y%m%d-%H%M%S)"
cp -a "$CONF" "$BACKUP"
echo "backup: $BACKUP"

if ! grep -q "^\[$REPO_NAME\]" "$CONF"; then
  cat >> "$CONF" <<EOF

[$REPO_NAME]
SigLevel = Required DatabaseOptional
Server = $SERVER
EOF
  echo "追加: [$REPO_NAME] -> $CONF"
else
  echo "既に存在: [$REPO_NAME]"
fi

FPR="$(gpg --show-keys --with-colons "$KEY_FILE" | awk -F: '$1=="fpr"{print $10; exit}')"
if [ -z "$FPR" ]; then
  echo "fingerprint を取得できません: $KEY_FILE" >&2
  exit 1
fi

pacman-key --add "$KEY_FILE" >/dev/null 2>&1 || true
pacman-key --lsign-key "$FPR"
pacman -Sy

echo
echo "fingerprint: $FPR"
echo "== リポジトリ確認 =="
pacman -Si mechvibes webtorrent-mpv-hook | grep -E '^(リポジトリ|名前|バージョン)' || true
