# Product Requirements Documentation (PRD) Guide

## Overview

This directory contains all Product Requirements Documents (PRDs) for the Nexus MCP Research Mongo Database Server project. Following modern best practices (2024-2025), our PRDs are living documents that evolve with the product development lifecycle.

## Directory Structure

```
docs/prd/
├── README.md              # This file
├── features/              # Feature-specific PRDs
│   ├── core/             # Core functionality PRDs
│   ├── integrations/     # Integration-related PRDs
│   └── infrastructure/   # Infrastructure & system PRDs
├── templates/            # Reusable PRD templates
├── prompts/              # AI prompt templates for PRD generation
└── assets/               # Diagrams, mockups, and visual assets
```

## PRD Philosophy

Based on current best practices from leading product teams (Intercom, Airbnb, Asana), our PRDs follow these principles:

1. **Problem-Solution Separation**: Clearly distinguish between problem exploration and solution development
2. **Living Documents**: PRDs evolve alongside development rather than being rigid specifications
3. **Outcome-Focused**: Define what we're building and why, not how
4. **Collaborative**: Created with input from all stakeholders

## Working with PRDs

### Creating a New PRD

1. **Use AI Assistance**: Reference the prompt templates in `/prompts` when asking Claude to help create a PRD
2. **Start with the Template**: Use `templates/prd-template.md` as your starting point
3. **Focus on the Problem**: Begin with clear problem definition before jumping to solutions
4. **Include Success Metrics**: Define measurable outcomes

### Referencing PRDs in Development

When working with Claude on implementation:
```
@claude Please review the PRD at docs/prd/features/core/[feature-name].md before implementing
```

### PRD Lifecycle

1. **Draft**: Initial problem exploration and high-level solution
2. **Review**: Stakeholder feedback and refinement
3. **Approved**: Ready for implementation
4. **In Development**: Being actively built
5. **Completed**: Feature shipped, document archived

## Quick Links

- [PRD Template](templates/prd-template.md)
- [AI Prompt Templates](prompts/README.md)
- [Core Features](features/core/README.md)

## Best Practices

- Keep PRDs concise and scannable
- Use visuals (diagrams, mockups) in the `/assets` folder
- Update PRDs as you learn during development
- Link to related technical documentation
- Version significant changes

## Integration with CLAUDE.md

The main `CLAUDE.md` file references this PRD structure. When starting work on a feature, Claude will:
1. Check for existing PRDs
2. Reference success metrics and requirements
3. Align implementation with documented goals