# API Design Principles

This document outlines the core API design principles for the {{PROJECT_NAME}} server, ensuring consistency, maintainability, and developer experience across all API endpoints.

## RESTful Design Principles

### Resource-Oriented Architecture
- APIs are organized around resources (nouns) rather than actions (verbs)
- Each resource has a unique identifier (URI)
- Resources can have relationships with other resources
- Operations on resources are performed using standard HTTP methods

### Statelessness
- Each request contains all information necessary to understand and process it
- Server maintains no client context between requests
- Authentication tokens are passed with each request
- Session state is stored client-side or in distributed cache

### Uniform Interface
- Consistent patterns across all endpoints
- Self-descriptive messages with proper content types
- HATEOAS (Hypermedia as the Engine of Application State) for discoverability
- Standard media types (application/json, application/hal+json)

## Resource Naming Conventions

### General Rules
```
# Collection resources (plural nouns)
GET /api/v1/{{resources}}
GET /api/v1/users
GET /api/v1/{{entities}}
GET /api/v1/{{items}}

# Instance resources
GET /api/v1/{{resources}}/{resourceId}
GET /api/v1/users/{userId}
GET /api/v1/{{entities}}/{entityId}
GET /api/v1/{{items}}/{itemId}

# Nested resources
GET /api/v1/{{resources}}/{resourceId}/{{sub-resources}}
GET /api/v1/{{entities}}/{entityId}/{{properties}}
GET /api/v1/{{items}}/{itemId}/{{actions}}
```

### Naming Guidelines
- Use lowercase letters
- Use hyphens to separate words (kebab-case)
- Use plural nouns for collections
- Avoid deep nesting (maximum 3 levels)
- Use query parameters for filtering, not path segments

### Domain-Specific Examples
```
# {{DOMAIN_ENTITY_1}} management
GET /api/v1/{{domain-entities}}
GET /api/v1/{{domain-entities}}/{entityId}/{{related-data}}
GET /api/v1/{{domain-entities}}/{entityId}/{{operations}}

# {{DOMAIN_ENTITY_2}} management
GET /api/v1/{{entity-definitions}}
GET /api/v1/{{entity-instances}}
GET /api/v1/{{entity-actions}}

# User permissions
GET /api/v1/users/{userId}/permissions
GET /api/v1/{{organizations}}/{organizationId}/roles
```

## URL Structure and Versioning Strategy

### Base URL Structure
```
https://api.{{domain}}.com/{version}/{resource}
```

### Versioning Strategy
- Version in URL path for major versions: `/api/v1/`, `/api/v2/`
- Minor versions handled through backward-compatible changes
- Deprecation notices in headers: `Sunset: Sat, 31 Dec 2024 23:59:59 GMT`
- Version negotiation through Accept header as fallback

### Environment-Specific URLs
```
# Development
https://api-dev.{{domain}}.com/v1/

# Staging
https://api-staging.{{domain}}.com/v1/

# Production
https://api.{{domain}}.com/v1/
```

## HTTP Method Usage

### GET - Retrieve Resources
```http
# List collection
GET /api/v1/datasets
# Retrieve specific resource
GET /api/v1/datasets/{id}
# Retrieve nested resources
GET /api/v1/datasets/{id}/variables
```

### POST - Create Resources
```http
# Create new resource
POST /api/v1/{{resources}}
Content-Type: application/json

{
  "name": "{{Resource Name}}",
  "{{parentId}}": "{{ID12345678}}",
  "{{properties}}": [...]
}
```

### PUT - Full Update
```http
# Replace entire resource
PUT /api/v1/{{resources}}/{id}
Content-Type: application/json

{
  "name": "Updated {{Resource Name}}",
  "{{parentId}}": "{{ID12345678}}",
  "{{properties}}": [...],
  "status": "active"
}
```

### PATCH - Partial Update
```http
# Update specific fields
PATCH /api/v1/{{resources}}/{id}
Content-Type: application/json

{
  "status": "archived",
  "archivedAt": "2024-06-08T10:00:00Z"
}
```

### DELETE - Remove Resources
```http
# Delete resource
DELETE /api/v1/{{resources}}/{id}

# Soft delete with reason
DELETE /api/v1/{{resources}}/{id}
Content-Type: application/json

{
  "reason": "{{Deletion reason}}",
  "deletedBy": "user123"
}
```

## Status Code Standards

### Success Codes
- `200 OK` - Successful GET, PUT, PATCH
- `201 Created` - Successful POST with resource creation
- `202 Accepted` - Request accepted for async processing
- `204 No Content` - Successful DELETE or action with no response body

### Client Error Codes
- `400 Bad Request` - Invalid request syntax or parameters
- `401 Unauthorized` - Missing or invalid authentication
- `403 Forbidden` - Authenticated but insufficient permissions
- `404 Not Found` - Resource does not exist
- `409 Conflict` - Resource state conflict
- `422 Unprocessable Entity` - Validation errors

### Server Error Codes
- `500 Internal Server Error` - Unexpected server error
- `502 Bad Gateway` - MongoDB connection issues
- `503 Service Unavailable` - Service temporarily down
- `504 Gateway Timeout` - Request timeout

## Pagination Patterns

### Cursor-Based Pagination (Preferred)
```http
GET /api/v1/{{resources}}?cursor=eyJpZCI6MTIzNDU2fQ&limit=20

Response:
{
  "data": [...],
  "pagination": {
    "cursor": "eyJpZCI6MTIzNDc2fQ",
    "hasMore": true,
    "totalCount": 1250
  }
}
```

### Offset-Based Pagination (Legacy Support)
```http
GET /api/v1/{{resources}}?page=2&limit=20

Response:
{
  "data": [...],
  "pagination": {
    "page": 2,
    "limit": 20,
    "totalPages": 50,
    "totalCount": 1000
  }
}
```

## Filtering, Sorting, and Searching

### Filtering
```http
# Simple filters
GET /api/v1/{{resources}}?status=active&{{attribute}}={{value}}

# Date range filters
GET /api/v1/{{resources}}?createdAfter=2024-01-01&createdBefore=2024-06-30

# Complex filters using query DSL
GET /api/v1/{{resources}}?filter={"$and":[{"status":"active"},{"{{attribute}}":{"$in":["{{value1}}","{{value2}}"]}}]}
```

### Sorting
```http
# Single field sort
GET /api/v1/{{resources}}?sort=createdAt

# Descending sort
GET /api/v1/{{resources}}?sort=-createdAt

# Multiple field sort
GET /api/v1/{{resources}}?sort={{field1}},-createdAt
```

### Searching
```http
# Full-text search
GET /api/v1/{{resources}}?search={{search-term}}

# Field-specific search
GET /api/v1/{{resources}}?name.contains={{partial-match}}

# Advanced search with database text search
GET /api/v1/{{resources}}?q={"$text":{"$search":"{{search phrase}}"}}
```

## Response Format Consistency

### Standard Response Envelope
```json
{
  "data": {
    "id": "507f1f77bcf86cd799439011",
    "type": "{{resource-type}}",
    "attributes": {
      "name": "{{Resource Name}}",
      "{{attribute1}}": "{{value1}}",
      "createdAt": "2024-06-08T10:00:00Z",
      "updatedAt": "2024-06-08T10:00:00Z"
    },
    "relationships": {
      "{{relation}}": {
        "data": [
          {"type": "{{related-type}}", "id": "507f1f77bcf86cd799439012"}
        ]
      }
    }
  },
  "meta": {
    "requestId": "req_123456",
    "timestamp": "2024-06-08T10:00:00Z"
  }
}
```

### Collection Response
```json
{
  "data": [...],
  "pagination": {
    "cursor": "eyJpZCI6MTIzNDU2fQ",
    "hasMore": true,
    "totalCount": 100
  },
  "meta": {
    "requestId": "req_123456",
    "timestamp": "2024-06-08T10:00:00Z"
  }
}
```

### Error Response
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed for {{resource}} creation",
    "details": [
      {
        "field": "name",
        "code": "REQUIRED",
        "message": "{{Resource}} name is required"
      }
    ]
  },
  "meta": {
    "requestId": "req_123456",
    "timestamp": "2024-06-08T10:00:00Z"
  }
}
```

## Field Selection and Sparse Responses

### Include Specific Fields
```http
GET /api/v1/{{resources}}?fields=id,name,{{field3}}
```

### Exclude Fields
```http
GET /api/v1/users?exclude=passwordHash,internalNotes
```

### Include Related Resources
```http
GET /api/v1/{{resources}}/{id}?include={{relation1}},{{relation2}}
```

## Best Practices

### Performance Optimization
- Implement field selection to reduce payload size
- Use compression (gzip) for responses
- Cache immutable resources with ETags
- Implement rate limiting per client

### Security Considerations
- Always use HTTPS
- Implement proper authentication (OAuth 2.0, JWT)
- Validate all inputs
- Sanitize outputs to prevent injection attacks
- Log all API access for audit trails

### Developer Experience
- Provide comprehensive error messages
- Include request IDs for debugging
- Offer SDK/client libraries
- Maintain backward compatibility
- Version deprecation notices

### Database-Specific Considerations
- Expose aggregation capabilities through query parameters
- Handle database-specific ID formats properly in URLs
- Implement proper indexing for common queries
- Use projection to limit returned fields
- Handle large result sets with cursor-based pagination