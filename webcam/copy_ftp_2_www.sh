#!/bin/sh
#
# copy from ftp upload dir to weather station www data
#

. ../common_variables.sh
. /etc/cml_ftp_login_data.sh

#
# NO NEED TO EDIT BELOW THIS!
#

for pix in ${fiobbio_webcam_img_nowm_name} ${misma_webcam_px_nowm_name}
do
	echo "Locating last webcam pix..."

	if [ "${pix}" == "${misma_webcam_px_nowm_name}" ] 
	then
        _lookup_path=${misma_ftp_upload_dir}

        _file_pattern="snap.jpg"
        rm -f ${misma_ftp_upload_dir}/${_file_pattern}
        curl --basic -u admin:misma 192.168.1.205:8083/tmpfs/snap.jpg -v -o ${misma_ftp_upload_dir}/${_file_pattern}

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
done    
echo "All is good!"

exit 0

