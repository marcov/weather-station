#!/bin/bash

. ../../common_variables.sh

pushd "${WVIEW_DATA_DIR}"/img >/dev/null || { echo "Failed to cd ${WVIEW_DATA_DIR}/img"; exit $?; }

[ -e wview.htm ] || exit $?
cat wview.htm >> wview.txt

popd >/dev/null

exit 0
