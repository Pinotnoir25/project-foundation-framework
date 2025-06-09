# Prompt: Convert PRD to Technical Specifications

Use this prompt to analyze a Product Requirements Document (PRD) and generate comprehensive technical specifications.

## Prompt

I need you to analyze the PRD at `[PRD_PATH]` and create detailed technical specifications. Please follow these steps:

### 1. Analyze the PRD
First, read and understand:
- Core functionality requirements
- User stories and acceptance criteria
- Performance requirements
- Security requirements
- Integration requirements
- Success metrics

### 2. Create Technical Architecture Document (TAD)
Generate a TAD that includes:
- System architecture overview
- Component breakdown and responsibilities
- Data flow diagrams
- Technology stack recommendations with justifications
- Integration points and APIs needed
- Security architecture
- Performance optimization strategies
- Scalability considerations

Save this as `docs/technical/architecture/[feature-name]-tad.md`

### 3. Design API Specifications
If the feature requires APIs:
- Define RESTful endpoints
- Specify request/response formats
- Document authentication requirements
- Include error handling specifications
- Define rate limiting rules

Save this as `docs/technical/api/[feature-name]-api.md`

### 4. Create Test Specifications
Develop comprehensive test plans:
- Unit test requirements (minimum 80% coverage)
- Integration test scenarios
- End-to-end test cases
- Performance test benchmarks
- Security test scenarios
- Test data requirements

Save this as `docs/technical/testing/[feature-name]-test-spec.md`

### 5. Define Infrastructure Requirements
Specify infrastructure needs:
- Compute resources (CPU, memory)
- Storage requirements
- Network configuration
- Container specifications
- Deployment strategy
- Monitoring and logging setup

Save this as `docs/technical/infrastructure/[feature-name]-infrastructure.md`

### 6. Document Technical Decisions
For each major technical decision:
- Provide context and constraints
- List alternatives considered
- Explain the chosen solution
- Document trade-offs and risks

### 7. Create Implementation Checklist
Generate a checklist of technical tasks:
- Environment setup
- Dependencies to install
- Configuration requirements
- Security measures to implement
- Performance optimizations
- Monitoring setup

### 8. Link to Tasks
Reference the task breakdown from `docs/tasks/features/[feature]/` and ensure technical specs align with planned implementation tasks.

Please ensure all documentation:
- Uses the appropriate templates from `docs/technical/templates/`
- Includes clear diagrams where helpful
- References the source PRD
- Provides specific, actionable technical guidance
- Considers both development and production environments

## Example Usage

```
@claude analyze PRD at docs/prd/features/core/mongodb-connection-manager-prd.md and create technical specifications

The assistant will:
1. Read the MongoDB Connection Manager PRD
2. Create a TAD with connection pooling architecture
3. Design APIs for connection management
4. Specify tests for connection scenarios
5. Define infrastructure for MongoDB deployment
6. Document decisions about connection strategies
```

## Expected Output Structure

```
docs/technical/
├── architecture/
│   └── mongodb-connection-manager-tad.md
├── api/
│   └── connection-management-api.md
├── testing/
│   └── mongodb-connection-test-spec.md
├── infrastructure/
│   └── mongodb-infrastructure.md
└── standards/
    └── mongodb-best-practices.md
```

## Additional Considerations

When generating technical specifications:

1. **Be Specific**: Include version numbers, specific configurations, and concrete examples
2. **Consider Scale**: Design for both MVP and future growth
3. **Security First**: Address security at every layer
4. **Performance Matters**: Include specific performance targets and how to achieve them
5. **Developer Experience**: Make specs easy for developers to implement
6. **Operational Excellence**: Consider monitoring, logging, and maintenance from the start

## Follow-up Prompts

After generating initial specs, you might use:
- "Review technical specs for completeness and identify gaps"
- "Generate docker-compose.yml based on infrastructure requirements"
- "Create API mock server based on specifications"
- "Generate test stubs from test specifications"