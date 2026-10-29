#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO="${REPO:-syu-toutousai/arch-mini-aur}"
TAG="${1:-}"

if [ -z "$TAG" ]; then
  echo "usage: $0 <tag>  (例: v2026.10.29)" >&2
  exit 1
fi

KEY="${KEY:-}"
if [ -z "$KEY" ]; then
  KEY="$(gpg --list-keys --with-colons "syu-toutousai mini-AUR" 2>/dev/null \
    | awk -F: '$1=="fpr"{print $10; exit}')"
fi
if [ -z "$KEY" ]; then
  echo "署名鍵が見つかりません。先に tools/gen-signing-key.sh を実行してください。" >&2
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "gh が必要です" >&2
  exit 1
fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

if [ -n "${ARTIFACT_DIR:-}" ]; then
  echo "==> ローカル artifact を使用: $ARTIFACT_DIR"
  cp -a "$ARTIFACT_DIR" "$WORK/repo"
  cd "$WORK/repo"
else
  RUN_ID="$(gh run list --repo "$REPO" --workflow build.yml --status success --limit 1 \
    --json databaseId --jq '.[0].databaseId')"
  if [ -z "$RUN_ID" ] || [ "$RUN_ID" = "null" ]; then
    echo "成功した CI ビルドがありません。GitHub Actions の完了後に再実行してください。" >&2
    exit 1
  fi

  echo "==> CI artifact を取得: run $RUN_ID"
  gh run download "$RUN_ID" --repo "$REPO" --name mini-aur --dir "$WORK"
  if [ -d "$WORK/repo" ]; then
    cd "$WORK/repo"
  else
    cd "$WORK"
  fi
fi
shopt -s nullglob
PKGS=(./*.pkg.tar.zst)
if [ "${#PKGS[@]}" -eq 0 ]; then
  echo "パッケージが artifact にありません" >&2
  exit 1
fi

if [ -n "${KEY_PASSPHRASE_FILE:-}" ]; then
  KEYGRIP="$(gpg --with-keygrip --list-secret-keys "$KEY" \
    | awk '/Keygrip/{print $NF; exit}')"
  if [ -z "$KEYGRIP" ]; then
    echo "keygrip を取得できません: $KEY" >&2
    exit 1
  fi
  if [ ! -x /usr/lib/gnupg/gpg-preset-passphrase ]; then
    echo "gpg-preset-passphrase が見つかりません" >&2
    exit 1
  fi
  /usr/lib/gnupg/gpg-preset-passphrase --preset "$KEYGRIP" < "$KEY_PASSPHRASE_FILE"
  echo "==> パスフレーズを gpg-agent に preset"
fi

echo "==> パッケージ署名: ${#PKGS[@]} 個"
for pkg in "${PKGS[@]}"; do
  gpg --batch --yes --local-user "$KEY" --detach-sign "$pkg"
done

echo "==> リポジトリ DB を更新・署名"
repo-add --sign --key "$KEY" --include-sigs syu-mini-aur.db.tar.gz "${PKGS[@]}"
cp --remove-destination syu-mini-aur.db.tar.gz syu-mini-aur.db
cp --remove-destination syu-mini-aur.files.tar.gz syu-mini-aur.files
gpg --batch --yes --local-user "$KEY" --detach-sign syu-mini-aur.db

echo "==> 署名を検証"
gpg --verify syu-mini-aur.db.sig syu-mini-aur.db
for pkg in "${PKGS[@]}"; do
  gpg --verify "$pkg.sig" "$pkg"
done

LOCAL_REPO_DIR="${LOCAL_REPO_DIR:-$ROOT/local-repo}"
echo "==> ローカルミラーを作成: $LOCAL_REPO_DIR"
rm -rf "$LOCAL_REPO_DIR"
mkdir -p "$LOCAL_REPO_DIR"
cp -a ./* "$LOCAL_REPO_DIR"/

mkdir -p "$ROOT/keys"
gpg --armor --export "$KEY" > "$ROOT/keys/syu-mini-aur.asc"
FPR="$(gpg --list-keys --with-colons "$KEY" | awk -F: '$1=="fpr"{print $10; exit}')"

cat > "$WORK/notes.md" <<EOF
arch-mini-aur $TAG

オフライン GPG 署名済みの pacman リポジトリです。

公開鍵 fingerprint: \`$FPR\`

インストール:

\`\`\`bash
curl -fsSLO https://github.com/$REPO/releases/latest/download/syu-mini-aur.asc
sudo pacman-key --add syu-mini-aur.asc
sudo pacman-key --lsign-key $FPR
\`\`\`

\`/etc/pacman.conf\`:

\`\`\`ini
[syu-mini-aur]
SigLevel = Required DatabaseOptional
Server = https://github.com/$REPO/releases/latest/download
\`\`\`
EOF

ASSETS=()
for f in "${PKGS[@]}" \
         "${PKGS[@]/%/.sig}" \
         syu-mini-aur.db \
         syu-mini-aur.db.sig \
         syu-mini-aur.db.tar.gz \
         syu-mini-aur.db.tar.gz.sig \
         syu-mini-aur.files \
         syu-mini-aur.files.tar.gz \
         "$ROOT/keys/syu-mini-aur.asc"; do
  [ -e "$f" ] && ASSETS+=("$f")
done

if [ "${DRY_RUN:-0}" = "1" ]; then
  echo "==> DRY_RUN: 署名と DB 検証は完了。リリースは作成しません。"
  echo "署名済み成果物: $(pwd)"
  exit 0
fi

if gh release view "$TAG" --repo "$REPO" >/dev/null 2>&1; then
  echo "==> 既存リリースを更新: $TAG"
  gh release upload "$TAG" --repo "$REPO" --clobber "${ASSETS[@]}"
  gh release edit "$TAG" --repo "$REPO" --draft=false --latest --notes-file "$WORK/notes.md"
else
  echo "==> リリースを作成: $TAG"
  gh release create "$TAG" --repo "$REPO" --title "$TAG" \
    --notes-file "$WORK/notes.md" --latest "${ASSETS[@]}"
fi

echo
echo "公開しました: https://github.com/$REPO/releases/tag/$TAG"
echo "fingerprint: $FPR"
echo "公開鍵をコミットしてください: git add keys/syu-mini-aur.asc && git commit -m 'add public key' && git push"
