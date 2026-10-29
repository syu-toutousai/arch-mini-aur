#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KEY_UID="${KEY_UID:-syu-toutousai mini-AUR <167145022+syu-toutousai@users.noreply.github.com>}"

if gpg --list-keys "$KEY_UID" >/dev/null 2>&1; then
  echo "既に鍵があります: $KEY_UID"
  gpg --list-keys --keyid-format long "$KEY_UID"
  exit 1
fi

GPG_OPTS=()
if [ -n "${KEY_PASSPHRASE_FILE:-}" ]; then
  echo "GPG 署名鍵を生成します（パスフレーズファイル: $KEY_PASSPHRASE_FILE）。"
  GPG_OPTS=(--batch --pinentry-mode loopback --passphrase-file "$KEY_PASSPHRASE_FILE")
else
  echo "GPG 署名鍵を生成します。パスフレーズを設定してください。"
fi
echo "UID: $KEY_UID"
gpg "${GPG_OPTS[@]}" --quick-generate-key "$KEY_UID" ed25519 sign 2y

FPR="$(gpg --list-keys --with-colons "$KEY_UID" | awk -F: '$1=="fpr"{print $10; exit}')"
if [ -z "$FPR" ]; then
  echo "fingerprint を取得できませんでした" >&2
  exit 1
fi

mkdir -p "$ROOT/keys"
gpg --armor --export "$FPR" > "$ROOT/keys/syu-mini-aur.asc"
chmod 644 "$ROOT/keys/syu-mini-aur.asc"

echo
echo "fingerprint: $FPR"
echo "公開鍵: $ROOT/keys/syu-mini-aur.asc"
echo "秘密鍵は ~/.gnupg にあります。必ずバックアップし、GitHub には置かないでください。"
echo "公開鍵をコミットしてください: git add keys/syu-mini-aur.asc"
