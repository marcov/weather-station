#!/bin/bash

set -o pipefail

. ../common_variables.sh

dst_path=${wview_html_dir}
#dst_path=.
webshot_tool=js/webshot.js

# Use phantomjs in path
phantomjs_bin="$(command -v phantomjs)"

# Use phantomjs from a local folder
if [ -z "$phantomjs_bin" ]; then
	phantomjs_bin="$phantomjs_pi_path"
	if ! [ -x "$phantomjs_bin" ]; then
		echo "ERROR: phantomjs tool could not be found"
		exit -1
	fi
fi

node js/run-webshot.js ${phantomjs_bin} ${webshot_tool} config.json ${dst_path}
exit $?

