[CmdletBinding()]
param (
    $Path = $null,
    $MediaFileType = ('.mp3','.m4b','.m4a')
)

if ($null -eq $Path){$Path = Get-Location}

try {
    $precheckTag = $true
    $dirList = Get-ChildItem $Path -Directory

    if (-not (Test-Path $Path)){
        Write-Host "Directory path is not correct." -ForegroundColor Yellow
        $precheckTag =$false
    }
    foreach ($directory in $dirList){

    #test to see if there is metadata.json in the folder
        if (-not (Test-Path -LiteralPath "$($directory.FullName)/metadata.json")){
            Write-Host "`"$($directory.name)`" missing metadata.json" -ForegroundColor Red
            $precheckTag=$false
        }else{
            Write-Verbose "`"$($directory.name)`" metadata checking passed"
        }
    #test if there is media file in the folder, one and only one media file
        $mediaFile = Get-ChildItem -LiteralPath $directory.FullName | Where-Object Extension -in $MediaFileType
        switch ($mediaFile.count) {
            {$_ -gt 1}{
                Write-Host "`"$($directory.name)`" contain multiple media files" -ForegroundColor Red
                $precheckTag=$false
            }
            {$_ -eq 0}{
                Write-Host "`"$($directory.name)`" contain NO media file" -ForegroundColor Yellow
                $precheckTag=$false
            }
            {$_ -eq 1}{
                Write-Verbose "`"$($directory.name)`" media check passed."
            }
        }
    }

#test for same folder name after update
    Write-Verbose "Detecting duplicated audiobook name."
    $metadatalist = Get-ChildItem -LiteralPath $Path metadata.json -Recurse
    $t = New-Object System.Collections.ArrayList
    foreach ($tmp in $metadatalist){
        $m=Get-Content -LiteralPath $tmp | ConvertFrom-Json
        $tobj = @{
            NewName = "$($m.authors -join ", ") - $($m.title)"
            FolderName = $tmp.Directory | Split-Path -Leaf
        }
        $t.Add($tobj) | Out-Null
    }
    if(($t | Group-Object NewName | Where-Object Count -gt 1).Count -ne 0){
        write-host "Duplicated audiobook folder detected, the folder listed below:" -ForegroundColor Red
        ($t | Group-Object NewName | Where-Object Count -GT 1).Group | ForEach-Object{write-host ("New name `"{0}`", original name `"{1}`"" -f $_.NewName,$_.FolderName)}
        $precheckTag = $false
    }else {
        Write-Verbose "No duplicated audiobook foler detected."
    }
#check pre-check tag, if there is any fail
    if ($precheckTag){
        Write-Host "Audiobook Precheck Passed." -F Green
    }else {
        Write-Host "Audiobook Precheck Failed." -ForegroundColor Red
    }
}
catch {
    Write-host -f red "Encountered Error:"$_.Exception.Message
    Write-Host "Audiobook Precheck Failed."
}
