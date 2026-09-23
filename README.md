# lazygit 設定ファイル(upstream ブランチ)

このブランチ(`main`)は [lazygit](https://github.com/jesseduffield/lazygit) 公式ドキュメント
[docs/Config.md](https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md) の「Default」セクションにある
**デフォルト設定をそのまま**置いたものです。自分用のカスタマイズは `custom` ブランチにあります。

| ブランチ | 内容 |
| --- | --- |
| `main` | upstream(lazygit 公式)のデフォルト設定。直接編集しない |
| `custom` | `main` の上に自分用のカスタマイズを積んだブランチ(デフォルトブランチ) |

- 取得元タグ: **v0.65.1**
- `config.yml` は [`scripts/fetch-upstream-config.sh`](./scripts/fetch-upstream-config.sh) の出力そのものです(手で編集しない)

## カスタマイズ内容の差分を見る

```sh
git diff main custom -- config.yml
git log --oneline main..custom
```

## upstream の更新を取り込む

```sh
git switch main
scripts/fetch-upstream-config.sh v0.66.0     # 新しいタグを指定
# README.md の「取得元タグ」も更新する
git commit -am "lazygit v0.66.0 のデフォルト設定に更新"
git switch custom
git rebase main                                # 衝突があれば custom 側の意図に合わせて解消
```
