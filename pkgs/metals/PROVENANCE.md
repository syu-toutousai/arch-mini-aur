# 来歴（Provenance）

- パッケージ: `metals 1.5.2-2`（local-only）
- 上流: <https://scalameta.org/metals/>
- ライセンス: Apache-2.0
- AUR: `metals 1.5.2-1`（maintainer: isomarcte、OutOfDate フラグあり）
- ローカル既存: `metals 1.5.2-1.1`（Garuda Builder、2026-01-11）

## 方式

このパッケージは AUR ソースからの再ビルドではなく、**インストール済みの
1.5.2-1.1 のファイル（`/usr/bin/metals*` と `/usr/share/java/metals`）を
1.5.2-2 として再梱包**した local-only パッケージです。

- AUR の OutOfDate フラグは AUR 側のメタデータであり、こちらでは変更できません。
- yay の「古いバージョンのフラグ」行から外すため、ローカル同期リポジトリ
  `syu-mini-aur` にこのパッケージを置きます。
- `metals.install` は AUR のものを使用します（JDK 選択の案内のみ）。
- 公開 GitHub Release には含めません（`.local-only`）。

## 検証

- `pacman -Qkk metals` が 0 変更
- パッケージ内容は既存 1.5.2-1.1 と同一
- `pacman -Qm` / `yay -Qm` から foreign でなくなること
