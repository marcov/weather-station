#!/bin/sh

. ../../common_variables.sh

cd ${wview_html_dir} || exit $?

[ -e wview.htm ] || exit $?
cat wview.htm >> wview.txt

cd -

exit 0
