# User Story to PRD Conversion Prompt

Use this prompt to convert user stories or brief requirements into a full PRD:

---

I need you to create a Product Requirements Document (PRD) based on the following user stories/requirements. Please use the PRD template at `docs/prd/templates/prd-template.md`.

## User Stories
[Paste your user stories here in the format:]
- As a [user type], I want to [action] so that [benefit]
- As a [user type], I want to [action] so that [benefit]

## Quick Context
- **Feature Area**: [Which part of the system]
- **Priority**: [High/Medium/Low]
- **Target Users**: [Primary user groups]

## Known Requirements
[List any specific requirements or constraints you already know]

## Questions to Address in the PRD
1. What problem does this solve beyond what's stated in the user stories?
2. How will we measure success?
3. What are the security implications?
4. What MongoDB collections will be affected?
5. How does this fit into the overall MCP server architecture?

Please create a comprehensive PRD that:
1. Expands the user stories into detailed requirements
2. Identifies unstated needs and edge cases
3. Proposes success metrics based on the user benefits
4. Considers the clinical trial data context
5. Addresses technical implementation approach without going into code details

Save to: `docs/prd/features/[appropriate-category]/[feature-name]-prd.md`