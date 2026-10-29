# 来歴（Provenance）

- パッケージ: `webtorrent-mpv-hook 1.4.6-2`
- 上流: <https://github.com/mrxdst/webtorrent-mpv-hook>
- タグ: `v1.4.6`
- コミット: `1d55ebd178243a22d653aeea868c2f10886240f3`
- ソース: <https://github.com/mrxdst/webtorrent-mpv-hook/archive/refs/tags/v1.4.6.tar.gz>
- ソース SHA-256: `a57bd1fa2758d728490ddf2bae6e0ee4029048ea2a1a72f76d327f554fa77328`
- npm 公開物: <https://registry.npmjs.org/webtorrent-mpv-hook/-/webtorrent-mpv-hook-1.4.6.tgz>
- npm 公開物 SHA-256: `842edbcf6a8c53724b8a6c33f2865b47eab77221cdce3f35e160c35c1978e330`
- ライセンス: Unlicense

## ビルド

- 上流ソースの `package-lock.json` を使い、`npm ci` で依存を固定
- `npm run build`（上流の `prebuild` / `tsc`）で `build/` を生成
- `npm prune --omit=dev` で実行時依存だけを残す
- `package()` は npm グローバル相当の配置を再現する
  - `/usr/lib/node_modules/webtorrent-mpv-hook/{build,package.json,LICENSE,README.md,node_modules}`
  - `/usr/bin/webtorrent-mpv-hook` → `../lib/node_modules/.../build/bin.mjs`
  - `/etc/mpv/scripts/webtorrent.js` → `../../../usr/lib/node_modules/.../build/webtorrent.js`
  - `/usr/share/licenses/webtorrent-mpv-hook/LICENSE` → `../../../usr/lib/node_modules/.../LICENSE`

## AUR との関係

- 元の AUR パッケージ `webtorrent-mpv-hook` は、2026-10-29 時点で maintainer が不在（孤児）。
- 本パッケージは AUR の PKGBUILD を引き継がず、上流タグと上流 lockfile から直接ビルドする。
- `pkgrel=2` は mini-AUR による再ビルドを示す（AUR 版は `1.4.6-1`）。
- ソースへのパッチはない。

## 検証

- `check()` で `build/webtorrent.js`、`build/webtorrent.node.js`、`build/bin.mjs`、`package.json`/lockfile の版、実行時依存 `webtorrent` の存在を確認
- CI でクリーンな Arch コンテナからビルド
- インストール後に mpv のスクリプトシンボリックリンクと `node_modules` の解決を確認
