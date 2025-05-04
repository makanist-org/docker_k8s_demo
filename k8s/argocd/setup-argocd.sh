#!/bin/bash

# Check if ArgoCD CLI is installed
if ! command -v argocd &> /dev/null; then
    echo "ArgoCD CLI not found. Installing..."
    brew install argocd
fi

# Delete existing secret if it exists
kubectl delete secret repo-secret -n argocd --ignore-not-found

# Create the repository secret
kubectl apply -f k8s/argocd/repo-secret.yaml

# Wait for secret to be created
sleep 3

# Get ArgoCD server URL and admin password
ARGOCD_SERVER=localhost:443
ADMIN_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# Login to ArgoCD
echo "Logging into ArgoCD..."
argocd login $ARGOCD_SERVER --username admin --password $ADMIN_PASSWORD --insecure

# Create the project and application
kubectl apply -f k8s/argocd/project.yaml
kubectl apply -f k8s/argocd/application.yaml

# Show status
echo "Checking repository connection..."
argocd repo list

echo "Checking application status..."
argocd app get nodejs-app