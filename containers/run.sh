#!/bin/bash

docker run \
    --net=host -d --rm \
    -v /var/lib/wview/archive:/var/lib/wview/archive \
    -v /var/lib/wview/img:/var/lib/wview/img \
    -v /var/lib/wview/conf:/var/lib/wview/conf \
    -v /etc/wview:/etc/wview \
    -v /etc/cml_ftp_login_data.sh:/etc/cml_ftp_login_data.sh:ro \
    -v /etc/webcam_login_data.sh:/etc/webcam_login_data.sh:ro \
    -v /home/pi/weather_station:/home/pi/weather_station \
    -v /dev/log:/dev/log \
    -v /etc/timezone:/etc/timezone:ro \
    -v /etc/localtime:/etc/localtime:ro \
    \
    --name=wview \
    \
    pullme/wview:5.21.7 \
    \
    sh -c "/etc/init.d/wview restart; while true; do sleep 9999; done"
