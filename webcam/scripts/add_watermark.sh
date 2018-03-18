#!/bin/sh
#

. ../../common_variables.sh


function addWatermark() {
    name=$1
    pattern=$3
    text=$4
    temperature=$7

    text=$(echo ${text} | sed "s/_/ /g")
    text="${text}, `date +\"%d-%m-%Y  %T\"`. T: ${temperature}C"

    src=${wview_html_dir}/${webcam_raw_prefix}_${name}.jpg
    dst=$(echo ${src} | sed "s/${webcam_raw_prefix}/${webcam_prefix}/g")
    dst_small=$(echo ${src} | sed "s/${webcam_raw_prefix}/${webcam_small_prefix}/g")

    echo "Source: ${src}"
    echo "  With watermark: ${dst}"
    echo "  Resized: ${dst_small}"
    echo "  Watermark text: ${text}"

    echo "Adding watermark..."

    convert -pointsize 32 \
        -fill white \
        -undercolor "rgba(0,0,0,0.6)" \
        -gravity northwest \
        -draw "text 0,0 \"${text}\"" \
        ${src} ${dst} || returni $?
    echo "Done"

    echo "Creating resized image for faster loading..."

    convert \
        resize 800x600 \
        ${dst} ${dst_small} || return $?
    echo "Done"
}

addWatermark "${fiobbioCfg[@]}"
addWatermark "${mismaCfg[@]}"
#addWatermark "${mismaPanoCfg[@]}"
exit 0

