#/bin/sh

cd /home/pi/weather_station/webcam || exit $?

echo "Executing copy ftp 2 www..."
./copy_ftp_2_www.sh && echo "OK!"|| echo "Failed!" 


echo "Executing add watermark..."
./add_watermark.sh && echo "OK!" || echo "Failed!" 

echo "Executing wview.txt generate..." 
../wview/scripts/generate_wview_txt.sh && echo "OK!" || echo "Failed!"

cd -

exit 0