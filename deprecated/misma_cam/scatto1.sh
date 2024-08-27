#!/bin/sh

SCRIPT=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPT`

dn=$(php ${SCRIPTPATH}/dn.php)

currdate=$(date +%Y%m%d_%H%M%S)
rasp_webcam_px_name="webcampx_${currdate}.jpg"
rasp_webcam_px="/var/www/${rasp_webcam_px_name}"
rasp_webcam_px_remote=${rasp_webcam_px_name}
rasp_parameters_common="-w 800 -h 600 -o ${rasp_webcam_px} -v"
rasp_parameters_day="-sa 50 -sh 100 -ev 55 -ex auto -awb fluorescent"
rasp_parameters_night="-sa 0 -sh 50 -ISO 400 -ev 50 -awb fluorescent -awbg 1,1 -ss 6000000 -t 60000"

rasp_parameters_full=${rasp_parameters_common}

if [ "$dn" = "1" ]
then
	echo "Switching to day mode"
	rasp_parameters_full="${rasp_parameters_full} ${rasp_parameters_day}"
elif [ "$dn" = "2" ]
then
	echo "Switching to night mode"
	rasp_parameters_full="${rasp_parameters_full} ${rasp_parameters_night}"
else
	echo "Invalid mode detected: $dn "
	exit 1
fi

echo "Running raspistill with parameters: ${rasp_parameters_full}"
raspistill ${rasp_parameters_full} || exit $?
chmod +r ${rasp_webcam_px}

echo "Copying webcam px via ftp..."
ftp -in -u "ftp://ftp:ftp@192.168.1.200/upload/${rasp_webcam_px_remote}" ${rasp_webcam_px} || exit $?
exit 0
