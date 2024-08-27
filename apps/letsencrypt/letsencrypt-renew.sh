#!/bin/bash

# Don't set -e: the script should run to completion so that nginx is always
# restarted, even on error.
set +e

declare -r le_certs_path=/certificates
set -x -u -o pipefail

declare -r tmp_service_file=$(mktemp /tmp/k8s_service_nginx.XXXX)

# Redirect HTTP-80 traffic to this pod
kubectl patch service nginx --patch '{"spec":{"selector": {"app": "letsencrypt"}}}'

# dry run
#certbot renew  --logs-dir /tmp --config-dir "${le_certs_path}" --work-dir /tmp --standalone --dry-run

# actual run
certbot renew  --logs-dir /tmp --config-dir "${le_certs_path}" --work-dir /tmp --standalone

# Restore HTTP-80 traffic to nginx
kubectl patch service nginx --patch '{"spec":{"selector": {"app": "nginx"}}}'
