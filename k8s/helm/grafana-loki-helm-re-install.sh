# Uninstall current release
helm uninstall loki -n grafana-monitoring

# Wait for pods to terminate
kubectl wait --for=delete pod --all -n grafana-monitoring --timeout=60s

# Install with new configuration
helm install loki ./k8s/helm/charts/loki-stack \
  --namespace grafana-monitoring \
  -f k8s/helm/loki-stack-values.yaml

# Verify node-exporter pods
kubectl get pods -n grafana-monitoring | grep node-exporter