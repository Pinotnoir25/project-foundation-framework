# MongoDB Infrastructure for Nexus MCP

## Overview

This document provides comprehensive guidance for MongoDB infrastructure setup, configuration, and management specific to the Nexus MCP project's research database requirements. The database contains CMP metadata and is accessed securely through SSH tunnels.

## SSH Tunnel Configuration

### SSH Tunnel Architecture

```mermaid
graph LR
    A[MCP Server] --> B[SSH Tunnel Client]
    B --> C[SSH Bastion Host]
    C --> D[MongoDB Primary]
    C --> E[MongoDB Secondary 1]
    C --> F[MongoDB Secondary 2]
    
    style A fill:#f9f,stroke:#333,stroke-width:2px
    style D fill:#9f9,stroke:#333,stroke-width:2px
```

### SSH Tunnel Setup

```bash
#!/bin/bash
# scripts/setup-ssh-tunnel.sh

# Configuration
SSH_HOST="${SSH_HOST:-bastion.nexus.internal}"
SSH_PORT="${SSH_PORT:-22}"
SSH_USER="${SSH_USER:-nexus-mcp}"
SSH_KEY="${SSH_KEY:-~/.ssh/nexus-mcp-key}"
LOCAL_PORT="${LOCAL_PORT:-27017}"
MONGO_HOST="${MONGO_HOST:-mongodb.nexus.internal}"
MONGO_PORT="${MONGO_PORT:-27017}"

# Create persistent SSH tunnel with auto-reconnect
create_ssh_tunnel() {
    while true; do
        ssh -N -L ${LOCAL_PORT}:${MONGO_HOST}:${MONGO_PORT} \
            -o ServerAliveInterval=60 \
            -o ServerAliveCountMax=3 \
            -o ExitOnForwardFailure=yes \
            -o StrictHostKeyChecking=no \
            -o UserKnownHostsFile=/dev/null \
            -i ${SSH_KEY} \
            ${SSH_USER}@${SSH_HOST} -p ${SSH_PORT}
        
        echo "SSH tunnel disconnected. Reconnecting in 5 seconds..."
        sleep 5
    done
}

# Run tunnel in background
create_ssh_tunnel &
SSH_TUNNEL_PID=$!

# Save PID for cleanup
echo $SSH_TUNNEL_PID > /var/run/ssh-tunnel.pid
```

### Docker SSH Tunnel Container

```dockerfile
# docker/ssh-tunnel/Dockerfile
FROM alpine:3.18

RUN apk add --no-cache \
    openssh-client \
    autossh \
    bash

# Create non-root user
RUN adduser -D -s /bin/bash tunnel

# Copy scripts
COPY scripts/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

USER tunnel

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
```

```bash
#!/bin/bash
# docker/ssh-tunnel/scripts/entrypoint.sh

# Validate environment variables
if [ -z "$SSH_HOST" ] || [ -z "$MONGO_HOST" ]; then
    echo "Error: Required environment variables not set"
    exit 1
fi

# Setup SSH key
if [ -f "/run/secrets/ssh_key" ]; then
    cp /run/secrets/ssh_key ~/.ssh/id_rsa
    chmod 600 ~/.ssh/id_rsa
fi

# Configure SSH client
cat > ~/.ssh/config <<EOF
Host tunnel
    HostName ${SSH_HOST}
    Port ${SSH_PORT:-22}
    User ${SSH_USER}
    IdentityFile ~/.ssh/id_rsa
    ServerAliveInterval 60
    ServerAliveCountMax 3
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
EOF

# Create tunnel using autossh for automatic reconnection
exec autossh -M 0 -N \
    -L ${LOCAL_PORT:-27017}:${MONGO_HOST}:${MONGO_PORT:-27017} \
    tunnel
```

### Kubernetes SSH Tunnel Sidecar

```yaml
# k8s/ssh-tunnel-sidecar.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: ssh-tunnel-config
  namespace: nexus
data:
  ssh_config: |
    Host bastion
        HostName bastion.nexus.internal
        Port 22
        User nexus-mcp
        ServerAliveInterval 60
        ServerAliveCountMax 3
        StrictHostKeyChecking no
        UserKnownHostsFile /dev/null

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nexus-mcp-with-tunnel
  namespace: nexus
spec:
  template:
    spec:
      containers:
      # Main MCP container
      - name: nexus-mcp
        image: nexus-mcp:latest
        env:
        - name: MONGO_URI
          value: "mongodb://localhost:27017/nexus_research"
        
      # SSH tunnel sidecar
      - name: ssh-tunnel
        image: nexus-ssh-tunnel:latest
        env:
        - name: SSH_HOST
          valueFrom:
            secretKeyRef:
              name: ssh-tunnel-secret
              key: host
        - name: MONGO_HOST
          value: "mongodb.internal"
        - name: LOCAL_PORT
          value: "27017"
        volumeMounts:
        - name: ssh-key
          mountPath: /home/tunnel/.ssh/id_rsa
          subPath: id_rsa
          readOnly: true
        - name: ssh-config
          mountPath: /home/tunnel/.ssh/config
          subPath: ssh_config
        livenessProbe:
          exec:
            command:
            - /bin/sh
            - -c
            - "nc -z localhost 27017"
          initialDelaySeconds: 10
          periodSeconds: 10
        
      volumes:
      - name: ssh-key
        secret:
          secretName: ssh-tunnel-secret
          defaultMode: 0600
      - name: ssh-config
        configMap:
          name: ssh-tunnel-config
```

## Connection Pooling Settings

### Connection Pool Configuration

```javascript
// src/config/mongodb.js
const { MongoClient } = require('mongodb');

class MongoDBConnectionManager {
  constructor(config) {
    this.config = {
      // Connection pool settings optimized for research workloads
      minPoolSize: config.minPoolSize || 10,
      maxPoolSize: config.maxPoolSize || 100,
      maxIdleTimeMS: config.maxIdleTimeMS || 60000,
      waitQueueTimeoutMS: config.waitQueueTimeoutMS || 5000,
      
      // Connection settings
      connectTimeoutMS: config.connectTimeoutMS || 30000,
      socketTimeoutMS: config.socketTimeoutMS || 0, // No timeout for long queries
      serverSelectionTimeoutMS: config.serverSelectionTimeoutMS || 30000,
      
      // Retry settings
      retryWrites: true,
      retryReads: true,
      
      // Monitoring
      monitorCommands: true,
      
      // Compression for large datasets
      compressors: ['snappy', 'zlib'],
      
      // Read preference for research workloads
      readPreference: 'secondaryPreferred',
      readConcern: { level: 'majority' },
      
      // Write concern
      writeConcern: {
        w: 'majority',
        j: true,
        wtimeout: 5000
      }
    };
    
    this.client = null;
    this.connectionRetries = 0;
    this.maxRetries = 5;
  }
  
  async connect() {
    try {
      // Build connection URI
      const uri = this.buildConnectionUri();
      
      // Create MongoClient with optimized settings
      this.client = new MongoClient(uri, this.config);
      
      // Set up event listeners
      this.setupEventListeners();
      
      // Connect with retry logic
      await this.connectWithRetry();
      
      console.log('MongoDB connected successfully');
      return this.client;
    } catch (error) {
      console.error('MongoDB connection failed:', error);
      throw error;
    }
  }
  
  async connectWithRetry() {
    while (this.connectionRetries < this.maxRetries) {
      try {
        await this.client.connect();
        this.connectionRetries = 0;
        return;
      } catch (error) {
        this.connectionRetries++;
        console.warn(`Connection attempt ${this.connectionRetries} failed:`, error.message);
        
        if (this.connectionRetries >= this.maxRetries) {
          throw new Error('Maximum connection retries exceeded');
        }
        
        // Exponential backoff
        const delay = Math.min(1000 * Math.pow(2, this.connectionRetries), 30000);
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }
  }
  
  setupEventListeners() {
    // Connection pool monitoring
    this.client.on('connectionPoolCreated', (event) => {
      console.log('Connection pool created:', event.address);
    });
    
    this.client.on('connectionPoolClosed', (event) => {
      console.log('Connection pool closed:', event.address);
    });
    
    this.client.on('connectionCreated', (event) => {
      console.log('New connection created:', event.connectionId);
    });
    
    this.client.on('connectionClosed', (event) => {
      console.log('Connection closed:', event.connectionId, event.reason);
    });
    
    // Monitor pool statistics
    setInterval(() => {
      this.logPoolStatistics();
    }, 60000); // Every minute
  }
  
  logPoolStatistics() {
    const stats = {
      available: this.client.topology?.s?.pool?.availableConnectionCount || 0,
      pending: this.client.topology?.s?.pool?.pendingConnectionCount || 0,
      current: this.client.topology?.s?.pool?.currentConnectionCount || 0,
      maxSize: this.config.maxPoolSize
    };
    
    console.log('Connection pool stats:', stats);
    
    // Alert if pool is exhausted
    if (stats.available === 0 && stats.pending > 10) {
      console.warn('Connection pool may be exhausted!');
    }
  }
  
  buildConnectionUri() {
    const host = process.env.MONGO_HOST || 'localhost';
    const port = process.env.MONGO_PORT || 27017;
    const database = process.env.MONGO_DATABASE || 'nexus_research';
    const user = process.env.MONGO_USERNAME;
    const password = process.env.MONGO_PASSWORD;
    
    let uri = 'mongodb://';
    
    if (user && password) {
      uri += `${encodeURIComponent(user)}:${encodeURIComponent(password)}@`;
    }
    
    uri += `${host}:${port}/${database}`;
    
    // Add replica set if configured
    if (process.env.MONGO_REPLICA_SET) {
      uri += `?replicaSet=${process.env.MONGO_REPLICA_SET}`;
    }
    
    return uri;
  }
}
```

### Environment-Specific Pool Settings

```yaml
# Development
development:
  mongodb:
    minPoolSize: 5
    maxPoolSize: 20
    maxIdleTimeMS: 120000
    socketTimeoutMS: 60000

# Staging
staging:
  mongodb:
    minPoolSize: 20
    maxPoolSize: 50
    maxIdleTimeMS: 60000
    socketTimeoutMS: 120000

# Production
production:
  mongodb:
    minPoolSize: 50
    maxPoolSize: 200
    maxIdleTimeMS: 30000
    socketTimeoutMS: 0  # No timeout for long research queries
```

## Replica Set Configuration

### Replica Set Architecture

```mermaid
graph TB
    subgraph "Primary Data Center"
        P[Primary Node]
        S1[Secondary Node 1]
        S2[Secondary Node 2]
    end
    
    subgraph "Secondary Data Center"
        S3[Secondary Node 3 - Priority 0]
        A[Arbiter]
    end
    
    P -.-> S1
    P -.-> S2
    P -.-> S3
    P -.-> A
    
    style P fill:#9f9,stroke:#333,stroke-width:4px
    style S1 fill:#ff9,stroke:#333,stroke-width:2px
    style S2 fill:#ff9,stroke:#333,stroke-width:2px
    style S3 fill:#ff9,stroke:#333,stroke-width:2px
    style A fill:#f99,stroke:#333,stroke-width:2px
```

### Replica Set Initialization

```javascript
// scripts/init-replica-set.js
const replicaSetConfig = {
  _id: "nexusResearchRS",
  members: [
    {
      _id: 0,
      host: "mongodb-primary.nexus.internal:27017",
      priority: 10,
      tags: {
        dc: "primary",
        rack: "rack1"
      }
    },
    {
      _id: 1,
      host: "mongodb-secondary1.nexus.internal:27017",
      priority: 5,
      tags: {
        dc: "primary",
        rack: "rack2"
      }
    },
    {
      _id: 2,
      host: "mongodb-secondary2.nexus.internal:27017",
      priority: 5,
      tags: {
        dc: "primary",
        rack: "rack3"
      }
    },
    {
      _id: 3,
      host: "mongodb-dr.nexus.internal:27017",
      priority: 0,  // Cannot become primary
      hidden: true, // Not used for reads
      tags: {
        dc: "secondary",
        rack: "rack1"
      }
    },
    {
      _id: 4,
      host: "mongodb-arbiter.nexus.internal:27017",
      arbiterOnly: true,
      tags: {
        dc: "secondary",
        rack: "rack2"
      }
    }
  ],
  settings: {
    electionTimeoutMillis: 5000,
    heartbeatIntervalMillis: 2000,
    catchUpTimeoutMillis: 60000,
    getLastErrorDefaults: {
      w: "majority",
      j: true,
      wtimeout: 5000
    }
  }
};

// Initialize replica set
rs.initiate(replicaSetConfig);

// Configure read preference tags
rs.conf().settings.getLastErrorModes = {
  "multiDataCenter": {
    "dc": 2
  }
};
```

### Connection String for Replica Set

```javascript
// Connection string with replica set
const MONGO_URI = `mongodb://user:pass@mongodb-primary.nexus.internal:27017,mongodb-secondary1.nexus.internal:27017,mongodb-secondary2.nexus.internal:27017/nexus_research?replicaSet=nexusResearchRS&readPreference=secondaryPreferred&maxStalenessSeconds=90`;
```

## Backup and Restore Procedures

### Automated Backup Strategy

```bash
#!/bin/bash
# scripts/mongodb-backup.sh

# Configuration
BACKUP_DIR="/backup/mongodb"
RETENTION_DAYS=30
S3_BUCKET="nexus-mongodb-backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="nexus_research_${DATE}"

# Create backup directory
mkdir -p ${BACKUP_DIR}/${DATE}

# Perform backup using mongodump with compression
mongodump \
  --uri="${MONGO_URI}" \
  --gzip \
  --oplog \
  --out="${BACKUP_DIR}/${DATE}" \
  --readPreference=secondary

# Calculate backup size
BACKUP_SIZE=$(du -sh ${BACKUP_DIR}/${DATE} | cut -f1)
echo "Backup completed: ${BACKUP_NAME}, Size: ${BACKUP_SIZE}"

# Create tarball
tar -czf ${BACKUP_DIR}/${BACKUP_NAME}.tar.gz -C ${BACKUP_DIR} ${DATE}

# Upload to S3 with encryption
aws s3 cp ${BACKUP_DIR}/${BACKUP_NAME}.tar.gz \
  s3://${S3_BUCKET}/daily/ \
  --storage-class STANDARD_IA \
  --server-side-encryption AES256

# Cleanup old local backups
find ${BACKUP_DIR} -type f -name "*.tar.gz" -mtime +7 -delete

# Cleanup old S3 backups
aws s3 ls s3://${S3_BUCKET}/daily/ | \
  while read -r line; do
    createDate=$(echo $line | awk '{print $1" "$2}')
    createDate=$(date -d "$createDate" +%s)
    olderThan=$(date -d "${RETENTION_DAYS} days ago" +%s)
    if [[ $createDate -lt $olderThan ]]; then
      fileName=$(echo $line | awk '{print $4}')
      aws s3 rm s3://${S3_BUCKET}/daily/$fileName
    fi
  done

# Send notification
curl -X POST https://nexus.webhook.internal/backup \
  -H "Content-Type: application/json" \
  -d "{
    \"status\": \"success\",
    \"backup_name\": \"${BACKUP_NAME}\",
    \"size\": \"${BACKUP_SIZE}\",
    \"location\": \"s3://${S3_BUCKET}/daily/${BACKUP_NAME}.tar.gz\"
  }"
```

### Backup Schedule (Cron)

```bash
# /etc/cron.d/mongodb-backup
# Daily backups at 2 AM
0 2 * * * mongodb /opt/scripts/mongodb-backup.sh >> /var/log/mongodb-backup.log 2>&1

# Weekly full backup on Sunday at 3 AM
0 3 * * 0 mongodb /opt/scripts/mongodb-backup-full.sh >> /var/log/mongodb-backup.log 2>&1

# Monthly backup verification on the 1st at 4 AM
0 4 1 * * mongodb /opt/scripts/mongodb-backup-verify.sh >> /var/log/mongodb-backup.log 2>&1
```

### Restore Procedure

```bash
#!/bin/bash
# scripts/mongodb-restore.sh

BACKUP_FILE=$1
RESTORE_DIR="/tmp/mongodb-restore"
TARGET_DB=${2:-nexus_research}

if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: $0 <backup-file> [target-database]"
    exit 1
fi

# Create restore directory
mkdir -p ${RESTORE_DIR}

# Download from S3 if needed
if [[ $BACKUP_FILE == s3://* ]]; then
    echo "Downloading backup from S3..."
    aws s3 cp $BACKUP_FILE ${RESTORE_DIR}/backup.tar.gz
    BACKUP_FILE="${RESTORE_DIR}/backup.tar.gz"
fi

# Extract backup
echo "Extracting backup..."
tar -xzf $BACKUP_FILE -C ${RESTORE_DIR}

# Find the backup directory
BACKUP_DIR=$(find ${RESTORE_DIR} -type d -name "*_*" | head -1)

# Restore with mongorestore
echo "Restoring database..."
mongorestore \
  --uri="${MONGO_URI}" \
  --gzip \
  --oplogReplay \
  --drop \
  --nsInclude="${TARGET_DB}.*" \
  --dir="${BACKUP_DIR}"

# Verify restore
echo "Verifying restore..."
mongo "${MONGO_URI}" --eval "
  db = db.getSiblingDB('${TARGET_DB}');
  print('Collections in ${TARGET_DB}:');
  db.getCollectionNames().forEach(function(c) {
    count = db[c].countDocuments();
    print(c + ': ' + count + ' documents');
  });
"

# Cleanup
rm -rf ${RESTORE_DIR}

echo "Restore completed successfully"
```

### Point-in-Time Recovery

```javascript
// scripts/point-in-time-recovery.js
const { MongoClient } = require('mongodb');

async function pointInTimeRecovery(targetTimestamp) {
  const client = new MongoClient(process.env.MONGO_URI);
  
  try {
    await client.connect();
    const db = client.db('nexus_research');
    
    // Get oplog entries up to target timestamp
    const oplog = client.db('local').collection('oplog.rs');
    const targetTime = new Date(targetTimestamp);
    
    const operations = await oplog.find({
      ts: { $lte: Timestamp.fromNumber(targetTime.getTime() / 1000) },
      ns: /^nexus_research\./
    }).toArray();
    
    console.log(`Found ${operations.length} operations to replay`);
    
    // Replay operations
    for (const op of operations) {
      await replayOperation(db, op);
    }
    
    console.log('Point-in-time recovery completed');
  } finally {
    await client.close();
  }
}

async function replayOperation(db, op) {
  const [, collection] = op.ns.split('.');
  
  switch (op.op) {
    case 'i': // Insert
      await db.collection(collection).insertOne(op.o);
      break;
    case 'u': // Update
      await db.collection(collection).updateOne(op.o2, op.o);
      break;
    case 'd': // Delete
      await db.collection(collection).deleteOne(op.o);
      break;
  }
}
```

## Performance Tuning for Research Workloads

### Index Strategy

```javascript
// scripts/create-indexes.js
async function createOptimizedIndexes(db) {
  // Compound indexes for common query patterns
  await db.collection('datasets').createIndex(
    { organizationId: 1, createdAt: -1 },
    { name: 'org_created_idx' }
  );
  
  await db.collection('variables').createIndex(
    { datasetId: 1, variableType: 1, name: 1 },
    { name: 'dataset_type_name_idx' }
  );
  
  await db.collection('signals').createIndex(
    { organizationId: 1, status: 1, severity: -1, createdAt: -1 },
    { name: 'org_signal_priority_idx' }
  );
  
  // Text indexes for search
  await db.collection('datasets').createIndex(
    { name: 'text', description: 'text' },
    { name: 'dataset_text_idx', weights: { name: 10, description: 5 } }
  );
  
  // Partial indexes for active records
  await db.collection('users').createIndex(
    { organizationId: 1, lastLogin: -1 },
    { 
      name: 'active_users_idx',
      partialFilterExpression: { isActive: true }
    }
  );
  
  // TTL index for temporary data
  await db.collection('sessionData').createIndex(
    { expiresAt: 1 },
    { name: 'session_ttl_idx', expireAfterSeconds: 0 }
  );
}
```

### Query Optimization

```javascript
// src/services/queryOptimizer.js
class QueryOptimizer {
  constructor(db) {
    this.db = db;
    this.queryCache = new Map();
  }
  
  async optimizeDatasetQuery(filter, options = {}) {
    const queryKey = JSON.stringify({ filter, options });
    
    // Check cache
    if (this.queryCache.has(queryKey)) {
      return this.queryCache.get(queryKey);
    }
    
    // Build optimized aggregation pipeline
    const pipeline = [];
    
    // Use index-friendly match stage
    if (filter.organizationId) {
      pipeline.push({ $match: { organizationId: filter.organizationId } });
    }
    
    // Add other filters
    const additionalFilters = { ...filter };
    delete additionalFilters.organizationId;
    if (Object.keys(additionalFilters).length > 0) {
      pipeline.push({ $match: additionalFilters });
    }
    
    // Projection to reduce data transfer
    if (options.fields) {
      pipeline.push({ $project: options.fields });
    }
    
    // Sorting with index support
    if (options.sort) {
      pipeline.push({ $sort: options.sort });
    }
    
    // Pagination
    if (options.skip) {
      pipeline.push({ $skip: options.skip });
    }
    if (options.limit) {
      pipeline.push({ $limit: options.limit });
    }
    
    // Add read concern for consistency
    const cursor = this.db.collection('datasets').aggregate(pipeline, {
      readConcern: { level: 'majority' },
      allowDiskUse: true, // For large datasets
      hint: 'org_created_idx' // Force index usage
    });
    
    const results = await cursor.toArray();
    
    // Cache results for 5 minutes
    this.queryCache.set(queryKey, results);
    setTimeout(() => this.queryCache.delete(queryKey), 300000);
    
    return results;
  }
  
  async explainQuery(collection, query) {
    const explanation = await this.db.collection(collection)
      .find(query)
      .explain('executionStats');
    
    return {
      indexUsed: explanation.executionStats.executionStages.indexName,
      documentsExamined: explanation.executionStats.totalDocsExamined,
      documentsReturned: explanation.executionStats.nReturned,
      executionTime: explanation.executionStats.executionTimeMillis,
      indexEfficiency: explanation.executionStats.nReturned / 
                      explanation.executionStats.totalDocsExamined
    };
  }
}
```

### Memory and Cache Configuration

```javascript
// MongoDB configuration for research workloads
const mongoConfig = {
  // WiredTiger cache size (50% of available RAM)
  wiredTigerCacheSizeGB: 32,
  
  // Index prefix compression
  wiredTigerIndexPrefixCompression: true,
  
  // Collection block compression
  wiredTigerCollectionBlockCompressor: 'snappy',
  
  // Journal compression
  wiredTigerJournalCompressor: 'snappy',
  
  // Read ahead for sequential access
  wiredTigerReadAhead: 16,
  
  // Checkpoint frequency
  wiredTigerCheckpointFrequency: 300, // 5 minutes
  
  // Statistics collection
  wiredTigerStatisticsLogDelaySecs: 60
};
```

## Data Retention Policies

### Automated Data Retention

```javascript
// scripts/data-retention.js
const retentionPolicies = {
  signals: {
    retentionDays: 365,
    archiveAfterDays: 90,
    deleteAfterDays: 365
  },
  actions: {
    retentionDays: 730,
    archiveAfterDays: 180,
    deleteAfterDays: 730
  },
  auditLogs: {
    retentionDays: 2555, // 7 years for compliance
    archiveAfterDays: 365,
    deleteAfterDays: 2555
  },
  sessionData: {
    retentionDays: 30,
    archiveAfterDays: null,
    deleteAfterDays: 30
  }
};

async function applyRetentionPolicies(db) {
  for (const [collection, policy] of Object.entries(retentionPolicies)) {
    console.log(`Applying retention policy for ${collection}`);
    
    const now = new Date();
    
    // Archive old data
    if (policy.archiveAfterDays) {
      const archiveDate = new Date(now - policy.archiveAfterDays * 24 * 60 * 60 * 1000);
      
      const toArchive = await db.collection(collection).find({
        createdAt: { $lt: archiveDate },
        archived: { $ne: true }
      }).toArray();
      
      if (toArchive.length > 0) {
        // Move to archive collection
        await db.collection(`${collection}_archive`).insertMany(toArchive);
        
        // Mark as archived
        await db.collection(collection).updateMany(
          { _id: { $in: toArchive.map(doc => doc._id) } },
          { $set: { archived: true, archivedAt: now } }
        );
        
        console.log(`Archived ${toArchive.length} documents from ${collection}`);
      }
    }
    
    // Delete expired data
    const deleteDate = new Date(now - policy.deleteAfterDays * 24 * 60 * 60 * 1000);
    
    const deleteResult = await db.collection(collection).deleteMany({
      createdAt: { $lt: deleteDate }
    });
    
    console.log(`Deleted ${deleteResult.deletedCount} expired documents from ${collection}`);
  }
}

// Run retention policies
const client = new MongoClient(process.env.MONGO_URI);
client.connect().then(async () => {
  const db = client.db('nexus_research');
  await applyRetentionPolicies(db);
  await client.close();
});
```

### Archive Storage Configuration

```yaml
# S3 Lifecycle Policy for MongoDB Archives
{
  "Rules": [{
    "Id": "MongoDBArchiveLifecycle",
    "Status": "Enabled",
    "Transitions": [
      {
        "Days": 30,
        "StorageClass": "STANDARD_IA"
      },
      {
        "Days": 90,
        "StorageClass": "GLACIER"
      },
      {
        "Days": 365,
        "StorageClass": "DEEP_ARCHIVE"
      }
    ],
    "NoncurrentVersionTransitions": [
      {
        "NoncurrentDays": 7,
        "StorageClass": "GLACIER"
      }
    ],
    "AbortIncompleteMultipartUpload": {
      "DaysAfterInitiation": 7
    }
  }]
}
```

## Monitoring and Alerting

### MongoDB Monitoring Setup

```yaml
# prometheus/mongodb-exporter.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mongodb-exporter
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app: mongodb-exporter
  template:
    metadata:
      labels:
        app: mongodb-exporter
    spec:
      containers:
      - name: mongodb-exporter
        image: percona/mongodb_exporter:0.39.0
        args:
          - --mongodb.uri=$(MONGO_URI)
          - --collect-all
          - --compatible-mode
        env:
        - name: MONGO_URI
          valueFrom:
            secretKeyRef:
              name: mongodb-secret
              key: uri
        ports:
        - containerPort: 9216
          name: metrics
```

### Alert Rules

```yaml
# prometheus/mongodb-alerts.yaml
groups:
  - name: mongodb
    rules:
    - alert: MongoDBDown
      expr: up{job="mongodb-exporter"} == 0
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "MongoDB instance is down"
        
    - alert: MongoDBReplicationLag
      expr: mongodb_replset_member_lag_seconds > 10
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "MongoDB replication lag is high"
        
    - alert: MongoDBHighConnections
      expr: mongodb_connections{state="current"} > 800
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "MongoDB connection count is high"
        
    - alert: MongoDBCacheUsage
      expr: (mongodb_wiredtiger_cache_bytes_currently_in_the_cache / mongodb_wiredtiger_cache_maximum_bytes_configured) > 0.8
      for: 10m
      labels:
        severity: warning
      annotations:
        summary: "MongoDB cache usage is high"
```

## Disaster Recovery

### DR Strategy

```mermaid
graph TD
    A[Primary Site Failure] --> B{DR Decision}
    B --> C[Failover to Secondary]
    B --> D[Restore from Backup]
    
    C --> E[Promote Secondary to Primary]
    E --> F[Update Connection Strings]
    F --> G[Verify Application Connectivity]
    
    D --> H[Restore Latest Backup]
    H --> I[Apply OpLog]
    I --> J[Validate Data Integrity]
    
    G --> K[Monitor Performance]
    J --> K
    K --> L[Document Incident]
```

### DR Runbook

```bash
#!/bin/bash
# scripts/disaster-recovery.sh

# 1. Assess the situation
echo "=== MongoDB Disaster Recovery Procedure ==="
echo "Current time: $(date)"

# 2. Check primary status
PRIMARY_STATUS=$(mongo --quiet --eval "rs.isMaster().ismaster")

if [ "$PRIMARY_STATUS" != "true" ]; then
    echo "WARNING: No primary detected in replica set"
    
    # 3. Force reconfiguration if needed
    echo "Attempting to force reconfiguration..."
    mongo --eval "
      cfg = rs.conf();
      cfg.members = cfg.members.filter(m => m.host.includes('nexus.internal'));
      rs.reconfig(cfg, {force: true});
    "
    
    # 4. Wait for new primary election
    sleep 30
    
    # 5. Verify new primary
    NEW_PRIMARY=$(mongo --quiet --eval "rs.isMaster().primary")
    echo "New primary elected: $NEW_PRIMARY"
fi

# 6. Update application configuration
kubectl set env deployment/nexus-mcp MONGO_URI="mongodb://$NEW_PRIMARY/nexus_research" -n nexus-prod

# 7. Verify connectivity
./scripts/verify-mongodb-connection.sh

# 8. Send notification
curl -X POST https://nexus.webhook.internal/dr-alert \
  -H "Content-Type: application/json" \
  -d "{
    \"event\": \"disaster_recovery_completed\",
    \"primary\": \"$NEW_PRIMARY\",
    \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"
  }"
```