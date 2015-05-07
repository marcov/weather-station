#/bin/sh

cd /home/pi/weather_station/webcam || exit $?

echo "Executing copy ftp 2 www..."
./copy_ftp_2_www.sh || exit $?
echo "OK!"

echo "Executing add watermark..."
./add_watermark.sh  || exit $?
echo "OK!"

echo "Executing wview.txt generate..." 
../wview/generate_wview_txt.sh || exit $?
echo "OK"

cd -

exit 0
