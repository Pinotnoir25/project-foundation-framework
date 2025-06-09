# PRD to Task Breakdown Prompt

Use this prompt to analyze a PRD and generate a comprehensive task breakdown:

---

I need you to analyze a Product Requirements Document (PRD) and create a detailed task breakdown for implementation. Please read the PRD at `[PRD_PATH]` and generate a task breakdown using the template at `docs/tasks/templates/task-breakdown-template.md`.

## Analysis Requirements

### 1. Requirement Extraction
From the PRD, identify:
- All functional requirements (FR)
- All non-functional requirements (NFR)
- Technical constraints
- Dependencies mentioned
- Success metrics

### 2. Epic Definition
Create epics based on:
- Major functional areas from the PRD
- Logical groupings of related features
- Dependencies and implementation order

### 3. User Story Creation
For each epic, create user stories that:
- Follow the format: "As a [user], I want [capability] so that [benefit]"
- Map directly to PRD requirements
- Are independently deliverable when possible
- Follow INVEST principles

### 4. Task Decomposition
For each user story, create tasks that:
- Are technically specific and actionable
- Can be completed in 1-2 days maximum
- Include clear completion criteria
- Identify technical implementation approach

### 5. Dependency Mapping
- Identify dependencies between tasks
- Note external dependencies (APIs, services, data)
- Create optimal implementation order
- Flag potential blocking issues

### 6. Size Estimation
Estimate each task using:
- XS (< 2 hours): Configuration changes, small updates
- S (2-4 hours): Simple features, basic CRUD operations  
- M (1-2 days): Complex features, integrations
- L (3-5 days): Major components, architectural changes
- XL (> 1 week): Should be decomposed further

### 7. Risk Identification
For each epic/story:
- Identify implementation risks
- Create mitigation tasks if needed
- Note areas needing research/spikes

## Output Requirements

1. **Complete Task Hierarchy**: Epics → Stories → Tasks with clear IDs
2. **Dependency Diagram**: Visual representation of task dependencies
3. **Implementation Phases**: Logical grouping for sprint planning
4. **Testing Strategy**: Unit, integration, and acceptance test tasks
5. **Technical Decisions**: Key architecture/technology choices needed

## Special Considerations

### For {{PROJECT_TYPE}} Features:
- Consider {{DATABASE_TYPE}} connection requirements
- Account for {{CONNECTION_CONSTRAINTS}}
- Include {{PROTOCOL}} compliance tasks
- Add security validation tasks

### For {{INDUSTRY_CONTEXT}}:
- Include data privacy/{{COMPLIANCE_FRAMEWORK}} compliance tasks
- Add audit logging tasks where needed
- Consider {{SENSITIVE_DATA_TYPE}} handling requirements

## Additional Instructions

- Break down any task estimated as XL
- Include documentation tasks for APIs/interfaces
- Add monitoring/logging setup tasks
- Consider rollback/recovery scenarios
- Include performance testing for requirements with metrics

Please create a comprehensive task breakdown that can be directly used for sprint planning and development tracking.

Save the result to: `docs/tasks/features/[category]/[feature-name]-tasks.md`