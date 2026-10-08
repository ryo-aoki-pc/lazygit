# lazygit 検証記録

[導入・更新手順](../../README.md)

lazygit 0.66.0 の公式 JSON スキーマ([schema/config.json](https://github.com/jesseduffield/lazygit/blob/v0.66.0/schema/config.json))と、新規 AlmaLinux 10.2 VM の実 TUI で検証済みです。2026-10-08 には Ubuntu 24.04 のコンテナで、`os.editInTerminal` と Windows 向け手順のうち Linux で確かめられる範囲を確認しました(Windows の実機では未実行)。

## editInTerminal と Windows 向け手順の確認（2026-10-08）

Linux(Ubuntu 24.04.5、x86_64 のコンテナ)で確認した。Windows の実機では何も実行していない。

- 版: lazygit 0.66.0(公式の `lazygit_0.66.0_linux_x86_64.tar.gz`。SHA256 は公式の `checksums.txt` と一致)、Vim 9.1、tmux 3.4、Git 2.43.0、delta 0.20.1(`x86_64-unknown-linux-gnu`)、Neovim 0.12.5、PowerShell 7.6.2(Linux 版)
- lazygit は `env -i` で環境変数を空にしてから起動し、エディタの指定は `EDITOR=vim` だけにした(`VISUAL`・`GIT_EDITOR`・`core.editor` は無し)。設定は `config.yml` の写しを読ませ、変更が 1 ファイルある試験用リポジトリを tmux の 120列×40行で開いた

```sh
env -i HOME=<作業用> PATH=<lazygit の場所>:/usr/bin:/bin TERM=screen-256color SHELL=/bin/bash EDITOR=vim LANG=C.UTF-8 \
  lazygit --use-config-file <config.yml の写し> -p <試験用リポジトリ>
# ファイル一覧で e を押し、tmux capture-pane で画面を、/proc/<vim の PID>/fd/0〜2 で vim の標準入出力を見た
```

### `e` キーと `os.editInTerminal`

| `os.editInTerminal` | `e` を押した後 | その後 |
| --- | --- | --- |
| `false`(変更前) | 画面は lazygit のまま。`vim` は起動するが、標準入力が `/dev/null`、標準出力・標準エラーがパイプで、端末が無い。lazygit はキー入力に反応しない | `:q` を送っても(キーは vim に届かない)、vim は終わらない(`e` から 40 秒の時点でも起動したまま)。vim を `kill` すると、`Vim: Warning: Output is not to a terminal` / `Vim: Warning: Input is not from a terminal` のエラーが出た |
| `true`(変更後) | vim が全画面に出る(標準入力は `/dev/pts/N`) | `:q` で lazygit に戻る。編集して `:wq` すると、ファイル一覧の変更行数が `+1` から `+2` に更新された |
| キーを消す(参考) | `true` と同じ | `true` と同じ |

- lazygit 0.66.0 の `getEditInTerminal`([editor_presets.go](https://github.com/jesseduffield/lazygit/blob/v0.66.0/pkg/config/editor_presets.go#L193))は、`editInTerminal` が書かれていればその値を使い、無ければプリセット(`vim` / `nvim` は一時停止する)に従う。公式デフォルト一覧から写した `false` が、プリセットの判定より優先されていた。0.65.1 も同じ実装
- 変更後の `config.yml` は v0.66.0 の `schema/config.json` への照合(Python の jsonschema 4.26.0)でエラー 0 件。lazygit の起動・終了の前後で設定の SHA256 は変わらなかった

### Neovim の中から開いた lazygit(`nvim-remote`)

snacks.nvim の lazygit と同じく、`LG_CONFIG_FILE` の最後に `os.editPreset: nvim-remote` だけの設定ファイルを足し、`nvim --clean` の `:terminal` で lazygit を開いて `e` を押した(`$NVIM` が設定された状態)。snacks.nvim・LazyVim そのものは使っていない。

| `os.editInTerminal` | `e` を押した後 |
| --- | --- |
| `false`(変更前) | lazygit が終了し、ファイルは Neovim の新しいタブに開いた |
| `true`(変更後) | ファイルは Neovim の新しいタブに開いたが、lazygit は終了せず、元のタブの端末に残った |
| `true` で、足した設定ファイルに `editInTerminal: false` も書く | 変更前と同じ |

- 値を `null` にする(キーを残して未設定にする)と両方の場面でプリセットどおりに動いたが、JSON スキーマの照合で `None is not of type 'boolean'` のエラーになるため採らなかった

### delta の設定例の引用符

- [README の設定例](../../README.md#設定手順)の 2 つのコマンドを、単一引用符の形と二重引用符の形で、Linux の lazygit と同じ `/bin/bash -c` に通して比べた(`git -c color.diff=always diff | /bin/bash -c '<コマンド>'`)。速度優先・見やすさ優先とも、出力はバイト単位で一致した
- 二重引用符の形を設定ファイルに書いて lazygit を起動した。コマンドログに `/bin/bash -c "delta … --word-diff-regex="(?s).+" … --line-numbers-right-format="│ " --wrap-max-lines=0"` と出て、`|` で速度優先 → 見やすさ優先 → 内蔵表示 → 速度優先と切り替わり、エラーは出なかった
- Windows で `cmd /s /c "<コマンド>"` で実行することは、lazygit 0.66.0 の [cmd_obj_builder.go](https://github.com/jesseduffield/lazygit/blob/v0.66.0/pkg/commands/oscommands/cmd_obj_builder.go)(`newWindowsShell`)と [os_windows.go](https://github.com/jesseduffield/lazygit/blob/v0.66.0/pkg/commands/oscommands/os_windows.go) を読んだもの

### Windows 向けの手順(Linux で確かめた範囲)

- `delta-0.20.1-x86_64-pc-windows-msvc.zip`(scoop の `delta` 0.20.1 の manifest と同じ URL)の `delta.exe` を `objdump -p`(GNU Binutils 2.42)で読み、インポートに `VCRUNTIME140.dll` があることを確認した。zip にはランタイムの DLL が無く、manifest に `depends` / `suggest` も無い
- README の PowerShell のブロック 4 つ(導入方法・元に戻す確認・元に戻す・delta の導入)と `Test-Path "$env:WINDIR\System32\vcruntime140.dll"` は、PowerShell 7.6.2 のパーサーでエラー 0 件(Windows PowerShell 5.1 のパーサーではない)。導入方法のブロックは、パスの `\` を `/` に替え、`LOCALAPPDATA` を作業用のフォルダーにして 3 通りを流した
  - 何も無い: GitHub の公開 URL から clone し、`custom` と出た
  - `lazygit` がある: `moved: …/lazygit -> …/lazygit.bak` の後に clone し、`custom` と出た
  - `lazygit.bak` がある: 警告だけを出し、フォルダーの中身は変わらなかった
- 元に戻すブロック 2 つも、同じくパスの `\` を `/` に替えて流した。GitHub の公開 URL から clone した `lazygit` と、中身の分かる `lazygit.bak` を置いて試した
  - 1 つ目(確認): clone したままでは何も出なかった。`config.yml` を書き換えると ` M config.yml`、さらにコミットすると `<ハッシュ> test` が出た
  - 2 つ目(削除と復元): `lazygit` が消え、`lazygit.bak` が `lazygit` に戻った(中身は置いたときのまま)。`lazygit.bak` が無い場合は `lazygit` が消えるだけで、エラーは出なかった
- Windows と同じく設定と状態を 1 つのフォルダーに置く形(`XDG_CONFIG_HOME` と `XDG_STATE_HOME` を同じにする)で、clone した設定で lazygit を起動・終了した。clone の中に `state.yml` ができ、`git status --short` は空(`--ignored` では `!! state.yml`)、`config.yml` の SHA256 は変わらなかった
- 同じ形で、作業ツリーの `.gitignore`(`development.log` を追加)と `config.yml` を入れた clone を使い、`lazygit --debug` で起動・終了した。clone の中に `development.log` もでき、`git status --short` は空(`--ignored` では `!! development.log` と `!! state.yml`)、`config.yml` の SHA256 は変わらなかった
- Git for Windows の既定(`core.autocrlf=true`)で取り出したときに備え、改行を CRLF にした `config.yml` でも起動した。delta の描画の設定と `e` の動き(vim が全画面に出て、`:q` で戻る)は LF のときと同じで、ファイルは書き換えられなかった

### Windows で未検証の項目

- Windows PowerShell 5.1 への導入方法のブロックの貼り付けと実行(`Move-Item`、`git clone`、`lazygit --print-config-dir` が `C:\Users\<ユーザー名>\AppData\Local\lazygit` を出すこと)
- Windows PowerShell 5.1 での元に戻すブロック 2 つの実行(`Remove-Item -Recurse -Force` で clone の読み取り専用のファイルも消えること)
- Windows の lazygit が `state.yml`・`github_pull_requests.json`・`development.log`(`--debug` のとき)を `%LOCALAPPDATA%\lazygit` に作ること(lazygit 0.66.0 と adrg/xdg 0.5.3 のソースでは、Windows の状態の置き場所の既定は `%LOCALAPPDATA%`)
- Windows での `e`(`editInTerminal: true` で、cmd.exe から起動した Vim / Neovim が端末を受け取り、終了後に lazygit に戻ること)
- `cmd /s /c` での delta の設定例の引用符(単一引用符の形が失敗し、二重引用符の形が動くこと)と、`│` などの ASCII 以外の引数の受け渡し
- リポジトリの `config.yml` の delta の行の、Windows での表示
- `VCRUNTIME140.dll` が無い PC で `delta.exe` が起動しないことと、Visual C++ 再頒布可能パッケージを入れた後の起動(`winget install --exact --id Microsoft.VCRedist.2015+.x64` の実行と管理者の承認を含む)
- Windows の Neovim の中から開いた lazygit の `e`(`nvim-remote` のテンプレートは POSIX sh の構文で、Windows では cmd.exe で動かすため、動かない可能性が高い。[lazygit の issue #3467](https://github.com/jesseduffield/lazygit/issues/3467))

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
