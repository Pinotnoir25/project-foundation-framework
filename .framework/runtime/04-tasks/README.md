# Task Management - Progressive Approach

This directory contains templates and prompts for progressive task management. Our philosophy: **start small, build as needed**.

## Core Philosophy

Traditional task management creates comprehensive plans upfront. We do the opposite:

1. **Start with 3-5 essential tasks** - Just enough to begin
2. **Add tasks as you discover them** - Let implementation inform planning  
3. **Keep documentation minimal** - Focus on doing, not documenting
4. **Track progress simply** - Checkboxes and brief notes

Tasks emerge from work, not precede it.

## Directory Structure

### `/templates/`
- `task-minimal.md` - Simple 5-10 line task list (start here)
- `task-list-minimal.md` - Basic checklist format
- `task-breakdown-comprehensive.md` - Full template (rarely needed)

### `/prompts/`
- `create-initial-tasks.md` - Extract 3-5 starter tasks from PRD
- `add-tasks-as-needed.md` - Add tasks discovered during work
- `track-progress.md` - Simple progress updates
- `prioritize-tasks.md` - Decide what to do next
- `prd-to-tasks.md` - Convert PRD to initial tasks
- `estimate-tasks.md` - Size tasks when needed

## Quick Start

### 1. Starting a Feature
```bash
# Use minimal template
cp .framework/runtime/04-tasks/templates/task-minimal.md docs/tasks/features/core/my-feature-tasks.md

# Or extract from PRD
@claude Create initial tasks from docs/prd/features/core/my-feature-prd.md
```

### 2. During Development
```bash
# Discovered something new?
@claude I found we need X. Add to my task list.

# Update progress
@claude Mark task 1 complete, starting task 2
```

### 3. What's Next?
```bash
# Need help prioritizing?
@claude What should I work on next?
```

## When to Use What

### Use Minimal Template When:
- Starting any new feature
- Working independently
- Clear, straightforward requirements
- Want to start coding quickly

### Use Comprehensive Template When:
- Multiple team coordination needed
- Complex dependencies to track
- Regulatory/compliance requirements
- Explicitly requested by stakeholders

## Progressive Task Patterns

### Pattern 1: Feature Development
1. Start: "Set up basic [feature] structure"
2. Discover: "Need database schema"  
3. Add: "Create [feature] database tables"
4. Continue building...

### Pattern 2: Bug Investigation
1. Start: "Reproduce the issue"
2. Discover: "Root cause in X component"
3. Add: "Fix X component logic"
4. Add: "Add test to prevent regression"

### Pattern 3: Integration Work
1. Start: "Test API connection"
2. Discover: "Need authentication"
3. Add: "Implement auth flow"
4. Discover: "Need error handling"
5. Add: "Add retry logic"

## Anti-Patterns to Avoid

❌ **Don't**: Create 50+ tasks before starting  
✅ **Do**: Start with 3-5, add as you go

❌ **Don't**: Estimate everything upfront  
✅ **Do**: Estimate when needed for planning

❌ **Don't**: Create detailed subtasks immediately  
✅ **Do**: Break down tasks when you reach them

❌ **Don't**: Track every micro-step  
✅ **Do**: Track meaningful progress

## Integration with Development

Tasks should support development, not drive it:

```markdown
# Good Task Flow
1. [x] Create user model
2. [x] Add authentication endpoint
3. [ ] Implement login UI
   - Discovered: need password reset
4. [ ] Add password reset flow
```

```markdown
# Avoid This
1. Research authentication methods (2 days)
2. Document authentication approach (1 day)  
3. Review documentation (0.5 days)
4. Set up development environment (1 day)
... 20 more tasks before any code
```

## Remember

- Tasks are a tool, not the goal
- Working software > perfect plans
- Discovery is part of development
- Simple tracking > complex systems
- Start now, refine later

The best task list is one that helps you make progress, not one that looks impressive in a spreadsheet.