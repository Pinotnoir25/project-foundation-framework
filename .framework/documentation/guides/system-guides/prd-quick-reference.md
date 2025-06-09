# PRD System Quick Reference

## Creating a New PRD with Claude

### Step 1: Choose Your Scenario
- **New Feature**: `docs/prd/prompts/new-feature-prd.md`
- **Integration**: `docs/prd/prompts/integration-prd.md`  
- **From User Story**: `docs/prd/prompts/user-story-to-prd.md`

### Step 2: Fill the Prompt Template
Replace all placeholders with your specific information.

### Step 3: Ask Claude
```
@claude Please create a PRD using [prompt file] with these details: [your info]
```

### Step 4: Review and Save
PRD will be saved to: `docs/prd/features/[category]/[feature-name]-prd.md`

## Working with Existing PRDs

### Before Implementing
```
@claude Please review the PRD at docs/prd/features/core/[feature]-prd.md before starting
```

### During Development
```
@claude According to the PRD, what are the success metrics for this feature?
```

### Updating PRDs
```
@claude Please update the [feature] PRD status to "In Development" and add these learnings: [details]
```

## PRD Categories
- `core/` - Core MCP server functionality
- `integrations/` - External system connections
- `infrastructure/` - System architecture, deployment

## Key Questions for PRDs
1. What problem are we solving?
2. Who has this problem?
3. How will we measure success?
4. What's the minimal solution?
5. What are the risks?