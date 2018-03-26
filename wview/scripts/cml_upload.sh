#!/bin/sh

# Account FTP per upload su server CML
###############################################################################

CML_ftp_enabled=1

noasListFile=/var/lib/wview/img/ftp_plus_noaa.list

. /etc/cml_ftp_login_data.sh

ftpUrl="ftp.centrometeolombardo.com"
#ftpPort=20000

ftpCommands="/etc/wview/ftp.list"

tmpFile="/tmp/cml_ftp_commands.txt"

###############################################################################

if ! [ ${CML_ftp_enabled} -eq 1 ]; then
    echo "Ftp is disabled..exiting"
    exit 0
fi


if ! true && [ -e /var/lib/wview/img/tempday_last.png ]; then
 cmp -s /var/lib/wview/img/tempday.png /var/lib/wview/img/tempday_last.png
 if [ $? -eq 0 ]; then
    echo "Content has not changed...exiting"
    exit 0
 else
    cp /var/lib/wview/img/tempday.png /var/lib/wview/img/tempday_last.png
 fi
fi

# Procedi all'upload FTP

anno=`date +"%Y"`
mese=`date +"%m"`
giorno=`date +"%d"`
ore=`date +"%H"`
minuti=`date +"%M"`


rm ${tmpFile}
echo "USER $cml_ftp_user_fiobbio" >> ${tmpFile}
echo "PASS $cml_ftp_pwd_fiobbio" >> ${tmpFile}
cat ${ftpCommands} >> ${tmpFile}

if [ $minuti -gt 10 -a $minuti -le 15 ]; then
    if [ $mese -eq 1 ]; then
      pr_mese="12"
      pr_anno=`expr $anno - 1`
    else
      pr_mese=`expr $mese - 1`
      if [ $pr_mese -lt 10 ]; then
       pr_mese="0$pr_mese"
      fi
      pr_anno=$anno;
    fi

    echo "NOAA Archive Upload"

    echo "cd private" >> ${tmpFile}

    if [ $giorno -eq 1 ]; then
      echo "put /var/lib/wview/img/NOAA/NOAA-$pr_anno-$pr_mese.txt NOAA-$pr_anno-$pr_mese.txt" >> ${tmpFile}
      if [ $pr_anno -le $anno ]; then
        echo "put /var/lib/wview/img/NOAA/NOAA-$pr_anno.txt NOAA-$pr_anno.txt" >> ${tmpFile}
      fi
    else
      echo "put /var/lib/wview/img/NOAA/NOAA-$anno-$mese.txt NOAA-$anno-$mese.txt" >> ${tmpFile}
    fi
    echo "put /var/lib/wview/img/NOAA/NOAA-$anno.txt NOAA-$anno.txt" >> ${tmpFile}
    echo "cd .." >> ${tmpFile}

else
    echo "Normal ftp upload"
fi

/usr/bin/ftp -n -v -p -i ${ftpUrl} ${ftpPort} ${tmpFile}


exit 0
