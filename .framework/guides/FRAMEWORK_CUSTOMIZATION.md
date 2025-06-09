# Framework Customization Guide

This document explains how the generic documentation framework dynamically adapts to your specific project through the use of template variables and context-aware customization.

## Overview

This documentation framework uses a template variable system (e.g., `{{VARIABLE_NAME}}`) that allows it to be customized for any project type, technology stack, or industry domain. When you use this framework with Claude, these variables are automatically replaced with project-specific values based on your project's context.

## How It Works

### 1. Project Context Detection

When you start working with Claude on your project, it analyzes:
- The `CLAUDE.md` file in your project root
- Existing code and configuration files
- Your initial requests and descriptions
- Domain-specific terminology you use

### 2. Automatic Variable Replacement

Claude automatically replaces template variables with appropriate values:

| Template Variable | Example Replacement | Context |
|------------------|-------------------|---------|
| `{{PROJECT_NAME}}` | "Nexus MCP Research Database" | From CLAUDE.md or project description |
| `{{DATABASE_TYPE}}` | "MongoDB" | From technology stack |
| `{{DOMAIN_ENTITY}}` | "Clinical Trial" | From domain context |
| `{{COMPLIANCE_FRAMEWORKS}}` | "HIPAA, GDPR" | From industry requirements |

### 3. Dynamic Document Generation

When generating documentation, Claude:
1. Uses the generic templates as a foundation
2. Replaces all template variables with project-specific values
3. Adds domain-specific examples and considerations
4. Ensures consistency across all generated documents

## Template Variables Reference

### Project Information
- `{{PROJECT_NAME}}` - Your project's name
- `{{PROJECT_TYPE}}` - Type of project (e.g., "API server", "Web application")
- `{{PROJECT_PURPOSE}}` - Main purpose or goal of the project
- `{{DOMAIN}}` - Business domain or industry

### Technology Stack
- `{{PRIMARY_LANGUAGE}}` - Main programming language
- `{{DATABASE_TYPE}}` - Database system (PostgreSQL, MongoDB, etc.)
- `{{FRAMEWORK}}` - Primary framework being used
- `{{ADDITIONAL_TOOLS}}` - Other important tools or services

### Domain Entities
- `{{DOMAIN_ENTITY_1}}`, `{{DOMAIN_ENTITY_2}}` - Main business entities
- `{{RESOURCE_TYPE}}` - Primary resource in your API
- `{{DATA_TYPE}}` - Type of data being processed

### Compliance & Security
- `{{COMPLIANCE_FRAMEWORKS}}` - Relevant compliance standards
- `{{SECURITY_REQUIREMENTS}}` - Specific security needs
- `{{DATA_PROTECTION_LAWS}}` - Applicable data protection regulations
- `{{INDUSTRY_STANDARDS}}` - Industry-specific standards

### Infrastructure
- `{{DEPLOYMENT_PLATFORM}}` - Where the application is deployed
- `{{CLOUD_PROVIDER}}` - Cloud service provider if applicable
- `{{CONTAINER_PLATFORM}}` - Container orchestration system

## Using the Framework

### Step 1: Initialize Your Project Context

Create or update your `CLAUDE.md` file with project-specific information:

```markdown
# CLAUDE.md

## Project Overview

This project is a [type of application] that [main purpose].

## Technology Stack
- Language: [Primary language]
- Database: [Database type]
- Framework: [Main framework]

## Domain Context
- Industry: [Your industry]
- Main Entities: [List key domain objects]
- Compliance: [Any compliance requirements]
```

### Step 2: Request Documentation Generation

When asking Claude to generate documentation, the framework automatically adapts:

```
"Create a PRD for user authentication in my project"
```

Claude will:
1. Use the PRD template
2. Replace template variables with your project's specifics
3. Add relevant examples from your domain
4. Include appropriate compliance considerations

### Step 3: Customize Further

You can override any template variable by specifying values:

```
"Create API documentation where {{RESOURCE_TYPE}} is 'Patient Records' and {{API_PROTOCOL}} is 'RESTful'"
```

## Examples of Customization

### Example 1: E-commerce Platform

**Context Detection:**
- Project: "ShopFlow API"
- Database: PostgreSQL
- Domain: E-commerce
- Entities: Products, Orders, Customers

**Generated Documentation:**
- API endpoints: `/api/v1/products`, `/api/v1/orders`
- Compliance: PCI-DSS, GDPR
- Examples use shopping cart and inventory scenarios

### Example 2: Healthcare System

**Context Detection:**
- Project: "MedTrack System"
- Database: MongoDB
- Domain: Healthcare
- Entities: Patients, Appointments, Prescriptions

**Generated Documentation:**
- API endpoints: `/api/v1/patients`, `/api/v1/appointments`
- Compliance: HIPAA, GDPR, FDA regulations
- Examples use medical records and patient privacy

### Example 3: Financial Services

**Context Detection:**
- Project: "FinCore Platform"
- Database: Oracle
- Domain: Banking
- Entities: Accounts, Transactions, Customers

**Generated Documentation:**
- API endpoints: `/api/v1/accounts`, `/api/v1/transactions`
- Compliance: SOX, PCI-DSS, Basel III
- Examples use banking transactions and audit trails

## Advanced Customization

### Custom Variable Definitions

You can define custom variables for your project:

```markdown
# In CLAUDE.md
## Custom Variables
- {{RATE_LIMIT}}: "100 requests per minute"
- {{SLA_TARGET}}: "99.9%"
- {{TEAM_SIZE}}: "5-10 developers"
```

### Domain-Specific Templates

Create domain-specific template extensions:

```
docs/
├── templates/
│   ├── domain/
│   │   ├── healthcare/
│   │   ├── finance/
│   │   └── ecommerce/
```

### Conditional Sections

Some templates include conditional sections that appear based on context:

```markdown
{{#if REQUIRES_COMPLIANCE}}
## Compliance Considerations
- {{COMPLIANCE_FRAMEWORK_1}}
- {{COMPLIANCE_FRAMEWORK_2}}
{{/if}}
```

## Best Practices

1. **Keep CLAUDE.md Updated**: Ensure your project context is current
2. **Use Consistent Terminology**: Define domain terms clearly
3. **Specify Requirements Early**: Include compliance and security needs upfront
4. **Review Generated Content**: Verify that customizations are appropriate
5. **Iterate and Refine**: Update templates based on your needs

## Troubleshooting

### Variables Not Replaced
If you see `{{VARIABLE}}` in generated documents:
1. Check if the variable is defined in your context
2. Provide the value explicitly in your request
3. Update CLAUDE.md with missing information

### Incorrect Domain Assumptions
If Claude makes wrong assumptions:
1. Clarify your domain in CLAUDE.md
2. Provide specific examples
3. Correct any misunderstandings explicitly

### Generic Examples
If examples are too generic:
1. Provide domain-specific scenarios
2. Include real use cases in your requests
3. Reference existing code or documentation

## Integration with Development Workflow

### 1. Project Initialization
```bash
# When starting a new project
1. Copy the framework to your project
2. Create CLAUDE.md with project details
3. Run: @claude Initialize documentation framework for my {{PROJECT_TYPE}} project
```

### 2. Feature Development
```bash
# When adding new features
@claude Create PRD for {{FEATURE_NAME}} using our project context
```

### 3. Technical Documentation
```bash
# When documenting implementation
@claude Generate technical specs based on PRD at {{PRD_PATH}}
```

### 4. Continuous Updates
```bash
# As project evolves
@claude Update documentation to reflect new {{CHANGES}}
```

## Conclusion

This framework provides a flexible foundation that adapts to any project while maintaining consistency and completeness. By using template variables and context-aware customization, it ensures that generated documentation is always relevant and specific to your project's needs.

Remember: The framework is a starting point. Feel free to modify templates, add new ones, or create domain-specific extensions as needed for your project.