# Technical Documentation Prompts

This directory contains prompts for progressive technical discovery and documentation.

## Core Philosophy

Technical decisions emerge from implementing PRDs, not from upfront planning. These prompts help identify when and how to document technical choices.

## Available Prompts

### 1. Technical Design Discovery
**File**: `technical-design-discovery.md`

Framework for identifying technical decisions needed when implementing PRD features. This is your starting point for all technical work.

**Usage**: When implementing any PRD feature, use this framework to identify technical questions that need answers.

### 2. Document Technical Decisions
**File**: `document-technical-decisions.md`

Guidance on when and how to document technical decisions made during implementation.

**Usage**: After making non-obvious technical choices, use this to determine if and how to document them.

### 3. When to Create Technical Docs
**File**: `when-to-create-technical-docs.md`

Helps determine when technical documentation adds value vs when code is sufficient.

**Usage**: Before creating any technical documentation, consult this to ensure you're not over-documenting.

## Workflow

1. **Start with PRD**: Business requirements drive everything
2. **Discover technical needs**: Use `technical-design-discovery.md` to identify decisions
3. **Ask clarifying questions**: Get user input on technical choices
4. **Document if valuable**: Use `document-technical-decisions.md` to capture important decisions
5. **Keep it minimal**: Use `when-to-create-technical-docs.md` to avoid over-documentation

## Key Principles

- Code is the primary documentation
- Only document the "why" when it's not obvious from code
- Technical decisions are progressive - start simple, refine as needed
- Documentation should live close to the code it describes

## Output Location

Technical designs and decisions go in: `/docs/technical/design/`

Use the template at: `.framework/runtime/03-technical/templates/technical-design-template.md`