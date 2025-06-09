# Data Protection Guidelines

## Overview

This document defines data protection standards for the Nexus MCP MongoDB server, ensuring compliance with healthcare regulations and protecting sensitive clinical trial metadata.

## Data Classification

### Classification Levels

#### Level 1: Public
**Definition:** Information that can be freely shared
**Examples:**
- Public API documentation
- Open-source code
- General system capabilities

**Protection Requirements:**
- No encryption required
- Public access allowed
- Standard logging

#### Level 2: Internal
**Definition:** Information for internal use only
**Examples:**
- System architecture diagrams
- Internal process documentation
- Non-sensitive configuration

**Protection Requirements:**
- Encryption in transit
- Authentication required
- Access logging enabled

#### Level 3: Confidential
**Definition:** Sensitive business or operational data
**Examples:**
- User account information
- Organization details
- System performance metrics

**Protection Requirements:**
- Encryption at rest and in transit
- Role-based access control
- Audit trail required
- Data retention policies enforced

#### Level 4: Restricted
**Definition:** Highly sensitive clinical or personal data
**Examples:**
- Clinical trial metadata
- Patient identifiers
- Statistical analysis results
- PII/PHI data

**Protection Requirements:**
- AES-256 encryption at rest
- TLS 1.3 encryption in transit
- Field-level encryption for specific attributes
- Strict access control with MFA
- Complete audit trail
- Data masking in non-production environments

### Data Classification Matrix

```yaml
data_elements:
  user_email:
    classification: Confidential
    encryption: at_rest
    retention: 7_years
    
  clinical_signal_data:
    classification: Restricted
    encryption: field_level
    retention: 10_years
    
  api_logs:
    classification: Internal
    encryption: in_transit
    retention: 90_days
    
  session_tokens:
    classification: Confidential
    encryption: at_rest
    retention: until_expiry
```

## Encryption at Rest

### AES-256 Implementation

**MongoDB Encryption Configuration:**
```javascript
const encryptionConfig = {
  // Enable encryption at rest
  enableEncryption: true,
  
  // Master key configuration
  masterKey: {
    provider: 'aws', // or 'azure', 'gcp', 'local'
    region: 'us-east-1',
    key: process.env.KMS_MASTER_KEY_ID
  },
  
  // Schema for automatic encryption
  schemaMap: {
    'nexus.users': {
      bsonType: 'object',
      properties: {
        email: {
          encrypt: {
            bsonType: 'string',
            algorithm: 'AEAD_AES_256_CBC_HMAC_SHA_512-Deterministic'
          }
        },
        phone: {
          encrypt: {
            bsonType: 'string',
            algorithm: 'AEAD_AES_256_CBC_HMAC_SHA_512-Random'
          }
        }
      }
    }
  }
};
```

### Storage Encryption

**Requirements:**
- Full disk encryption using AES-256
- Encrypted backups with separate keys
- Encrypted logs and temporary files
- Secure key storage in HSM or KMS

**Implementation Checklist:**
- [ ] Enable MongoDB encrypted storage engine
- [ ] Configure automatic field-level encryption
- [ ] Set up encrypted backup storage
- [ ] Implement encrypted file uploads
- [ ] Encrypt temporary data directories

## Encryption in Transit

### TLS 1.3 Configuration

**MongoDB Connection String:**
```javascript
const mongoUri = `mongodb://username:password@host:port/database?` +
  `tls=true&` +
  `tlsMinVersion=1.3&` +
  `tlsCAFile=/path/to/ca.pem&` +
  `tlsCertificateKeyFile=/path/to/client.pem&` +
  `tlsAllowInvalidHostnames=false&` +
  `tlsAllowInvalidCertificates=false`;
```

**TLS Requirements:**
- Minimum TLS version: 1.3
- Strong cipher suites only
- Certificate validation required
- Mutual TLS for service-to-service communication

**Approved Cipher Suites:**
```
TLS_AES_256_GCM_SHA384
TLS_CHACHA20_POLY1305_SHA256
TLS_AES_128_GCM_SHA256
```

### API Encryption

**HTTPS Configuration:**
```javascript
const httpsOptions = {
  key: fs.readFileSync('/path/to/private-key.pem'),
  cert: fs.readFileSync('/path/to/certificate.pem'),
  ca: fs.readFileSync('/path/to/ca-bundle.pem'),
  ciphers: 'TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256',
  honorCipherOrder: true,
  minVersion: 'TLSv1.3'
};
```

## Key Management Practices

### Key Hierarchy

```
Master Key (in HSM/KMS)
  └── Data Encryption Keys (DEK)
      ├── Database Encryption Key
      ├── Backup Encryption Key
      ├── Field-Level Encryption Keys
      └── Application Secret Keys
```

### Key Rotation Policy

**Rotation Schedule:**
- Master keys: Annual
- Data encryption keys: Quarterly
- API keys: Every 90 days
- Session keys: On each login

**Key Rotation Process:**
```javascript
const keyRotation = {
  async rotateDataKey(keyId) {
    // 1. Generate new key
    const newKey = await kms.generateDataKey();
    
    // 2. Re-encrypt data with new key
    await reencryptData(keyId, newKey);
    
    // 3. Update key metadata
    await updateKeyMetadata(keyId, newKey.id);
    
    // 4. Archive old key (keep for decryption only)
    await archiveKey(keyId);
    
    // 5. Audit log the rotation
    await auditLog('key_rotation', { keyId, timestamp: new Date() });
  }
};
```

### Key Storage Security

**Best Practices:**
- Never store keys in source code
- Use hardware security modules (HSM) for master keys
- Implement key escrow for recovery
- Separate keys by environment
- Use different keys for different data types

## Data Masking and Anonymization

### Masking Strategies

**PII Masking Rules:**
```javascript
const maskingRules = {
  email: (email) => {
    const [user, domain] = email.split('@');
    return `${user.substring(0, 2)}***@${domain}`;
  },
  
  phone: (phone) => {
    return phone.replace(/\d(?=\d{4})/g, '*');
  },
  
  name: (name) => {
    return name.split(' ').map(part => 
      part.charAt(0) + '*'.repeat(part.length - 1)
    ).join(' ');
  },
  
  objectId: (id) => {
    return id.substring(0, 8) + '****************';
  }
};
```

### Environment-Specific Masking

**Production vs Non-Production:**
```yaml
environments:
  production:
    masking: disabled
    access: restricted
    
  staging:
    masking: partial
    rules:
      - mask_pii: true
      - preserve_relationships: true
      
  development:
    masking: full
    rules:
      - replace_pii: synthetic_data
      - scramble_ids: true
```

## PII Handling Guidelines

### Identifying PII

**PII Categories in Clinical Context:**
- Direct identifiers: Name, email, phone, address
- Indirect identifiers: Organization ID, user ID, IP address
- Clinical identifiers: Trial ID, signal ID, dataset references

### PII Processing Rules

**Collection Principles:**
- Collect only necessary PII
- Obtain explicit consent
- Document purpose of collection
- Implement purpose limitation

**Storage Rules:**
```javascript
const piiStorage = {
  // Separate PII from other data
  collections: {
    users: 'encrypted_users_collection',
    audit: 'encrypted_audit_collection'
  },
  
  // Field-level encryption for PII
  encryptedFields: [
    'email', 'phone', 'name', 'address',
    'ipAddress', 'userAgent'
  ],
  
  // Automatic expiration
  ttlIndexes: {
    sessions: 24 * 60 * 60, // 24 hours
    tempData: 7 * 24 * 60 * 60 // 7 days
  }
};
```

## Data Retention and Deletion

### Retention Policies

**Data Type Retention Matrix:**
```yaml
retention_policies:
  clinical_signals:
    retention_period: 10_years
    legal_basis: clinical_trial_regulations
    
  user_accounts:
    retention_period: 7_years_after_last_activity
    legal_basis: business_records
    
  audit_logs:
    retention_period: 7_years
    legal_basis: compliance_requirements
    
  session_data:
    retention_period: 24_hours
    legal_basis: operational_necessity
    
  temporary_files:
    retention_period: 7_days
    legal_basis: operational_cleanup
```

### Deletion Procedures

**Secure Deletion Process:**
```javascript
const secureDelete = {
  async deleteUserData(userId) {
    // 1. Create deletion audit record
    await auditLog('deletion_request', { userId, timestamp: new Date() });
    
    // 2. Soft delete (mark as deleted)
    await db.users.updateOne(
      { _id: userId },
      { $set: { deleted: true, deletedAt: new Date() } }
    );
    
    // 3. Anonymize PII
    await anonymizePII(userId);
    
    // 4. Schedule hard delete after retention period
    await scheduleHardDelete(userId, retentionPeriod);
    
    // 5. Remove from all caches
    await clearUserCaches(userId);
    
    // 6. Update deletion registry
    await updateDeletionRegistry(userId);
  }
};
```

### Right to Erasure Implementation

**GDPR Article 17 Compliance:**
```javascript
const rightToErasure = {
  async processRequest(requestId) {
    const request = await getErasureRequest(requestId);
    
    // Verify request authenticity
    if (!await verifyRequest(request)) {
      throw new Error('Invalid erasure request');
    }
    
    // Check for legal obligations to retain
    const retentionObligations = await checkLegalObligations(request.userId);
    
    if (retentionObligations.length > 0) {
      // Partial deletion - remove PII but keep anonymized records
      await partialErasure(request.userId);
    } else {
      // Complete deletion
      await completeErasure(request.userId);
    }
    
    // Send confirmation
    await sendErasureConfirmation(request);
  }
};
```

## Backup Encryption

### Backup Security Requirements

**Encryption Standards:**
- Use AES-256 for backup encryption
- Different keys for different backup sets
- Encrypted transmission to backup storage
- Encrypted backup media

**Backup Configuration:**
```bash
#!/bin/bash
# MongoDB encrypted backup script

# Variables
BACKUP_KEY=$(aws kms generate-data-key --key-id $MASTER_KEY_ID)
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="backup_${DATE}.tar.gz"

# Create encrypted backup
mongodump --uri="$MONGO_URI" --gzip --archive=/tmp/${BACKUP_FILE}

# Encrypt backup file
openssl enc -aes-256-cbc -salt -in /tmp/${BACKUP_FILE} \
  -out /backup/${BACKUP_FILE}.enc -k "${BACKUP_KEY}"

# Upload to secure storage
aws s3 cp /backup/${BACKUP_FILE}.enc \
  s3://nexus-secure-backups/${BACKUP_FILE}.enc \
  --server-side-encryption aws:kms \
  --sse-kms-key-id $BACKUP_KMS_KEY

# Clean up
shred -vfz -n 3 /tmp/${BACKUP_FILE}
```

### Backup Testing

**Monthly Validation:**
- Test backup restoration
- Verify encryption integrity
- Validate data completeness
- Document recovery time

## Data Protection Monitoring

### Automated Monitoring

**Key Metrics:**
```javascript
const dataProtectionMetrics = {
  encryptionStatus: {
    metric: 'percentage_encrypted_data',
    threshold: 100,
    alert: 'critical'
  },
  
  keyRotation: {
    metric: 'days_since_rotation',
    threshold: 90,
    alert: 'warning'
  },
  
  backupSuccess: {
    metric: 'successful_backup_percentage',
    threshold: 99,
    alert: 'critical'
  },
  
  deletionCompliance: {
    metric: 'deletion_request_completion_time',
    threshold: 30, // days
    alert: 'warning'
  }
};
```

### Compliance Dashboard

**Required Dashboards:**
- Encryption coverage by data type
- Key rotation status
- PII access patterns
- Deletion request status
- Backup success rates
- Data classification coverage

## Implementation Checklist

### Phase 1: Encryption (Week 1)
- [ ] Enable MongoDB encryption at rest
- [ ] Configure TLS 1.3 for all connections
- [ ] Implement field-level encryption
- [ ] Set up KMS integration

### Phase 2: Data Classification (Week 2)
- [ ] Classify all data elements
- [ ] Implement access controls by classification
- [ ] Configure data masking rules
- [ ] Set up audit logging

### Phase 3: Retention & Deletion (Week 3)
- [ ] Implement retention policies
- [ ] Create deletion procedures
- [ ] Build right to erasure workflow
- [ ] Test backup encryption

### Phase 4: Monitoring (Week 4)
- [ ] Deploy monitoring dashboards
- [ ] Configure alerts
- [ ] Conduct security review
- [ ] Document procedures

## References

- NIST SP 800-57: Key Management
- GDPR Guidelines on Encryption
- HIPAA Security Rule §164.312
- MongoDB Encryption at Rest
- AWS/Azure/GCP KMS Documentation