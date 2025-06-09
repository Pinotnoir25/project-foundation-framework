#!/bin/bash
# Force build without cache to ensure fresh builds

set -e

echo "Building Docker image with --no-cache flag..."
echo "This ensures all layers are rebuilt from scratch"

# Default values
IMAGE_NAME=${1:-"app"}
DOCKERFILE=${2:-"Dockerfile"}

# Build with no cache
docker build --no-cache -t "$IMAGE_NAME" -f "$DOCKERFILE" .

echo "Build complete. Image: $IMAGE_NAME"
echo "Remember: Always use --no-cache for frontend apps to prevent stale assets!"