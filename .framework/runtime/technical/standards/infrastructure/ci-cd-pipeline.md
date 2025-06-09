# CI/CD Pipeline

## Overview

This document outlines the continuous integration and continuous deployment pipeline for the Nexus MCP server, including GitHub Actions workflows, deployment strategies, and release automation.

## GitHub Actions Workflows

### Main CI/CD Workflow

```yaml
# .github/workflows/main.yml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]
  release:
    types: [created]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  # Linting and Code Quality
  lint:
    name: Lint Code
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run ESLint
        run: npm run lint
      
      - name: Run Prettier
        run: npm run format:check
      
      - name: Check TypeScript
        run: npm run type-check

  # Unit and Integration Tests
  test:
    name: Run Tests
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [18, 20]
        mongodb-version: ['5.0', '6.0', '7.0']
    
    services:
      mongodb:
        image: mongo:${{ matrix.mongodb-version }}
        ports:
          - 27017:27017
        options: >-
          --health-cmd "mongosh --eval 'db.adminCommand({ ping: 1 })'"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run unit tests
        run: npm run test:unit
        env:
          MONGO_URI: mongodb://localhost:27017/nexus_test
      
      - name: Run integration tests
        run: npm run test:integration
        env:
          MONGO_URI: mongodb://localhost:27017/nexus_test
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
          flags: unittests
          name: codecov-umbrella

  # Security Scanning
  security:
    name: Security Scan
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          format: 'sarif'
          output: 'trivy-results.sarif'
      
      - name: Upload Trivy scan results
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy-results.sarif'
      
      - name: Run npm audit
        run: npm audit --production
      
      - name: Run Snyk security scan
        uses: snyk/actions/node@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          args: --severity-threshold=high

  # Build Docker Image
  build:
    name: Build Docker Image
    runs-on: ubuntu-latest
    needs: [lint, test, security]
    permissions:
      contents: read
      packages: write
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Log in to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
            type=sha,prefix={{branch}}-
      
      - name: Build and push Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          platforms: linux/amd64,linux/arm64
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
          build-args: |
            BUILD_DATE=${{ github.event.repository.updated_at }}
            VCS_REF=${{ github.sha }}
            VERSION=${{ steps.meta.outputs.version }}

  # Deploy to Development
  deploy-dev:
    name: Deploy to Development
    runs-on: ubuntu-latest
    needs: build
    if: github.ref == 'refs/heads/develop'
    environment:
      name: development
      url: https://dev.mcp.nexus.example.com
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Kubectl
        uses: azure/setup-kubectl@v3
        with:
          version: 'v1.28.0'
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      
      - name: Update kubeconfig
        run: |
          aws eks update-kubeconfig --name nexus-dev-cluster --region us-east-1
      
      - name: Deploy to Kubernetes
        run: |
          kubectl set image deployment/nexus-mcp \
            nexus-mcp=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:develop-${{ github.sha }} \
            -n nexus-dev
          kubectl rollout status deployment/nexus-mcp -n nexus-dev

  # Deploy to Staging
  deploy-staging:
    name: Deploy to Staging
    runs-on: ubuntu-latest
    needs: build
    if: github.ref == 'refs/heads/main'
    environment:
      name: staging
      url: https://staging.mcp.nexus.example.com
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy to staging
        uses: ./.github/actions/deploy
        with:
          environment: staging
          image-tag: main-${{ github.sha }}
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

  # Deploy to Production
  deploy-prod:
    name: Deploy to Production
    runs-on: ubuntu-latest
    needs: [build, deploy-staging]
    if: github.event_name == 'release'
    environment:
      name: production
      url: https://mcp.nexus.example.com
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy to production
        uses: ./.github/actions/deploy
        with:
          environment: production
          image-tag: ${{ github.event.release.tag_name }}
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          deployment-strategy: blue-green
```

### Reusable Deploy Action

```yaml
# .github/actions/deploy/action.yml
name: 'Deploy to Environment'
description: 'Deploy Nexus MCP to specified environment'

inputs:
  environment:
    description: 'Target environment'
    required: true
  image-tag:
    description: 'Docker image tag'
    required: true
  aws-access-key-id:
    description: 'AWS Access Key ID'
    required: true
  aws-secret-access-key:
    description: 'AWS Secret Access Key'
    required: true
  deployment-strategy:
    description: 'Deployment strategy (rolling, blue-green, canary)'
    required: false
    default: 'rolling'

runs:
  using: 'composite'
  steps:
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: ${{ inputs.aws-access-key-id }}
        aws-secret-access-key: ${{ inputs.aws-secret-access-key }}
        aws-region: us-east-1
    
    - name: Update kubeconfig
      shell: bash
      run: |
        aws eks update-kubeconfig --name nexus-${{ inputs.environment }}-cluster
    
    - name: Deploy with strategy
      shell: bash
      run: |
        case "${{ inputs.deployment-strategy }}" in
          "blue-green")
            ./scripts/deploy-blue-green.sh ${{ inputs.environment }} ${{ inputs.image-tag }}
            ;;
          "canary")
            ./scripts/deploy-canary.sh ${{ inputs.environment }} ${{ inputs.image-tag }}
            ;;
          *)
            ./scripts/deploy-rolling.sh ${{ inputs.environment }} ${{ inputs.image-tag }}
            ;;
        esac
```

## Build Stages

### 1. Lint Stage

```javascript
// .eslintrc.js
module.exports = {
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:security/recommended',
    'prettier'
  ],
  plugins: ['@typescript-eslint', 'security', 'import'],
  rules: {
    'no-console': 'error',
    'no-unused-vars': 'error',
    'security/detect-object-injection': 'warn',
    'import/order': ['error', {
      'groups': ['builtin', 'external', 'internal'],
      'newlines-between': 'always'
    }]
  }
};
```

### 2. Test Stage

```json
// package.json test scripts
{
  "scripts": {
    "test": "npm run test:unit && npm run test:integration",
    "test:unit": "jest --coverage --testPathPattern=unit",
    "test:integration": "jest --coverage --testPathPattern=integration",
    "test:e2e": "jest --coverage --testPathPattern=e2e",
    "test:performance": "k6 run tests/performance/load-test.js",
    "test:security": "npm audit && snyk test"
  }
}
```

### 3. Security Scan Stage

```yaml
# trivy-config.yaml
scan:
  security-checks:
    - vuln
    - config
    - secret
  
severity:
  - CRITICAL
  - HIGH
  - MEDIUM

ignore-unfixed: true

format: table
output: trivy-report.txt

vulnerability:
  type:
    - os
    - library
  
ignorefile: .trivyignore
```

### 4. Build Stage

```dockerfile
# Dockerfile
# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./
COPY tsconfig*.json ./

# Install dependencies
RUN npm ci --only=production && \
    npm ci --only=development

# Copy source code
COPY src ./src

# Build application
RUN npm run build

# Runtime stage
FROM node:20-alpine

WORKDIR /app

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Copy production dependencies
COPY package*.json ./
RUN npm ci --only=production && \
    npm cache clean --force

# Copy built application
COPY --from=builder /app/dist ./dist

# Switch to non-root user
USER nodejs

# Expose port
EXPOSE 3000

# Set environment
ENV NODE_ENV=production

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node healthcheck.js

# Start application
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "dist/index.js"]
```

## Branch Protection Rules

### Main Branch Protection

```yaml
# GitHub branch protection settings
protection_rules:
  main:
    required_status_checks:
      strict: true
      contexts:
        - "lint"
        - "test (18, 6.0)"
        - "test (20, 7.0)"
        - "security"
        - "build"
    
    enforce_admins: true
    
    required_pull_request_reviews:
      required_approving_review_count: 2
      dismiss_stale_reviews: true
      require_code_owner_reviews: true
      dismissal_restrictions:
        users: ["tech-lead", "senior-dev"]
    
    restrictions:
      users: ["release-bot"]
      teams: ["nexus-core-team"]
    
    allow_force_pushes: false
    allow_deletions: false
    required_conversation_resolution: true
```

### Develop Branch Protection

```yaml
protection_rules:
  develop:
    required_status_checks:
      strict: false
      contexts:
        - "lint"
        - "test (20, 7.0)"
    
    required_pull_request_reviews:
      required_approving_review_count: 1
      dismiss_stale_reviews: true
    
    allow_force_pushes: false
    allow_deletions: false
```

## Automated Versioning and Tagging

### Semantic Release Configuration

```javascript
// .releaserc.js
module.exports = {
  branches: ['main'],
  plugins: [
    '@semantic-release/commit-analyzer',
    '@semantic-release/release-notes-generator',
    ['@semantic-release/changelog', {
      changelogFile: 'CHANGELOG.md'
    }],
    ['@semantic-release/npm', {
      npmPublish: false
    }],
    '@semantic-release/github',
    ['@semantic-release/git', {
      assets: ['CHANGELOG.md', 'package.json', 'package-lock.json'],
      message: 'chore(release): ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}'
    }]
  ]
};
```

### Version Bump Workflow

```yaml
# .github/workflows/version-bump.yml
name: Version Bump

on:
  workflow_dispatch:
    inputs:
      version:
        description: 'Version type (patch, minor, major)'
        required: true
        default: 'patch'
        type: choice
        options:
          - patch
          - minor
          - major

jobs:
  version-bump:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          token: ${{ secrets.PAT }}
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
      
      - name: Bump version
        run: |
          git config user.name github-actions
          git config user.email github-actions@github.com
          npm version ${{ github.event.inputs.version }}
          git push && git push --tags
```

## Deployment Strategies

### Blue-Green Deployment

```bash
#!/bin/bash
# scripts/deploy-blue-green.sh

ENVIRONMENT=$1
IMAGE_TAG=$2
NAMESPACE="nexus-${ENVIRONMENT}"

# Get current deployment color
CURRENT_COLOR=$(kubectl get service nexus-mcp-active -n $NAMESPACE -o jsonpath='{.spec.selector.color}')
NEW_COLOR=$([[ "$CURRENT_COLOR" == "blue" ]] && echo "green" || echo "blue")

echo "Current deployment: $CURRENT_COLOR"
echo "Deploying to: $NEW_COLOR"

# Update the inactive deployment
kubectl set image deployment/nexus-mcp-$NEW_COLOR \
  nexus-mcp=ghcr.io/nexus/nexus-mcp:$IMAGE_TAG \
  -n $NAMESPACE

# Wait for rollout
kubectl rollout status deployment/nexus-mcp-$NEW_COLOR -n $NAMESPACE

# Run smoke tests
./scripts/smoke-test.sh $NAMESPACE nexus-mcp-$NEW_COLOR

if [ $? -eq 0 ]; then
  echo "Smoke tests passed. Switching traffic to $NEW_COLOR"
  
  # Switch service to new deployment
  kubectl patch service nexus-mcp-active -n $NAMESPACE \
    -p '{"spec":{"selector":{"color":"'$NEW_COLOR'"}}}'
  
  echo "Traffic switched successfully"
else
  echo "Smoke tests failed. Keeping traffic on $CURRENT_COLOR"
  exit 1
fi
```

### Canary Deployment

```bash
#!/bin/bash
# scripts/deploy-canary.sh

ENVIRONMENT=$1
IMAGE_TAG=$2
NAMESPACE="nexus-${ENVIRONMENT}"

# Deploy canary version
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nexus-mcp-canary
  namespace: $NAMESPACE
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nexus-mcp
      version: canary
  template:
    metadata:
      labels:
        app: nexus-mcp
        version: canary
    spec:
      containers:
      - name: nexus-mcp
        image: ghcr.io/nexus/nexus-mcp:$IMAGE_TAG
        ports:
        - containerPort: 3000
EOF

# Wait for canary deployment
kubectl rollout status deployment/nexus-mcp-canary -n $NAMESPACE

# Configure traffic split (10% to canary)
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: nexus-mcp-service
  namespace: $NAMESPACE
spec:
  selector:
    app: nexus-mcp
  ports:
  - port: 3000
    targetPort: 3000
EOF

# Monitor canary metrics
./scripts/monitor-canary.sh $NAMESPACE

# If successful, promote canary
if [ $? -eq 0 ]; then
  kubectl set image deployment/nexus-mcp \
    nexus-mcp=ghcr.io/nexus/nexus-mcp:$IMAGE_TAG \
    -n $NAMESPACE
  
  kubectl delete deployment nexus-mcp-canary -n $NAMESPACE
fi
```

## Rollback Procedures

### Automated Rollback

```yaml
# .github/workflows/rollback.yml
name: Rollback Deployment

on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to rollback'
        required: true
        type: choice
        options:
          - development
          - staging
          - production
      revision:
        description: 'Revision to rollback to (optional)'
        required: false

jobs:
  rollback:
    runs-on: ubuntu-latest
    environment: ${{ github.event.inputs.environment }}
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      
      - name: Rollback deployment
        run: |
          NAMESPACE="nexus-${{ github.event.inputs.environment }}"
          
          if [ -z "${{ github.event.inputs.revision }}" ]; then
            # Rollback to previous revision
            kubectl rollout undo deployment/nexus-mcp -n $NAMESPACE
          else
            # Rollback to specific revision
            kubectl rollout undo deployment/nexus-mcp \
              --to-revision=${{ github.event.inputs.revision }} \
              -n $NAMESPACE
          fi
          
          kubectl rollout status deployment/nexus-mcp -n $NAMESPACE
```

### Manual Rollback Procedure

```bash
#!/bin/bash
# scripts/manual-rollback.sh

# 1. Check current deployment status
kubectl get deployments -n nexus-prod
kubectl get rs -n nexus-prod

# 2. View rollout history
kubectl rollout history deployment/nexus-mcp -n nexus-prod

# 3. Rollback to previous version
kubectl rollout undo deployment/nexus-mcp -n nexus-prod

# 4. Or rollback to specific revision
kubectl rollout undo deployment/nexus-mcp --to-revision=42 -n nexus-prod

# 5. Monitor rollback status
kubectl rollout status deployment/nexus-mcp -n nexus-prod

# 6. Verify application health
curl -f https://mcp.nexus.example.com/health || exit 1
```

## Release Notes Automation

### Release Notes Generator

```javascript
// scripts/generate-release-notes.js
const { Octokit } = require('@octokit/rest');
const semver = require('semver');

async function generateReleaseNotes(owner, repo, tagName) {
  const octokit = new Octokit({
    auth: process.env.GITHUB_TOKEN
  });
  
  // Get previous release
  const { data: releases } = await octokit.repos.listReleases({
    owner,
    repo,
    per_page: 2
  });
  
  const previousTag = releases[1]?.tag_name || 'v0.0.0';
  
  // Get commits between tags
  const { data: comparison } = await octokit.repos.compareCommits({
    owner,
    repo,
    base: previousTag,
    head: tagName
  });
  
  // Categorize commits
  const features = [];
  const fixes = [];
  const breaking = [];
  const other = [];
  
  comparison.commits.forEach(commit => {
    const message = commit.commit.message;
    if (message.startsWith('feat:')) {
      features.push(message);
    } else if (message.startsWith('fix:')) {
      fixes.push(message);
    } else if (message.includes('BREAKING CHANGE:')) {
      breaking.push(message);
    } else {
      other.push(message);
    }
  });
  
  // Generate release notes
  let notes = `# Release ${tagName}\n\n`;
  
  if (breaking.length > 0) {
    notes += `## 🚨 Breaking Changes\n${breaking.map(m => `- ${m}`).join('\n')}\n\n`;
  }
  
  if (features.length > 0) {
    notes += `## ✨ Features\n${features.map(m => `- ${m}`).join('\n')}\n\n`;
  }
  
  if (fixes.length > 0) {
    notes += `## 🐛 Bug Fixes\n${fixes.map(m => `- ${m}`).join('\n')}\n\n`;
  }
  
  if (other.length > 0) {
    notes += `## 📝 Other Changes\n${other.map(m => `- ${m}`).join('\n')}\n\n`;
  }
  
  // Add contributors
  const contributors = [...new Set(comparison.commits.map(c => c.author.login))];
  notes += `## 👥 Contributors\n${contributors.map(c => `- @${c}`).join('\n')}\n`;
  
  return notes;
}
```

### Release Workflow

```yaml
# .github/workflows/release.yml
name: Create Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      
      - name: Generate release notes
        id: release_notes
        run: |
          node scripts/generate-release-notes.js \
            ${{ github.repository_owner }} \
            ${{ github.event.repository.name }} \
            ${{ github.ref_name }} > release-notes.md
      
      - name: Create Release
        uses: actions/create-release@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          tag_name: ${{ github.ref }}
          release_name: Release ${{ github.ref }}
          body_path: release-notes.md
          draft: false
          prerelease: ${{ contains(github.ref, '-rc') }}
```

## Pipeline Monitoring

### Metrics Collection

```yaml
# .github/workflows/metrics.yml
name: Pipeline Metrics

on:
  workflow_run:
    workflows: ["CI/CD Pipeline"]
    types: [completed]

jobs:
  collect-metrics:
    runs-on: ubuntu-latest
    steps:
      - name: Collect pipeline metrics
        run: |
          DURATION=${{ github.event.workflow_run.run_duration }}
          STATUS=${{ github.event.workflow_run.conclusion }}
          
          curl -X POST https://metrics.nexus.example.com/api/v1/pipeline \
            -H "Content-Type: application/json" \
            -d '{
              "workflow": "ci-cd",
              "duration": '$DURATION',
              "status": "'$STATUS'",
              "branch": "${{ github.event.workflow_run.head_branch }}",
              "commit": "${{ github.event.workflow_run.head_sha }}",
              "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"
            }'
```