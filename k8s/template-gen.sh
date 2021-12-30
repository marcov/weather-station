#!/bin/bash
set -euo pipefail

set -x
declare -r scriptDir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

cat ${scriptDir}/wview-template.yaml | \
    WVIEW_INSTANCE_NAME=fiobbio1 WVIEW_STATION_TYPE=vpro \
    envsubst '$WVIEW_INSTANCE_NAME $WVIEW_STATION_TYPE' > ${scriptDir}/manifests/wview-fiobbio1-generated.yaml

cat ${scriptDir}/wview-template.yaml | \
    WVIEW_INSTANCE_NAME=misma WVIEW_STATION_TYPE=vpro \
    envsubst '$WVIEW_INSTANCE_NAME $WVIEW_STATION_TYPE' > ${scriptDir}/manifests/wview-misma-generated.yaml

cat ${scriptDir}/wview-template.yaml | \
    WVIEW_INSTANCE_NAME=fiobbio2 WVIEW_STATION_TYPE=wxt510 \
    envsubst '$WVIEW_INSTANCE_NAME $WVIEW_STATION_TYPE' > ${scriptDir}/manifests/wview-fiobbio2-generated.yaml
