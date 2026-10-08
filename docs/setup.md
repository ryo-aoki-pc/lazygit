# lazygit 設定の導入

[文書一覧](README.md) / [設定内容](reference/readme.md) / [検証記録](verification/readme.md)

lazygit 本体の導入・更新・削除は [setup-notes の導入手順](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/lazygit.md)を参照してください。この文書では、このリポジトリの個人設定を配置します。

## 前提ツール

この設定は以下を有効化した状態になっています。未導入の場合はインストールするか、該当設定を無効化してください。

| ツール | 用途 | 未導入の場合 |
| --- | --- | --- |
| [Nerd Fonts](https://www.nerdfonts.com/)(v3系) | ファイルアイコン等の表示 | `gui.nerdFontsVersion` を `""` にする |
| [git-delta](https://github.com/dandavison/delta) | 左右比較と単語単位の変更強調を含む差分表示 | `git.diffRenderers` を `[]` に戻す |

## 導入方法

`config.yml` を lazygit の設定ディレクトリに配置します(ディレクトリは `lazygit --print-config-dir` で確認できます)。

| OS | 配置場所 |
| --- | --- |
| Linux | `~/.config/lazygit/config.yml` |
| macOS | `~/Library/Application Support/lazygit/config.yml` |
| Windows | `%LOCALAPPDATA%\lazygit\config.yml` |

このリポジトリをクローンしてシンボリックリンクを張る場合(Linux の例):

```sh
git clone https://github.com/ryo-aoki-pc/lazygit.git ~/lazygit-config
mkdir -p ~/.config/lazygit
ln -sf ~/lazygit-config/config.yml ~/.config/lazygit/config.yml
```

このリポジトリを設定ディレクトリに直接クローンする場合(Windows の例。lazygit を終了してから Windows PowerShell に貼り付けます):

```powershell
$d = "$env:LOCALAPPDATA\lazygit"
if (Test-Path -LiteralPath "$d.bak") {
  Write-Warning "$d.bak がすでにあるため中止しました。中身を確かめて片付けてから、貼り直してください"
} else {
  if (Test-Path -LiteralPath $d) { Move-Item -LiteralPath $d -Destination "$d.bak" -ErrorAction Stop; "moved: $d -> $d.bak" }
  git clone https://github.com/ryo-aoki-pc/lazygit.git $d
  git -C $d branch --show-current
  lazygit --print-config-dir
}
```

- Windows ではシンボリックリンクの作成に開発者モードか管理者権限が必要なため、リンクではなく設定ディレクトリ `%LOCALAPPDATA%\lazygit` に直接クローンします
- 既存の `%LOCALAPPDATA%\lazygit`(以前の設定と状態ファイル)は `lazygit.bak` に退避します。`lazygit.bak` がすでにある場合は、退避もクローンもせずに警告を出して止まります
- `custom`(既定のブランチ)と `C:\Users\<ユーザー名>\AppData\Local\lazygit` が表示されれば完了です
- Windows の lazygit は状態ファイル(`state.yml` など)も同じフォルダーに作りますが、[`.gitignore`](../.gitignore) で `state.yml`・`github_pull_requests.json`・`development.log` を除外しているため、`git status` には出ません
- Windows の実機ではまだ実行していません。確認した範囲は[検証記録](verification/readme.md#editinterminal-と-windows-向け手順の確認2026-10-08)に記載しています
- 元に戻す場合は、lazygit を終了し、次の 1 つ目のブロックで何も表示されない(未コミット・未 push の変更が無い)ことを確かめてから、2 つ目のブロックを貼り付けます

```powershell
$d = "$env:LOCALAPPDATA\lazygit"
git -C $d status --short
git -C $d log --oneline '@{u}..'
```

```powershell
$d = "$env:LOCALAPPDATA\lazygit"
Remove-Item -LiteralPath $d -Recurse -Force
if (Test-Path -LiteralPath "$d.bak") { Move-Item -LiteralPath "$d.bak" -Destination $d }
```

ファイルを置かずに一時的に試す場合:

```sh
lazygit --use-config-file ~/lazygit-config/config.yml
```

差分の表示を調整する場合は [delta の設定と表示](diff-renderers.md)、Excel を比較する場合は [Excel の差分表示](excel-diff.md)を参照してください。
