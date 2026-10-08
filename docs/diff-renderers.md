# delta の設定と表示

[文書一覧](README.md) / [設定の導入](setup.md) / [検証記録](verification/readme.md#delta-の表示と性能の検証)

このリポジトリの `config.yml` は、構文ハイライトを省いた左右比較を使用しています。以下は、速度優先・見やすさ優先・内蔵表示を切り替えて使うための設定例です。

## 設定手順

1. `delta --version` で導入を確認します。Homebrew を使う場合は `brew install git-delta`、Windows の scoop では `scoop install delta` で導入できます(Windows は[Windows で使う場合](#windows-で使う場合)も参照)。
2. `lazygit --print-config-dir` で設定ディレクトリを確認し、その中の `config.yml` を開きます。既存の `git.diffRenderers` を下の3項目に置き換えます。`git:` がすでにある場合は、その中に設定してください。
3. 保存後に lazygit を終了して再起動します。

```yaml
git:
  diffRenderers:
    - command: >-
        delta --no-gitconfig --dark --paging=never --syntax-theme=none --tabs=4 --side-by-side
        --raw --inspect-raw-lines=false --word-diff-regex='(?s).+' --max-line-distance=1
        --line-numbers-left-format='' --line-numbers-right-format='│ ' --wrap-max-lines=0
      colorArg: never
      name: delta side-by-side fast
    - command: >-
        delta --no-gitconfig --dark --paging=never --tabs=4 --side-by-side --line-numbers
        --syntax-theme='Monokai Extended' --wrap-max-lines=unlimited
      name: delta side-by-side readable
    - type: rawGit
      name: default
```

起動時は最初の `delta side-by-side fast` が選ばれます。`|` キーを押すたびに、速度優先 → 見やすさ優先 → 内蔵表示 → 速度優先の順に切り替わります。見やすさ優先を初期表示にする場合は、`delta side-by-side readable` の項目を `diffRenderers` 配列の先頭に移動してください。

共通の `--no-gitconfig` は Git 側の delta 設定を読み込まず、この設定例の表示を使います。`--paging=never` は外部ページャを起動せず、`--tabs=4` は lazygit のタブ幅に揃えます。ダーク背景向けのため、ライト背景の端末では両方の `--dark` を `--light` にし、見やすさ優先の構文テーマを `--syntax-theme=GitHub` に変更してください。

左右比較では変更前が左、変更後が右に並びます。表示幅が足りない場合は、`0` キーで差分ビューにフォーカスし、`+` キーで拡大してください。ファイル一覧やコミットの差分閲覧で有効です。lazygit 0.66.0 では、Enter で差分ビューに入り、delta 0.20.1 の表示を保ったまま行・ハンクを選択できます。lazygit 0.65.1 では、Enter で入るステージング画面は内蔵表示になります。

## Windows で使う場合

Windows の lazygit は、描画のコマンドを `cmd /s /c "<コマンド>"`(cmd.exe)で実行します。cmd.exe も delta.exe の引数の解釈も単一引用符 `'…'` を引用符として扱わないため、`'` が値に残ったり、空白で引数が分かれたりします。上の設定例は、単一引用符を二重引用符に置き換えた次の形で使ってください。

```yaml
git:
  diffRenderers:
    - command: >-
        delta --no-gitconfig --dark --paging=never --syntax-theme=none --tabs=4 --side-by-side
        --raw --inspect-raw-lines=false --word-diff-regex="(?s).+" --max-line-distance=1
        --line-numbers-left-format="" --line-numbers-right-format="│ " --wrap-max-lines=0
      colorArg: never
      name: delta side-by-side fast
    - command: >-
        delta --no-gitconfig --dark --paging=never --tabs=4 --side-by-side --line-numbers
        --syntax-theme="Monokai Extended" --wrap-max-lines=unlimited
      name: delta side-by-side readable
    - type: rawGit
      name: default
```

二重引用符の形は、Linux でも単一引用符の形と同じ表示になります。このリポジトリの `config.yml` の delta の行は引用符を使っていないため、Windows でも書き換えは不要です。

Windows の `delta.exe` は Visual C++ ランタイム(`VCRUNTIME140.dll`)を必要とします。scoop の `delta` はランタイムを含まないため、PowerShell で `Test-Path "$env:WINDIR\System32\vcruntime140.dll"` が `False` の場合は、先に [Visual C++ 再頒布可能パッケージ](https://learn.microsoft.com/ja-jp/cpp/windows/latest-supported-vc-redist)の X64 版を入れてから(インストールには管理者の承認が要ります。winget では `winget install --exact --id Microsoft.VCRedist.2015+.x64`)、delta を入れてください。

```powershell
scoop install delta
delta --version
```

Windows 11 の実機で、scoop の delta 0.20.1 と、同梱の `config.yml`・上の二重引用符の形の表示を確認しました。単一引用符の形は表示が崩れます。結果は[検証記録](verification/readme.md#windows-と-raspberry-pi-の実機での検証2026-10-08)に記載しています。

## 速度を最優先にする設定

`delta side-by-side fast` は、確認した候補の中で表示速度を優先した設定です。構文ハイライト、行番号、単語単位の強調を省き、`--raw` で追加・削除を緑・赤の文字と `+/-` で表示します。`colorArg: never` と `--inspect-raw-lines=false` で Git の色入力と色移動の検査を省きます。

`--word-diff-regex='(?s).+'` は一行をまとめて扱い、`--max-line-distance=1` はバッファ内の削除行と追加行を出現順に対応付けます。似た行を探して対応付ける処理を減らすため、追加行が途中に挟まる場合などは、変更前後の対応がずれることがあります。行バッファは既定値32を使用します。

`--wrap-max-lines=0` は折り返しを止め、列幅に収まらない部分を省略します。長い行の末尾を確認する場合は差分ビューを拡大するか、見やすさ優先へ切り替えてください。

全文処理時間の比較と測定条件は[検証記録](verification/readme.md#delta-の表示と性能の検証)を参照してください。Windows では git と delta の起動に時間がかかるため、小さな差分でも lazygit での表示に 0.4 秒前後かかります([Windows と Raspberry Pi の測定](verification/readme.md#表示の速さ))。

## 見やすさを優先する設定

`delta side-by-side readable` は、行番号、`Monokai Extended` による構文ハイライト、単語単位の変更強調を表示します。行の類似度による対応付けは既定値を使い、途中に追加行がある場合も対応する変更前後の行を探します。

`--wrap-max-lines=unlimited` で長い行を末尾まで折り返します。表示を増やして内容を確認しやすくする設定のため、構文解析や長い行の描画に時間がかかります。大きな差分を素早く切り替える場合は、速度優先または `default` を選んでください。

## 表示の比較

同じファイルの差分を、120列×40行の lazygit 画面で比較しています。ダーク背景と HackGen Console NF を使用し、コマンドログを非表示にしています。

**内蔵表示** — 追加・削除の行を Git の色分けで表示します。

![lazygitの内蔵差分表示](images/diff-renderers/native.png)

**軽量deltaの通常表示** — 構文ハイライトを省いて変更前後を一列に並べ、変更した単語を強調します。

![deltaの一列の差分表示](images/diff-renderers/delta-unified.png)

**同梱設定の軽量な左右比較** — 構文ハイライトを省き、行番号と単語単位の強調を残した左右比較です。リポジトリの `config.yml` はこの設定を使用しています。

![構文ハイライトを省いたdeltaの左右比較](images/diff-renderers/delta-side-by-side.png)

**速度優先の左右比較** — 行番号と単語単位の強調を省き、変更行を順番に並べます。長い行は列幅で省略します。

![速度を優先したdeltaの左右比較](images/diff-renderers/delta-side-by-side-fast.png)

**見やすさ優先の左右比較** — 構文ハイライト、行番号、単語単位の強調を使い、長い行を折り返します。

![見やすさを優先したdeltaの左右比較](images/diff-renderers/delta-side-by-side-readable.png)

設定形式と切替操作は [lazygit の公式資料](https://github.com/jesseduffield/lazygit/blob/v0.66.0/docs/Custom_DiffRenderers.md)、左右比較は [delta の公式資料](https://dandavison.github.io/delta/side-by-side-view.html)、各オプションは [delta の公式ヘルプ](https://dandavison.github.io/delta/full---help-output.html)を参照してください。動作確認の環境と内容は[検証記録](verification/readme.md#delta-の表示と性能の検証)に記載しています。
