#!/bin/bash

set -euo pipefail

trap sighandler SIGINT SIGTERM ERR EXIT

declare -i tailPid=
declare -a wviewPids=

sighandler() {
    trap - SIGINT SIGTERM ERR EXIT
    echo "INFO: sighandler: got signal, exiting now!"

    while true; do
        echo "WARN: keeping alive to allow debug"
        sleep 1
    done

    kill -KILL ${wviewPids[@]} $tailPid
    exit 0
}

echo "INFO: k8s wview starting up..."

# Set the timezone
ln -sf /usr/share/zoneinfo/Europe/Rome /etc/localtime

# If dev log is not provided, wait for the log socket from the syslog container
# and symlink it to /dev/log
if ! [ -e /dev/log ]; then

    while ! [ -e /tmp/syslog/dev-log.sock ]; do
        echo "INFO: waiting for /dev/log from rsyslog container"
        sleep 1
    done

    ln -s /tmp/syslog/dev-log.sock /dev/log
fi

#wviewd_bin="/usr/bin/`cat /etc/wview/wview-binary`"
wviewd_bin="/usr/bin/wviewd_${WVIEW_STATION_TYPE}"
if ! [ -x ${wviewd_bin} ]; then
    echo "ERR: invalid WVIEW_STATION_TYPE \"${WVIEW_STATION_TYPE}\": \"${wviewd_bin}\" is not a valid executable!"
    exit -1
fi

tail -n0 --follow --retry /tmp/syslog/syslog &
tailPid="$!"

radmrouted 1 /var/lib/wview &
sleep 2
echo "radmrouted PID: $(pidof -s radmrouted)"

"${wviewd_bin}" &
sleep 1
echo "INFO: wviewd_${WVIEW_STATION_TYPE} PID: $(pidof -s wviewd_${WVIEW_STATION_TYPE})"

htmlgend &
sleep 1
echo "INFO: htmlgend PID: $(pidof -s htmlgend)"

wvhttpd &
sleep 1
echo "INFO: wvhttpd PID: $(pidof -s wvhttpd)"

wvpmond &
sleep 1
echo "INFO: wvpmond PID: $(pidof -s wvpmond)"

while true; do
    wviewPids=( \
        $(pidof -s radmrouted) \
        $(pidof -s ${wviewd_bin}) \
        $(pidof -s htmlgend) \
        $(pidof -s wvhttpd) \
        $(pidof -s wvpmond) \
    )

    if [[ ${#wviewPids[@]} = 0 ]]; then
        echo "INFO: No PIDs to wait, exiting..."
        break;
    fi

    echo "INFO: Waiting PIDs: ${wviewPids[@]}"
    sleep 60
done

kill -TERM "$tailPid"
wait

echo "INFO: k8s wview exiting"
