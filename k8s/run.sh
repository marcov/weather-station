#!/bin/bash
#
# Start all the k8s weather stuff
#
set -euo pipefail

set -x
declare -r scriptDir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

. ${scriptDir}/../common_variables.sh

declare -r scriptStarted="/tmp/run-sh-started"
declare -r scriptCompleted="/tmp/run-sh-completed"
declare -r arch="$(arch)"
declare removeEphemeral=

if [ "`id -u`" != 0 ]; then
    asRoot="/usr/bin/sudo"
fi

${asRoot:-} rm -f "$scriptStarted" "$scriptCompleted"
touch "$scriptStarted"

#
# TODO: find a better way to store wview img in a tmpfs shared volume b/w host and containers!
#
if [ -n "${removeEphemeral}" ]; then
    rm -rf "${hostWviewImgDir}"
    mkdir "${hostWviewImgDir}"
fi

# Provision webcam,webhost folders
mkdir -p /tmp/{webcam,webshot}

# Provision img folder
mkdir -p "${hostWviewImgDir}"

# Create the ddns ip cache file
${asRoot} touch /tmp/ddns-ip
${asRoot} chmod 666 /tmp/ddns-ip

cp -a \
    "${hostRepoRoot}/wview/fs/${WVIEW_CONF_DIR}/html/classic/static/" \
    "${hostWviewImgDir}/fiobbio1"

cp -a \
    "${hostRepoRoot}/wview/fs/${WVIEW_CONF_DIR}/html/classic/static/" \
    "${hostWviewImgDir}/misma"

cp -a \
    "${hostRepoRoot}/wview/fs/${WVIEW_CONF_DIR}/html/classic/static/" \
    "${hostWviewImgDir}/fiobbio2"

cp \
    "${hostRepoRoot}/wview/fs/${WVIEW_CONF_DIR}/html/chart_bg_bigger.png" \
    "${hostWviewImgDir}/fiobbio1/chart_bg.png"

cp \
    "${hostRepoRoot}/wview/fs/${WVIEW_CONF_DIR}/html/chart_bg_bigger.png" \
    "${hostWviewImgDir}/fiobbio2/chart_bg.png"

cp \
    "${hostRepoRoot}/wview/fs/${WVIEW_CONF_DIR}/html/chart_bg_bigger.png" \
    "${hostWviewImgDir}/misma/chart_bg.png"

mkdir -p "${hostWviewImgDir}"/{fiobbio1,misma,fiobbio2}/NOAA
mkdir -p "${hostWviewImgDir}"/{fiobbio1,misma,fiobbio2}/Archive

set -x
minikube status || minikube start --extra-config=apiserver.service-node-port-range=1-65535

${scriptDir}/template-gen.sh

# TODO fix cml ftp login info
if ! kubectl get secrets cml-ftp-login >/dev/null; then
    kubectl create secret generic cml-ftp-login --from-env-file=/home/pi/secrets/cml_ftp_login_data.sh
fi

# TODO all the other secrets needs to be created

# TODO: needs to be deleted?
#kubectl delete --wait=true -f ${scriptDir}/manifests/ || echo "WARN: ignoring kubectl error on delete"

# TODO helm charts in helm-charts.md
kubectl apply -f ${scriptDir}/manifests/

set +x

touch "$scriptCompleted"
