# Docker Standards

This document outlines the Docker best practices and standards for containerizing the Nexus MCP MongoDB integration services.

## Table of Contents

1. [Dockerfile Best Practices](#dockerfile-best-practices)
2. [Multi-Stage Builds](#multi-stage-builds)
3. [Security Scanning Requirements](#security-scanning-requirements)
4. [Image Tagging Conventions](#image-tagging-conventions)
5. [Docker Compose Standards](#docker-compose-standards)
6. [Container Resource Limits](#container-resource-limits)

## Dockerfile Best Practices

### General Principles

1. **One process per container**
2. **Minimize layers and image size**
3. **Use specific base image versions**
4. **Order instructions from least to most frequently changing**
5. **Use .dockerignore to exclude unnecessary files**

### Standard Dockerfile Structure

```dockerfile
# 1. ARG for build-time variables (before FROM)
ARG NODE_VERSION=20.11.0

# 2. Base image with specific version
FROM node:${NODE_VERSION}-alpine AS base

# 3. Metadata labels
LABEL maintainer="nexus-team@example.com"
LABEL version="1.0.0"
LABEL description="Nexus MCP MongoDB Integration Service"

# 4. Install system dependencies
RUN apk add --no-cache \
    curl \
    ca-certificates \
    && rm -rf /var/cache/apk/*

# 5. Create non-root user
RUN addgroup -g 1000 nexus && \
    adduser -D -u 1000 -G nexus nexus

# 6. Set working directory
WORKDIR /app

# 7. Copy dependency files first
COPY package*.json ./

# 8. Install dependencies
RUN npm ci --only=production && \
    npm cache clean --force

# 9. Copy application code
COPY --chown=nexus:nexus . .

# 10. Switch to non-root user
USER nexus

# 11. Expose ports
EXPOSE 3000

# 12. Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node healthcheck.js || exit 1

# 13. Set entrypoint and command
ENTRYPOINT ["node"]
CMD ["src/index.js"]
```

### Best Practices Examples

#### 1. Minimize Layers

```dockerfile
# Bad - Multiple RUN commands create multiple layers
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y git
RUN apt-get clean

# Good - Combine commands to minimize layers
RUN apt-get update && \
    apt-get install -y \
        curl \
        git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
```

#### 2. Use Specific Versions

```dockerfile
# Bad - Latest tag is unpredictable
FROM node:latest
FROM python:alpine

# Good - Specific versions ensure reproducibility
FROM node:20.11.0-alpine3.19
FROM python:3.11.7-alpine3.19
```

#### 3. Leverage Build Cache

```dockerfile
# Copy dependency files before source code
# This allows Docker to cache dependency installation

# For Node.js projects
COPY package*.json ./
RUN npm ci --only=production
COPY . .

# For Python projects
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
```

#### 4. Use .dockerignore

```bash
# .dockerignore
node_modules
npm-debug.log
.git
.gitignore
README.md
.env
.env.*
.vscode
.idea
coverage
.nyc_output
*.log
.DS_Store
**/*.test.js
**/*.spec.js
docs/
```

## Multi-Stage Builds

### TypeScript/Node.js Application

```dockerfile
# Build stage
FROM node:20.11.0-alpine AS builder

WORKDIR /build

# Copy dependency files
COPY package*.json ./
COPY tsconfig.json ./

# Install all dependencies (including dev)
RUN npm ci

# Copy source code
COPY src ./src

# Build the application
RUN npm run build

# Production stage
FROM node:20.11.0-alpine AS production

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

# Create non-root user
RUN addgroup -g 1000 nexus && \
    adduser -D -u 1000 -G nexus nexus

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install only production dependencies
RUN npm ci --only=production && \
    npm cache clean --force

# Copy built application from builder stage
COPY --from=builder --chown=nexus:nexus /build/dist ./dist

# Copy other necessary files
COPY --chown=nexus:nexus config ./config

USER nexus

EXPOSE 3000

# Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "dist/index.js"]
```

### Python Application with Dependencies

```dockerfile
# Build stage for compiling dependencies
FROM python:3.11.7-alpine AS builder

# Install build dependencies
RUN apk add --no-cache \
    gcc \
    musl-dev \
    libffi-dev \
    openssl-dev \
    python3-dev

WORKDIR /build

# Copy and install requirements
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Runtime stage
FROM python:3.11.7-alpine AS runtime

# Install runtime dependencies only
RUN apk add --no-cache \
    libffi \
    openssl

# Create non-root user
RUN addgroup -g 1000 nexus && \
    adduser -D -u 1000 -G nexus nexus

WORKDIR /app

# Copy installed packages from builder
COPY --from=builder /root/.local /home/nexus/.local

# Copy application code
COPY --chown=nexus:nexus . .

USER nexus

# Update PATH to include user packages
ENV PATH=/home/nexus/.local/bin:$PATH

EXPOSE 8000

CMD ["python", "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

## Security Scanning Requirements

### 1. Vulnerability Scanning

All images must pass vulnerability scanning before deployment:

```bash
# Using Trivy for vulnerability scanning
trivy image nexus-mcp:latest

# Fail on high or critical vulnerabilities
trivy image --exit-code 1 --severity HIGH,CRITICAL nexus-mcp:latest

# Generate security report
trivy image --format json --output security-report.json nexus-mcp:latest
```

### 2. Docker Security Best Practices

```dockerfile
# 1. Never run as root
USER nexus

# 2. Use read-only root filesystem when possible
# In docker-compose.yml or kubernetes:
# read_only: true

# 3. Drop unnecessary capabilities
# In docker-compose.yml:
# cap_drop:
#   - ALL
# cap_add:
#   - NET_BIND_SERVICE

# 4. No sudo or su in containers
# Don't install sudo package

# 5. Sign and verify images
# Use Docker Content Trust
# export DOCKER_CONTENT_TRUST=1

# 6. Scan for secrets
# Never include .env files or credentials
# Use build arguments for build-time secrets
ARG NPM_TOKEN
RUN echo "//registry.npmjs.org/:_authToken=${NPM_TOKEN}" > .npmrc && \
    npm ci && \
    rm .npmrc
```

### 3. Security Checklist

```yaml
# security-scan.yml - CI/CD security checks
security_checks:
  - vulnerability_scan:
      tool: trivy
      fail_on: HIGH,CRITICAL
      
  - secret_scan:
      tool: gitleaks
      config: .gitleaks.toml
      
  - dockerfile_lint:
      tool: hadolint
      config: .hadolint.yaml
      
  - base_image_check:
      allowed_registries:
        - docker.io
        - gcr.io
      required_image_signing: true
```

## Image Tagging Conventions

### Tagging Strategy

```bash
# Format: [REGISTRY/]NAMESPACE/IMAGE:TAG

# Development tags
nexus/mcp-server:dev
nexus/mcp-server:feature-add-auth
nexus/mcp-server:pr-123

# Version tags (following SemVer)
nexus/mcp-server:1.2.3
nexus/mcp-server:1.2.3-alpine
nexus/mcp-server:1.2

# Release tags
nexus/mcp-server:latest      # Latest stable
nexus/mcp-server:stable      # Current stable
nexus/mcp-server:edge        # Latest development

# Git commit SHA for traceability
nexus/mcp-server:sha-a1b2c3d
nexus/mcp-server:1.2.3-sha-a1b2c3d
```

### Automated Tagging Script

```bash
#!/bin/bash
# tag-docker-image.sh

IMAGE_NAME="nexus/mcp-server"
VERSION=$(cat package.json | jq -r .version)
GIT_SHA=$(git rev-parse --short HEAD)
BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Build the image
docker build -t ${IMAGE_NAME}:${VERSION} .

# Tag with multiple tags
docker tag ${IMAGE_NAME}:${VERSION} ${IMAGE_NAME}:latest
docker tag ${IMAGE_NAME}:${VERSION} ${IMAGE_NAME}:${VERSION}-sha-${GIT_SHA}

# Tag based on branch
if [ "$BRANCH" = "main" ]; then
    docker tag ${IMAGE_NAME}:${VERSION} ${IMAGE_NAME}:stable
elif [ "$BRANCH" = "develop" ]; then
    docker tag ${IMAGE_NAME}:${VERSION} ${IMAGE_NAME}:edge
else
    # Feature branch
    SAFE_BRANCH=$(echo $BRANCH | sed 's/[^a-zA-Z0-9]/-/g')
    docker tag ${IMAGE_NAME}:${VERSION} ${IMAGE_NAME}:${SAFE_BRANCH}
fi
```

## Docker Compose Standards

### Development Environment

```yaml
# docker-compose.yml
version: '3.8'

services:
  # Application service
  mcp-server:
    build:
      context: .
      dockerfile: Dockerfile
      target: development  # Use development stage
      args:
        - NODE_ENV=development
    image: nexus/mcp-server:dev
    container_name: nexus-mcp-server
    restart: unless-stopped
    env_file:
      - .env.development
    environment:
      - NODE_ENV=development
      - LOG_LEVEL=debug
    ports:
      - "3000:3000"
      - "9229:9229"  # Node.js debugger
    volumes:
      - ./src:/app/src:ro  # Read-only mount
      - ./config:/app/config:ro
      - node_modules:/app/node_modules  # Named volume for dependencies
    networks:
      - nexus-network
    depends_on:
      - mongodb
      - redis
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  # MongoDB service
  mongodb:
    image: mongo:7.0.5
    container_name: nexus-mongodb
    restart: unless-stopped
    environment:
      - MONGO_INITDB_ROOT_USERNAME=${MONGO_ROOT_USER}
      - MONGO_INITDB_ROOT_PASSWORD=${MONGO_ROOT_PASSWORD}
      - MONGO_INITDB_DATABASE=nexus_research
    ports:
      - "27017:27017"
    volumes:
      - mongodb_data:/data/db
      - ./scripts/mongo-init.js:/docker-entrypoint-initdb.d/init.js:ro
    networks:
      - nexus-network
    command: mongod --auth
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  # Redis for caching
  redis:
    image: redis:7.2.4-alpine
    container_name: nexus-redis
    restart: unless-stopped
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    networks:
      - nexus-network
    command: redis-server --appendonly yes
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 3

# Named volumes
volumes:
  node_modules:
  mongodb_data:
  redis_data:

# Networks
networks:
  nexus-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.28.0.0/16
```

### Override for Different Environments

```yaml
# docker-compose.override.yml (for local development)
version: '3.8'

services:
  mcp-server:
    build:
      target: development
    volumes:
      - ./src:/app/src  # Allow writes in development
      - ./tests:/app/tests
    command: npm run dev  # Use nodemon for hot reload

  mongodb:
    ports:
      - "27017:27017"  # Expose for local development
```

```yaml
# docker-compose.prod.yml (for production)
version: '3.8'

services:
  mcp-server:
    build:
      target: production
    restart: always
    deploy:
      replicas: 3
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
    logging:
      driver: "fluentd"
      options:
        fluentd-address: "localhost:24224"
        tag: "nexus.mcp"

  mongodb:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
        reservations:
          cpus: '1'
          memory: 2G
```

## Container Resource Limits

### Resource Planning

```yaml
# Resource allocation guidelines
services:
  # API Service (Node.js)
  api:
    deploy:
      resources:
        limits:
          cpus: '0.5'        # 0.5 CPU cores max
          memory: 512M       # 512MB RAM max
        reservations:
          cpus: '0.25'       # 0.25 CPU cores guaranteed
          memory: 256M       # 256MB RAM guaranteed

  # Worker Service (Python - Data Processing)
  worker:
    deploy:
      resources:
        limits:
          cpus: '2'          # 2 CPU cores for computation
          memory: 2G         # 2GB RAM for data processing
        reservations:
          cpus: '1'
          memory: 1G

  # Database
  mongodb:
    deploy:
      resources:
        limits:
          cpus: '4'
          memory: 8G
        reservations:
          cpus: '2'
          memory: 4G
```

### Monitoring Resource Usage

```bash
# Monitor container resource usage
docker stats

# Check specific container
docker stats nexus-mcp-server

# Export metrics for monitoring
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" \
  --no-stream > resource-usage.txt
```

### Resource Limit Best Practices

1. **Always set both limits and reservations**
   - Limits prevent runaway containers
   - Reservations ensure minimum performance

2. **Memory limits should include buffer**
   ```yaml
   # If app uses 256MB, set:
   reservations:
     memory: 256M
   limits:
     memory: 512M  # 2x buffer for spikes
   ```

3. **CPU limits for different workloads**
   ```yaml
   # I/O bound services (APIs)
   limits:
     cpus: '0.5'
   
   # CPU bound services (data processing)
   limits:
     cpus: '2'
   ```

4. **JVM-based applications**
   ```dockerfile
   # Set heap size to 50-75% of container memory
   ENV JAVA_OPTS="-Xmx384m -Xms384m"  # For 512M container
   ```

5. **Node.js applications**
   ```dockerfile
   # Set max old space size
   ENV NODE_OPTIONS="--max-old-space-size=384"  # For 512M container
   ```

### Health Checks and Restart Policies

```yaml
services:
  app:
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:3000/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
    
    restart: unless-stopped  # For development
    # restart: always        # For production
    
    # Restart with backoff
    deploy:
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
        window: 120s
```