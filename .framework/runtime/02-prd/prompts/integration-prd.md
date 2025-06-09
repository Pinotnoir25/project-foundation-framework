# Integration PRD Generation Prompt

Use this prompt for creating PRDs focused on integrations with external systems:

---

I need you to create a Product Requirements Document (PRD) for an integration feature in our MCP server. Please use the PRD template at `docs/prd/templates/prd-template.md`.

## Integration Overview
- **Integration Name**: [Name of the integration]
- **External System**: [System we're integrating with]
- **Integration Type**: [API/Database/File/Stream/etc.]
- **Data Flow Direction**: [Inbound/Outbound/Bidirectional]

## Business Context
- **Why This Integration**: [Business reason for this integration]
- **Expected Volume**: [Data volume, frequency of use]
- **Critical User Workflows**: [Key use cases that depend on this]

## Technical Integration Details
- **Authentication Method**: [How we'll authenticate]
- **Data Format**: [JSON/XML/CSV/etc.]
- **Protocol**: [REST/GraphQL/gRPC/etc.]
- **Rate Limits**: [Any known limitations]

## Data Mapping
- **Source Data**: [What data from their system]
- **Target Collections**: [Which MongoDB collections affected]
- **Transformation Requirements**: [How data needs to be transformed]

## Security & Compliance
- **Data Sensitivity**: [PHI/PII considerations]
- **Compliance Requirements**: [HIPAA, GDPR, etc.]
- **Access Controls**: [Who can use this integration]

## Error Handling & Monitoring
- **Failure Scenarios**: [What could go wrong]
- **Retry Strategy**: [How to handle failures]
- **Monitoring Needs**: [What to track]

Please create a comprehensive integration PRD that:
1. Clearly defines the integration boundaries
2. Addresses data security given the clinical trial context
3. Includes detailed error handling requirements
4. Specifies monitoring and alerting needs
5. Considers the SSH tunnel constraint for MongoDB access

Save to: `docs/prd/features/integrations/[integration-name]-prd.md`