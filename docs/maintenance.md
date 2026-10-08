# lazygit 設定の保守

[文書一覧](README.md) / [設定内容](reference/readme.md) / [検証記録](verification/readme.md)

## ブランチ構成

| ブランチ | 内容 |
| --- | --- |
| `custom`(デフォルト) | このブランチ。`main` の上に自分用のカスタマイズを積んだもの |
| `main` | lazygit 公式のデフォルト設定([docs/Config.md](https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md) の Default セクション)をそのまま置いた upstream 追従ブランチ。直接編集しない |

## このリポジトリの運用

`main` は upstream 追従用です。直接編集しないでください。

- 設定の変更は `custom` からトピックブランチを切って Pull Request で取り込みます。
- 公式デフォルトからのカスタマイズ差分は `git diff main custom -- config.yml`(コミット単位なら `git log --oneline main..custom`)で確認できます。
- `custom` の `config.yml` は `main` の全項目形式を保ち、変えたい値だけを書き換えます(項目の削除・並べ替え・独自ヘッダの追加はしない)。版の互換性に必要なキーの改名・移動は[検証記録](verification/readme.md)に残します。変更した値の直上に日本語コメントを 1 行付けます。
- upstream(lazygit の新バージョン)への追従は、`main` で [`scripts/fetch-upstream-config.sh`](../scripts/fetch-upstream-config.sh) を実行してコミットし、
  `custom` を `git rebase main` で載せ直します(手順の詳細は [`main` ブランチの README](https://github.com/ryo-aoki-pc/lazygit/blob/main/README.md) を参照)。
