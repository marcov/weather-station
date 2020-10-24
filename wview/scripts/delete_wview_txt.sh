#!/bin/bash

. ../../common_variables.sh

declare -i maxFileSize=20480

pushd "${WVIEW_DATA_DIR}"/img >/dev/null || { echo "Failed to pushd ${WVIEW_DATA_DIR}/img"; exit $?; }

declare -i filesize="$(wc -c wview.txt | awk '{print $1}')"
[ "${filesize}" -lt "${maxFileSize}" ] || { rm wview.txt; }

popd >/dev/null

exit 0
