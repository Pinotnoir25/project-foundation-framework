# PRD Prompt Templates

This directory contains reusable prompts for generating high-quality PRDs with AI assistance (Claude). These prompts follow modern PRD best practices and ensure consistency across all product documentation.

## How to Use These Prompts

1. Choose the appropriate prompt template based on your needs
2. Fill in the placeholders with your specific information
3. Copy the completed prompt and use it with Claude
4. Review and refine the generated PRD

## Available Prompts

### 1. New Feature PRD (`new-feature-prd.md`)
Use this when creating a PRD for a completely new feature or capability.

### 2. Integration PRD (`integration-prd.md`)
Use this for features that involve connecting with external systems or services.

### 3. Technical Infrastructure PRD (`infrastructure-prd.md`)
Use this for backend systems, architecture changes, or infrastructure improvements.

### 4. Quick PRD from User Story (`user-story-to-prd.md`)
Convert existing user stories or requirements into a full PRD.

### 5. PRD Review and Enhancement (`prd-review.md`)
Improve an existing PRD draft.

## Best Practices for Prompting

1. **Be Specific**: Provide as much context as possible about your product and users
2. **Include Constraints**: Mention technical, business, or resource limitations
3. **Reference Existing Docs**: Point to related PRDs or technical documentation
4. **Iterate**: Use follow-up prompts to refine specific sections

## Example Usage

```
@claude Please create a PRD using the template at docs/prd/prompts/new-feature-prd.md 
with the following details: [your specific information]
```