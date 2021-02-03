#!/bin/bash

set -euo pipefail

declare -r configFile="config.json"
declare -r arch="$(arch)"

. ../common_variables.sh

declare scriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

[ "$#" = 0 ] || configFile="$1"

echo "INFO: using config file: ${configFile}"

set -x

# --add-host: HACK to avoid cookie consent popup
# --add-host cdn.privacy-mgmt.com:0.0.0.0 \
#
docker run \
    --rm \
    \
    -v "${scriptDir}/${configFile}":/config.json \
    -v "${wviewEphemeralImg}":/destdir \
    \
    -v /etc/timezone:/etc/timezone:ro \
    -v /etc/localtime:/etc/localtime:ro \
    --add-host cdn.privacy-mgmt.com:0.0.0.0 \
    \
    \
    \
    --name=webshot \
    \
    pullme/"${arch}"-webshot:latest \
    \
    /webshot/run.sh /config.json /destdir
