# lazygit の設定のロールバック

[手順書（Windows 11）](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/windows-setup.md#lazygit-の設定を導入する)・[検証記録](https://github.com/ryo-aoki-pc/setup-notes-verification/blob/main/repos/lazygit/docs/verification/readme.md)・[参考資料](../reference/readme.md)

- 「この節の手順 N」はこの文書の手順を指す
- AlmaLinux 10 の設定は、setup-notes の[Git の道具を消す](https://github.com/ryo-aoki-pc/setup-notes/blob/main/docs/extra/almalinux-setup.md#git-の道具を消す)の手順 1 の箇条書きで消す（`~/lazygit-config` の clone とリンク）

## Windows 11 のロールバック

Windows 11 の自分のユーザーの Windows PowerShell で行う。lazygit を終了し、手順 1 で未コミット・未 push の変更が無いことを確かめてから削除へ進む。退避した設定は `%LOCALAPPDATA%\lazygit.bak` にある。

1. lazygit を終了し、未コミット・未 push の変更がないか確かめる。

   ```powershell
   $d = "$env:LOCALAPPDATA\lazygit"
   git -C $d status --short
   git -C $d log --oneline '@{u}..'
   ```

   - 何も出ないことを確かめ、必要な変更は別の場所へ退避してから次へ進む

1. clone を消して退避した設定を戻す（取り戻せない）。

   ```powershell
   $d = "$env:LOCALAPPDATA\lazygit"
   Remove-Item -LiteralPath $d -Recurse -Force
   if (Test-Path -LiteralPath "$d.bak") { Move-Item -LiteralPath "$d.bak" -Destination $d }
   ```
