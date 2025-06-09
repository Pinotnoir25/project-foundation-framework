# Document API Prompt

When documenting APIs during development:

## 1. Start Minimal

As you build endpoints, document:
- **Endpoint**: Method and path
- **Purpose**: One line description
- **Example**: Request and response

That's it. Add more only as needed.

## 2. When to Expand Documentation

Add details when:
- **External teams integrate**: They need contracts
- **Complex logic**: Non-obvious behavior
- **Special requirements**: Auth, rate limits, etc.
- **Breaking changes**: Version strategy needed

## 3. What to Document

### Essential (always):
```markdown
### GET /api/v1/users/:id
Get user by ID

**Response** (200):
```json
{
  "id": "123",
  "name": "John Doe",
  "email": "john@example.com"
}
```

### Additional (as needed):
- Query parameters and filtering
- Authentication requirements
- Error responses
- Rate limits
- Webhooks

## 4. Where to Document

- **Internal APIs**: Near the code (comments or README)
- **External APIs**: `docs/api/[feature]-api.md`
- **Public APIs**: Consider OpenAPI spec

## 5. API Documentation Evolution

1. **While building**: Method, path, example
2. **When stable**: Add query params, errors
3. **When public**: Full OpenAPI spec
4. **When versioned**: Migration guides

## Anti-Patterns

❌ Don't:
- Document before building
- List every possible error
- Duplicate what code shows
- Create 200-line specs upfront

✅ Do:
- Document as you build
- Show real examples
- Focus on contracts
- Keep it maintainable

## Good API Docs Example

```markdown
## User API

### Create User
POST /api/v1/users

Creates a new user. Sends invitation email if `send_invite` is true.

**Request**:
```json
{
  "email": "user@example.com",
  "name": "Jane Doe",
  "send_invite": true
}
```

**Response** (201):
```json
{
  "id": "456",
  "email": "user@example.com",
  "status": "invited"
}
```

**Errors**:
- `409`: Email already exists
- `422`: Invalid email format
```

That's enough for most APIs. Expand only when complexity demands it.