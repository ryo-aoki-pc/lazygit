# lazygit 設定リファレンス

[導入・更新手順](../../README.md) / [検証記録](../verification/readme.md)

`main` ブランチ(lazygit 公式のデフォルト設定)の `config.yml` を丸ごとベースにし、変更した項目にだけ日本語のコメントを付けてあります。

## 主な設定内容

### 画面・操作

- **[delta による左右比較の差分表示](../../README.md#delta-の設定と表示)** — 標準(構文ハイライトなし)・速度優先・見やすさ優先の3種類の左右比較と内蔵表示を `|` キーで切替可能。引用符を二重引用符に揃え、Linux と Windows で同じ設定
- **[Excel の差分表示と部分ステージ](../excel-diff.md)** — Git の `textconv` でセルを左右比較する。ファイル一覧の `E` で既存の xlsx 系ファイルのセル値・数式を選択し、専用画面の `X` で元の Excel のままステージする。端末ごとに追加の導入が必要
- **あいまい検索** — `/` での絞り込みが fuzzy match になり、少ないタイプ数で目的の項目に届く
- **Nerd Fonts アイコン** — ファイル種別などをアイコンで表示
- **情報量の多い表示** — ブランチ一覧にコミットハッシュ、ファイル一覧に変更行数(+10 −3)、ベースブランチからの遅れ(↓3)を表示
- **ISO 形式の日付・24時間表記** — `2026-06-10` / `15:04` 形式
- **快適なスクロールとタブ切替** — スクロール量を増加、パネル番号キー(1〜5)の再押下でタブ切替
- **フォーカスパネルの自動拡大**、絵文字コード(`:sparkles:` 等)の表示
- **マウス操作の無効化** — ターミナル側のテキスト選択・コピーをそのまま使える
- **`e` キーで Vim / Neovim を端末内で開く** — `os.editInTerminal` を `true` にし、エディタの終了まで lazygit を一時停止する。公式デフォルト一覧の `false` を明示すると、エディタのプリセット(`vim` / `nvim` など)の判定より優先されて端末を渡さず、`e` でエディタが表示されないまま lazygit が止まる([検証記録](../verification/readme.md#editinterminal-と-windows-向け手順の確認2026-10-08))。Neovim の中から `nvim-remote` のプリセットで開いた lazygit(snacks.nvim の lazygit。LazyVim の `<leader>gg` など)では、`e` の後も lazygit が閉じずに残る(snacks.nvim と同じ設定の重ね方で確認。閉じる動きに戻すには、snacks.nvim の lazygit の設定で `os.editInTerminal` を `false` にする)
- **外部エディタから戻るときの Enter 不要**、起動時ポップアップもオフ

## 補足

- 全設定項目のリファレンスは公式ドキュメントを参照してください:
  - [Config.md](https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md)(全設定項目)

## ブランチ構成

| ブランチ | 内容 |
| --- | --- |
| `custom`(デフォルト) | このブランチ。`main` の上に自分用のカスタマイズを積んだもの |
| `main` | lazygit 公式のデフォルト設定([docs/Config.md](https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md) の Default セクション)をそのまま置いた upstream 追従ブランチ。直接編集しない |
