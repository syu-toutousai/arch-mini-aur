# 来歴（Provenance）

- パッケージ: `lib32-pam`
- 方式: AUR スナップショットを基に mini-AUR で再ビルド（pkgrel +1）
- AUR: <https://aur.archlinux.org/packages/lib32-pam>
- ソース・ライセンス・依存は同梱の PKGBUILD を参照
- 変更: `pkgrel=2`。ソースを GitHub codeload tarball `https://codeload.github.com/linux-pam/linux-pam/tar.gz/refs/tags/v1.7.2` に変更（SHA-256 `d7ce5cb6e07ee8603d8af41a672bcb515b9d27079ee309fb3f729a8020166694`）。`lib32-polkit` のビルド依存として追加。
