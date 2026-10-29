# mini-AUR 設計

## 目的

AUR で maintainer 不在（孤児）になったパッケージを、AUR に依存せず管理する個人用リポジトリ。

- 上流を直接参照し、取得物を SHA-256 で固定する
- CI でクリーンビルド・検証する
- 秘密鍵を手元に置いたまま、オフラインで GPG 署名する
- pacman の同期リポジトリとして配布する

AUR の maintainer 登録・孤児パッケージの引き継ぎは行わない。AUR 側の孤児メタデータは変更しない。

## アーキテクチャ

```
arch-mini-aur/
├── pkgs/<name>/          # PKGBUILD, パッチ, PROVENANCE.md
├── tools/                # ビルド, 署名, 検証, 状態確認
├── keys/                 # 公開鍵（秘密鍵は置かない）
├── docs/
└── .github/workflows/    # CI: ビルドと未署名 artifact のみ
```

- 1 パッケージ = 1 ディレクトリ。`PKGBUILD` と `PROVENANCE.md` を同じ場所に置く。
- パッケージ名は元の AUR 名を維持する。`pkgver` / `pkgrel` で既存インストールを置き換える。
- 単一の pacman リポジトリ `syu-mini-aur` に集約する。

## 上流の固定方法

| 種別 | 方法 | 現在の例 |
| --- | --- | --- |
| 公式バイナリ | 上流リリースを SHA-256 固定し、必要ならパッチ | `mechvibes`（公式 deb + asar 日本語化） |
| ソース | 上流タグの tarball を SHA-256 固定し、上流 lockfile で依存を固定してビルド | `webtorrent-mpv-hook` |
| Arch 公式の 32bit 版 | Arch GitLab の公式 PKGBUILD を基に multilib でビルド | 将来の `lib32-*` |
| バージョン固定ランタイム | 上流 tarball + `SHASUMS256` + GPG | 将来の `nodejs-lts-iron` |
| データのみ | 上流配布物のハッシュとライセンスを確認 | 将来の `open-jtalk-voice-mei` |

孤児 AUR の PKGBUILD は参考程度に監査し、そのまま信用しない。`source` は上流に直接向ける。

## pacman / yay / 集計ツールの判定

pacman に「孤児」という状態はない。

- `pacman -Qm` は **foreign**（どの同期リポジトリにも属さない）を列挙する。
- `[syu-mini-aur]` を `pacman.conf` に追加して `pacman -Sy` すると、対象パッケージは同期リポジトリに属するため `-Qm` から消える。
- yay/paru は pacman の同期 DB を見る。同期リポジトリに入ったパッケージは AUR パッケージではなくリポジトリパッケージとして扱われ、AUR 版への更新誘導もなくなる。
- AUR の `Maintainer: None` は AUR 側のメタデータであり、AUR を引き継ぐか削除しない限り残る。AUR RPC を直接照会する集計ツール（独自の orphan rollup など）は、AUR ではなく `pacman -Sl syu-mini-aur` を正とするよう変更する必要がある。
- `yay -Ss` のような横断検索では AUR 側も表示され得る。導入は `pacman -S` を使う。
- 同じパッケージ名を複数の自作リポジトリに入れない。`[mechvibes-ja]` と `[syu-mini-aur]` の併用は避ける。

状態確認:

```bash
./tools/mini-aur-status.sh
```

## CI

- Arch のクリーンコンテナで `makepkg -s`
- 各パッケージの `check()` を実行
- `repo-add` で未署名の staging DB を作成
- `actions/upload-artifact` で `mini-aur` artifact を保存
- Release は作らない（署名は手元）

## 署名と信頼モデル

- CI は秘密鍵を持たない。
- 手元で `gpg --detach-sign`（パッケージ）と `repo-add --sign`（DB）を実行する。
- クライアントは `SigLevel = Required DatabaseOptional` でパッケージ署名を必須にする。
- GitHub アカウントが侵害されても、秘密鍵がなければ pacman は改ざんを受け入れない。
- 秘密鍵のバックアップ、失効、ローテーションは [signing.md](signing.md) を参照。

## 配布基盤

- 小規模なうちは GitHub Releases（`latest/download`）で DB とパッケージを同じベース URL に置く。
- パッケージ数・サイズが増えたら Cloudflare R2 などのオブジェクトストレージへ移し、GitHub は CI と監査に特化する。
- DB とパッケージは必ず同じベース URL に置く（pacman は DB 内のファイル名を Server に結合する）。

## 脅威モデルと限界

- **AUR 乗っ取り**: 本リポジトリは AUR に依存しないため影響を受けない。
- **GitHub アカウント侵害**: 未署名 artifact は作れるが、署名済みパッケージは作れない。branch protection、2FA、Actions の最小権限を併用する。
- **上流の侵害**: SHA-256 固定と lockfile で取得物を固定するが、上流自体が悪意を持つ場合はソースレビューでしか防げない。
- **バイナリのみの上流**: ハッシュと挙動の検証以上はできない。「消毒」ではなく「来歴検証」と呼ぶ。
- **ライセンス**: 再配布不可のデータ・フォント・音声は公開リポジトリに置かない。
- **保守**: 上流更新の追従は手作業。使わないパッケージは削除する。

## パッケージ追加の手順

1. `pkgs/<name>/PKGBUILD` を作る。`source` は上流に直接向け、SHA-256 を固定する。
2. `PROVENANCE.md` に上流 URL、タグ/コミット、ハッシュ、ライセンス、ビルド方法、検証を記録する。
3. `check()` で成果物・版・依存を検証する。
4. `makepkg --printsrcinfo > .SRCINFO` を生成する。
5. CI でビルドが通り、`mini-aur-status.sh` で状態を確認する。
6. 署名して Release を更新する。

## ロードマップ

- 完了: `mechvibes`、`webtorrent-mpv-hook`
- 次候補: `nodejs-lts-iron`（システムパッケージとして必要か再評価）、`lib32-*`（Arch GitLab の公式 PKGBUILD と照合）、`open-jtalk-voice-mei`（ライセンス確認）
- 全 15 個を一度に追加しない。2〜3 個ずつ検証して増やす。

## 現在の範囲

- 変更したのは `mechvibes` と `webtorrent-mpv-hook` のみ。
- 他の孤児パッケージのインストール・削除・リポジトリ追加は行っていない。
- 署名鍵の生成と Release 公開は、ユーザーが手元で行う（オフライン署名）。
