#!/bin/bash
# Clean build artifacts and rebuild with no cache

set -e

echo "Cleaning build artifacts and Docker cache..."

# Clean common frontend build directories
echo "Removing build directories..."
rm -rf dist/ build/ .next/ .nuxt/ node_modules/.cache/

# If using docker-compose
if [ -f "docker-compose.yml" ]; then
    echo "Stopping and removing containers..."
    docker-compose down -v
    
    echo "Building with --no-cache..."
    docker-compose build --no-cache
    
    echo "Starting fresh containers..."
    docker-compose up -d
else
    # Single container build
    IMAGE_NAME=${1:-"app"}
    DOCKERFILE=${2:-"Dockerfile"}
    
    echo "Building $IMAGE_NAME with --no-cache..."
    docker build --no-cache -t "$IMAGE_NAME" -f "$DOCKERFILE" .
fi

echo "Clean build complete!"