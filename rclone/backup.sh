#!/bin/bash

wviewDataPath=/wview-data
#destDir="/data/$(date "+%Y-%m-%d_%H-%M-%S")"
destDir="/data"

declare -a filesList=($(find "${wviewDataPath}"/{archive,conf}/ -maxdepth 1 -type f -name "*sdb"))

mkdir -p "${destDir}"

for f in "${filesList[@]}"; do
    echo "INFO: backing up ${f}"
    sqlite3 \
        -cmd ".timeout 10000" \
        "${f}" \
        ".backup ${destDir}/$(basename ${f})"
done

rclone sync "${destDir}" backblaze:weather-station
