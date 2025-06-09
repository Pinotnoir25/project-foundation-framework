# Framework Runtime

This directory contains materials that **Claude uses during execution** to generate documents, analyze requirements, and follow technical standards. These files are not typically read by humans directly.

## Directory Structure

### Theme-Based Organization
Runtime materials are organized by functional theme, with each theme containing:
- `/prompts/` - Instructions for Claude's analysis and thinking process
- `/templates/` - Document structures Claude uses to create deliverables

### Themes

#### `/prd/`
Product Requirements Documentation generation:
- **Prompts**: How to analyze requirements, identify users, define metrics
- **Templates**: PRD document structures

#### `/tasks/`
Task breakdown and sprint planning:
- **Prompts**: How to decompose PRDs into tasks, estimate effort
- **Templates**: Task list and sprint planning formats

#### `/context/`
Project context management:
- **Templates**: project.json, current-state.md, decisions.md, glossary.md

#### `/initialization/`
Project setup and configuration:
- **Prompts**: How to generate project-specific scripts
- **Templates**: Setup scripts, health checks, directory structures

#### `/technical/`
Technical standards and patterns Claude should follow:
- **Prompts**: How to design APIs, create test plans, define infrastructure
- **Templates**: Technical specification documents
- **Standards**: API patterns, security requirements, Docker practices, etc.

## How Claude Uses These Files

1. User requests an action (e.g., "Create a PRD for feature X")
2. Claude reads relevant prompt(s) to understand the analysis process
3. Claude performs the analysis following prompt instructions
4. Claude uses template(s) to structure the output
5. Claude creates the deliverable in the user's project

## Note

These files are optimized for Claude's execution and may not be easily readable by humans. For learning about these concepts, see `/documentation/guides/`.