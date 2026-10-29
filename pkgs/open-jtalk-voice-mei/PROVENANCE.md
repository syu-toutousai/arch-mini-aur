# 来歴（Provenance）

- パッケージ: `open-jtalk-voice-mei 1.7-2`（local-only）
- 上流: <http://www.mmdagent.jp/>
- ソース: `MMDAgent_Example-1.7.zip`（SourceForge）
- ソース SHA-256: `5b560e8c23c5acaf67688e6e25788db2c0bb230aff0635b7c75a82a87c7f6dba`
- ライセンス: `CCPL`
- AUR: `open-jtalk-voice-mei 1.7-1`（orphan、OutOfDate フラグあり）

## 方式

- AUR の PKGBUILD と同じソース・同じ 5 つの `.htsvoice` を `1.7-2` としてビルド。
- `CCPL` の再配布条件を確認するまで **local-only** とし、公開 GitHub Release には含めない。
- `syu-mini-aur` のローカルミラーにのみ置き、yay の OutOfDate 行から外す。

## 検証

- `pacman -Qkk open-jtalk-voice-mei` が 0 変更
- `/usr/share/open-jtalk/voices/mei_*.htsvoice` の 5 ファイル
- `pacman -Qm` / `yay -Qm` から foreign でなくなること
