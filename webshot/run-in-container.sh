#!/bin/bash

set -euo pipefail

. ../common_variables.sh

declare scriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

set -x

docker run \
    --rm \
    \
    -v "${scriptDir}"/config.json:/config.json \
    -v "${wviewEphemeralImg}":/destdir \
    \
    -v /etc/timezone:/etc/timezone:ro \
    -v /etc/localtime:/etc/localtime:ro \
    \
    --name=webshot \
    \
    pullme/webshot:latest \
    \
    /webshot/run.sh /config.json /destdir
