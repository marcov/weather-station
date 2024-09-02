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

httpServerHostname=nginx

declare -r -A fiobbioCfg=( \
    [name]="fiobbio" \
    [url]="http http://192.168.1.178/cgi-bin/snapshot.cgi?stream=0" \
    [watermark]="Fiobbio" \
    [tsource]="http://${httpServerHostname}/fiobbio1/realtime.json" \
    [size]="800x600" \
    [retries]=1 \
    [suffix]="" \
)

declare -r -A mismaCfg=( \
    [name]="misma" \
    [url]="http http://192.168.1.205:8083/tmpfs/${misma_pic_name}" \
    [watermark]="Mt_Misma_(Fiobbio)" \
    [tsource]="http://${httpServerHostname}/misma/realtime.json" \
    [size]="800x600" \
    [retries]=6 \
    [suffix]="" \
)

# FIXME: panogen dir is unknown !?!?
declare -r -A mismaPanoCfg=( \
    [name]="mismapano" \
    [url]="local /tmp/panogen/out/panorama.jpg" \
    [watermark]="Mt_Misma_360" \
    [tsource]="http://${httpServerHostname}/misma/realtime.json" \
    [size]="2048x1536" \
    [retries]=0 \
    [suffix]="_pano" \
)
