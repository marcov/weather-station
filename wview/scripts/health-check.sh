#!/bin/bash
#
# (optional) arg1 is an alternative wview img dir to use
#
set -euo pipefail

# htmlgend runs every 5 minutes, so use 5' + 50%
declare -r -i checkMinutes=8

wviewImgDir="/var/lib/wview/img"

if [[ $# = 1 ]]; then
    wviewImgDir=$1
    echo "INFO: overridden wview img dir with input argument: ${wviewImgDir}"
fi

# NOTE: remember to check a file WE DO NOT change afterwards :-)
declare -ra expectedFiles=( \
    realtime.json \
    tempdaycomp.png \
)

[ -d ${wviewImgDir} ] || { echo "ERR: ${wviewImgDir} is not a dir"; exit 2; }

declare -i filesCount=0
for f in ${expectedFiles[@]}; do
    filesCount+="$(find "${wviewImgDir}" -mmin -${checkMinutes} -name "${f}" | wc -l)"
    echo "INFO: file count after checking ${f}: ${filesCount}"
done

declare -i unhealthy=
(( ${filesCount} == ${#expectedFiles[@]} )) && unhealthy=0 || unhealthy=1

# Update health status
sed -E -i "s,^unhealthy [01]$,unhealthy ${unhealthy}," "${wviewImgDir}/metrics.prom"

echo "INFO: expected files count = ${#expectedFiles[@]} - found = ${filesCount} - unhealthy = ${unhealthy}"
(( ${unhealthy} == 1 )) && exit 1 || exit 0
