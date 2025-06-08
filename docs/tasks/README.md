# Task Management System

## Overview

This directory contains the task breakdown and tracking system for implementing features defined in PRDs. It follows modern agile practices with a focus on clear task decomposition, dependency management, and progress tracking.

## Directory Structure

```
docs/tasks/
├── README.md              # This file
├── features/              # Task breakdowns by feature
│   ├── core/             # Core functionality tasks
│   ├── integrations/     # Integration tasks
│   └── infrastructure/   # Infrastructure tasks
├── templates/            # Reusable task templates
├── prompts/              # AI prompts for PRD analysis
└── tracking/             # Task tracking and burndown
```

## Task Management Philosophy

Based on agile best practices (2024-2025):

1. **Progressive Elaboration**: Tasks are refined as more information becomes available
2. **INVEST Principles**: Tasks should be Independent, Negotiable, Valuable, Estimable, Small, and Testable
3. **Clear Dependencies**: Explicit task ordering and blocking relationships
4. **Measurable Outcomes**: Each task has clear completion criteria

## Task Hierarchy

```
Feature (from PRD)
├── Epic (Major deliverable)
│   ├── User Story (User-facing functionality)
│   │   ├── Task (Technical implementation)
│   │   └── Sub-task (Specific work item)
```

## Workflow

### 1. PRD to Task Breakdown
```bash
# Use the prompt template to analyze a PRD
@claude Please analyze the PRD at docs/prd/features/core/[feature].md 
and create a task breakdown using docs/tasks/prompts/prd-to-tasks.md
```

### 2. Task Documentation
Each feature gets a task breakdown document:
- Location: `docs/tasks/features/[category]/[feature]-tasks.md`
- Uses template: `docs/tasks/templates/task-breakdown-template.md`

### 3. Task Tracking
- Daily updates in `tracking/[feature]-progress.md`
- Dependencies tracked in task breakdown
- Completion status updated as work progresses

## Task States

- **📋 Planned**: Task defined but not started
- **🚧 Blocked**: Waiting on dependency
- **💻 In Progress**: Actively being worked on
- **👀 Review**: Complete, awaiting review
- **✅ Done**: Fully complete and tested

## Task Sizing

| Size | Story Points | Dev Time | Description |
|------|-------------|----------|-------------|
| XS   | 1           | < 2 hrs  | Trivial change |
| S    | 2-3         | 2-4 hrs  | Small feature |
| M    | 5-8         | 1-2 days | Medium feature |
| L    | 13          | 3-5 days | Large feature |
| XL   | 21+         | > 1 week | Should be broken down |

## Integration with Development

### During Implementation
```bash
# Check current task status
@claude What's the status of tasks for [feature]?

# Update task progress
@claude Mark task T1.2 as complete and start T1.3
```

### Task Dependencies
- Tasks can depend on other tasks
- Dependencies must be completed first
- Circular dependencies are not allowed

## Best Practices

1. **One Task, One Purpose**: Each task should have a single, clear objective
2. **Testable Completion**: Define "done" criteria for each task
3. **Regular Updates**: Update task status at least daily
4. **Dependency Awareness**: Check dependencies before starting work
5. **Time Boxing**: Estimate and track actual time spent

## Quick Links

- [Task Breakdown Template](templates/task-breakdown-template.md)
- [PRD Analysis Prompts](prompts/README.md)
- [Current Sprint Tasks](tracking/current-sprint.md)
- [Task Metrics](tracking/metrics.md)