#!/bin/sh

. ../common_variables.sh

cd ${wview_html_dir}
 
ORA=`date '+ %-H'`
MIN=`date '+ %-M'`
let ORA=ORA*100
TEMPO=$[$ORA+$MIN]
if [ $TEMPO -eq 0000 ] 
then
   rm wview.txt
fi

if [ $TEMPO -ge 0008 ] && [ $TEMPO -le 2359 ]
   then
   cat wview.htm >> wview.txt
fi

cd -

exit 0
