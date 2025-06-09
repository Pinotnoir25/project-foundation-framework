# Technical Documentation Quick Reference

Quick commands and workflows for common technical documentation tasks.

## Common Commands

### Generate Documentation

```bash
# Generate technical spec from PRD
@claude analyze PRD at docs/prd/features/[feature]/[name]-prd.md and create technical specifications

# Create architecture document
@claude create TAD for [component] with [requirements]

# Design API from requirements
@claude design REST API for [feature] following OpenAPI 3.0

# Generate test plan
@claude create test plan for [feature] covering unit, integration, and e2e tests

# Create infrastructure spec
@claude define infrastructure requirements for [component] supporting [load]
```

### Update Documentation

```bash
# Update TAD with implementation details
@claude update architecture document at [path] with implementation changes

# Add new API endpoint
@claude add endpoint [POST /api/v1/resource] to API documentation

# Update test coverage
@claude update test plan with new test cases for [scenario]

# Document security measures
@claude document security implementation for [feature]
```

### Review and Validate

```bash
# Review technical documentation completeness
@claude review all technical docs for [feature] and identify gaps

# Validate API design
@claude validate API design against REST best practices

# Check test coverage
@claude analyze test plan coverage for [feature]

# Verify infrastructure requirements
@claude verify infrastructure spec meets performance requirements
```

## Document Templates Quick Start

### Technical Architecture Document (TAD)
```
docs/technical/templates/tad-template.md
- System overview
- Component design
- Data flow
- Technology stack
- Deployment architecture
```

### API Design Document
```
docs/technical/templates/api-design-template.md
- API overview
- Authentication
- Endpoints
- Data models
- Error handling
```

### Test Specification
```
docs/technical/templates/test-specification-template.md
- Test strategy
- Test scenarios
- Coverage requirements
- Test data
- Performance criteria
```

### Infrastructure Specification
```
docs/technical/templates/infrastructure-template.md
- Infrastructure overview
- Resource requirements
- Deployment configuration
- Scaling strategy
- Monitoring setup
```

## Workflow Cheatsheet

### New Feature Technical Documentation

1. **Analyze PRD**
   ```
   @claude analyze PRD and identify technical requirements
   ```

2. **Create Technical Spec**
   ```
   @claude create technical specification covering architecture, API, and testing
   ```

3. **Design Architecture**
   ```
   @claude create TAD for [feature] components
   ```

4. **Define APIs**
   ```
   @claude design REST API with OpenAPI specification
   ```

5. **Plan Testing**
   ```
   @claude create comprehensive test plan
   ```

### API Development Flow

1. **Design API Contract**
   ```
   @claude design API endpoints for [resource]
   ```

2. **Document Data Models**
   ```
   @claude define request/response schemas
   ```

3. **Specify Error Handling**
   ```
   @claude document error codes and responses
   ```

4. **Create Examples**
   ```
   @claude generate API usage examples
   ```

### Infrastructure Setup

1. **Define Requirements**
   ```
   @claude analyze infrastructure needs for [component]
   ```

2. **Create Docker Config**
   ```
   @claude create Dockerfile and docker-compose.yml
   ```

3. **Document Environment**
   ```
   @claude document environment variables and configuration
   ```

4. **Setup Monitoring**
   ```
   @claude define monitoring and logging requirements
   ```

## File Naming Conventions

### Architecture Documents
```
[component]-tad.md
mongodb-connection-tad.md
authentication-service-tad.md
```

### API Documentation
```
[service]-api.md
signals-api.md
users-api.md
```

### Test Specifications
```
[feature]-test-spec.md
signal-detection-test-spec.md
user-management-test-spec.md
```

### Infrastructure Docs
```
[environment]-infrastructure.md
production-infrastructure.md
development-infrastructure.md
```

## Documentation Checklist

### Technical Specification
- [ ] Requirements analysis from PRD
- [ ] Technology stack selection
- [ ] Component breakdown
- [ ] Integration points
- [ ] Security considerations
- [ ] Performance requirements

### Architecture Document
- [ ] System diagram
- [ ] Component descriptions
- [ ] Data flow diagrams
- [ ] Technology justification
- [ ] Scalability plan
- [ ] Deployment strategy

### API Documentation
- [ ] API overview
- [ ] Authentication method
- [ ] Endpoint specifications
- [ ] Request/response examples
- [ ] Error code definitions
- [ ] Rate limiting rules

### Test Plan
- [ ] Test strategy
- [ ] Unit test requirements
- [ ] Integration test scenarios
- [ ] E2E test cases
- [ ] Performance benchmarks
- [ ] Security test cases

## Quick Tips

1. **Start with Templates**: Always use provided templates as starting points
2. **Link Everything**: Connect technical docs to PRDs and tasks
3. **Include Examples**: Add code snippets and configuration examples
4. **Version Control**: Track major changes in documentation
5. **Stay Current**: Update docs immediately when implementation changes

## Common Patterns

### MCP Server Documentation
```
1. Connection handling
2. Tool registration
3. Request/response flow
4. Error handling
5. Security measures
```

### MongoDB Integration
```
1. Connection management
2. Schema definitions
3. Query patterns
4. Index strategies
5. Migration plans
```

### Authentication Flow
```
1. Token generation
2. Validation process
3. Permission checks
4. Session management
5. Security headers
```

## Troubleshooting Documentation Issues

### Missing Information
```
@claude identify missing technical details for [feature]
```

### Outdated Documentation
```
@claude compare technical docs with current implementation
```

### Inconsistent Specifications
```
@claude review and align all technical documents for [feature]
```

### Incomplete Test Coverage
```
@claude analyze test plan and identify coverage gaps
```