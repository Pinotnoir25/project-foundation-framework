# Scripts Template System

This directory contains generic, template-based scripts that can be customized for any project. These templates use a placeholder system to generate project-specific scripts based on your technology stack and requirements.

## Overview

The template system allows you to:
- Generate customized setup scripts for different programming languages
- Create prerequisite checkers tailored to your tech stack
- Produce health check scripts that verify your specific environment
- Adapt to various databases, tools, and frameworks

## Directory Structure

```
scripts/
├── templates/          # Generic template scripts
│   ├── check-prerequisites-template.sh
│   ├── setup-template.sh
│   ├── health-check-template.js
│   └── health-check-template.py
└── README.md          # This file
```

## Template Placeholders

Templates use double-brace notation for placeholders:

### Core Placeholders

- `{{PROJECT_NAME}}` - Your project's display name
- `{{PRIMARY_LANGUAGE}}` - Main programming language (nodejs, python, go, rust)
- `{{PACKAGE_MANAGER}}` - Package manager (npm, yarn, pip, cargo, etc.)
- `{{DATABASE_TYPE}}` - Database system (mongodb, postgresql, mysql, none)
- `{{SCRIPT_EXTENSION}}` - File extension for scripts (js, py, sh, etc.)

### Language-Specific Placeholders

#### Node.js
- `{{NODE_MIN_VERSION}}` - Minimum Node.js version (e.g., "18.0.0")
- `{{NODE_MAJOR_VERSION}}` - Major version number (e.g., 18)
- `{{PACKAGE_MANAGER_INSTALL}}` - How to install the package manager

#### Python
- `{{PYTHON_MIN_VERSION}}` - Minimum Python version (e.g., "3.9.0")
- `{{PYTHON_MAJOR}}` - Major version (e.g., 3)
- `{{PYTHON_MINOR}}` - Minor version (e.g., 9)

#### Go
- `{{GO_MIN_VERSION}}` - Minimum Go version (e.g., "1.19")

#### Rust
- `{{RUST_MIN_VERSION}}` - Minimum Rust version (e.g., "1.70.0")

### Infrastructure Placeholders

- `{{DOCKER_SERVICES}}` - Array of Docker service definitions
- `{{DOCKER_COMPOSE_COMMAND}}` - docker-compose or docker compose
- `{{PROJECT_NETWORK}}` - Docker network name
- `{{REQUIRED_TOOLS}}` - Array of required command-line tools
- `{{OPTIONAL_TOOLS}}` - Array of optional but recommended tools

### Environment Placeholders

- `{{ENV_VARIABLES}}` - Array of environment variable definitions
- `{{REQUIRED_ENV_VARS}}` - Array of required environment variable names
- `{{REQUIRED_DIRECTORIES}}` - Directories that must exist
- `{{REQUIRED_FILES}}` - Files that must exist

### Conditional Blocks

Templates support conditional sections:

```bash
{{#if_language_nodejs}}
# Node.js specific content
{{/if_language_nodejs}}

{{#if_docker_required}}
# Docker-related setup
{{/if_docker_required}}

{{#if_database_mongodb}}
# MongoDB-specific checks
{{/if_database_mongodb}}
```

## Using the Template System

### 1. Generate Scripts Using the Initialization Prompt

Use the provided initialization prompt to generate customized scripts:

```bash
# Example: Generate scripts for a Node.js project with MongoDB
@claude Please generate setup scripts for a Node.js project using MongoDB and Docker
```

### 2. Manual Customization

You can also manually customize templates:

1. Copy the template to your project
2. Replace placeholders with your values
3. Remove unnecessary conditional sections
4. Add project-specific customizations

### 3. Example Configuration

Here's an example configuration for a Node.js MCP server project:

```json
{
  "PROJECT_NAME": "My MCP Server",
  "PRIMARY_LANGUAGE": "nodejs",
  "PACKAGE_MANAGER": "npm",
  "NODE_MIN_VERSION": "18.0.0",
  "NODE_MAJOR_VERSION": 18,
  "DATABASE_TYPE": "mongodb",
  "DOCKER_SERVICES": [
    {
      "name": "mongodb",
      "image": "mongo:6.0",
      "container_name": "my-mongodb",
      "ports": ["27017:27017"],
      "environment": {
        "MONGO_INITDB_ROOT_USERNAME": "admin",
        "MONGO_INITDB_ROOT_PASSWORD": "password"
      }
    }
  ],
  "REQUIRED_ENV_VARS": ["NODE_ENV", "PORT", "MONGODB_URI"],
  "PROJECT_DIRECTORIES": ["logs", "dist", "coverage"],
  "REQUIRED_TOOLS": ["git", "docker", "mongosh"]
}
```

## Script Templates

### check-prerequisites-template.sh

Checks if all required software is installed:
- Programming language runtime and version
- Package managers
- Database clients
- Docker and Docker Compose
- SSH configuration
- Optional development tools

### setup-template.sh

Automates the initial project setup:
- Verifies prerequisites
- Installs dependencies
- Sets up environment configuration
- Starts Docker containers
- Creates necessary directories
- Configures Git hooks
- Runs initial build
- Performs health check

### health-check-template.js / health-check-template.py

Verifies the development environment:
- Runtime version check
- Environment variable validation
- File system verification
- Database connectivity
- Docker service status
- Dependency installation check
- Custom health checks

## Extending the Templates

To add support for new languages or tools:

1. Add new placeholder definitions
2. Create conditional blocks for the new technology
3. Add relevant checks and setup steps
4. Document the new placeholders in this README

## Examples

For real-world examples of generated scripts, see:
- `examples/mongodb-mcp-server/scripts/` - Scripts for a MongoDB MCP server project

## Best Practices

1. **Keep templates generic** - Avoid project-specific logic in templates
2. **Use meaningful placeholders** - Make placeholder names self-explanatory
3. **Document dependencies** - List all tools and versions clearly
4. **Provide sensible defaults** - Include reasonable default values
5. **Test generated scripts** - Verify scripts work across different environments
6. **Version compatibility** - Handle version checking gracefully

## Initialization Prompt

To generate customized scripts for your project, use the following prompt template:

```
Please generate setup scripts for a {{LANGUAGE}} project with the following specifications:
- Project name: {{PROJECT_NAME}}
- Database: {{DATABASE_TYPE}}
- Docker services needed: {{LIST_SERVICES}}
- Required tools: {{LIST_TOOLS}}
- Key environment variables: {{LIST_ENV_VARS}}
```

The system will analyze your requirements and generate appropriate scripts based on the templates in this directory.