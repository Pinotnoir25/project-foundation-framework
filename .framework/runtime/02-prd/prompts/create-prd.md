# Create PRD Prompt

When asked to create a PRD, follow this approach:

## 1. Determine PRD Type Needed

### Start with Minimal PRD if:
- User provides brief feature description
- Problem is straightforward
- No complex integrations mentioned
- Quick experiment or proof of concept

### Choose Specific Template Based on:
- **Feature PRD**: User-facing functionality
- **Integration PRD**: Connecting with external services
- **Infrastructure PRD**: Platform, performance, or deployment needs

## 2. Gather Essential Information

Ask only what's missing for the minimal PRD:
- What problem does this solve?
- Who experiences this problem?
- What's the simplest solution approach?
- How will we know it's successful?

Don't ask for:
- Detailed technical specifications
- Full user journeys
- Comprehensive metrics
- Phase planning

## 3. Create Progressive PRD

1. Start with appropriate minimal template from:
   - `.framework/runtime/02-prd/templates/prd-minimal.md`
   - `.framework/runtime/02-prd/templates/prd-feature.md`
   - `.framework/runtime/02-prd/templates/prd-integration.md`
   - `.framework/runtime/02-prd/templates/prd-infrastructure.md`

2. Fill only sections with actual content
3. Note at bottom: "Expand this PRD as feature develops"
4. Save to: `docs/prd/features/[category]/[feature-name].md`

## 4. Suggest Next Steps

After creating minimal PRD:
- "This PRD captures the core idea. As we develop, we can add:"
  - User personas (if multiple user types emerge)
  - Technical details (if architecture decisions needed)
  - Phases (if too large for one release)
  - Risks (if uncertainties discovered)

## Key Principles

- Don't overwhelm with comprehensive PRD upfront
- Let PRD grow with understanding
- Focus on what's needed now, not what might be needed
- Keep it conversational and iterative