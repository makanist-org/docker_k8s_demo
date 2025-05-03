#!/bin/bash

# Build the Docker image
echo "Building Docker image..."
docker build -t docker-demo-app:1.0 .

# Check if a container with the same name exists
if [ "$(docker ps -aq -f name=eks-demo-app)" ]; then
    echo "Removing existing container..."
    docker rm -f docker-demo-app
fi

# Run the container
echo "Starting container..."
docker run -d \
    --name docker-demo-app \
    -p 3000:3000 \
    docker-demo-app:1.0

echo "Container started! App is running on http://localhost:3000/contacts"