# MongoDB Security Configuration

## Overview

This document provides MongoDB-specific security configurations for the Nexus MCP server, focusing on securing the research database containing clinical trial metadata accessed via SSH tunnel.

## SSH Tunnel Security Configuration

### SSH Tunnel Setup

**Secure SSH Configuration:**
```bash
# SSH client configuration (~/.ssh/config)
Host nexus-mongo-tunnel
    HostName mongo.nexus-clinical.internal
    Port 22
    User nexus-mongo
    IdentityFile ~/.ssh/nexus_mongo_rsa
    ServerAliveInterval 60
    ServerAliveCountMax 3
    StrictHostKeyChecking yes
    UserKnownHostsFile ~/.ssh/known_hosts
    Compression yes
    
    # Security hardening
    Protocol 2
    Ciphers aes256-gcm@openssh.com,chacha20-poly1305@openssh.com
    MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
    KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org
    
    # Port forwarding for MongoDB
    LocalForward 27017 localhost:27017
```

### Automated SSH Tunnel Management

**Tunnel Manager Script:**
```javascript
const { Client } = require('ssh2');
const fs = require('fs');

class SecureSSHTunnel {
  constructor(config) {
    this.config = {
      host: process.env.SSH_HOST,
      port: 22,
      username: process.env.SSH_USER,
      privateKey: fs.readFileSync(process.env.SSH_KEY_PATH),
      passphrase: process.env.SSH_KEY_PASSPHRASE,
      algorithms: {
        kex: ['curve25519-sha256', 'curve25519-sha256@libssh.org'],
        cipher: ['aes256-gcm@openssh.com', 'chacha20-poly1305@openssh.com'],
        serverHostKey: ['rsa-sha2-512', 'rsa-sha2-256'],
        hmac: ['hmac-sha2-512-etm@openssh.com', 'hmac-sha2-256-etm@openssh.com']
      },
      readyTimeout: 30000,
      keepaliveInterval: 60000
    };
    
    this.connection = null;
    this.forwardedPort = null;
  }
  
  async connect() {
    return new Promise((resolve, reject) => {
      this.connection = new Client();
      
      this.connection
        .on('ready', () => {
          console.log('SSH tunnel established');
          this.setupPortForwarding(resolve, reject);
        })
        .on('error', (err) => {
          console.error('SSH tunnel error:', err);
          reject(err);
        })
        .on('close', () => {
          console.log('SSH tunnel closed');
          this.reconnect();
        })
        .connect(this.config);
    });
  }
  
  setupPortForwarding(resolve, reject) {
    this.connection.forwardOut(
      '127.0.0.1',
      0,
      '127.0.0.1',
      27017,
      (err, stream) => {
        if (err) return reject(err);
        
        this.forwardedPort = stream;
        resolve(stream);
      }
    );
  }
  
  async reconnect() {
    console.log('Attempting to reconnect SSH tunnel...');
    setTimeout(() => this.connect(), 5000);
  }
}
```

### SSH Key Management

**Key Security Requirements:**
- Use ED25519 or RSA-4096 keys
- Protect private keys with strong passphrases
- Rotate SSH keys quarterly
- Use separate keys per environment
- Store keys in secure vault (HashiCorp Vault, AWS Secrets Manager)

**Key Generation:**
```bash
# Generate secure SSH key
ssh-keygen -t ed25519 -f nexus_mongo_ed25519 -C "nexus-mcp@clinical.com" -N "strong_passphrase"

# Set proper permissions
chmod 600 nexus_mongo_ed25519
chmod 644 nexus_mongo_ed25519.pub

# Add to SSH agent with timeout
ssh-add -t 3600 nexus_mongo_ed25519
```

## MongoDB Authentication (SCRAM-SHA-256)

### Authentication Configuration

**Enable SCRAM-SHA-256:**
```javascript
// MongoDB configuration
{
  security: {
    authorization: "enabled",
    authenticationMechanisms: "SCRAM-SHA-256"
  }
}
```

### User Creation with SCRAM-SHA-256

**Create Secure Users:**
```javascript
// Admin user creation
db.getSiblingDB("admin").createUser({
  user: "nexus-admin",
  pwd: passwordPrompt(), // Use secure password input
  roles: [
    { role: "userAdminAnyDatabase", db: "admin" },
    { role: "readWriteAnyDatabase", db: "admin" },
    { role: "dbAdminAnyDatabase", db: "admin" },
    { role: "clusterAdmin", db: "admin" }
  ],
  mechanisms: ["SCRAM-SHA-256"]
});

// Application user with limited permissions
db.getSiblingDB("nexus_clinical").createUser({
  user: "nexus-app",
  pwd: passwordPrompt(),
  roles: [
    { role: "readWrite", db: "nexus_clinical" },
    { role: "read", db: "nexus_audit" }
  ],
  mechanisms: ["SCRAM-SHA-256"],
  authenticationRestrictions: [
    {
      clientSource: ["127.0.0.1", "::1"], // Only localhost via SSH tunnel
      serverAddress: []
    }
  ]
});
```

### Connection String Security

**Secure Connection Example:**
```javascript
const { MongoClient } = require('mongodb');

class SecureMongoConnection {
  constructor() {
    this.client = null;
    this.connectionOptions = {
      authSource: 'admin',
      authMechanism: 'SCRAM-SHA-256',
      tls: true,
      tlsCAFile: process.env.MONGO_CA_CERT,
      tlsCertificateKeyFile: process.env.MONGO_CLIENT_CERT,
      tlsAllowInvalidHostnames: false,
      tlsAllowInvalidCertificates: false,
      serverSelectionTimeoutMS: 5000,
      socketTimeoutMS: 300000,
      maxPoolSize: 10,
      minPoolSize: 2,
      maxIdleTimeMS: 60000
    };
  }
  
  async connect() {
    const uri = this.buildSecureUri();
    
    try {
      this.client = new MongoClient(uri, this.connectionOptions);
      await this.client.connect();
      
      // Verify connection
      await this.client.db('admin').command({ ping: 1 });
      console.log('Secure MongoDB connection established');
      
      return this.client;
    } catch (error) {
      console.error('MongoDB connection failed:', error);
      throw error;
    }
  }
  
  buildSecureUri() {
    // Never log or expose the full connection string
    const username = encodeURIComponent(process.env.MONGO_USER);
    const password = encodeURIComponent(process.env.MONGO_PASSWORD);
    const host = process.env.MONGO_HOST || 'localhost';
    const port = process.env.MONGO_PORT || '27017';
    const database = process.env.MONGO_DATABASE || 'nexus_clinical';
    
    return `mongodb://${username}:${password}@${host}:${port}/${database}`;
  }
}
```

## Role-Based Access Control Setup

### Custom Role Definitions

**Clinical Data Roles:**
```javascript
// Create custom roles for clinical data access
db.getSiblingDB("nexus_clinical").createRole({
  role: "clinicalDataReader",
  privileges: [
    {
      resource: { db: "nexus_clinical", collection: "datasets" },
      actions: ["find", "aggregate"]
    },
    {
      resource: { db: "nexus_clinical", collection: "variables" },
      actions: ["find", "aggregate"]
    },
    {
      resource: { db: "nexus_clinical", collection: "signals" },
      actions: ["find"]
    }
  ],
  roles: []
});

db.getSiblingDB("nexus_clinical").createRole({
  role: "clinicalDataManager",
  privileges: [
    {
      resource: { db: "nexus_clinical", collection: "datasets" },
      actions: ["find", "insert", "update", "remove", "aggregate"]
    },
    {
      resource: { db: "nexus_clinical", collection: "variables" },
      actions: ["find", "insert", "update", "remove", "aggregate"]
    },
    {
      resource: { db: "nexus_clinical", collection: "signals" },
      actions: ["find", "insert", "update", "aggregate"]
    },
    {
      resource: { db: "nexus_clinical", collection: "actions" },
      actions: ["find", "insert", "update"]
    }
  ],
  roles: ["clinicalDataReader"]
});

db.getSiblingDB("nexus_clinical").createRole({
  role: "organizationAdmin",
  privileges: [
    {
      resource: { db: "nexus_clinical", collection: "users" },
      actions: ["find", "insert", "update", "remove"]
    },
    {
      resource: { db: "nexus_clinical", collection: "organizations" },
      actions: ["find", "update"]
    }
  ],
  roles: ["clinicalDataManager"]
});
```

### Organization-Level Isolation

**Implement Data Isolation:**
```javascript
// Middleware for organization-based filtering
class OrganizationIsolation {
  static applyFilter(query, user) {
    if (!user.isSystemAdmin) {
      // Automatically add organization filter
      query.organizationId = user.organizationId;
    }
    return query;
  }
  
  static validateAccess(document, user) {
    if (user.isSystemAdmin) return true;
    
    return document.organizationId === user.organizationId;
  }
  
  static createAggregationPipeline(pipeline, user) {
    if (!user.isSystemAdmin) {
      // Prepend organization match stage
      pipeline.unshift({
        $match: { organizationId: user.organizationId }
      });
    }
    return pipeline;
  }
}
```

## Audit Logging Configuration

### Enable MongoDB Audit Logging

**Audit Configuration:**
```yaml
# mongod.conf
auditLog:
  destination: file
  format: JSON
  path: /var/log/mongodb/audit.json
  filter: '{
    "$or": [
      { "atype": { "$in": ["authenticate", "authCheck"] } },
      { "atype": "createUser" },
      { "atype": "dropUser" },
      { "atype": "updateUser" },
      { "atype": "createRole" },
      { "atype": "dropRole" },
      { "atype": "updateRole" },
      { "atype": "createDatabase" },
      { "atype": "dropDatabase" },
      { "atype": "createCollection" },
      { "atype": "dropCollection" },
      { "param.command": { "$in": ["find", "insert", "update", "delete"] } }
    ]
  }'

setParameter:
  auditAuthorizationSuccess: true
```

### Custom Audit Trail

**Application-Level Audit Logging:**
```javascript
class AuditLogger {
  constructor(db) {
    this.auditCollection = db.collection('audit_trail');
    this.setupIndexes();
  }
  
  async setupIndexes() {
    await this.auditCollection.createIndexes([
      { key: { timestamp: -1 }, expireAfterSeconds: 7 * 365 * 24 * 60 * 60 }, // 7 years
      { key: { userId: 1, timestamp: -1 } },
      { key: { action: 1, timestamp: -1 } },
      { key: { 'resource.collection': 1, 'resource.id': 1 } }
    ]);
  }
  
  async logAction(context) {
    const auditEntry = {
      timestamp: new Date(),
      userId: context.user.id,
      userName: context.user.name,
      userRole: context.user.role,
      organizationId: context.user.organizationId,
      action: context.action,
      resource: {
        database: context.database,
        collection: context.collection,
        id: context.resourceId
      },
      details: context.details,
      ip: context.ip,
      userAgent: context.userAgent,
      success: context.success,
      error: context.error || null
    };
    
    try {
      await this.auditCollection.insertOne(auditEntry);
    } catch (error) {
      console.error('Audit logging failed:', error);
      // Fail securely - deny access if audit fails
      throw new Error('Audit system unavailable');
    }
  }
}
```

## Network Isolation and VPC Setup

### Network Architecture

```yaml
network_architecture:
  vpc:
    cidr: 10.0.0.0/16
    
  subnets:
    private_mongodb:
      cidr: 10.0.1.0/24
      availability_zones: [a, b, c]
      
    private_application:
      cidr: 10.0.2.0/24
      availability_zones: [a, b, c]
      
    public_bastion:
      cidr: 10.0.10.0/24
      availability_zones: [a]
      
  security_groups:
    mongodb:
      ingress:
        - port: 27017
          source: private_application_subnet
          protocol: tcp
        - port: 22
          source: bastion_security_group
          protocol: tcp
          
    application:
      ingress:
        - port: 443
          source: 0.0.0.0/0
          protocol: tcp
          
    bastion:
      ingress:
        - port: 22
          source: admin_ip_whitelist
          protocol: tcp
```

### Firewall Rules

**MongoDB Server Firewall:**
```bash
# iptables rules for MongoDB server
#!/bin/bash

# Default policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow loopback
iptables -A INPUT -i lo -j ACCEPT

# Allow established connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow SSH from bastion only
iptables -A INPUT -p tcp --dport 22 -s 10.0.10.0/24 -j ACCEPT

# Allow MongoDB from application subnet only
iptables -A INPUT -p tcp --dport 27017 -s 10.0.2.0/24 -j ACCEPT

# Log denied connections
iptables -A INPUT -j LOG --log-prefix "Denied: "

# Save rules
iptables-save > /etc/iptables/rules.v4
```

## Connection String Security

### Secure Connection Management

**Connection String Encryption:**
```javascript
const crypto = require('crypto');

class SecureConnectionManager {
  constructor() {
    this.algorithm = 'aes-256-gcm';
    this.key = Buffer.from(process.env.CONNECTION_ENCRYPTION_KEY, 'hex');
  }
  
  encryptConnectionString(connectionString) {
    const iv = crypto.randomBytes(16);
    const cipher = crypto.createCipheriv(this.algorithm, this.key, iv);
    
    let encrypted = cipher.update(connectionString, 'utf8', 'hex');
    encrypted += cipher.final('hex');
    
    const authTag = cipher.getAuthTag();
    
    return {
      encrypted,
      iv: iv.toString('hex'),
      authTag: authTag.toString('hex')
    };
  }
  
  decryptConnectionString(encryptedData) {
    const decipher = crypto.createDecipheriv(
      this.algorithm,
      this.key,
      Buffer.from(encryptedData.iv, 'hex')
    );
    
    decipher.setAuthTag(Buffer.from(encryptedData.authTag, 'hex'));
    
    let decrypted = decipher.update(encryptedData.encrypted, 'hex', 'utf8');
    decrypted += decipher.final('utf8');
    
    return decrypted;
  }
  
  async getSecureConnection() {
    // Retrieve encrypted connection string from secure storage
    const encryptedConn = await this.getFromVault('mongodb-connection');
    
    // Decrypt connection string
    const connectionString = this.decryptConnectionString(encryptedConn);
    
    // Use connection string immediately and clear from memory
    const client = new MongoClient(connectionString);
    
    // Clear sensitive data
    connectionString = null;
    
    return client;
  }
}
```

### Environment-Specific Connections

**Connection Configuration:**
```javascript
const connectionConfigs = {
  production: {
    replicaSet: 'nexus-prod-rs',
    readPreference: 'primaryPreferred',
    w: 'majority',
    j: true,
    wtimeout: 5000,
    readConcern: { level: 'majority' }
  },
  
  staging: {
    replicaSet: 'nexus-staging-rs',
    readPreference: 'secondary',
    w: 1,
    j: true
  },
  
  development: {
    directConnection: true,
    w: 1
  }
};
```

## Query Injection Prevention

### Input Validation

**Sanitization Functions:**
```javascript
class QuerySanitizer {
  static sanitizeQuery(query) {
    if (typeof query !== 'object' || query === null) {
      throw new Error('Invalid query format');
    }
    
    // Remove dangerous operators
    const dangerousOperators = [
      '$where', '$expr', '$function', '$accumulator',
      '$regex' // Only if not explicitly allowed
    ];
    
    return this.recursiveSanitize(query, dangerousOperators);
  }
  
  static recursiveSanitize(obj, forbidden) {
    const cleaned = {};
    
    for (const [key, value] of Object.entries(obj)) {
      if (forbidden.includes(key)) {
        console.warn(`Dangerous operator ${key} removed from query`);
        continue;
      }
      
      if (typeof value === 'object' && value !== null) {
        cleaned[key] = this.recursiveSanitize(value, forbidden);
      } else {
        cleaned[key] = value;
      }
    }
    
    return cleaned;
  }
  
  static validateObjectId(id) {
    const objectIdRegex = /^[0-9a-fA-F]{24}$/;
    if (!objectIdRegex.test(id)) {
      throw new Error('Invalid ObjectId format');
    }
    return id;
  }
  
  static escapeRegex(string) {
    return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  }
}
```

### Safe Query Patterns

**Parameterized Queries:**
```javascript
class SafeQueryBuilder {
  static findByEmail(email) {
    // Validate email format
    if (!this.isValidEmail(email)) {
      throw new Error('Invalid email format');
    }
    
    return {
      email: { $eq: email } // Use explicit operator
    };
  }
  
  static searchByName(name) {
    // Escape special regex characters
    const escaped = QuerySanitizer.escapeRegex(name);
    
    return {
      name: {
        $regex: `^${escaped}`,
        $options: 'i'
      }
    };
  }
  
  static aggregateWithLimit(pipeline, maxStages = 10) {
    if (pipeline.length > maxStages) {
      throw new Error('Pipeline too complex');
    }
    
    // Validate each stage
    const allowedStages = [
      '$match', '$group', '$sort', '$limit',
      '$project', '$lookup', '$unwind'
    ];
    
    for (const stage of pipeline) {
      const stageType = Object.keys(stage)[0];
      if (!allowedStages.includes(stageType)) {
        throw new Error(`Disallowed stage: ${stageType}`);
      }
    }
    
    return pipeline;
  }
}
```

## Field-Level Encryption

### Client-Side Field Encryption

**Setup Field-Level Encryption:**
```javascript
const { ClientEncryption } = require('mongodb-client-encryption');

class FieldEncryption {
  constructor() {
    this.schemaMap = {
      'nexus_clinical.users': {
        bsonType: 'object',
        encryptMetadata: {
          keyId: '/organizationId'
        },
        properties: {
          email: {
            encrypt: {
              bsonType: 'string',
              algorithm: 'AEAD_AES_256_CBC_HMAC_SHA_512-Deterministic'
            }
          },
          phoneNumber: {
            encrypt: {
              bsonType: 'string',
              algorithm: 'AEAD_AES_256_CBC_HMAC_SHA_512-Random'
            }
          },
          personalNotes: {
            encrypt: {
              bsonType: 'string',
              algorithm: 'AEAD_AES_256_CBC_HMAC_SHA_512-Random'
            }
          }
        }
      },
      'nexus_clinical.signals': {
        properties: {
          sensitiveData: {
            encrypt: {
              bsonType: 'object',
              algorithm: 'AEAD_AES_256_CBC_HMAC_SHA_512-Random'
            }
          }
        }
      }
    };
  }
  
  async setupEncryption(client) {
    const encryption = new ClientEncryption(client, {
      keyVaultNamespace: 'encryption.__keyVault',
      kmsProviders: {
        aws: {
          accessKeyId: process.env.AWS_ACCESS_KEY_ID,
          secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY
        }
      }
    });
    
    // Create data encryption keys per organization
    const organizations = await this.getOrganizations();
    
    for (const org of organizations) {
      const dataKey = await encryption.createDataKey('aws', {
        masterKey: {
          region: 'us-east-1',
          key: process.env.KMS_KEY_ARN
        },
        keyAltNames: [`organization_${org._id}`]
      });
      
      console.log(`Created encryption key for organization: ${org._id}`);
    }
    
    return encryption;
  }
}
```

### Encryption Key Rotation

**Automated Key Rotation:**
```javascript
class EncryptionKeyRotation {
  async rotateOrganizationKeys() {
    const organizations = await this.getOrganizations();
    
    for (const org of organizations) {
      await this.rotateOrgKey(org._id);
    }
  }
  
  async rotateOrgKey(orgId) {
    // 1. Create new data key
    const newKeyId = await this.createNewDataKey(orgId);
    
    // 2. Re-encrypt existing data
    await this.reencryptOrgData(orgId, newKeyId);
    
    // 3. Mark old key as inactive
    await this.deactivateOldKey(orgId);
    
    // 4. Audit log the rotation
    await this.auditKeyRotation(orgId, newKeyId);
  }
}
```

## Security Monitoring and Alerts

### Real-time Security Monitoring

**Security Event Detection:**
```javascript
class SecurityMonitor {
  constructor() {
    this.thresholds = {
      failedLogins: { count: 5, window: 300 }, // 5 failures in 5 minutes
      queryRate: { count: 1000, window: 60 }, // 1000 queries per minute
      largeQuery: { documents: 10000 }, // Queries returning > 10k docs
      slowQuery: { duration: 5000 } // Queries taking > 5 seconds
    };
  }
  
  async monitorSecurityEvents() {
    // Monitor authentication failures
    this.monitorAuthFailures();
    
    // Monitor query patterns
    this.monitorQueryPatterns();
    
    // Monitor connection anomalies
    this.monitorConnections();
    
    // Monitor data access patterns
    this.monitorDataAccess();
  }
  
  async monitorAuthFailures() {
    const pipeline = [
      {
        $match: {
          timestamp: { $gte: new Date(Date.now() - 300000) },
          action: 'authenticate',
          success: false
        }
      },
      {
        $group: {
          _id: '$userId',
          count: { $sum: 1 },
          ips: { $addToSet: '$ip' }
        }
      },
      {
        $match: {
          count: { $gte: this.thresholds.failedLogins.count }
        }
      }
    ];
    
    const suspects = await this.auditCollection.aggregate(pipeline).toArray();
    
    for (const suspect of suspects) {
      await this.handleSecurityAlert('AUTH_FAILURE_THRESHOLD', suspect);
    }
  }
}
```

### Security Alerts Configuration

**Alert Definitions:**
```yaml
security_alerts:
  authentication:
    - name: brute_force_attempt
      condition: failed_logins > 5 in 5_minutes
      action: [block_ip, notify_security]
      
    - name: suspicious_login_location
      condition: login_from_new_country
      action: [require_mfa, notify_user]
      
  data_access:
    - name: mass_data_export
      condition: query_returns > 10000_documents
      action: [log_query, notify_admin]
      
    - name: unauthorized_collection_access
      condition: access_denied_to_restricted_collection
      action: [block_user, investigate]
      
  infrastructure:
    - name: ssh_tunnel_failure
      condition: tunnel_down > 2_minutes
      action: [restart_tunnel, page_oncall]
      
    - name: replication_lag
      condition: secondary_lag > 60_seconds
      action: [investigate, notify_dba]
```

## Implementation Checklist

### Week 1: SSH Tunnel & Authentication
- [ ] Configure secure SSH tunnel with key-based auth
- [ ] Implement automated tunnel management
- [ ] Enable SCRAM-SHA-256 authentication
- [ ] Create role-based users

### Week 2: Access Control & Audit
- [ ] Define custom MongoDB roles
- [ ] Implement organization-level isolation
- [ ] Configure audit logging
- [ ] Set up application-level audit trail

### Week 3: Network Security & Encryption
- [ ] Configure VPC and security groups
- [ ] Implement firewall rules
- [ ] Enable field-level encryption
- [ ] Set up connection string encryption

### Week 4: Monitoring & Hardening
- [ ] Deploy security monitoring
- [ ] Configure security alerts
- [ ] Implement query injection prevention
- [ ] Conduct security testing

## Security Testing Procedures

### Penetration Testing Checklist

- [ ] Test SSH tunnel security
- [ ] Attempt authentication bypass
- [ ] Test for NoSQL injection
- [ ] Verify encryption implementation
- [ ] Test access control boundaries
- [ ] Validate audit trail completeness
- [ ] Test backup security
- [ ] Verify key rotation procedures

## References

- MongoDB Security Checklist
- MongoDB Encryption at Rest
- MongoDB Field Level Encryption
- SSH Hardening Guide
- OWASP NoSQL Injection Prevention