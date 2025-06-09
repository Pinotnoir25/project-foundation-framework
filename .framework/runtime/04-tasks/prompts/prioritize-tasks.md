# Prioritize Tasks Prompt

Use this prompt when you need to decide what to work on next:

---

I need help prioritizing tasks for [FEATURE_NAME]. Current task list is at `[TASK_FILE_PATH]`.

## Current Context
- What's done: [Completed items]
- What's blocking: [Any blockers]
- Time available: [How much time we have]
- Project goals: [What we're optimizing for]

## Prioritization Criteria

Help me order tasks based on:
1. **Immediate Blockers**: What unblocks the most other work?
2. **User Value**: What delivers visible progress?
3. **Technical Risk**: What validates our approach?
4. **Quick Wins**: What can we complete quickly?

## Consider
- Dependencies between tasks
- Current team expertise
- External constraints
- What we'll learn from each task

## Output

Provide a simple priority order:
```markdown
## Priority Order
1. [Task X] - Because it unblocks Y and Z
2. [Task A] - Quick win, builds momentum  
3. [Task B] - Validates technical approach
4. [Task C] - Can wait until after A and B

## Notes
- Start with [Task X] immediately
- [Task D] can be deferred - not critical path
- Consider pairing on [Task B] - it's complex
```

Keep recommendations practical and focused on what to do next, not long-term planning.