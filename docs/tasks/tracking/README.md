# Task Tracking Guide

This directory contains task progress tracking, metrics, and sprint management documentation.

## Tracking Structure

```
tracking/
├── README.md           # This file
├── current-sprint.md   # Active sprint status
├── metrics.md         # Overall project metrics
└── [feature]/         # Feature-specific tracking
    ├── progress.md    # Daily progress updates
    └── burndown.md   # Sprint burndown data
```

## Daily Tracking Process

### 1. Morning Check-in
Update `current-sprint.md` with:
- Tasks completed yesterday
- Tasks planned for today
- Any blockers identified

### 2. Task Status Updates
When working on a task:
```bash
# Starting a task
@claude Mark task T1.1.1 as "In Progress" in [feature]-tasks.md

# Completing a task
@claude Mark task T1.1.1 as "Done" and start T1.1.2

# Blocked task
@claude Mark task T1.1.3 as "Blocked" - waiting on [dependency]
```

### 3. End of Day Update
- Update task completion percentages
- Note any discoveries or deviations
- Update time tracking

## Progress Tracking Template

### Daily Update Format
```markdown
## YYYY-MM-DD

### Completed
- T1.1.1: [Task name] - [actual hours]
- T1.1.2: [Task name] - [actual hours]

### In Progress
- T1.2.1: [Task name] - [% complete] - [hours spent today]

### Blocked
- T1.3.1: [Task name] - [blocker description]

### Notes
- [Any important discoveries]
- [Deviations from plan]

### Tomorrow's Plan
- Complete T1.2.1
- Start T1.2.2
- Resolve blocker for T1.3.1
```

## Metrics to Track

### Sprint Metrics
- **Velocity**: Story points completed per sprint
- **Completion Rate**: Tasks completed vs. committed
- **Cycle Time**: Average time from start to done
- **Blockage Time**: Time tasks spend blocked

### Project Metrics
- **Burndown Rate**: Actual vs. planned progress
- **Technical Debt**: Debt tasks vs. feature tasks
- **Defect Rate**: Bugs found vs. tasks completed
- **Rework Rate**: Tasks requiring changes after review

## Status Reporting

### Weekly Status Format
```markdown
# Week [N] Status Report

## Summary
- Sprint Progress: X% complete
- On Track: Yes/No
- Major Risks: [List]

## Metrics
- Tasks Completed: X/Y
- Story Points: X/Y
- Hours Used: X/Y

## Achievements
- [Major milestone reached]
- [Key feature completed]

## Challenges
- [Issue faced]
- [How it was resolved]

## Next Week
- [Key objectives]
- [Dependencies needed]
```

## Burndown Tracking

### Sprint Burndown Data
Track daily in `[feature]/burndown.md`:

| Day | Planned Remaining | Actual Remaining | Notes |
|-----|------------------|------------------|-------|
| 1   | 50 points        | 50 points        | Sprint start |
| 2   | 45 points        | 48 points        | T1.1.1 took longer |
| 3   | 40 points        | 44 points        | Caught up on T1.1.2 |

## Automation with Claude

### Quick Commands
```bash
# Get current sprint status
@claude Show me the current sprint status

# Update multiple tasks
@claude Update tasks: T1.1.1 done (4h), T1.1.2 in progress (50%), T1.1.3 blocked

# Generate weekly report
@claude Generate weekly status report for [feature]

# Check sprint health
@claude Analyze sprint burndown and identify risks
```

## Best Practices

1. **Update Daily**: Even if just to say "no changes"
2. **Be Honest**: Track actual vs. estimated time
3. **Document Blockers**: Include resolution attempts
4. **Celebrate Wins**: Note what went well
5. **Learn from Issues**: Document for retrospectives

## Integration with Git

Consider commit message format:
```
[T1.1.1] Implement MongoDB connection pooling

- Added connection pool with size 5-20
- Implemented retry logic
- Added health check endpoint

Task: T1.1.1 (Complete)
Time: 6 hours (Est: 4 hours)
```

This helps track task progress through version control.