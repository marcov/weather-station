#!/bin/bash

# Don't set -e: the script should run to completion so that nginx is always
# restarted, even on error.
set +e

set -x -u -o pipefail

# dump service
tmp_service_file=$(mktemp /tmp/k8s_service_nginx.XXXX)
kubectl get service -o yaml nginx > ${tmp_service_file}

# service delete may fail, if it does not exist - just keep going.
kubectl delete service nginx

# dry run
#sudo certbot renew  --logs-dir /tmp --config-dir ~/secrets/letsencrypt --work-dir /tmp --standalone --dry-run

# actual run
sudo certbot renew  --logs-dir /tmp --config-dir ~/secrets/letsencrypt --work-dir /tmp --standalone

# restore & restart nginx
kubectl apply -f ${tmp_service_file}
kubectl delete pod -l app=nginx
