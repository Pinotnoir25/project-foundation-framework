# API Design Patterns

This document outlines generic API design patterns and best practices that can be applied to any type of project, whether it's REST, GraphQL, gRPC, or other API architectures.

## Query API Design

### Basic Query Structure
```typescript
interface Query {
  resource: string;
  filter: FilterQuery;
  options?: QueryOptions;
}

interface QueryOptions {
  projection?: Projection;
  sort?: Sort;
  limit?: number;
  offset?: number;
  hint?: IndexHint;
  explain?: boolean;
}
```

### RESTful Query Examples

#### Basic Resource Query
```http
GET /api/v1/resources?status=active&type=premium&created_after=2024-01-01
Accept: application/json

Response:
{
  "data": [...],
  "pagination": {
    "total": 150,
    "page": 1,
    "limit": 20
  }
}
```

#### Complex Filtering
```http
POST /api/v1/resources/search
Content-Type: application/json

{
  "filters": {
    "and": [
      { "field": "status", "operator": "in", "value": ["active", "pending"] },
      { "field": "score", "operator": "gte", "value": 80 },
      { "field": "tags", "operator": "contains", "value": "important" }
    ]
  },
  "sort": [
    { "field": "score", "order": "desc" },
    { "field": "created_at", "order": "desc" }
  ],
  "pagination": {
    "page": 1,
    "limit": 50
  }
}
```

### GraphQL Query Patterns

#### Basic Query
```graphql
query GetResources($filter: ResourceFilter!, $pagination: Pagination) {
  resources(filter: $filter, pagination: $pagination) {
    edges {
      node {
        id
        name
        status
        metadata
      }
    }
    pageInfo {
      hasNextPage
      endCursor
    }
  }
}
```

#### Nested Query with Relationships
```graphql
query GetResourceWithRelations($id: ID!) {
  resource(id: $id) {
    id
    name
    category {
      id
      name
    }
    associations {
      id
      type
      target {
        ... on TypeA {
          specificFieldA
        }
        ... on TypeB {
          specificFieldB
        }
      }
    }
  }
}
```

## Aggregation and Analytics APIs

### Aggregation Endpoint Design
```http
POST /api/v1/analytics/aggregate
Content-Type: application/json

{
  "resource": "events",
  "pipeline": [
    {
      "stage": "filter",
      "conditions": {
        "timestamp": { "$gte": "2024-01-01" }
      }
    },
    {
      "stage": "group",
      "by": ["category", "status"],
      "metrics": {
        "count": { "function": "count" },
        "avgValue": { "function": "avg", "field": "value" },
        "maxValue": { "function": "max", "field": "value" }
      }
    },
    {
      "stage": "sort",
      "by": { "count": -1 }
    }
  ]
}
```

### Time Series Analysis
```json
{
  "resource": "metrics",
  "timeSeries": {
    "field": "timestamp",
    "interval": "1h",
    "timezone": "UTC",
    "start": "2024-01-01T00:00:00Z",
    "end": "2024-01-31T23:59:59Z"
  },
  "metrics": [
    {
      "name": "request_count",
      "function": "count"
    },
    {
      "name": "avg_response_time",
      "function": "avg",
      "field": "response_time"
    },
    {
      "name": "error_rate",
      "function": "percentage",
      "condition": { "status": "error" }
    }
  ]
}
```

## Bulk Operations Handling

### Bulk Operations Endpoint
```http
POST /api/v1/bulk
Content-Type: application/json

{
  "operations": [
    {
      "method": "create",
      "resource": "items",
      "data": {
        "name": "New Item",
        "type": "standard"
      }
    },
    {
      "method": "update",
      "resource": "items",
      "id": "item_123",
      "data": {
        "status": "active"
      }
    },
    {
      "method": "delete",
      "resource": "items",
      "id": "item_456"
    }
  ],
  "options": {
    "atomic": true,
    "continueOnError": false
  }
}
```

### Bulk Import/Export
```http
POST /api/v1/import
Content-Type: multipart/form-data

FormData:
- file: data.csv
- format: csv
- resource: items
- options: {
    "mapping": {
      "Item Name": "name",
      "Item Type": "type",
      "Price": "price"
    },
    "validation": {
      "required": ["name", "type"],
      "unique": ["sku"]
    },
    "onConflict": "update"
  }
```

## Transaction Support in APIs

### Transaction Wrapper Pattern
```http
POST /api/v1/transactions
Content-Type: application/json

{
  "isolation": "read_committed",
  "operations": [
    {
      "resource": "accounts",
      "method": "update",
      "id": "acc_123",
      "data": { "balance": { "$decrement": 100 } }
    },
    {
      "resource": "accounts",
      "method": "update",
      "id": "acc_456",
      "data": { "balance": { "$increment": 100 } }
    },
    {
      "resource": "transactions",
      "method": "create",
      "data": {
        "from": "acc_123",
        "to": "acc_456",
        "amount": 100,
        "type": "transfer"
      }
    }
  ]
}
```

### Saga Pattern for Distributed Transactions
```typescript
interface Saga {
  id: string;
  steps: SagaStep[];
  compensations: CompensationStep[];
  state: 'pending' | 'executing' | 'completed' | 'compensating' | 'failed';
}

interface SagaStep {
  service: string;
  action: string;
  params: any;
  completed: boolean;
}
```

## Pagination Strategies

### Offset-Based Pagination
```http
GET /api/v1/items?page=2&limit=20

Response:
{
  "data": [...],
  "pagination": {
    "page": 2,
    "limit": 20,
    "total": 500,
    "totalPages": 25,
    "hasNext": true,
    "hasPrev": true
  }
}
```

### Cursor-Based Pagination
```http
GET /api/v1/items?cursor=eyJpZCI6MTIzLCJ0cyI6MTcwMDAwMDAwMH0&limit=20

Response:
{
  "data": [...],
  "pagination": {
    "nextCursor": "eyJpZCI6MTQzLCJ0cyI6MTcwMDAwMTAwMH0",
    "prevCursor": "eyJpZCI6MTAzLCJ0cyI6MTY5OTk5OTAwMH0",
    "hasNext": true,
    "hasPrev": true
  }
}
```

### Keyset Pagination
```sql
-- Efficient pagination using indexed columns
SELECT * FROM items 
WHERE (created_at, id) > ('2024-01-01 10:00:00', 'uuid-123')
ORDER BY created_at, id
LIMIT 20;
```

## Real-time Updates and Streaming

### WebSocket Subscriptions
```javascript
// Client subscription
{
  "action": "subscribe",
  "channels": [
    {
      "resource": "notifications",
      "filters": {
        "userId": "user_123",
        "type": ["alert", "message"]
      }
    },
    {
      "resource": "updates",
      "filters": {
        "entityType": "project",
        "entityId": "proj_456"
      }
    }
  ]
}

// Server push
{
  "channel": "notifications",
  "event": "new_notification",
  "data": {
    "id": "notif_789",
    "type": "alert",
    "message": "New alert received",
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

### Server-Sent Events (SSE)
```http
GET /api/v1/events/stream
Accept: text/event-stream

Response:
event: update
data: {"id": "123", "status": "processing"}

event: progress
data: {"id": "123", "progress": 45}

event: complete
data: {"id": "123", "status": "completed", "result": {...}}
```

## API Versioning Strategies

### URL Path Versioning
```
/api/v1/resources
/api/v2/resources
```

### Header Versioning
```http
GET /api/resources
Accept: application/vnd.company.v2+json
```

### Query Parameter Versioning
```
/api/resources?version=2
```

## Error Handling Patterns

### Standardized Error Response
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [
      {
        "field": "email",
        "code": "INVALID_FORMAT",
        "message": "Email format is invalid"
      }
    ],
    "requestId": "req_abc123",
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

### Problem Details (RFC 7807)
```json
{
  "type": "https://example.com/errors/out-of-credit",
  "title": "Out of credit",
  "status": 403,
  "detail": "Your current balance is 30, but that costs 50.",
  "instance": "/account/12345/transactions/abc"
}
```

## Rate Limiting and Throttling

### Rate Limit Headers
```http
HTTP/1.1 200 OK
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1704067200
X-RateLimit-Reset-After: 3600
```

### Retry-After Header
```http
HTTP/1.1 429 Too Many Requests
Retry-After: 120
Content-Type: application/json

{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Rate limit exceeded. Try again in 120 seconds.",
    "retryAfter": 120
  }
}
```

## Caching Strategies

### Cache Headers
```http
HTTP/1.1 200 OK
Cache-Control: public, max-age=3600, s-maxage=7200
ETag: "686897696a7c876b7e"
Last-Modified: Wed, 15 Jan 2024 10:00:00 GMT
Vary: Accept-Encoding, Accept-Language
```

### Conditional Requests
```http
GET /api/v1/resource/123
If-None-Match: "686897696a7c876b7e"
If-Modified-Since: Wed, 15 Jan 2024 10:00:00 GMT

Response:
HTTP/1.1 304 Not Modified
```

## API Security Patterns

### API Key Authentication
```http
GET /api/v1/resources
X-API-Key: your-api-key-here
```

### Bearer Token (JWT)
```http
GET /api/v1/resources
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### HMAC Signature
```http
GET /api/v1/resources
X-Signature: sha256=HMAC-SHA256(secret, timestamp + method + path + body)
X-Timestamp: 1704067200
```

## API Documentation Standards

### OpenAPI/Swagger Example
```yaml
openapi: 3.0.0
info:
  title: Generic API
  version: 1.0.0
paths:
  /resources:
    get:
      summary: List resources
      parameters:
        - name: filter
          in: query
          schema:
            type: object
        - name: sort
          in: query
          schema:
            type: string
      responses:
        '200':
          description: Success
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ResourceList'
```

## Performance Optimization

### Field Selection / Sparse Fieldsets
```http
GET /api/v1/resources?fields=id,name,status,metadata.tags
```

### Eager Loading / Include Related Data
```http
GET /api/v1/resources?include=category,tags,author
```

### Response Compression
```http
GET /api/v1/resources
Accept-Encoding: gzip, br

Response:
Content-Encoding: gzip
```

## Best Practices

### API Design Principles
- Use consistent naming conventions
- Follow REST principles where applicable
- Version your APIs appropriately
- Provide comprehensive error messages
- Document all endpoints thoroughly
- Implement proper authentication and authorization
- Use appropriate HTTP status codes
- Support content negotiation
- Implement idempotency for non-GET requests
- Provide filtering, sorting, and pagination

### Performance Best Practices
- Implement caching strategies
- Use database indexes effectively
- Limit response payload sizes
- Support partial responses
- Implement request/response compression
- Use connection pooling
- Monitor API performance
- Set appropriate timeouts

### Security Best Practices
- Always use HTTPS
- Implement rate limiting
- Validate all inputs
- Sanitize outputs
- Use secure authentication methods
- Implement proper CORS policies
- Log security events
- Regular security audits
- Keep dependencies updated
- Follow OWASP guidelines