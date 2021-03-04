#!/bin/bash

set -euo pipefail

declare scriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source "${scriptDir}"/../config.sh
source "${scriptDir}"/../../common_variables.sh

getTemperature () {
    url="$1"
    jsonTmp=$(mktemp)

    #
    # Add the insecure flag, since it's a local IP but it's using TLS.
    #
    if curl -o "$jsonTmp" -k -fsSL "${temperatureUrl}"
    then
        read -r temperature <<< `jq -r .outsideTemp "$jsonTmp"`
    else
        temperature="N.A."
    fi

    rm -f $jsonTmp 2>&1 >> /dev/null

    echo "$temperature"
}

addWatermark () {
    name=$1
    srcInfo=$2
    stationName=$3
    temperatureUrl=$4
    resolution=$5

    temperature=`getTemperature "${temperatureUrl}"`
    stationName="$(sed "s/_/ /g" <<< "${stationName}")"
    dateTime="$(date +"%H:%M %d-%m-%Y")"
    watermarkText="${stationName}, ${temperature}°C - ${dateTime}"

    src=${hostWebcamDir}/${webcam_raw_prefix}_${name}.jpg

    dst=$(echo ${src} | sed "s/${webcam_raw_prefix}/${webcam_prefix}/g")
    dst_small=$(echo ${src} | sed "s/${webcam_raw_prefix}/${webcam_small_prefix}/g")

    dst_tmp="${dst}.tmp"
    dst_small_tmp="${dst_small}.tmp"

    echo "SRC: ${src}"
    echo "  Watermark text:  ${watermarkText}"
    echo "  DST (watermark): ${dst_tmp}"
    echo "  DST (scaled):    ${dst_small_tmp}"

    [ -f "${src}" ] || { echo "ERR: ${src} does not exists, skip watermark"; return; }

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
