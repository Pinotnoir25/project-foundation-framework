# Technical Design Discovery Framework

This framework helps identify technical decisions needed for PRD features. The system includes pre-built suggestions for common patterns to accelerate decision-making.

## Available Technical Suggestions

The framework includes ready-to-use templates in `.framework/runtime/03-technical/suggestions/`:

### Frontend
- **Next.js Minimal Dark**: Modern, minimalist dark theme with enterprise aesthetic
- **React SPA Modern**: Vite-powered React with modern tooling
- **Vue Enterprise**: Production-ready Vue 3 with TypeScript

### Backend
- **Node.js API Patterns**: Express/Fastify with clean architecture
- **Python FastAPI**: High-performance async Python API

### Database
- **PostgreSQL Patterns**: Relational patterns with advanced features
- **MongoDB Schema Design**: Document-oriented patterns

### Infrastructure
- **Docker Compose Patterns**: Multi-container development setups
- **Deployment Patterns**: Kubernetes, AWS, CI/CD configurations

## Discovery Process

1. **Check for Suggestions**: Look for applicable templates in the suggestions library
2. **Present Options**: Show relevant suggestions to the user
3. **Customize**: Adapt suggestions based on specific requirements
4. **Document**: Record decisions in technical design docs

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

## Example Discovery Flow with Suggestions

### Scenario: PRD mentions "user interface needed"

1. **Detect Pattern**: Frontend required
2. **Present Suggestions**:
   ```
   I see you need a frontend. Here are some ready-to-use options:
   
   a) Next.js Minimal Dark Theme (Recommended for SaaS)
      - Modern black/white aesthetic
      - Server-side rendering
      - TypeScript + Tailwind CSS
      
   b) React SPA with Vite
      - Fast development
      - Client-side only
      - Modern tooling
      
   c) Vue Enterprise Setup
      - Progressive framework
      - Great for teams familiar with Vue
      
   Which approach fits your needs? Or would you prefer something else?
   ```

3. **Apply Selection**: Use the chosen template as baseline
4. **Customize**: Ask specific follow-ups based on PRD requirements

### Scenario: PRD mentions "data persistence"

1. **Present Options**:
   ```
   For data storage, I can suggest:
   
   a) PostgreSQL (Recommended for relational data)
      - ACID compliance
      - Complex queries
      - Strong consistency
      
   b) MongoDB
      - Flexible schemas
      - Document-oriented
      - Good for varied data
      
   What type of data will you be storing?
   ```

## Smart Question Patterns

### For Authentication Features
- **Default Suggestion**: "JWT-based authentication with refresh tokens?"
- Token-based (JWT) or session-based?
- Which authentication providers (email, OAuth)?
- Multi-factor authentication needed?
- Session timeout requirements?

### For Data Storage Features
- **Default Suggestion**: "PostgreSQL for relational data?"
- Database type (SQL/NoSQL)?
- Expected data volume?
- Query patterns?
- Backup/recovery needs?

### For API Features
- **Default Suggestion**: "RESTful API with OpenAPI documentation?"
- REST or GraphQL?
- Versioning strategy?
- Rate limiting requirements?
- Authentication method?

### For File Upload Features
- **Default Suggestion**: "Cloud storage (S3-compatible) with CDN?"
- Storage location (local, cloud)?
- Size limits?
- Allowed formats?
- Processing requirements?

### For Deployment
- **Default Suggestion**: "Docker containers with Kubernetes?"
- Container orchestration needed?
- Cloud provider preference?
- Scaling requirements?
- CI/CD pipeline needs?

## Using Suggestions Effectively

1. **Always Start with Suggestions**: Check if a pattern exists before asking open-ended questions
2. **Present 2-3 Options**: Don't overwhelm with choices
3. **Explain Trade-offs**: Brief pros/cons for each suggestion
4. **Allow Custom Options**: Always include "or would you prefer something else?"
5. **Progressive Refinement**: Start with high-level choices, then drill down

Remember: Suggestions accelerate decision-making but don't replace understanding the specific needs of each project.