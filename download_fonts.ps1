$ErrorActionPreference = "Stop"

class FontConfig {
    [ValidateNotNullOrEmpty()][string]$Path

    FontConfig($path) {
        $this.Path = $path
    }

    [void] Install() {
        Write-Host -ForegroundColor Blue "Downloading font ""$($this.Path)""..."

        $family = $this.Path.Substring(0, $this.Path.IndexOf('/')).Replace('_', ' ')

        $uri = "https://fonts.google.com/download/list?family=$($family.Replace(' ', '+'))"
        $response = Invoke-WebRequest -Uri $uri

        if ($response.StatusCode -ne 200) {
            Write-Error "Failed to retrieve font metadata: $($response.StatusCode) - $($response.StatusDescription)" -ErrorAction Continue
            return
        }

        $content = ConvertFrom-Json $response.Content.Substring($response.Content.IndexOf('{'))

        $fileName = $this.Path.Substring($this.Path.IndexOf('/') + 1)
        $fileRefs = $content.manifest.fileRefs
        $fileRef = $fileRefs | Where-Object { $_.filename -eq $fileName }
        if ($fileRef.Count -eq 0) {
            Write-Error "Specific font file not found!" -ErrorAction Continue
            Write-Host $response.Content
            return
        } elseif ($fileRef.Count -gt 1) {
            Write-Error "More identically-named files found!" -ErrorAction Continue
            Write-Host $response.Content
            return
        }
        $fileRef = $fileRef[0]

        $files = $content.manifest.files
        foreach ($file in $files) {
            $directory = "./fonts/$($family.Replace(' ', '_'))"
            New-Item -Path $directory -ItemType Directory -Force | Out-Null
            Out-File -FilePath "$directory/$($file.filename)" -InputObject $file.contents -Force
        }
        
        $fontPath = Join-Path -Path "./fonts" -ChildPath $this.Path
        $fontDirectory = Split-Path -Path $fontPath -Parent
        New-Item -Path $fontDirectory -ItemType Directory -Force | Out-Null
        $downloadResponse = Invoke-WebRequest -Uri $fileRef.url -OutFile $fontPath -PassThru
        if ($downloadResponse.StatusCode -ne 200) {
            Write-Error "Failed to download font file: $($downloadResponse.StatusCode) - $($downloadResponse.StatusDescription)" -ErrorAction Continue
            return
        }
    }
}

function Main {
    [FontConfig[]] $Fonts = @(
        [FontConfig]::New("Anton/Anton-Regular.ttf")
        [FontConfig]::New("Are_You_Serious/AreYouSerious-Regular.ttf"),
        [FontConfig]::New("Audiowide/Audiowide-Regular.ttf"),
        [FontConfig]::New("Bad_Script/BadScript-Regular.ttf"),
        [FontConfig]::New("Cinzel/static/Cinzel-Regular.ttf"),
        [FontConfig]::New("Concert_One/ConcertOne-Regular.ttf"),
        [FontConfig]::New("Courier_Prime/CourierPrime-Regular.ttf"),
        [FontConfig]::New("Dancing_Script/static/DancingScript-SemiBold.ttf"),
        [FontConfig]::New("Didact_Gothic/DidactGothic-Regular.ttf"),
        [FontConfig]::New("Farsan/Farsan-Regular.ttf"),
        [FontConfig]::New("IM_Fell_English/IMFellEnglish-Regular.ttf"),
        [FontConfig]::New("Jost/static/Jost-Regular.ttf"),
        [FontConfig]::New("Kode_Mono/static/KodeMono-SemiBold.ttf"),
        [FontConfig]::New("Lexend_Zetta/static/LexendZetta-Light.ttf"),
        [FontConfig]::New("Libre_Bodoni/static/LibreBodoni-Regular.ttf"),
        [FontConfig]::New("Lugrasimo/Lugrasimo-Regular.ttf"),
        [FontConfig]::New("M_PLUS_Rounded_1c/MPLUSRounded1c-Black.ttf"),
        [FontConfig]::New("M_PLUS_Rounded_1c/MPLUSRounded1c-Bold.ttf"),
        [FontConfig]::New("M_PLUS_Rounded_1c/MPLUSRounded1c-ExtraBold.ttf"),
        [FontConfig]::New("M_PLUS_Rounded_1c/MPLUSRounded1c-Medium.ttf"),
        [FontConfig]::New("Manjari/Manjari-Regular.ttf"),
        [FontConfig]::New("Nanum_Brush_Script/NanumBrushScript-Regular.ttf"),
        [FontConfig]::New("Nixie_One/NixieOne-Regular.ttf"),
        [FontConfig]::New("Noto_Sans_JP/static/NotoSansJP-Regular.ttf"),
        [FontConfig]::New("Noto_Sans_JP/static/NotoSansJP-Light.ttf"),
        [FontConfig]::New("Noto_Sans_JP/static/NotoSansJP-Medium.ttf"),
        [FontConfig]::New("Patrick_Hand/PatrickHand-Regular.ttf"),
        [FontConfig]::New("Pixelify_Sans/static/PixelifySans-Regular.ttf"),
        [FontConfig]::New("Playfair_Display/static/PlayfairDisplay-Regular.ttf"),
        [FontConfig]::New("Playfair_Display/static/PlayfairDisplay-Black.ttf"),
        [FontConfig]::New("Playfair_Display/static/PlayfairDisplay-ExtraBold.ttf"),
        [FontConfig]::New("Playfair_Display/static/PlayfairDisplay-Medium.ttf"),
        [FontConfig]::New("Playfair_Display/static/PlayfairDisplay-SemiBold.ttf"),
        [FontConfig]::New("Playpen_Sans/static/PlaypenSans-Regular.ttf"),
        [FontConfig]::New("Playpen_Sans/static/PlaypenSans-Light.ttf"),
        [FontConfig]::New("Playpen_Sans/static/PlaypenSans-Medium.ttf"),
        [FontConfig]::New("Roboto/static/Roboto-Regular.ttf"),
        [FontConfig]::New("Sedgwick_Ave/SedgwickAve-Regular.ttf"),
        [FontConfig]::New("Special_Elite/SpecialElite-Regular.ttf")
    )

    New-Item -Path "./fonts" -ItemType Directory -Force | Out-Null

    foreach ($font in $Fonts) { $font.Install() }
}

Main
