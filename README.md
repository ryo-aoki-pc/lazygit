# lazygit 設定ファイル

[lazygit](https://github.com/jesseduffield/lazygit) を便利に使うための設定ファイル([`config.yml`](./config.yml))です。
各設定には日本語のコメントを付けてあるので、好みに合わせて調整してください。
公式の JSON スキーマ([schema/config.json](https://github.com/jesseduffield/lazygit/blob/master/schema/config.json))で検証済みです。

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

## 主な設定内容

### 画面・操作

- **あいまい検索** — `/` での絞り込みが fuzzy match になり、少ないタイプ数で目的の項目に届く
- **Nerd Fonts アイコン** — ファイル種別などをアイコンで表示
- **情報量の多い表示** — ブランチ一覧にコミットハッシュ、ファイル一覧に変更行数(+10 −3)、ベースブランチからの遅れ(↓3)を表示
- **ISO 形式の日付・24時間表記** — `2026-06-10` / `15:04` 形式
- **快適なスクロールとタブ切替** — スクロール量を増加、パネル番号キー(1〜5)の再押下でタブ切替
- **フォーカスパネルの自動拡大**、絵文字コード(`:sparkles:` 等)の表示
- **マウス操作の無効化** — ターミナル側のテキスト選択・コピーをそのまま使える
- **外部エディタから戻るときの Enter 不要**、起動時ポップアップもオフ

### カスタムコマンド

| キー | 使える場所 | 動作 |
| --- | --- | --- |
| `Ctrl+V` | どこでも | Conventional Commits 形式(`feat: ...` など)のコミットを対話形式で作成 |
| `P` | リモートパネル | リモートで削除済みのブランチ参照を掃除(`git remote prune`) |
| `B` | ファイルパネル | 選択ファイルの `git blame` を表示 |
| `F` | ファイルパネル | 選択ファイルの変更履歴をリネーム追跡・差分付きで表示 |

### コメントアウトで用意してあるオプション

必要に応じてコメントを外して使ってください。

- `os.editPreset` — `e` キーで開くエディタの指定(未指定なら `$EDITOR` 等から自動判定)
- `os.copyToClipboardCmd` — SSH 先や tmux 内でも OSC52 でローカルのクリップボードへコピー
- `git.commitPrefix` — ブランチ名(例: `feature/JIRA-123`)からコミットメッセージの接頭辞を自動入力
- `git.mainBranches` / `git.autoForwardBranches` — develop 運用や全ブランチ自動 fast-forward
- `gui.statusPanelView` — ステータスパネルに全ブランチのログを表示
- `gui.authorColors` / `gui.sidePanelWidth` / `keybinding` — 見た目・操作の微調整

## 補足

- 1 行目の `yaml-language-server` コメントにより、VSCode(YAML 拡張)などでは公式スキーマによる補完・検証が効きます。
- 全設定項目のリファレンスは公式ドキュメントを参照してください:
  - [Config.md](https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md)(全設定項目)
  - [Custom_Command_Keybindings.md](https://github.com/jesseduffield/lazygit/blob/master/docs/Custom_Command_Keybindings.md)(カスタムコマンド)

## このリポジトリの運用

| ブランチ | 内容 |
| --- | --- |
| `custom`(デフォルト) | このブランチ。`main` の上に自分用のカスタマイズを積んだもの |
| `main` | lazygit 公式のデフォルト設定([docs/Config.md](https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md) の Default セクション)をそのまま置いた upstream 追従ブランチ。直接編集しない |

- 設定の変更は `custom` からトピックブランチを切って Pull Request で取り込みます。
- 公式デフォルトからのカスタマイズ差分は `git diff main custom -- config.yml`(コミット単位なら `git log --oneline main..custom`)で確認できます。
- upstream(lazygit の新バージョン)への追従は、`main` で [`scripts/fetch-upstream-config.sh`](./scripts/fetch-upstream-config.sh) を実行してコミットし、
  `custom` を `git rebase main` で載せ直します(手順の詳細は `main` ブランチの README を参照)。
