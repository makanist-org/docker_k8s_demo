# Setup Helm Repository
# Add Grafana repo
helm repo add grafana https://grafana.github.io/helm-charts

# Update helm repos
helm repo update

# Create helm directory if not exists
mkdir -p k8s/helm/charts

# Download the chart
helm pull grafana/loki-stack --untar --untardir k8s/helm/charts

# Install Loki stack from local chart
helm install loki ./k8s/helm/charts/loki-stack \
  --namespace grafana-monitoring \
  -f k8s/helm/loki-stack-values.yaml

# Get Grafana admin password
kubectl get secret --namespace grafana-monitoring loki-grafana \
  -o jsonpath="{.data.admin-password}" | base64 --decode

# To upgrade helm chart
helm upgrade loki ./k8s/helm/charts/loki-stack \
  --namespace grafana-monitoring \
  -f k8s/helm/loki-stack-values.yaml

# To verify installation
kubectl get pods -n grafana-monitoring
kubectl get svc -n grafana-monitoring

# Deployment Management
## Check Deployment Status
kubectl get deployments -n grafana-monitoring
kubectl rollout history deployment loki-grafana -n grafana-monitoring

## Roll Out Changes
kubectl rollout restart deployment loki-grafana -n grafana-monitoring
kubectl rollout restart deployment loki-prometheus-server -n grafana-monitoring

## Monitor Rollout
kubectl rollout status deployment loki-grafana -n grafana-monitoring
kubectl get pods -n grafana-monitoring -w

## Rollback if Needed
kubectl rollout undo deployment loki-grafana -n grafana-monitoring

# Get admin password
kubectl get secret --namespace grafana-monitoring loki-grafana \
  -o jsonpath="{.data.admin-password}" | base64 --decode

# Uninstall current release
helm uninstall loki -n grafana-monitoring

# Wait for pods to terminate
kubectl wait --for=delete pod --all -n grafana-monitoring --timeout=90s

# Verify node-exporter pods
kubectl get pods -n grafana-monitoring | grep node-exporter