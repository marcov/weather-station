#!/bin/bash
#
# Check that the program is healthy by expecting a list of well-known generated
# files to have a recent "last modified" timestamp.
#
# arg 1 is the html dir to use

set -euo pipefail

# htmlgend runs every 5 minutes, so use 5' + 50%
declare -r -i checkMinutes=8

htmlDir="${1}"

if [[ $# = 1 ]]; then
    htmlDir=$1
    echo "INFO: overridden wview html dir with input argument: ${htmlDir}"
fi

# NOTE: remember to check a file WE DO NOT change afterwards :-)
declare -ra expectedFiles=(
    realtime.json
    daytempdew.png
)

[ -d ${htmlDir} ] || { echo "ERR: ${htmlDir} is not a dir"; exit 2; }

declare -i filesCount=0
for f in ${expectedFiles[@]}; do
    filesCount+="$(find "${htmlDir}" -mmin -${checkMinutes} -name "${f}" | wc -l)"
    echo "INFO: files count after checking ${f}: ${filesCount}"
done

declare -i unhealthy=
(( ${filesCount} == ${#expectedFiles[@]} )) && unhealthy=0 || unhealthy=1

read -r -d '' awk_program << 'EOF' || true
{
    if ($0 ~ /^#/) {
        # Print commented lines as-is
        print $0;
    } else if ($1 == "unhealthy"){
        # Set metric unhealthy to the passed field value
        print $1" "unhealthy;
    } else if (unhealthy == "1"){
        # If the passed unhealthy value is 1, remove the old value of any other
        # metrics (but unhealthy)
        # This is to avoid prometheus to show stale constant data where no new
        # data is being produced by the station.
        $NF=""; print $0;
    } else {
        # Print everything else as is
        print $0;
    }
}
EOF

awk -v unhealthy="${unhealthy}" "${awk_program}" "${htmlDir}/metrics.prom" > "${htmlDir}/metrics.prom.tmp"
mv "${htmlDir}/metrics.prom.tmp" "${htmlDir}/metrics.prom"

echo "INFO: expected files count = ${#expectedFiles[@]} - found = ${filesCount} - unhealthy = ${unhealthy}"
exit "${unhealthy}"
