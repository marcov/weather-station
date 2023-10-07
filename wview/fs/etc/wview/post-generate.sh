#!/bin/bash

set -uo pipefail

declare -r scripts_path="/weather-station/wview/scripts"
declare -r data_dir="/var/lib/wview/img"

set -x

pushd "${scripts_path}"
./cml-upload.sh "${data_dir}"
./update-wview-txt.sh "${data_dir}"
popd

exit 0
