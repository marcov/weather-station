#!/bin/bash
#
# Start all the weather containers
#
set -euo pipefail

echo "DISABLED in favor of k8s!"
exit 0

declare scriptDir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

. ${scriptDir}/../common_variables.sh

declare -r scriptStarted="/tmp/run-sh-started"
declare -r scriptCompleted="/tmp/run-sh-completed"
declare -r arch="$(arch)"
declare removeEphemeral=

if [ "`id -u`" != 0 ]; then
    asRoot="/usr/bin/sudo"
fi

${asRoot:-} rm -f "$scriptStarted" "$scriptCompleted"
touch "$scriptStarted"

echo "NOTE: run with the env INTERACTIVE=1 for interactive startup!"
echo "INFO: starting up in 1 seconds"
sleep 1

#
# TODO: find a better way to store wview img in a tmpfs shared volume b/w host and containers!
#
if [ -n "${removeEphemeral}" ]; then
    rm -rf "${hostWviewImgDir}"
fi

# Provision img folder
mkdir -p "${hostWviewImgDir}"

# Provision img folder
cp -a \
    "${hostRepoRoot}/wview/fs/${WVIEW_CONF_DIR}/html/classic/static" \
    "${hostWviewImgDir}/fiobbio"

cp -a \
    "${hostRepoRoot}/wview/fs/${WVIEW_CONF_DIR}/html/classic/static" \
    "${hostWviewImgDir}/misma"

mkdir -p "${hostWviewImgDir}"/{fiobbio,misma}/NOAA
mkdir -p "${hostWviewImgDir}"/{fiobbio,misma}/Archive


[ "${1:-}" = "-i" ] && { echo "INFO: INTERACTIVE mode"; INTERACTIVE=1; }

#
# Return 0 -> container start is skipped
# Return 1 -> container start is run
#
stop_start () {
    set +x
    local ctrName="$1"

    [ -n "${INTERACTIVE:-}" ] || { set -x; return 1; }

    echo -n "Stop/start $ctrName? [y/N] "
    local answer=
    read -e answer

    [ "${answer:-}" != y ] && { set -x; return 0; }

    docker stop ${ctrName}

    set -x
    return 1
}

set -x

#
# Stop everything
#
[ -n "${INTERACTIVE:-}" ] || docker stop `docker ps -a -q` 2>/dev/null || { echo "No containers to stop"; }

#
# NOTE: --privileged for /dev/ttyUSB0 access
#
stop_start ser2net || docker run \
    -d --rm \
    --privileged \
    \
    -v ${hostRepoRoot}/ser2net/ser2net.conf:/etc/ser2net.conf \
    --device=/dev/ttyUSB0 \
    \
    --name=ser2net \
    \
    pullme/"${arch}"-ser2net:wview

################################################################################

set +x
. /home/pi/secrets/cml_ftp_login_data.sh
set -x

stop_start wview-fiobbio || docker run \
    -d --rm \
    \
    --net=container:ser2net \
    \
    -v ${hostWviewDataDir}/fiobbio/archive:${WVIEW_DATA_DIR}/archive \
    -v "${hostWviewImgDir}/fiobbio":${WVIEW_DATA_DIR}/img \
    -v ${hostRepoRoot}/wview/fs/${WVIEW_CONF_DIR}:${WVIEW_CONF_DIR} \
    -v ${hostWviewDataDir}/fiobbio/conf/wview-conf.sdb:${WVIEW_CONF_DIR}/wview-conf.sdb \
    \
    -v ${hostRepoRoot}/wview/scripts:/weather-station/wview/scripts:ro \
    -v ${hostRepoRoot}/common_variables.sh:/weather-station/common_variables.sh:ro \
    \
    -v /dev/log:/dev/log \
    -v /etc/timezone:/etc/timezone:ro \
    -v /etc/localtime:/etc/localtime:ro \
    \
    -e cml_ftp_user="$cml_ftp_user_fiobbio" \
    -e cml_ftp_pwd="$cml_ftp_pwd_fiobbio" \
    \
    --name=wview-fiobbio \
    \
    pullme/"${arch}"-wview:5.21.7 \
    \
    sh -c "/etc/init.d/wview restart; while true; do sleep 9999; done"


stop_start wview-misma || docker run \
    -d --rm \
    \
    --net=container:ser2net \
    \
    -v ${hostWviewDataDir}/misma/archive:${WVIEW_DATA_DIR}/archive \
    -v "${hostWviewImgDir}/misma":${WVIEW_DATA_DIR}/img \
    -v ${hostRepoRoot}/wview/fs/${WVIEW_CONF_DIR}:${WVIEW_CONF_DIR} \
    -v ${hostWviewDataDir}/misma/conf/wview-conf.sdb:${WVIEW_CONF_DIR}/wview-conf.sdb \
    \
    -v ${hostRepoRoot}/wview/scripts:/weather-station/wview/scripts:ro \
    -v ${hostRepoRoot}/common_variables.sh:/weather-station/common_variables.sh:ro \
    \
    -e cml_ftp_user="$cml_ftp_user_misma" \
    -e cml_ftp_pwd="$cml_ftp_pwd_misma" \
    \
    -v /dev/log:/dev/log \
    -v /etc/timezone:/etc/timezone:ro \
    -v /etc/localtime:/etc/localtime:ro \
    \
    --name=wview-misma \
    \
    pullme/"${arch}"-wview:5.21.7 \
    \
    sh -c "/etc/init.d/wview restart; while true; do sleep 9999; done"

################################################################################

# Extra publish options for debug
#    --publish 9000:9000 \
#    --publish 3000:3000 \
#
stop_start nginx || docker run \
    -d --rm \
    \
    --publish 80:80 \
    --publish 443:443 \
    \
    -v ${hostRepoRoot}/http_server/nginx_cfg:/etc/nginx/conf.d/default.conf:ro \
    -v /home/pi/secrets/letsencrypt:/etc/letsencrypt:ro \
    \
    -v "${hostWviewImgDir}/fiobbio":/www/wview-img/fiobbio:ro \
    -v "${hostWviewImgDir}/misma":/www/wview-img/misma:ro \
    -v ${hostWebcamDir}:/www/webcam:ro \
    -v ${hostWebshotDir}:/www/webshot:ro \
    -v ${hostRepoRoot}/wview/html/fiobbio:/weather-station/wview/html/fiobbio:ro \
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
#    -v ${hostRepoRoot}/host/crontab:/var/spool/cron/crontabs/root \
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

# FIXME: nginx-exporter
if false; then
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
fi

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

if [ "${ENABLE_PORTAINER:-0}" = "1" ] && docker volume inspect portainer_data >/dev/null; then

    stop_start portainer || docker run \
        -d --rm \
        \
        --net=container:nginx \
        \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v portainer_data:/data \
        \
        --name=portainer \
        \
        portainer/portainer-ce
else
    echo "WARN: skipping portainer because disabled / portainer_data volume wasn't found!"
fi

if docker volume inspect grafana-storage >/dev/null; then

    # FIXME: grafana-image-renderer
    if false; then
        stop_start grafana-image-renderer || docker run \
            --rm -d \
            \
            --network=container:nginx \
            \
            -v grafana-storage:/var/lib/grafana \
            \
            --env ENABLE_METRICS="true" \
            \
            --name=grafana-image-renderer \
            \
            grafana/grafana-image-renderer:latest
    fi

    #    --env GF_RENDERING_SERVER_URL="http://localhost:8081/render" \
    #    --env GF_RENDERING_CALLBACK_URL="http://localhost:3000/" \
    #    \

    stop_start grafana || docker run \
        --rm -d \
        \
        --network=container:nginx \
        \
        -v grafana-storage:/var/lib/grafana \
        -v ${hostRepoRoot}/grafana/grafana.ini:/etc/grafana/grafana.ini \
        -v ${hostWviewDataDir}/fiobbio/archive/wview-archive.sdb:/wview-archive-fiobbio.sdb:ro \
        -v ${hostWviewDataDir}/misma/archive/wview-archive.sdb:/wview-archive-misma.sdb:ro \
        \
        --name=grafana \
        \
        grafana/grafana
else
    echo "WARN: skipping grafana because grafana-storage volume wasn't found!"
fi

set +x

touch "$scriptCompleted"
