#!/bin/bash
#
set -euo pipefail
set -x

declare -r scriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

echo "INFO: get raw image..."
"${scriptDir}"/get_raw_image.sh || { echo "Failed to get raw image: \"$?\""; }

echo "INFO: add watermark..."
"${scriptDir}"/add_watermark.sh || { echo "Failed to add watermark: \"$?\""; }

echo "INFO: uploading 2 CML FTP..."
"${scriptDir}"/upload_2_cml_ftp.sh || { echo "Failed to upload 2 CML FTP: \"$?\""; }

cd -

exit 0
