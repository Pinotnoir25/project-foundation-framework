# Task Generation Prompts

This directory contains AI prompts for analyzing PRDs and generating comprehensive task breakdowns. These prompts ensure consistent, thorough task decomposition following agile best practices.

## Available Prompts

### 1. PRD to Task Breakdown (`prd-to-tasks.md`)
Analyzes a PRD and creates a complete task hierarchy with dependencies.

### 2. Task Estimation (`estimate-tasks.md`)
Helps estimate task sizes and effort based on complexity.

### 3. Dependency Analysis (`analyze-dependencies.md`)
Identifies and maps task dependencies from requirements.

### 4. Sprint Planning (`sprint-planning.md`)
Organizes tasks into sprints based on priorities and dependencies.

### 5. Risk-Based Task Generation (`risk-based-tasks.md`)
Creates mitigation tasks based on identified risks in the PRD.

## Usage Examples

### Generate Tasks from PRD
```
@claude Please analyze the PRD at docs/prd/features/core/[feature]-prd.md 
and create a task breakdown using docs/tasks/prompts/prd-to-tasks.md
```

### Estimate Existing Tasks
```
@claude Please estimate the tasks in docs/tasks/features/core/[feature]-tasks.md 
using the prompt at docs/tasks/prompts/estimate-tasks.md
```

### Plan Sprint
```
@claude Please create a sprint plan for [feature] using 
docs/tasks/prompts/sprint-planning.md
```

## Best Practices

1. **Always Reference the PRD**: Ensure the PRD path is correct before analysis
2. **Review Generated Tasks**: AI suggestions should be reviewed and refined
3. **Validate Dependencies**: Check that dependency chains make sense
4. **Consider Context**: Add project-specific context to prompts
5. **Iterate**: Use follow-up prompts to refine specific areas