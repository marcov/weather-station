#!/bin/bash

set -euo pipefail

. ../common_variables.sh

declare -r repoDir="/home/pi/weather-station"
declare -r dataDir="/home/pi/wview-data"
declare -r scriptStarted="/tmp/run-sh-started"
declare -r scriptCompleted="/tmp/run-sh-completed"
declare removeEphemeral=

rm -f "$scriptCompleted"
touch "$scriptStarted"

set -x

# Stop everything
docker stop `docker ps -a -q` 2>/dev/null || { echo "No containers to stop"; }

#
# TODO: find a better way to store wview img in a tmpfs shared volume b/w host and containers!
#
if [ -n "${removeEphemeral}" ]; then
    rm -rf "${wviewEphemeralImg}"
fi
# Provision img folder
cp -a "${repoDir}/wview/fs/${WVIEW_CONF_DIR}/html/classic/static" "${wviewEphemeralImg}"
mkdir -p "${wviewEphemeralImg}/NOAA"
mkdir -p "${wviewEphemeralImg}/Archive"

#
# NOTE: --privileged for /dev/ttyUSB0 access
#
docker run \
    -d --rm \
    --privileged \
    \
    -v ${repoDir}/ser2net/ser2net.conf:/etc/ser2net.conf \
    --device=/dev/ttyUSB0 \
    \
    --name=ser2net \
    \
    pullme/ser2net:wview

docker run \
    -d --rm \
    \
    --net=container:ser2net \
    \
    -v ${dataDir}/archive:${WVIEW_DATA_DIR}/archive \
    -v "${wviewEphemeralImg}":${WVIEW_DATA_DIR}/img \
    -v ${repoDir}/wview/fs/${WVIEW_CONF_DIR}:${WVIEW_CONF_DIR} \
    -v ${dataDir}/conf/wview-conf.sdb:${WVIEW_CONF_DIR}/wview-conf.sdb \
    \
    -v /etc/cml_ftp_login_data.sh:/etc/cml_ftp_login_data.sh:ro \
    -v /etc/webcam_login_data.sh:/etc/webcam_login_data.sh:ro \
    \
    -v ${repoDir}/wview/scripts:/weather-station/wview/scripts:ro \
    -v ${repoDir}/common_variables.sh:/weather-station/common_variables.sh:ro \
    \
    -v /dev/log:/dev/log \
    -v /etc/timezone:/etc/timezone:ro \
    -v /etc/localtime:/etc/localtime:ro \
    \
    --name=wview \
    \
    pullme/wview:5.21.7 \
    \
    sh -c "/etc/init.d/wview restart; while true; do sleep 9999; done"

docker run \
    -d --rm \
    \
    --publish 80:80 \
    \
    -v "${wviewEphemeralImg}":${WVIEW_DATA_DIR}/img:ro \
    -v ${repoDir}/http_server/nginx_cfg:/etc/nginx/conf.d/default.conf:ro \
    -v ${repoDir}/wview/html/fiobbio:/weather-station/wview/html/fiobbio:ro \
    \
    -v /dev/log:/dev/log \
    -v /etc/timezone:/etc/timezone:ro \
    -v /etc/localtime:/etc/localtime:ro \
    \
    --name=nginx \
    \
    nginx:latest

#docker run \
#    -d --rm \
#    \
#    -v ${repoDir}/host/crontab:/var/spool/cron/crontabs \
#    \
#    -v /dev/log:/dev/log \
#    -v /etc/timezone:/etc/timezone:ro \
#    -v /etc/localtime:/etc/localtime:ro \
#    \
#    --name=crond \
#    \
#    alpine:latest \
#    \
#    /usr/sbin/crond -f -c /var/spool/cron/crontabs

################################################################################
docker run \
    -d --rm \
    \
    --net=container:nginx \
    \
    \
    --name=nginx-exporter \
    \
    pullme/nginx-prometheus-exporter:raspi3 \
    \
    -nginx.scrape-uri http://127.0.0.1/stub_status


docker run \
    --rm -d \
    \
    -v "/:/host:ro,rslave" \
    \
    --pid=host \
    \
    --net=container:nginx \
    \
    --name=node-exporter \
    \
    quay.io/prometheus/node-exporter \
    \
    --path.rootfs=/host

set +x

touch "$scriptCompleted"
