# PRD to Initial Tasks Prompt

Use this prompt to analyze a PRD and identify the first essential tasks to begin implementation:

---

I need you to analyze a Product Requirements Document (PRD) and identify the initial tasks to start implementation. Please read the PRD at `[PRD_PATH]` and create a starter task list.

## Analysis Focus

### 1. Core Requirements
From the PRD, identify:
- The most critical functionality to build first
- Any prerequisites or blockers
- The simplest path to initial value

### 2. Starting Points
Look for:
- What creates the foundation for other work
- What validates our technical approach
- What delivers quick, visible progress

### 3. Initial Task Selection
Create 3-5 tasks that:
- Can be started immediately
- Build naturally on each other
- Create a working foundation
- Are concrete and actionable

## Output Format

Keep it simple - use the minimal template:

```markdown
# [Feature Name] Tasks

**Started**: [Date]  
**Status**: Active

## Current Focus
[What we're building first and why]

## Tasks
- [ ] Task 1 - [Specific first step]
- [ ] Task 2 - [Natural next step]
- [ ] Task 3 - [Following action]
- [ ] Task 4 - [If needed]
- [ ] Task 5 - [If needed]

## Might Need Next
- [Task we'll likely discover]
- [Another probable task]

## Notes
- Key decision: [Any important choices made]
- Assumption: [What we're assuming]
```

## Remember
- Start small - we'll add more tasks as we learn
- Focus on what unblocks other work
- Don't try to plan everything upfront
- Tasks should be concrete actions, not research

Save the result to: `docs/tasks/features/[category]/[feature-name]-tasks.md`