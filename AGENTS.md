# AGENTS.md

このリポジトリで作業するコーディングエージェント（Claude Code・Codex・Grok Build・Antigravity CLI）への指示。Claude Code は CLAUDE.md の `@AGENTS.md` で、Codex・Grok Build・Antigravity CLI はこのファイルを直接読む。

利用者への回答・質問・報告は、常に日本語で書く（コードのコメントなどの言語は、このファイルのほかの決まりに従う）。

## 導入手順の正本

導入・更新・使い方の手順は、setup-notes の [almalinux-setup.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/almalinux-setup.md#lazygit) と [windows-setup.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/windows-setup.md#lazygit) の「lazygit」とその子の項（設定の導入・Excel の差分表示）にある。このリポジトリには置かない。Windows 11 の設定のロールバックと、macOS の導入（Excel の差分表示）は、このリポジトリに置く。

## このリポジトリは何か

[lazygit](https://github.com/jesseduffield/lazygit) の自分用の設定（`config.yml`）と、Excel の差分表示・部分ステージの道具。導入の表と、このリポジトリの運用は [README.md](README.md)、設定の中身は [docs/reference/readme.md](docs/reference/readme.md)、Excel の道具は [docs/excel-diff.md](docs/excel-diff.md)、検証記録は [docs/verification/readme.md](docs/verification/readme.md)。

ドキュメント・コミットメッセージ・Pull Request の説明は日本語で書く。

### ブランチ構成

`custom` が実際に使う設定（既定のブランチ。作業はここから始める）、`main` が lazygit 公式の既定の設定を置いた上流の追従用（直接編集しない）。`config.yml` の書き換え方と上流への追従は、README の「このリポジトリの運用」に従う。

## 構成

- `config.yml` — lazygit の設定。lazygit の設定ディレクトリに置くかリンクを張って使う（Windows は `%LOCALAPPDATA%\lazygit` に直接 clone する）
- `scripts/excel-textconv.py` — Git の textconv で、Excel のセルを差分用のテキストにする
- `scripts/excel-stage.py`・`scripts/excel_stage_ooxml.py` — Excel のセル変更を選んで、Excel の形のまま部分ステージする（選んだセルだけを作り直す）
- `scripts/setup-excel-diff.py` — Excel の差分表示と部分ステージを、その端末の Git 全体に設定する（依存はリポジトリの外の仮想環境に入れる。`requirements-excel-diff.txt`）
- `scripts/fetch-upstream-config.sh` — 上流の既定の設定を取り出す（`main` の更新用）
- `tests/` — unittest
- `.gitignore` — Windows の lazygit が同じフォルダーに作る状態ファイル（`state.yml` など）を除く
- `docs/excel-diff.md` — Excel の差分表示の仕様と検査・macOS の導入。`docs/extra/excel-diff.md` — その対応条件と制限（注意点）
- `docs/extra/readme.md` — Windows 11 の設定のロールバック。`docs/reference/readme.md` — 設定の中身と理由。`docs/verification/readme.md` — 検証記録。`docs/images/` — README の画像

## テスト

```sh
python3 -B -m unittest discover -s tests -v
```

- リポジトリの直下で動かす。Windows は `python`
- openpyxl などの依存は、`scripts/setup-excel-diff.py` が作る仮想環境の Python で動かすと揃う（[docs/excel-diff.md](docs/excel-diff.md) の「自動検証」）

## 文書の置き場所

- 導入・利用・更新の手順は正本に置き、README の「導入」の表から正本の項へ直接リンクする（手順書の先頭やカテゴリの見出しへはリンクしない）。執筆規則は setup-notes の `docs/dev/writing-rules.md`
- `docs/extra/` はロールバックと注意点、`docs/reference/` は設定の中身と理由、`docs/verification/` は検証記録（実施日・環境・結果・未確認事項）。テストのコマンドは上の「テスト」
- 案内だけになった文書・節は消し、旧パスと移動先を setup-notes の集約対応表に足す。消すときは参照元のリンクを付け替える（検証記録は、削除前の固定コミットの URL にする）
- 検証していないことを「動く」と書かない。検証記録の過去の節は書き換えず、新しい節を足す

## 共同作業の規則

このリポジトリでは、Claude Code・Codex・Grok Build・Antigravity CLI が同じ規則で作業する。分担と `custom` への取り込みは人が決める。

- 起動された worktree（作業ディレクトリ）の中だけでファイルを変える。ほかの worktree のファイルは変えない
- 今のブランチにだけコミットする。`custom` にはコミットも push もしない
- 頼まれた範囲のファイルだけを変える。範囲の外を変えるときは、変える前に理由を書いて確かめる
- 終わったら、テストとリンターを通してから、目的ごとにコミットする。通らなければコミットせずに、結果を報告する
- コミットしたら、今のブランチを push し、`custom` への Pull Request を作る（既にあれば足す）。`custom` への取り込み（マージ）とブランチの削除は人が行う。今のブランチに `custom` を取り込むのは、頼まれたときと、Pull Request が競合したときだけ
- 秘密情報（`.env`・鍵・トークン・パスワード）を読まない・書かない・出力しない
- レビューを頼まれたら、ファイルを変えずに、指摘を「重大度・場所（ファイル:行）・理由・直し方」で挙げる
- ほかの担当の変更は、`git diff custom...agent/codex` のように git で読む（ほかの worktree へ移らない）
- `main` は上流の追従用。上流の追従を頼まれたとき以外は変えない
