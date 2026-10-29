# keys

`tools/gen-signing-key.sh` が公開鍵 `syu-mini-aur.asc` をここに書き出します。

- `syu-mini-aur.asc` はコミットしてよい（公開鍵）。
- 秘密鍵 (`~/.gnupg`) は絶対にコミットしない。
- 鍵をローテーションしたら、このファイルを更新して Release と pacman-key に反映する。
