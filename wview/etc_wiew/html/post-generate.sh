######################################
# post-generate.sh :: CML VERSION :: #
######################################

#!/bin/sh

# Account FTP per upload su server CML
############################################

CML_ftp_enabled=1

CML_usr="fiobbio"
CML_pwd="***REMOVED***"

# Verifica che i contenuti generati siano cambiati dall'ultima chiamata dello script
########################################################################################

updated=1
if [ -e /var/lib/wview/img/tempday_last.png ]; then
 if [ "$(cmp /var/lib/wview/img/tempday.png /var/lib/wview/img/tempday_last.png)" == "" ]; then
  updated=0
 fi
fi

# Procedi all'upload FTP

if [ $updated -eq 1 ]; then
	
	cp /var/lib/wview/img/tempday.png /var/lib/wview/img/tempday_last.png
	
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
		
		echo "cd private" > /etc/wview/ftp_plus_noaa.list
		if [ $giorno -eq 1 ]; then
			echo "put /var/lib/wview/img/NOAA/NOAA-$pr_anno-$pr_mese.txt NOAA-$pr_anno-$pr_mese.txt" >> /etc/wview/ftp_plus_noaa.list
			if [ $pr_anno -le $anno ]; then
				echo "put /var/lib/wview/img/NOAA/NOAA-$pr_anno.txt NOAA-$pr_anno.txt" >> /etc/wview/ftp_plus_noaa.list
			fi
		else
			echo "put /var/lib/wview/img/NOAA/NOAA-$anno-$mese.txt NOAA-$anno-$mese.txt" >> /etc/wview/ftp_plus_noaa.list
		fi
		echo "put /var/lib/wview/img/NOAA/NOAA-$anno.txt NOAA-$anno.txt" >> /etc/wview/ftp_plus_noaa.list
		echo "cd .." >> /etc/wview/ftp_plus_noaa.list
		
		cat /etc/wview/ftp.list >> /etc/wview/ftp_plus_noaa.list
		
		if [ $CML_ftp_enabled -eq 1 ]; then
			cat /etc/wview/ftp_plus_noaa.list | /usr/bin/ftp -iVT put,20000 ftp://$CML_usr:$CML_pwd@ftp.centrometeolombardo.com
		fi

	else
	
		if [ $CML_ftp_enabled -eq 1 ]; then
			cat /etc/wview/ftp.list | /usr/bin/ftp -iVT put,20000 ftp://$CML_usr:$CML_pwd@ftp.centrometeolombardo.com
		fi

	fi
	
fi

exit 0
