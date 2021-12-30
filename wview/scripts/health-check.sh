#!/bin/bash
set -euo pipefail

declare -i checkMinutes=2
#checkDir="/tmp/wview-data-img/misma"
checkDir="/var/lib/wview/img"

###

[ -d ${checkDir} ] || { echo "ERR: ${checkDir} is not a dir"; exit 2; }

filesCount="$(find "${checkDir}" -mmin -${checkMinutes} | wc -l)"

declare -i unhealthy=
[ "${filesCount}" != 0 ] && unhealthy=0 || unhealthy=1

sed -E -i "s,^unhealthy [01]$,unhealthy ${unhealthy}," "${checkDir}/metrics.prom"

echo "INFO: files count = ${filesCount} - unhealthy = ${unhealthy}"
[ "${unhealthy}" = 1 ] && exit 1 || exit 0
