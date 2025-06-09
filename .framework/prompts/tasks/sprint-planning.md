# Sprint Planning Prompt

Use this prompt to organize tasks into sprints:

---

I need you to create a sprint plan for the tasks in `[TASK_FILE_PATH]`. Please organize the tasks into 2-week sprints following these guidelines:

## Sprint Planning Criteria

### 1. Capacity Planning
- Sprint Duration: 2 weeks (10 working days)
- Developer Capacity: [X developers × 6 productive hours/day]
- Buffer: 20% for meetings, reviews, unexpected issues
- Total Sprint Capacity: [Calculate based on above]

### 2. Priority Factors
1. **Business Value**: Features that deliver immediate user value
2. **Technical Dependencies**: Prerequisites must come first
3. **Risk Reduction**: High-risk items early when possible
4. **Learning Curve**: Complex new tech in earlier sprints

### 3. Sprint Goals
Each sprint should have:
- Clear, achievable objective
- Demonstrable outcome
- Value delivery to users/system

## Sprint Structure Template

### Sprint [N]: [Sprint Name]
**Duration**: [Start Date] - [End Date]  
**Goal**: [What this sprint achieves]  
**Capacity**: [X story points / Y hours]

#### Committed Tasks
| Priority | Task ID | Task Name | Size | Dependencies Met? | Assignee |
|----------|---------|-----------|------|-------------------|----------|
| P0 | T1.1.1 | [Task] | M | ✓ | TBD |
| P0 | T1.1.2 | [Task] | S | After T1.1.1 | TBD |
| P1 | T1.2.1 | [Task] | L | ✓ | TBD |

#### Sprint Metrics
- Total Points: X
- P0 Tasks: Y
- P1 Tasks: Z
- Technical Debt: A%

#### Risks
- [Risk 1 and mitigation]
- [Risk 2 and mitigation]

#### Definition of Done
- [ ] Code complete and reviewed
- [ ] Unit tests passing (>80% coverage)
- [ ] Integration tests passing
- [ ] Documentation updated
- [ ] Deployed to staging

## Planning Constraints

### Must-Have Rules
1. No task dependencies across sprints (except epic boundaries)
2. Each sprint must have a shippable increment
3. Include time for testing and bug fixes
4. Reserve capacity for code reviews

### Balance Considerations
- Mix of frontend/backend tasks
- Include some quick wins
- Balance new features with technical debt
- Leave room for discovered work

## Output Format

Provide:
1. **Sprint Overview**: Table of all sprints with goals and capacity
2. **Detailed Sprint Plans**: Full task list for first 2 sprints
3. **Dependency Timeline**: Critical path visualization
4. **Risk Matrix**: Per-sprint risk assessment
5. **Backlog**: Remaining tasks for future sprints

## Success Metrics
- Velocity trend (should stabilize after Sprint 2)
- Completion rate (target >90%)
- Technical debt ratio (<20%)

Please create a realistic sprint plan that maximizes value delivery while managing technical dependencies and risks.