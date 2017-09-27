#/bin/sh

cd /home/pi/weather_station/wview/scripts || exit $?

echo "Executing copy ftp 2 www..."
./cml_upload.sh && echo "OK!"|| echo "Failed!" 

cd -

exit 0
