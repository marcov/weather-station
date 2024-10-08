#!/bin/bash
#
# Get raw images from the webcam
#
set -euo pipefail

declare scriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source "${scriptDir}"/../config.sh

declare -i maxCurlTime=120

httpGet() {
    login="$1"
    url="$2"
    dst="$3"

    echo "INFO: HTTP GET"
    httpResponseHeaders=$(curl \
                             -fL \
                             --max-time "$maxCurlTime" \
                             --basic -u "${login}" \
                             -o "${dst}" \
                             --dump-header /dev/stdout \
                             "${url}")

    #
    # Delete the image if it's not completely downloaded (should check err code 28)
    # Call `false' so that return code is a failure
    #
    [ "$?" = "0" ] || { echo "ERR: cURL (HTTP GET) failed"; rm -f "${dst}"; false; return; }

    contentLength=$(grep -P -o -e "Content-Length: \K([0-9]+)" <<< "${httpResponseHeaders}")
    [ "$?" = "0" ] || { echo "ERR: detecting file size failed"; false; return; }

    echo "INFO: HTTP GET Content-Length: ${contentLength}"

    filesize=$(stat -c "%s" "${dst}")
    [ "$?" = "0" ] || { echo "ERR: stat'ing dst file"; false; return; }
    echo "INFO: stat file size: ${filesize}"

    [ "$contentLength" = "$filesize" ] || { echo "ERR: file size $filesize does not match HTTP Content-Length $contentLength"; false; return; }
}

localGet() {
        srcDir=$1
        pattern=$2
        dst=$3

        echo "INFO: LOCAL GET"
        echo "INFO: Locating most recent file..."

        latest=$(find ${srcDir} -type f -name "${pattern}" | sort | tail -n 1)

        if ! [ -e "${latest}" ]; then
            echo "ERR: latest file not found...exiting"
            false
            return
        fi

        echo "INFO: latest file found: ${latest}"

        echo "INFO: Copying..."

        /bin/cp ${latest} ${dst} || { false; return; }

        echo "INFO: Deleting ..."
        rm -f ${latest} || false
}

getRawPicture() {
    local -n cfgRef="$1"
    local login="${2:-}"
    local srcType=$(awk '{print $1}' <<< "${cfgRef[url]}")

    local dst=${hostWebcamDir}/${webcam_raw_prefix}_${cfgRef[name]}.jpg

    if [ ${srcType} == "http" ]; then
        url=$(awk '{print $2}' <<< "${cfgRef[url]}")

        httpGet ${login} ${url} ${dst} || { false; return; }
    elif [ ${srcType} == "local" ]; then
        srcDir=$(awk '{print $2}' <<< "${cfgRef[url]}")
        pattern=$(awk '{print $3}' <<< "${cfgRef[url]}")

        localGet ${srcDir} ${pattern} ${dst} || { false; return; }
    else
        echo "ERR: srcType is empty / invalid...nothing to do"
        false
        return
    fi

    echo "INFO: chmod +rw"
    chmod +rw ${dst} || return $?
    echo "INFO: Done"
}

for i in $(seq 0 ${fiobbioCfg[retries]}); do
    sleepTime=$(( $i * 2 ))
    echo "INFO: sleeping $sleepTime"
    sleep "$sleepTime"
    echo "INFO: get fiobbio $i"
    getRawPicture fiobbioCfg "${fiobbio_webcam_login}" && \
        break || echo "ERR: failed to get fiobbio"
done

for i in $(seq 0 ${mismaCfg[retries]}); do
    sleepTime=$(( $i * 2 ))
    echo "INFO: sleeping $sleepTime"
    sleep "$sleepTime"
    echo "INFO: get misma $i"
    getRawPicture mismaCfg "${misma_webcam_login}" && \
        break || echo "ERR: failed to get misma"
done

for i in $(seq 0 ${mismaPanoCfg[retries]}); do
    sleepTime=$(( $i * 2 ))
    echo "INFO: sleeping $sleepTime"
    sleep "$sleepTime"
    echo "INFO: get misma pano $i"
    getRawPicture mismaPanoCfg && break || echo "ERR: failed to get misma pano"
done

exit $?
