#!/bin/sh

#
#  Attention! Do not edit this script unless u know what u are doing!
#  This script is deleting folders recursively and may accidentaly delete things that shouldnt
#

. ../config.sh

CURDATE=$(/bin/date +%Y%m%d)

echo "Checking for empty path..."
[ "${ftp_upload_dir}" != "" ] || exit $?
echo "OK"

echo "Checking for root path..."
[ "${ftp_upload_dir}" != "/" ] || exit $?
echo "OK"

echo "Checking for existing FTP directory..."
[ -e "${ftp_upload_dir}" ] || exit $?
echo "OK"

echo "Sanity check ok...!"

for i in $(find $ftp_upload_dir -mindepth 1 -maxdepth 4 -type f -name "*.jpg" | grep -v $CURDATE)
do
    echo "Removing $i..."
    /bin/rm -rf $i || exit $?
done

exit 0
