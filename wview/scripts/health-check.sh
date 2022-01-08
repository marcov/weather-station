#!/bin/bash
set -euo pipefail

declare -i checkMinutes=2
#wviewImgDir="/tmp/wview-data-img/misma"
wviewImgDir="/var/lib/wview/img"
# NOTE: check a file we do not change afterwards :-)
expectedFiles=( \
    realtime.json \
    tempdaycomp.png \
)

###

[ -d ${wviewImgDir} ] || { echo "ERR: ${wviewImgDir} is not a dir"; exit 2; }

declare -i filesCount=0
for f in ${expectedFiles[@]}; do
    filesCount+="$(find "${wviewImgDir}" -mmin -${checkMinutes} -name "${f}" | wc -l)"
done

declare -i unhealthy=
[ "${filesCount}" = "${#expectedFiles[@]}" ] && unhealthy=0 || unhealthy=1

# Update health status
sed -E -i "s,^unhealthy [01]$,unhealthy ${unhealthy}," "${wviewImgDir}/metrics.prom"

echo "INFO: expected files count = ${#expectedFiles[@]} - found = ${filesCount} - unhealthy = ${unhealthy}"
[ "${unhealthy}" = 1 ] && exit 1 || exit 0
