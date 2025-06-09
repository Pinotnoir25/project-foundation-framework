# When to Create Context Files

This prompt guides the progressive creation of context files based on actual need, avoiding premature documentation.

## Core Principle
Start minimal. Create files only when they provide immediate value. Don't create empty templates "for later."

## File Creation Guidelines

### 1. project.json
**Create immediately when**: User says "Let's start" or begins any project work
**Start with**: Minimal fields only
```json
{
  "name": "Project Name",
  "description": "Brief description", 
  "primaryLanguage": "Language being used",
  "status": "Starting"
}
```
**Add fields when**: 
- User mentions specific framework → add "framework"
- Database is chosen → add "database"
- Deployment target discussed → add "infrastructure"
- Commands are established → add setup/build/test/run commands

### 2. current-state.md
**Create when**:
- First feature is completed
- User asks "what's the status?"
- Significant milestone reached
- Blocker encountered that needs tracking

**Don't create for**:
- Empty "nothing implemented yet" content
- Theoretical future plans

### 3. decisions.md
**Create when**:
- First significant technical choice is made
- User explicitly chooses between alternatives
- Trade-off is accepted (e.g., "we'll use X even though Y is faster")
- Architecture pattern is selected

**Don't create for**:
- Obvious choices (e.g., using npm with Node.js)
- Default framework conventions

### 4. glossary.md
**Create when**:
- Domain-specific terms emerge in conversation
- User defines business concepts
- Confusion about terminology arises
- API resources are named

**Don't create for**:
- Standard technical terms
- Single-term projects

## Progressive Enhancement

When a file exists but needs expansion:
1. Add only the new relevant section
2. Keep existing content minimal
3. Don't add empty sections "for completeness"

## Key Questions to Ask

Before creating any context file:
1. Will this file have meaningful content right now?
2. Will it be referenced in the next few conversations?
3. Is the user asking for this information?

If any answer is "no," wait to create the file.

## Examples

**Good timing**:
- User: "We'll use PostgreSQL for the database" → Update project.json
- User: "What have we built so far?" → Create current-state.md
- User: "Let's use event sourcing instead of CRUD" → Create decisions.md
- User: "In our system, a 'widget' means..." → Create glossary.md

**Too early**:
- Project just started → Don't create all four files
- No code written yet → Don't create current-state.md
- Using standard stack → Don't document obvious decisions
- No domain complexity → Don't create empty glossary