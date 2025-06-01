#!/bin/bash

# Load Docker credentials from .env file
if [ -f .env ]; then
  source .env
else
  echo "Error: .env file not found"
  exit 1
fi

# Apply the Image Updater resources
kubectl apply -f k8s/argocd/image-updater.yaml

# Create the Docker Hub secret
kubectl create secret docker-registry dockerhub-secret \
  --namespace argocd \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=$DOCKER_USERNAME \
  --docker-password=$DOCKER_PASSWORD \
  --docker-email=$DOCKER_EMAIL \
  --dry-run=client -o yaml | kubectl apply -f -

# Label the secret for Image Updater
kubectl label secret dockerhub-secret -n argocd argocd-image-updater.argoproj.io/secret-type=pull-secret

# Apply the updated application with Image Updater annotations
kubectl apply -f k8s/argocd/application.yaml

echo "ArgoCD Image Updater installed and configured successfully!"
echo "The updater will check for new images every 2 minutes."