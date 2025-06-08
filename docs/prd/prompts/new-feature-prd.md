# New Feature PRD Generation Prompt

Use this prompt template to generate a comprehensive PRD for a new feature:

---

I need you to create a Product Requirements Document (PRD) for a new feature in our MCP (Model Context Protocol) server project. Please use the PRD template located at `docs/prd/templates/prd-template.md`.

## Context
- **Project**: Nexus MCP Research Mongo Database Server
- **Purpose**: Enable Nexus LLM to interact with a Research MongoDB containing metadata for an eClinical solution (CMP)
- **Current Stage**: [e.g., "Early development", "MVP planning", "Production enhancement"]

## Feature Information
- **Feature Name**: [Name of the feature]
- **Feature Category**: [core/integrations/infrastructure]
- **Brief Description**: [1-2 sentences about what this feature does]

## Problem Details
- **Problem Statement**: [Describe the specific problem this feature solves]
- **Affected Users**: [Who experiences this problem]
- **Current Workaround**: [How users currently handle this, if applicable]
- **Evidence/Data**: [Any user feedback, metrics, or research supporting this need]

## Solution Direction
- **High-Level Approach**: [General idea of how to solve this]
- **Key Capabilities**: [Main things the feature should do]
- **Out of Scope**: [What this feature will NOT do]

## Success Criteria
- **Primary Success Metric**: [How we'll measure if this works]
- **Additional Metrics**: [Other important measurements]
- **Target Timeline**: [When this needs to be delivered]

## Technical Context
- **Related Systems**: [MongoDB collections, APIs, or services involved]
- **Technical Constraints**: [Any limitations or requirements]
- **Dependencies**: [What this feature depends on]

## Additional Information
[Any other context, links to discussions, or relevant details]

---

Please create a comprehensive PRD following the template structure, ensuring to:
1. Separate problem exploration from solution details
2. Include specific, measurable success metrics
3. Define clear acceptance criteria for each requirement
4. Consider security implications given the healthcare/clinical trial context
5. Account for the SSH tunnel requirement for MongoDB access

Save the PRD to: `docs/prd/features/[category]/[feature-name]-prd.md`