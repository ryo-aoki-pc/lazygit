# AGENTS.md

このリポジトリで作業するコーディングエージェント（Claude Code・Codex・Grok Build・Antigravity CLI）への指示。Claude Code は CLAUDE.md の `@AGENTS.md` で、Codex・Grok Build・Antigravity CLI はこのファイルを直接読む。

利用者への回答・質問・報告は、常に日本語で書く（コードのコメントなどの言語は、このファイルのほかの決まりに従う）。

## 導入手順の正本

Windows 11・AlmaLinux 10 の導入・利用・更新・任意操作は、setup-notes の [windows-setup.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/windows-setup.md) と [almalinux-setup.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/almalinux-setup.md) に集約する。既存の手順も対象とする。

- 固有の仕様・他 OS の手順・開発者検査・理由・注意・検証記録・ロールバックが残る文書は保持する
- 案内だけになった旧文書は削除する。README から上の2冊と[集約対応表](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/dev/consolidation-map.md)へ案内する

文書規則は、Windows・AlmaLinux の実行手順には上の正本へ適用する。操作や移動先を変えたら正本・README・集約対応表・参照情報を同期し、過去の検証本文は保持する。共通 bash 設定が読むツールの初期化を `~/.bashrc` に直接追記しない。

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
- [docs/extra/readme.md](docs/extra/readme.md) — Windows で退避した設定を戻す手順

## テスト

```sh
python3 -B -m unittest discover -s tests -v
```

- リポジトリの直下で動かす。Windows は `python`
- openpyxl などの依存は、`scripts/setup-excel-diff.py` が作る仮想環境の Python で動かすと揃う（[docs/excel-diff.md](docs/excel-diff.md) の「自動検証」）

## 書き方の規則

- Windows・AlmaLinux の操作は setup-notes の2冊、設定の中身と理由は `docs/reference/readme.md`、実施日・環境・結果は `docs/verification/readme.md` に分ける
- 検証していないことを「動く」と書かない。検証記録の過去の節は書き換えず、新しい節を足す

## 共同作業の規則

このリポジトリでは、Claude Code・Codex・Grok Build・Antigravity CLI が同じ規則で作業する。分担は人が決める。

- 起動された worktree（作業ディレクトリ）の中だけでファイルを変える。ほかの worktree のファイルは変えない
- 今のブランチにだけコミットする。`custom` にはコミットも push もしない
- 頼まれた範囲のファイルだけを変える。範囲の外を変えるときは、変える前に理由を書いて確かめる
- 終わったら、テストとリンターを通してから、目的ごとにコミットする。通らなければコミットせずに、結果を報告する
- コミットしたら、今のブランチを push し、`custom` への Pull Request を作る（既にあれば足す）。今のブランチに `custom` を取り込むのは、頼まれたときと、Pull Request が競合したときだけ
- `custom` への取り込み（マージ）は、エージェントが行ってよい（2026-10-15、利用者の決定）。テストとリンターが通り、Pull Request が競合していなければ、`gh pr merge --squash` で Pull Request を取り込む（手元の `custom` にはコミットも push もしない）。利用者が取り込まないよう頼んだときは取り込まず、そのことを報告する。取り込んだ Pull Request のブランチは、GitHub がリモートから自動で消す（リポジトリの Automatically delete head branches は人が有効にしておき、エージェントは変えない）。取り込んだブランチには、その後コミットも push もせず、次の作業は新しいブランチで始める。手元に残ったブランチの削除は人が行う
- 秘密情報（`.env`・鍵・トークン・パスワード）を読まない・書かない・出力しない
- レビューを頼まれたら、ファイルを変えずに、指摘を「重大度・場所（ファイル:行）・理由・直し方」で挙げる
- ほかの担当の変更は、`git diff custom...agent/codex` のように git で読む（ほかの worktree へ移らない）
- `main` は上流の追従用。上流の追従を頼まれたとき以外は変えない

## 既定の分担

利用者が Claude Code に、分担を指定せずにファイルを変える作業を頼んだときは、Claude Code が取りまとめて次の 4 つで分担する（2026-10-15、利用者の決定）。「共同作業の規則」の「分担は人が決める」で、人が分担を決めていないときの既定にする。利用者がほかのエージェントに直接頼んだときは、この節は使わず「共同作業の規則」に従う。

- Claude Code だけで行うもの: 利用者の質問への答え、ファイルを変えない調べもの、1 つのファイルの数行で振る舞いを変えない直し（誤字・リンク・値の直しなど）
- Claude Code: 計画・実機での確かめ・ほかの 3 つへの依頼・指摘の確かめ・統合・コミットと Pull Request・取り込み
- Codex: 実装と下書き。Claude Code が用意した別の clone か worktree の中だけで書く。この分担で頼まれたときは、「共同作業の規則」のコミット・push・Pull Request・取り込みを行わず、変更を残して報告する（Claude Code が確かめ、自分の worktree に移してからコミットする）
- Grok Build: 差分の読み取り専用のレビュー。ファイルを変えない（Windows 11 では、Claude Code は `--always-approve` を付けずに頼む）
- Antigravity CLI（Windows 11 だけ）: 差分の読み取り専用のレビューと、その作業のための調べもの。ファイルを変えない（Claude Code は、入力を写した使い捨てのフォルダーで 1 回だけ実行し、`--dangerously-skip-permissions`・`--mode` を付けない）
- Claude Code から頼まれたエージェントは、上の自分の役割の範囲で作業する
- レビューの指摘は、実物で確かめてから採る。採らなかった指摘は、理由を付けて報告する
- 使えないエージェント（入っていない・ログインが切れた・AlmaLinux 10 の Antigravity CLI）は飛ばし、そのことを報告する
- 頼み方は、setup-notes（https://github.com/ryo-aoki-pc/setup-notes）の `docs/ai-agents.md` の「コーディングエージェントの共同作業: 既定で分担する」と、`docs/reference/coding-agents.md` の「既定の分担」
