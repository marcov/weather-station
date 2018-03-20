#/bin/sh

cd /home/pi/weather_station/webcam/scripts || exit $?

echo "Executing get raw image..."
./get_raw_image.sh && echo "OK!"|| echo "Failed!"

echo "Executing add watermark..."
./add_watermark.sh && echo "OK!" || echo "Failed!"

echo "Uploading 2 cml ftp..."
./upload_2_cml_ftp.sh && echo "OK!" || echo "Failed!"

cd -

exit 0
