#!/bin/bash

# Login to ArgoCD
ARGOCD_SERVER=localhost:443
ADMIN_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
argocd login $ARGOCD_SERVER --username admin --password $ADMIN_PASSWORD --insecure

# Delete application
echo "Deleting ArgoCD application..."
kubectl delete application nodejs-app -n argocd

# Delete project
echo "Deleting ArgoCD project..."
kubectl delete appproject nodejs-project -n argocd

# Delete repository secret
echo "Deleting repository secret..."
kubectl delete secret repo-secret -n argocd

echo "Cleanup completed!"