#!/bin/bash

. ../common_variables.sh

set -x

#
# /tmp needed for:
# - /tmp/webcam-lock
# - /tmp/cml_ftp.log
#
docker run \
    --rm \
    \
    -v /home/pi/secrets/cml_ftp_login_data.sh:/home/pi/secrets/cml_ftp_login_data.sh:ro \
    -v /home/pi/secrets/webcam_login_data.sh:/home/pi/secrets/webcam_login_data.sh:ro \
    -v /home/pi/panogen/out:/home/pi/panogen/out \
    -v ${hostRepoRoot}/webcam/scripts:/webcam/scripts:ro \
    -v ${hostRepoRoot}/webcam/config.sh:/webcam/config.sh:ro \
    -v ${hostRepoRoot}/common_variables.sh:/common_variables.sh:ro \
    -v ${webcamHostDir}:${webcamHostDir} \
    -v /tmp:/tmp \
    \
    -v /dev/log:/dev/log \
    -v /etc/timezone:/etc/timezone:ro \
    -v /etc/localtime:/etc/localtime:ro \
    \
    --name=webcam \
    \
    pullme/x86_64-webcam:latest \
    \
    /webcam/scripts/main.sh
