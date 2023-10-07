#!/bin/bash

set -euo pipefail

#
# Uploads on CML FTP server wview-generated data
#

. ../../common_variables.sh

declare -i -r ftp_port=21

declare -r data_dir="${1}"

#
# The base set of FTP commands. These are the files always uploaded, and
# FTP setup commands.
#
declare -r ftpBaseCmds="ftp_commands.txt"

#
# NOTE: make sure this matches the paths specified in ftpBaseCmds!
#
declare -r resized_png_path="/tmp/cml-pngs"
#
# The full set of FTP commands, login info + base upload + NOAA upload + quit
# NOAA are sent only periodically.
#
declare -r ftpSendCmds="/tmp/cml_ftp_commands.txt"

#
# This is the default resolution for wview charts, as specified in /etc/wview/graphics.conf
#
reqdPngResolution="300x180"

################################################################################

if ! [[ -d ${data_dir} ]]; then
    echo "ERR: invalid data dir: ${data_dir}"
    exit 1
fi

upload_needed_or_exit() {
    if [[ -z ${cml_ftp_user} ]] || [[ -z ${cml_ftp_pwd} ]]; then
        echo "No FTP upload credentials -- nothing to do"
        exit 1
    fi

    if cmp -s "${data_dir}"/tempday.png "${data_dir}"/tempday_last.png; then
        echo "Content has not changed -- nothing to do"
        exit 1
    fi

    cp "${data_dir}"/tempday.png "${data_dir}"/tempday_last.png
}

resize_pngs() {
    rm -rf "$resized_png_path"
    mkdir -p "$resized_png_path"

    echo "Creating resized image for proper rendering on CML website"
    for img in `find "${data_dir}" -name "*day.png"`; do
        dst_small="${resized_png_path}/$(basename "$img")"
        set -x
        convert \
            -resize ${reqdPngResolution} \
            ${img} ${dst_small}
        set +x
    done
}

prepare_ftp_commands() {
    declare -r -i anno=`date +"%Y"`
    declare -r -i mese=`date +"%m"`
    declare -r -i giorno=`date +"%d"`
    declare -r -i ore=`date +"%H"`
    declare -r -i minuti=`date +"%M"`

    echo "FTP upload now..."

    rm -f ${ftpSendCmds}
    echo "user ${cml_ftp_user} ${cml_ftp_pwd}" >> ${ftpSendCmds}
    cat ${ftpBaseCmds} >> ${ftpSendCmds}

    if [[ $ore == 0 ]] && [[ $minuti > 10 ]] && [[ $minuti < 16 ]]; then

        # Get prev month and prev year
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

        # On day 1, upload prev month NOAA data.
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

upload_needed_or_exit
resize_pngs
prepare_ftp_commands

ftp -n -v -i ${cml_ftp_server} ${ftp_port} < ${ftpSendCmds}
