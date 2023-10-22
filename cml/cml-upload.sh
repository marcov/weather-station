#!/bin/bash

set -euo pipefail

#
# Uploads on CML FTP server wview-generated data
#

declare -r scripts_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

declare -r cml_ftp_server="ftp.centrometeolombardo.com"
declare -i -r ftp_port=21

declare -r data_dir="${1}"

#
# The base set of FTP commands. These are the files always uploaded, and
# FTP setup commands.
#
declare -r ftpBaseCmds="${scripts_dir}/ftp_commands.txt"

#
# NOTE: make sure this matches the paths specified in ftpBaseCmds!
#
declare -r cml_upload_path="${data_dir}/cml-upload"
#
# The full set of FTP commands, login info + base upload + NOAA upload + quit
# NOAA are sent only periodically.
#
declare -r ftpSendCmds="/tmp/cml_ftp_commands.txt"

#
# This is the default resolution for wview charts, as specified in /etc/wview/graphics.conf
#
declare -r scaled_resolution=300x180

################################################################################

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
    echo "Creating resized image for proper rendering on CML website"
    for img in `find "${data_dir}" -name "*day.png"`; do
        dst_small="${cml_upload_path}/$(basename "$img")"

        convert -resize "${scaled_resolution}" "${img}" "${dst_small}"
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

    # This assumes the script runs every 5 minutes ...
    if [[ $ore == 0 ]] && [[ $minuti > 10 ]] && [[ $minuti < 18 ]]; then
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
            echo "put NOAA/NOAA-$pr_anno-$pr_mese.txt NOAA-$pr_anno-$pr_mese.txt" >> ${ftpSendCmds}
            if [ $pr_anno -le $anno ]; then
                echo "put NOAA/NOAA-$pr_anno.txt NOAA-$pr_anno.txt" >> ${ftpSendCmds}
            fi
        else
            echo "put NOAA/NOAA-$anno-$mese.txt NOAA-$anno-$mese.txt" >> ${ftpSendCmds}
        fi

        echo "put NOAA/NOAA-$anno.txt NOAA-$anno.txt" >> ${ftpSendCmds}

        echo "cd .." >> ${ftpSendCmds}

    else
            echo "Normal ftp upload"
    fi

    echo "quit" >> ${ftpSendCmds}
}

################################################################################

if ! [[ -d ${data_dir} ]]; then
    echo "ERR: invalid data dir: ${data_dir}"
    exit 1
fi

upload_needed_or_exit

rm -rf "$cml_upload_path"
mkdir -p "$cml_upload_path"

resize_pngs
prepare_ftp_commands

# Commands are relative to data dir
pushd ${data_dir}
ftp -n -i ${cml_ftp_server} ${ftp_port} < ${ftpSendCmds}
popd
