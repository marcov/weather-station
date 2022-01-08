#!/bin/bash

set -euo pipefail

trap sighandler SIGINT SIGTERM ERR EXIT

declare -i tailPid=
declare -a wviewPids=

sighandler() {
    trap - SIGINT SIGTERM ERR EXIT
    echo "sighandler: trapped signal, exiting now!"

    kill -KILL ${wviewPids[@]} $tailPid
    exit 0
}

echo "k8s wview starting up..."

# Set the timezone
ln -sf /usr/share/zoneinfo/Europe/Rome /etc/localtime

# If dev log is not provided, wait for the log socket from the syslog container
# and symlink it to /dev/log
if ! [ -e /dev/log ]; then

    while ! [ -e /tmp/syslog/dev-log.sock ]; do
        echo "Waiting for /dev/log from rsyslog container"
        sleep 1
    done

    ln -s /tmp/syslog/dev-log.sock /dev/log
fi

radmrouted 1 /var/lib/wview &
sleep 2

#wviewd_bin="/usr/bin/`cat /etc/wview/wview-binary`"
wviewd_bin="/usr/bin/wviewd_${WVIEW_STATION_TYPE}"
if ! [ -x ${wviewd_bin} ]; then
    echo "ERR: invalid WVIEW_STATION_TYPE \"${WVIEW_STATION_TYPE}\": \"${wviewd_bin}\" is not a valid executable!"
    exit -1
fi

"${wviewd_bin}" &
sleep 1

htmlgend &
sleep 1

wvhttpd &
sleep 1

wvpmond &
sleep 1

tail -f /tmp/syslog/syslog &
tailPid="$!"

while true; do
    wviewPids=($(pgrep radmrouted; \
            pgrep "${wviewd_bin}"; \
            pgrep htmlgend; \
            pgrep wvhttpd; \
            pgrep wvpmond) \
         )

    if [ ${#wviewPids[@]} = 0 ]; then
        echo "INFO: No PIDs to wait, exiting..."
        break;
    fi

    echo "INFO: Waiting PIDs: ${wviewPids[@]}"
    sleep 60
done

kill -TERM "$tailPid"
wait

echo "k8s wview exiting"
