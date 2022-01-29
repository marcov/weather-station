## helm charts

### promtail and loki
```
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
#helm show readme grafana/promtail
helm upgrade --install promtail grafana/promtail --set "config.lokiAddress=http://loki:3100/loki/api/v1/push"
helm upgrade --install loki grafana/loki
```

### kube-state-metrics
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install --generate-name prometheus-community/kube-state-metrics
```

Remember to update prometheus config with the target url shown.
