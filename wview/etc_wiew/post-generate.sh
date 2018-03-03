#/bin/sh                                      

cd /home/pi/weather_station/wview/scripts || exit $?                                         

#echo "Generating wview txt..."
./generate_wview_txt.sh >/dev/null #&& echo "OK!" || echo "Failed!"

#echo "Executing cml upload..."
./cml_upload.sh >/dev/null #&& echo "OK"|| echo "Failed"  



cd -                                          

exit 0                       
