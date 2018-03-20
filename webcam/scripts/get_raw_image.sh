#!/bin/sh
#
# copy from ftp upload dir to weather station www data
#

. ../../common_variables.sh

#
# NO NEED TO EDIT BELOW THIS!
#

function httpGet() {
    login=$1
    url=$2
    dst=$3

    echo "HTTP GET"

    curl --max-time 10 --basic -u ${login} ${url}  -o ${dst}
}

function localGet() {
        srcDir=$1
        pattern=$2
        dst=$3

        echo "Local GET"
        echo "Locating last webcam pic..."

        webcamLocal=$(find ${srcDir} -type f -name "${pattern}" | sort | tail -n 1)

        if ! [ -e "${webcamLocal}" ]; then
            echo "Raw image not found...exiting"
            return
        fi

        echo "Raw image found: ${webcamLocal}"

        echo "Copying..."

        /bin/cp ${webcamLocal} ${dst} || return $?
}

function getRawPicture() {
    name=$1
    srcType=$(echo $2 | cut -d" " -f 1)

    dst=${wview_html_dir}/${webcam_raw_prefix}_${name}.jpg


    if [ ${srcType} == "http" ]; then

        login=$(echo $2 | cut -d" " -f 2)
        url=$(echo $2 | cut -d" " -f 3)

        httpGet ${login} ${url} ${dst}

    elif [ ${srcType} == "local" ]; then

        srcDir=$(echo $2 | cut -d" " -f 2)
        pattern=$(echo $2 | cut -d" " -f 3)

        localGet ${srcDir} ${pattern} ${dst}

    else
        echo "srcType is empty / invalid ...nothing to do"
        return
    fi

    echo "chmoding..."
	chmod +rw ${dst} || return $?
	echo "Done"
}

getRawPicture ${fiobbioCfg[@]}
getRawPicture ${mismaCfg[@]}
getRawPicture ${mismaPanoCfg[@]}

exit 0

