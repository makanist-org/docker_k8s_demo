#!/bin/bash

# Docker Hub username
DOCKER_USERNAME="makanist"
IMAGE_NAME="docker-kubernetes-test"

# Read the current version from a version file, create if not exists
VERSION_FILE="version.txt"
if [ ! -f "$VERSION_FILE" ]; then
    echo "1.0.0" > "$VERSION_FILE"
fi

# Read current version and increment patch number
CURRENT_VERSION=$(cat "$VERSION_FILE")
NEW_VERSION=$(echo "$CURRENT_VERSION" | awk -F. '{$NF = $NF + 1;} 1' | sed 's/ /./g')

# Build the Docker image
echo "Building Docker image version $NEW_VERSION..."
docker build -t $DOCKER_USERNAME/$IMAGE_NAME:$NEW_VERSION .

# Tag the image
echo "Tagging image..."
docker tag $DOCKER_USERNAME/$IMAGE_NAME:$NEW_VERSION $DOCKER_USERNAME/$IMAGE_NAME:latest

# Push both version tag and latest tag
echo "Pushing to Docker Hub..."
docker push $DOCKER_USERNAME/$IMAGE_NAME:$NEW_VERSION
docker push $DOCKER_USERNAME/$IMAGE_NAME:latest

# Save the new version
echo $NEW_VERSION > "$VERSION_FILE"

echo "Successfully pushed version $NEW_VERSION to Docker Hub"