#!/bin/bash

. ../common_variables.sh

dst_path=${wview_html_dir}
#dst_path=.
webshot_tool=webshot.js

if which phantomjs > /dev/null
then
    phantomjs_bin=phantomjs
else
    phantomjs_bin=/home/pi/bin/phantomjs-2.0.1-development-linux-armv6l/bin/phantomjs
fi

node run-webshot.js ${phantomjs_bin} ${webshot_tool} websites.json ${dst_path} || exit $?

