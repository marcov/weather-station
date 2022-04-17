#!/bin/bash

set -x -e -u -o pipefail

kubectl delete service nginx || { echo "No nginx service, already deleted?"; }

# dry run
sudo certbot renew  --logs-dir /tmp --config-dir ~/secrets/letsencrypt --work-dir /tmp --standalone --dry-run

# actual run
sudo certbot renew  --logs-dir /tmp --config-dir ~/secrets/letsencrypt --work-dir /tmp --standalone

kubectl apply -f k8s/manifests/nginx-no-ingress.yaml
kubectl delete pod -l app=nginx
