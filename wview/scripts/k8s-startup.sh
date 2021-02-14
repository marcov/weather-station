#!/bin/bash

set -euo pipefail

echo "k8s wview starting up..."

ln -sf /usr/share/zoneinfo/Europe/Rome /etc/localtime

if ! [ -e /dev/log ]; then
    while ! [ -e /tmp/syslog/dev-log.sock ]; do
        echo "Waiting for /dev/log from rsyslog container"
        sleep 1
    done

    ln -s /tmp/syslog/dev-log.sock /dev/log
fi

radmrouted 1 /var/lib/wview &
sleep 2

wviewd_bin="/usr/bin/`cat /etc/wview/wview-binary`"
"${wviewd_bin}" &
sleep 1

htmlgend &
sleep 1

wvhttpd &
sleep 1

wvpmond &
sleep 1

while true; do
    pids=($(pgrep radmrouted; \
            pgrep "${wviewd_bin}"; \
            pgrep htmlgend; \
            pgrep wvhttpd; \
            pgrep wvpmond) \
         )

    if [ ${#pids[@]} = 0 ]; then
        echo "INFO: No PIDs to wait, exiting..."
        break;
    fi

    echo "INFO: Waiting PIDs: ${pids[@]}"
    sleep 5
done &

tail -f /tmp/syslog/syslog
wait

echo "k8s wview completed!"
