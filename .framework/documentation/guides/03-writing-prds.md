# Product Requirements Documentation (PRD) Guide

## Overview

Product Requirements Documents (PRDs) are living documents that capture what you're building and why. This guide explains how to create, maintain, and use PRDs effectively within the Project Foundation Framework.

## What is a PRD?

A PRD defines:
- **The Problem**: What user need or business challenge you're addressing
- **The Solution**: High-level approach to solving the problem
- **Success Metrics**: How you'll measure if the solution works
- **Requirements**: Key features and constraints
- **User Stories**: How different users will interact with the solution

## PRD Philosophy

Based on current best practices from leading product teams, effective PRDs follow these principles:

1. **Problem-First Thinking**: Deeply understand the problem before defining solutions
2. **Living Documents**: PRDs evolve throughout development as you learn
3. **Outcome-Focused**: Define success metrics, not implementation details
4. **User-Centric**: Center on user needs and experiences
5. **Collaborative**: Incorporate perspectives from all stakeholders

## Creating PRDs with Claude

### Starting a New PRD

When you need a new PRD, Claude can help:
```
@claude Create a PRD for [feature description]
```

Claude will:
1. Ask clarifying questions about the problem
2. Use PRD templates from `.framework/runtime/prd/templates/`
3. Apply analysis prompts from `.framework/runtime/prd/prompts/`
4. Generate a structured PRD in `docs/prd/features/`

### PRD Categories

Organize PRDs by their primary focus:
- **Core**: Essential product functionality
- **Infrastructure**: System architecture, performance, reliability
- **Integrations**: External services, APIs, third-party tools

### Key Sections of a PRD

1. **Problem Statement**: Clear description of the user need or business challenge
2. **User Personas**: Who will use this feature and their contexts
3. **Success Metrics**: Measurable outcomes that indicate success
4. **Requirements**: 
   - Functional: What the feature must do
   - Non-functional: Performance, security, usability constraints
5. **User Stories**: Specific scenarios showing how users achieve their goals
6. **Out of Scope**: What this PRD explicitly does not cover
7. **Open Questions**: Areas needing further research or decisions

## Working with PRDs

### During Development

Reference PRDs when implementing features:
```
@claude Review the PRD at docs/prd/features/core/[feature-name].md and implement the user authentication flow
```

### Updating PRDs

As you learn during development:
- Update requirements based on technical constraints
- Refine success metrics based on feasibility
- Document decisions in the PRD
- Add lessons learned

### PRD Lifecycle

1. **Draft**: Initial problem exploration and solution ideation
2. **Review**: Gathering stakeholder feedback
3. **Approved**: Ready for implementation
4. **In Development**: Being actively built (update as needed)
5. **Completed**: Feature shipped, PRD becomes historical reference

## Best Practices

### Do:
- Start with user problems, not solutions
- Include concrete success metrics
- Use visuals (diagrams, mockups) in `docs/prd/assets/`
- Keep language clear and concise
- Update PRDs as understanding evolves
- Link to related technical documentation

### Don't:
- Include implementation details (that's for technical specs)
- Make PRDs overly long or complex
- Treat PRDs as unchangeable contracts
- Skip the problem definition
- Work in isolation

## Integration with Other Systems

### From PRD to Tasks
Once a PRD is approved:
```
@claude Analyze the PRD at [path] and create a task breakdown
```

This generates tasks in `docs/tasks/features/` based on PRD requirements.

### From PRD to Technical Specs
For complex features:
```
@claude Create a technical design from the PRD at [path]
```

This creates technical documentation while keeping the PRD focused on the "what" and "why".

## Tips for Success

1. **Iterate Quickly**: Start with a draft and refine based on feedback
2. **Stay User-Focused**: Always tie features back to user needs
3. **Measure Everything**: If you can't measure success, reconsider the feature
4. **Collaborate Early**: Get input from engineering, design, and stakeholders
5. **Document Decisions**: Future you will thank current you

## Common Pitfalls

- **Solution Bias**: Jumping to how before understanding why
- **Metric Absence**: No clear way to measure success
- **Scope Creep**: PRD grows to include everything
- **Over-Specification**: Including too much implementation detail
- **Under-Specification**: Missing critical requirements

## Conclusion

PRDs are communication tools that align teams around what to build and why. They're living documents that evolve with your understanding. Use them to maintain clarity and purpose throughout the development process.

For PRD templates and examples, see `.framework/runtime/prd/templates/` and `.framework/documentation/examples/prd/`.