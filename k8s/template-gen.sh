#!/bin/bash
set -euo pipefail

set -x
declare -r scriptDir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
declare -r manifestsDir="$1"

declare -A wview_stations_map=(
)

rm -rf ${manifestsDir}
mkdir -p ${manifestsDir}

################################################################################

for sta in "${!wview_stations_map[@]}"; do
    cat > ${manifestsDir}/wview-${sta}.yaml << EOF
#
# Generated from a template using "${BASH_SOURCE[@]}"
#
EOF

    cat ${scriptDir}/wview-template.yaml | \
        WVIEW_INSTANCE_NAME="${sta}" \
        WVIEW_STATION_TYPE="${wview_stations_map[${sta}]}" \
        envsubst '$WVIEW_INSTANCE_NAME $WVIEW_STATION_TYPE' >> "${manifestsDir}/wview-${sta}.yaml"
done

################################################################################

declare -A weewx_stations_map=(
    [fiobbio1]=vpro
    [fiobbio2]=wxt510
    [misma]=vpro
)

for sta in "${!weewx_stations_map[@]}"; do
    cat > ${manifestsDir}/weewx-${sta}.yaml << EOF
#
# Generated from a template using "${BASH_SOURCE[@]}"
#
EOF

    cat ${scriptDir}/weewx-template.yaml | \
        WEEWX_INSTANCE_NAME="${sta}" \
        WEEWX_STATION_TYPE="${weewx_stations_map[${sta}]}" \
        envsubst '$WEEWX_INSTANCE_NAME $WEEWX_STATION_TYPE' >> "${manifestsDir}/weewx-${sta}.yaml"
done
