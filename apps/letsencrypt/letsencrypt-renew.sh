#!/bin/bash

# Don't set -e: the script should run to completion, so that the webserver
# service is always restored, even on error.
#
# NOTE: POD_APP_LABEL must be exposed via the fieldRef downward API.

set +e
set -x -u -o pipefail

declare -r tls_certificates_path=/certificates

certbot renew --verbose --logs-dir /tmp --config-dir "${tls_certificates_path}" --work-dir /tmp --standalone
declare exitcode=$?

cat /tmp/letsencrypt.log

exit "${exitcode}"
