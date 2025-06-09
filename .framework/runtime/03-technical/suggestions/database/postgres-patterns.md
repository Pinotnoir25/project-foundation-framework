# PostgreSQL Patterns Template

## Overview
Production-ready PostgreSQL patterns for relational data with strong consistency, ACID compliance, and advanced features.

## When to Suggest
- Relational data with complex relationships
- Need for ACID transactions
- Complex queries and reporting
- Data integrity requirements
- Financial or regulated applications

## Core Patterns

### Schema Design Principles
- Use UUID for primary keys (distributed-friendly)
- Include audit columns (created_at, updated_at)
- Soft deletes with deleted_at column
- Proper indexing strategy
- Foreign key constraints for referential integrity

### Base Table Pattern
```sql
-- Base audit columns for all tables
CREATE TABLE base_table (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id)
);

-- Updated timestamp trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_[table_name]_updated_at BEFORE UPDATE
    ON [table_name] FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

### User Management Schema
```sql
-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    last_login_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

-- Indexes
CREATE INDEX idx_users_email ON users(email) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_username ON users(username) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_active ON users(is_active) WHERE deleted_at IS NULL;

-- User profiles
CREATE TABLE user_profiles (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    avatar_url VARCHAR(500),
    bio TEXT,
    phone VARCHAR(20),
    date_of_birth DATE,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### Role-Based Access Control (RBAC)
```sql
-- Roles table
CREATE TABLE roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    is_system BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Permissions table
CREATE TABLE permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    resource VARCHAR(100) NOT NULL,
    action VARCHAR(50) NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(resource, action)
);

-- Role permissions junction
CREATE TABLE role_permissions (
    role_id UUID REFERENCES roles(id) ON DELETE CASCADE,
    permission_id UUID REFERENCES permissions(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (role_id, permission_id)
);

-- User roles junction
CREATE TABLE user_roles (
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    role_id UUID REFERENCES roles(id) ON DELETE CASCADE,
    granted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    granted_by UUID REFERENCES users(id),
    expires_at TIMESTAMPTZ,
    PRIMARY KEY (user_id, role_id)
);

-- Helper view for checking permissions
CREATE VIEW user_permissions AS
SELECT DISTINCT
    ur.user_id,
    p.resource,
    p.action
FROM user_roles ur
JOIN role_permissions rp ON ur.role_id = rp.role_id
JOIN permissions p ON rp.permission_id = p.id
WHERE ur.expires_at IS NULL OR ur.expires_at > NOW();
```

### Multi-Tenancy Pattern
```sql
-- Tenants table
CREATE TABLE tenants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    settings JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

-- Row-level security policy example
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation ON products
    FOR ALL
    USING (tenant_id = current_setting('app.current_tenant')::UUID);

-- Alternative: Schema-based multi-tenancy
-- Create schema per tenant dynamically
```

### Audit Trail Pattern
```sql
-- Generic audit log
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_name VARCHAR(100) NOT NULL,
    record_id UUID NOT NULL,
    action VARCHAR(20) NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE')),
    old_values JSONB,
    new_values JSONB,
    changed_fields TEXT[],
    user_id UUID REFERENCES users(id),
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Partition by month for performance
CREATE TABLE audit_logs_2024_01 PARTITION OF audit_logs
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

-- Index for common queries
CREATE INDEX idx_audit_logs_table_record ON audit_logs(table_name, record_id);
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at DESC);
```

### Hierarchical Data Pattern
```sql
-- Categories with closure table pattern
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    parent_id UUID REFERENCES categories(id),
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Closure table for efficient hierarchy queries
CREATE TABLE category_closure (
    ancestor_id UUID REFERENCES categories(id) ON DELETE CASCADE,
    descendant_id UUID REFERENCES categories(id) ON DELETE CASCADE,
    depth INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY (ancestor_id, descendant_id)
);

-- Materialized path alternative
ALTER TABLE categories ADD COLUMN path TEXT;
-- Example path: /root/electronics/computers/laptops
CREATE INDEX idx_categories_path ON categories USING GIST (path gist_trgm_ops);
```

### Full-Text Search Pattern
```sql
-- Products with full-text search
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    search_vector TSVECTOR,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Update search vector
CREATE FUNCTION update_product_search_vector() RETURNS TRIGGER AS $$
BEGIN
    NEW.search_vector := 
        setweight(to_tsvector('english', COALESCE(NEW.name, '')), 'A') ||
        setweight(to_tsvector('english', COALESCE(NEW.description, '')), 'B');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_product_search_vector_trigger
    BEFORE INSERT OR UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION update_product_search_vector();

-- GIN index for fast searches
CREATE INDEX idx_products_search ON products USING GIN(search_vector);

-- Search query example
SELECT * FROM products
WHERE search_vector @@ plainto_tsquery('english', 'laptop computer')
ORDER BY ts_rank(search_vector, plainto_tsquery('english', 'laptop computer')) DESC;
```

### Event Sourcing Pattern
```sql
-- Events table
CREATE TABLE events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    aggregate_id UUID NOT NULL,
    aggregate_type VARCHAR(100) NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    event_version INTEGER NOT NULL,
    event_data JSONB NOT NULL,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID REFERENCES users(id)
);

-- Ensure event ordering
CREATE UNIQUE INDEX idx_events_aggregate_version 
    ON events(aggregate_id, event_version);

-- Event snapshots for performance
CREATE TABLE event_snapshots (
    aggregate_id UUID PRIMARY KEY,
    aggregate_type VARCHAR(100) NOT NULL,
    snapshot_data JSONB NOT NULL,
    event_version INTEGER NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### Performance Optimization Patterns

#### Indexing Strategy
```sql
-- Composite indexes for common queries
CREATE INDEX idx_orders_user_status_created 
    ON orders(user_id, status, created_at DESC)
    WHERE deleted_at IS NULL;

-- Partial indexes for specific conditions
CREATE INDEX idx_users_unverified 
    ON users(created_at) 
    WHERE is_verified = false AND deleted_at IS NULL;

-- Expression indexes
CREATE INDEX idx_users_email_lower 
    ON users(LOWER(email));
```

#### Partitioning Strategy
```sql
-- Time-based partitioning
CREATE TABLE logs (
    id UUID DEFAULT gen_random_uuid(),
    level VARCHAR(20),
    message TEXT,
    metadata JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
) PARTITION BY RANGE (created_at);

-- Auto-create monthly partitions
CREATE OR REPLACE FUNCTION create_monthly_partition()
RETURNS VOID AS $$
DECLARE
    start_date DATE;
    end_date DATE;
    partition_name TEXT;
BEGIN
    start_date := DATE_TRUNC('month', CURRENT_DATE);
    end_date := start_date + INTERVAL '1 month';
    partition_name := 'logs_' || TO_CHAR(start_date, 'YYYY_MM');
    
    EXECUTE format('CREATE TABLE IF NOT EXISTS %I PARTITION OF logs 
        FOR VALUES FROM (%L) TO (%L)', 
        partition_name, start_date, end_date);
END;
$$ LANGUAGE plpgsql;
```

### Connection Configuration
```yaml
# Database connection pool settings
database:
  host: localhost
  port: 5432
  name: myapp
  user: myapp_user
  password: secure_password
  
  # Connection pool
  pool:
    min_size: 5
    max_size: 20
    acquire_timeout: 30s
    idle_timeout: 300s
    
  # Performance settings
  options:
    statement_timeout: 30s
    lock_timeout: 10s
    idle_in_transaction_session_timeout: 60s
```

## Migration Strategy
```sql
-- Example migration with safety checks
BEGIN;

-- Add new column with default
ALTER TABLE users 
    ADD COLUMN IF NOT EXISTS email_verified_at TIMESTAMPTZ;

-- Backfill data
UPDATE users 
SET email_verified_at = created_at 
WHERE is_verified = true 
    AND email_verified_at IS NULL;

-- Add constraint after backfill
ALTER TABLE users 
    ADD CONSTRAINT check_email_verified 
    CHECK (is_verified = false OR email_verified_at IS NOT NULL);

COMMIT;
```

## Key Benefits
- ACID compliance for data integrity
- Rich querying capabilities
- Strong typing and constraints
- Mature ecosystem and tooling
- Advanced features (JSONB, full-text search, etc.)
- Excellent performance with proper indexing
- Row-level security support

## Common Pitfalls to Avoid
- Over-normalization
- Missing indexes on foreign keys
- Not using connection pooling
- Ignoring VACUUM and ANALYZE
- Complex queries without EXPLAIN ANALYZE
- Not partitioning large tables
- Incorrect isolation levels