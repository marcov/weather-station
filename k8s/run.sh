#!/bin/bash
#
# Start all the k8s weather stuff
#
set -euo pipefail

set -x
declare -r scriptDir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

# Used to store data shared among pods
declare -r k8s_pv_shared_path=/tmp/k8s-pv-shared

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

if [ -n "${removeEphemeral}" ]; then
    rm -rf "${k8s_pv_shared_path}"
    mkdir "${k8s_pv_shared_path}"
fi

# Create pv shared subdirs
mkdir -p "${k8s_pv_shared_path}"/{webcam,webshot,downloader,stations}

# Create the ddns ip cache file
${asRoot} touch "${k8s_pv_shared_path}"/ddns-ip
${asRoot} chmod 666 "${k8s_pv_shared_path}"/ddns-ip

for sta in ${stations[@]}; do
    mkdir -p "${k8s_pv_shared_path}"/stations/"${sta}"/NOAA
    mkdir -p "${k8s_pv_shared_path}"/stations/"${sta}"/Archive
done

set -x
minikube status || minikube start --driver none --extra-config=apiserver.service-node-port-range=1-65535

${scriptDir}/template-gen.sh ${genManifestsDir}

declare -r -A k8s_create_env_secrets=(
    [cml-ftp-login]="cml_ftp_login_data.sh"
    [webcam-login]="webcam_login_data.sh"
    [backblaze-info]="backblaze"
    [ddns-info]="ddns-info.txt"
)

declare -r -A k8s_create_file_secrets=(
    [grafana-config]="grafana.ini"
)

for sname in ${!k8s_create_env_secrets[@]}
do
    sfpath="${secretsDir}/${k8s_create_env_secrets[${sname}]}"
    echo "Checking and creating env secret ${sname} -> ${sfpath}"
    # Do not do anything if secret already exists
    kubectl create secret generic ${sname} --from-env-file=${sfpath} \
        --dry-run=client -o yaml | kubectl apply -f -
done

for sname in ${!k8s_create_file_secrets[@]}
do
    sfpath="${secretsDir}/${k8s_create_file_secrets[${sname}]}"
    echo "Checking and creating file secret ${sname} -> ${sfpath}"
    # Do not do anything if secret already exists
    kubectl create secret generic ${sname} --from-file=${sfpath} \
        --dry-run=client -o yaml | kubectl apply -f -
done

${asRoot} chmod o+r /home/pi/secrets/letsencrypt/live/meteo.fiobbio.com/privkey.pem
kubectl create secret tls tls-meteo-fiobbio-com \
    --cert=/home/pi/secrets/letsencrypt/live/meteo.fiobbio.com/fullchain.pem \
    --key=/home/pi/secrets/letsencrypt/live/meteo.fiobbio.com/privkey.pem \
     --dry-run=client -o yaml | kubectl apply -f -

${asRoot} chmod o-r /home/pi/secrets/letsencrypt/live/meteo.fiobbio.com/privkey.pem

kubectl create configmap config-localtime \
    --from-file=etc-localtime=/etc/localtime \
    --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f ${genManifestsDir} || echo "WARN: kubectl create got some errors (may be OK)..."
kubectl apply -f ${scriptDir}/manifests/ || echo "WARN: kubectl create got some errors (may be OK)..."

# FIXME: make sure network is up -- if not, running this will fail!
#helm repo add grafana https://grafana.github.io/helm-charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
#helm upgrade --install promtail grafana/promtail --set "config.lokiAddress=http://loki:3100/loki/api/v1/push"
#helm install --values ${scriptDir}/loki-values.yaml --set "loki.auth_enabled=false" loki grafana/loki

helm upgrade --install kube-state-metrics prometheus-community/kube-state-metrics
helm upgrade --install prometheus-node-exporter prometheus-community/prometheus-node-exporter

set +x

touch "$scriptCompleted"
