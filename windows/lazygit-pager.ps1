#!/usr/bin/env pwsh
# =============================================================================
# lazygit 用 Windows 向け delta 連携スクリプト(公式回避策)
# =============================================================================
# lazygit のカスタムページャ(git.paging / git.pagers の pager)は Windows では
# 非対応のため、「外部 diff コマンド」として delta を呼び出して差分表示を再現する。
# 出典: lazygit docs/Custom_Pagers.md「Emulating custom pagers on Windows」
# (lazygit v0.56.0 以降で使用可)
#
# 必要条件:
#   - PowerShell 7(pwsh)        … 行頭パイプの行継続構文を使うため(5.1 では動かない)
#   - delta が PATH 上にあること … winget install dandavison.delta 等
#
# 使い方(詳細は README.md のトラブルシューティング参照):
#   1. このファイルを %LOCALAPPDATA%\lazygit\ などにコピー
#   2. config.yml の git.paging ブロックをコメントアウトし、次を設定:
#        git:
#          pagers:
#            - externalDiffCommand: C:/Users/<ユーザー名>/AppData/Local/lazygit/lazygit-pager.ps1
#
# 既知の制限: リネームが「旧ファイルの変更」として表示される
# (ハンクヘッダのみの問題で、diff の内容自体は常に正しい)
#
# ライトテーマの端末では --dark を --light に変更すること。

$old = $args[1].Replace('\', '/')
$new = $args[4].Replace('\', '/')
$path = $args[0]
git diff --no-index --no-ext-diff $old $new
  | %{ $_.Replace($old, $path).Replace($new, $path) }
  | delta --dark --width=$env:LAZYGIT_COLUMNS

# 行番号付き + クリックでエディタの該当行を開くリッチ版(最終行と差し替えて使う):
#   | delta --dark --width=$env:LAZYGIT_COLUMNS --line-numbers --hyperlinks --hyperlinks-file-link-format="lazygit-edit://{path}:{line}"
