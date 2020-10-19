#!/bin/bash

#set -uo pipefail

pushd /home/pi/weather_station/wview/scripts > /dev/null || exit $?

loggerTag="wview-post-generate.sh"

logger -t ${loggerTag} "Generating wview txt..."
chronic ./generate_wview_txt.sh | logger -t ${loggerTag}

logger -t ${loggerTag} "CML FTP upload"
chronic ./cml_upload.sh | logger -t ${loggerTag}

popd > /dev/null

exit 0
