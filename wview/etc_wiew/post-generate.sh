#/bin/sh                                      

cd /home/pi/weather_station/wview/scripts || exit $?                                         

echo "Generating wview txt..."
./generate_wview_txt.sh && echo "OK!" || echo "Failed!"

echo "Executing copy ftp 2 www..."            
./cml_upload.sh && echo "OK"|| echo "Failed"  



cd -                                          

exit 0                       
