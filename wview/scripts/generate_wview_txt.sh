#!/bin/sh

. ../common_variables.sh

cd ${wview_html_dir} || exit $?

[ -e wview.htm ] || echo "wview.htm not found!"; exit $?
cat wview.htm >> wview.txt

cd -

exit 0
