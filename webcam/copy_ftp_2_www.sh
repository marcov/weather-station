#!/bin/sh
#
# copy from ftp upload dir to weather station www data
#

. ../common_variables.sh
. /etc/cml_ftp_login_data.sh

#
# NO NEED TO EDIT BELOW THIS!
#

for pix in ${wview_webcam_px_nowm_name} ${misma_webcam_px_nowm_name}
do
	echo "Locating last webcam pix..."

	if [ "${pix}" == "${misma_webcam_px_nowm_name}" ] 
	then
        _lookup_path=${misma_ftp_upload_dir}
        _file_pattern="*jpg"
        _ftp_username=${cml_ftp_user_misma}
        _ftp_password=${cml_ftp_pwd_misma}
	else
        _lookup_path=${ftp_upload_dir}
        _file_pattern="*-alarm.jpg"
        _ftp_username=${cml_ftp_user_fiobbio}
        _ftp_password=${cml_ftp_pwd_fiobbio}
	fi
        last_webcam_px=$(find ${_lookup_path} -type f -name "${_file_pattern}" | sort | tail -n 1) 

	echo "Checking for existence of: ${last_webcam_px}"
	[ -e "${last_webcam_px}" ] || exit $?
	echo "Detected last webcam px is: ${last_webcam_px}"
	echo "Copying and chmoding pix..."
	/bin/cp ${last_webcam_px} ${wview_html_dir}/${pix} || exit $?
	chmod +rw ${wview_html_dir}/${pix} || exit $?
	echo "Done"

    echo "Uploading image to CML..."
    ftp -n -v ${cml_ftp_server} >> /tmp/ftp.log < EOF
    user ${_ftp_username} ${_ftp_pwd}
    cd ${cml_ftp_upload_folder}
    put ${wview_html_dir}/${pix}
    EOF
done

echo "All is good!"

exit 0

