#!/bin/bash
set -euo pipefail

set -x
declare -r scriptDir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
declare -r manifestsDir="$1"

declare -A stationsMap=(
    [fiobbio1]=vpro
    [fiobbio2]=wxt510
    [misma]=vpro
)

rm -rf ${manifestsDir}
mkdir -p ${manifestsDir}

for sta in "${!stationsMap[@]}"; do
    cat > ${manifestsDir}/wview-${sta}.yaml << EOF
#
# Generated from a template using "${BASH_SOURCE[@]}"
#
EOF

    cat ${scriptDir}/wview-template.yaml | \
        WVIEW_INSTANCE_NAME="${sta}" \
        WVIEW_STATION_TYPE="${stationsMap[${sta}]}" \
        envsubst '$WVIEW_INSTANCE_NAME $WVIEW_STATION_TYPE' >> "${manifestsDir}/wview-${sta}.yaml"
done
