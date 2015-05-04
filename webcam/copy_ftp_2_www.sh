#!/bin/sh
#
# copy from ftp upload dir to weather station www data
#

. common_variables.sh

#
# NO NEED TO EDIT BELOW THIS!
#
last_webcam_px=$(ls -rt ${ftp_upload_dir} | tail -n 1) 
[ -e "${ftp_upload_dir}/${last_webcam_px}" ] || exit $?
echo "Detected last webcam px is: ${last_webcam_px}"
/bin/cp ${ftp_upload_dir}/${last_webcam_px} ${wview_html_dir}/${wview_webcam_px_name} || exit $?
chmod +rw ${wview_html_dir}/${wview_webcam_px_nowm_name} | tail -n 1 || exit $?
echo "All is good!"
exit 0

