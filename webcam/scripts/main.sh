#!/bin/bash
#
set -euo pipefail
set -x

cd /home/pi/weather_station/webcam/scripts || exit $?

echo "INFO: get raw image..."
./get_raw_image.sh || { echo "Failed to get raw image: \"$?\""; }

echo "INFO: add watermark..."
./add_watermark.sh || { echo "Failed to add watermark: \"$?\""; }

echo "INFO: uploading 2 CML FTP..."
./upload_2_cml_ftp.sh || { echo "Failed to upload 2 CML FTP: \"$?\""; }

cd -

exit 0
