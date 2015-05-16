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

	if [ "${pix}" == "${misma_webcam_px_nowm_name}" ] 
	then
		last_webcam_px=$(ls -rt ${ftp_upload_dir}/webcampx* | tail -n 1) 
	else
		last_webcam_px=$(ls -rt ${ftp_upload_dir}/2* | tail -n 1) 
	fi
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

