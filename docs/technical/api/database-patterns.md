# Database Design Patterns

This document outlines database design patterns and best practices that can be applied to various database systems including relational (PostgreSQL, MySQL), NoSQL (MongoDB, DynamoDB), and other data storage solutions.

## Query Design Patterns

### Generic Query Structure
```typescript
interface DatabaseQuery {
  table: string;
  conditions: QueryConditions;
  options?: QueryOptions;
}

interface QueryOptions {
  fields?: string[];
  orderBy?: OrderClause[];
  limit?: number;
  offset?: number;
  joins?: JoinClause[];
  groupBy?: string[];
}
```

### SQL Query Patterns

#### Basic CRUD Operations
```sql
-- Create
INSERT INTO users (name, email, status) 
VALUES ('John Doe', 'john@example.com', 'active');

-- Read with filtering
SELECT id, name, email, created_at 
FROM users 
WHERE status = 'active' 
  AND created_at >= '2024-01-01'
ORDER BY created_at DESC
LIMIT 20 OFFSET 0;

-- Update
UPDATE users 
SET status = 'inactive', 
    updated_at = CURRENT_TIMESTAMP 
WHERE id = 123;

-- Delete (soft delete pattern)
UPDATE users 
SET deleted_at = CURRENT_TIMESTAMP 
WHERE id = 123;
```

#### Complex Joins and Aggregations
```sql
-- Multi-table join with aggregation
SELECT 
    p.id,
    p.name,
    COUNT(DISTINCT o.id) as order_count,
    SUM(oi.quantity * oi.price) as total_revenue,
    AVG(r.rating) as avg_rating
FROM products p
LEFT JOIN order_items oi ON p.id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.id
LEFT JOIN reviews r ON p.id = r.product_id
WHERE p.status = 'active'
  AND o.created_at >= DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY)
GROUP BY p.id, p.name
HAVING order_count > 0
ORDER BY total_revenue DESC;
```

### NoSQL Query Patterns

#### Document Database Queries
```javascript
// MongoDB-style query
db.collection.find({
  status: "active",
  score: { $gte: 80 },
  tags: { $in: ["important", "urgent"] },
  "metadata.reviewed": true
})
.sort({ score: -1, createdAt: -1 })
.limit(20)
.skip(0);

// Aggregation pipeline
db.collection.aggregate([
  { $match: { status: "active" } },
  { $unwind: "$items" },
  { $group: {
    _id: "$category",
    totalValue: { $sum: "$items.value" },
    avgValue: { $avg: "$items.value" },
    count: { $sum: 1 }
  }},
  { $sort: { totalValue: -1 } }
]);
```

#### Key-Value Store Patterns
```python
# Redis-style operations
# Simple key-value
SET user:123:profile '{"name": "John", "email": "john@example.com"}'
GET user:123:profile

# Hash operations
HSET user:123 name "John" email "john@example.com" 
HGET user:123 email
HGETALL user:123

# Sets for relationships
SADD user:123:friends "456" "789" "012"
SISMEMBER user:123:friends "456"
SINTER user:123:friends user:456:friends
```

## Transaction Patterns

### ACID Transaction Pattern
```sql
BEGIN TRANSACTION;

-- Debit from account
UPDATE accounts 
SET balance = balance - 100,
    updated_at = CURRENT_TIMESTAMP
WHERE id = 'ACC001' 
  AND balance >= 100;

-- Check if update succeeded
IF @@ROWCOUNT = 0 THEN
  ROLLBACK;
  RETURN 'Insufficient funds';
END IF;

-- Credit to account
UPDATE accounts 
SET balance = balance + 100,
    updated_at = CURRENT_TIMESTAMP
WHERE id = 'ACC002';

-- Record transaction
INSERT INTO transactions (from_account, to_account, amount, type, timestamp)
VALUES ('ACC001', 'ACC002', 100, 'transfer', CURRENT_TIMESTAMP);

COMMIT;
```

### Distributed Transaction Patterns

#### Two-Phase Commit
```typescript
class TwoPhaseCommit {
  async executeTransaction(operations: Operation[]) {
    const transactionId = generateId();
    
    // Phase 1: Prepare
    const prepareResults = await Promise.all(
      operations.map(op => op.prepare(transactionId))
    );
    
    if (prepareResults.every(result => result.canCommit)) {
      // Phase 2: Commit
      await Promise.all(
        operations.map(op => op.commit(transactionId))
      );
      return { success: true, transactionId };
    } else {
      // Rollback
      await Promise.all(
        operations.map(op => op.rollback(transactionId))
      );
      return { success: false, transactionId };
    }
  }
}
```

#### Saga Pattern
```typescript
interface SagaStep {
  execute: () => Promise<any>;
  compensate: () => Promise<void>;
}

class SagaOrchestrator {
  async executeSaga(steps: SagaStep[]) {
    const executedSteps: number[] = [];
    
    try {
      for (let i = 0; i < steps.length; i++) {
        await steps[i].execute();
        executedSteps.push(i);
      }
      return { success: true };
    } catch (error) {
      // Compensate in reverse order
      for (let i = executedSteps.length - 1; i >= 0; i--) {
        await steps[executedSteps[i]].compensate();
      }
      throw error;
    }
  }
}
```

## Indexing Strategies

### Relational Database Indexes
```sql
-- Single column index
CREATE INDEX idx_users_email ON users(email);

-- Composite index
CREATE INDEX idx_orders_user_status_date 
ON orders(user_id, status, created_at DESC);

-- Partial index
CREATE INDEX idx_active_users 
ON users(email) 
WHERE status = 'active';

-- Unique index
CREATE UNIQUE INDEX idx_unique_email 
ON users(LOWER(email));

-- Full-text index
CREATE FULLTEXT INDEX idx_products_search 
ON products(name, description);

-- Covering index
CREATE INDEX idx_covering_orders 
ON orders(user_id, created_at) 
INCLUDE (status, total_amount);
```

### NoSQL Indexing
```javascript
// MongoDB indexes
// Single field
db.collection.createIndex({ "email": 1 });

// Compound index
db.collection.createIndex({ 
  "category": 1, 
  "status": 1, 
  "score": -1 
});

// Text index
db.collection.createIndex({ 
  "title": "text", 
  "content": "text" 
});

// Geospatial index
db.collection.createIndex({ 
  "location": "2dsphere" 
});

// TTL index for automatic expiration
db.sessions.createIndex(
  { "expiresAt": 1 }, 
  { expireAfterSeconds: 0 }
);
```

## Data Modeling Patterns

### Normalized vs Denormalized

#### Normalized Design (3NF)
```sql
-- Normalized structure
CREATE TABLE authors (
  id INT PRIMARY KEY,
  name VARCHAR(100),
  email VARCHAR(100)
);

CREATE TABLE books (
  id INT PRIMARY KEY,
  title VARCHAR(200),
  author_id INT REFERENCES authors(id),
  published_date DATE
);

CREATE TABLE categories (
  id INT PRIMARY KEY,
  name VARCHAR(50)
);

CREATE TABLE book_categories (
  book_id INT REFERENCES books(id),
  category_id INT REFERENCES categories(id),
  PRIMARY KEY (book_id, category_id)
);
```

#### Denormalized Design
```javascript
// Denormalized document
{
  "_id": "book_123",
  "title": "Database Design Patterns",
  "author": {
    "id": "author_456",
    "name": "Jane Smith",
    "email": "jane@example.com"
  },
  "categories": ["Technology", "Databases", "Programming"],
  "publishedDate": "2024-01-15",
  "metadata": {
    "pageCount": 450,
    "isbn": "978-1234567890"
  }
}
```

### Event Sourcing Pattern
```sql
-- Event store table
CREATE TABLE events (
  id BIGSERIAL PRIMARY KEY,
  aggregate_id UUID NOT NULL,
  aggregate_type VARCHAR(100) NOT NULL,
  event_type VARCHAR(100) NOT NULL,
  event_data JSONB NOT NULL,
  metadata JSONB,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_aggregate (aggregate_id, created_at)
);

-- Snapshot table for performance
CREATE TABLE snapshots (
  aggregate_id UUID PRIMARY KEY,
  aggregate_type VARCHAR(100) NOT NULL,
  version BIGINT NOT NULL,
  state JSONB NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Sharding and Partitioning

### Horizontal Partitioning
```sql
-- Range partitioning by date
CREATE TABLE orders (
  id BIGSERIAL,
  user_id INT,
  created_at TIMESTAMP,
  total_amount DECIMAL(10,2)
) PARTITION BY RANGE (created_at);

CREATE TABLE orders_2024_q1 PARTITION OF orders
FOR VALUES FROM ('2024-01-01') TO ('2024-04-01');

CREATE TABLE orders_2024_q2 PARTITION OF orders
FOR VALUES FROM ('2024-04-01') TO ('2024-07-01');

-- Hash partitioning by user_id
CREATE TABLE user_data (
  user_id INT,
  data JSONB
) PARTITION BY HASH (user_id);

CREATE TABLE user_data_0 PARTITION OF user_data
FOR VALUES WITH (modulus 4, remainder 0);
```

### Sharding Strategies
```typescript
// Consistent hashing for sharding
class ShardRouter {
  private shards: Shard[];
  
  getShardForKey(key: string): Shard {
    const hash = this.hashFunction(key);
    const shardIndex = hash % this.shards.length;
    return this.shards[shardIndex];
  }
  
  // Range-based sharding
  getShardByRange(value: number): Shard {
    if (value < 1000000) return this.shards[0];
    if (value < 2000000) return this.shards[1];
    return this.shards[2];
  }
  
  // Geo-based sharding
  getShardByLocation(location: GeoPoint): Shard {
    const region = this.getRegion(location);
    return this.shardsByRegion[region];
  }
}
```

## Caching Patterns

### Cache-Aside Pattern
```typescript
class CacheAsideRepository {
  async get(id: string): Promise<Entity> {
    // Try cache first
    const cached = await cache.get(`entity:${id}`);
    if (cached) return cached;
    
    // Load from database
    const entity = await database.findById(id);
    if (entity) {
      // Store in cache
      await cache.set(`entity:${id}`, entity, ttl);
    }
    
    return entity;
  }
  
  async update(id: string, data: any): Promise<void> {
    // Update database
    await database.update(id, data);
    
    // Invalidate cache
    await cache.delete(`entity:${id}`);
  }
}
```

### Write-Through Cache
```typescript
class WriteThroughCache {
  async save(entity: Entity): Promise<void> {
    // Write to cache and database simultaneously
    await Promise.all([
      cache.set(`entity:${entity.id}`, entity),
      database.save(entity)
    ]);
  }
}
```

## Connection Pooling

### Generic Pool Configuration
```typescript
interface PoolConfig {
  min: number;              // Minimum connections
  max: number;              // Maximum connections
  idleTimeoutMillis: number; // Remove idle connections
  connectionTimeoutMillis: number; // Connection timeout
  maxWaitingClients: number; // Queue size
  testOnBorrow: boolean;     // Validate before use
}

const poolConfig: PoolConfig = {
  min: 5,
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 5000,
  maxWaitingClients: 10,
  testOnBorrow: true
};
```

### Connection Pool Monitoring
```typescript
class PoolMonitor {
  getPoolStats() {
    return {
      totalConnections: this.pool.totalCount,
      activeConnections: this.pool.borrowedCount,
      idleConnections: this.pool.idleCount,
      waitingRequests: this.pool.pendingCount,
      poolUtilization: (this.pool.borrowedCount / this.pool.max) * 100
    };
  }
  
  checkPoolHealth() {
    const stats = this.getPoolStats();
    
    if (stats.poolUtilization > 80) {
      logger.warn('Pool utilization high', stats);
    }
    
    if (stats.waitingRequests > 5) {
      logger.error('Pool exhausted, requests queuing', stats);
    }
  }
}
```

## Backup and Recovery Strategies

### Backup Patterns
```bash
#!/bin/bash
# Generic backup script

# Configuration
BACKUP_DIR="/backups/database"
RETENTION_DAYS=30
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Backup strategies
case $DB_TYPE in
  "postgresql")
    pg_dump -h $DB_HOST -U $DB_USER -d $DB_NAME \
      --format=custom --compress=9 \
      > "$BACKUP_DIR/backup_$TIMESTAMP.dump"
    ;;
    
  "mysql")
    mysqldump -h $DB_HOST -u $DB_USER -p$DB_PASS \
      --single-transaction --routines --triggers \
      $DB_NAME | gzip > "$BACKUP_DIR/backup_$TIMESTAMP.sql.gz"
    ;;
    
  "mongodb")
    mongodump --uri=$DB_URI --gzip \
      --out="$BACKUP_DIR/backup_$TIMESTAMP"
    ;;
esac

# Cleanup old backups
find $BACKUP_DIR -type f -mtime +$RETENTION_DAYS -delete
```

### Point-in-Time Recovery
```sql
-- PostgreSQL PITR setup
-- Enable WAL archiving
ALTER SYSTEM SET wal_level = replica;
ALTER SYSTEM SET archive_mode = on;
ALTER SYSTEM SET archive_command = 'cp %p /archive/%f';

-- Create restore point
SELECT pg_create_restore_point('before_major_update');

-- Restore to specific time
-- recovery.conf
restore_command = 'cp /archive/%f %p'
recovery_target_time = '2024-01-15 10:30:00'
recovery_target_action = 'promote'
```

## Performance Optimization

### Query Optimization Techniques
```sql
-- Use EXPLAIN to analyze queries
EXPLAIN (ANALYZE, BUFFERS) 
SELECT * FROM large_table 
WHERE status = 'active' 
  AND created_at > '2024-01-01';

-- Optimize with proper indexes
CREATE INDEX CONCURRENTLY idx_status_date 
ON large_table(status, created_at) 
WHERE status = 'active';

-- Use materialized views for complex queries
CREATE MATERIALIZED VIEW sales_summary AS
SELECT 
  DATE_TRUNC('day', created_at) as sale_date,
  product_category,
  COUNT(*) as transaction_count,
  SUM(amount) as total_amount
FROM sales
GROUP BY 1, 2;

CREATE INDEX ON sales_summary(sale_date, product_category);
```

### Database Tuning Parameters
```ini
# PostgreSQL tuning example
# Memory settings
shared_buffers = 25% of RAM
effective_cache_size = 75% of RAM
work_mem = RAM / max_connections / 2
maintenance_work_mem = RAM / 16

# Checkpoint settings
checkpoint_completion_target = 0.9
wal_buffers = 16MB
max_wal_size = 4GB

# Query planner
random_page_cost = 1.1  # For SSD
effective_io_concurrency = 200  # For SSD
```

## Security Patterns

### Row-Level Security
```sql
-- PostgreSQL RLS example
-- Enable RLS
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY user_documents ON documents
  FOR ALL
  TO application_role
  USING (user_id = current_setting('app.current_user_id')::INT);

-- Multi-tenant isolation
CREATE POLICY tenant_isolation ON all_tables
  USING (tenant_id = current_setting('app.current_tenant_id')::INT);
```

### Data Encryption
```sql
-- Column-level encryption
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Encrypt sensitive data
INSERT INTO users (email, encrypted_ssn) 
VALUES (
  'user@example.com',
  pgp_sym_encrypt('123-45-6789', 'encryption_key')
);

-- Decrypt when needed
SELECT 
  email,
  pgp_sym_decrypt(encrypted_ssn, 'encryption_key') as ssn
FROM users
WHERE id = 123;
```

## Monitoring and Diagnostics

### Performance Monitoring Queries
```sql
-- Long running queries
SELECT 
  pid,
  now() - pg_stat_activity.query_start AS duration,
  query,
  state
FROM pg_stat_activity
WHERE (now() - pg_stat_activity.query_start) > interval '5 minutes';

-- Table bloat
SELECT 
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename) - pg_relation_size(schemaname||'.'||tablename)) AS external_size
FROM pg_tables
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC
LIMIT 10;

-- Connection stats
SELECT 
  datname,
  numbackends,
  xact_commit,
  xact_rollback,
  blks_read,
  blks_hit,
  tup_returned,
  tup_fetched,
  tup_inserted,
  tup_updated,
  tup_deleted
FROM pg_stat_database;
```

## Best Practices

### Design Principles
- Choose the right database for your use case
- Design for scalability from the start
- Normalize when consistency is critical
- Denormalize for read performance
- Use appropriate data types
- Plan for data growth
- Consider data lifecycle
- Document your schema

### Performance Best Practices
- Index strategically, not excessively
- Monitor query performance regularly
- Use connection pooling
- Implement caching where appropriate
- Batch operations when possible
- Avoid N+1 query problems
- Use database-specific optimizations
- Regular maintenance (vacuum, analyze, etc.)

### Security Best Practices
- Use parameterized queries
- Implement least privilege access
- Encrypt sensitive data
- Regular security audits
- Monitor database access
- Implement row-level security where needed
- Regular backups with encryption
- Secure connection strings