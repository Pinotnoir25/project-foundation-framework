# Environment Configuration

## Overview

This document outlines the environment configuration strategy for the Nexus MCP server across different deployment tiers, including environment variable management, secret handling, and configuration structures.

## Environment Tiers

### Local Development

```bash
# .env.local
NODE_ENV=development
MCP_PORT=3000
LOG_LEVEL=debug

# SSH Tunnel Configuration
SSH_HOST=bastion.dev.nexus.internal
SSH_PORT=22
SSH_USER=nexus-dev
SSH_KEY_PATH=~/.ssh/nexus-dev-key

# MongoDB Configuration
MONGO_HOST=mongodb-dev.internal
MONGO_PORT=27017
MONGO_DATABASE=nexus_research_dev
MONGO_USERNAME=nexus_dev_user
MONGO_CONNECTION_TIMEOUT=30000
MONGO_POOL_SIZE=10

# Feature Flags
FEATURE_ADVANCED_QUERIES=true
FEATURE_BATCH_OPERATIONS=true
FEATURE_REAL_TIME_SYNC=false

# Development Tools
ENABLE_SWAGGER=true
ENABLE_GRAPHQL_PLAYGROUND=true
ENABLE_HOT_RELOAD=true
```

### Development Environment

```yaml
# k8s/dev/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nexus-mcp-config
  namespace: nexus-dev
data:
  NODE_ENV: "development"
  MCP_PORT: "3000"
  LOG_LEVEL: "info"
  
  # MongoDB Configuration
  MONGO_HOST: "mongodb-dev.nexus.internal"
  MONGO_PORT: "27017"
  MONGO_DATABASE: "nexus_research_dev"
  MONGO_CONNECTION_TIMEOUT: "30000"
  MONGO_POOL_SIZE: "20"
  
  # Feature Flags
  FEATURE_FLAGS: |
    {
      "advancedQueries": true,
      "batchOperations": true,
      "realTimeSync": false,
      "debugMode": true,
      "performanceMonitoring": true
    }
  
  # Service Discovery
  SERVICE_DISCOVERY_ENABLED: "true"
  SERVICE_REGISTRY_URL: "http://consul.nexus.internal:8500"
```

### Staging Environment

```yaml
# k8s/staging/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nexus-mcp-config
  namespace: nexus-staging
data:
  NODE_ENV: "staging"
  MCP_PORT: "3000"
  LOG_LEVEL: "info"
  
  # MongoDB Configuration
  MONGO_HOST: "mongodb-staging.nexus.internal"
  MONGO_PORT: "27017"
  MONGO_DATABASE: "nexus_research_staging"
  MONGO_CONNECTION_TIMEOUT: "20000"
  MONGO_POOL_SIZE: "50"
  
  # Performance Settings
  MAX_CONCURRENT_CONNECTIONS: "100"
  REQUEST_TIMEOUT: "60000"
  CACHE_TTL: "3600"
  
  # Feature Flags
  FEATURE_FLAGS: |
    {
      "advancedQueries": true,
      "batchOperations": true,
      "realTimeSync": true,
      "debugMode": false,
      "performanceMonitoring": true,
      "auditLogging": true
    }
```

### Production Environment

```yaml
# k8s/prod/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nexus-mcp-config
  namespace: nexus-prod
data:
  NODE_ENV: "production"
  MCP_PORT: "3000"
  LOG_LEVEL: "warn"
  
  # MongoDB Configuration
  MONGO_HOST: "mongodb-prod.nexus.internal"
  MONGO_PORT: "27017"
  MONGO_DATABASE: "nexus_research_prod"
  MONGO_CONNECTION_TIMEOUT: "15000"
  MONGO_POOL_SIZE: "100"
  
  # Performance Settings
  MAX_CONCURRENT_CONNECTIONS: "500"
  REQUEST_TIMEOUT: "30000"
  CACHE_TTL: "7200"
  
  # High Availability
  ENABLE_CIRCUIT_BREAKER: "true"
  CIRCUIT_BREAKER_THRESHOLD: "0.5"
  CIRCUIT_BREAKER_TIMEOUT: "60000"
  
  # Feature Flags
  FEATURE_FLAGS: |
    {
      "advancedQueries": true,
      "batchOperations": true,
      "realTimeSync": true,
      "debugMode": false,
      "performanceMonitoring": true,
      "auditLogging": true,
      "rateLimiting": true
    }
```

## Environment Variable Management

### Variable Naming Convention

```bash
# Format: <SCOPE>_<CATEGORY>_<SPECIFIC>
# Examples:
MCP_SERVER_PORT          # MCP server specific
MONGO_CONNECTION_STRING  # MongoDB specific
SSH_TUNNEL_HOST         # SSH tunnel specific
FEATURE_BATCH_OPS       # Feature flag
METRIC_EXPORT_INTERVAL  # Monitoring specific
```

### Environment Variable Hierarchy

```javascript
// src/config/configLoader.js
class ConfigLoader {
  static loadConfig() {
    return {
      // Priority order: ENV > Config File > Defaults
      server: {
        port: process.env.MCP_PORT || config.server?.port || 3000,
        host: process.env.MCP_HOST || config.server?.host || '0.0.0.0',
        timeout: parseInt(process.env.REQUEST_TIMEOUT || config.server?.timeout || 30000)
      },
      
      mongodb: {
        uri: process.env.MONGO_URI || this.buildMongoUri(),
        options: {
          poolSize: parseInt(process.env.MONGO_POOL_SIZE || 10),
          connectTimeoutMS: parseInt(process.env.MONGO_CONNECTION_TIMEOUT || 30000),
          serverSelectionTimeoutMS: 5000,
          useNewUrlParser: true,
          useUnifiedTopology: true
        }
      },
      
      features: this.parseFeatureFlags()
    };
  }
  
  static buildMongoUri() {
    const user = process.env.MONGO_USERNAME;
    const pass = process.env.MONGO_PASSWORD;
    const host = process.env.MONGO_HOST || 'localhost';
    const port = process.env.MONGO_PORT || 27017;
    const db = process.env.MONGO_DATABASE;
    
    if (user && pass) {
      return `mongodb://${user}:${pass}@${host}:${port}/${db}`;
    }
    return `mongodb://${host}:${port}/${db}`;
  }
  
  static parseFeatureFlags() {
    if (process.env.FEATURE_FLAGS) {
      return JSON.parse(process.env.FEATURE_FLAGS);
    }
    
    // Individual feature flag fallback
    return {
      advancedQueries: process.env.FEATURE_ADVANCED_QUERIES === 'true',
      batchOperations: process.env.FEATURE_BATCH_OPERATIONS === 'true',
      realTimeSync: process.env.FEATURE_REAL_TIME_SYNC === 'true'
    };
  }
}
```

## Secret Management

### Docker Secrets (Development)

```yaml
# docker-compose.secrets.yml
version: '3.8'

secrets:
  ssh_private_key:
    file: ./secrets/ssh/id_rsa
  mongo_password:
    file: ./secrets/mongo/password.txt
  api_keys:
    file: ./secrets/api/keys.json

services:
  nexus-mcp:
    secrets:
      - ssh_private_key
      - mongo_password
      - api_keys
    environment:
      - SSH_KEY_PATH=/run/secrets/ssh_private_key
      - MONGO_PASSWORD_FILE=/run/secrets/mongo_password
      - API_KEYS_FILE=/run/secrets/api_keys
```

### Kubernetes Secrets (Production)

```yaml
# k8s/secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: nexus-secrets
  namespace: nexus-prod
type: Opaque
stringData:
  ssh-host: "bastion.prod.nexus.internal"
  ssh-user: "nexus-prod"
  mongo-username: "nexus_prod_user"
data:
  ssh-private-key: |
    LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQo...
  mongo-password: |
    cHJvZHVjdGlvbl9wYXNzd29yZF9iYXNlNjQ=
  api-keys: |
    ewogICJtY3BfYXBpX2tleSI6ICJza19wcm9kXzEyMzQ1Njc4OTAiLAog...
```

### Secret Rotation Strategy

```bash
#!/bin/bash
# rotate-secrets.sh

# Function to rotate MongoDB password
rotate_mongo_password() {
  NEW_PASSWORD=$(openssl rand -base64 32)
  
  # Update in MongoDB
  mongo --eval "db.changeUserPassword('nexus_user', '$NEW_PASSWORD')"
  
  # Update Kubernetes secret
  kubectl create secret generic nexus-secrets \
    --from-literal=mongo-password="$NEW_PASSWORD" \
    --dry-run=client -o yaml | kubectl apply -f -
  
  # Trigger rolling update
  kubectl rollout restart deployment/nexus-mcp -n nexus-prod
}

# Function to rotate SSH keys
rotate_ssh_keys() {
  # Generate new key pair
  ssh-keygen -t rsa -b 4096 -f nexus-new-key -N ""
  
  # Deploy public key to bastion host
  ssh-copy-id -i nexus-new-key.pub nexus@bastion.prod.nexus.internal
  
  # Update Kubernetes secret
  kubectl create secret generic nexus-secrets \
    --from-file=ssh-private-key=nexus-new-key \
    --dry-run=client -o yaml | kubectl apply -f -
  
  # Cleanup old keys after verification
  rm nexus-new-key*
}
```

## Configuration File Structures

### Application Configuration

```yaml
# config/default.yaml
server:
  port: 3000
  host: 0.0.0.0
  cors:
    origin: "*"
    credentials: true
  
logging:
  level: info
  format: json
  outputs:
    - type: console
    - type: file
      path: /var/log/nexus-mcp/app.log
      maxSize: 100MB
      maxFiles: 10

mongodb:
  connectionOptions:
    poolSize: 10
    bufferMaxEntries: 0
    useNewUrlParser: true
    useUnifiedTopology: true
  collections:
    organizations: "organizations"
    users: "users"
    datasets: "datasets"
    variables: "variables"
    signals: "signals"
    actions: "actions"

mcp:
  protocol:
    version: "1.0"
    capabilities:
      - tools
      - resources
      - prompts
  tools:
    - name: "queryDatasets"
      description: "Query clinical trial datasets"
      inputSchema:
        type: object
        properties:
          query:
            type: object
          projection:
            type: object
          limit:
            type: number
    - name: "analyzeSignals"
      description: "Analyze statistical signals"
      inputSchema:
        type: object
        properties:
          datasetId:
            type: string
          threshold:
            type: number

cache:
  type: redis
  ttl: 3600
  keyPrefix: "nexus:mcp:"
  
monitoring:
  metrics:
    enabled: true
    port: 9090
    path: /metrics
  healthCheck:
    enabled: true
    path: /health
    interval: 30000
```

### Environment-Specific Overrides

```yaml
# config/production.yaml
server:
  port: 3000
  host: 0.0.0.0
  cors:
    origin: 
      - "https://nexus.example.com"
      - "https://app.nexus.example.com"
    credentials: true
  
logging:
  level: warn
  outputs:
    - type: console
      format: json
    - type: elasticsearch
      host: "elasticsearch.nexus.internal"
      index: "nexus-mcp-logs"

mongodb:
  connectionOptions:
    poolSize: 100
    maxPoolSize: 200
    minPoolSize: 50
    maxIdleTimeMS: 60000
    
rateLimiting:
  enabled: true
  windowMs: 60000
  max: 100
  message: "Too many requests from this IP"
  
security:
  helmet:
    enabled: true
    contentSecurityPolicy:
      directives:
        defaultSrc: ["'self'"]
        styleSrc: ["'self'", "'unsafe-inline'"]
  encryption:
    algorithm: "aes-256-gcm"
    keyRotationInterval: 86400000
```

## Feature Flags and Toggles

### Feature Flag Implementation

```javascript
// src/features/featureFlags.js
class FeatureFlags {
  constructor(config) {
    this.flags = config.features || {};
    this.overrides = new Map();
  }
  
  isEnabled(feature, context = {}) {
    // Check for user-specific override
    if (context.userId && this.overrides.has(`${feature}:${context.userId}`)) {
      return this.overrides.get(`${feature}:${context.userId}`);
    }
    
    // Check for organization-specific override
    if (context.orgId && this.overrides.has(`${feature}:org:${context.orgId}`)) {
      return this.overrides.get(`${feature}:org:${context.orgId}`);
    }
    
    // Check percentage rollout
    if (this.flags[feature]?.percentage) {
      const hash = this.hashString(context.userId || context.sessionId);
      return (hash % 100) < this.flags[feature].percentage;
    }
    
    // Default flag value
    return this.flags[feature]?.enabled || false;
  }
  
  setOverride(feature, value, scope = 'global', scopeId = null) {
    const key = scopeId ? `${feature}:${scope}:${scopeId}` : feature;
    this.overrides.set(key, value);
  }
  
  hashString(str) {
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash;
    }
    return Math.abs(hash);
  }
}

// Usage
const features = new FeatureFlags(config);

if (features.isEnabled('batchOperations', { userId: req.user.id })) {
  // Enable batch operations
}
```

### Feature Flag Configuration

```json
{
  "features": {
    "advancedQueries": {
      "enabled": true,
      "description": "Enable advanced MongoDB query capabilities",
      "rolloutPercentage": 100
    },
    "batchOperations": {
      "enabled": true,
      "description": "Allow batch processing of multiple documents",
      "rolloutPercentage": 100,
      "maxBatchSize": 1000
    },
    "realTimeSync": {
      "enabled": false,
      "description": "Enable real-time data synchronization",
      "rolloutPercentage": 0,
      "requiredPermissions": ["admin", "sync_manager"]
    },
    "aiAssistant": {
      "enabled": true,
      "description": "Enable AI-powered query assistance",
      "rolloutPercentage": 50,
      "modelVersion": "gpt-4"
    },
    "performanceMode": {
      "enabled": true,
      "description": "Enable performance optimizations",
      "conditions": {
        "minMemory": "1GB",
        "minCpu": "2",
        "environment": ["staging", "production"]
      }
    }
  }
}
```

## Environment-Specific Settings

### Development Settings

```javascript
// config/environments/development.js
module.exports = {
  debug: true,
  verboseLogging: true,
  mockServices: {
    enabled: true,
    services: ['email', 'sms']
  },
  database: {
    seedData: true,
    resetOnStart: false
  },
  security: {
    disableCsrf: true,
    allowInsecureConnections: true
  },
  development: {
    hotReload: true,
    sourceMaps: true,
    errorStackTraces: true
  }
};
```

### Production Settings

```javascript
// config/environments/production.js
module.exports = {
  debug: false,
  verboseLogging: false,
  compression: {
    enabled: true,
    level: 6
  },
  security: {
    forceHttps: true,
    hsts: {
      maxAge: 31536000,
      includeSubDomains: true,
      preload: true
    },
    rateLimiting: {
      enabled: true,
      windowMs: 15 * 60 * 1000,
      max: 100
    }
  },
  performance: {
    caching: {
      enabled: true,
      ttl: 3600
    },
    clustering: {
      enabled: true,
      workers: 'auto'
    }
  }
};
```

## Configuration Validation

```javascript
// src/config/validator.js
const Joi = require('joi');

const configSchema = Joi.object({
  server: Joi.object({
    port: Joi.number().port().required(),
    host: Joi.string().hostname().required()
  }).required(),
  
  mongodb: Joi.object({
    uri: Joi.string().uri().required(),
    options: Joi.object({
      poolSize: Joi.number().min(1).max(500),
      connectTimeoutMS: Joi.number().min(1000)
    })
  }).required(),
  
  features: Joi.object().pattern(
    Joi.string(),
    Joi.alternatives().try(
      Joi.boolean(),
      Joi.object({
        enabled: Joi.boolean(),
        percentage: Joi.number().min(0).max(100)
      })
    )
  )
});

function validateConfig(config) {
  const { error, value } = configSchema.validate(config, {
    abortEarly: false,
    allowUnknown: true
  });
  
  if (error) {
    throw new Error(`Configuration validation failed: ${error.message}`);
  }
  
  return value;
}
```