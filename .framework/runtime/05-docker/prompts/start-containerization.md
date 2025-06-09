# Start Containerization Prompt

When beginning Docker setup for a project, follow the "start small, build as needed" approach:

## 1. Start with the Minimal Setup

Begin with the simplest possible container:
- Use `dockerfile-minimal` template
- Use `docker-compose-minimal.yml` if compose is needed
- Focus on getting the app running first

## 2. Initial Questions

Ask yourself:
- What is the minimum required to run this app?
- Can it run with just the runtime and code?
- Do I need any services right now?

## 3. Build Command

ALWAYS use --no-cache for initial builds:
```bash
docker build --no-cache -t myapp .
```

Or use the provided script:
```bash
./scripts/build-no-cache.sh myapp
```

## 4. Test the Minimal Setup

Before adding complexity:
1. Build the minimal container
2. Run it and verify it works
3. Check logs for any issues
4. Only then consider what else is needed

## 5. Common Progressions

Only add when actually needed:
- Database: Use `docker-compose-with-db.yml` when data persistence required
- Caching: Use `docker-compose-with-cache.yml` when performance matters
- Multi-stage: Use `dockerfile-multistage` when image size/security critical

Remember: It's easier to add complexity than remove it. Start minimal!