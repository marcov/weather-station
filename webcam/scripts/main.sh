#!/bin/bash
#
set -euo pipefail

cd /home/pi/weather_station/webcam/scripts || exit $?

echo "INFO: get raw image..."
./get_raw_image.sh && echo "OK!"|| echo "Failed!"

echo "INFO: add watermark..."
./add_watermark.sh && echo "OK!" || echo "Failed!"

echo "INFO: uploading 2 cml ftp..."
./upload_2_cml_ftp.sh && echo "OK!" || echo "Failed!"

cd -

exit 0
