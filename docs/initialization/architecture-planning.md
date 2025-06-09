# Architecture Planning Initialization

Use this prompt to design your system architecture with Claude:

---

## Prompt for Claude

I need to plan the architecture for my [PROJECT_NAME] project. Based on our project setup and domain mapping, help me design a robust and scalable architecture.

**System Requirements:**
- Expected Users: [Concurrent users, total users]
- Data Volume: [Expected data size and growth]
- Performance Needs: [Response time, throughput]
- Availability Requirements: [Uptime SLA, disaster recovery]

**Architecture Style:**
What architectural pattern best fits my needs?
- [ ] Monolithic
- [ ] Microservices
- [ ] Serverless
- [ ] Event-driven
- [ ] Other: [Specify]

**Component Design:**
Help me define the main components:

1. **Frontend/Client Layer**
   - Technology: [Web, Mobile, Desktop, API]
   - Framework: [Specific framework choice]
   - Key Features: [List main UI/UX features]

2. **Backend/Service Layer**
   - API Style: [REST, GraphQL, gRPC, etc.]
   - Services Needed: [List core services]
   - Integration Points: [External systems]

3. **Data Layer**
   - Primary Database: [Type and purpose]
   - Caching Strategy: [Redis, Memcached, etc.]
   - Data Patterns: [CQRS, Event Sourcing, etc.]

4. **Infrastructure Layer**
   - Deployment Target: [Cloud, On-premise, Hybrid]
   - Container Strategy: [Docker, Kubernetes, etc.]
   - CI/CD Approach: [Tools and pipeline]

**Cross-Cutting Concerns:**
- Authentication/Authorization: [Approach]
- Logging/Monitoring: [Strategy and tools]
- Error Handling: [Patterns to use]
- Security: [Key security measures]

**Scalability Plan:**
- How will the system scale? [Horizontal, Vertical]
- What are the bottlenecks? [Identify potential issues]
- Caching strategy? [Where and what to cache]

Please help me:
1. Create an architecture diagram
2. Document key architectural decisions
3. Identify technology choices with rationale
4. Plan for future growth
5. Define integration patterns

---

## What Claude Will Do

Claude will help you:

1. **Create Architecture Documentation**
   - `.project/context/architecture.md` with diagrams
   - `.project/context/decisions.md` for ADRs
   - `.project/context/tech-stack.md` with choices

2. **Design System Components**
   - Component responsibility mapping
   - Interface definitions
   - Data flow diagrams
   - Deployment topology

3. **Establish Patterns**
   - Design patterns to implement
   - Communication patterns
   - Error handling strategies
   - Security patterns

4. **Plan Implementation**
   - Development sequence
   - Risk mitigation
   - Testing strategy
   - Performance benchmarks

## Architecture Decision Record (ADR) Template

```markdown
# ADR-001: [Decision Title]

## Status
[Proposed | Accepted | Deprecated]

## Context
[What is the issue we're addressing?]

## Decision
[What have we decided to do?]

## Consequences
[What are the positive and negative outcomes?]

## Alternatives Considered
[What other options did we evaluate?]
```

## Example Architecture Planning

```
**System Requirements:**
- Expected Users: 1000 concurrent, 10,000 total
- Data Volume: 1TB initial, 100GB/month growth
- Performance Needs: <200ms API response, 99.9% uptime
- Availability Requirements: 99.9% SLA, 4-hour RTO

**Architecture Style:**
- [x] Microservices (for independent scaling and deployment)

[... continue with all sections ...]
```