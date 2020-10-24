#!/bin/bash

set -euo pipefail

declare -r phantomjs_pi_path="/home/pi/bin/phantomjs-2.0.1-development-linux-armv6l/bin/phantomjs"
declare -r webshot_tool="js/webshot.js"

[ "$#" -ge 1 ] || { echo "Need destination path as argument"; exit -1; }
dst_path="$1"

#
# Try to use phantomjs in path
#
phantomjs_bin="$(command -v phantomjs)"

#
# If unavailable, try to use our raspi binary
#
if [ -z "$phantomjs_bin" ]; then
	phantomjs_bin="$phantomjs_pi_path"
	[ -x "$phantomjs_bin" ] || { echo "ERR: phantomjs tool could not be found"; exit -1; }
fi

node js/run-webshot.js ${phantomjs_bin} ${webshot_tool} config.json ${dst_path}
exit $?
