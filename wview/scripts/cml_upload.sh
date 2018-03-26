#!/bin/sh

# Account FTP per upload su server CML
############################################
CML_ftp_enabled=1

listFile=/var/lib/wview/img/ftp_plus_noaa.list

. /etc/cml_ftp_login_data.sh

ftpUrl="ftp://$cml_ftp_user_fiobbio:$cml_ftp_pwd_fiobbio@ftp.centrometeolombardo.com"
ftpPort=20000

# Verifica che i contenuti generati siano cambiati dall'ultima chiamata dello script
########################################################################################

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

    # NOAA Archive Upload

    echo "cd private" > ${listFile}

    if [ $giorno -eq 1 ]; then
      echo "put /var/lib/wview/img/NOAA/NOAA-$pr_anno-$pr_mese.txt NOAA-$pr_anno-$pr_mese.txt" >> ${listFile}
      if [ $pr_anno -le $anno ]; then
        echo "put /var/lib/wview/img/NOAA/NOAA-$pr_anno.txt NOAA-$pr_anno.txt" >> ${listFile}
      fi
    else
      echo "put /var/lib/wview/img/NOAA/NOAA-$anno-$mese.txt NOAA-$anno-$mese.txt" >> ${listFile}
    fi
    echo "put /var/lib/wview/img/NOAA/NOAA-$anno.txt NOAA-$anno.txt" >> ${listFile}
    echo "cd .." >> ${listFile}

    if [ -e /etc/wview/ftp.list ]; then
      cat /etc/wview/ftp.list >> ${listFile}
    fi

    echo "NOAA Archive Upload"
    /usr/bin/ftp -n -v -p -i \
     ${ftpUrl} ${ftpPort} \
     ${listFile}

else

  echo "Normal ftp upload"
  if [ -e /etc/wview/ftp.list ]; then
    echo /usr/bin/ftp -n -v -p -i \
      ${ftpUrl} ${ftpPort} \
      /etc/wview/ftp.list
  fi

fi


exit 0
