# Create directory
mkdir -p k8s/helm-argocd

# Add ArgoCD Helm repository
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Download the chart
helm pull argo/argo-cd --untar --untardir k8s/helm-argocd
