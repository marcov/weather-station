#!/bin/bash

set -euo pipefail

#
# Uploads on CML FTP server wview-generated data
#

. ../../common_variables.sh

declare -r CML_ftp_enabled=1
declare -r ftpPort=21

#
# The base set of FTP commands. These are the files always uploaded, and
# FTP setup commands.
#
declare -r ftpBaseCmds="ftp_commands.txt"

#
# NOTE: make sure this matches the paths specified in ftpBaseCmds!
#
declare -r cmlPngsPath="/tmp/cml-pngs"
#
# The full set of FTP commands, login info + base upload + NOAA upload + quit
# NOAA are sent only periodically.
#
declare -r ftpSendCmds="/tmp/cml_ftp_commands.txt"

declare -r imgDir="${WVIEW_DATA_DIR}/img"

#
# This is the default resolution for wview chargs, as specified in /etc/wview/graphics.conf
#
reqdPngResolution="300x180"

###############################################################################

check_upload_needed() {
    if ! [ ${CML_ftp_enabled} -eq 1 ]; then
        echo "FTP upload disabled..exiting"
        exit 0
    fi

    if ! true && [ -e "${imgDir}"/tempday_last.png ]; then
     cmp -s "${imgDir}"/tempday.png "${imgDir}"/tempday_last.png
     if [ $? -eq 0 ]; then
        echo "Content has not changed...exiting"
        exit 0
     else
        cp "${imgDir}"/tempday.png "${imgDir}"/tempday_last.png
     fi
    fi
}

resize_pngs() {
    rm -rf "$cmlPngsPath"
    mkdir -p "$cmlPngsPath"


    echo "Creating resized image for proper rendering on CML website"
    for img in `find /var/lib/wview/img -name "*day.png"`; do
        dst_small="${cmlPngsPath}/$(basename "$img")"
        set -x
        convert \
            -resize ${reqdPngResolution} \
            ${img} ${dst_small}
        set +x
    done
}

prepare_ftp_commands() {
    declare -r anno=`date +"%Y"`
    declare -r mese=`date +"%m"`
    declare -r giorno=`date +"%d"`
    declare -r ore=`date +"%H"`
    declare -r minuti=`date +"%M"`

    echo "FTP upload now..."

    rm -f ${ftpSendCmds}
    echo "user ${cml_ftp_user} ${cml_ftp_pwd}" >> ${ftpSendCmds}
    cat ${ftpBaseCmds} >> ${ftpSendCmds}

    if [ $minuti -gt 10 -a $minuti -le 15 ]; then
        if [ $mese -eq 1 ]; then
          pr_mese="12"
          pr_anno=`expr $anno - 1`
        else
          pr_mese=`expr $mese - 1`
          if [ $pr_mese -lt 10 ]; then
           pr_mese="0$pr_mese"
          fi
          pr_anno=$anno;
        fi

        echo "NOAA Archive Upload"

        echo "cd private" >> ${ftpSendCmds}

        if [ $giorno -eq 1 ]; then
          echo "put "${imgDir}"/NOAA/NOAA-$pr_anno-$pr_mese.txt NOAA-$pr_anno-$pr_mese.txt" >> ${ftpSendCmds}
          if [ $pr_anno -le $anno ]; then
            echo "put "${imgDir}"/NOAA/NOAA-$pr_anno.txt NOAA-$pr_anno.txt" >> ${ftpSendCmds}
          fi
        else
          echo "put "${imgDir}"/NOAA/NOAA-$anno-$mese.txt NOAA-$anno-$mese.txt" >> ${ftpSendCmds}
        fi
        echo "put "${imgDir}"/NOAA/NOAA-$anno.txt NOAA-$anno.txt" >> ${ftpSendCmds}
        echo "cd .." >> ${ftpSendCmds}

    else
        echo "Normal ftp upload"
    fi

    echo "quit" >> ${ftpSendCmds}
}

ftp_upload() {
    /usr/bin/ftp \
        -n -v -i ${cml_ftp_server} ${ftpPort} < ${ftpSendCmds}
}

check_upload_needed
resize_pngs
prepare_ftp_commands
ftp_upload
