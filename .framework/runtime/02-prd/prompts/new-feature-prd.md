# New Feature PRD Prompt

When creating a PRD for a new user-facing feature:

## Information to Gather

### Essential (for minimal PRD):
1. **Problem**: What specific problem does this solve for users?
2. **Users**: Who experiences this problem?
3. **Solution**: High-level approach (1-2 sentences)
4. **Success**: How do we measure if it works?

### Additional (as complexity emerges):
1. **User Journey**: How users currently handle this
2. **Technical Approach**: Architecture considerations
3. **Dependencies**: Other features or services needed
4. **Risks**: What could go wrong?

## Creation Process

1. **Start Small**:
   - Use `prd-minimal.md` for simple features
   - Use `prd-feature.md` for more complex user features

2. **Focus on User Value**:
   - Lead with the problem, not the solution
   - Describe impact on user experience
   - Keep technical details minimal initially

3. **Container Considerations**:
   - Which service/container implements this?
   - Any new endpoints needed?
   - Environment variables or configuration?

4. **Progressive Enhancement**:
   - Start with core sections
   - Add detail as feature develops
   - Update PRD as learning occurs

## Anti-Patterns to Avoid
- Don't create 10-page PRDs upfront
- Don't include implementation details
- Don't leave sections empty "for later"
- Don't delay starting due to "incomplete" info

## Output
Save to: `docs/prd/features/core/[feature-name].md`