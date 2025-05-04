#!/bin/bash

# Create namespace if not exists
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Apply new configuration
helm upgrade --install argocd ./k8s/helm-argocd/argo-cd \
  --namespace argocd \
  -f k8s/helm-argocd/values.yaml

# Wait for pods and service
echo "Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available deployment -l "app.kubernetes.io/name=argocd-server" -n argocd --timeout=300s

# Get admin password
echo "ArgoCD admin password:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo