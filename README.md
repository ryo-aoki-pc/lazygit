# lazygit 設定ファイル

[lazygit](https://github.com/jesseduffield/lazygit) を便利に使うための設定ファイル([`config.yml`](config.yml))です。

[設定内容・ブランチ構成](docs/reference/readme.md) / [検証記録](docs/verification/readme.md)

## 前提ツール

この設定は以下を有効化した状態になっています。未導入の場合はインストールするか、該当設定を無効化してください。

| ツール | 用途 | 未導入の場合 |
| --- | --- | --- |
| [Nerd Fonts](https://www.nerdfonts.com/)(v3系) | ファイルアイコン等の表示 | `gui.nerdFontsVersion` を `""` にする |

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

ファイルを置かずに一時的に試す場合:

```sh
lazygit --use-config-file ~/lazygit-config/config.yml
```

## 必要になったら検討する項目

`config.yml` には書いていません(デフォルトのまま)。使うときは `config.yml` 内の該当キーの値を書き換えてください。

- `os.editPreset` — `e` キーで開くエディタの指定(未指定なら `$EDITOR` 等から自動判定)
- `os.copyToClipboardCmd` — SSH 先や tmux 内でも OSC52 でローカルのクリップボードへコピー
- `git.commitPrefix` — ブランチ名(例: `feature/JIRA-123`)からコミットメッセージの接頭辞を自動入力
- `git.mainBranches` / `git.autoForwardBranches` — develop 運用や全ブランチ自動 fast-forward
- `gui.statusPanelView` — ステータスパネルに全ブランチのログを表示
- `gui.theme.authorColors` / `gui.sidePanelWidth` / `keybinding` — 見た目・操作の微調整

## このリポジトリの運用

`main` は upstream 追従用です。直接編集しないでください。

- 設定の変更は `custom` からトピックブランチを切って Pull Request で取り込みます。
- 公式デフォルトからのカスタマイズ差分は `git diff main custom -- config.yml`(コミット単位なら `git log --oneline main..custom`)で確認できます。
- `custom` の `config.yml` は `main` の全項目形式を保ち、変えたい値だけを書き換えます(項目の削除・並べ替え・独自ヘッダの追加はしない)。版の互換性に必要なキーの改名・移動は[検証記録](docs/verification/readme.md)に残します。変更した値の直上に日本語コメントを 1 行付けます。
- upstream(lazygit の新バージョン)への追従は、`main` で [`scripts/fetch-upstream-config.sh`](scripts/fetch-upstream-config.sh) を実行してコミットし、
  `custom` を `git rebase main` で載せ直します(手順の詳細は `main` ブランチの README を参照)。
