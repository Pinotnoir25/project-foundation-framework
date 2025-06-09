# Generate Project Scripts Prompt

Use this prompt to generate customized setup and health check scripts for your project based on the templates in `/scripts/templates/`.

## Prompt Template

```
I need to generate setup scripts for my project. Please analyze my requirements and create customized scripts based on the templates in /scripts/templates/.

Project Details:
- Project Name: [Your project name]
- Primary Language: [nodejs/python/go/rust/other]
- Package Manager: [npm/yarn/pip/poetry/cargo/go mod/other]
- Database Type: [mongodb/postgresql/mysql/redis/none/multiple]
- Container Runtime: [docker/podman/none]
- MCP Integration: [yes/no]

Technical Requirements:
- Minimum Language Version: [e.g., Node.js 18+, Python 3.9+]
- Required CLI Tools: [list tools like git, ssh, aws-cli, etc.]
- Optional Tools: [list nice-to-have tools]
- Key Environment Variables: [list critical env vars]

Infrastructure Needs:
- Docker Services: [list services like database, cache, message queue]
- External Dependencies: [APIs, SSH tunnels, cloud services]
- Development Ports: [list ports your app will use]

Project Structure:
- Key Directories: [src, dist, logs, etc.]
- Configuration Files: [.env, config.json, etc.]
- Build Output: [where compiled/built files go]

Development Workflow:
- Build Command: [how to build the project]
- Test Command: [how to run tests]
- Start Command: [how to start in dev mode]
- Git Hooks Needed: [pre-commit, pre-push checks]

Please generate:
1. check-prerequisites.sh - Customized prerequisite checker
2. quick-setup.sh - Automated setup script
3. health-check.[js/py] - Health check script in appropriate language
4. docker-compose.yml - If Docker is required
5. .env.example - Template environment file

Additional Customizations:
[Any specific requirements or special cases]
```

## Example Usage

### Node.js MCP Server with MongoDB

```
I need to generate setup scripts for my project. Please analyze my requirements and create customized scripts based on the templates in /scripts/templates/.

Project Details:
- Project Name: Nexus MCP Research Database
- Primary Language: nodejs
- Package Manager: npm
- Database Type: mongodb
- Container Runtime: docker
- MCP Integration: yes

Technical Requirements:
- Minimum Language Version: Node.js 18+
- Required CLI Tools: git, ssh, docker, mongosh
- Optional Tools: code (VS Code), mongodb-compass
- Key Environment Variables: NODE_ENV, PORT, MONGODB_URI, SSH_HOST, SSH_USERNAME

Infrastructure Needs:
- Docker Services: MongoDB (v6.0), Mongo Express
- External Dependencies: SSH tunnel to remote MongoDB
- Development Ports: 3000 (app), 27017 (mongodb), 8081 (mongo-express)

Project Structure:
- Key Directories: src, dist, logs, coverage, .vscode
- Configuration Files: .env, tsconfig.json, package.json
- Build Output: dist/

Development Workflow:
- Build Command: npm run build (TypeScript compilation)
- Test Command: npm test
- Start Command: npm run dev
- Git Hooks Needed: pre-commit (lint, type-check)

Please generate all scripts with proper error handling and clear user guidance.
```

### Python Data Science Project

```
I need to generate setup scripts for my project. Please analyze my requirements and create customized scripts based on the templates in /scripts/templates/.

Project Details:
- Project Name: ML Pipeline Processor
- Primary Language: python
- Package Manager: pip
- Database Type: postgresql
- Container Runtime: docker
- MCP Integration: no

Technical Requirements:
- Minimum Language Version: Python 3.9+
- Required CLI Tools: git, docker, psql
- Optional Tools: jupyter, tensorboard
- Key Environment Variables: DATABASE_URL, MODEL_PATH, API_KEY

Infrastructure Needs:
- Docker Services: PostgreSQL (v14), pgAdmin, Redis
- External Dependencies: S3 bucket access, GPU support
- Development Ports: 8000 (api), 5432 (postgres), 6379 (redis)

Project Structure:
- Key Directories: src, models, data, notebooks, tests
- Configuration Files: .env, requirements.txt, setup.py
- Build Output: dist/, models/

Development Workflow:
- Build Command: python setup.py build
- Test Command: pytest
- Start Command: python -m src.main
- Git Hooks Needed: pre-commit (black, flake8, pytest)

Additional Customizations:
- Need GPU detection in health check
- Virtual environment setup required
- Data directory size check (minimum 10GB free)
```

## Customization Guidelines

When using this prompt:

1. **Be Specific**: Provide exact version numbers and tool names
2. **List All Services**: Include all Docker containers needed
3. **Environment Variables**: List all required and optional env vars
4. **Ports**: Specify all ports to avoid conflicts
5. **Special Requirements**: Mention any unique setup needs

## Output Expectations

The generated scripts will:
- Use your project-specific values in place of templates
- Include only relevant sections for your tech stack
- Provide clear error messages and recovery steps
- Follow platform-specific conventions (bash for Unix, consideration for Windows)
- Include helpful comments and documentation

## Post-Generation Steps

After scripts are generated:

1. Review and adjust any project-specific details
2. Make scripts executable: `chmod +x scripts/*.sh`
3. Test the prerequisite checker first
4. Run the setup script in a clean environment
5. Verify the health check catches common issues
6. Commit the customized scripts to your repository

## Template Variables Reference

See `/scripts/README.md` for a complete list of available template variables and conditional blocks that can be customized.