<#
Automatically merges all subtitles into the video files

Make sure mkvmerge is installed! (https://mkvtoolnix.download/)

This script assumes the following file structure:
 root
 ├── anime                Contains all anime episodes
 ├── auto-mkv-subs.ps1    This script
 ├── fonts                The fonts folder, as supplied in the download links
 ├── full                 The full subtitles, as supplied by the ssa-cleanup script
 ├── output               The output folder (will be automatically generated)
 └── ss                   The signs+songs subtitles, as supplied by the ssa-cleanup script

The episode number of the video will be identified by concatonating ALL NUMBERS in the filename
make sure these are thus equal to the desired episode number (leading zeroes are ignored)
(e.g. "[Anime Time] Steins;Gate 0 - 12" will be evaluated as "012" -> episode 12)
Any episode whose number does not evaluate to something between 1 and 23 will be treated as the OVA

The subtitles will be associated with their video file by evaluating the episode number in the same way
#>

$Anton = ".\fonts\Anton\Anton-Regular.ttf"
$AreYouSerious = ".\fonts\Are_You_Serious\AreYouSerious-Regular.ttf"
$Audiowide = ".\fonts\Audiowide\Audiowide-Regular.ttf"
$BadScript = ".\fonts\Bad_Script\BadScript-Regular.ttf"
$Cinzel = ".\fonts\Cinzel\static\Cinzel-Regular.ttf"
$ConcertOne = ".\fonts\Concert_One\ConcertOne-Regular.ttf"
$CourierPrime = ".\fonts\Courier_Prime\CourierPrime-Regular.ttf"
$DancingScriptSemiBold = ".\fonts\Dancing_Script\static\DancingScript-SemiBold.ttf"
$DidactGothic = ".\fonts\Didact_Gothic\DidactGothic-Regular.ttf"
$Farsan = ".\fonts\Farsan\Farsan-Regular.ttf"
$IMFellEnglish = ".\fonts\IM_Fell_English\IMFellEnglish-Regular.ttf"
$Jost = ".\fonts\Jost\static\Jost-Regular.ttf"
$KodeMonoSemiBold = ".\fonts\Kode_Mono\static\KodeMono-SemiBold.ttf"
$LexendZettaLight = ".\fonts\Lexend_Zetta\static\LexendZetta-Light.ttf"
$LibreBodoni = ".\fonts\Libre_Bodoni\static\LibreBodoni-Regular.ttf"
$Lugrasimo = ".\fonts\Lugrasimo\Lugrasimo-Regular.ttf"
$MPlusRounded1cBlack = ".\fonts\M_PLUS_Rounded_1c\MPLUSRounded1c-Black.ttf"
$MPlusRounded1cBold = ".\fonts\M_PLUS_Rounded_1c\MPLUSRounded1c-Bold.ttf"
$MPlusRounded1cExtrabold = ".\fonts\M_PLUS_Rounded_1c\MPLUSRounded1c-ExtraBold.ttf"
$MPlusRounded1cMedium = ".\fonts\M_PLUS_Rounded_1c\MPLUSRounded1c-Medium.ttf"
$Manjari = ".\fonts\Manjari\Manjari-Regular.ttf"
$NanumBrushScript = ".\fonts\Nanum_Brush_Script\NanumBrushScript-Regular.ttf"
$NixieOne = ".\fonts\Nixie_One\NixieOne-Regular.ttf"
$NotoSansJP = ".\fonts\Noto_Sans_JP\static\NotoSansJP-Regular.ttf"
$NotoSansJPLight = ".\fonts\Noto_Sans_JP\static\NotoSansJP-Light.ttf"
$NotoSansJPMedium = ".\fonts\Noto_Sans_JP\static\NotoSansJP-Medium.ttf"
$PatrickHand = ".\fonts\Patrick_Hand\PatrickHand-Regular.ttf"
$PixelifySans = ".\fonts\Pixelify_Sans\static\PixelifySans-Regular.ttf"
$PlayfairDisplay = ".\fonts\Playfair_Display\static\PlayfairDisplay-Regular.ttf"
$PlayfairDisplayBlack = ".\fonts\Playfair_Display\static\PlayfairDisplay-Black.ttf"
$PlayfairDisplayExtrabold = ".\fonts\Playfair_Display\static\PlayfairDisplay-ExtraBold.ttf"
$PlayfairDisplayMedium = ".\fonts\Playfair_Display\static\PlayfairDisplay-Medium.ttf"
$PlayfairDisplaySemibold = ".\fonts\Playfair_Display\static\PlayfairDisplay-SemiBold.ttf"
$PlaypenSans = ".\fonts\Playpen_Sans\static\PlaypenSans-Regular.ttf"
$PlaypenSansLight = ".\fonts\Playpen_Sans\static\PlaypenSans-Light.ttf"
$PlaypenSansMedium = ".\fonts\Playpen_Sans\static\PlaypenSans-Medium.ttf"
$Roboto = ".\fonts\Roboto\Roboto-Regular.ttf"
$SedgwickAve = ".\fonts\Sedgwick_Ave\SedgwickAve-Regular.ttf"
$SpecialElite = ".\fonts\Special_Elite\SpecialElite-Regular.ttf"

function Get-Episode-Number($String) {
    return [int]($String -replace "[^0-9]", '')
}

function Get-Subtitles($FolderName) {
    [string[]]$EpisodeSubFiles

    $SubFiles = Get-ChildItem -Path ".\$FolderName\*.ass"
    foreach ($SubFile in $SubFiles) {
        $SubNumber = Get-Episode-Number($SubFile.BaseName)
        if (!($SubNumber -eq $EpisodeNumber -or $($SubNumber -isnot [int] -and $EpisodeNumber -eq "OVA"))) {continue}
        
        $EpisodeSubFiles += Join-Path -Path $FolderName -ChildPath $SubFile.Name
    }
    
    return $EpisodeSubFiles
}


New-Item -Path .\output -ItemType Directory -Force
$Files = Get-ChildItem -Path .\anime\*.mkv
foreach ($File in $Files) {
    $FileName = $File.BaseName
    $EpisodeNumber = Get-Episode-Number($FileName)

    Switch ($EpisodeNumber) {
        1 {
            $Fonts =
                $ConcertOne,
                $NotoSansJP,
                $NotoSansJPMedium,
                $PatrickHand,
                $PixelifySans,
                $PlayfairDisplay,
                $PlayfairDisplayMedium,
                $PlayfairDisplaySemibold,
                $PlaypenSans,
                $SpecialElite
        }
        2 {
            $Fonts =
                $LibreBodoni,
                $Lugrasimo,
                $NotoSansJP,
                $NotoSansJPMedium,
                $PlayfairDisplay
        }
        3 {
            $Fonts =
                $LibreBodoni,
                $Lugrasimo,
                $NotoSansJP,
                $NotoSansJPMedium,
                $PatrickHand,
                $PlayfairDisplay,
                $PlaypenSans,
                $Roboto
        }
        4 {
            $Fonts =
                $LibreBodoni,
                $Lugrasimo,
                $NotoSansJP,
                $NotoSansJPMedium,
                $PlayfairDisplay,
                $PlayfairDisplayExtrabold,
                $Roboto
        }
        5 {
            $Fonts =
                $Anton,
                $LibreBodoni,
                $Lugrasimo,
                $NotoSansJP,
                $NotoSansJPMedium,
                $PlayfairDisplay,
                $PlaypenSans
        }
        6 {
            $Fonts =
                $Jost,
                $LibreBodoni,
                $Lugrasimo,
                $NotoSansJP,
                $NotoSansJPMedium,
                $PlayfairDisplay,
                $SedgwickAve
        }
        7 {
            $Fonts =
                $LibreBodoni,
                $Lugrasimo,
                $NotoSansJP,
                $NotoSansJPMedium,
                $PlayfairDisplay,
                $PlayfairDisplayMedium,
                $PlaypenSans,
                $Roboto,
                $SedgwickAve
        }
        8 {
            $Fonts =
                $Cinzel,
                $DancingScriptSemiBold,
                $LibreBodoni,
                $Manjari,
                $NotoSansJP,
                $NotoSansJPMedium,
                $PlayfairDisplay,
                $PlayfairDisplayExtrabold,
                $PlaypenSans,
                $PlaypenSansMedium
        }
        9 {
            $Fonts =
                $Anton,
                $ConcertOne,
                $Farsan,
                $LibreBodoni,
                $Lugrasimo,
                $MPlusRounded1cExtrabold,
                $NotoSansJP,
                $NotoSansJPMedium,
                $PlayfairDisplay,
                $PlayfairDisplayMedium,
                $PlaypenSans
        }
        10 {
            $Fonts =
                $ConcertOne,
                $LibreBodoni,
                $Lugrasimo,
                $NotoSansJP,
                $NotoSansJPMedium,
                $PlayfairDisplay,
                $PlayfairDisplayMedium,
                $PlaypenSans
        }
        11 {
            $Fonts =
                $Anton,
                $AreYouSerious,
                $LibreBodoni,
                $Lugrasimo,
                $MPlusRounded1cMedium,
                $NotoSansJP,
                $NotoSansJPMedium,
                $PlayfairDisplay,
                $PlayfairDisplayMedium,
                $PlaypenSans
        }
        12 {
            $Fonts =
                $Anton,
                $Audiowide,
                $Jost,
                $LibreBodoni,
                $MPlusRounded1cBold,
                $MPlusRounded1cExtrabold,
                $NotoSansJP,
                $NotoSansJPLight,
                $NotoSansJPMedium,
                $PlayfairDisplay,
                $SedgwickAve
        }
        13 {
            $Fonts =
                $BadScript,
                $ConcertOne,
                $LibreBodoni,
                $Lugrasimo,
                $MPlusRounded1cBlack,
                $NanumBrushScript,
                $NotoSansJP,
                $NotoSansJPMedium,
                $PlayfairDisplay,
                $PlaypenSans,
                $PlaypenSansMedium,
                $SedgwickAve
        }
        14 {
            $Fonts =
                $DidactGothic,
                $Jost,
                $KodeMonoSemiBold,
                $LibreBodoni,
                $Manjari,
                $MPlusRounded1cExtrabold,
                $NotoSansJP,
                $NotoSansJPMedium,
                $PlayfairDisplay,
                $PlayfairDisplayMedium,
                $PlaypenSans,
                $Roboto
        }
        15 {
            $Fonts =
                $Farsan,
                $Jost,
                $KodeMonoSemiBold,
                $LibreBodoni,
                $NanumBrushScript,
                $NotoSansJP,
                $NotoSansJPMedium,
                $PlayfairDisplay,
                $PlaypenSans
        }
        16 {
            $Fonts =
                $AreYouSerious,
                $CourierPrime,
                $KodeMonoSemiBold,
                $LibreBodoni,
                $NotoSansJPMedium,
                $PlayfairDisplay,
                $PlaypenSans
        }
        17 {
            $Fonts =
                $CourierPrime,
                $KodeMonoSemiBold,
                $LibreBodoni,
                $Manjari,
                $NotoSansJP,
                $NotoSansJPMedium,
                $PatrickHand,
                $PlayfairDisplay,
                $PlaypenSans
        }
        18 {
            $Fonts =
                $DancingScriptSemiBold,
                $LibreBodoni,
                $NotoSansJP,
                $NotoSansJPMedium,
                $PlayfairDisplay,
                $PlaypenSans
        }
        19 {
            $Fonts =
                $Jost,
                $KodeMonoSemiBold,
                $LibreBodoni,
                $NotoSansJP,
                $NotoSansJPMedium,
                $PlayfairDisplay,
                $PlaypenSans
        }
        20 {
            $Fonts =
                $KodeMonoSemiBold,
                $LibreBodoni,
                $NotoSansJPMedium,
                $PlayfairDisplay,
                $SedgwickAve
        }
        21 {
            $Fonts =
                $LibreBodoni,
                $NixieOne,
                $NotoSansJPMedium,
                $PlayfairDisplay
        }
        22 {
            $Fonts =
                $CourierPrime,
                $NotoSansJPMedium,
                $PixelifySans,
                $PlayfairDisplay,
                $PlaypenSans,
                $PlaypenSansMedium
        }
        23 {
            $Fonts =
                $IMFellEnglish,
                $LexendZettaLight,
                $Manjari,
                $NotoSansJP,
                $NotoSansJPMedium,
                $PlayfairDisplay,
                $PlaypenSans,
                $PlaypenSansMedium
        }
        Default { # OVA
            $EpisodeNumber = "OVA"
            $Fonts =
                $KodeMonoSemiBold,
                $LibreBodoni,
                $MPlusRounded1cBlack,
                $MPlusRounded1cMedium,
                $MPlusRounded1cExtrabold,
                $Manjari,
                $NotoSansJP,
                $NotoSansJPLight,
                $NotoSansJPMedium,
                $PatrickHand,
                $PlayfairDisplay,
                $PlayfairDisplayBlack,
                $PlaypenSansLight
        }
    }

    Write-Host -ForegroundColor Blue "`nMerging ""$FileName.mkv"" as episode $EpisodeNumber..."

    $Executable = "mkvmerge"

    $InputFile = Join-Path -Path "anime" -ChildPath ("$FileName.mkv")
    $OutputFile = Join-Path -Path "output" -ChildPath ("$FileName.mkv")
    $AddOutput = "-o", $OutputFile, "--default-track-flag", "1:0", "--default-track", "2:1", $InputFile

    $FullPrefix = "--default-track-flag", "0:1", "--language", "0:en", "--track-name", "0:Full [StyledHorribleFix]"
    $AddFullSubs = @(Get-Subtitles("full") | ForEach-Object {$FullPrefix + $_})

    $SSPrefix = "--default-track-flag", "0:0", "--language", "0:en", "--track-name", "0:Signs+Songs [StyledHorribleFix]"
    $AddSSSubs = @(Get-Subtitles("ss") | ForEach-Object {$SSPrefix + $_})

    $FontPrefix = "--attachment-mime-type", "application/x-truetype-font", "--attach-file"
    $AddFonts = @($Fonts | ForEach-Object {$FontPrefix + $_})

    &$Executable @(($AddOutput, $AddFullSubs, $AddSSSubs, $AddFonts) | ForEach-Object {$_})
}
