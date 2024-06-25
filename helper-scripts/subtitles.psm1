function Get-EpisodeNumber {
    param(
        [string]$String
    )

    return [int]($String -replace "[^0-9]", '')
}

function Get-Subtitles {
    param(
        $FolderName,
        $EpisodeNumber
    )

    [string[]]$EpisodeSubFiles

    $SubFiles = Get-ChildItem -Path ".\$FolderName\*.ass"
    foreach ($SubFile in $SubFiles) {
        $SubNumber = Get-EpisodeNumber($SubFile.BaseName)
        if (!($SubNumber -eq $EpisodeNumber -or $(($SubNumber -isnot [int] -or $SubNumber -lt 1 -or $SubNumber -gt 23) -and $EpisodeNumber -eq "OVA"))) {continue}
        
        $EpisodeSubFiles += Join-Path -Path $FolderName -ChildPath $SubFile.Name
    }
    
    return $EpisodeSubFiles
}
