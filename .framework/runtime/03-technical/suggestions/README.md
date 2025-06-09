# Technical Suggestions Catalog

This directory contains ready-to-use technical patterns and templates that can be suggested during the technical discovery process. Each suggestion includes complete implementation details, best practices, and customization options.

## Quick Reference

### Frontend Solutions

#### Next.js Minimal Dark Theme
- **File**: `frontend/nextjs-minimal-dark.md`
- **Best For**: Modern SaaS applications, enterprise tools
- **Key Features**: Dark theme default, glass morphism, Tailwind CSS
- **Stack**: Next.js 15, TypeScript, Tailwind CSS

#### React SPA Modern
- **File**: `frontend/react-spa-modern.md`
- **Best For**: Client-side applications, dashboards
- **Key Features**: Vite tooling, Tanstack Query, Zustand
- **Stack**: React 18, Vite, TypeScript

#### Vue Enterprise
- **File**: `frontend/vue-enterprise.md`
- **Best For**: Large-scale applications, gradual migrations
- **Key Features**: Composition API, Pinia, Element Plus
- **Stack**: Vue 3, TypeScript, Vite

### Backend Solutions

#### Node.js API Patterns
- **File**: `backend/nodejs-api-patterns.md`
- **Best For**: RESTful APIs, microservices
- **Key Features**: Clean architecture, JWT auth, Prisma
- **Stack**: Express/Fastify, TypeScript, PostgreSQL

#### Python FastAPI
- **File**: `backend/python-fastapi-defaults.md`
- **Best For**: High-performance APIs, ML endpoints
- **Key Features**: Async support, automatic docs, type safety
- **Stack**: FastAPI, SQLAlchemy, Pydantic

### Database Patterns

#### PostgreSQL Patterns
- **File**: `database/postgres-patterns.md`
- **Best For**: Relational data, complex queries, ACID requirements
- **Key Features**: Audit trails, RBAC, full-text search
- **Includes**: Schema patterns, indexing strategies, migrations

#### MongoDB Schema Design
- **File**: `database/mongodb-schema-design.md`
- **Best For**: Document data, flexible schemas, real-time
- **Key Features**: Embedding patterns, aggregations, change streams
- **Includes**: Collection design, indexing, sharding patterns

### Infrastructure Solutions

#### Docker Compose Patterns
- **File**: `infrastructure/docker-compose-patterns.md`
- **Best For**: Local development, multi-service apps
- **Key Features**: Full-stack setup, monitoring, development overrides
- **Includes**: Production configs, microservices patterns

#### Deployment Patterns
- **File**: `infrastructure/deployment-patterns.md`
- **Best For**: Production deployments, CI/CD
- **Key Features**: Kubernetes, AWS ECS, GitHub Actions
- **Includes**: Blue-green, canary deployments, monitoring

## How to Use These Suggestions

### During Technical Discovery

1. **Pattern Recognition**: When analyzing a PRD, identify which technical areas are needed
2. **Suggestion Matching**: Find relevant templates from this catalog
3. **Present Options**: Show 2-3 relevant options to the user with brief descriptions
4. **Apply Selection**: Use the chosen template as the baseline implementation

### Example Discovery Flow

```
Claude: "I see your PRD mentions building a web application with user authentication. 
Here are some architectural suggestions:

Frontend:
a) Next.js with minimal dark theme - Great for modern SaaS
b) React SPA - Perfect for dashboards and internal tools

Backend:
a) Node.js with Express - JavaScript throughout
b) Python FastAPI - High performance with great docs

Database:
a) PostgreSQL - Best for structured data with relationships
b) MongoDB - Flexible for evolving schemas

Which combination would you prefer?"
```

### Customization Process

1. **Start with Template**: Use the suggestion as foundation
2. **Gather Requirements**: Ask specific questions based on PRD
3. **Adapt Patterns**: Modify the template to fit exact needs
4. **Document Changes**: Record customizations in technical design docs

## Adding New Suggestions

When adding new suggestion templates:

1. **Follow Structure**: Use existing templates as examples
2. **Include Complete Code**: Provide working examples
3. **Document Trade-offs**: Explain when to use and when not to
4. **Add to Catalog**: Update this README with the new entry

## Integration with Project Preferences

Projects can specify default preferences in `.project/context/preferences.json`:

```json
{
  "technical_defaults": {
    "frontend": "nextjs-minimal-dark",
    "backend": "nodejs-api-patterns",
    "database": "postgres-patterns",
    "infrastructure": "docker-compose-patterns"
  }
}
```

This allows Claude Code to automatically suggest the preferred patterns for a project.