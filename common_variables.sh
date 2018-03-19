#
# Common variables. Edit variables as needed
#
. /etc/cml_ftp_login_data.sh
. /etc/webcam_login_data.sh

ftp_upload_dir=/srv/ftp/upload
wview_html_dir=/var/www/weather

fiobbioTemperature=$(grep outsideTemp ${wview_html_dir}/realtime.json | sed -E "s/.+\"([0-9]+.[0-9]+)\".+/\1/g")
mismaTemperature=$(curl http://localhost/misma/realtime.json | grep outsideTemp | sed -E "s/.+\"([-]?[0-9]+\.[0-9]+)\".+/\1/g")

misma_pic_name="snap.jpg"
misma_webcam_url=192.168.1.205:8083/tmpfs/${misma_pic_name}
misma_pano_name="panorama.jpg"
#
#
# CML FTP config (note: login credentials are not here :P)
cml_ftp_log_file=/var/log/cml_ftp.log
cml_ftp_server=ftp.centrometeolombardo.com
cml_ftp_upload_folder=public
# Set to 1 to log ftp upload information to stdout
cml_ftp_log_info=1


webcam_prefix="webcam"
webcam_raw_prefix="${webcam_prefix}_raw"
webcam_small_prefix="${webcam_prefix}_small"


#
# cfg format:
#
# name=$1
# src=$2
# pattern=$3
# text=$4
# ftpuser=$5
# ftppass=$6
# temperature=$7

fiobbioCfg=( "fiobbio" \
             ${ftp_upload_dir} \
             "*-alarm.jpg" \
             "Fiobbio_di_Albino" \
             ${cml_ftp_user_fiobbio} \
             ${cml_ftp_pwd_fiobbio}  \
             "${fiobbioTemperature}" )

mismaCfg=( "misma" \
           ${ftp_upload_dir}/misma \
           ${misma_pic_name} \
           "Monte_Misma_(Fiobbio)"
           ${cml_ftp_user_misma} \
           ${cml_ftp_pwd_misma} \
           "${mismaTemperature}" )


mismaPanoCfg=( "mismapano" \
           "${ftp_upload_dir}/misma" \
           ${misma_pano_name} \
           "Monte_Misma_360"
           ${cml_ftp_user_misma} \
           ${cml_ftp_pwd_misma} \
           "${mismaTemperature}" )


