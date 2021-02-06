#
# Common variables. Edit variables as needed
#

declare scriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
declare -r repoRoot="${scriptDir}"
#
# Container only dir
#
declare -r WVIEW_CONF_DIR="/etc/wview"
declare -r WVIEW_DATA_DIR="/var/lib/wview"

#
# Host dir
#
declare -r hostWviewImgDir="/tmp/wview-data-img"
declare -r hostWviewDataDir="/home/pi/wview-data"
declare -r hostRepoRoot="${repoRoot}"
declare -r hostWebcamDir="/tmp/webcam"
declare -r hostWebshotDir="/tmp/webshot"
