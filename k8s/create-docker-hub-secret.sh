#!/bin/bash

# Load environment variables
if [ -f .env ]; then
    source .env
else
    echo "Error: .env file not found"
    exit 1
fi

# Variables
NAMESPACE="docker-demo-namespace"
SECRET_NAME="docker-hub-creds"

# Check and remove existing secret
if kubectl get secret $SECRET_NAME -n $NAMESPACE >/dev/null 2>&1; then
    echo "Removing existing secret..."
    kubectl delete secret $SECRET_NAME -n $NAMESPACE
fi

# Log in to Docker Hub
echo "Logging in to Docker Hub..."
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

# Create Kubernetes secret
echo "Creating new Kubernetes secret..."
kubectl create secret docker-registry $SECRET_NAME \
    --namespace=$NAMESPACE \
    --docker-server=https://index.docker.io/v1/ \
    --docker-username="$DOCKER_USERNAME" \
    --docker-password="$DOCKER_PASSWORD" \
    --docker-email="$DOCKER_EMAIL"

echo "Secret creation complete!"