#!/bin/bash

. ../common_variables.sh

docker run \
    --rm \
    \
    -v ${hostWviewDataDir}:/wview-data \
    -v /home/pi/secrets/rclone.conf:/config/rclone/rclone.conf \
    -v ${hostRepoRoot}/rclone/backup:/backup \
    \
    -v /dev/log:/dev/log \
    -v /etc/timezone:/etc/timezone:ro \
    -v /etc/localtime:/etc/localtime:ro \
    \
    --name=rclone \
    \
    pullme/rclone:latest \
    \
    /backup
