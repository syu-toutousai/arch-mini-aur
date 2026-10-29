# 署名とリリース

このリポジトリは **オフライン署名** を採用します。CI はビルドと検証だけを行い、秘密鍵は手元の GPG 鍵リングから出ません。

## 信頼の構造

```
上流ソース/成果物 --SHA-256固定--> CI ビルド --未署名artifact--> 手元で署名 --Release--> pacman
                                                              ^
                                                         手元のGPG秘密鍵
```

- GitHub アカウントが侵害されても、攻撃者は CI を書き換えて未署名 artifact を作ることはできても、**署名済みパッケージ**は作れません。
- pacman は `SigLevel = Required DatabaseOptional` でパッケージ署名を必須にします。
- 公開鍵は `keys/syu-mini-aur.asc` と Release に掲載します。

## 1. 鍵の生成（初回のみ）

```bash
./tools/gen-signing-key.sh
```

- UID: `syu-toutousai mini-AUR <167145022+syu-toutousai@users.noreply.github.com>`
- アルゴリズム: Ed25519（署名用）、有効期限 2 年
- パスフレーズは対話的に設定されます
- 公開鍵: `keys/syu-mini-aur.asc`
- 秘密鍵: `~/.gnupg`（**GitHub に置かない**）

表示された fingerprint をメモし、公開鍵をコミットします。

```bash
git add keys/syu-mini-aur.asc
git commit -m "add mini-AUR public key"
git push
```

### バックアップ

秘密鍵を失うと、既存ユーザーに新しい鍵を配るまで更新を署名できなくなります。暗号化したオフラインバックアップを取ってください。

```bash
gpg --export-secret-keys --armor <FINGERPRINT> > mini-aur-secret.asc
# 安全な場所へ移動し、必要なら暗号化する。リポジトリには絶対に置かない。
```

## 2. ビルド（CI）

`main` への push で GitHub Actions が全パッケージをビルドし、未署名の `mini-aur` artifact を作ります。

- `mechvibes`: 公式 deb を SHA-256 検証 → asar 日本語化 → `check()`
- `webtorrent-mpv-hook`: 上流タグ + `package-lock.json` → `npm ci` → `npm run build` → `npm prune --omit=dev` → `check()`
- `repo-add` で未署名の staging DB を作成

CI は Release を作りません。

## 3. 署名と公開

CI 完了後:

```bash
./tools/sign-and-publish.sh v2026.10.29
```

スクリプトの処理:

1. 最新の成功 CI artifact を `gh run download` で取得
2. 各 `*.pkg.tar.zst` を `gpg --detach-sign` で署名（`.sig`）
3. `repo-add --sign --include-sigs` で DB を更新・署名
4. `syu-mini-aur.db` と `.db.sig` を生成
5. `gpg --verify` で DB と全パッケージを検証
6. `keys/syu-mini-aur.asc` を更新
7. GitHub Release を `latest` として作成（既存なら asset を置換）

### ドライラン

リリースを作らず、署名と検証だけを試す:

```bash
DRY_RUN=1 ./tools/sign-and-publish.sh v-test
```

ローカルの staging repo を使う場合:

```bash
./tools/build-repo.sh
DRY_RUN=1 ARTIFACT_DIR=repo ./tools/sign-and-publish.sh v-test
```

## 4. クライアント側

```bash
curl -fsSLO https://github.com/syu-toutousai/arch-mini-aur/releases/latest/download/syu-mini-aur.asc
sudo pacman-key --add syu-mini-aur.asc
sudo pacman-key --lsign-key <FINGERPRINT>
```

`/etc/pacman.conf`:

```ini
[syu-mini-aur]
SigLevel = Required DatabaseOptional
Server = https://github.com/syu-toutousai/arch-mini-aur/releases/latest/download
```

```bash
sudo pacman -Sy
sudo pacman -S mechvibes webtorrent-mpv-hook
```

### 検証

```bash
./tools/verify-repo.sh repo
pacman -Qkk mechvibes webtorrent-mpv-hook
```

## 鍵のローテーション

1. 新しい鍵を生成（`KEY_UID` を変える）
2. 新しい公開鍵を配布し、`pacman-key --lsign-key` してもらう
3. 全パッケージと DB を新鍵で再署名して Release
4. 旧鍵を失効（`gpg --gen-revoke`）し、公開鍵を更新

`SigLevel = Required DatabaseOptional` のため、パッケージ署名が検証できなければ pacman は更新を拒否します。

## やらないこと

- 秘密鍵を GitHub Secrets / CI / リポジトリに置かない
- `repo-add --sign` を CI で実行しない
- 署名なしの Release を `latest` にしない
- AUR の maintainer 登録や孤児パッケージの引き継ぎは行わない
