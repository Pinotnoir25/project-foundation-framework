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

## Development Tool Preferences

### MCP Tools to Use
When these MCP tools are available, ALWAYS use them instead of alternatives:
- **Docker MCP**: Use for ALL Docker operations (don't use Bash for docker commands)
- **Playwright MCP**: Use for ALL E2E testing (don't write raw Playwright code)
- **Sequential Thinking MCP**: Use for complex problem breakdown and architecture planning
- **GitHub MCP**: Use for ALL git operations (don't use Bash for git commands)

### Tool Priority
If an MCP tool exists for the task, use it. Only fall back to Bash/direct code when no MCP tool is available.

### Examples
- ❌ DON'T: `bash docker build -t myapp .`
- ✅ DO: Use Docker MCP to build image

- ❌ DON'T: `bash git commit -m "message"`
- ✅ DO: Use GitHub MCP for commits

- ❌ DON'T: Write Playwright test code manually
- ✅ DO: Use Playwright MCP to generate and run tests

## Docker & Frontend Caching Prevention

### IMPORTANT: Always Prevent Caching Issues
When working with frontend applications in Docker, ALWAYS follow these steps to ensure changes are visible:

1. **Docker Build Commands**
   - Always use `--no-cache` flag: `docker build --no-cache -t appname .`
   - Include build args for cache busting: `--build-arg CACHEBUST=$(date +%s)`

2. **Docker Compose**
   - Always rebuild: `docker-compose build --no-cache`
   - Force recreate containers: `docker-compose up --force-recreate --build`
   - Or use: `docker-compose down && docker-compose up --build`

3. **Frontend-Specific**
   - Clear build folders before building: `rm -rf dist/ build/ .next/ .nuxt/`
   - Set environment variables: `GENERATE_SOURCEMAP=false` (for production)
   - For Next.js: Clear `.next/cache/`
   - For Vite/React: Clear `node_modules/.vite/`

4. **Browser Cache**
   - Add cache-busting to assets: `app.js?v=${timestamp}`
   - Set proper headers in Dockerfile:
     ```dockerfile
     # Add to nginx.conf or equivalent
     location /static {
       add_header Cache-Control "no-cache, no-store, must-revalidate";
     }
     ```

5. **Development Workflow**
   - Before testing changes: 
     1. Stop all containers: `docker-compose down`
     2. Remove volumes: `docker volume prune -f`
     3. Rebuild with no cache: `docker-compose build --no-cache`
     4. Start fresh: `docker-compose up`

### Quick Command for Fresh Rebuild
Always use this command when frontend changes aren't showing:
```bash
docker-compose down -v && docker-compose build --no-cache && docker-compose up
```

---

*This file is automatically customized based on your project configuration. Update `.project/context/project.json` to modify project details.*