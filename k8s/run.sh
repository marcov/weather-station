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

# Create required dirs
mkdir -p /tmp/{webcam,webshot,downloader}

# Create img folder
mkdir -p "${hostWviewImgDir}"

# Create the ddns ip cache file
${asRoot} touch /tmp/ddns-ip
${asRoot} chmod 666 /tmp/ddns-ip

for sta in ${stations[@]}; do
    cp -a \
        "${hostRepoRoot}/apps/wview/fs/${WVIEW_CONF_DIR}/html/classic/static/" \
        "${hostWviewImgDir}/${sta}"

    cp \
        "${hostRepoRoot}/apps/wview/fs/${WVIEW_CONF_DIR}/html/chart_bg_bigger.png" \
        "${hostWviewImgDir}/${sta}/chart_bg.png"

    mkdir -p "${hostWviewImgDir}"/${sta}/NOAA
    mkdir -p "${hostWviewImgDir}"/${sta}/Archive
done

set -x
minikube status || minikube start --driver none --extra-config=apiserver.service-node-port-range=1-65535

${scriptDir}/template-gen.sh ${genManifestsDir}

declare -r -A secrets_list=(
    [cml-ftp-login]="cml_ftp_login_data.sh"
    [webcam-login]="webcam_login_data.sh"
    [backblaze-info]="backblaze"
    [ddns-info]="ddns-info.txt"
)

for sname in ${!secrets_list[@]}
do
    sfpath="${secretsDir}/${secrets_list[${sname}]}"
    echo "Checking and creating secret ${sname} -> ${sfpath}"
    # Do not do anything if secret already exists
    kubectl create secret generic ${sname} --from-env-file=${sfpath} --dry-run=client -o yaml | kubectl apply -f -
done

kubectl apply -f ${genManifestsDir} || echo "WARN: kubectl create got some errors (may be OK)..."
kubectl apply -f ${scriptDir}/manifests/ || echo "WARN: kubectl create got some errors (may be OK)..."

# FIXME: network needs to be up for this to work!
#helm repo add grafana https://grafana.github.io/helm-charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
#helm upgrade --install promtail grafana/promtail --set "config.lokiAddress=http://loki:3100/loki/api/v1/push"
#helm install --values ${scriptDir}/loki-values.yaml --set "loki.auth_enabled=false" loki grafana/loki

helm upgrade --install kube-state-metrics prometheus-community/kube-state-metrics
helm upgrade --install prometheus-node-exporter prometheus-community/prometheus-node-exporter

set +x

touch "$scriptCompleted"
