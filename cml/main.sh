#!/bin/bash

set -uo pipefail

declare -r scripts_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
declare -r data_dir="${1}"

set -x
${scripts_dir}/cml-upload.sh "${data_dir}"
${scripts_dir}/update-wview-txt.sh "${data_dir}"

exit 0
