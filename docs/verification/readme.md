# lazygit 検証記録

[導入・更新手順](../../README.md)

lazygit 0.66.0 の公式 JSON スキーマ([schema/config.json](https://github.com/jesseduffield/lazygit/blob/v0.66.0/schema/config.json))と、新規 AlmaLinux 10.2 VM の実 TUI で検証済みです。

## 新規 AlmaLinux VM での検証（2026-10-06）

- AlmaLinux 10.2 Workstation の x86_64 新規 VM へ Homebrew 7.0.8 / lazygit 0.66.0 を入れ、[導入手順](../../README.md#導入方法)の公開 URL から `dc3873e` を clone して `~/.config/lazygit/config.yml` のリンクを作った。SSH の対話 PTY で試験用 git リポジトリを開き、変更行数・ファイルツリー・差分の表示と `q` の終了を確認した
- 初回起動は 4 キーを自動移行し、リンク先の `config.yml` を書き換えた。新規 clone に不要な変更が残らないよう、設定の値とコメントを保持して次の互換修正を適用した
  - `gui.wrapLinesInStagingView` → `gui.wrapLinesInDiffView`
  - `gui.useHunkModeInStagingView` → `gui.useHunkModeInDiffView`
  - `gui.authorColors` / `gui.branchColorPatterns` → `gui.theme` 配下の同名キー
- 修正ファイルを同じ VM に転送して起動し直すと、自動移行の通知が無く、起動前後の設定の SHA256 は一致した。v0.66.0 の公式タグの JSON Schema への照合もエラー 0 件だった
- この確認は Linux の clone・リンク・実 TUI と設定互換性。macOS / Windows、upstream の main 更新・rebase・GitHub への push は実行していない。フォントのグリフの見た目は GUI では確認していない
