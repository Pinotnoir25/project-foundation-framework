# Containerization Strategy Prompt

When creating Docker configurations for a project, analyze the following aspects:

## 1. Application Analysis
- Identify the application type (web server, API, worker, database, etc.)
- Determine the runtime/language requirements
- List all dependencies and external services
- Identify build-time vs runtime requirements

## 2. Container Strategy
Decide on containerization approach:
- Single container vs multi-container
- Development vs production configurations
- Multi-stage builds for optimization
- Base image selection criteria

## 3. Security Considerations
- Non-root user setup
- Secret management approach
- Network isolation requirements
- Vulnerability scanning needs

## 4. Performance Optimization
- Layer caching strategies
- Image size optimization
- Build argument usage
- Volume mount strategies

## 5. Orchestration Needs
For docker-compose configurations:
- Service dependencies
- Network configuration
- Volume management
- Environment variable handling
- Health checks and restart policies

## Output Requirements
Based on the analysis, generate:
1. Appropriate Dockerfile(s)
2. docker-compose.yml for local development
3. docker-compose.prod.yml for production (if different)
4. .dockerignore file
5. Environment variable documentation

Consider the project's specific needs and follow Docker best practices for the technology stack.