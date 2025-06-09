# When to Create Technical Documentation

## Core Principle
Code is the primary documentation. Only document what code cannot express clearly.

## When Technical Docs Add Value

### Create Technical Documentation When:
1. **Architectural decisions have trade-offs**
   - Chose pattern A over B for specific reasons
   - Performance vs simplicity trade-offs
   - Security vs usability decisions

2. **Implementation is non-obvious**
   - Complex algorithms
   - Unusual patterns for good reasons
   - Workarounds for external limitations

3. **Container architecture is complex**
   - Multiple services interacting
   - Special networking requirements
   - Non-standard configurations

### Create API Documentation When:
1. **External consumers exist**
   - Other teams/services use your API
   - Public or partner APIs
   - Webhook contracts

2. **Contract stability matters**
   - Breaking changes would impact others
   - Versioning strategy needed
   - SLA commitments

### Create Test Plan When:
1. **Testing strategy is non-standard**
   - Special test data requirements
   - Complex integration scenarios
   - Performance benchmarks critical

2. **Regulatory requirements**
   - Compliance needs documentation
   - Audit trail requirements

## When NOT to Create Technical Docs

### Skip Documentation When:
1. **Code is self-explanatory**
   - Standard CRUD operations
   - Conventional patterns
   - Framework defaults

2. **Still exploring**
   - Rapid prototyping phase
   - Requirements unstable
   - Learning the domain

3. **Documentation duplicates code**
   - List of functions (code already shows this)
   - Database schema (migrations show this)
   - Basic REST endpoints (code is clear)

## Progressive Documentation

### Start Minimal
- One paragraph on key decision
- Basic API endpoint + example
- Three critical test cases

### Expand When
- Complexity emerges
- Multiple people need understanding
- Decisions prove controversial
- Performance becomes critical

### Signs You Need More Docs
- Same questions asked repeatedly
- New developers confused
- Bugs from misunderstanding
- External teams integrating

## Good vs Bad Documentation

### ✅ Good Technical Docs:
- "We use event sourcing because..."
- "This caching strategy prevents..."
- "Rate limiting works by..."

### ❌ Bad Technical Docs:
- "This function takes X and returns Y"
- "First, install dependencies..."
- "The user model has these fields..."

## Output Guidelines

Keep technical docs:
- Close to code (in repo)
- Minimal but sufficient
- Focused on "why" not "what"
- Updated when decisions change

Remember: The best documentation is code that doesn't need documentation.