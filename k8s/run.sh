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
declare -r secretsDir="/home/pi/secrets"
declare -r genManifestsDir="/tmp/k8s_manifests"
declare removeEphemeral=
declare -r -a stations=( \
    fiobbio1 \
    fiobbio2 \
    misma \
)

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

for sta in ${stations[@]}; do
    cp -a \
        "${hostRepoRoot}/wview/fs/${WVIEW_CONF_DIR}/html/classic/static/" \
        "${hostWviewImgDir}/${sta}"

    cp \
        "${hostRepoRoot}/wview/fs/${WVIEW_CONF_DIR}/html/chart_bg_bigger.png" \
        "${hostWviewImgDir}/${sta}/chart_bg.png"

    mkdir -p "${hostWviewImgDir}"/${sta}/NOAA
    mkdir -p "${hostWviewImgDir}"/${sta}/Archive
done

set -x
minikube status || minikube start --driver none --extra-config=apiserver.service-node-port-range=1-65535

${scriptDir}/template-gen.sh ${genManifestsDir}

# all secrets
kubectl create secret generic cml-ftp-login --from-env-file=${secretsDir}/cml_ftp_login_data.sh
kubectl create secret generic webcam-login --from-env-file=${secretsDir}/webcam_login_data.sh
kubectl create secret generic backblaze-info --from-env-file=${secretsDir}/backblaze
kubectl create secret generic ddns-info --from-env-file=${secretsDir}/ddns-info.txt

kubectl apply -f ${scriptDir}/manifests/ ${genManifestsDir} || echo "WARN: kubectl create got some errors (may be OK)..."

# FIXME: network needs to be up for this to work!
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install promtail grafana/promtail --set "config.lokiAddress=http://loki:3100/loki/api/v1/push"
helm upgrade --install loki grafana/loki
helm upgrade --install kube-state-metrics prometheus-community/kube-state-metrics

set +x

touch "$scriptCompleted"
