#!/bin/sh
#

. ../../common_variables.sh


function addWatermark() {
    name=$1
    srcInfo=$2
    text=$3
    temperatureUrl=$4

    temperature=$(curl ${temperatureUrl} | grep outsideTemp | sed -E "s/.+\"([-]?[0-9]+\.[0-9]+)\".+/\1/g")

    text=$(echo ${text} | sed "s/_/ /g")
    text="${text}, `date +\"%d-%m-%Y  %T\"`. T: ${temperature}C"

    src=${wview_html_dir}/${webcam_raw_prefix}_${name}.jpg
    dst=$(echo ${src} | sed "s/${webcam_raw_prefix}/${webcam_prefix}/g")
    dst_small=$(echo ${src} | sed "s/${webcam_raw_prefix}/${webcam_small_prefix}/g")

    if ! [[ -e ${src} ]]; then
        echo "Source ${src} does not exists...nothing to do"
        return
    fi

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

    rm ${src}

    echo "Done"
}

addWatermark "${fiobbioCfg[@]}"
addWatermark "${mismaCfg[@]}"
addWatermark "${mismaPanoCfg[@]}"

exit 0

