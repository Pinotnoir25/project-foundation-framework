# Technical Documentation Prompts

This directory contains AI prompts for generating technical documentation from product requirements and other sources.

## Available Prompts

### 1. PRD to Technical Specifications
**File**: `prd-to-technical-spec.md`

Converts Product Requirements Documents into comprehensive technical specifications including:
- Technical Architecture Documents (TADs)
- API specifications
- Test plans
- Infrastructure requirements

**Usage**:
```
@claude analyze PRD at [path] and create technical specifications
```

### 2. Generate Test Plan
**File**: `generate-test-plan.md`

Creates detailed test plans from requirements including:
- Test strategies
- Test scenarios and cases
- Performance test plans
- Security test specifications
- Test data requirements

**Usage**:
```
@claude generate test plan for [feature] based on PRD at [path]
```

### 3. API Design
**File**: `api-design-prompt.md`

Designs REST APIs from feature requirements including:
- Resource modeling
- Endpoint specifications
- Request/response schemas
- Error handling
- Authentication/authorization

**Usage**:
```
@claude design REST API for [feature] based on PRD at [path]
```

### 4. Infrastructure Requirements
**File**: `infrastructure-requirements.md`

Determines infrastructure needs based on technical specifications:
- Resource calculations
- Scaling strategies
- Network architecture
- Container configurations
- Cost estimations

**Usage**:
```
@claude determine infrastructure requirements for [component] expecting [load]
```

## How to Use These Prompts

1. **Choose the Right Prompt**: Select based on what documentation you need to generate
2. **Provide Context**: Always include paths to relevant existing documentation
3. **Be Specific**: Include details about scale, environment, and constraints
4. **Review Output**: AI-generated documentation should be reviewed and refined
5. **Iterate**: Use follow-up prompts to refine and expand documentation

## Best Practices

### Before Using Prompts
- Ensure PRDs are complete and up-to-date
- Gather any additional context (scale, constraints, preferences)
- Check for existing technical documentation to avoid duplication

### When Using Prompts
- Provide clear file paths and feature names
- Specify the target environment (dev, staging, production)
- Include any specific requirements or constraints
- Mention any technology preferences or standards

### After Generation
- Review generated documentation for accuracy
- Ensure consistency with existing documentation
- Update cross-references and links
- Validate technical decisions against constraints
- Share with team for feedback

## Combining Prompts

Often you'll use multiple prompts in sequence:

1. Start with PRD to Technical Spec
2. Generate detailed API design if needed
3. Create comprehensive test plans
4. Determine infrastructure requirements
5. Generate implementation code stubs

Example workflow:
```bash
# 1. Generate technical specs from PRD
@claude analyze PRD at docs/prd/features/core/user-management-prd.md and create technical specifications

# 2. Design detailed APIs
@claude design REST API for user management based on the technical specs

# 3. Create test plan
@claude generate test plan for user management covering all API endpoints

# 4. Determine infrastructure
@claude determine infrastructure requirements for user management service expecting 10000 users
```

## Creating New Prompts

When creating new technical documentation prompts:

1. **Structure**: Follow the existing format with clear sections
2. **Examples**: Include concrete examples of expected output
3. **Checklists**: Provide validation checklists
4. **Templates**: Reference relevant templates to use
5. **Follow-ups**: Suggest next steps and related prompts

## Prompt Maintenance

- **Version Control**: Track changes to prompts as standards evolve
- **Feedback Loop**: Update prompts based on user feedback
- **Best Practices**: Incorporate learned best practices
- **Tool Updates**: Adjust for new tools and technologies

## Quick Reference

| Need | Prompt | Output |
|------|--------|--------|
| Technical design from requirements | prd-to-technical-spec.md | TAD, API specs, test plans |
| Comprehensive testing strategy | generate-test-plan.md | Test cases, scenarios, data |
| API design from features | api-design-prompt.md | REST endpoints, schemas |
| Infrastructure sizing | infrastructure-requirements.md | Resources, costs, configs |

## Related Documentation

- PRD Prompts: `docs/prd/prompts/`
- Task Prompts: `docs/tasks/prompts/`
- Technical Templates: `docs/technical/templates/`
- Quick Reference: `docs/technical/QUICK_REFERENCE.md`