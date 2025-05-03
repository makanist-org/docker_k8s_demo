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