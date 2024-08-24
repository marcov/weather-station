#!/bin/bash
#
# upload webcam images from www data to cml ftp
#
set -euo pipefail

declare scriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source "${scriptDir}"/../config.sh
source "${scriptDir}"/../../common_variables.sh

#
# NO NEED TO EDIT BELOW THIS!
#

ftpUpload() {
    local _ftp_username="$1"
    local _ftp_password="$2"
    local -n cfgRef="$3"

    src="${hostWebcamDir}/${webcam_prefix}_${cfgRef[name]}.jpg"
    src_small="${hostWebcamDir}/${webcam_small_prefix}_${cfgRef[name]}.jpg"

    if ! [[ -e ${src} ]] && ! [[ -e ${src_small} ]]; then
        echo "WARN: FTP src ${src} does not exist...nothing to do"
        return
    fi

    echo "INFO: FTP upload for ${src} ${src_small}..." >> ${log_dest}

    # vvv FTP commands starts here vvv
    ftp -n -v -p ${cml_ftp_server} >> ${cml_ftp_log_file} << EOF
user ${_ftp_username} ${_ftp_password}
binary
cd ${cml_ftp_upload_folder}
put ${src} ${webcam_prefix}${cfgRef[suffix]}.jpg
put ${src_small} ${webcam_small_prefix}${cfgRef[suffix]}.jpg
quit
EOF
# ^^^ FTP commands ends here ^^^

    if [[ $? != 0 ]]
    then
      echo "ERR: Failed FTP upload for ${src}!"
      exit $?
    fi

    #
    # Keep for local webserver
    #
    # rm ${src} ${src_small}

    echo "INFO: FTP done" >> ${log_dest}
}

if [ ${cml_ftp_log_info} == "1" ]
then
    log_dest=/dev/stdout
else
    log_dest=/dev/null
fi

# Reset ftp log file
rm -f ${cml_ftp_log_file}

ftpUpload ${cml_ftp_user_fiobbio} ${cml_ftp_pwd_fiobbio} fiobbioCfg
ftpUpload ${cml_ftp_user_misma} ${cml_ftp_pwd_misma} mismaCfg
ftpUpload ${cml_ftp_user_misma} ${cml_ftp_pwd_misma} mismaPanoCfg

exit 0

