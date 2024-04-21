#!/bin/bash
: '
Automatically merges all subtitles into the video files

Make sure mkvmerge is installed! (https://mkvtoolnix.download/)

This script assumes the following file structure:
 root
 ├── anime                Contains all anime episodes
 ├── auto-mkv-subs.sh     This script
 ├── fonts                The fonts folder, as supplied in the download links
 ├── full                 The full subtitles, as supplied by the ssa-cleanup script
 ├── output               The output folder (will be automatically generated)
 └── ss                   The signs+songs subtitles, as supplied by the ssa-cleanup script

The episode number of the video will be identified by concatonating ALL NUMBERS in the filename
make sure these are thus equal to the desired episode number (leading zeroes are ignored)
(e.g. "[Anime Time] Steins;Gate 0 - 12" will be evaluated as "012" -> episode 12)
Any episode whose number does not evaluate to something between 1 and 23 will be treated as the OVA

The subtitles will be associated with their video file by evaluating the episode number in the same way
'

Anton="./fonts/Anton/Anton-Regular.ttf"
AreYouSerious="./fonts/Are_You_Serious/AreYouSerious-Regular.ttf"
Audiowide="./fonts/Audiowide/Audiowide-Regular.ttf"
BadScript="./fonts/Bad_Script/BadScript-Regular.ttf"
Cinzel="./fonts/Cinzel/static/Cinzel-Regular.ttf"
ConcertOne="./fonts/Concert_One/ConcertOne-Regular.ttf"
CourierPrime="./fonts/Courier_Prime/CourierPrime-Regular.ttf"
DancingScriptSemiBold="./fonts/Dancing_Script/static/DancingScript-SemiBold.ttf"
DidactGothic="./fonts/Didact_Gothic/DidactGothic-Regular.ttf"
Farsan="./fonts/Farsan/Farsan-Regular.ttf"
IMFellEnglish="./fonts/IM_Fell_English/IMFellEnglish-Regular.ttf"
Jost="./fonts/Jost/static/Jost-Regular.ttf"
KodeMonoSemiBold="./fonts/Kode_Mono/static/KodeMono-SemiBold.ttf"
LexendZettaLight="./fonts/Lexend_Zetta/static/LexendZetta-Light.ttf"
LibreBodoni="./fonts/Libre_Bodoni/static/LibreBodoni-Regular.ttf"
Lugrasimo="./fonts/Lugrasimo/Lugrasimo-Regular.ttf"
MPlusRounded1cBlack="./fonts/M_PLUS_Rounded_1c/MPLUSRounded1c-Black.ttf"
MPlusRounded1cBold="./fonts/M_PLUS_Rounded_1c/MPLUSRounded1c-Bold.ttf"
MPlusRounded1cExtrabold="./fonts/M_PLUS_Rounded_1c/MPLUSRounded1c-ExtraBold.ttf"
MPlusRounded1cMedium="./fonts/M_PLUS_Rounded_1c/MPLUSRounded1c-Medium.ttf"
Manjari="./fonts/Manjari/Manjari-Regular.ttf"
NanumBrushScript="./fonts/Nanum_Brush_Script/NanumBrushScript-Regular.ttf"
NixieOne="./fonts/Nixie_One/NixieOne-Regular.ttf"
NotoSansJP="./fonts/Noto_Sans_JP/static/NotoSansJP-Regular.ttf"
NotoSansJPLight="./fonts/Noto_Sans_JP/static/NotoSansJP-Light.ttf"
NotoSansJPMedium="./fonts/Noto_Sans_JP/static/NotoSansJP-Medium.ttf"
PatrickHand="./fonts/Patrick_Hand/PatrickHand-Regular.ttf"
PixelifySans="./fonts/Pixelify_Sans/static/PixelifySans-Regular.ttf"
PlayfairDisplay="./fonts/Playfair_Display/static/PlayfairDisplay-Regular.ttf"
PlayfairDisplayBlack="./fonts/Playfair_Display/static/PlayfairDisplay-Black.ttf"
PlayfairDisplayExtrabold="./fonts/Playfair_Display/static/PlayfairDisplay-ExtraBold.ttf"
PlayfairDisplayMedium="./fonts/Playfair_Display/static/PlayfairDisplay-Medium.ttf"
PlayfairDisplaySemibold="./fonts/Playfair_Display/static/PlayfairDisplay-SemiBold.ttf"
PlaypenSans="./fonts/Playpen_Sans/static/PlaypenSans-Regular.ttf"
PlaypenSansLight="./fonts/Playpen_Sans/static/PlaypenSans-Light.ttf"
PlaypenSansMedium="./fonts/Playpen_Sans/static/PlaypenSans-Medium.ttf"
Roboto="./fonts/Roboto/Roboto-Regular.ttf"
SedgwickAve="./fonts/Sedgwick_Ave/SedgwickAve-Regular.ttf"
SpecialElite="./fonts/Special_Elite/SpecialElite-Regular.ttf"

# $1: string to replace
function get_episode_number {
    echo "$1" | sed -e "s/[^0-9]//g" -e "s/^0*//"
}

# $1: folder name
function get_subtitles {
    episode_sub_files=()

    for sub_file in ./$1/*.ass
    do
        sub_file_name_ext=$(basename -- "$sub_file")
        sub_file_name="${sub_file_name_ext%.*}"
        sub_number=$(get_episode_number "$sub_file_name")

        if [[ $sub_number -eq "" ]]; then sub_number=0; fi
        if (( !($sub_number == $episode_number || ($sub_number != 0 && $sub_number < 1 || 23 < $sub_number) && $episode_number == "OVA") ))
        then
            continue
        fi

        episode_sub_files+=($sub_file)
    done

    echo ${episode_sub_files[@]}
}

mkdir -p ./output
for file in ./anime/*.mkv
do
    file_name_ext=$(basename -- "$file")
    file_name="${file_name_ext%.*}"
    episode_number=$(get_episode_number "$file_name")

    case $episode_number in
        "1")
            fonts=(
                $ConcertOne
                $NotoSansJP
                $NotoSansJPMedium
                $PatrickHand
                $PixelifySans
                $PlayfairDisplay
                $PlayfairDisplayMedium
                $PlayfairDisplaySemibold
                $PlaypenSans
                $SpecialElite
            );;
        "2")
            fonts=(
                $LibreBodoni
                $Lugrasimo
                $NotoSansJP
                $NotoSansJPMedium
                $PlayfairDisplay
            );;
        "3")
            fonts=(
                $LibreBodoni
                $Lugrasimo
                $NotoSansJP
                $NotoSansJPMedium
                $PatrickHand
                $PlayfairDisplay
                $PlaypenSans
                $Roboto
            );;
        "4")
            fonts=(
                $LibreBodoni
                $Lugrasimo
                $NotoSansJP
                $NotoSansJPMedium
                $PlayfairDisplay
                $PlayfairDisplayExtrabold
                $Roboto
            );;
        "5")
            fonts=(
                $Anton
                $LibreBodoni
                $Lugrasimo
                $NotoSansJP
                $NotoSansJPMedium
                $PlayfairDisplay
                $PlaypenSans
            );;
        "6")
            fonts=(
                $Jost
                $LibreBodoni
                $Lugrasimo
                $NotoSansJP
                $NotoSansJPMedium
                $PlayfairDisplay
                $SedgwickAve
            );;
        "7")
            fonts=(
                $LibreBodoni
                $Lugrasimo
                $NotoSansJP
                $NotoSansJPMedium
                $PlayfairDisplay
                $PlayfairDisplayMedium
                $PlaypenSans
                $Roboto
                $SedgwickAve
            );;
        "8")
            fonts=(
                $Cinzel
                $DancingScriptSemiBold
                $LibreBodoni
                $Manjari
                $NotoSansJP
                $NotoSansJPMedium
                $PlayfairDisplay
                $PlayfairDisplayExtrabold
                $PlaypenSans
                $PlaypenSansMedium
            );;
        "9")
            fonts=(
                $Anton
                $ConcertOne
                $Farsan
                $LibreBodoni
                $Lugrasimo
                $MPlusRounded1cExtrabold
                $NotoSansJP
                $NotoSansJPMedium
                $PlayfairDisplay
                $PlayfairDisplayMedium
                $PlaypenSans
            );;
        "10")
            fonts=(
                $ConcertOne
                $LibreBodoni
                $Lugrasimo
                $NotoSansJP
                $NotoSansJPMedium
                $PlayfairDisplay
                $PlayfairDisplayMedium
                $PlaypenSans
            );;
        "11")
            fonts=(
                $Anton
                $AreYouSerious
                $LibreBodoni
                $Lugrasimo
                $MPlusRounded1cMedium
                $NotoSansJP
                $NotoSansJPMedium
                $PlayfairDisplay
                $PlayfairDisplayMedium
                $PlaypenSans
            );;
        "12")
            fonts=(
                $Anton
                $Audiowide
                $Jost
                $LibreBodoni
                $MPlusRounded1cBold
                $MPlusRounded1cExtrabold
                $NotoSansJP
                $NotoSansJPLight
                $NotoSansJPMedium
                $PlayfairDisplay
                $SedgwickAve
            );;
        "13")
            fonts=(
                $BadScript
                $ConcertOne
                $LibreBodoni
                $Lugrasimo
                $MPlusRounded1cBlack
                $NanumBrushScript
                $NotoSansJP
                $NotoSansJPMedium
                $PlayfairDisplay
                $PlaypenSans
                $PlaypenSansMedium
                $SedgwickAve
            );;
        "14")
            fonts=(
                $DidactGothic
                $Jost
                $KodeMonoSemiBold
                $LibreBodoni
                $Manjari
                $MPlusRounded1cExtrabold
                $NotoSansJP
                $NotoSansJPMedium
                $PlayfairDisplay
                $PlayfairDisplayMedium
                $PlaypenSans
                $Roboto
            );;
        "15")
            fonts=(
                $Farsan
                $Jost
                $KodeMonoSemiBold
                $LibreBodoni
                $NanumBrushScript
                $NotoSansJP
                $NotoSansJPMedium
                $PlayfairDisplay
                $PlaypenSans
            );;
        "16")
            fonts=(
                $AreYouSerious
                $CourierPrime
                $KodeMonoSemiBold
                $LibreBodoni
                $NotoSansJPMedium
                $PlayfairDisplay
                $PlaypenSans
            );;
        "17")
            fonts=(
                $CourierPrime
                $KodeMonoSemiBold
                $LibreBodoni
                $Manjari
                $NotoSansJP
                $NotoSansJPMedium
                $PatrickHand
                $PlayfairDisplay
                $PlaypenSans
            );;
        "18")
            fonts=(
                $DancingScriptSemiBold
                $LibreBodoni
                $NotoSansJP
                $NotoSansJPMedium
                $PlayfairDisplay
                $PlaypenSans
            );;
        "19")
            fonts=(
                $Jost
                $KodeMonoSemiBold
                $LibreBodoni
                $NotoSansJP
                $NotoSansJPMedium
                $PlayfairDisplay
                $PlaypenSans
            );;
        "20")
            fonts=(
                $KodeMonoSemiBold
                $LibreBodoni
                $NotoSansJPMedium
                $PlayfairDisplay
                $SedgwickAve
            );;
        "21")
            fonts=(
                $LibreBodoni
                $NixieOne
                $NotoSansJPMedium
                $PlayfairDisplay
            );;
        "22")
            fonts=(
                $CourierPrime
                $NotoSansJPMedium
                $PixelifySans
                $PlayfairDisplay
                $PlaypenSans
                $PlaypenSansMedium
            );;
        "23")
            fonts=(
                $IMFellEnglish
                $LexendZettaLight
                $Manjari
                $NotoSansJP
                $NotoSansJPMedium
                $PlayfairDisplay
                $PlaypenSans
                $PlaypenSansMedium
            );;
        *)
            episode_number="OVA"
            fonts=(
                $KodeMonoSemiBold
                $LibreBodoni
                $MPlusRounded1cBlack
                $MPlusRounded1cMedium
                $MPlusRounded1cExtrabold
                $Manjari
                $NotoSansJP
                $NotoSansJPLight
                $NotoSansJPMedium
                $PatrickHand
                $PlayfairDisplay
                $PlayfairDisplayBlack
                $PlaypenSansLight
            );;
    esac

    echo -e "\n\033[1;34mMerging \"$file_name_ext\" as episode $episode_number...\033[0m"

    executable="mkvmerge"

    input_file=$file
    output_file="./output/$file_name.mkv"
    addOutput=("-o" "\"$output_file\"" "--default-track" "1:0" "--default-track" "2:1" "\"$input_file\"")

    full_prefix=("--default-track" "0:1" "--language" "0:en" "--track-name" "0:\"Full [StyledHorribleFix]\"")
    add_full_subs=()
    full_subs=$(get_subtitles "full")
    for ((i = 0; i < ${#full_subs[@]}; i++))
    do
        add_full_subs+=("${full_prefix[@]}" "\"${full_subs[$i]}\"")
    done

    ss_prefix=("--default-track" "0:0" "--language" "0:en" "--track-name" "0:\"Signs+Songs [SyledHorribleFix]\"")
    add_ss_subs=()
    ss_subs=$(get_subtitles "ss")
    for ((i = 0; i < ${#ss_subs[@]}; i++))
    do
        add_ss_subs+=("${ss_prefix[@]}" "\"${ss_subs[$i]}\"")
    done

    font_prefix=("--attachment-mime-type" "application/x-truetype-font" "--attach-file")
    add_fonts=()
    for ((i = 0; i < ${#fonts[@]}; i++))
    do
        add_fonts+=("${font_prefix[@]}" "\"${fonts[$i]}\"")
    done

    command=( "${executable[@]}" "${addOutput[@]}" "${add_full_subs[@]}" "${add_ss_subs[@]}" "${add_fonts[@]}")

    eval "${command[@]}"
done
