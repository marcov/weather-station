#/bin/sh
#
# Add any post template generation processing or utilities here. Keep in mind this 
# script runs in the htmlgend process's context so don't add anything that is overly
# time constrained.


#cd /var/lib/wview/img
#ORA=`date '+ %-H'`
#MIN=`date '+ %-M'`
#let ORA=ORA*100
#TEMPO=$[$ORA+$MIN]
#if [ $TEMPO -eq 0000 ] 
#   then
#   rm wview.txt
#fi
#if [ $TEMPO -ge 0008 ] && [ $TEMPO -le 2359 ]
#   then
#   cat wview.htm >> wview.txt
#fi

#Created a cron rule to remove the file
# Add any pre template generation processing or utilities here. Keep in mind this 
# script runs in the htmlgend process's context so don't add anything that is overly
# time constrained.

#
# copy from ftp upload dir to weather station www data
#
ftp_upload_dir=/srv/ftp/upload
wview_html_dir=/var/www/weather
wview_webcam_px_name=webcam.jpg
# Copy webcam image to the http-server served path
#/bin/cp
 $IMAGE_FILE /var/lib/wview/img/webcam_1.jpg && /bin/chmod +r /var/lib/wview/img/webcam_1.jpg


OUTIMAGE=webcam.jpg

TEXT="Fiobbio di Albino, `date +\"%d-%m-%Y  %T (%Z)\"`"





#
#
#
last_webcam_px=$(ls -rt ${ftp_upload_dir} | tail -n 1) 
[ -e "${ftp_upload_dir}/${last_webcam_px}" ] || exit $?
echo "Detected last webcam px is: ${last_webcam_px}"
/bin/cp ${ftp_upload_dir}/${last_webcam_px} ${wview_html_dir}/${wview_webcam_px_name} || exit $?
chmod +rw ${wview_html_dir}/${wview_webcam_px_name} | tail -n 1 || exit $?
convert -pointsize 12 -fill white -undercolor black -gravity northwest -draw "text 0,0 'Data: $(date -R)' " /srv/ftp/upload /var/lib/wview/last_webcam_px.jpg
echo "All is good!"
exit 0

