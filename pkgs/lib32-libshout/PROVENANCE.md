# 来歴（Provenance）

- パッケージ: `lib32-libshout`
- 方式: AUR スナップショットを基に mini-AUR で再ビルド（pkgrel +1）
- AUR: <https://aur.archlinux.org/packages/lib32-libshout>
- ソース・ライセンス・依存は同梱の PKGBUILD を参照
- 変更: `pkgrel=5`。ソースを GitLab タグアーカイブ + サブモジュール（`icecast-m4` commit `57027c6cc3f8b26d59e9560b4ac72a1a06d643b9`、`icecast-common` commit `5de3e8b3b063002d8a9f52122e97f721e1742531`）に変更。`prepare()` でサブモジュール内容を配置し `./autogen.sh` を実行。
- SHA-256: libshout `92e81faaf4f5bf0a4feb5e3d29f9e79f5eeb392bc633ffed869a905b86c4dcb5`、m4 `a838f9c0a9380b76e9b5e295de30699d934d8094f528ba00c708939275e34e09`、common `f575cd77fb879b4a97a83f6ab75408ee80d8fa2683173e9ade6de52f0c92bcdb`。
