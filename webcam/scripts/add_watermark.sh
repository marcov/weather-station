#!/bin/bash

set -euo pipefail

. ../../common_variables.sh


addWatermark() {
    name=$1
    srcInfo=$2
    stationName=$3
    temperatureUrl=$4
    ftplogin=$5
    resolution=$6

    #
    # Add the insecure flag, since it's a local IP but it's using TLS.
    #
    temperature="$(curl -k -fsSL "${temperatureUrl}" | jq -r .outsideTemp)"
    stationName="$(sed "s/_/ /g" <<< "${stationName}")"
    dateTime="$(date +"%H:%M %d-%m-%Y")"
    watermarkText="${stationName}, ${temperature}°C - ${dateTime}"

    src=${wviewEphemeralImg}/${webcam_raw_prefix}_${name}.jpg

    dst=$(echo ${src} | sed "s/${webcam_raw_prefix}/${webcam_prefix}/g")
    dst_small=$(echo ${src} | sed "s/${webcam_raw_prefix}/${webcam_small_prefix}/g")

    dst_tmp="${dst}.tmp"
    dst_small_tmp="${dst_small}.tmp"

    [ -f "${src}" ] || { echo "ERR: ${src} does not exists, skip watermark"; return; }

    echo "SRC: ${src}"
    echo "  Watermark text:  ${watermarkText}"
    echo "  DST (watermark): ${dst_tmp}"
    echo "  DST (scaled):    ${dst_small_tmp}"

    echo "Adding watermark"
    convert -pointsize 32 \
        -fill white \
        -undercolor "rgba(0,0,0,0.6)" \
        -gravity northwest \
        -draw "text 0,0 \"${watermarkText}\" " \
        ${src} ${dst_tmp} || return $?
    echo "Done"

    echo "Creating scaled image"
    convert \
        -resize ${resolution} \
        ${dst_tmp} ${dst_small_tmp} || return $?
    echo "Done"

    mv ${dst_tmp} ${dst}
    mv ${dst_small_tmp} ${dst_small}

    rm -f ${src} ${dst_tmp} ${dst_small_tmp}
}

addWatermark "${fiobbioCfg[@]}"
addWatermark "${mismaCfg[@]}"
addWatermark "${mismaPanoCfg[@]}"

exit 0
