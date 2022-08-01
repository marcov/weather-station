#!/bin/bash

set -euo pipefail

declare -i restartThreshold=5

set -x
podName=$(kubectl get pods -o=json | jq -r '.items[] | "\(.metadata.name) \(.status.containerStatuses[] | select(.restartCount>'${restartThreshold}').name)"' | awk '{print $1}')

if [[ ${podName} != '' ]]; then
    kubectl delete pod ${podName}
fi
