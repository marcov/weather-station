#!/bin/sh
#
# copy from ftp upload dir to weather station www data
#

. ../../common_variables.sh

#
# NO NEED TO EDIT BELOW THIS!
#

function copy2www() {
    name=$1
    src=$2
    pattern=$3

    if [ ${src} == "" ]; then
        echo "src is empty...nothing to copy"
        return
    fi

    echo ${name} ${src} ${pattern}

    echo "Locating last webcam pic..."

    webcam_raw=$(find ${src} -type f -name "${pattern}" | sort | tail -n 1)

	if ! [ -e "${webcam_raw}" ]; then
	    echo "Raw image not found...exiting"
        return
    fi

	echo "Raw image found: ${webcam_raw}"

	echo "Copying and chmoding..."

    dst=${wview_html_dir}/${webcam_raw_prefix}_${name}.jpg

    /bin/cp ${webcam_raw} ${dst} || exit $?
	chmod +rw ${dst} || exit $?
	echo "Done"

    rm ${webcam_raw}
}

copy2www ${fiobbioCfg[@]}
copy2www ${mismaCfg[@]}
#copy2www ${mismaPanoCfg[@]}

exit 0

