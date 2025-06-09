# Document Technical Decisions Prompt

When documenting technical decisions during or after implementation:

## 1. Check if Documentation Needed

Ask yourself:
- Is this decision non-obvious from the code?
- Were there significant trade-offs?
- Will future developers wonder "why"?

If no to all, skip documentation.

## 2. What to Document

### Architecture Decisions
- **Pattern chosen**: [e.g., Event sourcing, CQRS, etc.]
- **Why this way**: [Specific project needs]
- **What we gave up**: [Trade-offs accepted]
- **When to revisit**: [Conditions for change]

### Container Decisions
- **Service boundaries**: Why split this way?
- **Communication patterns**: Why REST vs message queue?
- **Data persistence**: Why this database for this service?

### Performance Optimizations
- **What optimization**: [Caching, indexing, etc.]
- **Measured impact**: [Before/after metrics]
- **Complexity cost**: [What became harder]

### Security Choices
- **Beyond defaults**: Only document non-standard choices
- **Threat model**: What specific risk addressed
- **Implementation**: High-level approach

## 3. How to Document

Use minimal template:
1. Start with one paragraph explaining the decision
2. Add detail only if questions arise
3. Link to relevant code/PRD
4. Keep in `docs/technical/[feature]-technical.md`

## 4. When to Document

Best times:
- **During implementation**: When making non-obvious choice
- **After confusion**: When someone asks "why?"
- **Before handoff**: When others will maintain

Not:
- Before coding (premature)
- For standard patterns (unnecessary)
- As busywork (wasteful)

## Examples

### Good Documentation:
"We use Redis for session storage instead of the database because our session reads outnumber writes 100:1 and database CPU was bottlenecking at 10K concurrent users."

### Unnecessary Documentation:
"We use Express.js for our REST API with standard middleware configuration following the official documentation."

Remember: If the code clearly shows WHAT, only document WHY when it's not obvious.