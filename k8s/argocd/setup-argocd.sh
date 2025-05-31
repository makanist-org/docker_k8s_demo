#!/bin/bash

# Create namespace
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Install ArgoCD using Helm
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd argo/argo-cd \
  --namespace argocd \
  --version 7.9.0 \
  --set server.service.type=LoadBalancer \
  --set server.extraArgs[0]=--insecure \
  --set redis.enabled=true \
  --set dex.enabled=false

# Wait for ArgoCD to be ready
echo "Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available deployment -l "app.kubernetes.io/name=argocd-server" -n argocd --timeout=300s

# Create SSH key for GitHub access
SSH_KEY_FILE="/tmp/argocd_ssh_key"
echo "Generating SSH key for ArgoCD..."
ssh-keygen -t rsa -b 4096 -C "argocd@example.com" -f "$SSH_KEY_FILE" -N ""
echo ""
echo "Add this public key to your GitHub repository deploy keys:"
cat "$SSH_KEY_FILE.pub"
echo ""

# Create known_hosts file
ssh-keyscan github.com > /tmp/known_hosts

# Create repository secret
kubectl create secret generic github-repo-secret \
  --namespace argocd \
  --from-file=sshPrivateKey="$SSH_KEY_FILE" \
  --from-file=known_hosts=/tmp/known_hosts \
  --from-literal=url=git@github.com:makanist-org/docker_k8s_demo.git \
  --from-literal=type=git \
  --dry-run=client -o yaml | \
  kubectl label --local -f - argocd.argoproj.io/secret-type=repository --overwrite -o yaml | \
  kubectl apply -f -

# Apply project and application
kubectl apply -f k8s/argocd/project.yaml
kubectl apply -f k8s/argocd/application.yaml

# Clean up temporary files
rm "$SSH_KEY_FILE" "$SSH_KEY_FILE.pub" /tmp/known_hosts

# Get ArgoCD admin password
echo ""
echo "ArgoCD admin password:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo ""
echo "Access ArgoCD UI using port-forward:"
echo "kubectl port-forward svc/argocd-server -n argocd 8080:80"
echo "Then open http://localhost:8080 in your browser"