<#
Automatically builds all subtitle files into full-release and signsSongs-release versions.
It applies the karaoke templates, strips all comments from the subtitles, removes dialogue in the case of signsSongs,
and replaces the auto-generated Aegisub header with a custom one per-episode.
#>

$ErrorActionPreference = "Stop"

Remove-Module -Name subtitles -Force -ErrorAction Ignore
Remove-Module -Name headers -Force -ErrorAction Ignore
Import-Module -Name .\helper-scripts\subtitles -Function Get-EpisodeNumber, Get-Subtitles -ErrorAction Stop
Import-Module -Name .\helper-scripts\headers -Function Get-Headers -ErrorAction Stop

$global:Headers = Get-Headers
$global:RemoveAegisubGarbage = ".\ssa-cleanup-processing-files\templates\removeAegisubGarbage.txt"
$global:ReleaseBlacklist = ".\ssa-cleanup-processing-files\blacklists\release.txt"
$global:SignsSongsBlacklist = ".\ssa-cleanup-processing-files\blacklists\signsSongs.txt"

# Episodes that should not have a karaoke template applied
$global:NoTemplateEpisodes = @("23")

$global:FullPath = join-Path -Path (Get-Location) -ChildPath "full"
$global:SsPath = Join-Path -Path (Get-Location) -ChildPath "ss"

class Config {
    [ValidateNotNullOrEmpty()][string]$AegisubCli
    [ValidateNotNullOrEmpty()][string]$Python
    [ValidateNotNullOrEmpty()][string]$SsaCleanupTool

    Config([PSCustomObject]$jsonObject) {
        $this.AegisubCli = $jsonObject.aegisub_cli
        $this.Python = $jsonObject.python
        $this.SsaCleanupTool = $jsonObject.ssa_cleanup_tool
    }

    [void] Validate() {
        if ($null -eq (Get-Command -Name $this.AegisubCli -ErrorAction SilentlyContinue)) {
            Write-Error "Could not execute aegisub-cli with given command ""$($this.AegisubCli)""`nPlease update builder_config.json"
        }

        if ($null -eq (Get-Command -Name $this.Python -ErrorAction SilentlyContinue)) {
            Write-Error "Could not execute Python with given command ""$($this.Python)""`nPlease update builder_config.json"
        }

        if (-not (Test-Path $this.SsaCleanupTool -PathType Leaf)) {
            Write-Error "Could not find ssa_cleanup_tool at given path ""$($this.SsaCleanupTool)""`nPlease update builder_config.json"
        }
    }
}

function Get-Config {
    [OutputType([Config])]
    param()

    $path = ".\builder_config.json"

    if (-not (Test-Path $path -PathType Leaf)) {
        Write-Error "Please specify your settings in '$path'"
    }

    [Config]$result = Get-Content $path | ConvertFrom-Json
    $result.Validate()

    return $result
}

function ConvertTo-BuiltSubtitles {
    param(
        [System.IO.FileSystemInfo]$file,
        [Config]$config
    )

    $fileName = $file.Name
    $episodeNumber = Get-EpisodeNumber $fileName

    $episodeNumberPrint = $episodeNumber
    if ($episodeNumber -isnot [int] -or $episodeNumber -lt 1 -or $episodeNumber -gt 23) {
        $episodeNumber = 0
        $episodeNumberPrint = "OVA"
    }

    Write-Host -ForegroundColor Blue "`nBuilding ""$fileName"" as episode $episodeNumberPrint..."

    $templatedFile = Join-Path -Path (Get-Location) -ChildPath "$($file.BaseName)~TEMP.ass"
    if ($episodeNumber -NotIn $global:NoTemplateEpisodes) {
        Write-Host -ForegroundColor Cyan "Applying karaoke template..."
        & $config.AegisubCli --automation kara-templater.lua $file.Fullname $templatedFile 'Apply karaoke template'
        if (-not (Test-Path -LiteralPath $templatedFile)) {
            Write-Error "Failed to apply karaoke template" -ErrorAction Continue
            Return
        }
    } else {
        Copy-Item -LiteralPath $file.Fullname -Destination $templatedFile
    }

    Write-Host -ForegroundColor Cyan "Replacing header..."
    $replacedFile = Join-Path -Path (Get-Location) -ChildPath "$($file.BaseName)~REPL.ass"
    & $config.Python $config.SsaCleanupTool replace-sections $templatedFile -t $global:Headers[$episodeNumber] $global:RemoveAegisubGarbage -o $replacedFile
    Remove-Item -LiteralPath $templatedFile -Force
    if (-not (Test-Path -LiteralPath $replacedFile)) {
        Write-Error "Failed to replace sections in subtitle file" -ErrorAction Continue
        Return
    }

    Write-Host -ForegroundColor Cyan "Building full subtitles..."
    $fullSubPath = Join-Path -Path $global:FullPath -ChildPath $fileName
    & $config.Python $config.SsaCleanupTool parse-regex $replacedFile -b $global:ReleaseBlacklist -o $fullSubPath
    if (-not (Test-Path -LiteralPath $fullSubPath)) {
        Write-Error "Failed to sanitize full subtitles" -ErrorAction Continue

        Remove-Item -LiteralPath $replacedFile -Force
        Return
    }

    Write-Host -ForegroundColor Cyan "Building signs+songs subtitles..."
    $ssSubPath = Join-Path -Path $global:SsPath -ChildPath $fileName
    & $config.Python $config.SsaCleanupTool parse-regex $replacedFile -b $global:ReleaseBlacklist $global:SignsSongsBlacklist -o $ssSubPath
    if (-not (Test-Path -LiteralPath $ssSubPath)) {
        Write-Error "Failed to sanitize signs+songs subtitles" -ErrorAction Continue

        Remove-Item -LiteralPath $replacedFile -Force
        Return
    }

    Remove-Item -LiteralPath $replacedFile -Force
}

function Main {
    $config = Get-Config

    New-Item -Path .\full -ItemType Directory -Force | Out-Null
    New-Item -Path .\ss -ItemType Directory -Force | Out-Null

    $files = Get-ChildItem -Path .\subs\*.ass
    foreach ($file in $files) { ConvertTo-BuiltSubtitles -File $file -Config $config}

    Remove-Module -Name subtitles -Force -ErrorAction Continue
    Remove-Module -Name headers -Force -ErrorAction Continue

    Write-Host -ForegroundColor Blue "`nDone!"
}

Main
