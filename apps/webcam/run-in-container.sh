#!/bin/bash

. ../common_variables.sh

. /home/pi/secrets/cml_ftp_login_data.sh
. /home/pi/secrets/webcam_login_data.sh
set -x

#
# /tmp needed for:
# - /tmp/webcam-lock
# - /tmp/cml_ftp.log
#
docker run \
    --rm \
    \
    --env fiobbio_webcam_login="${fiobbio_webcam_login}" \
    --env misma_webcam_login="${misma_webcam_login}" \
    \
    --env cml_ftp_user_fiobbio=${cml_ftp_user_fiobbio} \
    --env cml_ftp_pwd_fiobbio=${cml_ftp_pwd_fiobbio} \
    --env cml_ftp_user_misma=${cml_ftp_user_misma} \
    --env cml_ftp_pwd_misma=${cml_ftp_pwd_misma} \
    \
    -v /home/pi/panogen/out:/home/pi/panogen/out \
    -v ${hostRepoRoot}/webcam/scripts:/webcam/scripts:ro \
    -v ${hostRepoRoot}/webcam/config.sh:/webcam/config.sh:ro \
    -v ${hostRepoRoot}/common_variables.sh:/common_variables.sh:ro \
    -v ${hostWebcamDir}:${hostWebcamDir} \
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
