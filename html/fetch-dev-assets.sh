#!/usr/bin/env bash

set -u
set -o pipefail

readonly base_url="${METEO_BASE_URL:-https://meteo.fiobbio.com}"
readonly script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly current_year="$(date +%Y)"
readonly current_month="$(date +%m)"

download() {
    local relative_path="$1"
    local destination="${script_dir}/${relative_path}"
    local temporary_file

    mkdir -p -- "$(dirname -- "${destination}")"
    temporary_file="$(mktemp "${destination}.tmp.XXXXXX")"

    if curl --fail --location --silent --show-error \
        "${base_url}/${relative_path}" --output "${temporary_file}"; then
        mv -- "${temporary_file}" "${destination}"
        printf 'updated  %s\n' "${relative_path}"
        return 0
    fi

    rm -f -- "${temporary_file}"
    printf 'missing  %s\n' "${relative_path}" >&2
    return 1
}

assets=(
    fiobbio1/realtime.json
    fiobbio1/stationinfo.json
    fiobbio1/daytempdew.png
    fiobbio1/daywind.png
    fiobbio1/dayradiation.png
    fiobbio1/rainday.png
    fiobbio1/baromday.png
    fiobbio1/humidday.png
    fiobbio1/dayhum.png
    fiobbio1/dayrain.png
    fiobbio2/realtime.json
    fiobbio2/daytempdew.png
    fiobbio2/daywind.png
    fiobbio2/dayhum.png
    fiobbio2/dayrain.png
    misma/realtime.json
    misma/daytempdew.png
    misma/daywind.png
    misma/dayhum.png
    misma/dayrain.png
    webcam/webcam_small_fiobbio.jpg
    webcam/webcam_small_misma.jpg
    webcam/webcam_fiobbio.jpg
    webcam/webcam_misma.jpg
    downloader/rain_day.png
    downloader/rain_month.png
    downloader/rain_year.png
    downloader/sat_alps.jpg
    webshot/meteoblue.jpg
    webshot/wz_meteogram.jpg
    webshot/wz_meteogram.svg
    webshot/wz_ensemble.jpg
    webshot/radar_lom.jpg
    "fiobbio1/NOAA/NOAA-${current_year}-${current_month}.txt"
    "fiobbio1/NOAA/NOAA-${current_year}.txt"
    "fiobbio2/NOAA/NOAA-${current_year}-${current_month}.txt"
    "fiobbio2/NOAA/NOAA-${current_year}.txt"
    "misma/NOAA/NOAA-${current_year}-${current_month}.txt"
    "misma/NOAA/NOAA-${current_year}.txt"
)

failures=0
for asset in "${assets[@]}"; do
    if ! download "${asset}"; then
        failures=$((failures + 1))
    fi
done

printf '\nLocal snapshot refresh complete: %d available, %d unavailable.\n' \
    "$((${#assets[@]} - failures))" "${failures}"

# A missing live asset should not make the otherwise useful snapshot unusable.
exit 0
