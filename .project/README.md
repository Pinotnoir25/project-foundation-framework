# Project Context Directory

This directory maintains persistent context across Claude conversations, ensuring continuity and consistency in your project development.

## Directory Structure

```
.project/
├── context/           # Current project state and configuration
├── conversations/     # Saved conversation contexts
├── templates/         # Reusable context templates
└── metadata/          # Project metadata and tracking
```

## Usage

### Context Files

- `context/project.json` - Core project information
- `context/current-state.md` - Current development status
- `context/decisions.md` - Architectural and design decisions
- `context/glossary.md` - Project-specific terminology

### Conversation Tracking

Conversations are automatically saved with timestamps:
- `conversations/YYYY-MM-DD-HH-MM-summary.md`
- Includes key decisions, changes, and next steps

### Templates

Reusable templates for common contexts:
- `templates/project-init.json`
- `templates/feature-context.json`
- `templates/sprint-context.json`

## Best Practices

1. **Update Regularly**: Keep context files current
2. **Review Periodically**: Check saved conversations for insights
3. **Version Control**: Commit important context changes
4. **Clean Periodically**: Archive old conversations

## Quick Commands

- `@claude save current context` - Persist current conversation
- `@claude load context [date]` - Restore previous context
- `@claude show project state` - Display current project status