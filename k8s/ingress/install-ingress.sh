#!/bin/bash

# Add the ingress-nginx repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Install the ingress-nginx controller
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.publishService.enabled=true \
  --set controller.service.type=NodePort \
  --set controller.hostPort.enabled=true \
  --set controller.hostPort.ports.http=80 \
  --set controller.hostPort.ports.https=443

# Wait for the ingress controller to be ready
echo "Waiting for ingress controller to be ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

# Apply the ingress resource for the nodejs app
kubectl apply -f k8s/manifests/ingress.yaml

echo "Ingress controller installed successfully!"
echo "Add this to your /etc/hosts file:"
echo "127.0.0.1 nodejs-app.local"
echo ""
echo "Then access your application at: http://nodejs-app.local/contacts"