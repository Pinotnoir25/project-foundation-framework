# Quick Start Guide

Get up and running with Nexus MCP Research Database in under 5 minutes.

## Prerequisites Check

```bash
# Run this command to check all prerequisites
curl -sSL https://raw.githubusercontent.com/your-org/nexus_mcp_rd_mongo/main/scripts/check-prerequisites.sh | bash
```

## One-Command Setup

### macOS/Linux

```bash
# Clone and setup in one command
git clone git@github.com:your-org/nexus_mcp_rd_mongo.git && \
cd nexus_mcp_rd_mongo && \
./scripts/quick-setup.sh
```

### Windows (PowerShell)

```powershell
# Clone and setup
git clone git@github.com:your-org/nexus_mcp_rd_mongo.git
cd nexus_mcp_rd_mongo
.\scripts\quick-setup.ps1
```

## Manual Quick Setup

If the automated script fails, follow these steps:

### 1. Clone Repository

```bash
git clone git@github.com:your-org/nexus_mcp_rd_mongo.git
cd nexus_mcp_rd_mongo
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Setup Environment

```bash
# Copy environment template
cp .env.template .env

# Edit .env with your favorite editor
# At minimum, set:
# - SSH_HOST
# - SSH_USERNAME
# - SSH_KEY_PATH
```

### 4. Start Development Environment

```bash
# Start all services
npm run dev:all

# This runs:
# - Docker MongoDB container
# - SSH tunnel to remote MongoDB
# - MCP server in watch mode
# - Test watcher
```

## Minimal Setup for Immediate Development

### Local MongoDB Only (No SSH Tunnel)

```bash
# Start local MongoDB
docker run -d --name nexus-mongo \
  -p 27017:27017 \
  -e MONGO_INITDB_ROOT_USERNAME=admin \
  -e MONGO_INITDB_ROOT_PASSWORD=localdev123 \
  mongo:6.0

# Update .env
echo "MONGODB_URI=mongodb://admin:localdev123@localhost:27017/nexus_research" >> .env

# Start development
npm run dev
```

### Using Remote MongoDB

```bash
# Setup SSH tunnel
ssh -N -L 27018:localhost:27017 username@ssh-host.com &

# Update .env
echo "MONGODB_URI=mongodb://localhost:27018/nexus_research" >> .env

# Start development
npm run dev
```

## Health Check Commands

### Check Everything

```bash
npm run health:check
```

### Individual Checks

```bash
# Check Node.js setup
node --version  # Should be >= 18.0.0

# Check MongoDB connection
npm run db:ping

# Check MCP server
npm run mcp:test

# Check SSH tunnel
npm run tunnel:status
```

## Sample Data Loading

### Load All Sample Data

```bash
npm run db:seed:all
```

### Load Specific Collections

```bash
# Load organizations
npm run db:seed:organizations

# Load users
npm run db:seed:users

# Load datasets
npm run db:seed:datasets

# Load signals
npm run db:seed:signals
```

## Quick Verification Tests

### 1. Test MongoDB Connection

```bash
npm run test:db:connection
```

Expected output:
```
✓ MongoDB connection established
✓ Database 'nexus_research' accessible
✓ Collections found: 5
```

### 2. Test MCP Server

```bash
npm run test:mcp:basic
```

Expected output:
```
✓ MCP server started
✓ Tools registered: 12
✓ Test query executed successfully
```

### 3. Run Smoke Tests

```bash
npm run test:smoke
```

This runs a minimal test suite to verify:
- Database connectivity
- Basic CRUD operations
- MCP tool registration
- API endpoints

## Common Development Commands

```bash
# Start development server
npm run dev

# Run tests
npm test

# Run specific test file
npm test -- --testPathPattern=connection

# Build project
npm run build

# Lint code
npm run lint

# Format code
npm run format

# Type check
npm run type-check
```

## VS Code Quick Setup

1. Open project in VS Code:
   ```bash
   code .
   ```

2. Install recommended extensions:
   - Press `Cmd+Shift+P` (Mac) or `Ctrl+Shift+P` (Windows/Linux)
   - Type "Extensions: Show Recommended Extensions"
   - Click "Install All"

3. Start debugging:
   - Press `F5` to start debugging
   - Select "Debug MCP Server" configuration

## Common Troubleshooting

### MongoDB Connection Failed

```bash
# Check if MongoDB is running
docker ps | grep mongo

# Restart MongoDB
docker restart nexus-mongo

# Check logs
docker logs nexus-mongo
```

### SSH Tunnel Issues

```bash
# Kill existing tunnel
pkill -f "ssh.*27018:localhost:27017"

# Start tunnel with verbose mode
ssh -v -N -L 27018:localhost:27017 username@ssh-host.com
```

### Permission Denied

```bash
# Fix script permissions
chmod +x scripts/*.sh

# Fix SSH key permissions
chmod 600 ~/.ssh/id_rsa
```

### Port Already in Use

```bash
# Find process using port
lsof -ti:3000 | xargs kill -9

# Or change port in .env
PORT=3001
```

## Next Steps

1. **Explore the API**: Open http://localhost:3000/api-docs
2. **Try MCP Tools**: Run `npm run mcp:playground`
3. **Review PRDs**: Check `docs/prd/features/`
4. **Pick a Task**: See `docs/tasks/tracking/current-sprint.md`

## Getting Help

- Check [Troubleshooting Guide](./troubleshooting-guide.md)
- Review [Development Environment Setup](./development-environment.md)
- Ask in team Slack channel: #nexus-mcp-dev