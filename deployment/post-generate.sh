#/bin/sh

# Esegue lo script dal repository weather_station.
#
# Vedi: https://github.com/marcov/weather_station
#
/home/pi/weather_station/wview/scripts/post-generate.sh >/dev/null || exit $?

exit 0
