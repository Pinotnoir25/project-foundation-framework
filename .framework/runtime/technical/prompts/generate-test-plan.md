# Prompt: Generate Comprehensive Test Plan

Use this prompt to create detailed test plans from PRDs and technical specifications.

## Prompt

I need you to generate a comprehensive test plan for `[FEATURE_NAME]` based on:
- PRD at: `[PRD_PATH]`
- Technical specs at: `[TECH_SPEC_PATH]` (if available)

Please create a test plan that covers all aspects of quality assurance.

### 1. Analyze Requirements
Extract from the PRD:
- Functional requirements
- User stories and acceptance criteria
- Performance benchmarks
- Security requirements
- Edge cases and error scenarios

### 2. Define Test Strategy
Create an overall testing approach:
- Testing methodology (TDD, BDD, etc.)
- Test levels (unit, integration, e2e, performance, security)
- Automation strategy (what to automate vs manual)
- Test environment requirements
- Test data management approach

### 3. Generate Test Scenarios
For each user story, create:
- Happy path scenarios
- Edge cases
- Error scenarios
- Performance scenarios
- Security scenarios

### 4. Design Test Cases
For each scenario, specify:
- Test ID and title
- Priority (Critical, High, Medium, Low)
- Type (Positive, Negative, Boundary)
- Preconditions
- Test steps with specific inputs
- Expected results
- Postconditions
- Automation feasibility

### 5. Create Test Data Specifications
Define:
- Valid test data sets
- Invalid/boundary test data
- Performance test data volumes
- Security test payloads
- Data setup and cleanup procedures

### 6. Specify Performance Tests
Include:
- Load test scenarios (normal, peak, stress)
- Performance benchmarks from PRD
- Resource utilization targets
- Scalability test plans
- Performance test scripts/examples

### 7. Design Security Tests
Cover:
- Authentication testing
- Authorization/permission testing
- Input validation testing
- Injection attack testing
- Session management testing
- Encryption verification

### 8. Plan Integration Tests
Define tests for:
- API integrations
- Database interactions
- External service dependencies
- Message queue interactions
- Error handling across services

### 9. Create Test Execution Plan
Specify:
- Test execution order
- Dependencies between tests
- Test environment setup
- Parallel execution strategy
- Test reporting structure

### 10. Define Success Criteria
Include:
- Coverage targets (e.g., 80% code coverage)
- Performance thresholds
- Security scan requirements
- Zero critical bugs
- All acceptance criteria met

Save the complete test plan as `docs/technical/testing/[feature-name]-test-spec.md`

## Example Usage

```
@claude generate test plan for {{Feature Name}} based on PRD at docs/prd/features/{{category}}/{{feature}}-prd.md

The assistant will create:
- Test strategy for {{analysis_type}}
- Test cases for {{primary_function}}
- Performance tests for large datasets
- Security tests for data access
- Integration tests with {{database_type}}
```

## Test Case Example Format

```markdown
### TC001: Successful User Login
- **Category**: Authentication
- **Priority**: Critical
- **Type**: Positive
- **Automated**: Yes

**Preconditions**:
- User account exists with email: test@example.com
- User is not currently logged in

**Test Steps**:
1. Navigate to login page
2. Enter email: test@example.com
3. Enter password: ValidPass123!
4. Click "Login" button

**Expected Results**:
- User redirected to dashboard
- Session token created
- Last login time updated

**Test Data**:
```json
{
  "validUser": {
    "email": "test@example.com",
    "password": "ValidPass123!"
  }
}
```
```

## Performance Test Example

```yaml
load_test:
  tool: k6
  scenario: "Normal Load - {{Process Type}}"
  virtual_users: 100
  ramp_up: 5m
  sustain: 30m
  ramp_down: 5m
  
  thresholds:
    - http_req_duration: p(95) < 500ms
    - http_req_failed: rate < 0.01
    - {{metric_name}}: p(95) < 2s
  
  test_data:
    - 1000 {{entity_plural}}
    - 50 {{sub_entities}} per {{entity}}
    - 100 concurrent users
```

## Additional Considerations

When generating test plans:

1. **Risk-Based Testing**: Prioritize tests based on risk and impact
2. **Maintainability**: Create reusable test components
3. **Traceability**: Link tests to requirements
4. **Automation ROI**: Focus automation on high-value, repetitive tests
5. **Negative Testing**: Don't forget unhappy paths
6. **Cross-Browser/Platform**: Consider compatibility requirements

## Follow-up Prompts

- "Generate Postman collection from API test cases"
- "Create Cypress test scripts from e2e test cases"
- "Generate load test scripts for k6/JMeter"
- "Create test data factories for the test scenarios"
- "Generate security test payloads for penetration testing"