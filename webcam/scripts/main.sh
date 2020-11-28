#!/bin/bash
#
set -euo pipefail
set -x

# Lock or exit
declare -r lockFile=/tmp/webcam-lock
exec 999>"$lockFile"
flock -n 999 || { echo "ERR: cannot lock $lockFile. Another instance of this script may be running"; exit -1; }

declare -r scriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

echo "INFO: get raw image..."
"${scriptDir}"/get_raw_image.sh || { echo "Failed to get raw image: \"$?\""; }

echo "INFO: add watermark..."
"${scriptDir}"/add_watermark.sh || { echo "Failed to add watermark: \"$?\""; }

echo "INFO: uploading 2 CML FTP..."
"${scriptDir}"/upload_2_cml_ftp.sh || { echo "Failed to upload 2 CML FTP: \"$?\""; }

exit 0
