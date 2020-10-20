#!/bin/bash

set -euo pipefail

set -x

#
# NOTE: --privileged for /dev/ttyUSB0 access
#
docker run \
    -d --rm \
    --privileged \
    \
    -v /home/pi/weather_station/ser2net/ser2net.conf:/etc/ser2net.conf \
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
    -v /var/lib/wview/img:/var/lib/wview/img \
    -v /home/pi/weather_station/http_server/nginx_cfg:/etc/nginx/conf.d/default.conf \
    -v /home/pi/weather_station/wview/html/fiobbio:/home/pi/weather_station/wview/html/fiobbio \
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
    -v /var/lib/wview/archive:/var/lib/wview/archive \
    -v /var/lib/wview/img:/var/lib/wview/img \
    -v /var/lib/wview/conf:/var/lib/wview/conf \
    -v /etc/wview:/etc/wview \
    -v /etc/cml_ftp_login_data.sh:/etc/cml_ftp_login_data.sh:ro \
    -v /etc/webcam_login_data.sh:/etc/webcam_login_data.sh:ro \
    -v /home/pi/weather_station:/home/pi/weather_station \
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
