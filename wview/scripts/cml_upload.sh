#!/bin/sh

# Account FTP per upload su server CML
###############################################################################

CML_ftp_enabled=1

. ../../common_variables.sh

noasListFile="${wview_html_dir}"/ftp_plus_noaa.list

. /etc/cml_ftp_login_data.sh

declare -r ftpUrl="ftp.centrometeolombardo.com"
#ftpPort=20000

declare -r ftpBaseCmds="ftp_commands.txt"
declare -r ftpSendCmds="/tmp/cml_ftp_commands.txt"

###############################################################################

if ! [ ${CML_ftp_enabled} -eq 1 ]; then
    echo "Ftp is disabled..exiting"
    exit 0
fi

if ! true && [ -e "${wview_html_dir}"/tempday_last.png ]; then
 cmp -s "${wview_html_dir}"/tempday.png "${wview_html_dir}"/tempday_last.png
 if [ $? -eq 0 ]; then
    echo "Content has not changed...exiting"
    exit 0
 else
    cp "${wview_html_dir}"/tempday.png "${wview_html_dir}"/tempday_last.png
 fi
fi

echo "FTP upload now..."

anno=`date +"%Y"`
mese=`date +"%m"`
giorno=`date +"%d"`
ore=`date +"%H"`
minuti=`date +"%M"`


rm -f ${ftpSendCmds}
echo "user ${cml_ftp_user_fiobbio} ${cml_ftp_pwd_fiobbio}" >> ${ftpSendCmds}
cat ${ftpBaseCmds} >> ${ftpSendCmds}

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

    echo "cd private" >> ${ftpSendCmds}

    if [ $giorno -eq 1 ]; then
      echo "put "${wview_html_dir}"/NOAA/NOAA-$pr_anno-$pr_mese.txt NOAA-$pr_anno-$pr_mese.txt" >> ${ftpSendCmds}
      if [ $pr_anno -le $anno ]; then
        echo "put "${wview_html_dir}"/NOAA/NOAA-$pr_anno.txt NOAA-$pr_anno.txt" >> ${ftpSendCmds}
      fi
    else
      echo "put "${wview_html_dir}"/NOAA/NOAA-$anno-$mese.txt NOAA-$anno-$mese.txt" >> ${ftpSendCmds}
    fi
    echo "put "${wview_html_dir}"/NOAA/NOAA-$anno.txt NOAA-$anno.txt" >> ${ftpSendCmds}
    echo "cd .." >> ${ftpSendCmds}

else
    echo "Normal ftp upload"
fi

echo "quit" >> ${ftpSendCmds}

/usr/bin/ftp \
    -d -n -v -p -i ${ftpUrl} ${ftpPort} < ${ftpSendCmds}
