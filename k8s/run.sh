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
touch /tmp/ddns-ip
chmod 666 /tmp/ddns-ip

cp -a \
    "${hostRepoRoot}/wview/fs/${WVIEW_CONF_DIR}/html/classic/static" \
    "${hostWviewImgDir}/fiobbio"

cp -a \
    "${hostRepoRoot}/wview/fs/${WVIEW_CONF_DIR}/html/classic/static" \
    "${hostWviewImgDir}/misma"

cp \
    "${hostRepoRoot}/wview/fs/${WVIEW_CONF_DIR}/html/chart_bg_bigger.png" \
    "${hostWviewImgDir}/fiobbio/chart_bg.png"

cp \
    "${hostRepoRoot}/wview/fs/${WVIEW_CONF_DIR}/html/chart_bg_bigger.png" \
    "${hostWviewImgDir}/misma/chart_bg.png"

mkdir -p "${hostWviewImgDir}"/{fiobbio,misma}/NOAA
mkdir -p "${hostWviewImgDir}"/{fiobbio,misma}/Archive

set -x
minikube status || minikube start --extra-config=apiserver.service-node-port-range=1-65535

# TODO: generate or commit files?
#cat ${scriptDir}/manifests/wview-template.yaml | WVIEW_INSTANCE_NAME=fiobbio envsubst '$WVIEW_INSTANCE_NAME' > /tmp/wview-fiobbio-generated.yaml
#cat ${scriptDir}/manifests/wview-template.yaml | WVIEW_INSTANCE_NAME=misma envsubst '$WVIEW_INSTANCE_NAME' > /tmp/wview-misma-generated.yaml

if ! kubectl get secrets cml-ftp-login >/dev/null; then
    kubectl create secret generic cml-ftp-login --from-env-file=/home/pi/secrets/cml_ftp_login_data.sh
fi

kubectl delete --wait=true -f ${scriptDir}/manifests/ || echo "WARN: ignoring kubectl error on delete"

kubectl apply -f ${scriptDir}/manifests/

set +x

touch "$scriptCompleted"
