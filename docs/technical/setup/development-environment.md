# Development Environment Setup

This guide provides comprehensive instructions for setting up the {{PROJECT_NAME}} development environment.

## Prerequisites

### Required Software

1. **{{PRIMARY_LANGUAGE}} Runtime** ({{MIN_VERSION}} or higher)
   ```bash
   # Install via package manager (recommended)
   # For Node.js:
   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
   nvm install {{NODE_VERSION}}
   nvm use {{NODE_VERSION}}
   
   # For Python:
   pyenv install {{PYTHON_VERSION}}
   pyenv local {{PYTHON_VERSION}}
   
   # For other languages, use appropriate version managers
   ```

2. **Docker Desktop** (if using containers)
   - Download from [Docker Desktop](https://www.docker.com/products/docker-desktop)
   - Ensure Docker Compose is included (v2.0+)

3. **{{DATABASE_TYPE}} Tools**
   ```bash
   # Example for various database types:
   # PostgreSQL
   brew install postgresql
   
   # MySQL
   brew install mysql
   
   # MongoDB
   brew tap mongodb/brew
   brew install mongodb-community-shell mongodb-database-tools
   
   # Redis
   brew install redis
   ```

4. **{{ADDITIONAL_TOOLS}}**
   - {{TOOL_1}} for {{PURPOSE_1}}
   - {{TOOL_2}} for {{PURPOSE_2}}

### Development Tools

1. **Git**
   ```bash
   # macOS
   brew install git

   # Linux
   sudo apt-get install git
   
   # Windows
   # Download from https://git-scm.com/
   ```

2. **IDE/Editor** (recommended)
   - VS Code: [code.visualstudio.com](https://code.visualstudio.com/)
   - {{ALTERNATIVE_IDE}}: {{IDE_LINK}}

## Step-by-Step Setup Instructions

### 1. Clone the Repository

```bash
git clone {{REPOSITORY_URL}}
cd {{PROJECT_DIRECTORY}}
```

### 2. Install Dependencies

```bash
# For Node.js projects
npm install

# For Python projects
pip install -r requirements.txt
# or with Poetry
poetry install

# For Go projects
go mod download

# For other languages, use appropriate package managers
```

### 3. Environment Variable Setup

Create a `.env` file in the project root:

```bash
cp .env.template .env
```

Edit `.env` with your configuration:

```env
# Application
{{APP_ENV}}=development
PORT={{DEFAULT_PORT}}
LOG_LEVEL=debug

# Database Connection
{{DB_CONNECTION_VAR}}={{DB_CONNECTION_STRING}}
{{DB_NAME_VAR}}={{DB_NAME}}

# External Service Configuration (if applicable)
{{SERVICE_HOST}}={{SERVICE_URL}}
{{SERVICE_PORT}}={{SERVICE_PORT_NUMBER}}
{{SERVICE_AUTH}}={{AUTH_METHOD}}

# Security
{{SECRET_KEY_VAR}}={{DEV_SECRET}}
{{ENCRYPTION_KEY_VAR}}={{DEV_ENCRYPTION_KEY}}

# Feature Flags
{{FEATURE_FLAG_1}}=true
{{FEATURE_FLAG_2}}=false

# Additional Configuration
{{CONFIG_VAR_1}}={{CONFIG_VALUE_1}}
{{CONFIG_VAR_2}}={{CONFIG_VALUE_2}}
```

### 4. Database Setup

#### Option A: Docker Compose (Recommended for local development)

Create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  {{database_service}}:
    image: {{database_image}}:{{database_version}}
    container_name: {{project_name}}-{{database_type}}-local
    restart: unless-stopped
    ports:
      - "{{host_port}}:{{container_port}}"
    environment:
      {{DB_ENV_VAR_1}}: {{DB_ENV_VALUE_1}}
      {{DB_ENV_VAR_2}}: {{DB_ENV_VALUE_2}}
      {{DB_ENV_VAR_3}}: {{DB_ENV_VALUE_3}}
    volumes:
      - {{database_type}}_data:/data
      - ./scripts/db-init:/docker-entrypoint-initdb.d
    networks:
      - {{project_name}}-network

  {{optional_service}}:
    image: {{service_image}}:{{service_version}}
    container_name: {{project_name}}-{{service_name}}
    restart: unless-stopped
    ports:
      - "{{service_port}}:{{service_internal_port}}"
    environment:
      {{SERVICE_CONFIG}}: {{SERVICE_VALUE}}
    depends_on:
      - {{database_service}}
    networks:
      - {{project_name}}-network

volumes:
  {{database_type}}_data:

networks:
  {{project_name}}-network:
    driver: bridge
```

Start services:

```bash
docker-compose up -d
```

#### Option B: Direct Installation

```bash
# Install database locally
# For macOS
brew install {{database_package}}
brew services start {{database_service}}

# For Linux
sudo apt-get install {{database_package}}
sudo systemctl start {{database_service}}
sudo systemctl enable {{database_service}}
```

### 5. IDE Configuration

#### VS Code Setup

1. Install recommended extensions:

Create `.vscode/extensions.json`:

```json
{
  "recommendations": [
    "{{language_extension}}",
    "{{formatter_extension}}",
    "{{linter_extension}}",
    "ms-azuretools.vscode-docker",
    "{{database_extension}}",
    "humao.rest-client",
    "streetsidesoftware.code-spell-checker",
    "wayou.vscode-todo-highlight",
    "gruntfuggly.todo-tree",
    "eamodio.gitlens",
    "{{additional_extensions}}"
  ]
}
```

2. Configure VS Code settings:

Create `.vscode/settings.json`:

```json
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true
  },
  "editor.defaultFormatter": "{{formatter_extension}}",
  "[{{language}}]": {
    "editor.defaultFormatter": "{{language_formatter}}"
  },
  "{{language}}.{{setting}}": "{{value}}",
  "files.exclude": {
    "**/.git": true,
    "**/.DS_Store": true,
    "**/node_modules": true,
    "**/__pycache__": true,
    "**/.env.local": true
  },
  "search.exclude": {
    "**/node_modules": true,
    "**/dist": true,
    "**/build": true,
    "**/coverage": true,
    "**/.venv": true
  }
}
```

3. Configure debugging:

Create `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "{{debugger_type}}",
      "request": "launch",
      "name": "Debug Application",
      "{{language_specific_config}}": "{{config_value}}",
      "program": "${workspaceFolder}/{{entry_point}}",
      "env": {
        "{{ENV_VAR}}": "development"
      },
      "envFile": "${workspaceFolder}/.env",
      "console": "integratedTerminal"
    },
    {
      "type": "{{debugger_type}}",
      "request": "launch",
      "name": "Debug Tests",
      "{{test_runner_config}}": "{{test_config_value}}",
      "args": ["{{test_args}}"],
      "console": "integratedTerminal",
      "env": {
        "{{ENV_VAR}}": "test"
      }
    }
  ]
}
```

### 6. Git Configuration

Configure Git hooks:

```bash
# Install git hooks manager (e.g., husky for Node.js projects)
{{HOOKS_INSTALL_COMMAND}}

# Add pre-commit hook
{{PRE_COMMIT_HOOK_COMMAND}}

# Add commit message hook
{{COMMIT_MSG_HOOK_COMMAND}}
```

Configure `.gitconfig`:

```bash
git config --local user.name "Your Name"
git config --local user.email "your-email@example.com"
git config --local core.autocrlf input
git config --local pull.rebase true
```

### 7. First Run Verification

1. **Start required services**:
   ```bash
   # If using Docker
   docker-compose up -d
   
   # If using local services
   {{SERVICE_START_COMMAND}}
   ```

2. **Verify database connection**:
   ```bash
   # Test database connection
   {{DB_TEST_COMMAND}}
   ```

3. **Run development server**:
   ```bash
   {{DEV_SERVER_COMMAND}}
   ```

4. **Run tests**:
   ```bash
   {{TEST_COMMAND}}
   ```

5. **Check application health**:
   ```bash
   {{HEALTH_CHECK_COMMAND}}
   ```

## Environment Health Check

Run the health check script to verify your setup:

```bash
{{HEALTH_CHECK_SCRIPT}}
```

This will check:
- Runtime version
- Required packages
- Database connectivity
- Service availability
- Environment variables
- File permissions
- External dependencies

## Next Steps

1. Review the [Quick Start Guide](./quick-start.md)
2. Load sample data: `{{SEED_COMMAND}}`
3. Review the [Project Overview](../../README.md)
4. Check out a starter task from the [Task Board](../../tasks/tracking/current-sprint.md)

## Troubleshooting

### Common Issues

#### {{ISSUE_1_TITLE}}
**Problem**: {{ISSUE_1_DESCRIPTION}}
**Solution**: 
```bash
{{ISSUE_1_SOLUTION}}
```

#### {{ISSUE_2_TITLE}}
**Problem**: {{ISSUE_2_DESCRIPTION}}
**Solution**: 
```bash
{{ISSUE_2_SOLUTION}}
```

#### Database Connection Issues
**Problem**: Cannot connect to database
**Solution**: 
1. Check if database service is running
2. Verify connection string in `.env`
3. Check firewall/network settings
4. Review database logs

#### Port Conflicts
**Problem**: Port already in use
**Solution**: 
```bash
# Find process using the port
lsof -i :{{PORT}}
# Kill the process or change port in .env
```

## Additional Resources

- [{{LANGUAGE}} Documentation]({{LANGUAGE_DOCS_URL}})
- [{{DATABASE}} Documentation]({{DATABASE_DOCS_URL}})
- [Docker Documentation](https://docs.docker.com/)
- [Project Wiki]({{WIKI_URL}})

For additional help, refer to the [Troubleshooting Guide](./troubleshooting-guide.md) or contact the development team.