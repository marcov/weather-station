#/bin/sh                                      

cd /home/pi/weather_station/webcam/scripts || exit $? 

echo "Executing copy ftp 2 www..."            
./copy_ftp_2_www.sh && echo "OK!"|| echo "Failed!"                                           

echo "Executing add watermark..."             
./add_watermark.sh && echo "OK!" || echo "Failed!"                                           

echo "Uploading 2 cml ftp..."
./upload_2_cml_ftp.sh && echo "OK!" || echor "Failed!"

cd -                                          

exit 0               
