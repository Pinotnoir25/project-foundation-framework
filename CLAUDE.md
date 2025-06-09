# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Framework Rules (Always Apply)

These rules apply regardless of project state:

### MCP Tools to Use
When these MCP tools are available, ALWAYS use them instead of alternatives:
- **Docker MCP**: Use for ALL Docker operations (don't use Bash for docker commands)
- **Playwright MCP**: Use for ALL E2E testing (don't write raw Playwright code)
- **Sequential Thinking MCP**: Use for complex problem breakdown and architecture planning
- **GitHub MCP**: Use for ALL git operations (don't use Bash for git commands)

### Framework File Protection
Check the working directory name to determine the mode:
- If directory is named `project-foundation-framework`: **Framework Development Mode** - OK to modify .framework/ files
- Any other directory name: **Project Mode** - NEVER modify files in .framework/ directory

### Docker & Frontend Caching Prevention
When working with frontend applications in Docker, ALWAYS:
- Use `--no-cache` flag: `docker build --no-cache -t appname .`
- Force recreate: `docker-compose down -v && docker-compose build --no-cache && docker-compose up`
- Clear build folders: `rm -rf dist/ build/ .next/ .nuxt/`

## Project Context (Build Progressively)

### First Time Setup
If this is a fresh framework clone and `.project/context/project.json` doesn't exist:
1. **Run initialization wizard**: 
   - Create `.project/` directory structure
   - Generate `project.json` from template
   - Populate initial context files
   - Set up development environment
2. **Capture project vision**: Document initial requirements as PRDs
3. **Plan implementation**: Break down PRDs into tasks
4. **Begin development**: Follow framework patterns and standards

### Ongoing Development
If `.project/context/project.json` exists:
1. Load project context from `.project/context/project.json`
2. Review current state in `.project/context/current-state.md`
3. Check architectural decisions in `.project/context/decisions.md`
4. Reference domain terms in `.project/context/glossary.md`
5. Review existing PRDs in `docs/prd/features/`
6. Check task progress in `docs/tasks/features/`

## Project Overview

[PROJECT_DESCRIPTION]

## Current Status

**Status**: [PROJECT_STATUS]

## Product Requirements Documentation (PRD)

This project uses a structured PRD system for feature planning and documentation. Before implementing any feature:

1. **Check for existing PRDs**: Look in `docs/prd/features/` for relevant documentation
2. **Create new PRDs**: Use templates in `.framework/templates/prd/` and prompts in `.framework/prompts/prd/`
3. **Reference PRDs during development**: Align implementation with documented requirements and success metrics

See `.framework/guides/system-guides/prd-guide.md` for the complete PRD guide.

## Task Management System

PRDs are broken down into actionable tasks using our task management system:

1. **Generate tasks from PRD**: Use prompts in `.framework/prompts/tasks/` to analyze PRDs and create task breakdowns
2. **Track task progress**: Update task status in `docs/tasks/features/` as work progresses
3. **Sprint planning**: Organize tasks into sprints based on dependencies and priorities
4. **Daily updates**: Use tracking templates in `docs/tasks/tracking/`

Quick commands:
- Generate tasks: `@claude analyze PRD at [path] and create tasks`
- Update status: `@claude mark task T1.1.1 as complete`
- Check progress: `@claude show current sprint status`

See `.framework/guides/system-guides/tasks-guide.md` for the complete task management guide.

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

1. **Initialize**: Use guides in `.framework/initialization/` for project setup
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

## Additional Framework Guidelines

### Quick Commands Reference
- Initialize project: `@claude run project initialization`
- Generate tasks from PRD: `@claude analyze PRD at [path] and create tasks`
- Update task status: `@claude mark task T1.1.1 as complete`
- Save context: `@claude save current conversation context`
- Load context: `@claude load project context`

### In Project Mode
If changes are needed to framework files, inform the user to:
1. Make changes in the upstream framework repository
2. Pull updates into their project
3. Or override locally with project-specific versions outside .framework/


---

*This file is automatically customized based on your project configuration. Update `.project/context/project.json` to modify project details.*