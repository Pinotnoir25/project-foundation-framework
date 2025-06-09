# [Feature] Docker Architecture

**Created**: [DATE]

## Container Structure

### New Containers
```yaml
service-name:
  build: ./path
  purpose: [What this container does]
  dependencies: [Other services]
```

### Modified Containers
[List existing containers that need changes]

## Service Communication
```
[Container A] --[protocol]--> [Container B]
     |
     v
[Container C]
```

## Volume Mounts
[Only if special volumes needed beyond code]

## Network Configuration
[Only if beyond default bridge network]

## Environment Variables
```yaml
SERVICE_CONFIG:
  - KEY=purpose
  - SECRET_KEY=${SECRET_KEY} # From .env
```

## Resource Limits
[Only if specific constraints needed]

---
*Focus on container architecture decisions. Implementation details belong in docker-compose.yml*