#!/bin/bash

set -euo pipefail

declare -r data_dir="${1}"

declare -r -i max_file_size=20480

pushd "${data_dir}"

if ! [ -e wview.htm ]; then
    echo "ERR: NO wview.html found!"
    exit 1
fi

cat wview.htm >> wview.txt

declare -i -r file_size="$(wc -c wview.txt | awk '{print $1;}')"

if [[ ${file_size} > ${max_file_size} ]]; then
    echo "INFO: wview.txt size ${file_size} is over the max size ${max_file_size} - removing it."
    rm wview.txt
fi

popd
