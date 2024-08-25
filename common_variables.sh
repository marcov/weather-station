#
# Common variables. Edit variables as needed
#

# repo root is this dir
declare -r repoRoot="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
#
# Container only dir
#
declare -r WVIEW_CONF_DIR="/etc/wview"
declare -r WVIEW_DATA_DIR="/var/lib/wview"

#
# Host dir
#
declare -r hostWviewImgDir="/tmp/station-data-img"
declare -r hostRepoRoot="${repoRoot}"

