#
# Webcam config
#

ftp_upload_dir="/srv/ftp/upload"

misma_pic_name="snap.jpg"
misma_webcam_url=
misma_pano_name="panorama.jpg"

webcam_prefix="webcam"
webcam_raw_prefix="${webcam_prefix}_raw"
webcam_small_prefix="${webcam_prefix}_small"

httpServerHostname="192.168.1.200"
#
# cfg format:
#
# name=$1
# srcInfo=$2
# text=$3
# temperature=$4
# picture_size=$5
# ftp_suffix=$6

fiobbioCfg=( "fiobbio" \
             "http http://192.168.1.178/cgi-bin/snapshot.cgi?stream=0" \
             "Fiobbio_di_Albino" \
             "http://${httpServerHostname}/realtime.json" \
             "800x600" )


declare -i fiobbioRetries=1
declare -i mismaRetries=6
declare -i panoRetries=0

mismaCfg=( "misma" \
           "http 192.168.1.205:8083/tmpfs/${misma_pic_name}" \
           "Monte_Misma_(Fiobbio)" \
           "http://${httpServerHostname}/misma/realtime.json" \
           "800x600" )

mismaPanoCfg=( "mismapano" \
               "local /home/pi/panogen/out panorama.jpg" \
               "Monte_Misma_360" \
               "http://${httpServerHostname}/misma/realtime.json" \
               "2048x1536" \
               "_pano" )
