# 来歴（Provenance）

- パッケージ: `lib32-popt`
- 方式: AUR スナップショットを基に mini-AUR で再ビルド（pkgrel +1）
- AUR: <https://aur.archlinux.org/packages/lib32-popt>
- ソース・ライセンス・依存は同梱の PKGBUILD を参照
- 変更: `pkgrel=3`。ソースを GitHub codeload のタグ tarball `https://codeload.github.com/rpm-software-management/popt/tar.gz/refs/tags/popt-1.19-release` に変更（SHA-256 `6eb40d650526cb9fe63eb4415bcecdf9cf306f7556e77eff689abc5a44670060`）。`prepare()` で `./autogen.sh` を実行。
