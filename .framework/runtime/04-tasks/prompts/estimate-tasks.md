# Task Estimation Prompt

Use this prompt when you need to estimate tasks (not required upfront):

---

I need to estimate some tasks for planning purposes. Tasks are in `[TASK_FILE_PATH]`.

## Why I Need Estimates
[Explain why estimates are needed now - e.g., resource planning, deadline commitment, prioritization]

For the tasks that need estimates, provide:

## Estimation Criteria

### 1. Complexity Analysis
Consider:
- Technical complexity (algorithms, data structures)
- Integration complexity (external systems, APIs)
- Domain complexity (business rules, edge cases)
- Testing complexity (test scenarios, coverage)

### 2. Effort Factors
- **Development Time**: Actual coding time
- **Research Time**: Learning, investigation needed
- **Testing Time**: Writing and running tests
- **Review Time**: Code review cycles
- **Integration Time**: Deployment and verification

### 3. Risk Factors
- Uncertainty in requirements
- Dependency on external systems
- New technology/patterns
- Performance requirements

## Estimation Output

For each task, provide:

```
Task ID: [ID]
Task: [Name]
Current Size: [S/M/L]
Recommended Size: [XS/S/M/L/XL]
Estimated Hours: [X-Y hours]
Confidence: [High/Medium/Low]
Rationale: [Why this estimate]
Risks: [What could increase the estimate]
```

## Size Guidelines

- **XS (< 2 hours)**:
  - Simple configuration changes
  - Minor bug fixes
  - Small UI updates
  - Basic documentation

- **S (2-4 hours)**:
  - Simple CRUD operations
  - Basic validation logic
  - Standard API endpoints
  - Simple UI components

- **M (1-2 days)**:
  - Complex business logic
  - Integration with external services
  - Performance optimizations
  - Complex UI features

- **L (3-5 days)**:
  - Major architectural components
  - Complex integrations
  - New service implementation
  - Significant refactoring

- **XL (> 1 week)**:
  - Should be broken down into smaller tasks
  - If unavoidable, provide breakdown suggestion

## Special Considerations

1. **First-time vs. Repeated Tasks**: First implementation takes longer
2. **Team Experience**: Adjust for familiarity with tech stack
3. **Code Quality Standards**: Include time for tests, documentation
4. **Review Cycles**: Account for feedback iterations

## Remember

- Only estimate what you need to estimate
- Rough estimates are often sufficient
- Estimates can be refined as you learn more
- "I don't know yet" is a valid answer for distant tasks

Please provide estimates only for tasks that need them, with brief rationale.