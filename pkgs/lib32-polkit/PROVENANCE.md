# 来歴（Provenance）

- パッケージ: `lib32-polkit`
- 方式: AUR スナップショットを基に mini-AUR で再ビルド（pkgrel +1）
- AUR: <https://aur.archlinux.org/packages/lib32-polkit>
- ソース・ライセンス・依存は同梱の PKGBUILD を参照
- 変更: `pkgrel=2`。ソースを GitHub codeload tarball `https://codeload.github.com/polkit-org/polkit/tar.gz/refs/tags/127` に変更（SHA-256 `9b7bc16f086479dcc626c575976568ba4a85d34297a750d8ab3d2e57f6d8b988`）。パッチは `patch -Np1` で適用。
