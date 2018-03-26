#!/bin/sh

cd /home/pi/weather_station/wview/scripts > /dev/null || exit $?

loggerTag="wview post-generate.sh"
echo logger -t ${loggerTag} "Generating wview txt..."

./generate_wview_txt.sh > /dev/null && logger -t ${loggerTag} "Exit code: $?"

logger -t ${loggerTag} "CML ftp upload"
./cml_upload.sh > /dev/null && logger -t ${loggerTag} "Exit code: $?"

cd - >/dev/null

exit 0
