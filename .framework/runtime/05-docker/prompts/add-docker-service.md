# Add Docker Service Prompt

When considering adding a new service to your Docker setup, evaluate carefully:

## 1. Justify the Need

Before adding any service, answer:
- What specific problem does this service solve?
- Is there a simpler alternative?
- Can the app function without it initially?
- Will this be needed in development, production, or both?

## 2. Common Service Additions

### Database (PostgreSQL, MySQL, MongoDB)
Add when:
- App requires persistent data storage
- You're moving beyond in-memory or file storage
- Multiple app instances need shared data

### Cache (Redis, Memcached)
Add when:
- Measured performance issues exist
- Session storage needed across instances
- Background job queuing required

### Message Queue (RabbitMQ, Kafka)
Add when:
- Async processing actually needed
- Multiple services need communication
- Event-driven architecture required

### Search (Elasticsearch)
Add when:
- Full-text search requirements
- Complex querying needs
- Faceted search features

## 3. Implementation Steps

1. Start with existing working setup
2. Add service to docker-compose incrementally
3. Test service in isolation first
4. Integrate with minimal code changes
5. Verify everything still works

## 4. Example Progression

```yaml
# Step 1: Current minimal setup works
# Step 2: Add just the service
services:
  existing-app:
    # ...
  
  new-service:
    image: service:latest
    # minimal config only

# Step 3: Connect and test
# Step 4: Add production configs later
```

Remember: Each service adds complexity. Only add when the benefit is clear!