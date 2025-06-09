# Technical Documentation System Guide

## Overview

The technical documentation system bridges product requirements and code implementation. It provides detailed specifications, architecture decisions, and implementation guidelines that complement your PRDs.

## What is Technical Documentation?

Technical documentation includes:
- **Architecture Documents**: System design, component interactions, and technical decisions
- **API Specifications**: Interface contracts, data models, and integration patterns
- **Infrastructure Specs**: Deployment configurations and operational requirements
- **Testing Strategies**: Test plans, coverage requirements, and quality processes
- **Security Guidelines**: Authentication, authorization, and data protection
- **Development Standards**: Coding conventions and best practices

## Purpose and Philosophy

Technical documentation serves to:
1. **Translate Requirements**: Convert PRDs into implementable specifications
2. **Capture Decisions**: Document architectural choices and trade-offs
3. **Enable Collaboration**: Provide clear contracts between components/teams
4. **Ensure Quality**: Define testing and security requirements upfront
5. **Facilitate Onboarding**: Help new developers understand the system

## Creating Technical Documentation with Claude

### From PRD to Technical Spec
When you have an approved PRD:
```
@claude Analyze PRD at [path] and create technical specifications
```

Claude will:
1. Extract technical requirements from the PRD
2. Use templates from `.framework/runtime/technical/templates/`
3. Apply prompts from `.framework/runtime/technical/prompts/`
4. Generate specifications addressing architecture, APIs, and testing

### Key Technical Documents

#### 1. Technical Architecture Documents (TADs)
Define system design and component architecture:
- High-level system overview
- Component responsibilities and interactions
- Technology choices with rationale
- Data flow and storage patterns
- Scalability and performance considerations

#### 2. API Design Documents
Specify interfaces and contracts:
- Endpoint definitions and REST/GraphQL schemas
- Request/response formats with examples
- Authentication and authorization requirements
- Error handling and status codes
- Versioning strategy

#### 3. Test Specifications
Plan quality assurance:
- Test strategy (unit, integration, e2e)
- Coverage requirements and metrics
- Test data and environment needs
- Performance benchmarks
- Security test scenarios

#### 4. Infrastructure Specifications
Document deployment and operations:
- Container configurations (Dockerfile, docker-compose)
- Environment variables and secrets management
- Resource requirements and limits
- Monitoring and logging setup
- Backup and disaster recovery

## Documentation Workflow

```
PRD → Technical Spec → Implementation → Documentation Updates
         ↓
    Architecture Doc
    API Design
    Test Plan
    Infrastructure Spec
```

### Best Practices

#### Do:
- **Start Early**: Create specs before coding begins
- **Keep Current**: Update docs alongside code changes
- **Be Specific**: Include concrete examples and schemas
- **Link Context**: Reference PRDs and related docs
- **Version Control**: Track changes and migrations
- **Review Together**: Include docs in code reviews

#### Don't:
- **Over-Engineer**: Don't design for imaginary requirements
- **Under-Document**: Don't skip "obvious" decisions
- **Work in Isolation**: Get feedback early and often
- **Ignore Standards**: Follow framework patterns in `.framework/runtime/technical/`
- **Forget Updates**: Stale docs are worse than no docs

## Common Commands

### Generate Documentation
```
# Create technical spec from PRD
@claude Create technical spec for the PRD at [path]

# Design API
@claude Design REST API for [feature] following our standards

# Create test plan
@claude Generate comprehensive test plan for [feature]

# Document infrastructure
@claude Create infrastructure spec for deploying [component]
```

### Update Documentation
```
# After implementation
@claude Update technical docs at [path] with implementation details

# API changes
@claude Update API documentation with new endpoints

# Architecture evolution
@claude Document architecture changes for [component]
```

### Review and Validate
```
# Check completeness
@claude Review technical documentation for [feature]

# Verify accuracy
@claude Validate technical docs against current implementation
```

## Integration Points

### With PRD System
- Technical specs reference source PRDs
- Success metrics inform test requirements
- User stories guide API design

### With Task Management
- Technical specs decompose into implementation tasks
- Documentation updates tracked as tasks
- Technical debt documented and prioritized

### With Development
- API specs can generate client/server stubs
- Test specs guide test implementation
- Infrastructure specs automate deployment

## Documentation Standards

### Structure
- Clear hierarchy with descriptive headings
- Consistent formatting across documents
- Tables for structured data
- Diagrams for complex relationships

### Content
- Write for developers new to the project
- Include rationale for decisions
- Provide concrete examples
- Document assumptions and constraints

### Maintenance
- Date all documents
- Track revision history
- Archive obsolete documentation
- Regular review cycles

## Common Patterns

### Microservices
- Service boundaries and responsibilities
- Inter-service communication patterns
- Data consistency strategies
- Service discovery and routing

### Event-Driven
- Event schemas and contracts
- Publishing and subscription patterns
- Event sourcing considerations
- Eventual consistency handling

### API-First
- API design before implementation
- Contract testing strategies
- Versioning and deprecation
- Client SDK generation

## Tips for Success

1. **Incremental Detail**: Start high-level, add detail as you learn
2. **Visual Communication**: Use diagrams for complex concepts
3. **Example-Driven**: Include request/response examples
4. **Decision Records**: Document why, not just what
5. **Living Documents**: Plan for updates from the start

## Conclusion

Technical documentation is your blueprint for implementation. It transforms product requirements into actionable specifications while capturing the reasoning behind technical decisions. Use it to align teams, ensure quality, and build maintainable systems.

For templates and standards, see `.framework/runtime/technical/`.