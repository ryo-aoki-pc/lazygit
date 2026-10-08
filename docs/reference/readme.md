# lazygit 設定リファレンス

[文書一覧](../README.md) / [設定の導入](../setup.md) / [設定の保守](../maintenance.md) / [検証記録](../verification/readme.md)

`main` ブランチ(lazygit 公式のデフォルト設定)の `config.yml` を丸ごとベースにし、変更した項目にだけ日本語のコメントを付けてあります。

## 主な設定内容

### 画面・操作

- **[delta による左右比較の差分表示](../diff-renderers.md)** — 構文ハイライトを無効にして負荷を抑え、`|` キーで内蔵表示へ切替可能
- **[Excel の差分表示](../excel-diff.md)** — Git の `textconv` にシート名・セル番地・値・数式を渡す変換処理を登録し、既存の delta で比較する。端末ごとに追加の導入が必要
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

## 必要になったら検討する項目

`config.yml` には書いていません(デフォルトのまま)。使うときは `config.yml` 内の該当キーの値を書き換えてください。

- `os.editPreset` — `e` キーで開くエディタの指定(未指定なら `$EDITOR` 等から自動判定)
- `os.copyToClipboardCmd` — SSH 先や tmux 内でも OSC52 でローカルのクリップボードへコピー
- `git.commitPrefix` — ブランチ名(例: `feature/JIRA-123`)からコミットメッセージの接頭辞を自動入力
- `git.mainBranches` / `git.autoForwardBranches` — develop 運用や全ブランチ自動 fast-forward
- `gui.statusPanelView` — ステータスパネルに全ブランチのログを表示
- `gui.theme.authorColors` / `gui.sidePanelWidth` / `keybinding` — 見た目・操作の微調整
