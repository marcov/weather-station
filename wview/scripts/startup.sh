#!/bin/bash

set -euo pipefail

echo "Starting up..."
set -x

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
    pids=($(pgrep radmrouted; pgrep "${wviewd_bin}"; pgrep htmlgend; pgrep wvpmond))

    if [ ${#pids[@]} = 0 ]; then
        break;
    fi

    echo "Waiting pids: ${pids[@]}"
    sleep 1
done

echo "Completed!"
