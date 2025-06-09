# Document Technical Decision Prompt

## First Check: Is this decision worth documenting?
Before creating or updating `decisions.md`:
- Is this a significant technical choice?
- Were alternatives seriously considered?
- Will this impact future development?
- Is this different from standard conventions?

If no to all, don't document. Avoid recording obvious choices.

## When documenting a significant decision:

## 1. Decision Context
Analyze the situation requiring a decision:
- What problem or need triggered this decision?
- What are the constraints (time, budget, technical)?
- Who are the stakeholders affected?
- What is the scope of impact?

## 2. Options Considered
For each alternative evaluated:
- Description of the approach
- Pros and advantages
- Cons and disadvantages
- Estimated effort/cost
- Risk assessment

## 3. Decision Made
Document the chosen approach:
- Which option was selected
- Primary reasons for selection
- Trade-offs accepted
- Implementation approach

## 4. Consequences
Analyze the implications:
- Positive outcomes expected
- Negative impacts accepted
- Changes required in other components
- Future flexibility gained or lost
- Technical debt incurred

## 5. Related Decisions
Link to context:
- Previous decisions that influenced this one
- Future decisions this enables or constrains
- Decisions that might need revisiting

## Decision Record Format
Structure as an ADR (Architectural Decision Record):
- Title: ADR-XXX: [Descriptive Title]
- Date: YYYY-MM-DD
- Status: [Proposed/Accepted/Deprecated/Superseded]
- Context: Clear problem statement
- Decision: What we're doing
- Consequences: What happens as a result

Keep decisions immutable once accepted - create new records to modify or reverse decisions.