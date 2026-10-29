# 来歴（Provenance）

- パッケージ: `lib32-audit`
- 方式: AUR スナップショットを基に mini-AUR で再ビルド（pkgrel +1）
- AUR: <https://aur.archlinux.org/packages/lib32-audit>
- ソース・ライセンス・依存は同梱の PKGBUILD を参照
- 変更: `pkgrel=2`。ソースを GitHub codeload tarball `https://codeload.github.com/linux-audit/audit-userspace/tar.gz/refs/tags/v4.2.1` に変更（SHA-256 `42876d195ee2ded19e5f72d7664096eee314928aa36ad346719ba5b25818fc84`）。`lib32-pam` のビルド依存として追加。
