#!/bin/sh
#
# copy from ftp upload dir to weather station www data
#

. ../common_variables.sh

#
# NO NEED TO EDIT BELOW THIS!
#

for pix in ${wview_webcam_px_nowm_name} ${misma_webcam_px_nowm_name}
do
	
	echo "Locating last webcam pix..."

	if [ "${pix}" == "${misma_webcam_px_nowm_name}" ] 
	then
                _lookup_path=${misma_ftp_upload_dir}
	else
                _lookup_path=${ftp_upload_dir}
	fi
	
        last_webcam_px=$(find ${_lookup_path} -type f -name "*jpg" | tail -n 1) 

	echo "Checking for existence of: ${last_webcam_px}"
	[ -e "${last_webcam_px}" ] || exit $?
	echo "Detected last webcam px is: ${last_webcam_px}"
	echo "Copying and chmoding pix..."
	/bin/cp ${last_webcam_px} \
		${wview_html_dir}/${pix} || exit $?
	chmod +rw \
	${wview_html_dir}/${pix} || exit $?
	echo "Done"
done

echo "All is good!"

exit 0

