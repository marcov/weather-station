#!/bin/bash

#
# Download given set of URLs
#
set -euo pipefail

declare -r destDir="/tmp/downloader"
declare -r local_grafana_domain=nginx.default.svc.cluster.local
declare -r grafana_all_stations_rain_panel="https://${local_grafana_domain}/grafana/render/d-solo/Ewu-ii3Mk/wview-all-stations?orgId=1&from=now&to=now&theme=dark&width=250&height=200&tz=Europe%2FRome&panelId="

# From current time should subtract 1h30m, and be rounded to 15 minutes increments
#declare -r sat_alps_url="https://imn-api.meteoplaza.com/v4/nowcast/tiles/satellite-europe/${get_date_time}/7/44/65/47/70?outputtype=jpeg"

declare -A urls=( \
    #[fiobbio-t-1m]="https://${local_grafana_domain}/grafana/render/d-solo/dqNwskkRz/wview-history?orgId=1&from=now-1m&to=now&panelId=9&width=1000&height=500&tz=Europe%2FRome"
    #[fiobbio-t-7d]="https://${local_grafana_domain}/grafana/render/d-solo/dqNwskkRz/wview-history?orgId=1&from=now-7d&to=now&panelId=9&width=1000&height=500&tz=Europe%2FRome"
    #[yearrain.png]="https://${local_grafana_domain}/grafana/render/d-solo/Ewu-ii3Mk/wview---all-stations?orgId=1&kiosk=tv&refresh=1m&from=1696843849094&to=1696930249094&panelId=40&width=250&height=380&tz=Europe%2FRome&theme=light&kiosk"
    [rain_day.png]="${grafana_all_stations_rain_panel}"43
    [rain_month.png]="${grafana_all_stations_rain_panel}"42
    [rain_year.png]="${grafana_all_stations_rain_panel}"40
)

[ -d "${destDir}" ] || { echo "ERR: missing dest dir ${destDir}, creating it"; exit 1; }

for fname in "${!urls[@]}"; do
    echo "Getting snap $fname"
    curl -sS -fkL -o "${destDir}/$fname" "${urls[$fname]}"
done
