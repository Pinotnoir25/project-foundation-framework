#!/bin/bash

# Nexus MCP Research Database - Quick Setup Script
# This script automates the initial setup process for new developers

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
echo "Nexus MCP Research Database - Quick Setup"
echo "=================================================="
echo ""

# Step 1: Check prerequisites
print_step "Checking prerequisites..."

MISSING_DEPS=0

# Check Node.js
if check_command node; then
    NODE_VERSION=$(node --version | cut -d 'v' -f 2)
    REQUIRED_VERSION="18.0.0"
    if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$NODE_VERSION" | sort -V | head -n1)" = "$REQUIRED_VERSION" ]; then
        print_success "Node.js version $NODE_VERSION meets requirements"
    else
        print_error "Node.js version $NODE_VERSION is below required version $REQUIRED_VERSION"
        MISSING_DEPS=1
    fi
else
    MISSING_DEPS=1
fi

# Check other dependencies
for cmd in git docker ssh mongosh; do
    check_command $cmd || MISSING_DEPS=1
done

if [ $MISSING_DEPS -eq 1 ]; then
    print_error "Missing prerequisites. Please install required software first."
    echo "See docs/technical/setup/development-environment.md for details"
    exit 1
fi

# Step 2: Install Node.js dependencies
print_step "Installing Node.js dependencies..."
npm install

# Step 3: Install global tools
print_step "Installing global development tools..."
npm install -g typescript ts-node nodemon @modelcontextprotocol/sdk

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
PORT=3000
LOG_LEVEL=debug

# MongoDB Connection
MONGODB_URI=mongodb://localhost:27017/nexus_research
MONGODB_DB_NAME=nexus_research

# SSH Tunnel Configuration (UPDATE THESE)
SSH_HOST=your-ssh-host.com
SSH_PORT=22
SSH_USERNAME=your-username
SSH_KEY_PATH=~/.ssh/id_rsa
SSH_PASSPHRASE=

# MongoDB via SSH
MONGODB_REMOTE_HOST=localhost
MONGODB_REMOTE_PORT=27017
LOCAL_MONGODB_PORT=27018

# MCP Server Configuration
MCP_SERVER_NAME=nexus-mcp-research
MCP_SERVER_VERSION=1.0.0

# Security
JWT_SECRET=dev-jwt-secret-change-in-production
ENCRYPTION_KEY=dev-encryption-key-change-in-production
EOF
        print_success "Created basic .env file"
        print_warning "You must update SSH settings in .env file"
    fi
else
    print_success ".env file already exists"
fi

# Step 5: Setup Docker
print_step "Setting up Docker containers..."
if [ -f docker-compose.yml ]; then
    docker-compose up -d
    print_success "Docker containers started"
else
    print_warning "docker-compose.yml not found, creating it..."
    cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  mongodb:
    image: mongo:6.0
    container_name: nexus-mongodb-local
    restart: unless-stopped
    ports:
      - "27017:27017"
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: localdev123
      MONGO_INITDB_DATABASE: nexus_research
    volumes:
      - mongodb_data:/data/db
    networks:
      - nexus-network

  mongo-express:
    image: mongo-express:latest
    container_name: nexus-mongo-express
    restart: unless-stopped
    ports:
      - "8081:8081"
    environment:
      ME_CONFIG_MONGODB_ADMINUSERNAME: admin
      ME_CONFIG_MONGODB_ADMINPASSWORD: localdev123
      ME_CONFIG_MONGODB_URL: mongodb://admin:localdev123@mongodb:27017/
      ME_CONFIG_BASICAUTH_USERNAME: admin
      ME_CONFIG_BASICAUTH_PASSWORD: admin123
    depends_on:
      - mongodb
    networks:
      - nexus-network

volumes:
  mongodb_data:

networks:
  nexus-network:
    driver: bridge
EOF
    docker-compose up -d
    print_success "Created docker-compose.yml and started containers"
fi

# Step 6: Wait for MongoDB to be ready
print_step "Waiting for MongoDB to be ready..."
for i in {1..30}; do
    if docker exec nexus-mongodb-local mongosh --eval "db.adminCommand('ping')" &> /dev/null; then
        print_success "MongoDB is ready"
        break
    fi
    if [ $i -eq 30 ]; then
        print_error "MongoDB failed to start in time"
        exit 1
    fi
    echo -n "."
    sleep 1
done
echo ""

# Step 7: Create necessary directories
print_step "Creating project directories..."
mkdir -p logs
mkdir -p dist
mkdir -p coverage
mkdir -p .vscode
print_success "Directories created"

# Step 8: Setup Git hooks
print_step "Setting up Git hooks..."
if [ -d .git ]; then
    mkdir -p .git/hooks
    cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
# Pre-commit hook
echo "Running pre-commit checks..."
npm run lint
npm run type-check
EOF
    chmod +x .git/hooks/pre-commit
    print_success "Git hooks configured"
else
    print_warning "Not a git repository, skipping git hooks"
fi

# Step 9: Run initial build
print_step "Running initial TypeScript build..."
if [ -f tsconfig.json ]; then
    npx tsc || print_warning "TypeScript build failed - this is OK for initial setup"
else
    print_warning "tsconfig.json not found, skipping build"
fi

# Step 10: Health check
print_step "Running health check..."
cat > scripts/health-check.js << 'EOF'
const { MongoClient } = require('mongodb');

async function checkHealth() {
    console.log('🏥 Running health check...\n');
    
    // Check Node.js version
    const nodeVersion = process.version;
    console.log(`✓ Node.js ${nodeVersion}`);
    
    // Check environment variables
    const requiredEnvVars = ['NODE_ENV', 'PORT', 'MONGODB_URI'];
    let envOk = true;
    for (const envVar of requiredEnvVars) {
        if (process.env[envVar]) {
            console.log(`✓ ${envVar} is set`);
        } else {
            console.log(`✗ ${envVar} is not set`);
            envOk = false;
        }
    }
    
    // Check MongoDB connection
    if (process.env.MONGODB_URI) {
        try {
            const client = new MongoClient(process.env.MONGODB_URI);
            await client.connect();
            await client.db().admin().ping();
            console.log('✓ MongoDB connection successful');
            await client.close();
        } catch (error) {
            console.log('✗ MongoDB connection failed:', error.message);
        }
    }
    
    console.log('\n🎉 Health check complete!');
}

require('dotenv').config();
checkHealth().catch(console.error);
EOF

node scripts/health-check.js

# Final summary
echo ""
echo "=================================================="
echo "Setup Complete!"
echo "=================================================="
echo ""
print_success "Environment is ready for development"
echo ""
echo "Next steps:"
echo "1. Update SSH settings in .env file"
echo "2. Run: npm run dev"
echo "3. Visit: http://localhost:3000"
echo "4. MongoDB Express: http://localhost:8081"
echo ""
echo "For more information, see:"
echo "- docs/technical/setup/quick-start.md"
echo "- docs/technical/setup/development-environment.md"
echo ""