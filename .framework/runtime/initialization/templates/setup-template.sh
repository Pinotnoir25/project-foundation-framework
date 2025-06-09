#!/bin/bash

# {{PROJECT_NAME}} - Quick Setup Script
# This script automates the initial setup process for new developers
# Generated from template for {{PRIMARY_LANGUAGE}} project

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_step() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}!${NC} $1"
}

check_command() {
    if command -v $1 &> /dev/null; then
        print_success "$1 is installed"
        return 0
    else
        print_error "$1 is not installed"
        return 1
    fi
}

# Header
echo "=================================================="
echo "{{PROJECT_NAME}} - Quick Setup"
echo "=================================================="
echo ""

# Step 1: Check prerequisites
print_step "Checking prerequisites..."

MISSING_DEPS=0

{{#if_language_nodejs}}
# Check Node.js
if check_command node; then
    NODE_VERSION=$(node --version | cut -d 'v' -f 2)
    REQUIRED_VERSION="{{NODE_MIN_VERSION}}"
    if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$NODE_VERSION" | sort -V | head -n1)" = "$REQUIRED_VERSION" ]; then
        print_success "Node.js version $NODE_VERSION meets requirements"
    else
        print_error "Node.js version $NODE_VERSION is below required version $REQUIRED_VERSION"
        MISSING_DEPS=1
    fi
else
    MISSING_DEPS=1
fi
{{/if_language_nodejs}}

{{#if_language_python}}
# Check Python
if check_command python3; then
    PYTHON_VERSION=$(python3 --version | awk '{print $2}')
    print_success "Python $PYTHON_VERSION is installed"
else
    MISSING_DEPS=1
fi
{{/if_language_python}}

{{#if_language_go}}
# Check Go
if check_command go; then
    GO_VERSION=$(go version | awk '{print $3}')
    print_success "Go $GO_VERSION is installed"
else
    MISSING_DEPS=1
fi
{{/if_language_go}}

{{#if_language_rust}}
# Check Rust
if check_command rustc; then
    RUST_VERSION=$(rustc --version | awk '{print $2}')
    print_success "Rust $RUST_VERSION is installed"
else
    MISSING_DEPS=1
fi
{{/if_language_rust}}

# Check other required dependencies
{{#each REQUIRED_COMMANDS}}
check_command {{this}} || MISSING_DEPS=1
{{/each}}

if [ $MISSING_DEPS -eq 1 ]; then
    print_error "Missing prerequisites. Please install required software first."
    echo "Run ./scripts/check-prerequisites.sh for detailed information"
    exit 1
fi

# Step 2: Install dependencies
print_step "Installing {{PRIMARY_LANGUAGE}} dependencies..."

{{#if_language_nodejs}}
{{PACKAGE_MANAGER}} install
{{/if_language_nodejs}}

{{#if_language_python}}
# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    python3 -m venv venv
    print_success "Created virtual environment"
fi

# Activate virtual environment
source venv/bin/activate

# Install dependencies
{{PACKAGE_MANAGER}} install -r requirements.txt
{{/if_language_python}}

{{#if_language_go}}
go mod download
{{/if_language_go}}

{{#if_language_rust}}
cargo fetch
{{/if_language_rust}}

# Step 3: Install development tools
print_step "Installing development tools..."

{{#if_language_nodejs}}
{{#each GLOBAL_TOOLS}}
{{../PACKAGE_MANAGER}} install -g {{this}}
{{/each}}
{{/if_language_nodejs}}

{{#if_language_python}}
{{#each GLOBAL_TOOLS}}
{{../PACKAGE_MANAGER}} install {{this}}
{{/each}}
{{/if_language_python}}

# Step 4: Setup environment file
print_step "Setting up environment configuration..."
if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        cp .env.example .env
        print_success "Created .env file from template"
        print_warning "Please edit .env file with your configuration"
    else
        print_warning ".env.example not found, creating basic .env file"
        cat > .env << 'EOF'
# Application
NODE_ENV=development
{{#each ENV_VARIABLES}}
{{key}}={{default_value}}
{{/each}}
EOF
        print_success "Created basic .env file"
        print_warning "You must update settings in .env file"
    fi
else
    print_success ".env file already exists"
fi

{{#if_docker_required}}
# Step 5: Setup Docker
print_step "Setting up Docker containers..."
if [ -f docker-compose.yml ]; then
    {{DOCKER_COMPOSE_COMMAND}} up -d
    print_success "Docker containers started"
else
    print_warning "docker-compose.yml not found"
    {{#if_create_docker_compose}}
    print_step "Creating docker-compose.yml..."
    cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
{{#each DOCKER_SERVICES}}
  {{name}}:
    image: {{image}}
    container_name: {{container_name}}
    restart: unless-stopped
    ports:
{{#each ports}}
      - "{{this}}"
{{/each}}
    environment:
{{#each environment}}
      {{key}}: {{value}}
{{/each}}
{{#if volumes}}
    volumes:
{{#each volumes}}
      - {{this}}
{{/each}}
{{/if}}
{{#if depends_on}}
    depends_on:
{{#each depends_on}}
      - {{this}}
{{/each}}
{{/if}}
    networks:
      - {{../PROJECT_NETWORK}}

{{/each}}
{{#if_volumes_needed}}
volumes:
{{#each DOCKER_VOLUMES}}
  {{this}}:
{{/each}}
{{/if_volumes_needed}}

networks:
  {{PROJECT_NETWORK}}:
    driver: bridge
EOF
    {{DOCKER_COMPOSE_COMMAND}} up -d
    print_success "Created docker-compose.yml and started containers"
    {{/if_create_docker_compose}}
fi

# Wait for services to be ready
{{#each DOCKER_SERVICES}}
{{#if health_check}}
print_step "Waiting for {{name}} to be ready..."
for i in {1..30}; do
    if {{health_check}}; then
        print_success "{{name}} is ready"
        break
    fi
    if [ $i -eq 30 ]; then
        print_error "{{name}} failed to start in time"
        exit 1
    fi
    echo -n "."
    sleep 1
done
echo ""
{{/if}}
{{/each}}
{{/if_docker_required}}

# Step 6: Create necessary directories
print_step "Creating project directories..."
{{#each PROJECT_DIRECTORIES}}
mkdir -p {{this}}
{{/each}}
print_success "Directories created"

{{#if_git_hooks}}
# Step 7: Setup Git hooks
print_step "Setting up Git hooks..."
if [ -d .git ]; then
    mkdir -p .git/hooks
    
    # Pre-commit hook
    cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
# Pre-commit hook
echo "Running pre-commit checks..."
{{#each GIT_HOOKS.pre_commit}}
{{this}}
{{/each}}
EOF
    chmod +x .git/hooks/pre-commit
    
    {{#if GIT_HOOKS.pre_push}}
    # Pre-push hook
    cat > .git/hooks/pre-push << 'EOF'
#!/bin/bash
# Pre-push hook
echo "Running pre-push checks..."
{{#each GIT_HOOKS.pre_push}}
{{this}}
{{/each}}
EOF
    chmod +x .git/hooks/pre-push
    {{/if}}
    
    print_success "Git hooks configured"
else
    print_warning "Not a git repository, skipping git hooks"
fi
{{/if_git_hooks}}

# Step 8: Run initial build/compile
print_step "Running initial build..."

{{#if_language_nodejs}}
if [ -f tsconfig.json ]; then
    npx tsc || print_warning "TypeScript build failed - this is OK for initial setup"
else
    print_warning "No TypeScript configuration found"
fi
{{/if_language_nodejs}}

{{#if_language_python}}
# Compile Python files
python3 -m compileall . || print_warning "Python compilation warnings"
{{/if_language_python}}

{{#if_language_go}}
go build ./... || print_warning "Go build failed - this is OK for initial setup"
{{/if_language_go}}

{{#if_language_rust}}
cargo build || print_warning "Rust build failed - this is OK for initial setup"
{{/if_language_rust}}

# Step 9: Run health check
print_step "Running health check..."
if [ -f scripts/health-check.{{SCRIPT_EXTENSION}} ]; then
    {{HEALTH_CHECK_COMMAND}}
else
    print_warning "No health check script found"
fi

# Final summary
echo ""
echo "=================================================="
echo "Setup Complete!"
echo "=================================================="
echo ""
print_success "Environment is ready for development"
echo ""
echo "Next steps:"
{{#each NEXT_STEPS}}
echo "{{@index}}. {{this}}"
{{/each}}
echo ""
echo "For more information, see:"
{{#each DOCUMENTATION_LINKS}}
echo "- {{this}}"
{{/each}}
echo ""