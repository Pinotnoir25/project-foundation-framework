# Create Test Plan Prompt

When creating test plans during development:

## 1. Start with Core Tests

As you build, identify:
- **Happy path**: Does it work as intended?
- **Key edge case**: What's likely to break?
- **Error handling**: Does it fail gracefully?

Document these in `test-plan-minimal.md`.

## 2. Expand Based on Risk

Add test cases when:
- **High risk area**: Payment, auth, data loss
- **Complex logic**: Multiple paths, calculations
- **External dependencies**: APIs, services
- **Performance critical**: User-facing latency
- **Regulatory requirements**: Compliance needs

## 3. Container Testing Approach

Since everything runs in Docker:
```yaml
# Basic test command
docker-compose run test

# With specific service
docker-compose run backend npm test

# Integration tests
docker-compose up -d db redis
docker-compose run test-integration
```

## 4. Progressive Test Documentation

### Phase 1: While Building
```markdown
## Authentication Tests
- ✓ User can login with valid credentials
- ✓ Invalid password shows error
- ✓ Account locks after 5 attempts
```

### Phase 2: When Stable
```markdown
## Authentication Tests

### Login Flow
1. **Valid login** - Returns JWT token
2. **Invalid password** - Returns 401 with message
3. **Account lockout** - Locks after 5 failed attempts
4. **Token expiry** - Refreshes automatically

Test data: See `test/fixtures/users.json`
```

### Phase 3: When Critical
Add performance tests, security scans, load tests

## 5. What NOT to Test

Don't write tests for:
- Framework functionality
- Third-party libraries
- Trivial getters/setters
- Configuration files

## Anti-Patterns

❌ Don't:
- Write 100-page test plans
- Test implementation details
- Create tests before code
- Aim for 100% coverage blindly

✅ Do:
- Test behavior, not implementation
- Focus on what could break
- Write tests as you code
- Prioritize based on risk

## Good Test Plan Example

```markdown
# User API Test Plan

## Core Functionality
1. Create user with valid data
2. Reject duplicate emails  
3. Validate email format
4. Send invitation email

## Edge Cases
- Concurrent user creation
- Database connection failure
- Email service timeout

## Performance
- Create 100 users < 5 seconds
- Search response < 200ms

## Container Setup
```bash
docker-compose run api npm test
```
```

Keep it lean, focused on real risks.