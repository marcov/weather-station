#!/bin/bash
#
set -euo pipefail

# Lock or exit
declare -r lockFile=/tmp/webcam-lock
exec 999>"$lockFile"
flock -n 999 || { echo "ERR: cannot lock $lockFile. Another instance of this script may be running"; exit -1; }

declare -r scriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# FIXME - move into some config file
export hostWebcamDir=/tmp/webcam
export websiteUrl=meteo.fiobbio.com
export cml_ftp_server=ftp.centrometeolombardo.com
export cml_ftp_log_file=/tmp/cml_ftp.log
export cml_ftp_upload_folder=public
export cml_ftp_log_info=1

echo "INFO: running get raw image script"
"${scriptDir}"/get_raw_image.sh || { echo "ERR: Failed to get raw image: \"$?\""; }

echo "INFO: running add watermark script"
"${scriptDir}"/add_watermark.sh || { echo "ERR: Failed to add watermark: \"$?\""; }

echo "INFO: running upload 2 cml script"
"${scriptDir}"/upload_2_cml_ftp.sh || { echo "ERR: Failed to upload 2 CML FTP: \"$?\""; }

exit 0
