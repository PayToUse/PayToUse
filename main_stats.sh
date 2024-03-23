#!/bin/bash
# Credits to @fearocanity in github

username="PayToUse"

circlelize_image(){
        convert "${1}" \
        -gravity Center \
        \( -size "${2}" \
           xc:Black \
           -fill White \
           -draw "circle $((${2%x*}/2)) $((${2%x*}/2)) $((${2%x*}/2)) 1" \
           -alpha Copy \
        \) -compose CopyOpacity -composite \
        -trim "${3}"
}

git_meta="$(curl -sL https://api.github.com/users/"${username}")"
followers="$(jq -r .followers <<< "$git_meta")"
following="$(jq -r .following <<< "$git_meta")"
profile_visitors="$(curl -sL "https://komarev.com/ghpvc/?username=${username}" | sed -nE 's_.*>([0-9,]*)</text>.*_\1_p' | head -n 1)"
curl -sL "$(jq -r .avatar_url <<< "$git_meta")" -o av.jpg


circlelize_image "av.jpg" "250x250" output_av_circ.png

for ((i=0;i<=100;i+=2)); do
        [[ "$i" = "0" ]] && { percentage="1" ; i=1 ;} || percentage="${i}"
        radius=100
        center_x=200
        center_y=200
        sweep_angle=$((percentage * 360 / 100))

        # Create mask
        (convert -size 400x400 xc:none \
          -fill none -stroke "#32CD32" -strokewidth 5 \
          -draw "arc $((center_x - radius)),$((center_y - radius)) $((center_x + radius)),$((center_y + radius)) 0,$sweep_angle" \
          mask_"$i".png

        # Apply mask as a stroke
        convert output_av_circ.png -resize 250x250 \
                \( mask_"$i".png \
                        -resize 490x490 \
                \) -gravity west -geometry -120.5+0 -composite -append output_avn_"$i".png


        convert -size 500x200 xc:none \
                -fill "#333333" -draw "roundrectangle 10,10,490,190,90,90" \
                \( output_avn_"$i".png \
                        -resize 45% \
                \) \
                -gravity west \
                -geometry +40+0 \
                -composite \
                -stroke none -fill "#FFFFFF" -font mona_b.ttf -pointsize 35 -annotate +175-50 "GitHub Stats:" \
                -font mona_bb.ttf -pointsize 15 -interline-spacing "5" -annotate +175+10 "Profile Visits: ${profile_visitors}\nFollowers: ${followers}\nFollowing: ${following}" \
                -append output_avx_"$i".png
        rm mask_"$i".png output_avn_"$i".png
        ) &
        [[ "$i" = "1" ]] && : "$((i-=1))"
done

wait -n
convert -dispose none -delay 2.5 $(ls -v output_avx_*.png) -coalesce banner_stats.gif
rm av.jpg output_av_circ.png output_avx_*.png
