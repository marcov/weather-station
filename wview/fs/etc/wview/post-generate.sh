#!/bin/bash
#
# NOTE:
# chronic will _only_ print to stdout if the command fails.
# When that happens, send stdout to logger.

set -euo pipefail

declare -r scriptsPath="/home/pi/weather_station/wview/scripts"
declare -r loggerTag="wview post-generate.sh"

pushd "${scriptsPath}" > /dev/null || { logger -t "${loggerTag}" "Failed to pushd scripts path: ${scriptsPath}"; exit $?; }

logger -t "${loggerTag}" "[start] generate wview txt"
chronic ./generate_wview_txt.sh | logger -t "${loggerTag}"

logger -t "${loggerTag}" "[start] CML FTP upload"
chronic ./cml_upload.sh | logger -t "${loggerTag}"
logger -t "${loggerTag}" "[done] CML FTP upload"

logger -t "${loggerTag}" "[start] delete wview txt (if required)"
chronic ./delete_wview_txt.sh | logger -t "${loggerTag}"

popd > /dev/null

exit 0
