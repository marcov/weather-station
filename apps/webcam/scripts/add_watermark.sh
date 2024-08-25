#!/bin/bash

set -euo pipefail

declare scriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source "${scriptDir}"/../config.sh

getTemperature () {
    local url="$1"
    local jsonTmp=$(mktemp)

    #
    # Add the insecure flag, since it's a local IP but it's using TLS.
    #
    if curl -o "$jsonTmp" -k -fsSL "${url}"
    then
        read -r temperature <<< `jq -r .outsideTemp "$jsonTmp"`
    else
        temperature="N.A."
    fi

    rm -f $jsonTmp 2>&1 >> /dev/null

    echo "$temperature"
}

addWatermark () {
    local -n cfgRef="$1"

    temperature=`getTemperature "${cfgRef[tsource]}"`
    stationName="$(sed "s/_/ /g" <<< "${cfgRef[watermark]}")"
    dateTime="$(date +"%H:%M %d/%m/%y")"

    watermarkText="${stationName}, ${temperature}°C, ${dateTime} - ${websiteUrl}"

    src=${hostWebcamDir}/${webcam_raw_prefix}_${cfgRef[name]}.jpg

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
        -resize ${cfgRef[size]} \
        ${dst_tmp} ${dst_small_tmp} || return $?
    echo "Done"

    mv ${dst_tmp} ${dst}
    mv ${dst_small_tmp} ${dst_small}

    rm -f ${src} ${dst_tmp} ${dst_small_tmp}
}

for cfg in fiobbioCfg mismaCfg mismaPanoCfg; do
    addWatermark "$cfg"
done

exit 0
