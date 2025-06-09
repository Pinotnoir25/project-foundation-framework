# API Documentation Standards

This document defines the documentation standards for all APIs in the Nexus MCP MongoDB server, ensuring consistency, completeness, and developer-friendly documentation.

## OpenAPI 3.0 Specification Requirements

### Base OpenAPI Structure
```yaml
openapi: 3.0.3
info:
  title: Nexus MCP MongoDB API
  description: |
    API for accessing clinical trial metadata through the Nexus MCP server.
    Provides RESTful endpoints for querying MongoDB collections containing
    CMP (Central Monitoring Platform) data.
  version: 1.0.0
  contact:
    name: Nexus API Support
    email: api-support@nexus-cmp.com
  license:
    name: Proprietary
    url: https://nexus-cmp.com/license
servers:
  - url: https://api.nexus-cmp.com/v1
    description: Production server
  - url: https://api-staging.nexus-cmp.com/v1
    description: Staging server
  - url: http://localhost:3000/v1
    description: Local development
```

### Security Schemes
```yaml
components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
      description: |
        JWT token obtained from /auth/login endpoint.
        Token expires after 24 hours.
    apiKey:
      type: apiKey
      in: header
      name: X-API-Key
      description: API key for service-to-service communication
    oauth2:
      type: oauth2
      flows:
        authorizationCode:
          authorizationUrl: https://auth.nexus-cmp.com/oauth/authorize
          tokenUrl: https://auth.nexus-cmp.com/oauth/token
          scopes:
            read:signals: Read signal data
            write:signals: Create and update signals
            read:trials: Read trial metadata
            admin:all: Full administrative access
```

### Endpoint Documentation Pattern
```yaml
paths:
  /signals:
    get:
      summary: List clinical trial signals
      description: |
        Retrieves a paginated list of signals based on filter criteria.
        Results are sorted by detection date in descending order by default.
      operationId: listSignals
      tags:
        - Signals
      parameters:
        - $ref: '#/components/parameters/TrialId'
        - $ref: '#/components/parameters/Severity'
        - $ref: '#/components/parameters/DateRange'
        - $ref: '#/components/parameters/Pagination'
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/SignalListResponse'
              examples:
                success:
                  $ref: '#/components/examples/SignalListExample'
        '400':
          $ref: '#/components/responses/BadRequest'
        '401':
          $ref: '#/components/responses/Unauthorized'
        '500':
          $ref: '#/components/responses/InternalError'
      x-code-samples:
        - lang: 'cURL'
          source: |
            curl -X GET "https://api.nexus-cmp.com/v1/signals?trialId=NCT12345678&severity=high" \
              -H "Authorization: Bearer YOUR_TOKEN"
        - lang: 'JavaScript'
          source: |
            const response = await fetch('https://api.nexus-cmp.com/v1/signals?trialId=NCT12345678', {
              headers: {
                'Authorization': 'Bearer YOUR_TOKEN'
              }
            });
            const signals = await response.json();
```

### Schema Definitions
```yaml
components:
  schemas:
    Signal:
      type: object
      required:
        - id
        - trialId
        - severity
        - category
        - detectedAt
      properties:
        id:
          type: string
          format: objectId
          description: Unique identifier for the signal
          example: "507f1f77bcf86cd799439011"
        trialId:
          type: string
          description: Clinical trial identifier
          pattern: "^NCT[0-9]{8}$"
          example: "NCT12345678"
        severity:
          type: string
          enum: [low, medium, high, critical]
          description: Signal severity level
        category:
          type: string
          enum: [safety, efficacy, quality, operational]
          description: Signal category
        description:
          type: string
          description: Detailed description of the signal
          maxLength: 5000
        detectedAt:
          type: string
          format: date-time
          description: Timestamp when signal was detected
        metadata:
          type: object
          additionalProperties: true
          description: Additional signal metadata
```

## API Documentation Structure

### Documentation Hierarchy
```
docs/
├── api/
│   ├── index.md                    # API overview and getting started
│   ├── authentication.md           # Authentication guide
│   ├── errors.md                   # Error handling reference
│   ├── pagination.md               # Pagination patterns
│   ├── filtering.md                # Query and filter syntax
│   ├── webhooks.md                 # Webhook configuration
│   ├── rate-limiting.md            # Rate limit details
│   ├── versioning.md               # API versioning guide
│   └── endpoints/
│       ├── signals.md              # Signal endpoints
│       ├── trials.md               # Trial endpoints
│       ├── datasets.md             # Dataset endpoints
│       ├── users.md                # User management
│       └── organizations.md        # Organization endpoints
```

### Endpoint Documentation Template
```markdown
# Signal Detection API

## Overview
The Signal Detection API provides endpoints for creating, querying, and managing 
statistical anomalies detected in clinical trial data.

## Base URL
```
https://api.nexus-cmp.com/v1/signals
```

## Authentication
All endpoints require authentication via Bearer token:
```
Authorization: Bearer <token>
```

## Endpoints

### List Signals
Retrieve a paginated list of signals with optional filtering.

**Endpoint:** `GET /signals`

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| trialId | string | No | Filter by clinical trial ID |
| severity | string | No | Filter by severity (low, medium, high, critical) |
| status | string | No | Filter by status (open, investigating, closed) |
| dateFrom | date | No | Start date for detection range |
| dateTo | date | No | End date for detection range |
| cursor | string | No | Pagination cursor |
| limit | integer | No | Results per page (max: 100, default: 20) |

**Example Request:**
```bash
curl -X GET "https://api.nexus-cmp.com/v1/signals?trialId=NCT12345678&severity=high&limit=10" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Example Response:**
```json
{
  "data": [
    {
      "id": "507f1f77bcf86cd799439011",
      "trialId": "NCT12345678",
      "severity": "high",
      "category": "safety",
      "description": "Elevated liver enzyme levels detected in treatment group",
      "detectedAt": "2024-06-08T10:00:00Z",
      "status": "open",
      "assignedTo": null,
      "metadata": {
        "affectedPatients": 15,
        "statisticalMethod": "z-score",
        "pValue": 0.003
      }
    }
  ],
  "pagination": {
    "cursor": "eyJpZCI6IjUwN2YxZjc3YmNmODZjZDc5OTQzOTAxMSJ9",
    "hasMore": true,
    "totalCount": 47
  }
}
```
```

## Example Request/Response for Each Endpoint

### Signal Creation Example
```yaml
post:
  summary: Create a new signal
  requestBody:
    required: true
    content:
      application/json:
        schema:
          $ref: '#/components/schemas/SignalCreate'
        examples:
          safetySignal:
            summary: Safety signal example
            value:
              trialId: "NCT12345678"
              severity: "high"
              category: "safety"
              description: "Elevated cardiac markers in subset of patients"
              detectedBy: "automated_analysis"
              statisticalDetails:
                method: "bayesian"
                threshold: 0.95
                baselineRate: 0.02
                observedRate: 0.08
          dataQualitySignal:
            summary: Data quality signal
            value:
              trialId: "NCT87654321"
              severity: "medium"
              category: "quality"
              description: "Missing lab values for 20% of patients"
              detectedBy: "completeness_check"
```

### MongoDB Query Example
```yaml
post:
  summary: Execute MongoDB query
  requestBody:
    content:
      application/json:
        examples:
          simpleQuery:
            summary: Simple filter query
            value:
              collection: "signals"
              filter:
                trialId: "NCT12345678"
                severity: "high"
              options:
                limit: 10
                sort:
                  detectedAt: -1
          complexQuery:
            summary: Complex aggregation query
            value:
              collection: "signals"
              pipeline:
                - $match:
                    trialId: "NCT12345678"
                - $group:
                    _id: "$severity"
                    count: { $sum: 1 }
                - $sort:
                    count: -1
```

## Error Response Catalog

### Standard Error Format
```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": {
      "field": "Additional context about the error"
    },
    "requestId": "req_abc123",
    "timestamp": "2024-06-08T10:00:00Z"
  }
}
```

### Common Error Codes

#### Authentication Errors
```json
{
  "error": {
    "code": "AUTH_TOKEN_EXPIRED",
    "message": "Authentication token has expired",
    "details": {
      "expiredAt": "2024-06-08T09:00:00Z",
      "tokenType": "bearer"
    }
  }
}
```

#### Validation Errors
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": {
      "violations": [
        {
          "field": "trialId",
          "code": "INVALID_FORMAT",
          "message": "Trial ID must match pattern NCT[0-9]{8}"
        },
        {
          "field": "severity",
          "code": "INVALID_ENUM",
          "message": "Severity must be one of: low, medium, high, critical"
        }
      ]
    }
  }
}
```

#### Database Errors
```json
{
  "error": {
    "code": "DATABASE_CONNECTION_ERROR",
    "message": "Unable to connect to database",
    "details": {
      "component": "mongodb",
      "retryable": true,
      "suggestedAction": "Please retry in a few moments"
    }
  }
}
```

### Error Code Reference
| Code | HTTP Status | Description | Retry |
|------|-------------|-------------|-------|
| AUTH_MISSING | 401 | No authentication provided | No |
| AUTH_INVALID | 401 | Invalid authentication credentials | No |
| AUTH_TOKEN_EXPIRED | 401 | Authentication token expired | Yes |
| PERMISSION_DENIED | 403 | Insufficient permissions | No |
| RESOURCE_NOT_FOUND | 404 | Requested resource not found | No |
| VALIDATION_ERROR | 400 | Request validation failed | No |
| DUPLICATE_RESOURCE | 409 | Resource already exists | No |
| RATE_LIMIT_EXCEEDED | 429 | Too many requests | Yes |
| DATABASE_ERROR | 500 | Database operation failed | Yes |
| INTERNAL_ERROR | 500 | Unexpected server error | Yes |

## Authentication Documentation

### Authentication Methods

#### JWT Bearer Token
```markdown
## JWT Authentication

### Obtaining a Token
POST /auth/login
Content-Type: application/json

{
  "username": "user@example.com",
  "password": "secure_password",
  "organizationId": "org_123"
}

Response:
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresIn": 86400,
  "refreshToken": "refresh_token_here"
}

### Using the Token
Include the token in the Authorization header:
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

### Token Claims
{
  "sub": "user_123",
  "org": "org_456",
  "permissions": ["read:signals", "write:signals"],
  "exp": 1717840800,
  "iat": 1717754400
}
```

#### API Key Authentication
```markdown
## API Key Authentication

### Obtaining an API Key
API keys are issued through the admin portal and are intended for 
service-to-service communication.

### Using API Keys
Include the API key in the X-API-Key header:
X-API-Key: nxs_prod_a1b2c3d4e5f6g7h8i9j0

### API Key Format
- Prefix: nxs_ (nexus)
- Environment: prod_, dev_, test_
- Random string: 20 alphanumeric characters
```

## Rate Limiting Documentation

### Rate Limit Headers
```http
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1717840800
X-RateLimit-Window: 3600
```

### Rate Limit Tiers
| Tier | Requests/Hour | Burst | Use Case |
|------|---------------|-------|----------|
| Free | 100 | 10 | Development/Testing |
| Basic | 1,000 | 100 | Small organizations |
| Professional | 10,000 | 500 | Medium organizations |
| Enterprise | 100,000 | 2,000 | Large organizations |
| Unlimited | Unlimited | 10,000 | Strategic partners |

### Rate Limit Response
```json
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "API rate limit exceeded",
    "details": {
      "limit": 1000,
      "window": "1h",
      "resetAt": "2024-06-08T11:00:00Z",
      "retryAfter": 1234
    }
  }
}
```

## Changelog and Deprecation Notices

### Changelog Format
```markdown
# API Changelog

## [1.2.0] - 2024-06-15
### Added
- New `/signals/bulk` endpoint for batch signal creation
- Support for webhook subscriptions
- GraphQL endpoint (beta)

### Changed
- Increased default pagination limit from 20 to 50
- Modified signal severity enum to include "info" level

### Deprecated
- `/signals/create` endpoint - use POST /signals instead
- `X-API-Version` header - version now in URL path

### Fixed
- Cursor pagination issue with deleted records
- Timezone handling in date filters

## [1.1.0] - 2024-05-01
### Added
- Change stream subscriptions via WebSocket
- Export functionality for large datasets
```

### Deprecation Policy
```markdown
## API Deprecation Policy

### Deprecation Timeline
1. **Announcement** - 6 months before removal
2. **Deprecation** - Feature marked as deprecated
3. **End of Life** - Feature removed

### Deprecation Headers
Deprecated endpoints return:
```
Sunset: Sat, 31 Dec 2024 23:59:59 GMT
Deprecation: true
Link: <https://docs.nexus-cmp.com/migrations/v2>; rel="successor-version"
```

### Migration Guides
Each deprecated feature includes:
- Reason for deprecation
- Recommended alternative
- Migration steps
- Code examples
```

## Interactive Documentation Setup (Swagger UI)

### Swagger Configuration
```yaml
# swagger-config.yaml
url: "/openapi.yaml"
dom_id: "#swagger-ui"
deepLinking: true
presets:
  - SwaggerUIBundle.presets.apis
  - SwaggerUIStandalonePreset
plugins:
  - SwaggerUIBundle.plugins.DownloadUrl
layout: "StandaloneLayout"
defaultModelsExpandDepth: 1
defaultModelExpandDepth: 1
displayRequestDuration: true
tryItOutEnabled: true
supportedSubmitMethods:
  - get
  - put
  - post
  - delete
  - options
  - head
  - patch
syntaxHighlight:
  activate: true
  theme: "monokai"
```

### Custom Swagger UI Theme
```css
/* Custom Nexus theme for Swagger UI */
.swagger-ui {
  font-family: 'Inter', sans-serif;
}

.swagger-ui .topbar {
  background-color: #1a1f2e;
  padding: 10px;
}

.swagger-ui .topbar .download-url-wrapper {
  display: none;
}

.swagger-ui .info .title {
  color: #2d3748;
}

.swagger-ui .btn.authorize {
  background-color: #4299e1;
  color: white;
}

.swagger-ui .btn.execute {
  background-color: #48bb78;
  color: white;
}

.swagger-ui .responses-wrapper .response.response-200 {
  border-color: #48bb78;
}

.swagger-ui .responses-wrapper .response.response-400,
.swagger-ui .responses-wrapper .response.response-404 {
  border-color: #f56565;
}
```

### Interactive Examples
```javascript
// Pre-populate authentication
window.onload = function() {
  // Check for saved auth token
  const token = localStorage.getItem('nexus_api_token');
  if (token) {
    window.ui.preauthorizeApiKey('bearerAuth', token);
  }
  
  // Add custom request interceptor
  window.ui.preauthorizeApiKey('apiKey', 'demo_key_for_testing');
  
  // Custom try-it-out defaults
  const spec = window.ui.getConfigs().spec;
  spec.paths['/signals'].get.parameters[0].default = 'NCT12345678';
};
```

## API Documentation Best Practices

### Writing Clear Descriptions
1. **Be Specific**: Avoid vague terms like "various" or "multiple"
2. **Use Examples**: Include realistic examples for complex fields
3. **Document Edge Cases**: Explain behavior for null, empty, or invalid values
4. **Specify Formats**: Document date formats, regex patterns, enum values

### Organizing Documentation
1. **Group by Feature**: Organize endpoints by business domain
2. **Progressive Disclosure**: Start with common use cases
3. **Cross-Reference**: Link related endpoints and concepts
4. **Version Everything**: Track changes to documentation

### Maintaining Documentation
1. **Automate Generation**: Generate from code annotations when possible
2. **Test Examples**: Ensure all examples actually work
3. **Review Regularly**: Update documentation with each release
4. **Gather Feedback**: Include feedback mechanisms in docs

### Documentation Tools
- **OpenAPI Generator**: Generate SDKs from specs
- **Redoc**: Alternative to Swagger UI
- **Postman Collections**: Import/export API collections
- **API Blueprint**: Alternative specification format
- **AsyncAPI**: For event-driven APIs