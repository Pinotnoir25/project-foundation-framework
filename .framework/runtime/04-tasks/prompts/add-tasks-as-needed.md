# Add Tasks As Needed Prompt

Use this prompt when you discover new tasks during development:

---

I'm working on [FEATURE_NAME] and have discovered we need additional tasks.

## Current Situation
- What I was working on: [CURRENT_TASK]
- What I discovered: [NEW_REQUIREMENT/ISSUE]
- Why it's needed: [REASON]

## New Tasks to Add

Help me add these tasks to the existing list at `[TASK_FILE_PATH]`:

1. **Immediate Need**: [Task that blocks current work]
2. **Related Work**: [Task that naturally follows]
3. **Future Consideration**: [Task we might need but not urgent]

## Integration Points
- Where does this fit in our current work?
- What dependencies exist?
- Can we defer any of these?

## Output
Update the task list maintaining its simple format, inserting new tasks where they make sense chronologically or by priority.