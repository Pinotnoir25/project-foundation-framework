# Technical Design Discovery Framework

For every PRD feature, evaluate these dimensions:

## 1. Data & Storage
- What data is created/modified?
- Volume and growth expectations?
- Access patterns (read-heavy, write-heavy)?
- Retention requirements?

## 2. Integration Points
- External services needed?
- API contracts required?
- Data formats and protocols?
- Error handling strategies?

## 3. Security & Access
- Authentication requirements?
- Authorization rules?
- Data sensitivity level?
- Audit requirements?

## 4. Performance & Scale
- Expected load?
- Response time requirements?
- Caching opportunities?
- Resource constraints?

## 5. Operations & Maintenance
- Monitoring needs?
- Logging requirements?
- Error recovery processes?
- Update/migration considerations?

## Discovery Process
1. Read PRD feature
2. Identify which dimensions apply
3. Form specific questions for user
4. Document decisions made
5. Create implementation tasks based on decisions

## Example Questions to Ask

### For Authentication Features
- Token-based (JWT) or session-based?
- Which authentication providers (email, OAuth)?
- Multi-factor authentication needed?
- Session timeout requirements?

### For Data Storage Features
- Database type (SQL/NoSQL)?
- Expected data volume?
- Query patterns?
- Backup/recovery needs?

### For API Features
- REST or GraphQL?
- Versioning strategy?
- Rate limiting requirements?
- Authentication method?

### For File Upload Features
- Storage location (local, cloud)?
- Size limits?
- Allowed formats?
- Processing requirements?

Remember: Start with simple questions, refine as you learn more about the project's needs.