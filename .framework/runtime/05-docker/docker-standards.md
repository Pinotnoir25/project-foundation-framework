# Docker Standards - Framework Guidelines

## Core Principles

### 1. Start Small, Build as Needed
- Begin with minimal containers (5-10 lines)
- Add services only when required
- Complexity is easy to add, hard to remove

### 2. Cache Prevention is Primary
**MANDATORY for all builds:**
```bash
docker build --no-cache -t appname .
```

**For frontend applications:**
```bash
# Always clean build artifacts first
rm -rf dist/ build/ .next/ .nuxt/

# Then build with no cache
docker build --no-cache -t frontend-app .
```

## Development Workflow

### Initial Setup
1. Use `dockerfile-minimal` template
2. Use `docker-compose-minimal.yml` if needed
3. Test thoroughly before adding complexity

### Progressive Enhancement
```
Minimal → Database → Cache → Optimization
```

Only progress when you can answer YES to:
- "Is this solving a real problem?"
- "Have I tested without it?"
- "Is this the simplest solution?"

## Required Practices

### 1. Build Commands
```bash
# ALWAYS use --no-cache
docker build --no-cache -t myapp .

# Or use provided scripts
./scripts/build-no-cache.sh myapp
./scripts/clean-build.sh
```

### 2. Docker Compose
```bash
# Force rebuild everything
docker-compose down -v
docker-compose build --no-cache
docker-compose up
```

### 3. Frontend Specific
- Clear build directories before building
- Never rely on Docker layer caching
- Use frontend-specific templates with cache prevention

## File Organization

### Templates
```
templates/
├── dockerfile-minimal           # Start here
├── dockerfile-frontend-minimal  # Frontend with cache prevention
├── docker-compose-minimal.yml   # Single service
├── docker-compose-with-db.yml   # When persistence needed
└── docker-compose-with-cache.yml # When performance critical
```

### Scripts
```
scripts/
├── build-no-cache.sh   # Enforces --no-cache
└── clean-build.sh      # Removes artifacts + rebuilds
```

## Security Standards

### Minimal Security (Start Here)
- Use official base images
- Don't run as root in production

### Enhanced Security (When Needed)
- Non-root user creation
- Multi-stage builds
- Minimal final images
- Secret management

## Image Guidelines

### Base Image Selection
1. **Default**: Use official language images (node:20, python:3.11)
2. **When size matters**: Switch to alpine variants
3. **When security critical**: Use distroless or scratch

### Layer Optimization (Only When Needed)
- Order commands by change frequency
- Combine RUN commands
- Use .dockerignore
- Clean package caches

## Environment Configuration

### Development
- Mount source code as volumes
- Enable hot reload
- Expose debug ports

### Production (When Ready)
- No source code volumes
- Minimal exposed ports
- Health checks
- Resource limits

## Common Patterns

### Single Application
```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY . .
RUN npm install
CMD ["npm", "start"]
```

### Frontend Application
```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci && npm cache clean --force
COPY . .
RUN rm -rf dist/ build/ && npm run build
CMD ["npm", "start"]
```

### When Database Needed
Only add when persistent storage required:
```yaml
services:
  app:
    build: .
    depends_on:
      - db
  db:
    image: postgres:15-alpine
```

## Anti-Patterns to Avoid

1. **Starting Complex**: Don't begin with full orchestration
2. **Premature Optimization**: Don't optimize without metrics
3. **Cache Reliance**: Never trust cache for frontend builds
4. **Feature Creep**: Don't add services "just in case"

## Debugging Issues

### Build Problems
```bash
# Always start fresh
docker system prune -a
./scripts/clean-build.sh
```

### Frontend Issues
```bash
# Clear everything and rebuild
rm -rf node_modules dist build .next .nuxt
docker build --no-cache -t app .
```

## Remember

- Start with the minimum viable container
- Add complexity only when justified
- Always use --no-cache for builds
- Test each addition thoroughly
- Document why complexity was added

The goal is working software, not perfect containers!