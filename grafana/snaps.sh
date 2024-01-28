#!/bin/bash
#
# Take snapshoxts of grafana
#
set -euo pipefail

declare -r destDir="/tmp/grafana-snaps"

declare -A snaps=( \
    #[fiobbio-t-1m]="https://meteo.local/grafana/render/d-solo/dqNwskkRz/wview-history?orgId=1&from=now-1m&to=now&panelId=9&width=1000&height=500&tz=Europe%2FRome"
    #[fiobbio-t-7d]="https://meteo.local/grafana/render/d-solo/dqNwskkRz/wview-history?orgId=1&from=now-7d&to=now&panelId=9&width=1000&height=500&tz=Europe%2FRome"
    #[yearrain.png]="https://meteo.local/grafana/render/d-solo/Ewu-ii3Mk/wview---all-stations?orgId=1&kiosk=tv&refresh=1m&from=1696843849094&to=1696930249094&panelId=40&width=250&height=380&tz=Europe%2FRome&theme=light&kiosk"
    [rain_day.png]="https://meteo.local/grafana/render/d-solo/Ewu-ii3Mk/wview-all-stations?orgId=1&from=now&to=now&theme=dark&panelId=43&width=250&height=200&tz=Europe%2FRome"
    [rain_month.png]="https://meteo.local/grafana/render/d-solo/Ewu-ii3Mk/wview-all-stations?orgId=1&from=now&to=now&theme=dark&panelId=42&width=250&height=200&tz=Europe%2FRome"
    [rain_year.png]="https://meteo.local/grafana/render/d-solo/Ewu-ii3Mk/wview-all-stations?orgId=1&from=now&to=now&theme=dark&panelId=40&width=250&height=200&tz=Europe%2FRome"
)

declare scriptDir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

[ -d "${destDir}" ] || { echo "ERR: missing dest dir ${destDir}"; exit 1; }

for snap_name in "${!snaps[@]}"; do
    echo "Getting snap $snap_name"
    curl -sS -fkL -o "${destDir}/$snap_name" "${snaps[$snap_name]}"
done