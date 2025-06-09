# Task Management Quick Reference

## Creating Tasks from PRD

### Step 1: Analyze PRD
```
@claude Please analyze the PRD at docs/prd/features/[category]/[feature]-prd.md 
and create tasks using docs/tasks/prompts/prd-to-tasks.md
```

### Step 2: Review Generated Tasks
Tasks will be saved to: `docs/tasks/features/[category]/[feature]-tasks.md`

### Step 3: Estimate Tasks
```
@claude Please estimate tasks in [feature]-tasks.md using 
docs/tasks/prompts/estimate-tasks.md
```

### Step 4: Plan Sprints
```
@claude Create sprint plan for [feature] using 
docs/tasks/prompts/sprint-planning.md
```

## Working with Tasks

### Daily Updates
```
# Start work
@claude Mark task T1.1.1 as "In Progress"

# Complete task
@claude Mark task T1.1.1 as "Done" (actual: 4 hours)

# Get blocked
@claude Mark task T1.1.2 as "Blocked" - waiting on [dependency]
```

### Status Checks
```
# Current sprint status
@claude Show current sprint status

# Feature progress
@claude What's the progress on [feature] tasks?

# Find next task
@claude What task should I work on next for [feature]?
```

## Task Sizing Guide

| Size | Points | Time | Example |
|------|--------|------|---------|
| XS | 1 | <2h | Config change |
| S | 2-3 | 2-4h | Simple API |
| M | 5-8 | 1-2d | Complex logic |
| L | 13 | 3-5d | Major feature |
| XL | 21+ | >1w | Break it down! |

## Task States

- 📋 **Planned**: Ready to start
- 🚧 **Blocked**: Has dependency
- 💻 **In Progress**: Being worked on
- 👀 **Review**: In code review
- ✅ **Done**: Complete & merged

## Git Integration

### Commit Format
```
[T1.1.1] Brief description

- What was implemented
- Any important notes

Task: T1.1.1 (50% complete)
Time: 2h (est: 4h)
```

### PR Description
```
## Summary
Implements T1.1.1, T1.1.2 from [feature] tasks

## Tasks Completed
- [x] T1.1.1: SSH tunnel setup (4h)
- [x] T1.1.2: Connection logic (6h)

## Testing
- Unit tests added
- Integration test covers [scenario]

Refs: docs/tasks/features/core/[feature]-tasks.md
```

## Best Practices

1. **One task at a time**: Focus on single task completion
2. **Update immediately**: Don't batch status updates
3. **Track actual time**: Help improve estimates
4. **Document blockers**: Include what you tried
5. **Small commits**: One commit per task when possible