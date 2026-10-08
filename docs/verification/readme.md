# lazygit 検証記録

[導入・更新手順](../../README.md)

lazygit 0.66.0 の公式 JSON スキーマ([schema/config.json](https://github.com/jesseduffield/lazygit/blob/v0.66.0/schema/config.json))と、新規 AlmaLinux 10.2 VM の実 TUI で検証済みです。2026-10-08 には Ubuntu 24.04 のコンテナで、`os.editInTerminal` と Windows 向け手順のうち Linux で確かめられる範囲を確認しました(Windows の実機では未実行)。同じ日に、Windows 11 と Raspberry Pi 5(AlmaLinux 10.2)の実機でも、0.66.0 の既定値に追従した設定を確認しました。

## Windows 11 での Excel 差分の検証と大きいブックへの対応（2026-10-08）

[Excel の textconv 差分表示](#excel-の-textconv-差分表示2026-10-08)を Windows 11 の実機で確かめ、見つかった待ち時間の問題に対応した([大きいブックの表示](../excel-diff.md#大きいブックの表示))。

- 環境: Windows 11 Pro(ビルド 26300)、AMD Ryzen AI MAX+ 395(32 スレッド)、Git 2.55.0.windows.5、Python 3.14.8(scoop)、openpyxl 3.1.5、xlrd 2.0.2、lazygit 0.66.0・delta 0.20.1(scoop)。Linux 側の確認には同じ PC の WSL の AlmaLinux 10(Python 3.12.13、Git 2.52.0)を使った
- 方法: `HOME`・`USERPROFILE`・`LOCALAPPDATA` を一時フォルダーに向けて導入し、実際のグローバル Git 設定は変更していない。lazygit は ConPTY の 140列×40行で起動して pyte で画面を読み取り、`CONFIG_DIR` に同梱 `config.yml` の写しを置いた。`NO_COLOR` は外した

### 導入と自動テスト

- PowerShell の `python scripts/setup-excel-diff.py` で仮想環境・依存関係・Git 設定がそろった(初回は pip のダウンロードを含めて 42 秒)。再実行と `--check` の前後で設定が変わらず、`XDG_CONFIG_HOME` / `XDG_DATA_HOME` を変えても `--check` が成功した
- 既存の `core.attributesFile = ~/.gitattributes`(CRLF・末尾の改行なし)はそのまま残り、Excel の行だけが追記された。6 形式の大小文字混在の拡張子が `diff=excel` になり、`.xlsb` / `.csv` は対象外だった
- 日本語・空白・単一引用符を含む `--install-dir` でも、Git for Windows の sh から変換が動いた
- [`tests/test_excel_textconv.py`](../../tests/test_excel_textconv.py) の 16 テストが、Windows(仮想環境の Python 3.14.8)と WSL の AlmaLinux 10 の両方で成功した。変更前の 10 テストも Windows で成功していた

### lazygit での表示

- 変更・ステージ済み・追加・削除・未追跡・コミットの `.xlsx` / `.XLSX` と、ステージ済みの `.xls` の差分が delta の左右比較で表示された。`|` で切り替えた内蔵表示も同じ内容だった
- ファイル一覧の `Space` でステージした `.xlsx`・`.XLSX`・`.xls` は、インデックスの内容が元のファイルとバイト単位で一致した
- ファイル名に日本語を含むと、delta の見出しは `\345\243\262…` のような 8 進数の表記になる(Git の `core.quotePath` の既定値による。Excel 以外のファイルも同じ)。ファイル一覧の名前は正しく表示される
- `binary=true` のため、ファイル一覧の変更行数とコミットの `--stat` には Excel の行数が出ず、`Bin` と表示される
- 値だけが変わった行は、delta が変更前後を同じ段に並べないことがある(例: `B2 1000` → `B2 1200` は 1 段ずれ、`B2 300` → `B2 350` は同じ段に並んだ)。どちらも左右の同じ行番号の近くに表示される

### 大きいブックで見つけた問題と対応

- 50 万セル(1.9 MB)の `.xlsx` は、1 回の変換に 6.1 秒、キャッシュなしの `git diff` に 14.4 秒かかった。この間も lazygit のキー操作(カーソル移動・`Enter`・`Esc`・`Space`)は 20〜70 ms で反応したが、差分の欄は `loading...` のままだった
- lazygit 0.66.0 の Windows 版は、別のファイルを選んでも実行中の差分コマンドを止めない(ソースの `Terminate` が Windows では何もしない)。重いブック 2 つを順に選んでから小さいファイルへ移ると、変換が最大 4 本同時に走り、移動した後も約 27 秒間 CPU を使い続けた
- 起動直後の lazygit はルート(`/`)を選び、全ファイルの差分を作る。このブックを 2 つ変更したリポジトリでは、60 秒待っても差分の欄が表示されなかった
- 対応として、変換が 2 秒で終わらなければ「変換中」の内容を返し、残りを優先度の低い裏の処理 1 本で順に変換して、結果を内容のハッシュごとにキャッシュするようにした。シートの展開後の大きさから 2 秒で終わらないと分かるブック(展開後 16 MB 超)は待たずに返す。Git の変換キャッシュは仮の内容を保存してしまうため使わない
- 同じ操作で、ルートの差分は 2.9〜4.3 秒で表示され、重いブックを選ぶと 0.01 秒以内に「変換中」が表示された。変換は最大 2 本(表示中の 1 本と裏の 1 本)で、裏の変換が終わると lazygit の 10 秒ごとの更新で、選んだままの差分も完全な内容に切り替わった
- 片方の版だけが変換済みの場合は、その版のセルが全部消えたように表示されるが、「変換中」の行がシート名の行より前に来るため、差分の先頭に出た(lazygit とテストで確認)
- `.xls` の変換は、列名の計算のためだけに openpyxl を読み込んでいた(1 回あたり約 0.24 秒)。自前の計算に替え、1 万セルの `.xls` の変換が 0.31 秒から 0.19 秒になった。キャッシュから返すときは 0.13 秒(小さいブック)〜0.21 秒(10 万セル)だった

### 表示の速さ(変更前後)

lazygit でファイルを選んでから、差分の欄に変更したセルが出るまでの秒数(中央値)。測定中は別のアプリが CPU を 40〜90% 使っていたため、変更前と変更後の版を同じリポジトリで交互に 3 回ずつ測った。「初回」は変換結果のキャッシュを消してから選んだ時間(3 回)、「2 回目以降」はキャッシュがある状態で選び直した時間(12 回。`.xls` は 6 回)。変更前の 2 回目以降は、変更前の版(Git のキャッシュ)を使い、作業中の版だけを変換している。

| 選んだファイル | 変更前 初回 | 変更前 2 回目以降 | 変更後 初回 | 変更後 2 回目以降 |
| --- | ---: | ---: | ---: | ---: |
| テキスト(基準。40 行の 1 行変更) | — | 0.21 | — | 0.18 |
| `.xlsx` 100 セル | 0.99 | 0.50 | 0.92 | 0.48 |
| `.xlsx` 1 万セル | 1.11 | 0.57 | 0.97 | 0.49 |
| `.xlsx` 10 万セル | 2.61 | 1.43 | 2.77 | 0.52 |
| `.xls` 1 万セル | 0.97 | 0.71 | 0.67 | 0.54 |

- Excel の差分を設定しない場合(バイナリ表示)、同じ `.xlsx` を `git diff | delta` で表示するまでは 0.15〜0.23 秒だった
- 起動からルートの差分が出るまでは、変更前 2.03 秒・変更後 1.76 秒だった(キャッシュがある状態、各 3 回の中央値)。Excel の差分を設定しない場合は 1.2〜1.6 秒だった

## Excel の textconv 差分表示（2026-10-08）

[導入手順](../excel-diff.md)に対応する追加の検証。Debian 13.6 のコンテナで、Git 2.52.0、Python 3.12.14、openpyxl 3.1.5、xlrd 2.0.1 / 2.0.2、lazygit 0.66.0、delta 0.20.1 を使った。lazygit / delta の検証用バイナリは公式リリースのチェックサムと一致した。この節は大きいブックへの対応の前の版での確認で、Windows / macOS の実機では未検証だった(Windows は上の節で確認した)。

- [`tests/test_excel_textconv.py`](../../tests/test_excel_textconv.py) の 10 テストが成功。複数シート、日本語・空白を含むパス、拡張子の無い Git 一時ファイル、数式、日付・時刻・真偽値・エラー、セル内改行・タブ、書式だけの変更、不正なシート dimension と破損ファイルを確認した。実際の Git リポジトリで staged / unstaged / 追加 / 削除 / 未追跡の差分も確認した
- lazygit の実 TUI を PTY と pyte で読み取り、同梱 `config.yml` の delta と `|` で切り替える内蔵表示の両方で、変更・ステージ済み・追加・削除・未追跡・コミットの Excel 差分が出ることを確認した。`.xls` も複数シートのセル値を表示した
- ファイル一覧の `Space` でステージした `.xlsx` / `.xls` は、インデックスの内容が元の ZIP / OLE ファイルとバイト単位で一致した
- `Enter` で差分に入って部分ステージすると、既存の Excel ではパッチ適用エラーになった。未追跡の Excel では変換後のテキストをインデックスに入れてしまった。`diff.excel.binary=true` でも操作は禁止されないため、手順ではファイル全体のステージだけを案内している
- 導入スクリプトは隔離した Git 設定と、日本語・空白・単一引用符を含む保存先で実行した。既存の CRLF の属性行を保持し、6 形式の大小文字混在の拡張子が `diff=excel` になることを確認した。再実行と `--check` の前後で設定内容が変わらず、空・相対パス・複数の `core.attributesFile` は設定を書き換えずに止まった
- 変換処理・ライブラリの更新で設置先ファイル名が変わり、Git の変換キャッシュが更新されることを確認した。Windows 向けのパス引用符はコードとして確認したが、Git for Windows での実行は未検証
- システム設定にだけ既存の属性パスがある場合もその内容を保持した。別の `XDG_CONFIG_HOME` / `XDG_DATA_HOME` で起動しても登録済みのパスを使い、`--check` が設定を変更せず成功した。作業環境の通常の Git 設定にも導入し、新規の検証リポジトリで `.XLSX` のセル変更が delta に渡ることを確認した

## Windows と Raspberry Pi の実機での検証（2026-10-08）

Windows 11 の PC と、Raspberry Pi 5 の AlmaLinux 10.2 の 2 台(kawasaki-pi・abiko-pi)で、実際に使っている lazygit を起動して確かめた。3 台の設定フォルダーは同じ clone を Syncthing で同期しており、確認の前に `e6081c2` へ更新した。

- 確認後の版: lazygit 0.66.0(Windows は scoop、Pi は Homebrew)、delta 0.20.1(Windows は scoop、Pi は Homebrew)、Git 2.55.0.windows.5(Windows)/ 2.52.0(Pi)
- 確認前の版: Windows は lazygit 0.65.1・delta なし、kawasaki-pi は 0.65.1・delta 0.20.1、abiko-pi は 0.66.0・delta なし
- 方法: 疑似端末(Windows は ConPTY、Linux は pty)の 120列×40行で lazygit を起動し、画面を pyte で読み取った。`CONFIG_DIR` を一時フォルダーにして設定の写しを置き(実際の設定ファイルと同じ SHA256)、試験用リポジトリ(日本語・タブ・長い行・途中の追加行を含む変更 1 ファイル、`:sparkles:` を含むコミット、`main` より 1 つ遅れたブランチ)を開いた。起動 → `Enter` → `Esc` → `|` → `|` → `2` → `3` → `4` → `+` → `_` → `q` の各画面を確かめた
- AlmaLinux 10 の tmux(`tmux-3.3a-13.20230918gitb202a2f.el10`)は `capture-pane` でサーバーが落ちたため、Linux でも tmux は使わなかった

| 環境 | lazygit / delta | 結果 |
| --- | --- | --- |
| Windows(確認前) | 0.65.1 / なし | 差分ビューに `delta: command not found` だけが出る。`\|` で内蔵表示に切り替えると読める |
| abiko-pi(確認前) | 0.66.0 / なし | 同上 |
| kawasaki-pi(確認前) | 0.65.1 / 0.20.1 | 問題なし |
| 3 台(確認後) | 0.66.0 / 0.20.1 | 問題なし(`e6081c2`、#10、この追従後の設定のいずれも) |

- 「問題なし」は次をすべて満たしたこと: 自動移行・検証エラーの表示が無い、起動前後で設定の SHA256 が変わらない、マウスの追跡を有効にしない、ファイル一覧に変更行数とアイコンが出る、delta の左右比較が出る、`|` で内蔵表示と行き来できる、`2` の再押下でタブが切り替わる、ブランチにハッシュと `↓1` が出る、コミットに 8 桁のハッシュと ✨ が出る、展開表示の日付が `2006-01-02` 形式、`q` で終了する
- 0.66.0 では、`Enter` でフォーカスした差分も delta の左右比較のまま表示された(3 台とも)。0.65.1 では内蔵表示になった。2026-10-06 の記録で実 TUI では未試験としていた点
- 更新前の設定(`dc3873e` に未コミットの delta の変更を載せたもの)を 0.66.0 で起動すると、4 キーの自動移行で設定ファイルが書き換えられた。設定フォルダーは 3 台で同期しているため、更新しないまま abiko-pi で起動すると、書き換えが 3 台に広がるところだった

### 0.66.0 の既定値への追従

- `main` を `scripts/fetch-upstream-config.sh v0.66.0` で更新し、`custom` を rebase した。rebase 前の履歴はタグ `custom-pre-v0.66.0` に残した
- `config.yml` は、v0.66.0 の既定値の全項目に 17 項目の変更(各値の直上に日本語コメント)を載せた形にした。`git diff main custom -- config.yml` はこの 17 項目だけになる
  - 0.65.1 の既定値のまま固定していた `gui.theme.selectedLineBgColor`(`blue`)と `inactiveViewSelectedLineBgColor`(`bold`)は、0.66.0 の既定値 `[]`(端末の背景色から自動で決める)になる
  - 0.66.0 で増えたキー(`gui.colorScheme`・`gui.theme.selectedLineFgColor`・`gui.darkTheme`・`gui.lightTheme`・`gui.commitGraphStyle`・`keybinding.universal.jumpToFile`・`keybinding.main.prevFile` / `nextFile`)を既定値のまま加えた
- v0.66.0 の JSON スキーマへの照合ではエラーが 2 件出る。`selectedLineBgColor` と `inactiveViewSelectedLineBgColor` の `[]` が、スキーマの `minItems: 1` に合わないため。公式の既定値一覧(docs/Config.md)そのものも同じ 2 件のエラーになり、upstream の master でも同じ。lazygit は `[]` を自動の色として読み、起動時のエラーは出ない
- 3 台の実 TUI で上の項目がすべて問題なく、`e` も 3 台で動いた

### Windows で確かめたこと

- `scoop install delta` で delta 0.20.1 を入れた。この PC には `VCRUNTIME140.dll` があり、`delta --version` が動いた
- 描画のコマンドは `cmd /s /c "delta …"` で実行された(コマンドログに表示)。同梱の `config.yml` の delta の行は、そのまま左右比較で表示された
- README の単一引用符の形は表示が崩れた。速度優先は左の行番号の欄に `''`、区切りに `'│` がそのまま出て、見やすさ優先は `[bat warning]: Unknown theme ''Monokai', using default.` が出て既定のテーマになった。二重引用符の形は `│` を含めて正しく表示された
- `e`(Neovim 0.12.5。ユーザー設定を読まないよう、XDG の場所を一時フォルダーに向けた): `editInTerminal: false` では Neovim が画面に出ず、端末の無い Neovim のプロセスが残った。その後の lazygit の終了も不安定だった。`true` では Neovim が全画面に出て、`:q!` で Enter を求められずに lazygit に戻った。Pi の Vim 9.1 でも同じ結果だった
- Windows の lazygit は、`state.yml` と `github_pull_requests.json` を `%LOCALAPPDATA%\lazygit` に作っていた(実際の設定フォルダーで確認)

### 表示の速さ

lazygit の中で `|` を押して、内蔵表示から delta の左右比較に切り替えてから、左右比較が画面に出るまでの時間(7 回の中央値)。内蔵表示は、delta から `|` で戻したときの時間(3 つの設定で測った中央値の範囲)。

| 追加・削除の合計行数 | Windows 同梱設定 | Windows 速度優先 | Windows 見やすさ優先 | Windows 内蔵表示 |
| --- | ---: | ---: | ---: | ---: |
| 200行 | 409 ms | 373 ms | 698 ms | 190〜314 ms |
| 2,000行 | 842 ms | 403 ms | 423 ms | 548〜837 ms |
| 20,000行 | 385 ms | 1,642 ms | 2,035 ms | 4,435〜7,571 ms |

| 追加・削除の合計行数 | kawasaki-pi 同梱設定 | kawasaki-pi 速度優先 | kawasaki-pi 見やすさ優先 | kawasaki-pi 内蔵表示 |
| --- | ---: | ---: | ---: | ---: |
| 200行 | 56 ms | 59 ms | 60 ms | 63〜83 ms |
| 2,000行 | 101 ms | 102 ms | 116 ms | 264〜292 ms |
| 20,000行 | 3,783 ms | 3,760 ms | 3,746 ms | 7,497〜10,101 ms |

`git diff | delta` の全文処理時間(下の「delta の表示と性能の検証」と同じ条件。表示幅100列、ANSIによる行末描画、ウォームアップの後にランダムな順で7回測った中央値)。「git diff のみ」は delta を通さない時間。

| 追加・削除の合計行数 | Windows git diff のみ | Windows 同梱設定 | Windows 速度優先 | Windows 見やすさ優先 |
| --- | ---: | ---: | ---: | ---: |
| 200行 | 47 ms | 163 ms | 195 ms | 178 ms |
| 2,000行 | 55 ms | 209 ms | 160 ms | 421 ms |
| 20,000行 | 106 ms | 1,113 ms | 507 ms | 4,472 ms |

| 追加・削除の合計行数 | kawasaki-pi git diff のみ | kawasaki-pi 同梱設定 | kawasaki-pi 速度優先 | kawasaki-pi 見やすさ優先 |
| --- | ---: | ---: | ---: | ---: |
| 200行 | 4 ms | 33 ms | 24 ms | 97 ms |
| 2,000行 | 22 ms | 179 ms | 103 ms | 773 ms |
| 20,000行 | 990 ms | 2,522 ms | 1,776 ms | 8,560 ms |

- 差分は、変更なし 3 行と書き換え 2 行の組を繰り返し、追加・削除の合計を 200 / 2,000 / 20,000 行にした 1 ファイル(日本語・タブ・長い行を含む)。既存の測定とは差分の内容と測定機が違うため、数値は直接比べられない
- 小さな差分では、Windows の表示は Pi の 5〜8 倍の時間がかかった。git(約 40 ms)と delta(scoop の shim 経由で約 52 ms、`delta.exe` を直接起動すると約 29 ms)の起動が Pi(2 ms・5 ms)より長く、表示のたびに起動するため
- 20,000 行の差分では、CPU の速い Windows のほうが全文処理は速かった。見やすさ優先は構文ハイライトのため、Windows で 4.5 秒、Pi で 8.6 秒かかった
- Windows はばらつきが大きく、200 行の同梱設定で 299〜1,146 ms だった
- Windows では、Claude アプリのツール実行環境が付ける `NO_COLOR` を外して測った(付いたままだと lazygit が色を使わない)。delta は `NO_COLOR` に従わないことも確認した

### 今回の未確認範囲

- README の PowerShell のブロック(導入方法・元に戻す)は実機で実行していない。この PC の `%LOCALAPPDATA%\lazygit` は Syncthing で同期している clone のため
- `VCRUNTIME140.dll` が無い PC での delta、Windows での Vim の `e`、Windows の Neovim の中から開いた lazygit(`nvim-remote`)
- 実際の GUI の端末でのグリフの見た目(画面は pyte で読み取った文字と色で確認した)、TUI からのコミット・push

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

このうち、Windows での `e`(Neovim)、引用符と `│` の受け渡し、`config.yml` の delta の行の表示、状態ファイルの置き場所は、同じ日に[実機で確かめた](#windows-で確かめたこと)。

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
