#!/bin/bash

# Stop and remove the container if it exists
if [ "$(docker ps -aq -f name=docker-demo-app)" ]; then
    echo "Stopping and removing container..."
    docker stop docker-demo-app
    docker rm docker-demo-app
    echo "Container removed successfully"
fi

# Remove the image if it exists
if [ "$(docker images -q docker-demo-app:1.0)" ]; then
    echo "Removing docker image..."
    docker rmi docker-demo-app:1.0
    echo "Image removed successfully"
fi

echo "Cleanup complete!"