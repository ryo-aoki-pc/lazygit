# lazygit 設定ファイル

[lazygit](https://github.com/jesseduffield/lazygit) を便利に使うための設定ファイル([`config.yml`](./config.yml))です。
各設定には日本語のコメントを付けてあるので、好みに合わせて調整してください。
公式の JSON スキーマ([schema/config.json](https://github.com/jesseduffield/lazygit/blob/master/schema/config.json))で検証済みです。

## 前提ツール

この設定は以下を有効化した状態になっています。未導入の場合はインストールするか、該当設定を無効化してください。

| ツール | 用途 | 未導入の場合 |
| --- | --- | --- |
| [Nerd Fonts](https://www.nerdfonts.com/)(v3系) | ファイルアイコン等の表示 | `gui.nerdFontsVersion` を `""` にする |
| [delta](https://github.com/dandavison/delta) | 差分表示の強化(`brew install git-delta` / `cargo install git-delta` 等) | `git.paging` ブロックをコメントアウト |

> - ライトテーマの端末を使っている場合は、`git.paging` の `--dark` を `--light` に変更してください。
> - **Windows では delta の利用に追加の手順が必要です**(lazygit のカスタムページャが Windows 非対応のため)。
>   [トラブルシューティング](#windows-で-delta-の差分表示にならない)を参照してください。

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
- **delta による差分表示** — シンタックスハイライト付きの読みやすい diff
- **Nerd Fonts アイコン** — ファイル種別などをアイコンで表示
- **情報量の多い表示** — ブランチ一覧にコミットハッシュ、ファイル一覧に変更行数(+10 −3)、ベースブランチからの遅れ(↓3)を表示
- **ISO 形式の日付・24時間表記** — `2026-06-10` / `15:04` 形式
- **快適なスクロールとタブ切替** — スクロール量を増加、パネル番号キー(1〜5)の再押下でタブ切替
- **フォーカスパネルの自動拡大**、絵文字コード(`:sparkles:` 等)の表示
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
- `gui.authorColors` / `gui.mouseEvents` / `gui.sidePanelWidth` / `keybinding` — 見た目・操作の微調整

## トラブルシューティング

### delta の差分表示にならない(macOS / Linux / WSL)

1. delta がインストールされているか確認: `delta --version`(なければ `brew install git-delta` 等)
2. 設定ファイルが読み込まれているか確認: `lazygit --print-config-dir` が示す場所に `config.yml` があるか
3. ライトテーマの端末では `git.paging` の `--dark` を `--light` に変更
4. それでも直らない場合は `lazygit --version` を確認(かなり古いバージョンでは一部の設定キー自体が存在しません)

### Windows で delta の差分表示にならない

設定ミスではなく lazygit 本体の制約です。**lazygit のカスタムページャ(delta 等)は Windows では非対応**で、
最新版でも同じです(diff をページャへ渡すのに使う PTY ライブラリが Windows 未対応のため。
**Git Bash から起動しても回避できず、lazygit を更新しても直りません**)。
ターミナルの `git diff` で delta が効いていても、lazygit 内では効かないのはこのためです。

- 参考: [Custom_Pagers.md](https://github.com/jesseduffield/lazygit/blob/master/docs/Custom_Pagers.md)
  ("Support does not extend to Windows users…")、
  [#2300](https://github.com/jesseduffield/lazygit/issues/2300) /
  [#2337](https://github.com/jesseduffield/lazygit/issues/2337) /
  [#1453](https://github.com/jesseduffield/lazygit/issues/1453)(blocked)/
  [discussion #3241](https://github.com/jesseduffield/lazygit/discussions/3241)

#### 公式の回避策(lazygit v0.56.0 以降)

PowerShell スクリプトを「外部 diff コマンド」として使うことで delta 表示を再現できます。
このリポジトリに公式スクリプト([`windows/lazygit-pager.ps1`](./windows/lazygit-pager.ps1))を同梱しています。

1. delta の導入確認: `delta --version`(なければ `winget install dandavison.delta`)
2. PowerShell 7 の導入確認: `pwsh --version`(なければ `winget install Microsoft.PowerShell`)
3. [`windows/lazygit-pager.ps1`](./windows/lazygit-pager.ps1) を `%LOCALAPPDATA%\lazygit\` にコピー
4. `config.yml` の `git.paging:` ブロックをコメントアウトし、代わりに次を記述
   (`config.yml` 内に同じ内容のコメント例を用意してあります):

   ```yaml
   git:
     pagers:
       - externalDiffCommand: C:/Users/<ユーザー名>/AppData/Local/lazygit/lazygit-pager.ps1
   ```

5. lazygit を再起動

既知の制限: **リネームが「旧ファイルの変更」として表示されます**(ハンクヘッダのみの問題で、差分の内容自体は正しい)。

なお、**WSL(Ubuntu 等)上で lazygit を使う場合は回避策なしで delta が正規に動作**します(最も確実な方法)。

> 補足: lazygit を介さずターミナル単体で delta の表示が崩れる・文字化けする場合は、古い `less.exe` が
> 原因のことが多く、[jftuga/less-Windows](https://github.com/jftuga/less-Windows/releases/latest) の
> 新しい `less.exe` への更新が delta 公式の推奨です。

## 補足

- **差分表示の設定は、新旧どのバージョンでも動く `git.paging` 形式で記述しています。**
  lazygit v0.56.0 以降では初回起動時に新形式 `git.pagers`(配列)へ自動移行され、
  `config.yml` がその場で書き換えられます(正常な動作です)。シンボリックリンク運用の
  場合はリポジトリに差分が出るので、そのままコミットしてください。
- 1 行目の `yaml-language-server` コメントにより、VSCode(YAML 拡張)などでは公式スキーマによる補完・検証が効きます。
- 全設定項目のリファレンスは公式ドキュメントを参照してください:
  - [Config.md](https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md)(全設定項目)
  - [Custom_Command_Keybindings.md](https://github.com/jesseduffield/lazygit/blob/master/docs/Custom_Command_Keybindings.md)(カスタムコマンド)
  - [Custom_Pagers.md](https://github.com/jesseduffield/lazygit/blob/master/docs/Custom_Pagers.md)(delta 等のページャ設定。Windows 向け回避策の原典もここ)

## このリポジトリの運用

- デフォルトブランチは `main` です。設定の変更はトピックブランチを切って Pull Request で取り込みます。
