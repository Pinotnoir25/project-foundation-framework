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

### Framework Runtime Materials
The `.framework/runtime/` directory contains generation guides:

- **PRD Creation**: `/01-prd/` - Templates and prompts for requirements
- **Task Management**: `/02-tasks/` - Breaking down PRDs into work
- **Technical Design**: `/03-technical/` - Discovery framework for technical choices

These materials guide your thinking process:
1. Start with PRD templates to capture business needs
2. Use technical discovery to identify design decisions
3. Document designs with patterns in `/docs/technical/design/`
4. Generate tasks that reference both PRDs and technical designs

The framework ensures consistency through progressive refinement, not rigid templates.

### Bash Command Rules
When executing bash commands:
- NEVER add comments within the command string (e.g., DON'T: "# comment\ncommand")
- Use the description parameter to explain what the command does
- Keep commands clean and comment-free to avoid permission issues

### Docker & Frontend Caching Prevention
When working with frontend applications in Docker, ALWAYS:
- Use `--no-cache` flag: `docker build --no-cache -t appname .`
- Force recreate: `docker-compose down -v && docker-compose build --no-cache && docker-compose up`
- Clear build folders: `rm -rf dist/ build/ .next/ .nuxt/`

## Project Context (Build Progressively)

### First Time Setup
If this is a fresh framework clone and `.project/context/project.json` doesn't exist:
1. **Start minimal**: 
   - Create only `project.json` with basic info (name, description, language)
   - Other context files created only when needed
2. **Capture project vision**: Document initial requirements as PRDs
3. **Plan implementation**: Break down PRDs into tasks
4. **Begin development**: Follow framework patterns and standards

Context files are created progressively:
- `current-state.md` - When first feature is complete
- `decisions.md` - When first significant choice is made  
- `glossary.md` - When domain terms need definition

### Ongoing Development
If `.project/context/project.json` exists:
1. Load project context from `.project/context/project.json`
2. If they exist, review:
   - Current state in `.project/context/current-state.md`
   - Architectural decisions in `.project/context/decisions.md`
   - Domain terms in `.project/context/glossary.md`
3. Review existing PRDs in `docs/prd/features/`
4. Check task progress in `docs/tasks/features/`
5. Use runtime materials from `.framework/runtime/` for generation

Note: Context files are created progressively as needed, not all at once

## Project Overview

[PROJECT_DESCRIPTION]

## Current Status

**Status**: [PROJECT_STATUS]

## Product Requirements Documentation (PRD)

This project uses a structured PRD system for feature planning and documentation. Before implementing any feature:

1. **Check for existing PRDs**: Look in `docs/prd/features/` for relevant documentation
2. **Create new PRDs**: Use templates in `.framework/runtime/prd/templates/` and prompts in `.framework/runtime/prd/prompts/`
3. **Reference PRDs during development**: Align implementation with documented requirements and success metrics

See `.framework/documentation/guides/system-guides/prd-guide.md` for the complete PRD guide.

## Task Management System

PRDs are broken down into actionable tasks using our task management system:

1. **Generate tasks from PRD**: Use prompts in `.framework/runtime/tasks/prompts/` to analyze PRDs and create task breakdowns
2. **Track task progress**: Update task status in `docs/tasks/features/` as work progresses
3. **Sprint planning**: Organize tasks into sprints based on dependencies and priorities
4. **Daily updates**: Use tracking templates in `docs/tasks/tracking/`

Quick commands:
- Generate tasks: `@claude analyze PRD at [path] and create tasks`
- Update status: `@claude mark task T1.1.1 as complete`
- Check progress: `@claude show current sprint status`

See `.framework/documentation/guides/system-guides/tasks-guide.md` for the complete task management guide.

## Requirement Traceability

When implementing features from PRDs, add a simple comment linking the code to its requirements:

```javascript
// Implements user authentication from docs/prd/features/core/authentication.md
function login(req, res) { ... }
```

**When to add references:** APIs, core business logic, data models
**When to skip:** Utilities, config files, obvious boilerplate

That's it. Keep it simple.

## Technical Design Process

When implementing PRD features, identify and document technical designs:

1. **Discovery**: Use the framework in `.framework/runtime/03-technical/prompts/technical-design-discovery.md`
2. **Clarification**: Ask users about technical choices when gaps are identified
3. **Documentation**: Record designs and patterns in `/docs/technical/design/`
4. **Reference**: Use documented patterns for consistent implementation

### Workflow Example
PRD: "Users can upload profile pictures"
→ Technical questions emerge: Storage method? Size limits? Format validation?
→ Ask user for decisions
→ Document in `/docs/technical/design/file-uploads.md`
→ Include reusable patterns in the same document
→ Create tasks referencing these designs

Technical designs are progressive - start simple, refine as you learn more.

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

## Project Structure

- `/app/` - All application code goes here
  - For single component: Place code directly in `/app/`
  - For multiple components: Create subdirectories like `/app/frontend/`, `/app/backend/`, `/app/api/`
  - Each component should have its own Dockerfile
- `/docs/` - Project documentation (PRDs, tasks, API docs)
- `/.project/` - Project context and state files
- `docker-compose.yml` - Container orchestration (at root level)
- `.env` files - Environment configuration (at root level)

## Development Workflow

1. **Initialize**: Use guides in `.framework/documentation/guides/` for project setup
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