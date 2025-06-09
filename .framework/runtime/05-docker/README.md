# Docker Runtime - Progressive Containerization

This directory follows the "start small, build as needed" philosophy for Docker configurations.

## Directory Structure

```
05-docker/
├── templates/           # Docker templates by complexity
├── prompts/            # AI prompts for Docker setup
├── scripts/            # Build scripts with cache prevention
├── docker-standards.md # Framework Docker guidelines
└── README.md          # This file
```

## Quick Start

1. **Begin Minimal**: Start with `dockerfile-minimal` or `dockerfile-python-minimal`
2. **Build Properly**: Always use `--no-cache` flag or provided scripts
3. **Add As Needed**: Only add services when you have a specific need

## Templates (By Progression)

### 1. Minimal Starting Points
- `dockerfile-minimal` - Basic Node.js container (7 lines)
- `dockerfile-python-minimal` - Basic Python container (7 lines)
- `dockerfile-frontend-minimal` - Frontend with cache prevention
- `docker-compose-minimal.yml` - Single service setup

### 2. Adding Services
- `docker-compose-with-db.yml` - App + Database
- `docker-compose-with-cache.yml` - App + Database + Redis

### 3. Optimization (When Needed)
- `dockerfile-multistage` - For size/security optimization
- `dockerfile-*-comprehensive` - Full featured examples

### 4. Frontend Specific
- `dockerfile-react` - React with cache prevention
- `dockerfile-vue` - Vue.js with cache prevention  
- `dockerfile-nextjs` - Next.js with cache prevention

## Build Scripts

Always use these scripts to ensure proper builds:

```bash
# Build with no cache (required for frontend)
./scripts/build-no-cache.sh myapp

# Clean everything and rebuild
./scripts/clean-build.sh
```

## Important: Cache Prevention

**MANDATORY** for all builds, especially frontend:
```bash
docker build --no-cache -t myapp .
```

This prevents stale assets and build artifacts from being cached.

## Usage Flow

1. Start with minimal template
2. Test it works
3. Only add complexity when needed
4. Use progressive templates
5. Always build with --no-cache

## Philosophy

- Complexity is easy to add, hard to remove
- Start with the minimum viable container
- Add services only when solving real problems
- Measure before optimizing
- Document why complexity was added