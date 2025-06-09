# [Feature Name] Task Breakdown

**PRD Reference**: `docs/prd/features/[category]/[feature]-prd.md`  
**Created**: YYYY-MM-DD  
**Last Updated**: YYYY-MM-DD  
**Target Completion**: YYYY-MM-DD  
**Status**: Planning | In Progress | Complete

## Summary

[Brief overview of the feature and its implementation approach]

## Task Hierarchy

### Epic 1: [Epic Name]
**Description**: [What this epic delivers]  
**Success Criteria**: [How we know it's complete]

#### Story 1.1: [User Story]
**As a** [user type], **I want** [capability] **so that** [benefit]

##### Tasks:
| ID | Task | Size | Status | Assignee | Dependencies | Done Criteria |
|----|------|------|--------|----------|--------------|---------------|
| T1.1.1 | [Task description] | S/M/L | 📋 Planned | - | None | [Completion criteria] |
| T1.1.2 | [Task description] | S/M/L | 📋 Planned | - | T1.1.1 | [Completion criteria] |

#### Story 1.2: [User Story]
**As a** [user type], **I want** [capability] **so that** [benefit]

##### Tasks:
| ID | Task | Size | Status | Assignee | Dependencies | Done Criteria |
|----|------|------|--------|----------|--------------|---------------|
| T1.2.1 | [Task description] | S/M/L | 📋 Planned | - | None | [Completion criteria] |

### Epic 2: [Epic Name]
**Description**: [What this epic delivers]  
**Success Criteria**: [How we know it's complete]

## Task Details

### T1.1.1: [Full Task Name]
**Description**: [Detailed description of what needs to be done]  
**Technical Notes**: [Any technical considerations or approaches]  
**Acceptance Criteria**:
- [ ] [Specific criterion 1]
- [ ] [Specific criterion 2]
- [ ] Unit tests written and passing
- [ ] Code reviewed

### T1.1.2: [Full Task Name]
**Description**: [Detailed description]  
**Technical Notes**: [Technical details]  
**Acceptance Criteria**:
- [ ] [Criteria]

## Dependencies Diagram

```
T1.1.1 ──→ T1.1.2 ──→ T1.2.1
             ↓
           T2.1.1 ──→ T2.1.2
```

## Implementation Order

1. **Phase 1** (Sprint 1):
   - T1.1.1: [Task name]
   - T1.1.2: [Task name]

2. **Phase 2** (Sprint 2):
   - T1.2.1: [Task name]
   - T2.1.1: [Task name]

## Risk Mitigation

| Risk | Impact | Mitigation | Contingency |
|------|--------|------------|-------------|
| [Risk description] | High/Med/Low | [How to prevent] | [Backup plan] |

## Technical Decisions

### Architecture Choices
- [Decision 1]: [Rationale]
- [Decision 2]: [Rationale]

### Technology Stack
- [Component]: [Technology choice and why]

## Testing Strategy

### Unit Tests
- Coverage target: X%
- Key test scenarios: [List]

### Integration Tests
- [Test scenario 1]
- [Test scenario 2]

### Acceptance Tests
- [User flow 1]
- [User flow 2]

## Progress Tracking

### Metrics
- Total Tasks: X
- Completed: X (X%)
- In Progress: X
- Blocked: X

### Burndown
| Week | Planned | Actual | Notes |
|------|---------|--------|-------|
| 1    | 5 tasks | - | - |
| 2    | 10 tasks | - | - |

## Notes and Learnings

### Implementation Notes
- [Important discoveries during implementation]

### Deviations from PRD
- [Any changes from original plan and why]

### Retrospective Items
- What went well:
- What could improve:
- Action items:

---

## Task Status Legend
- 📋 Planned: Not started
- 🚧 Blocked: Waiting on dependency
- 💻 In Progress: Being worked on
- 👀 Review: Code complete, in review
- ✅ Done: Merged and deployed

## Size Estimates
- XS: < 2 hours
- S: 2-4 hours  
- M: 1-2 days
- L: 3-5 days
- XL: > 1 week (should be broken down)