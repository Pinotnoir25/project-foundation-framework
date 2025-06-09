# Context Management Guide

This guide explains how to maintain persistent context across Claude conversations, ensuring continuity and consistency in your project development.

## Overview

The context management system helps Claude understand your project's current state, decisions, and terminology across conversations. This prevents the need to re-explain your project each time you start a new conversation.

## Directory Structure

When you initialize a project, the following structure is created:

```
.project/
├── context/           # Current project state and configuration
│   ├── project.json   # Core project information
│   ├── current-state.md # Current development status
│   ├── decisions.md   # Architectural and design decisions
│   └── glossary.md    # Project-specific terminology
├── conversations/     # Saved conversation contexts
└── metadata/          # Project metadata and tracking
```

## Context Files Explained

### project.json
Core project configuration that populates CLAUDE.md placeholders:
- Project name and description
- Technical stack (languages, frameworks, databases)
- Key commands (setup, build, test, run)
- Integration points
- Current status
- Technical preferences (optional):
  - Default patterns for frontend/backend/database/infrastructure
  - Custom patterns for common features
  - Project conventions and standards

### current-state.md
Living document tracking:
- What has been implemented
- Current blockers or issues
- Recent changes and their impact
- Next planned steps
- Active feature development

### decisions.md
Architectural Decision Records (ADRs):
- Technology choices and rationale
- Design patterns adopted
- Trade-offs considered
- Constraints that influenced decisions
- Security considerations

### glossary.md
Domain-specific terminology:
- Business terms and definitions
- Technical acronyms
- Project-specific concepts
- API terminology
- User roles and permissions

## Conversation Management

### Saving Conversations
Conversations are saved with timestamps:
- Format: `conversations/YYYY-MM-DD-HH-MM-summary.md`
- Includes key decisions, changes, and next steps
- Helps maintain continuity between sessions

### Loading Context
When starting a new conversation:
1. Claude checks for existing `.project/context/project.json`
2. Loads all context files if they exist
3. Reviews recent conversations for continuity
4. Proceeds with current state awareness

## Best Practices

### 1. Update Regularly
- Update `current-state.md` after significant changes
- Add new decisions to `decisions.md` as they're made
- Keep `glossary.md` current with new terms

### 2. Be Specific
- Document WHY decisions were made, not just what
- Include specific version numbers and dependencies
- Note any temporary workarounds or technical debt

### 3. Review Periodically
- Check saved conversations for patterns
- Update project.json when stack changes
- Archive old conversations quarterly

### 4. Version Control
- Commit context changes with your code
- Use meaningful commit messages for context updates
- Consider `.gitignore` for sensitive information

## Quick Commands

Claude responds to these context management commands:

- `@claude save current context` - Persist current conversation
- `@claude load project context` - Load all context files
- `@claude update project state` - Update current-state.md
- `@claude show project state` - Display current status
- `@claude add decision [description]` - Document new decision
- `@claude add term [term]: [definition]` - Update glossary

## Integration with Framework

The context management system integrates with:
- **PRD System**: Links requirements to decisions
- **Task Management**: Tracks implementation state
- **Development Workflow**: Updates automatically

## Troubleshooting

### Missing Context Files
If context files are missing:
1. Run initialization wizard: `@claude run project initialization`
2. Or manually create from templates in `.framework/templates/context/`

### Stale Context
If context seems outdated:
1. Review recent git commits
2. Check conversation history
3. Update current-state.md
4. Verify project.json accuracy

### Large Conversation History
If conversations folder grows too large:
1. Archive conversations older than 3 months
2. Create quarterly summary documents
3. Keep only recent 10-15 conversations

## Technical Preferences

### Setting Default Patterns
Configure your preferred technical patterns in `project.json`:

```json
{
  "technicalPreferences": {
    "defaults": {
      "frontend": "nextjs-minimal-dark",
      "backend": "nodejs-api-patterns",
      "database": "postgres-patterns",
      "infrastructure": "docker-compose-patterns"
    }
  }
}
```

This allows Claude to automatically suggest your preferred patterns during technical discovery.

### Custom Pattern Preferences
Define project-specific patterns:

```json
{
  "technicalPreferences": {
    "customPatterns": {
      "authentication": "jwt-with-refresh-tokens",
      "apiStyle": "restful-clean",
      "errorHandling": "centralized-middleware"
    }
  }
}
```

### Using Preferences
When technical preferences are set:
1. Claude will default to your preferred suggestions
2. Technical discovery starts with your preferences
3. Patterns are consistently applied across features
4. Team members see the same defaults

## Advanced Usage

### Custom Context Files
You can add custom context files:
- `.project/context/api-contracts.md`
- `.project/context/deployment-notes.md`
- `.project/context/performance-metrics.md`

### Context Templates
Create reusable templates for:
- Feature development contexts
- Bug investigation contexts
- Refactoring contexts
- Performance optimization contexts

### Automated Updates
Consider scripts to:
- Update current-state.md from git commits
- Generate decision records from PR descriptions
- Sync glossary with code comments

---

*Context Management Guide - Version 1.0*