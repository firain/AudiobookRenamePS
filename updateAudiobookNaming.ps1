[CmdletBinding()]
param (
    $Path = $null,
    $MediaFileType = ('.mp3','.m4b','.m4a'),
    $AuthorLimit=3,
    [switch]$Dryrun,
    #exclude a list of item in authors by default
    $AuthorExcludePattern=("- illustrator","- translator","- editor","- foreword","- introductions","- director","- commentary","- contributor")
    #$AudioFileTemplate
)
#replacing invalide filename chars for windows system. linux system is / only
$invalidNameingChar = @('\','/',':','*','?','"','<','>','|')
#making regex for checking
$reg = "[{0}]" -f [regEx]::Escape($invalidNameingChar -join '')
$ap = "({0})" -f ($AuthorExcludePattern -join ")|(")
#$path = '/home/li/docker/audiobookshelf/media/tmp/tmp'
if ($null -eq $Path){$Path = Get-Location}

try {
    $dirList = Get-ChildItem $Path -Directory
    foreach ($directory in $dirList){
        $mediaFile = Get-ChildItem -LiteralPath $directory.FullName | Where-Object Extension -in $MediaFileType
        $metadata = Get-Content -LiteralPath "$($directory.FullName)/metadata.json" | ConvertFrom-Json
        #Write-Verbose "$mediaFile rename to $($metadata.title)"
        
        $title = $metadata.title -replace $reg,""
        #$author = $metadata.authors | ?{$_ -notmatch $ap}
        #need to use @() around the output to force it to be an array
        $author = (@($metadata.authors | ?{$_ -notmatch $ap})[0..$AuthorLimit] -join ", ") -replace $reg,""
        #$author = (@($metadata.authors | sort | ?{$_ -notmatch $ap})[0..$AuthorLimit] -join ", ") -replace $reg,""

        if ($mediaFile.name.Replace($mediaFile.Extension,"") -eq $title){
            Write-host "Matching file name, no need to update"
        }else{
            Write-Verbose ("File: {0} change to {1}" -f $mediaFile.name,"$title$($mediaFile.Extension)")
            Rename-Item $mediaFile -NewName "$title$($mediaFile.Extension)" -WhatIf:$Dryrun | Out-Null
        }
        #Write-Verbose "Driectory rename to $($metadata.author -join ", ") - $($metadata.title)"
        if ($directory.name -eq "$author - $title"){
            Write-host "Matching directory name, no need to update"
        }else{
            Write-Verbose ("Directory: {0} change to {1}" -f $directory.Name,"$author - $title")
            Rename-Item $directory -NewName "$author - $title" -WhatIf:$Dryrun | Out-Null
        }
    }
}
catch {
    Write-host -f red "Encountered Error:"$_.Exception.Message
}
