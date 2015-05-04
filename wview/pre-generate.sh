#/bin/sh

cd /home/pi/weather_station/webcam || exit $?
./copy_ftp_2_www.sh || exit $?
./add_watermark.sh  || exit $?
cd -

exit 0
