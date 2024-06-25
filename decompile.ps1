<#
Automatically strips all subtitle files from Aegisub compile artifacts
and replaces the auto-generated Aegisub header with a custom one per-episode.

Make sure my ssa-cleanup-tool is installed and is added to Path!
(https://github.com/PringlesGang/ssa-cleanup-tool/releases/tag/v2.0.0)
#>

Remove-Module -Name .\helper-scripts\subtitles -Force -ErrorAction Ignore
Remove-Module -Name .\helper-scripts\headers -Force -ErrorAction Ignore
Import-Module -Name .\helper-scripts\subtitles -Function Get-EpisodeNumber, Get-Subtitles
Import-Module -Name .\helper-scripts\headers -Function Get-Headers

$headers = Get-Headers
$removeAegisubGarbage = ".\ssa-cleanup-processing-files\templates\removeAegisubGarbage.txt"
$decompileBlacklist = ".\ssa-cleanup-processing-files\blacklists\decompile.txt"

$Files = Get-ChildItem -Path .\subs\*.ass
foreach ($File in $Files) {
    $EpisodeNumber = Get-EpisodeNumber $File.Name
    $TempFile = join-Path -Path (Get-Location) -ChildPath "$($File.Name)~TEMP"

    $EpisodeNumberPrint = $EpisodeNumber
    if ($EpisodeNumber -isnot [int] -or $EpisodeNumber -lt 1 -or $EpisodeNumber -gt 23) {
        $EpisodeNumber = 0
        $EpisodeNumberPrint = "OVA"
    }

    Write-Host -ForegroundColor Blue "`nDecompiling ""$($File.Name)"" as episode $EpisodeNumberPrint..."

    ssa-cleanup-tool replace-sections $File.FullName -t $headers[$EpisodeNumber] $removeAegisubGarbage -o $TempFile
    ssa-cleanup-tool parse-regex $TempFile -b $decompileBlacklist -o $File.FullName

    Remove-Item -LiteralPath $TempFile -Force
}

Remove-Module -Name .\helper-scripts\subtitles -Force -ErrorAction Ignore
Remove-Module -Name .\helper-scripts\headers -Force -ErrorAction Ignore
