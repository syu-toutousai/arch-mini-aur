# arch-mini-aur

個人用の **mini-AUR** です。AUR で孤児化したパッケージを、上流の固定ソース・クリーンビルド・検証・**オフライン GPG 署名**で管理します。AUR の maintainer にはならず、AUR の孤児メタデータ自体は変更しません。

- リポジトリ: <https://github.com/syu-toutousai/arch-mini-aur>
- pacman リポジトリ名: `syu-mini-aur`
- 署名: 手元の GPG 鍵でオフライン署名（CI はビルドと検証のみ）

## パッケージ

| パッケージ | 版 | 上流 | 備考 |
| --- | --- | --- | --- |
| `mechvibes` | `2.3.6.ja1-1` | [hainguyents13/mechvibes](https://github.com/hainguyents13/mechvibes) | 日本語化、上流 deb を SHA-256 固定 |
| `webtorrent-mpv-hook` | `1.4.6-2` | [mrxdst/webtorrent-mpv-hook](https://github.com/mrxdst/webtorrent-mpv-hook) | 上流タグ + 上流 lockfile からビルド |

## インストール（署名済みリリース）

初回は「リリース」節の署名手順を先に実行してください。

```bash
# 公開鍵を取得して pacman に登録
curl -fsSLO https://github.com/syu-toutousai/arch-mini-aur/releases/latest/download/syu-mini-aur.asc
sudo pacman-key --add syu-mini-aur.asc
sudo pacman-key --lsign-key <FINGERPRINT>
```

`/etc/pacman.conf` に追記:

```ini
[syu-mini-aur]
SigLevel = Required DatabaseOptional
Server = https://github.com/syu-toutousai/arch-mini-aur/releases/latest/download
```

```bash
sudo pacman -Sy
sudo pacman -S mechvibes webtorrent-mpv-hook
```

### 以前の `[mechvibes-ja]` を使っていた場合

mini-AUR にも `mechvibes` が入っているため、`[mechvibes-ja]` セクションは削除して一本化してください。同じパッケージ名が 2 つのリポジトリにあると、どちらが使われるか分かりにくくなります。

## orphan / foreign 判定について

pacman に「孤児」という状態はありません。`pacman -Qm` は **foreign**（どの同期リポジトリにも属さない）を意味します。

- `[syu-mini-aur]` を `pacman.conf` に追加して `pacman -Sy` すると、`mechvibes` と `webtorrent-mpv-hook` は foreign ではなくなり、`pacman -Qm` から消えます。
- yay/paru は pacman の同期 DB を見るため、これらを「AUR パッケージ」ではなく「リポジトリパッケージ」として扱います。AUR 版への更新誘導もなくなります。
- AUR 側の `Maintainer: None`（孤児）メタデータは消えません。AUR を引き継ぐか削除しない限り、AUR RPC を直接見るツールには孤児として見え続けます。その場合は AUR RPC ではなく `pacman -Sl syu-mini-aur` を正としてください。
- `yay -Ss mechvibes` のように AUR とリポジトリを横断検索すると AUR 側も表示され得ます。導入は `pacman -S` を使うのが確実です。

状態確認:

```bash
./tools/mini-aur-status.sh
```

## ローカルビルド

```bash
sudo pacman -S --needed base-devel asar nodejs npm
./tools/build-repo.sh
```

`build-repo.sh` は未署名の staging repo を `repo/` に作ります。署名と公開は次節です。

## リリース（オフライン署名）

秘密鍵は手元だけで管理し、GitHub には置きません。CI は未署名の成果物を作るだけです。

1. 初回のみ署名鍵を生成:

```bash
./tools/gen-signing-key.sh
# 表示された fingerprint をメモ
git add keys/syu-mini-aur.asc
git commit -m "add mini-AUR public key"
git push
```

2. `main` への push で GitHub Actions が全パッケージをビルドし、未署名の `mini-aur` artifact を作成します。

3. CI 完了後、手元で署名してリリース:

```bash
./tools/sign-and-publish.sh v2026.10.29
```

このスクリプトは最新の成功 CI artifact を取得し、各パッケージと DB を署名・検証して GitHub Release を `latest` として公開します。`DRY_RUN=1` でリリース作成を省略した署名テストもできます。

詳細は [docs/signing.md](docs/signing.md) を参照してください。

## セキュリティモデル

- 上流の取得物を SHA-256 で固定（mechvibes は公式 deb、webtorrent は上流タグ）
- webtorrent は上流の `package-lock.json` で依存を固定
- `check()` で成果物の存在・版・依存を検証
- CI はクリーンな Arch コンテナでビルドし、未署名 artifact のみを生成
- 署名は手元の GPG 鍵で実施。**GitHub アカウントが侵害されても、鍵がなければ pacman は更新を受け入れない**
- pacman 側は `SigLevel = Required DatabaseOptional`（パッケージ署名を必須、DB 署名は任意）
- 公開鍵は `keys/syu-mini-aur.asc` と Release に掲載

詳細は [docs/mini-aur-design.md](docs/mini-aur-design.md) を参照してください。

## 構成

```
pkgs/
  mechvibes/              # 日本語化 + 公式 deb 固定
  webtorrent-mpv-hook/    # 上流タグ + lockfile ビルド
tools/
  apply-ja.js             # mechvibes の asar パッチ
  verify-ja.js            # 日本語化の検証
  build-repo.sh           # 未署名 staging repo
  gen-signing-key.sh      # 署名鍵の生成
  sign-and-publish.sh     # 署名 + Release 公開
  verify-repo.sh          # 署名検証
  mini-aur-status.sh      # mini-AUR / foreign の状態確認
docs/
  signing.md              # 鍵管理と署名手順
  mini-aur-design.md      # 設計と脅威モデル
```

## ライセンス

- このリポジトリのパッケージングスクリプトとドキュメント: MIT（[LICENSE](LICENSE)）
- `mechvibes`: MIT（Copyright (c) 2021 Hai Nguyen）
- `webtorrent-mpv-hook`: Unlicense

各パッケージの上流ライセンスと著作権表示を保持します。
