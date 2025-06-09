# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

[PROJECT_DESCRIPTION]

## Current Status

**Status**: [PROJECT_STATUS]

When starting development:
1. Review existing PRDs in `docs/prd/features/` for feature requirements
2. Check task breakdowns in `docs/tasks/features/` for current progress
3. Load project context from `.project/context/project.json`
4. Reference the glossary in `.project/context/glossary.md` for terminology

## Product Requirements Documentation (PRD)

This project uses a structured PRD system for feature planning and documentation. Before implementing any feature:

1. **Check for existing PRDs**: Look in `docs/prd/features/` for relevant documentation
2. **Create new PRDs**: Use templates in `docs/prd/templates/` and prompts in `docs/prd/prompts/`
3. **Reference PRDs during development**: Align implementation with documented requirements and success metrics

See `docs/prd/README.md` for the complete PRD guide.

## Task Management System

PRDs are broken down into actionable tasks using our task management system:

1. **Generate tasks from PRD**: Use prompts in `docs/tasks/prompts/` to analyze PRDs and create task breakdowns
2. **Track task progress**: Update task status in `docs/tasks/features/` as work progresses
3. **Sprint planning**: Organize tasks into sprints based on dependencies and priorities
4. **Daily updates**: Use tracking templates in `docs/tasks/tracking/`

Quick commands:
- Generate tasks: `@claude analyze PRD at [path] and create tasks`
- Update status: `@claude mark task T1.1.1 as complete`
- Check progress: `@claude show current sprint status`

See `docs/tasks/README.md` for the complete task management guide.

## Context Management

Project context is maintained in the `.project/` directory:

- **Project Configuration**: `.project/context/project.json`
- **Current State**: `.project/context/current-state.md`
- **Architectural Decisions**: `.project/context/decisions.md`
- **Domain Glossary**: `.project/context/glossary.md`
- **Conversation History**: `.project/conversations/`

Quick commands:
- Save context: `@claude save current conversation context`
- Load context: `@claude load project context`
- Update state: `@claude update project state`

## Development Workflow

1. **Initialize**: Use prompts in `docs/initialization/` for project setup
2. **Requirements**: Document features as PRDs in `docs/prd/features/`
3. **Task Planning**: Break down PRDs into tasks in `docs/tasks/features/`
4. **Implementation**: Follow project standards and patterns
5. **Context Updates**: Keep `.project/context/` current with decisions

## Project-Specific Guidelines

[PROJECT_SPECIFIC_GUIDELINES]

## Technical Stack

- **Primary Language**: [PRIMARY_LANGUAGE]
- **Framework**: [FRAMEWORK]
- **Database**: [DATABASE]
- **Infrastructure**: [INFRASTRUCTURE]

## Development Commands

```bash
# [SETUP_COMMANDS]
# [BUILD_COMMANDS]
# [TEST_COMMANDS]
# [RUN_COMMANDS]
```

## Key Integration Points

[INTEGRATION_POINTS]

## Important Notes

[IMPORTANT_NOTES]

---

*This file is automatically customized based on your project configuration. Update `.project/context/project.json` to modify project details.*