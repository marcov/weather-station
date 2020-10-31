#!/bin/bash
#
# Start all the weather containers
#
set -euo pipefail

. ../common_variables.sh

declare -r repoDir="/home/pi/weather-station"
declare -r dataDir="/home/pi/wview-data"
declare -r scriptStarted="/tmp/run-sh-started"
declare -r scriptCompleted="/tmp/run-sh-completed"
declare removeEphemeral=
declare interactive=

rm -f "$scriptCompleted"
touch "$scriptStarted"

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

[ "${1:-}" = "-i" ] && { echo "INFO: interactive mode"; interactive=1; }

#
# Return 0 -> container start is skipped
# Return 1 -> container start is run
#
stop_start () {
    local ctrName="$1"

    [ -n "${interactive:-}" ] || return 1

    echo "Stop/start $ctrName? [y/n]"
    local answer=
    read -e answer

    [ "${answer:-}" != y ] && return 0

    docker stop ${ctrName}

    return 1
}


set -x

#
# Stop everything
#
[ -n "${interactive:-}" ] || docker stop `docker ps -a -q` 2>/dev/null || { echo "No containers to stop"; }

#
# NOTE: --privileged for /dev/ttyUSB0 access
#
stop_start ser2net || docker run \
    -d --rm \
    --privileged \
    \
    -v ${repoDir}/ser2net/ser2net.conf:/etc/ser2net.conf \
    --device=/dev/ttyUSB0 \
    \
    --name=ser2net \
    \
    pullme/ser2net:wview

stop_start wview || docker run \
    -d --rm \
    \
    --net=container:ser2net \
    \
    -v ${dataDir}/archive:${WVIEW_DATA_DIR}/archive \
    -v "${wviewEphemeralImg}":${WVIEW_DATA_DIR}/img \
    -v ${repoDir}/wview/fs/${WVIEW_CONF_DIR}:${WVIEW_CONF_DIR} \
    -v ${dataDir}/conf/wview-conf.sdb:${WVIEW_CONF_DIR}/wview-conf.sdb \
    \
    -v /home/pi/secrets/cml_ftp_login_data.sh:/etc/cml_ftp_login_data.sh:ro \
    -v /home/pi/secrets/webcam_login_data.sh:/etc/webcam_login_data.sh:ro \
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

stop_start nginx || docker run \
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

#stop_start crond || docker run \
#    -d --rm \
#    \
#    -v ${repoDir}/host/crontab:/var/spool/cron/crontabs/root \
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


#
# Run as daily cron script. Directly passing a crontab file does not work :-/
#
# Option not working: -v ${repoDir}/rclone/crontab:/var/spool/cron/crontabs/root
stop_start rclone || docker run \
    -d --rm \
    \
    -v ${dataDir}:/wview-data \
    -v /home/pi/secrets/rclone.conf:/config/rclone/rclone.conf \
    -v ${repoDir}/rclone/backup:/etc/periodic/daily/backup \
    \
    -v /dev/log:/dev/log \
    -v /etc/timezone:/etc/timezone:ro \
    -v /etc/localtime:/etc/localtime:ro \
    \
    --name=rclone \
    \
    pullme/rclone:latest

################################################################################
stop_start nginx-exporter || docker run \
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


stop_start node-exporter || docker run \
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
