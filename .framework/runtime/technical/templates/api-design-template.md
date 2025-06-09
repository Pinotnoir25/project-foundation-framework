# API Design Document: [API Name]

## Document Information

- **Version**: 1.0.0
- **Status**: Draft | In Review | Approved | Deprecated
- **API Version**: v1
- **Created**: YYYY-MM-DD
- **Last Updated**: YYYY-MM-DD
- **Author(s)**: [Names]
- **Related PRD**: [Link to PRD]
- **Related TAD**: [Link to Technical Architecture Document]

## Executive Summary

[Brief overview of the API, its purpose, and key design decisions. Include the primary use cases and target consumers.]

## Table of Contents

1. [API Overview](#api-overview)
2. [Authentication & Authorization](#authentication--authorization)
3. [API Design Principles](#api-design-principles)
4. [Base URL & Versioning](#base-url--versioning)
5. [Common Headers](#common-headers)
6. [Response Formats](#response-formats)
7. [Error Handling](#error-handling)
8. [Rate Limiting](#rate-limiting)
9. [Endpoints](#endpoints)
10. [Data Models](#data-models)
11. [Examples](#examples)
12. [SDK Support](#sdk-support)
13. [Migration Guide](#migration-guide)

## API Overview

### Purpose
[Describe what this API enables and why it exists]

### Target Consumers
- Consumer 1: [Description and use case]
- Consumer 2: [Description and use case]

### Key Features
- Feature 1: [Description]
- Feature 2: [Description]
- Feature 3: [Description]

### API Style
- [ ] REST
- [ ] GraphQL
- [ ] gRPC
- [ ] WebSocket
- [ ] Other: [Specify]

## Authentication & Authorization

### Authentication Method
[Describe the authentication mechanism: OAuth2, API Keys, JWT, etc.]

```
Authorization: Bearer <token>
```

### Authorization Model
[Describe how permissions are structured and enforced]

### Security Considerations
- HTTPS required for all endpoints
- Token expiration: [Duration]
- Refresh token strategy: [If applicable]

## API Design Principles

1. **RESTful Design**: Follow REST conventions for resource naming and HTTP methods
2. **Consistency**: Uniform response formats and error handling
3. **Versioning**: Backward compatibility with clear versioning strategy
4. **Documentation**: Self-documenting endpoints with clear naming
5. **Performance**: Pagination, filtering, and selective field returns

## Base URL & Versioning

### Base URLs
- **Development**: `https://api-dev.example.com/v1`
- **Staging**: `https://api-staging.example.com/v1`
- **Production**: `https://api.example.com/v1`

### Versioning Strategy
- URL path versioning: `/v1/`, `/v2/`
- Breaking changes trigger major version increment
- Non-breaking changes are added to current version

### Version Lifecycle
- **Deprecation Notice**: 6 months
- **End of Life**: 12 months after deprecation

## Common Headers

### Request Headers
| Header | Required | Description | Example |
|--------|----------|-------------|---------|
| Authorization | Yes | Bearer token | `Bearer eyJ...` |
| Content-Type | Yes* | Media type of request body | `application/json` |
| Accept | No | Preferred response format | `application/json` |
| X-Request-ID | No | Client-generated request ID | `550e8400-e29b-41d4-a716` |

*Required for requests with body (POST, PUT, PATCH)

### Response Headers
| Header | Description | Example |
|--------|-------------|---------|
| X-Request-ID | Request identifier for tracking | `550e8400-e29b-41d4-a716` |
| X-Rate-Limit-Remaining | Remaining requests in window | `99` |
| X-Rate-Limit-Reset | Unix timestamp of rate limit reset | `1640995200` |

## Response Formats

### Success Response
```json
{
  "status": "success",
  "data": {
    // Response data here
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "version": "1.0.0"
  }
}
```

### Paginated Response
```json
{
  "status": "success",
  "data": [
    // Array of items
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total_pages": 5,
    "total_items": 100,
    "has_next": true,
    "has_previous": false
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

## Error Handling

### Error Response Format
```json
{
  "status": "error",
  "error": {
    "code": "RESOURCE_NOT_FOUND",
    "message": "The requested resource was not found",
    "details": {
      "resource": "user",
      "id": "123456"
    },
    "request_id": "550e8400-e29b-41d4-a716"
  }
}
```

### Standard Error Codes
| HTTP Status | Error Code | Description |
|-------------|------------|-------------|
| 400 | INVALID_REQUEST | Request validation failed |
| 401 | UNAUTHORIZED | Missing or invalid authentication |
| 403 | FORBIDDEN | Insufficient permissions |
| 404 | NOT_FOUND | Resource not found |
| 409 | CONFLICT | Resource conflict (e.g., duplicate) |
| 429 | RATE_LIMITED | Too many requests |
| 500 | INTERNAL_ERROR | Server error |
| 503 | SERVICE_UNAVAILABLE | Service temporarily unavailable |

## Rate Limiting

### Limits
| Tier | Requests/Hour | Burst Limit |
|------|---------------|-------------|
| Free | 1,000 | 100/min |
| Basic | 10,000 | 1,000/min |
| Pro | 100,000 | 10,000/min |
| Enterprise | Custom | Custom |

### Rate Limit Headers
```
X-Rate-Limit-Limit: 1000
X-Rate-Limit-Remaining: 999
X-Rate-Limit-Reset: 1640995200
```

### Rate Limit Exceeded Response
```json
{
  "status": "error",
  "error": {
    "code": "RATE_LIMITED",
    "message": "Rate limit exceeded",
    "retry_after": 3600
  }
}
```

## Endpoints

### Resource: [Resource Name]

#### List [Resources]
```
GET /v1/[resources]
```

**Description**: Retrieve a paginated list of [resources]

**Query Parameters**:
| Parameter | Type | Required | Description | Default |
|-----------|------|----------|-------------|---------|
| page | integer | No | Page number | 1 |
| per_page | integer | No | Items per page | 20 |
| sort | string | No | Sort field | created_at |
| order | string | No | Sort order (asc/desc) | desc |
| filter | string | No | Filter expression | - |

**Response**: 
```json
{
  "status": "success",
  "data": [
    {
      "id": "123",
      "name": "Example",
      "created_at": "2024-01-15T10:30:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total_pages": 5,
    "total_items": 100
  }
}
```

#### Get [Resource]
```
GET /v1/[resources]/{id}
```

**Description**: Retrieve a specific [resource] by ID

**Path Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | string | Yes | Resource identifier |

**Response**:
```json
{
  "status": "success",
  "data": {
    "id": "123",
    "name": "Example",
    "description": "Detailed description",
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-15T10:30:00Z"
  }
}
```

#### Create [Resource]
```
POST /v1/[resources]
```

**Description**: Create a new [resource]

**Request Body**:
```json
{
  "name": "Example",
  "description": "Description of the resource",
  "metadata": {
    "key": "value"
  }
}
```

**Response**: 
```json
{
  "status": "success",
  "data": {
    "id": "124",
    "name": "Example",
    "description": "Description of the resource",
    "created_at": "2024-01-15T10:30:00Z"
  }
}
```

#### Update [Resource]
```
PUT /v1/[resources]/{id}
```

**Description**: Update an existing [resource]

**Path Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | string | Yes | Resource identifier |

**Request Body**:
```json
{
  "name": "Updated Example",
  "description": "Updated description"
}
```

**Response**: 
```json
{
  "status": "success",
  "data": {
    "id": "124",
    "name": "Updated Example",
    "description": "Updated description",
    "updated_at": "2024-01-15T11:00:00Z"
  }
}
```

#### Delete [Resource]
```
DELETE /v1/[resources]/{id}
```

**Description**: Delete a [resource]

**Path Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | string | Yes | Resource identifier |

**Response**: 
```json
{
  "status": "success",
  "message": "Resource deleted successfully"
}
```

## Data Models

### [Model Name]
```json
{
  "id": {
    "type": "string",
    "description": "Unique identifier",
    "example": "550e8400-e29b-41d4-a716"
  },
  "name": {
    "type": "string",
    "description": "Display name",
    "example": "Example Resource",
    "minLength": 1,
    "maxLength": 255
  },
  "description": {
    "type": "string",
    "description": "Detailed description",
    "example": "This is an example resource",
    "maxLength": 1000
  },
  "status": {
    "type": "string",
    "enum": ["active", "inactive", "pending"],
    "description": "Current status",
    "example": "active"
  },
  "metadata": {
    "type": "object",
    "description": "Additional metadata",
    "additionalProperties": true
  },
  "created_at": {
    "type": "string",
    "format": "date-time",
    "description": "Creation timestamp",
    "example": "2024-01-15T10:30:00Z"
  },
  "updated_at": {
    "type": "string",
    "format": "date-time",
    "description": "Last update timestamp",
    "example": "2024-01-15T10:30:00Z"
  }
}
```

### Validation Rules
- **name**: Required, 1-255 characters
- **description**: Optional, max 1000 characters
- **status**: Required, must be one of: active, inactive, pending
- **metadata**: Optional, max 10 properties

## Examples

### Example 1: Create and Retrieve a Resource

**Step 1: Create Resource**
```bash
curl -X POST https://api.example.com/v1/resources \
  -H "Authorization: Bearer eyJ..." \
  -H "Content-Type: application/json" \
  -d '{
    "name": "My Resource",
    "description": "This is my first resource"
  }'
```

**Response**:
```json
{
  "status": "success",
  "data": {
    "id": "123",
    "name": "My Resource",
    "description": "This is my first resource",
    "created_at": "2024-01-15T10:30:00Z"
  }
}
```

**Step 2: Retrieve Resource**
```bash
curl -X GET https://api.example.com/v1/resources/123 \
  -H "Authorization: Bearer eyJ..."
```

### Example 2: Filtering and Pagination

```bash
curl -X GET "https://api.example.com/v1/resources?page=2&per_page=50&sort=name&order=asc&filter=status:active" \
  -H "Authorization: Bearer eyJ..."
```

### Example 3: Error Handling

**Request with Invalid Data**:
```bash
curl -X POST https://api.example.com/v1/resources \
  -H "Authorization: Bearer eyJ..." \
  -H "Content-Type: application/json" \
  -d '{
    "description": "Missing required name field"
  }'
```

**Error Response**:
```json
{
  "status": "error",
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": {
      "name": ["This field is required"]
    }
  }
}
```

## SDK Support

### Official SDKs
- **JavaScript/TypeScript**: `npm install @example/api-client`
- **Python**: `pip install example-api-client`
- **Go**: `go get github.com/example/api-client-go`

### SDK Example (JavaScript)
```javascript
import { ApiClient } from '@example/api-client';

const client = new ApiClient({
  apiKey: 'your-api-key',
  baseUrl: 'https://api.example.com/v1'
});

// Create a resource
const resource = await client.resources.create({
  name: 'My Resource',
  description: 'Description'
});

// List resources
const resources = await client.resources.list({
  page: 1,
  perPage: 20
});
```

## Migration Guide

### Migrating from v0 to v1

#### Breaking Changes
1. **Authentication**: API keys replaced with OAuth2 tokens
2. **Response Format**: Standardized response wrapper
3. **Error Codes**: New error code system

#### Migration Steps
1. Update authentication to use Bearer tokens
2. Update response parsing to handle new format
3. Update error handling for new error codes

#### Deprecated Endpoints
| Old Endpoint | New Endpoint | Deprecation Date |
|--------------|--------------|------------------|
| GET /resources | GET /v1/resources | 2024-06-01 |
| POST /resources | POST /v1/resources | 2024-06-01 |

---

**Note**: This API documentation is versioned alongside the API implementation. Always refer to the version that matches your API version.