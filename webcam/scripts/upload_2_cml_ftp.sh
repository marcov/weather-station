#!/bin/sh
#
# upload webcam images from www data to cml ftp
#
set -euo pipefail

. ../../common_variables.sh

#
# NO NEED TO EDIT BELOW THIS!
#

ftpUpload() {
    name=$1
    srcInfo=$2
    text=$3
    temperatureUrl=$4

    _ftp_username=$(echo $5 | cut -d " " -f 1)
    _ftp_password=$(echo $5 | cut -d " " -f 2)
    suffix=$(echo $5 | cut -d " " -f 3)


    src=${wview_html_dir}/${webcam_prefix}_${name}.jpg
    src_small=$(echo ${src} | sed "s/${webcam_prefix}/${webcam_small_prefix}/g")

    if ! [[ -e ${src} ]] && ! [[ -e ${src_small} ]]; then
        echo "srcs do not exists...nothing to do"
        return
    fi

    echo "FTP upload for ${src} ${src_small}..." >> ${log_dest}

    # vvv FTP commands starts here vvv
    ftp -n -v -p ${cml_ftp_server} >> ${cml_ftp_log_file} << EOF
user ${_ftp_username} ${_ftp_password}
binary
cd ${cml_ftp_upload_folder}
put ${src} ${webcam_prefix}${suffix}.jpg
put ${src_small} ${webcam_small_prefix}${suffix}.jpg
quit
EOF
# ^^^ FTP commands ends here ^^^

    if [[ $? != 0 ]]
    then
      echo "Failed FTP upload for ${src}!"
      exit $?
    fi

    rm ${src} ${src_small}

    echo "Done" >> ${log_dest}

}

if [ ${cml_ftp_log_info} == "1" ]
then
    log_dest=/dev/stdout
else
    log_dest=/dev/null
fi

# Reset ftp log file
rm -f ${cml_ftp_log_file}

ftpUpload "${fiobbioCfg[@]}"
ftpUpload "${mismaCfg[@]}"
ftpUpload "${mismaPanoCfg[@]}"

exit 0

