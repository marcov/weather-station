#!/bin/sh
#
# copy from ftp upload dir to weather station www data
#

. ../common_variables.sh

#
# NO NEED TO EDIT BELOW THIS!
#
last_webcam_px=$(ls -rt ${ftp_upload_dir}/2* | tail -n 1) 
[ -e "${last_webcam_px}" ] || exit $?
echo "Detected last webcam px is: ${last_webcam_px}"
/bin/cp ${last_webcam_px} ${wview_html_dir}/${wview_webcam_px_nowm_name} || exit $?
chmod +rw ${wview_html_dir}/${wview_webcam_px_nowm_name} | tail -n 1 || exit $?
echo "All is good!"

#
# Copy Misma pic
#
last_webcam_px=$(ls -rt ${ftp_upload_dir}/${misma_webcam_px_name} | tail -n 1) 
[ -e "${last_webcam_px}" ] || exit $?
echo "Detected misma webcam px is: ${last_webcam_px}"
/bin/cp ${last_webcam_px} ${wview_html_dir}/${misma_webcam_px_nowm_name} || exit $?
chmod +rw ${wview_html_dir}/${misma_webcam_px_nowm_name} | tail -n 1 || exit $?
echo "All is good!"

exit 0

