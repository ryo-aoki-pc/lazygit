# AGENTS.md

このリポジトリで作業するコーディングエージェント（Claude Code・Codex・Grok Build）への指示。Claude Code は CLAUDE.md の `@AGENTS.md` で、Codex と Grok Build はこのファイルを直接読む。

## このリポジトリは何か

[lazygit](https://github.com/jesseduffield/lazygit) の自分用の設定（`config.yml`）と、Excel の差分表示・部分ステージの道具。使い方は [README.md](README.md)、設定の中身は [docs/reference/readme.md](docs/reference/readme.md)、Excel の道具は [docs/excel-diff.md](docs/excel-diff.md)、検証記録は [docs/verification/readme.md](docs/verification/readme.md)。

ドキュメント・コミットメッセージ・Pull Request の説明は日本語で書く。

### ブランチ構成

| ブランチ | 内容 |
| --- | --- |
| `custom` | 実際に使う設定（既定のブランチ）。`main` の上に自分の変更を積んだもの。作業はここから始める |
| `main` | lazygit 公式の既定の設定（`docs/Config.md` の Default の節）をそのまま置いた、上流の追従用。直接編集しない |

- `custom` の `config.yml` は `main` の全項目の形を保ち、変えたい値だけを書き換える（項目の削除・並べ替え・独自のヘッダの追加はしない）
- 自分の変更は `git diff main custom -- config.yml` で見る
- 上流の新しい版への追従は、`main` で `scripts/fetch-upstream-config.sh <タグ>` を実行してコミットし、`custom` を `git rebase main` で載せ直す（README の「このリポジトリの運用」）

## 構成

- `config.yml` — lazygit の設定。lazygit の設定ディレクトリに置くかリンクを張って使う（Windows は `%LOCALAPPDATA%\lazygit` に直接 clone する）
- `scripts/excel-textconv.py` — Git の textconv で、Excel のセルを差分用のテキストにする
- `scripts/excel-stage.py`・`scripts/excel_stage_ooxml.py` — Excel のセル変更を選んで、Excel の形のまま部分ステージする（選んだセルだけを作り直す）
- `scripts/setup-excel-diff.py` — Excel の差分表示と部分ステージを、その端末の Git 全体に設定する（依存はリポジトリの外の仮想環境に入れる。`requirements-excel-diff.txt`）
- `scripts/fetch-upstream-config.sh` — 上流の既定の設定を取り出す（`main` の更新用）
- `tests/` — unittest
- `.gitignore` — Windows の lazygit が同じフォルダーに作る状態ファイル（`state.yml` など）を除く

## テスト

```sh
python3 -B -m unittest discover -s tests -v
```

- リポジトリの直下で動かす。Windows は `python`
- openpyxl などの依存は、`scripts/setup-excel-diff.py` が作る仮想環境の Python で動かすと揃う（[docs/excel-diff.md](docs/excel-diff.md) の「自動検証」）

## 書き方の規則

- 操作は README と `docs/excel-diff.md`、設定の中身と理由は `docs/reference/readme.md`、実施日・環境・結果は `docs/verification/readme.md` に分ける
- 検証していないことを「動く」と書かない。検証記録の過去の節は書き換えず、新しい節を足す

## 共同作業の規則

このリポジトリでは、Claude Code・Codex・Grok Build が同じ規則で作業する。分担と `custom` への取り込みは人が決める。

- 起動された worktree（作業ディレクトリ）の中だけでファイルを変える。ほかの worktree のファイルは変えない
- 今のブランチにだけコミットする。`custom` にはコミットも push もしない
- 頼まれた範囲のファイルだけを変える。範囲の外を変えるときは、変える前に理由を書いて確かめる
- 終わったら、テストとリンターを通してから、目的ごとにコミットする。通らなければコミットせずに、結果を報告する
- コミットしたら、今のブランチを push し、`custom` への Pull Request を作る（既にあれば足す）。`custom` への取り込み（マージ）とブランチの削除は人が行う。今のブランチに `custom` を取り込むのは、頼まれたときと、Pull Request が競合したときだけ
- 秘密情報（`.env`・鍵・トークン・パスワード）を読まない・書かない・出力しない
- レビューを頼まれたら、ファイルを変えずに、指摘を「重大度・場所（ファイル:行）・理由・直し方」で挙げる
- ほかの担当の変更は、`git diff custom...agent/codex` のように git で読む（ほかの worktree へ移らない）
- `main` は上流の追従用。上流の追従を頼まれたとき以外は変えない
