# AGENTS.md

このリポジトリで作業するコーディングエージェント（Claude Code・Codex・Grok Build・Antigravity CLI）への指示。Claude Code は CLAUDE.md の `@AGENTS.md` で、Codex・Grok Build・Antigravity CLI はこのファイルを直接読む。

## 導入手順の正本

導入・更新・使い方の手順は、setup-notes の [almalinux-setup.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/almalinux-setup.md#lazygit) と [windows-setup.md](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/windows-setup.md#lazygit) の「lazygit」とその子の項（設定の導入）にある。このリポジトリには置かない。

## このリポジトリは何か

[lazygit](https://github.com/jesseduffield/lazygit) の自分用の設定（`config.yml`）。導入の表と、このリポジトリの運用は [README.md](README.md)、設定の中身は [docs/reference/readme.md](docs/reference/readme.md)、検証記録は [非公開側の readme.md](https://github.com/ryo-aoki-pc/setup-notes-verification/blob/main/repos/lazygit/docs/verification/readme.md)。

`E` のキーは、Excel と Word のどちらでも、[excel-diff](https://github.com/ryo-aoki-pc/excel-diff) が登録する `git excel-stage` を呼ぶ。

ドキュメント・コミットメッセージ・Pull Request の説明は日本語で書く。

### ブランチ構成

`custom` が実際に使う設定（既定のブランチ。作業はここから始める）、`main` が lazygit 公式の既定の設定を置いた上流の追従用（直接編集しない）。`config.yml` の書き換え方と上流への追従は、README の「このリポジトリの運用」に従う。

Pull Request の向き先は `custom`。`main` は上流の追従用で、上流の追従を頼まれたとき以外は変えない。

## 構成

- `config.yml` — lazygit の設定。lazygit の設定ディレクトリに置くかリンクを張って使う（Windows は `%LOCALAPPDATA%\lazygit` に直接 clone する）
- `scripts/fetch-upstream-config.sh` — 上流の既定の設定を取り出す（`main` の更新用）
- `.gitignore` — Windows の lazygit が同じフォルダーに作る状態ファイル（`state.yml` など）を除く
- `docs/reference/readme.md` — 設定の中身と理由。非公開側の検証記録は `readme.md`。`docs/images/` — README の画像

## テスト

このリポジトリに自動テストは無い。Excel・Word の道具のテストは [excel-diff](https://github.com/ryo-aoki-pc/excel-diff) にある。

## 文書の置き場所

- 導入・利用・更新の手順は正本に置き、README の「導入」の表から正本の項へ直接リンクする（手順書の先頭やカテゴリの見出しへはリンクしない）。執筆規則は setup-notes の `docs/dev/writing-rules.md`
- `docs/extra/` は注意点。ロールバック（取り消し）の手順は書かない。`docs/reference/` は設定の中身と理由。検証記録（実施日・環境・結果・未確認事項）は非公開の `ryo-aoki-pc/setup-notes-verification` の `repos/lazygit/docs/verification/` に置く
- 文書を移す・分ける・まとめるときは、移した経緯と、旧ファイル名・旧見出しとの対応を文書に書かない（経緯は git の履歴と Pull Request の本文に残す）。リンクを今の場所へ直す。中身が新しい場所への案内だけになったファイルは消す
- 検証記録を書く・直すときは、`setup-notes-verification` を clone し、そちらへ Pull Request を作る
- 検証していないことを「動く」と書かない
- 残す検証記録の実施日・対象版・環境・出力・成功と失敗・未実施の範囲・記録したときの手順番号は書き換えない。再検証せずに検証範囲を広げない。記録の手順番号が今の手順と違い、本文を読むのに要るときだけ「記録の手順 | 今の手順」の表で結ぶ
