# Prompt: Design REST APIs from Requirements

Use this prompt to create comprehensive API designs from feature requirements.

## Prompt

I need you to design REST APIs for `[FEATURE_NAME]` based on:
- PRD at: `[PRD_PATH]`
- Technical architecture at: `[TAD_PATH]` (if available)

Please create a complete API specification following REST best practices and our API design template.

### 1. Analyze Requirements
From the PRD, identify:
- Resources that need APIs
- Operations required on each resource
- Data relationships
- Performance requirements
- Security/authorization needs
- Integration requirements

### 2. Design Resource Model
Define:
- Resource names (nouns, plural)
- Resource relationships
- Resource identifiers
- Nested vs flat structure decisions

### 3. Map HTTP Methods
For each resource, specify:
- GET - Retrieve resource(s)
- POST - Create new resource
- PUT - Full update
- PATCH - Partial update
- DELETE - Remove resource

### 4. Design URL Structure
Create RESTful URLs:
```
GET    /v1/resources              # List all
GET    /v1/resources/{id}         # Get one
POST   /v1/resources              # Create
PUT    /v1/resources/{id}         # Update
PATCH  /v1/resources/{id}         # Partial update
DELETE /v1/resources/{id}         # Delete
GET    /v1/resources/{id}/nested  # Nested resources
```

### 5. Define Request/Response Schemas
For each endpoint:
- Request body schema (JSON Schema)
- Response body schema
- Validation rules
- Required vs optional fields
- Data types and constraints

### 6. Specify Query Parameters
Design filtering, sorting, and pagination:
```
GET /v1/resources?
  filter[status]=active&
  filter[created_after]=2024-01-01&
  sort=-created_at&
  page=2&
  per_page=50&
  fields=id,name,status
```

### 7. Design Error Responses
Standardize error handling:
- Error response format
- HTTP status codes
- Error codes and messages
- Validation error details
- Rate limiting errors

### 8. Plan API Versioning
Define:
- Versioning strategy (URL path vs header)
- Version lifecycle
- Deprecation process
- Backward compatibility rules

### 9. Document Authentication
Specify:
- Authentication method (JWT, OAuth2, API Key)
- Authorization/permissions model
- Token refresh strategy
- Security headers required

### 10. Add API Examples
Provide:
- cURL examples
- Request/response examples
- SDK usage examples
- Common workflows

Save as `docs/technical/api/[feature-name]-api.md`

## Example Usage

```
@claude design REST API for User Management feature based on PRD at docs/prd/features/core/user-management-prd.md

The assistant will design:
- User resource endpoints
- Organization endpoints
- Permission endpoints
- Authentication flow
- User invitation workflow
```

## API Design Example

```yaml
# User Resource API

## List Users
GET /v1/users
Authorization: Bearer {token}

Query Parameters:
- organization_id (required): Filter by organization
- role: Filter by role (admin, member, viewer)
- status: Filter by status (active, inactive, pending)
- search: Search by name or email
- page: Page number (default: 1)
- per_page: Items per page (default: 20, max: 100)

Response: 200 OK
{
  "status": "success",
  "data": [
    {
      "id": "usr_123",
      "email": "user@example.com",
      "name": "John Doe",
      "role": "member",
      "status": "active",
      "organization_id": "org_456",
      "created_at": "2024-01-15T10:00:00Z",
      "last_login": "2024-01-20T15:30:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 150,
    "pages": 8
  }
}

## Create User
POST /v1/users
Authorization: Bearer {token}
Content-Type: application/json

{
  "email": "newuser@example.com",
  "name": "Jane Smith",
  "role": "member",
  "organization_id": "org_456",
  "send_invitation": true
}

Response: 201 Created
{
  "status": "success",
  "data": {
    "id": "usr_789",
    "email": "newuser@example.com",
    "name": "Jane Smith",
    "role": "member",
    "status": "pending",
    "organization_id": "org_456",
    "invitation_sent_at": "2024-01-15T10:00:00Z",
    "created_at": "2024-01-15T10:00:00Z"
  }
}
```

## Best Practices Checklist

When designing APIs, ensure:

1. **RESTful Principles**
   - [x] Resources are nouns, not verbs
   - [x] HTTP methods convey actions
   - [x] Stateless design
   - [x] Consistent naming conventions

2. **API Design**
   - [x] Versioning strategy defined
   - [x] Consistent response format
   - [x] Comprehensive error handling
   - [x] Pagination for list endpoints

3. **Security**
   - [x] Authentication required
   - [x] Authorization checks documented
   - [x] Rate limiting specified
   - [x] Input validation rules

4. **Documentation**
   - [x] All endpoints documented
   - [x] Request/response examples
   - [x] Error scenarios covered
   - [x] Integration guides included

## OpenAPI Specification

Also generate OpenAPI 3.0 specification:

```yaml
openapi: 3.0.0
info:
  title: User Management API
  version: 1.0.0
  description: API for managing users and organizations

servers:
  - url: https://api.example.com/v1
    description: Production server

paths:
  /users:
    get:
      summary: List users
      parameters:
        - name: organization_id
          in: query
          required: true
          schema:
            type: string
      responses:
        200:
          description: Successful response
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UserList'
```

## Follow-up Prompts

- "Generate OpenAPI specification from this API design"
- "Create Postman collection for testing these APIs"
- "Generate API client SDK in TypeScript"
- "Create API documentation website"
- "Design GraphQL schema from these REST endpoints"