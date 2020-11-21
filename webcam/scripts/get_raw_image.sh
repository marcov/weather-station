# copy from ftp upload dir to weather station www data
#
set -euo pipefail

source ../../common_variables.sh

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

    [ "$?" = "0" ] || { echo "ERR: HTTP GET failed"; false; return; }

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

        /bin/mv ${latest} ${dst} || { false; return; }
}

getRawPicture() {
    name=$1
    srcType=$(echo $2 | cut -d" " -f 1)

    dst=${wviewEphemeralImg}/${webcam_raw_prefix}_${name}.jpg

    if [ ${srcType} == "http" ]; then
        login=$(echo $2 | cut -d" " -f 2)
        url=$(echo $2 | cut -d" " -f 3)

        httpGet ${login} ${url} ${dst} || { false; return; }
    elif [ ${srcType} == "local" ]; then
        srcDir=$(echo $2 | cut -d" " -f 2)
        pattern=$(echo $2 | cut -d" " -f 3)

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

for i in $(seq 0 ${fiobbioRetries}); do
    sleepTime=$(( $i * 2 ))
    echo "INFO: sleeping $sleepTime"
    sleep "$sleepTime"
    echo "INFO: get fiobbio $i"
    getRawPicture "${fiobbioCfg[@]}" && break || echo "ERR: failed to get fiobbio"
done

for i in $(seq 0 ${mismaRetries}); do
    sleepTime=$(( $i * 2 ))
    echo "INFO: sleeping $sleepTime"
    sleep "$sleepTime"
    echo "INFO: get misma $i"
    getRawPicture "${mismaCfg[@]}" && break || echo "ERR: failed to get misma"
done

for i in $(seq 0 ${panoRetries}); do
    sleepTime=$(( $i * 2 ))
    echo "INFO: sleeping $sleepTime"
    sleep "$sleepTime"
    echo "INFO: get misma pano $i"
    getRawPicture "${mismaPanoCfg[@]}" && break || echo "ERR: failed to get misma pano"
done

exit $?
