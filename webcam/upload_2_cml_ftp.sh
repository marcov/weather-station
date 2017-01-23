#!/bin/sh
#
# upload webcam images from www data to cml ftp
#

. ../common_variables.sh
. /etc/cml_ftp_login_data.sh

#
# NO NEED TO EDIT BELOW THIS!
#

rm ${cml_ftp_log_file}

for src in fiobbio misma
do
	if [ "${src}" == "fiobbio" ] 
	then
        _ftp_username=${cml_ftp_user_fiobbio}
        _ftp_password=${cml_ftp_pwd_fiobbio}
        _img_full=${wview_webcam_px_name}
        _img_small=${wview_webcam_small_px_name}
	else
        _ftp_username=${cml_ftp_user_misma}
        _ftp_password=${cml_ftp_pwd_misma}
        _img_full=${misma_webcam_px_name}
        _img_small=${misma_webcam_small_px_name}
	fi

    echo "FTP upload for ${src}..."
    ftp -n -v ${cml_ftp_server} >> ${cml_ftp_log_file} << EOF
user ${_ftp_username} ${_ftp_password}
binary
cd ${cml_ftp_upload_folder}
put ${wview_html_dir}/${_img_full} ${_img_full}
put ${wview_html_dir}/${_img_small} ${_img_small}
quit
EOF
    echo "Done"

done
