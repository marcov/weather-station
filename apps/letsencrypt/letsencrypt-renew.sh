#!/bin/bash

# Don't set -e: the script should run to completion.
set +e

set -x -u -o pipefail

declare -r le_config_data=/certificates

certbot renew \
    --verbose \
    --logs-dir /tmp \
    --config-dir "${le_config_data}" \
    --work-dir /tmp \
    --standalone \
    --deploy-hook \
"kubectl create secret tls tls-meteo-fiobbio-com \
     --cert=\"${le_config_data}\"/live/meteo.fiobbio.com/fullchain.pem \
     --key=\"${le_config_data}\"/live/meteo.fiobbio.com/privkey.pem \
     --dry-run=client -o yaml | kubectl apply -f -"

if (( $? != 0 )); then
    echo "ERR: certbot failed"

    cat /tmp/letsencrypt.log
    exit 1
fi

cat /tmp/letsencrypt.log

