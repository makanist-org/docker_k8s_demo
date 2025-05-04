#!/bin/bash

# Generate a random secret key
SECRET_KEY=$(openssl rand -base64 32)

# Create namespace if it doesn't exist
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Create the secret
kubectl create secret generic argocd-secret \
  --namespace argocd \
  --from-literal=server.secretkey="${SECRET_KEY}" \
  --dry-run=client -o yaml | kubectl apply -f -