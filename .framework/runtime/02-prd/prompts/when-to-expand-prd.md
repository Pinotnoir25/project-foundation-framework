# When to Expand PRD

## Core Principle
Start with minimal PRD. Add sections only when they provide clarity or address complexity.

## PRD Evolution Guidelines

### Start with Minimal PRD When:
- Feature is straightforward
- Problem and solution are clear
- Limited user impact
- No significant technical complexity
- Proof of concept or experiment

### Expand to Feature/Integration/Infrastructure PRD When:
- Multiple stakeholders involved
- User experience needs detail
- Technical approach has trade-offs
- Integration points exist
- Performance/security concerns

### Add Sections Progressively

#### Add "User Personas" When:
- Multiple user types affected differently
- User needs conflict
- Accessibility considerations
- Role-based features

#### Add "Technical Specification" When:
- Architecture decisions needed
- Performance requirements critical
- Security implications exist
- Database schema changes

#### Add "Phases/Milestones" When:
- Feature too large for single release
- Dependencies need sequencing
- Risk requires incremental rollout
- Learning needed between phases

#### Add "Risks & Mitigations" When:
- Technical unknowns exist
- Third-party dependencies
- Performance concerns
- Security implications
- Business risks identified

### Use Comprehensive PRD Only When:
- Major feature (3+ weeks of work)
- Cross-functional impact
- Strategic initiative
- Compliance requirements
- High-risk changes

## Anti-Patterns to Avoid

❌ **Don't**:
- Create empty sections "for later"
- Add sections because template has them
- Write novels when bullets suffice
- Document obvious things
- Delay starting due to "incomplete" PRD

✅ **Do**:
- Start minimal, expand as needed
- Focus on what's unclear or risky
- Keep sections that add value
- Update PRD as you learn
- Let PRD grow with feature complexity

## Examples

**Minimal PRD Appropriate**:
- "Add dark mode toggle"
- "Export data as CSV"
- "Update error messages"

**Expanded PRD Needed**:
- "Implement real-time collaboration"
- "Add payment processing"
- "Redesign authentication flow"

**Comprehensive PRD Required**:
- "Multi-tenant architecture"
- "GDPR compliance implementation"
- "Platform migration"