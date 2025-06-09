# Create Initial Tasks Prompt

Use this prompt when starting a new feature to identify the first few essential tasks:

---

I'm starting work on [FEATURE_NAME]. Help me identify 3-5 core tasks to begin with.

## What I Need

Based on the PRD at `[PRD_PATH]`, identify:
1. The most critical first step to get started
2. The next 2-4 immediate tasks that follow naturally
3. Any blockers that must be resolved first

## Focus On
- What creates immediate value or unblocks other work
- What validates our approach early
- What we can start and complete quickly

## Output Format

Create a simple task list:
```markdown
# [Feature] Initial Tasks

## Starting With
1. [ ] [First concrete action - what to build/create]
2. [ ] [Natural next step]
3. [ ] [Following step]

## Might Need Next
- [Potential task we'll discover more about]
- [Another likely task]
```

Keep it simple. We'll add more tasks as we learn. Save to: `docs/tasks/features/[category]/[feature]-tasks.md`