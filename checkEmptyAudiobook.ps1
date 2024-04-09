#check empty audiobook folder
Get-ChildItem | %{if((Get-ChildItem -LiteralPath $_.FullName | where extension -in .mp3,.m4b,.m4a,.mp4).count -eq 0){$_.fullname}}

#check for empty files
Get-ChildItem -Recurse | where{$_.Length -eq 0} | Select @{N='EmptyFiles';E={$_.FullName}} | Format-Table -AutoSize
