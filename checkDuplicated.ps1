$metadataFileList = dir -r | where name -EQ metadata.json

$list = New-Object System.Collections.ArrayList
foreach ($file in $metadataFileList){
    $tmp = Get-Content -LiteralPath $file | ConvertFrom-Json
    $tmpObject = [PSCustomObject]@{
        authors = $tmp.authors -join ", "
        title = $tmp.title
        fullname = "$($tmp.authors -join ", ") - $($tmp.title)"
        file_info = $file
    }
    $list.Add($tmpObject) | Out-Null
}

($list | group fullname | where Count -gt 1).group | select file_info