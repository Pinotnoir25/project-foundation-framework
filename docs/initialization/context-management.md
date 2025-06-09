# Context Management Guide

This guide helps Claude maintain context across conversations and track project progress effectively.

---

## Save Context Prompt

Use this when you want to save the current conversation context:

```
@claude Please save our current conversation context. Include:
- Key decisions made
- Technical choices
- Implementation details
- Open questions
- Next steps

Save this to the project context with today's date.
```

## Load Context Prompt

Use this to restore previous context:

```
@claude Please load the project context from [date] or the most recent context. Summarize:
- Project status
- Recent decisions
- Current tasks
- Open items
```

## Update Project State Prompt

Use this to update the overall project state:

```
@claude Please update the project state with:

**Completed Today**:
- [List what was accomplished]

**Current Status**:
- [Describe current state]

**Blockers**:
- [Any blocking issues]

**Next Steps**:
- [What needs to be done next]

**Key Decisions**:
- [Important choices made]
```

## Context Tracking Template

When Claude saves context, it will use this structure:

```markdown
# Conversation Context - [DATE TIME]

## Summary
[Brief overview of the session]

## Work Completed
- [Task/Feature 1]
- [Task/Feature 2]

## Technical Decisions
- **[Topic]**: [Decision and rationale]
- **[Topic]**: [Decision and rationale]

## Code Changes
- `[file]`: [What was changed and why]
- `[file]`: [What was changed and why]

## Configuration Updates
- [Any config changes made]

## Open Questions
- [ ] [Question needing resolution]
- [ ] [Another question]

## Next Session Focus
- [Priority 1]
- [Priority 2]

## Important Notes
[Any critical information for next session]
```

## Best Practices

1. **Save Regularly**: Save context after significant decisions or implementations
2. **Be Specific**: Include specific file paths, function names, and decisions
3. **Track Rationale**: Document not just what was decided, but why
4. **Update Status**: Keep project state current for team visibility

## Automated Context Commands

Claude can help with these context operations:

- `@claude show current project state` - Display project.json contents
- `@claude list recent conversations` - Show saved context files
- `@claude summarize last session` - Recap previous conversation
- `@claude track decision: [decision]` - Add to decision log
- `@claude update glossary: [term]` - Add domain terminology

## Context File Locations

- **Project State**: `.project/context/project.json`
- **Current Status**: `.project/context/current-state.md`
- **Decisions**: `.project/context/decisions.md`
- **Glossary**: `.project/context/glossary.md`
- **Conversations**: `.project/conversations/YYYY-MM-DD-*.md`

---

*Context management ensures continuity across sessions and helps maintain project momentum.*