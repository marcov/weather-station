#!/bin/sh
#
# upload webcam images from www data to cml ftp
#

. ../../common_variables.sh

#
# NO NEED TO EDIT BELOW THIS!
#

function ftpUpload() {

    name=$1
    src=$2
    pattern=$3
    text=$4
    _ftp_username=$5
    _ftp_password=$6

    src=${wview_html_dir}/${webcam_prefix}.jpg
    src_small=$(echo ${src} | sed "s/${webcam_prefix}/${webcam_prefix_small}/g")

    echo "FTP upload for ${src}..." >> ${log_dest}

    # vvv FTP commands starts here vvv
    ftp -n -v ${cml_ftp_server} >> ${cml_ftp_log_file} << EOF
user ${_ftp_username} ${_ftp_password}
binary
cd ${cml_ftp_upload_folder}
put ${src} ${webcam_prefix}.jpg
put ${src_small} ${webcam_small_prefix}.jpg
quit
EOF
# ^^^ FTP commands ends here ^^^

    if [[ $? != 0 ]]
    then
      echo "Failed FTP upload for ${src}!"
      exit $?
    fi
    echo "Done" >> ${log_dest}

}

if [ ${cml_ftp_log_info} == "1" ]
then
    log_dest=/dev/stdout
else
    log_dest=/dev/null
fi

# Reset ftp log file
echo "" > ${cml_ftp_log_file}
ftpUpload "${fiobbioCfg[@]}"
ftpUpload "${mismaCfg[@]}"

