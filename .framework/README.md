# Framework Directory

This directory contains all framework-level documentation, templates, and prompts that define the development methodology and standards for this project.

## Directory Structure

### guides/
Framework documentation and guides:
- **FRAMEWORK_GUIDE.md** - Main framework overview and principles
- **INITIALIZE.md** - Project initialization guide
- **FRAMEWORK_CUSTOMIZATION.md** - How to customize the framework for your needs
- **system-guides/** - Core system documentation:
  - `prd-guide.md` - Product Requirements Documentation system
  - `tasks-guide.md` - Task management system
  - `technical-guide.md` - Technical documentation system
  - Quick reference guides for each system

### templates/
All reusable templates organized by type:
- **prd/** - Product Requirements Document templates
- **tasks/** - Task breakdown and tracking templates
- **technical/** - Technical documentation templates (TAD, API, infrastructure)
- **scripts/** - Script templates for common operations
- **initialization/** - Project initialization templates

### prompts/
AI prompts for generating content:
- **prd/** - Prompts for creating PRDs from user stories
- **tasks/** - Prompts for breaking down PRDs into tasks
- **technical/** - Prompts for generating technical specs
- **initialization/** - Prompts for project setup

### initialization/
Project initialization resources:
- Architecture planning guides
- Domain mapping templates
- Context management strategies
- Project setup checklists

## Usage

1. **Starting a new project**: Begin with `guides/INITIALIZE.md`
2. **Creating documentation**: Use templates from `templates/`
3. **AI-assisted generation**: Use prompts from `prompts/`
4. **Customization**: Follow `guides/FRAMEWORK_CUSTOMIZATION.md`

## Key Principles

1. **Separation of Concerns**: Framework files are separate from project files
2. **Reusability**: Templates and prompts can be used across features
3. **Consistency**: All projects follow the same documentation structure
4. **AI-First**: Prompts enable efficient content generation
5. **Flexibility**: Framework can be customized per project needs

## Quick Commands

Generate PRD:
```
@claude use prompt at .framework/prompts/prd/new-feature-prd.md
```

Create tasks from PRD:
```
@claude use prompt at .framework/prompts/tasks/prd-to-tasks.md
```

Generate technical spec:
```
@claude use prompt at .framework/prompts/technical/prd-to-technical-spec.md
```