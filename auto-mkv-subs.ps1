<#
Automatically merges all subtitles into the video files

Requires mkvmerge to be installed! (https://mkvtoolnix.download/)

This script assumes the following file structure:
 root
 ├── anime                Contains all anime episodes
 ├── auto-mkv-subs.ps1    This script
 ├── fonts                The fonts folder, as supplied in the download links
 ├── full                 The full subtitles, as supplied by the ssa-cleanup script
 ├── helper-scripts       Folder containing helper scripts
 │   └── subtitles.psm1   Helper script for fetching the right subtitle files
 ├── output               The output folder (will be automatically generated)
 └── ss                   The signs+songs subtitles, as supplied by the ssa-cleanup script

The episode number of the video will be identified by concatenating ALL NUMBERS in the filename
make sure these are thus equal to the desired episode number (leading zeroes are ignored)
(e.g. "[Anime Time] Steins;Gate 0 - 12" will be evaluated as "012" -> episode 12)
Any episode whose number does not evaluate to something between 1 and 23 will be treated as the OVA

The subtitles will be associated with their video file by evaluating the episode number in the same way
#>

$ErrorActionPreference = "Stop"

$global:MkvMerge = "mkvmerge"

# Font locations
$global:Anton = "./fonts/Anton/Anton-Regular.ttf"
$global:AreYouSerious = "./fonts/Are_You_Serious/AreYouSerious-Regular.ttf"
$global:Audiowide = "./fonts/Audiowide/Audiowide-Regular.ttf"
$global:BadScript = "./fonts/Bad_Script/BadScript-Regular.ttf"
$global:Cinzel = "./fonts/Cinzel/static/Cinzel-Regular.ttf"
$global:ConcertOne = "./fonts/Concert_One/ConcertOne-Regular.ttf"
$global:CourierPrime = "./fonts/Courier_Prime/CourierPrime-Regular.ttf"
$global:DancingScriptSemiBold = "./fonts/Dancing_Script/static/DancingScript-SemiBold.ttf"
$global:DidactGothic = "./fonts/Didact_Gothic/DidactGothic-Regular.ttf"
$global:Farsan = "./fonts/Farsan/Farsan-Regular.ttf"
$global:IMFellEnglish = "./fonts/IM_Fell_English/IMFellEnglish-Regular.ttf"
$global:Jost = "./fonts/Jost/static/Jost-Regular.ttf"
$global:KodeMonoSemiBold = "./fonts/Kode_Mono/static/KodeMono-SemiBold.ttf"
$global:LexendZettaLight = "./fonts/Lexend_Zetta/static/LexendZetta-Light.ttf"
$global:LibreBodoni = "./fonts/Libre_Bodoni/static/LibreBodoni-Regular.ttf"
$global:Lugrasimo = "./fonts/Lugrasimo/Lugrasimo-Regular.ttf"
$global:MPlusRounded1cBlack = "./fonts/M_PLUS_Rounded_1c/MPLUSRounded1c-Black.ttf"
$global:MPlusRounded1cBold = "./fonts/M_PLUS_Rounded_1c/MPLUSRounded1c-Bold.ttf"
$global:MPlusRounded1cExtrabold = "./fonts/M_PLUS_Rounded_1c/MPLUSRounded1c-ExtraBold.ttf"
$global:MPlusRounded1cMedium = "./fonts/M_PLUS_Rounded_1c/MPLUSRounded1c-Medium.ttf"
$global:Manjari = "./fonts/Manjari/Manjari-Regular.ttf"
$global:NanumBrushScript = "./fonts/Nanum_Brush_Script/NanumBrushScript-Regular.ttf"
$global:NixieOne = "./fonts/Nixie_One/NixieOne-Regular.ttf"
$global:NotoSansJP = "./fonts/Noto_Sans_JP/static/NotoSansJP-Regular.ttf"
$global:NotoSansJPLight = "./fonts/Noto_Sans_JP/static/NotoSansJP-Light.ttf"
$global:NotoSansJPMedium = "./fonts/Noto_Sans_JP/static/NotoSansJP-Medium.ttf"
$global:PatrickHand = "./fonts/Patrick_Hand/PatrickHand-Regular.ttf"
$global:PixelifySans = "./fonts/Pixelify_Sans/static/PixelifySans-Regular.ttf"
$global:PlayfairDisplay = "./fonts/Playfair_Display/static/PlayfairDisplay-Regular.ttf"
$global:PlayfairDisplayBlack = "./fonts/Playfair_Display/static/PlayfairDisplay-Black.ttf"
$global:PlayfairDisplayExtrabold = "./fonts/Playfair_Display/static/PlayfairDisplay-ExtraBold.ttf"
$global:PlayfairDisplayMedium = "./fonts/Playfair_Display/static/PlayfairDisplay-Medium.ttf"
$global:PlayfairDisplaySemibold = "./fonts/Playfair_Display/static/PlayfairDisplay-SemiBold.ttf"
$global:PlaypenSans = "./fonts/Playpen_Sans/static/PlaypenSans-Regular.ttf"
$global:PlaypenSansLight = "./fonts/Playpen_Sans/static/PlaypenSans-Light.ttf"
$global:PlaypenSansMedium = "./fonts/Playpen_Sans/static/PlaypenSans-Medium.ttf"
$global:Roboto = "./fonts/Roboto/Roboto-Regular.ttf"
$global:SedgwickAve = "./fonts/Sedgwick_Ave/SedgwickAve-Regular.ttf"
$global:SpecialElite = "./fonts/Special_Elite/SpecialElite-Regular.ttf"

$global:Fonts = @(
    $global:Anton,
    $global:AreYouSerious,
    $global:Audiowide,
    $global:BadScript,
    $global:Cinzel,
    $global:ConcertOne,
    $global:CourierPrime,
    $global:DancingScriptSemiBold,
    $global:DidactGothic,
    $global:Farsan,
    $global:IMFellEnglish,
    $global:Jost,
    $global:KodeMonoSemiBold,
    $global:LexendZettaLight,
    $global:LibreBodoni,
    $global:Lugrasimo,
    $global:MPlusRounded1cBlack,
    $global:MPlusRounded1cBold,
    $global:MPlusRounded1cExtrabold,
    $global:MPlusRounded1cMedium,
    $global:Manjari,
    $global:NanumBrushScript,
    $global:NixieOne,
    $global:NotoSansJP,
    $global:NotoSansJPLight,
    $global:NotoSansJPMedium,
    $global:PatrickHand,
    $global:PixelifySans,
    $global:PlayfairDisplay,
    $global:PlayfairDisplayBlack,
    $global:PlayfairDisplayExtrabold,
    $global:PlayfairDisplayMedium,
    $global:PlayfairDisplaySemibold,
    $global:PlaypenSans,
    $global:PlaypenSansLight,
    $global:PlaypenSansMedium,
    $global:Roboto,
    $global:SedgwickAve,
    $global:SpecialElite
)
[string[]]$global:NotFoundFonts = @()

$global:SetupWarnings = $false


function Get-EpisodeNumber {
    [OutputType([int])]
    param(
        [string]$string
    )

    return [int]($string -replace "[^0-9]", '')
}

function Get-Subtitles {
    [OutputType([string[]])]
    param(
        $folderName,
        $episodeNumber
    )

    [string[]]$episodeSubFiles = @()

    $subFiles = Get-ChildItem -Path ".\$folderName\*.ass"
    foreach ($subFile in $subFiles) {
        $subNumber = Get-EpisodeNumber($subFile.BaseName)
        if (!($subNumber -eq $episodeNumber -or $(($subNumber -isnot [int] -or $subNumber -lt 1 -or $subNumber -gt 23) -and $episodeNumber -eq "OVA"))) { continue }
        
        $episodeSubFiles += Join-Path -Path $folderName -ChildPath $subFile.Name
    }
    
    return $episodeSubFiles
}

function Get-EpisodeFonts {
    [OutputType([string[]])]
    param(
        [string]$episodeNumber
    )

    Switch ($episodeNumber) {
        1 {
            $episodeFonts = @(
                $global:ConcertOne,
                $global:NotoSansJP,
                $global:NotoSansJPMedium,
                $global:PatrickHand,
                $global:PixelifySans,
                $global:PlayfairDisplay,
                $global:PlayfairDisplayMedium,
                $global:PlayfairDisplaySemibold,
                $global:PlaypenSans,
                $global:SpecialElite
            )
        }
        2 {
            $episodeFonts = @(
                $global:LibreBodoni,
                $global:Lugrasimo,
                $global:NotoSansJP,
                $global:NotoSansJPMedium,
                $global:PlayfairDisplay
            )
        }
        3 {
            $episodeFonts = @(
                $global:LibreBodoni,
                $global:Lugrasimo,
                $global:NotoSansJP,
                $global:NotoSansJPMedium,
                $global:PatrickHand,
                $global:PlayfairDisplay,
                $global:PlaypenSans,
                $global:Roboto
            )
        }
        4 {
            $episodeFonts = @(
                $global:LibreBodoni,
                $global:Lugrasimo,
                $global:NotoSansJP,
                $global:NotoSansJPMedium,
                $global:PlayfairDisplay,
                $global:PlayfairDisplayExtrabold,
                $global:Roboto
            )
        }
        5 {
            $episodeFonts = @(
                $global:Anton,
                $global:LibreBodoni,
                $global:Lugrasimo,
                $global:NotoSansJP,
                $global:NotoSansJPMedium,
                $global:PlayfairDisplay,
                $global:PlaypenSans
            )
        }
        6 {
            $episodeFonts = @(
                $global:Jost,
                $global:LibreBodoni,
                $global:Lugrasimo,
                $global:NotoSansJP,
                $global:NotoSansJPMedium,
                $global:PlayfairDisplay,
                $global:SedgwickAve
            )
        }
        7 {
            $episodeFonts = @(
                $global:LibreBodoni,
                $global:Lugrasimo,
                $global:NotoSansJP,
                $global:NotoSansJPMedium,
                $global:PlayfairDisplay,
                $global:PlayfairDisplayMedium,
                $global:PlaypenSans,
                $global:Roboto,
                $global:SedgwickAve
            )
        }
        8 {
            $episodeFonts = @(
                $global:Cinzel,
                $global:DancingScriptSemiBold,
                $global:LibreBodoni,
                $global:Manjari,
                $global:NotoSansJP,
                $global:NotoSansJPMedium,
                $global:PlayfairDisplay,
                $global:PlayfairDisplayExtrabold,
                $global:PlaypenSans,
                $global:PlaypenSansMedium
            )
        }
        9 {
            $episodeFonts = @(
                $global:Anton,
                $global:ConcertOne,
                $global:Farsan,
                $global:LibreBodoni,
                $global:Lugrasimo,
                $global:MPlusRounded1cExtrabold,
                $global:NotoSansJP,
                $global:NotoSansJPMedium,
                $global:PlayfairDisplay,
                $global:PlayfairDisplayMedium,
                $global:PlaypenSans
            )
        }
        10 {
            $episodeFonts = @(
                $global:ConcertOne,
                $global:LibreBodoni,
                $global:Lugrasimo,
                $global:NotoSansJP,
                $global:NotoSansJPMedium,
                $global:PlayfairDisplay,
                $global:PlayfairDisplayMedium,
                $global:PlaypenSans
            )
        }
        11 {
            $episodeFonts = @(
                $global:Anton,
                $global:AreYouSerious,
                $global:LibreBodoni,
                $global:Lugrasimo,
                $global:MPlusRounded1cMedium,
                $global:NotoSansJP,
                $global:NotoSansJPMedium,
                $global:PlayfairDisplay,
                $global:PlayfairDisplayMedium,
                $global:PlaypenSans
            )
        }
        12 {
            $episodeFonts = @(
                $global:Anton,
                $global:Audiowide,
                $global:Jost,
                $global:LibreBodoni,
                $global:MPlusRounded1cBold,
                $global:MPlusRounded1cExtrabold,
                $global:NotoSansJP,
                $global:NotoSansJPLight,
                $global:NotoSansJPMedium,
                $global:PlayfairDisplay,
                $global:SedgwickAve
            )
        }
        13 {
            $episodeFonts = @(
                $global:BadScript,
                $global:ConcertOne,
                $global:LibreBodoni,
                $global:Lugrasimo,
                $global:MPlusRounded1cBlack,
                $global:NanumBrushScript,
                $global:NotoSansJP,
                $global:NotoSansJPMedium,
                $global:PlayfairDisplay,
                $global:PlaypenSans,
                $global:PlaypenSansMedium,
                $global:SedgwickAve
            )
        }
        14 {
            $episodeFonts = @(
                $global:DidactGothic,
                $global:Jost,
                $global:KodeMonoSemiBold,
                $global:LibreBodoni,
                $global:Manjari,
                $global:MPlusRounded1cExtrabold,
                $global:NotoSansJP,
                $global:NotoSansJPMedium,
                $global:PlayfairDisplay,
                $global:PlayfairDisplayMedium,
                $global:PlaypenSans,
                $global:Roboto
            )
        }
        15 {
            $episodeFonts = @(
                $global:Farsan,
                $global:Jost,
                $global:KodeMonoSemiBold,
                $global:LibreBodoni,
                $global:NanumBrushScript,
                $global:NotoSansJP,
                $global:NotoSansJPMedium,
                $global:PlayfairDisplay,
                $global:PlaypenSans
            )
        }
        16 {
            $episodeFonts = @(
                $global:AreYouSerious,
                $global:CourierPrime,
                $global:KodeMonoSemiBold,
                $global:LibreBodoni,
                $global:NotoSansJPMedium,
                $global:PlayfairDisplay,
                $global:PlaypenSans
            )
        }
        17 {
            $episodeFonts = @(
                $global:CourierPrime,
                $global:KodeMonoSemiBold,
                $global:LibreBodoni,
                $global:Manjari,
                $global:NotoSansJP,
                $global:NotoSansJPMedium,
                $global:PatrickHand,
                $global:PlayfairDisplay,
                $global:PlaypenSans
            )
        }
        18 {
            $episodeFonts = @(
                $global:DancingScriptSemiBold,
                $global:LibreBodoni,
                $global:NotoSansJP,
                $global:NotoSansJPMedium,
                $global:PlayfairDisplay,
                $global:PlaypenSans
            )
        }
        19 {
            $episodeFonts = @(
                $global:Jost,
                $global:KodeMonoSemiBold,
                $global:LibreBodoni,
                $global:NotoSansJP,
                $global:NotoSansJPMedium,
                $global:PlayfairDisplay,
                $global:PlaypenSans
            )
        }
        20 {
            $episodeFonts = @(
                $global:KodeMonoSemiBold,
                $global:LibreBodoni,
                $global:NotoSansJPMedium,
                $global:PlayfairDisplay,
                $global:SedgwickAve
            )
        }
        21 {
            $episodeFonts = @(
                $global:LibreBodoni,
                $global:NixieOne,
                $global:NotoSansJPMedium,
                $global:PlayfairDisplay
            )
        }
        22 {
            $episodeFonts = @(
                $global:CourierPrime,
                $global:NotoSansJPMedium,
                $global:PixelifySans,
                $global:PlayfairDisplay,
                $global:PlaypenSans,
                $global:PlaypenSansMedium
            )
        }
        23 {
            $episodeFonts = @(
                $global:IMFellEnglish,
                $global:LexendZettaLight,
                $global:Manjari,
                $global:NotoSansJP,
                $global:NotoSansJPMedium,
                $global:PlayfairDisplay,
                $global:PlaypenSans,
                $global:PlaypenSansMedium
            )
        }
        Default { # OVA
            $episodeFonts = @(
                $global:KodeMonoSemiBold,
                $global:LibreBodoni,
                $global:MPlusRounded1cBlack,
                $global:MPlusRounded1cMedium,
                $global:MPlusRounded1cExtrabold,
                $global:Manjari,
                $global:NotoSansJP,
                $global:NotoSansJPLight,
                $global:NotoSansJPMedium,
                $global:PatrickHand,
                $global:PlayfairDisplay,
                $global:PlayfairDisplayBlack,
                $global:PlaypenSansLight
            )
        }
    }

    return $episodeFonts | Where-Object { $global:NotFoundFonts -NotContains $_ }
}

function Merge-Episode {
    param(
        [System.IO.FIleSystemInfo]$file
    )

    $fileName = $file.BaseName

    $episodeNumber = Get-EpisodeNumber $fileName
    if (($episodeNumber -lt 1) -or (23 -lt $episodeNumber)) {
        $episodeNumber = "OVA"
    }

    $episodeFonts = Get-EpisodeFonts $episodeNumber

    Write-Host -ForegroundColor Blue "`nMerging ""$fileName.mkv"" as episode $episodeNumber..."

    $mkvMergeArguments = @()

    $inputFile = Join-Path -Path "anime" -ChildPath ("$fileName.mkv")
    $outputFile = Join-Path -Path "output" -ChildPath ("$fileName.mkv")
    $addOutput = "-o", $outputFile, "--default-track-flag", "1:0", "--default-track-flag", "2:1", "--default-track-flag", "3:0", $inputFile

    $mkvMergeArguments += $addOutput

    if (Test-Path -Path "./full" -PathType Container) {
        $fullPrefix = "--default-track-flag", "0:1", "--language", "0:en", "--track-name", "0:Full [StyledHorribleFix]"
        $fullSubsPaths = Get-Subtitles -FolderName "full" -EpisodeNumber $episodeNumber
        if ($fullSubsPaths.Count -gt 0) {
            $addFullSubs = @($fullSubsPaths | ForEach-Object {$fullPrefix + $_})
            $mkvMergeArguments += $addFullSubs
        } else {
            Write-Warning "Failed to find a full subtitles file; not adding..."
        }
    }

    if (Test-Path -Path "./ss" -PathType Container) {
        $ssPrefix = "--default-track-flag", "0:0", "--language", "0:en", "--track-name", "0:Signs+Songs [StyledHorribleFix]"
        $ssSubsPaths = Get-Subtitles -FolderName "ss" -EpisodeNumber $episodeNumber
        if ($ssSubsPaths.Count -gt 0) {
            $addSsSubs = @($ssSubsPaths | ForEach-Object {$ssPrefix + $_})
            $mkvMergeArguments += $addSsSubs
        } else {
            Write-Warning "Failed to find a signs+songs subtitles file; not adding..."
        }
    }

    $fontPrefix = "--attachment-mime-type", "application/x-truetype-font", "--attach-file"
    $addFonts = @($episodeFonts | ForEach-Object {$fontPrefix + $_})
    if ($addFonts.Count -gt 0) { $mkvMergeArguments += $addFonts }

    &$global:MkvMerge $mkvMergeArguments
}

function Find-Fonts {
    # If the folder is not found, Find-Folders would've already given a warning
    if (-not (Test-Path -Path "./fonts" -PathType Container)) { return }

    $global:NotFoundFonts = @()

    foreach ($font in $global:Fonts) {
        if (-not (Test-Path -Path $font)) {
            Write-Warning "Could not find font '$font'; not including..."
            $global:NotFoundFonts += $font

            $global:SetupWarnings = $true
        }
    }
}

function Find-Folders {
    $animePath = Join-Path -Path (Get-Location) -ChildPath "anime"
    if (-not (Test-Path -LiteralPath $animePath -PathType Container)) {
        Write-Error "Could not find anime folder ""$animePath"""
    }

    $fullPath = Join-Path -Path (Get-Location) -ChildPath "full"
    if (-not (Test-Path -LiteralPath $fullPath -PathType Container)) {
        Write-Warning "Could not find full subtitles folder ""$fullPath""; not including..."
        $global:SetupWarnings = $true
    }

    $ssPath = Join-Path -Path (Get-Location) -ChildPath "ss"
    if (-not (Test-Path -LiteralPath $ssPath -PathType Container)) {
        Write-Warning "Could not find signs+songs subtitles folder ""$ssPath""; not including..."
        $global:SetupWarnings = $true
    }

    $fontsPath = Join-Path -Path (Get-Location) -ChildPath "fonts"
    if (-not (Test-Path -LiteralPath $fontsPath -PathType Container)) {
        Write-Warning "Could not find fonts folder ""$fontsPath""; not including..."
        $global:NotFoundFonts = $global:Fonts

        $global:SetupWarnings = $true
    }
}

function Find-MkvMerge {
    while ($null -eq (Get-Command -Name $global:MkvMerge)) {
        Write-Error "Could not execute mkvmerge with command ""$global:MkvMerge"""
        $global:MkvMerge = Read-Host "Please enter the path to mkvmerge"
    }
}

function Main {
    Find-Folders
    Find-Fonts
    Find-MkvMerge

    if ($global:SetupWarnings) {
        $continue = Read-Host "Continue? [y/n]"
        while ($continue.ToLower() -NotIn @("y", "n", "yes", "no")) {
            Write-Host -ForegroundColor Red "Please enter either 'y' or 'n'"
            $continue = Read-Host "Continue? [y/n]"
        }

        if ($continue.ToLower() -in @("n", "no")) {
            exit 1
        }
    }

    New-Item -Path ./output -ItemType Directory -Force | Out-Null

    $files = Get-ChildItem -Path ./anime/*.mkv
    foreach ($file in $files) { Merge-Episode $file }
}

Main
