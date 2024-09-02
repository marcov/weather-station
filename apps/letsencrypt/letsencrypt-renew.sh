#!/bin/bash

# Don't set -e: the script should run to completion, so that the webserver
# service is always restored, even on error.
#
# NOTE: POD_APP_LABEL must be exposed via the fieldRef downward API.

set +e
set -x -u -o pipefail

declare -r tls_certificates_path=/certificates
declare -r webserver_svc=webserver

# Obtain default webserver app
declare default_webserver_app=
default_webserver_app="$(kubectl get service "${webserver_svc}" -o=json | jq -r ".spec.selector.app")"

# Redirect webserver traffic to this pod
kubectl patch service "${webserver_svc}" --patch '{"spec":{"selector": {"app": "'"${POD_APP_LABEL}"'"}}}'

certbot renew --verbose --logs-dir /tmp --config-dir "${tls_certificates_path}" --work-dir /tmp --standalone

# Restore webserver traffic to default app
kubectl patch service "${webserver_svc}" --patch '{"spec": {"selector": {"app": "'"${default_webserver_app}"'"}}}'
