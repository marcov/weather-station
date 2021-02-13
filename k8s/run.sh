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

echo "NOTE: run with the env INTERACTIVE=1 for interactive startup!"
echo "INFO: starting up in 1 seconds"
sleep 1

#
# TODO: find a better way to store wview img in a tmpfs shared volume b/w host and containers!
#
if [ -n "${removeEphemeral}" ]; then
    rm -rf "${hostWviewImgDir}"
    mkdir "${hostWviewImgDir}"
fi

mkdir -p "${hostWviewImgDir}"/{fiobbio,misma}/NOAA
mkdir -p "${hostWviewImgDir}"/{fiobbio,misma}/Archive

# Provision webcam,webhost folders
mkdir -p /tmp/{webcam,webshot}

# Provision img folder
cp -a \
    "${hostRepoRoot}/wview/fs/${WVIEW_CONF_DIR}/html/classic/static" \
    "${hostWviewImgDir}/fiobbio"

cp -a \
    "${hostRepoRoot}/wview/fs/${WVIEW_CONF_DIR}/html/classic/static" \
    "${hostWviewImgDir}/misma"

[ "${1:-}" = "-i" ] && { echo "INFO: INTERACTIVE mode"; INTERACTIVE=1; }

set -x
minikube status || minikube start --extra-config=apiserver.service-node-port-range=1-65535

if ! kubectl get secrets cml-ftp-login >/dev/null; then
    kubectl create secret generic cml-ftp-login --from-env-file=/home/pi/secrets/cml_ftp_login_data.sh
fi

kubectl delete --wait=true pod wview-fiobbio || echo "INFO: nothing to delete"
kubectl delete --wait=true pod wview-misma || echo "INFO: nothing to delete"
kubectl delete --wait=true deployment nginx || echo "INFO: nothing to delete"
kubectl delete --wait=true deployment grafana || echo "INFO: nothing to delete"

kubectl apply -f ${scriptDir}/wview.yaml
kubectl apply -f ${scriptDir}/grafana-hostpath.yaml
kubectl apply -f ${scriptDir}/nginx-no-ingress.yaml

set +x

touch "$scriptCompleted"
