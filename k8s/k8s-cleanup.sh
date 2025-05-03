#!/bin/bash

NAMESPACE="docker-demo-namespace"

echo "Starting cleanup process..."

# Delete deployment and service
echo "Deleting deployment and service..."
kubectl delete -f app-server-deployment.yaml -n $NAMESPACE

# Wait for resources to be deleted
echo "Waiting for resources to terminate..."
sleep 5

# Verify resources are gone
echo "Checking remaining resources in namespace..."
REMAINING_RESOURCES=$(kubectl get all -n $NAMESPACE)

if [ -z "$REMAINING_RESOURCES" ]; then
    echo "All resources successfully removed!"
else
    echo "Some resources still exist in namespace:"
    echo "$REMAINING_RESOURCES"
fi

# Optionally delete namespace (uncommment if needed)
# echo "Deleting namespace..."
# kubectl delete namespace $NAMESPACE

echo "Cleanup complete!"