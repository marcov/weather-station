#!/bin/bash

# Don't set -e: the script should run to completion so that nginx is always
# restarted, even on error.
set +e

set -x -u -o pipefail

# service delte may fail, if it does not exist - just keep going.
kubectl delete service nginx

# dry run
sudo certbot renew  --logs-dir /tmp --config-dir ~/secrets/letsencrypt --work-dir /tmp --standalone --dry-run

# actual run
sudo certbot renew  --logs-dir /tmp --config-dir ~/secrets/letsencrypt --work-dir /tmp --standalone

kubectl apply -f k8s/manifests/nginx-no-ingress.yaml
kubectl delete pod -l app=nginx
