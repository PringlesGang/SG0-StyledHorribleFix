<#
Automatically builds all subtitle files into full-release and signsSongs-release versions.
It strips all comments from the subtitles, removes dialogue in the case of signsSongs,
and replaces the auto-generated Aegisub header with a custom one per-episode.

This script does NOT compile the Aegisub karaoke effects; this will need to be done manually.

Make sure my ssa-cleanup-tool is installed and is added to Path!
(https://github.com/PringlesGang/ssa-cleanup-tool/releases/tag/v2.0.0)
#>

Remove-Module -Name .\helper-scripts\subtitles -Force -ErrorAction Ignore
Remove-Module -Name .\helper-scripts\headers -Force -ErrorAction Ignore
Import-Module -Name .\helper-scripts\subtitles -Function Get-EpisodeNumber, Get-Subtitles
Import-Module -Name .\helper-scripts\headers -Function Get-Headers

$headers = Get-Headers
$removeAegisubGarbage = ".\ssa-cleanup-processing-files\templates\removeAegisubGarbage.txt"
$releaseBlacklist = ".\ssa-cleanup-processing-files\blacklists\release.txt"
$signsSongsBlacklist = ".\ssa-cleanup-processing-files\blacklists\signsSongs.txt"

$fullPath = join-Path -Path (Get-Location) -ChildPath "full"
$ssPath = Join-Path -Path (Get-Location) -ChildPath "ss"

New-Item -Path .\full -ItemType Directory -Force
New-Item -Path .\ss -ItemType Directory -Force
$Files = Get-ChildItem -Path .\subs\*.ass
foreach ($File in $Files) {
    $FileName = $File.Name
    $EpisodeNumber = Get-EpisodeNumber $FileName
    $TempFile = join-Path -Path (Get-Location) -ChildPath "$FileName~TEMP"

    $EpisodeNumberPrint = $EpisodeNumber
    if ($EpisodeNumber -isnot [int] -or $EpisodeNumber -lt 1 -or $EpisodeNumber -gt 23) {
        $EpisodeNumber = 0
        $EpisodeNumberPrint = "OVA"
    }

    Write-Host -ForegroundColor Blue "`nBuilding ""$FileName"" as episode $EpisodeNumberPrint..."

    ssa-cleanup-tool replace-sections $File.FullName -t $headers[$EpisodeNumber] $removeAegisubGarbage -o $TempFile
    ssa-cleanup-tool parse-regex $TempFile -b $releaseBlacklist -o (join-Path -Path $fullPath -ChildPath $FileName)
    ssa-cleanup-tool parse-regex $TempFile -b $releaseBlacklist $signsSongsBlacklist -o (join-Path -Path $ssPath -ChildPath $FileName)

    Remove-Item -LiteralPath $TempFile -Force
}

Remove-Module -Name .\helper-scripts\subtitles -Force -ErrorAction Ignore
Remove-Module -Name .\helper-scripts\headers -Force -ErrorAction Ignore
