#!/bin/bash

set -euo pipefail

declare -r repoDir="/home/pi/weather_station"

set -x

#
# NOTE: --privileged for /dev/ttyUSB0 access
#
docker run \
    -d --rm \
    --privileged \
    \
    -v ${repoDir}/ser2net/ser2net.conf:/etc/ser2net.conf \
    -v /dev/ttyUSB0:/dev/ttyUSB0 \
    \
    --name=ser2net \
    \
    pullme/ser2net:wview

docker run \
    -d --rm \
    \
    --publish 80:80 \
    \
    -v ${repoDir}/wview/fs/var/lib/wview/img:/var/lib/wview/img \
    -v ${repoDir}/http_server/nginx_cfg:/etc/nginx/conf.d/default.conf \
    -v ${repoDir}/wview/html/fiobbio:${repoDir}/wview/html/fiobbio \
    \
    -v /dev/log:/dev/log \
    -v /etc/timezone:/etc/timezone:ro \
    -v /etc/localtime:/etc/localtime:ro \
    \
    --name=nginx \
    \
    nginx:latest

docker run \
    -d --rm \
    \
    --net=container:ser2net \
    \
    -v ${repoDir}/wview/fs/var/lib/wview/archive:/var/lib/wview/archive \
    -v ${repoDir}/wview/fs/var/lib/wview/img:/var/lib/wview/img \
    -v ${repoDir}/wview/fs/var/lib/wview/conf:/var/lib/wview/conf \
    -v ${repoDir}/wview/fs/etc/wview:/etc/wview \
    -v /etc/cml_ftp_login_data.sh:/etc/cml_ftp_login_data.sh:ro \
    -v /etc/webcam_login_data.sh:/etc/webcam_login_data.sh:ro \
    -v ${repoDir}:${repoDir} \
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

set +x
