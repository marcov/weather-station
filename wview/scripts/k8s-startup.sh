#!/bin/bash

# Not setting -e since we could have a process returning a failure error code,
# and we want to handle that instead of just returning.
set -uo pipefail

trap sighandler SIGINT SIGTERM

declare -i tailPid=
declare -a allWviewPids=
declare -i procsStartCount=

sighandler () {
    trap - SIGINT SIGTERM ERR EXIT
    echo "INFO: sighandler: got signal, exiting now!"

    while false; do
        echo "WARN: keeping alive to allow debug"
        sleep 1
    done

    kill -KILL ${allWviewPids[@]} $tailPid
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

# TODO: get station type from sqlite config DB
wviewd_bin="/usr/bin/wviewd_${WVIEW_STATION_TYPE}"
if ! [ -x ${wviewd_bin} ]; then
    echo "ERR: invalid WVIEW_STATION_TYPE \"${WVIEW_STATION_TYPE}\": \"${wviewd_bin}\" is not a valid executable!"
    exit -1
fi

tail -n0 --follow --retry /tmp/syslog/syslog &
tailPid="$!"

start_all_procs() {
    procsStartCount=0

    if ! pidof -s radmrouted>/dev/null; then
        rm -f /var/lib/wview/radmrouted.pid
        radmrouted 1 /var/lib/wview &
        sleep 2
        echo "radmrouted PIDs: $(pidof radmrouted)"
    fi
    procsStartCount+=1

    if ! pidof -s ${wviewd_bin}>/dev/null; then
        rm -f /var/lib/wview/${wviewd_bin}.pid
        "${wviewd_bin}" &
        sleep 1
        echo "INFO: wviewd_${WVIEW_STATION_TYPE} PIDs: $(pidof wviewd_${WVIEW_STATION_TYPE})"
    fi
    procsStartCount+=1

    if ! pidof -s htmlgend>/dev/null; then
        rm -f /var/lib/wview/htmlgend.pid
        htmlgend &
        sleep 1
        echo "INFO: htmlgend PIDs: $(pidof htmlgend)"
    fi
    procsStartCount+=1

    # Ignore wvhttpd, it's optional and not a vital process anyway
    if ! pidof -s wvhttpd>/dev/null; then
        rm -f /var/lib/wview/wvhttpd.pid
        wvhttpd &
        sleep 1
        echo "INFO: wvhttpd PIDs: $(pidof wvhttpd)"
    fi

    if ! pidof -s wvpmond>/dev/null; then
        rm -f /var/lib/wview/wvpmond.pid
        wvpmond &
        sleep 1
        echo "INFO: wvpmond PIDs: $(pidof wvpmond)"
    fi
    procsStartCount+=1
}

start_all_procs

while true; do

    onePidPerProcs=( $(pidof -s radmrouted ${wviewd_bin} htmlgend wvpmond) )

    allWviewPids=($(pidof radmrouted ${wviewd_bin} htmlgend wvpmond))

    if ! [[ ${#onePidPerProcs[@]} = ${procsStartCount} ]]; then
        echo "INFO: Procs count mismatch:
  Running ${#onePidPerProcs[@]} vs started ${procsStartCount}
  All running PIDs: ${allWviewPids[@]})
  Retrying startup..."

        kill -KILL ${allWviewPids[@]}
        rm -f /var/lib/wview/*.pid
        procsStartCount=0

        start_all_procs
    else
        echo "INFO: All running PIDs: ${allWviewPids[@]}"
        sleep 10
    fi
done

kill -TERM "$tailPid"
wait

echo "INFO: k8s wview exiting"
