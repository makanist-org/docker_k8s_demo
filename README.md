# Docker and Kubernetes Demo

This repository contains a demonstration of Docker and Kubernetes deployment for a Node.js application.

## Project Structure

- `app/` - Node.js application source code
- `k8s/` - Kubernetes configuration files
  - `argocd/` - ArgoCD setup files
  - `helm-argocd/` - Helm charts for ArgoCD
  - `ingress/` - Ingress controller setup
  - `manifests/` - Application manifests (deployment, service, ingress)
  - `namespaces.yaml` - Namespace definitions

## Prerequisites

- Docker Desktop with Kubernetes enabled
- kubectl
- Helm
- Git

## Setup Instructions

### 1. Clone the Repository

```bash
git clone git@github.com:makanist-org/docker_k8s_demo.git
cd docker_k8s_demo
```

### 2. Create Namespaces

```bash
kubectl apply -f k8s/namespaces.yaml
```

### 3. Deploy ArgoCD

```bash
./k8s/argocd/setup-argocd.sh
```

This script will:
- Install ArgoCD in the `argocd` namespace
- Generate SSH keys for Git repository access
- Create the necessary secrets and configurations
- Display the ArgoCD admin password

After running the script, add the displayed SSH public key to your GitHub repository's deploy keys.

### 4. Access ArgoCD UI

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:80
```

Then open http://localhost:8080 in your browser.
- Username: admin
- Password: (displayed during setup)

### 5. Access the Application

The application is deployed in the `docker-demo-namespace` namespace. To access it:

```bash
kubectl port-forward svc/nodejs-app -n docker-demo-namespace 3000:80
```

Then open http://localhost:3000/contacts in your browser.

## Ingress Setup (Optional)

An Ingress controller has been set up, but due to limitations with Kind/Docker Desktop, it's recommended to use port forwarding for local development.

If you want to try using Ingress:

```bash
# Install the Ingress controller
./k8s/ingress/install-ingress.sh

# Add hostname to /etc/hosts
echo "127.0.0.1 nodejs-app.local" | sudo tee -a /etc/hosts
```

Then try accessing http://nodejs-app.local/contacts (note: this may not work reliably in all environments).

## Development Workflow

1. Make changes to the application code
2. Build and push the Docker image:
   ```bash
   docker build -t your-dockerhub-username/nodejs-app:latest .
   docker push your-dockerhub-username/nodejs-app:latest
   ```
3. Update the image in the deployment manifest if needed
4. Commit and push changes to the Git repository
5. ArgoCD will automatically sync the changes to the cluster

## Troubleshooting

If you encounter issues:

1. Check pod status:
   ```bash
   kubectl get pods -n docker-demo-namespace
   ```

2. Check pod logs:
   ```bash
   kubectl logs -n docker-demo-namespace <pod-name>
   ```

3. Check ArgoCD application status:
   ```bash
   kubectl get application -n argocd
   ```

4. If port forwarding doesn't work, ensure the service is running:
   ```bash
   kubectl get svc -n docker-demo-namespace
   ```