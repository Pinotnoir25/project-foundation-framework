# Task Prompts - Progressive Approach

This directory contains AI prompts for progressive task management. Start small, add tasks as you learn, track progress simply.

## Core Philosophy

**Tasks emerge from work, not precede it.** We start with a few essential tasks and add more as we discover them during implementation.

## Available Prompts

### 1. Create Initial Tasks (`create-initial-tasks.md`)
Identifies 3-5 core tasks to begin implementation from a PRD.

### 2. Add Tasks As Needed (`add-tasks-as-needed.md`)
Helps add newly discovered tasks during development.

### 3. Track Progress (`track-progress.md`)
Simple progress updates - mark done, add new discoveries.

### 4. Prioritize Tasks (`prioritize-tasks.md`)
Decide what to work on next based on current context.

### 5. PRD to Initial Tasks (`prd-to-tasks.md`)
Extract just the essential starting tasks from a PRD.

### 6. Task Estimation (`estimate-tasks.md`)
Estimate effort when needed (not required upfront).

## Usage Examples

### Start a New Feature
```
@claude Please analyze the PRD at docs/prd/features/core/[feature]-prd.md 
and create initial tasks using docs/tasks/prompts/create-initial-tasks.md
```

### Add Discovered Tasks
```
@claude I discovered we need X while working on Y. Please help me add tasks
using docs/tasks/prompts/add-tasks-as-needed.md
```

### Update Progress
```
@claude Update progress on [feature] using docs/tasks/prompts/track-progress.md
I completed tasks 1 and 2, working on 3, discovered we need task 4.
```

### Decide What's Next
```
@claude Help me prioritize remaining tasks using 
docs/tasks/prompts/prioritize-tasks.md
```

## Best Practices

1. **Start Small**: Begin with 3-5 concrete tasks, not comprehensive plans
2. **Add as You Go**: Discover and add tasks during implementation
3. **Keep It Simple**: Use minimal templates, don't over-document
4. **Focus on Now**: What needs doing next, not distant future
5. **Learn and Adapt**: Let implementation inform task creation