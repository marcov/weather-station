#!/bin/sh
#
# upload webcam images from www data to cml ftp
#

. ../../common_variables.sh
. /etc/cml_ftp_login_data.sh

#
# NO NEED TO EDIT BELOW THIS!
#

if [ ${cml_ftp_log_info} == "1" ]
then
    log_dest=/dev/stdout
else
    log_dest=/dev/null
fi


# Reset ftp log file
echo "" > ${cml_ftp_log_file}

for src in fiobbio misma
do
	if [ "${src}" == "fiobbio" ] 
	then
        _ftp_username=${cml_ftp_user_fiobbio}
        _ftp_password=${cml_ftp_pwd_fiobbio}
        _img_full=${fiobbio_webcam_img_name}
        _img_small=${fiobbio_webcam_img_small_name}
	else
        _ftp_username=${cml_ftp_user_misma}
        _ftp_password=${cml_ftp_pwd_misma}
        _img_full=${misma_webcam_px_name}
        _img_small=${misma_webcam_small_px_name}
	fi

    echo "FTP upload for ${src}..." >> ${log_dest}
    
    # vvv FTP commands starts here vvv
    ftp -n -v ${cml_ftp_server} >> ${cml_ftp_log_file} << EOF
user ${_ftp_username} ${_ftp_password}
binary
cd ${cml_ftp_upload_folder}
put ${wview_html_dir}/${_img_full} ${webcam_img_name}
put ${wview_html_dir}/${_img_small} ${webcam_img_small_name}
quit
EOF
# ^^^ FTP commands ends here ^^^
    
    if [[ $? != 0 ]]
    then
      echo "Failed FTP upload for ${src}!"
      exit $?
    fi
    echo "Done" >> ${log_dest}
done

