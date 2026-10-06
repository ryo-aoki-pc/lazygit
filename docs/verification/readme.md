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

## delta の表示と性能の検証

[設定手順と表示の比較](../../README.md#delta-の設定と表示)は lazygit 0.65.1 / delta 0.20.1 で確認した。README の設定例は YAML とコマンドの引用符を検証し、実際の lazygit の対話 PTY で速度優先 → 見やすさ優先 → 内蔵表示 → 速度優先の切り替えを確認した。

lazygit 0.66.0 の Enter 操作は[公式の差分ビューの実装](https://github.com/jesseduffield/lazygit/blob/v0.66.0/pkg/gui/controllers/switch_to_focused_main_view_controller.go#L91)と[内蔵表示への切り替え条件](https://github.com/jesseduffield/lazygit/blob/v0.66.0/pkg/gui/controllers/helpers/diff_line_raw_fallback.go#L29)で確認した。delta 0.20.1 は行選択に必要なメタデータに対応し、同梱設定・速度優先・見やすさ優先の各コマンドがメタデータを返すことも確認した。0.66.0 の Enter 操作自体は実 TUI では試験していない。

5種類の比較画像は、専用の仮想画面で実際の lazygit を起動して撮影した。同じサンプル差分に単語の変更、途中への行追加、日本語、タブ、長い行を含め、120列×40行、ダーク背景、HackGen Console NF で条件を揃えた。見やすさ優先では、単語単位の強調、挿入行を含む対応付け、約5,000文字の行の末尾までの折り返しを確認した。

同じ差分を処理したときの比較結果は以下のとおりです。

| 追加・削除の合計行数 | 同梱設定の左右比較(構文ハイライト無効) | 速度優先の左右比較 |
| --- | ---: | ---: |
| 200行 | 21.6 ms | 18.6 ms |
| 2,000行 | 53.3 ms | 39.1 ms |
| 20,000行 | 370.9 ms | 215.0 ms |

Linux arm64、Git 2.52.0、delta 0.20.1、表示幅100列、ANSIによる行末描画で比較しています。各条件をウォームアップした後、ランダムな順で7回測定した中央値です。Git と delta の起動、差分生成、差分全文の描画を含め、出力は `/dev/null` に捨てています。lazygit の画面操作時間を測ったものではありません。結果は実行環境や差分の内容で変わります。delta の起動と左右比較には追加の処理があるため、内蔵表示と同じ速度は保証できません。
