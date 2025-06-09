# Domain Mapping Initialization

Use this prompt to map out your business domain and establish consistent terminology:

---

## Prompt for Claude

I need to map out the domain for my [PROJECT_NAME] project. Please help me establish clear domain boundaries and terminology.

**Industry/Domain:**
- What industry or domain does this project serve? [e.g., Healthcare, Finance, E-commerce, Education]
- What specific area within that domain? [e.g., Patient monitoring, Payment processing, Inventory management]

**Core Concepts:**
Please help me define these key concepts in my domain:

1. **Primary Entity**: [What is the main "thing" your system manages?]
   - What are its key attributes?
   - What states can it have?
   - What actions can be performed on it?

2. **Supporting Entities**: [What other important concepts exist?]
   - Entity 1: [Name and description]
   - Entity 2: [Name and description]
   - Entity 3: [Name and description]

3. **Key Processes**: [What are the main workflows?]
   - Process 1: [Name and description]
   - Process 2: [Name and description]
   - Process 3: [Name and description]

**Domain Rules:**
- What are the critical business rules? [List 3-5 important rules]
- What validations must always be enforced?
- What are the edge cases to consider?

**Terminology Glossary:**
Help me create a glossary of domain-specific terms:
- Term 1: [Definition in project context]
- Term 2: [Definition in project context]
- Term 3: [Definition in project context]

**External Interactions:**
- What external systems will this interact with?
- What standards or protocols must be followed?
- What data formats are required?

Please create:
1. A domain model diagram (in text/ASCII)
2. A comprehensive glossary
3. Key domain rules documentation
4. Suggested bounded contexts

---

## What Claude Will Do

Claude will help you:

1. **Create Domain Documentation**
   - `.project/context/glossary.md` with all terminology
   - `.project/context/domain-model.md` with relationships
   - `.project/context/business-rules.md` with constraints

2. **Establish Naming Conventions**
   - Consistent terminology across documentation
   - Clear entity and action naming
   - Standardized status values

3. **Identify Patterns**
   - Common domain patterns applicable
   - Suggested design patterns
   - Anti-patterns to avoid

4. **Map Relationships**
   - Entity relationship diagrams
   - Process flow diagrams
   - Integration points

## Tips for Domain Mapping

- Use industry-standard terminology where applicable
- Define terms clearly for team alignment
- Consider future extensibility
- Map both happy paths and edge cases
- Include regulatory or compliance terms

## Example Domain Mapping

```
**Industry/Domain:**
- What industry or domain does this project serve? E-commerce
- What specific area within that domain? Order fulfillment and inventory management

**Core Concepts:**
1. **Primary Entity**: Order
   - Key attributes: order_id, customer, items, status, total_amount
   - States: pending, confirmed, processing, shipped, delivered, cancelled
   - Actions: create, confirm, fulfill, ship, deliver, cancel, refund

[... continue with all sections ...]
```