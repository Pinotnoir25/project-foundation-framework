# Update Project State Prompt

## First Check: Should this file exist?
If `current-state.md` doesn't exist yet:
- Is there meaningful state to document?
- Has at least one feature been implemented?
- Is the user asking about project status?

If no to all, don't create the file yet.

## When updating existing state documentation:

### 1. Implementation Progress
Review what has been completed:
- Features fully implemented
- Components partially completed
- Integration points established
- Tests written and passing

### 2. Current Work
Document active development:
- Features currently being built
- Progress percentage estimates
- Active branches or work streams
- Who is working on what (if team project)

### 3. Blockers and Issues
Identify impediments:
- Technical blockers
- Missing dependencies
- Unclear requirements
- Performance issues discovered
- Security concerns identified

### 4. Recent Changes
Summarize latest updates:
- What changed since last update
- Why changes were made
- Impact of changes on other components
- Any breaking changes introduced

### 5. Environment Status
Track deployment state:
- Development environment status
- Staging/testing environment state  
- Production deployment status
- Version numbers deployed

### 6. Next Steps
Define immediate priorities:
- Next features to implement
- Technical debt to address
- Refactoring needs
- Documentation updates required

## Progressive Enhancement
- Start with only sections that have content
- Don't create empty sections
- Add new sections as they become relevant
- Keep focus on actionable information

## Update Guidelines
- Be specific with dates and versions
- Include concrete metrics where possible
- Link to relevant PRDs or technical docs
- Highlight risks or concerns
- Keep entries concise but complete