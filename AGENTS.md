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
- 文書を移す・分ける・まとめるときは、移した経緯と、旧ファイル名・旧見出しとの対応を文書に書かない（経緯は git の履歴と Pull Request の本文に残す）。リンクを今の場所へ直す。中身が新しい場所への案内だけになったファイルは消す
- 検証していないことを「動く」と書かない
- 残す検証記録の実施日・対象版・環境・出力・成功と失敗・未実施の範囲・記録したときの手順番号は書き換えない。再検証せずに検証範囲を広げない。記録の手順番号が今の手順と違い、本文を読むのに要るときだけ「記録の手順 | 今の手順」の表で結ぶ

## 共同作業の規則

このリポジトリでは、Claude Code・Codex・Grok Build・Antigravity CLI が同じ規則で作業する。分担は人が決める。

- 起動された worktree（作業ディレクトリ）の中だけでファイルを変える。ほかの worktree のファイルは変えない
- 今のブランチにだけコミットする。`custom` にはコミットも push もしない
- 頼まれた範囲のファイルだけを変える。範囲の外を変えるときは、変える前に理由を書いて確かめる
- 終わったら、テストとリンターを通してから、目的ごとにコミットする。通らなければコミットせずに、結果を報告する
- コミットしたら、今のブランチを push し、`custom` への Pull Request を作る（既にあれば足す）。今のブランチに `custom` を取り込むのは、頼まれたときと、Pull Request が競合したときだけ
- `custom` への取り込み（マージ）は、エージェントが行ってよい。テストとリンターが通り、Pull Request が競合していなければ、`gh pr merge --squash` で Pull Request を取り込む（手元の `custom` にはコミットも push もしない）。利用者が取り込まないよう頼んだときは取り込まず、そのことを報告する。取り込んだ Pull Request のブランチは、GitHub がリモートから自動で消す（リポジトリの Automatically delete head branches は人が有効にしておき、エージェントは変えない）。取り込んだブランチには、その後コミットも push もせず、次の作業は新しいブランチで始める。手元に残ったブランチの削除は人が行う
- 秘密情報（`.env`・鍵・トークン・パスワード）を読まない・書かない・出力しない
- レビューを頼まれたら、ファイルを変えずに、指摘を「重大度・場所（ファイル:行）・理由・直し方」で挙げる
- ほかの担当の変更は、`git diff custom...agent/codex` のように git で読む（ほかの worktree へ移らない）
- `main` は上流の追従用。上流の追従を頼まれたとき以外は変えない

## 既定の分担

利用者が Claude Code に、分担を指定せずにファイルを変える作業を頼んだときは、Claude Code が取りまとめて次の 4 つで分担する。「共同作業の規則」の「分担は人が決める」で、人が分担を決めていないときの既定にする。利用者がほかのエージェントに直接頼んだときは、この節は使わず「共同作業の規則」に従う。

- Claude Code だけで行うもの: 利用者の質問への答え、ファイルを変えない調べもの、1 つのファイルの数行で振る舞いを変えない直し（誤字・リンク・値の直しなど）
- Claude Code: 計画・実機での確かめ・ほかの 3 つへの依頼・指摘の確かめ・統合・コミットと Pull Request・取り込み
- Codex: 実装と下書き。Claude Code が用意した別の clone か worktree の中だけで書く。この分担で頼まれたときは、「共同作業の規則」のコミット・push・Pull Request・取り込みを行わず、変更を残して報告する（Claude Code が確かめ、自分の worktree に移してからコミットする）
- Grok Build: 差分の読み取り専用のレビュー。ファイルを変えない（Windows 11 では、Claude Code は `--always-approve` を付けずに頼む）
- Antigravity CLI（Windows 11 だけ）: 差分の読み取り専用のレビューと、その作業のための調べもの。ファイルを変えない（Claude Code は、入力を写した使い捨てのフォルダーで 1 回だけ実行し、`--dangerously-skip-permissions`・`--mode` を付けない）
- Claude Code から頼まれたエージェントは、上の自分の役割の範囲で作業する
- レビューの指摘は、実物で確かめてから採る。採らなかった指摘は、理由を付けて報告する
- 使えないエージェント（入っていない・ログインが切れた・AlmaLinux 10 の Antigravity CLI）は飛ばし、そのことを報告する
- 頼み方は、[setup-notes](https://github.com/ryo-aoki-pc/setup-notes) の `docs/ai-agents.md` の「コーディングエージェントの共同作業: 既定で分担する」と、`docs/reference/coding-agents.md` の「既定の分担」
