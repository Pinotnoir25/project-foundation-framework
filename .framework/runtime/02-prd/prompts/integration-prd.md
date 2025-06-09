# Integration PRD Prompt

When creating a PRD for external service integration:

## Information to Gather

### Essential (for minimal PRD):
1. **Purpose**: Why do we need this integration?
2. **Service**: What are we integrating with?
3. **Value**: What does this enable for users?
4. **Success**: How do we measure integration success?

### Additional (as needed):
1. **Data Flow**: What data moves between systems?
2. **Authentication**: How do we connect securely?
3. **Rate Limits**: Any API constraints?
4. **Failure Handling**: What if service is down?

## Creation Process

1. **Start with Business Need**:
   - Why this integration now?
   - What user problem does it solve?
   - What happens without it?

2. **Container Architecture**:
   - Which container handles this integration?
   - New service needed or existing?
   - Environment variables for credentials?

3. **Security First**:
   - How are credentials stored?
   - Data privacy considerations?
   - Network isolation needs?

4. **Progressive Detail**:
   - Start with `prd-minimal.md` for simple integrations
   - Use `prd-integration.md` for complex third-party services
   - Add technical details as you explore APIs

## Key Considerations
- External service documentation quality
- Webhook vs polling patterns
- Retry and circuit breaker needs
- Data transformation requirements
- Cost implications

## Anti-Patterns
- Don't document entire third-party API
- Don't design complex orchestration upfront
- Don't ignore failure scenarios
- Don't hardcode credentials

## Output
Save to: `docs/prd/features/integrations/[service-name]-integration.md`