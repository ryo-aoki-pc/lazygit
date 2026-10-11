# lazygit の設定を戻す

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
