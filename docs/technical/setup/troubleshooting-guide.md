# Troubleshooting Guide

This guide helps you resolve common issues when setting up and developing with the Nexus MCP Research Database.

## Table of Contents

- [Setup Issues](#setup-issues)
- [SSH Tunnel Connection Problems](#ssh-tunnel-connection-problems)
- [MongoDB Authentication Issues](#mongodb-authentication-issues)
- [Docker Networking Problems](#docker-networking-problems)
- [Permission Issues](#permission-issues)
- [Environment Variable Conflicts](#environment-variable-conflicts)
- [Debug Logging Setup](#debug-logging-setup)
- [Common Runtime Errors](#common-runtime-errors)

## Setup Issues

### Node.js Version Mismatch

**Problem**: `Error: The module was compiled against a different Node.js version`

**Solution**:
```bash
# Check current Node version
node --version

# Clear npm cache
npm cache clean --force

# Rebuild native dependencies
npm rebuild

# Or reinstall all dependencies
rm -rf node_modules package-lock.json
npm install
```

### Package Installation Failures

**Problem**: `npm install` fails with permission errors or network issues

**Solutions**:

1. **Permission errors**:
   ```bash
   # Don't use sudo with npm, instead fix npm permissions
   mkdir ~/.npm-global
   npm config set prefix '~/.npm-global'
   echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
   source ~/.bashrc
   ```

2. **Network issues**:
   ```bash
   # Use a different registry
   npm config set registry https://registry.npmjs.org/
   
   # Or use proxy if behind corporate firewall
   npm config set proxy http://proxy.company.com:8080
   npm config set https-proxy http://proxy.company.com:8080
   ```

3. **Clear corrupted cache**:
   ```bash
   npm cache clean --force
   rm -rf ~/.npm
   ```

### TypeScript Compilation Errors

**Problem**: `Cannot find module` or type errors

**Solutions**:

```bash
# Ensure TypeScript is installed
npm install --save-dev typescript @types/node

# Reset TypeScript cache
rm -rf node_modules/.cache/typescript
npx tsc --build --clean

# Verify tsconfig.json
npx tsc --showConfig
```

## SSH Tunnel Connection Problems

### SSH Key Permissions

**Problem**: `Permissions 0644 for '/home/user/.ssh/id_rsa' are too open`

**Solution**:
```bash
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
chmod 700 ~/.ssh
```

### SSH Connection Refused

**Problem**: `ssh: connect to host xxx port 22: Connection refused`

**Solutions**:

1. **Check SSH service**:
   ```bash
   # Test basic SSH connection
   ssh -v username@hostname
   
   # Check if port 22 is open
   nc -zv hostname 22
   ```

2. **Use alternative port**:
   ```bash
   # If SSH is on a different port
   ssh -p 2222 username@hostname
   ```

3. **Check firewall/VPN**:
   - Ensure you're connected to VPN if required
   - Check local firewall settings
   - Verify IP whitelisting on server

### SSH Tunnel Drops Frequently

**Problem**: SSH tunnel disconnects after a period of inactivity

**Solution**:

1. **Add keep-alive settings** to `~/.ssh/config`:
   ```
   Host nexus-mongo-tunnel
       HostName your-ssh-host.com
       User your-username
       ServerAliveInterval 60
       ServerAliveCountMax 3
       TCPKeepAlive yes
   ```

2. **Use autossh for persistent tunnels**:
   ```bash
   # Install autossh
   brew install autossh  # macOS
   sudo apt-get install autossh  # Linux
   
   # Start persistent tunnel
   autossh -M 0 -N -L 27018:localhost:27017 username@hostname
   ```

### Multiple SSH Tunnels Conflict

**Problem**: `bind: Address already in use`

**Solution**:
```bash
# Find processes using the port
lsof -ti:27018

# Kill existing tunnels
pkill -f "ssh.*27018:localhost:27017"

# Or kill specific process
kill -9 $(lsof -ti:27018)
```

## MongoDB Authentication Issues

### Authentication Failed

**Problem**: `MongoServerError: Authentication failed`

**Solutions**:

1. **Verify credentials**:
   ```bash
   # Test connection with mongosh
   mongosh "mongodb://username:password@localhost:27017/database?authSource=admin"
   ```

2. **Check auth database**:
   ```javascript
   // In mongosh
   use admin
   db.auth('username', 'password')
   ```

3. **Reset local MongoDB password**:
   ```bash
   # Stop MongoDB
   docker-compose stop mongodb
   
   # Start without auth
   docker run -d --name mongo-temp -p 27017:27017 mongo:6.0 --noauth
   
   # Connect and create user
   mongosh
   use admin
   db.createUser({
     user: "admin",
     pwd: "newpassword",
     roles: ["root"]
   })
   ```

### Connection Timeout

**Problem**: `MongoNetworkTimeoutError: connection timed out`

**Solutions**:

1. **Increase connection timeout**:
   ```javascript
   // In connection string
   mongodb://localhost:27017/database?connectTimeoutMS=30000&socketTimeoutMS=30000
   ```

2. **Check MongoDB is running**:
   ```bash
   # Docker
   docker ps | grep mongo
   docker logs nexus-mongodb-local
   
   # System service
   sudo systemctl status mongod
   ```

### SSL/TLS Certificate Issues

**Problem**: `MongoServerSelectionError: self signed certificate`

**Solutions**:

1. **Disable SSL for development**:
   ```javascript
   // In connection options
   {
     tls: false,
     tlsAllowInvalidCertificates: true
   }
   ```

2. **Add certificate**:
   ```bash
   # Add to connection string
   mongodb://localhost:27017/database?tls=true&tlsCAFile=/path/to/ca.pem
   ```

## Docker Networking Problems

### Container Cannot Connect to Host

**Problem**: MongoDB container cannot be accessed from host

**Solutions**:

1. **Check port mapping**:
   ```bash
   docker port nexus-mongodb-local
   # Should show: 27017/tcp -> 0.0.0.0:27017
   ```

2. **Use host network mode** (Linux only):
   ```yaml
   # In docker-compose.yml
   services:
     mongodb:
       network_mode: host
   ```

3. **Check Docker network**:
   ```bash
   docker network ls
   docker network inspect nexus-network
   ```

### Containers Cannot Communicate

**Problem**: Application container cannot connect to MongoDB container

**Solution**:
```yaml
# Ensure both containers are on same network
services:
  app:
    networks:
      - nexus-network
    depends_on:
      - mongodb
    
  mongodb:
    networks:
      - nexus-network

networks:
  nexus-network:
    driver: bridge
```

### Docker Disk Space Issues

**Problem**: `no space left on device`

**Solution**:
```bash
# Clean up Docker
docker system prune -a --volumes

# Check disk usage
docker system df

# Remove unused images
docker image prune -a

# Remove unused volumes
docker volume prune
```

## Permission Issues

### File Permission Denied

**Problem**: Cannot read/write files

**Solutions**:

1. **Fix file permissions**:
   ```bash
   # Make scripts executable
   chmod +x scripts/*.sh
   
   # Fix directory permissions
   chmod 755 src tests docs
   
   # Fix file permissions
   find . -type f -name "*.ts" -exec chmod 644 {} \;
   ```

2. **Check file ownership**:
   ```bash
   # Change ownership
   sudo chown -R $(whoami):$(whoami) .
   ```

### Docker Socket Permission Denied

**Problem**: `Got permission denied while trying to connect to the Docker daemon socket`

**Solution**:
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Apply changes (logout/login or run)
newgrp docker

# Verify
docker run hello-world
```

## Environment Variable Conflicts

### Variables Not Loading

**Problem**: Environment variables from `.env` not available

**Solutions**:

1. **Check .env file location**:
   ```bash
   # Should be in project root
   ls -la .env
   ```

2. **Verify dotenv is loaded**:
   ```typescript
   // At the top of your entry file
   import dotenv from 'dotenv';
   dotenv.config();
   
   // Debug loaded variables
   console.log('Loaded env:', process.env.NODE_ENV);
   ```

3. **Check for typos**:
   ```bash
   # Common issues:
   # - Spaces around = sign
   # - Quotes in values
   # - Windows line endings
   
   # Fix line endings
   dos2unix .env
   ```

### Variable Override Issues

**Problem**: System variables overriding .env file

**Solution**:
```bash
# Check current environment
env | grep MONGODB

# Unset conflicting variables
unset MONGODB_URI

# Or use .env.local for overrides
# Load order: .env -> .env.local -> environment
```

## Debug Logging Setup

### Enable Debug Logging

1. **Application-wide debug**:
   ```bash
   # In .env
   LOG_LEVEL=debug
   DEBUG=*
   
   # Or via command line
   DEBUG=* npm run dev
   ```

2. **MongoDB driver debug**:
   ```javascript
   // In MongoDB connection
   const client = new MongoClient(uri, {
     loggerLevel: 'debug',
     logger: (msg, context) => {
       console.log(`[MONGO ${context?.commandName}]`, msg);
     }
   });
   ```

3. **MCP debug logging**:
   ```typescript
   // In MCP server setup
   import { Logger } from '@modelcontextprotocol/sdk';
   
   const logger = new Logger({
     level: 'debug',
     handler: (level, message, context) => {
       console.log(`[MCP ${level}]`, message, context);
     }
   });
   ```

### Structured Logging

```typescript
// Setup winston for better logging
import winston from 'winston';

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  transports: [
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.simple()
      )
    }),
    new winston.transports.File({ 
      filename: 'logs/error.log', 
      level: 'error' 
    }),
    new winston.transports.File({ 
      filename: 'logs/combined.log' 
    })
  ]
});
```

## Common Runtime Errors

### Memory Leaks

**Symptoms**: Increasing memory usage, eventual crash

**Debugging**:
```bash
# Monitor memory usage
node --inspect dist/index.js

# Take heap snapshots
# In Chrome DevTools: Memory tab -> Take snapshot

# Use clinic.js
clinic heap -- node dist/index.js
```

**Common causes**:
- Unclosed MongoDB connections
- Event listener accumulation
- Large arrays/objects kept in memory

### Event Loop Blocking

**Symptoms**: Slow response times, timeouts

**Debugging**:
```bash
# Monitor event loop
clinic doctor -- node dist/index.js

# Add event loop monitoring
npm install --save event-loop-stats
```

```typescript
import eventLoopStats from 'event-loop-stats';

setInterval(() => {
  console.log('Event loop stats:', eventLoopStats.sense());
}, 5000);
```

### Unhandled Promise Rejections

**Problem**: `UnhandledPromiseRejectionWarning`

**Solution**:
```typescript
// Global handlers
process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
  // Application specific logging, throwing an error, or other logic here
});

process.on('uncaughtException', (error) => {
  console.error('Uncaught Exception:', error);
  process.exit(1);
});

// Better: Always use try-catch or .catch()
async function main() {
  try {
    await riskyOperation();
  } catch (error) {
    logger.error('Operation failed:', error);
  }
}
```

## Getting Help

If you're still experiencing issues:

1. **Check logs**:
   ```bash
   # Application logs
   tail -f logs/combined.log
   
   # Docker logs
   docker logs -f nexus-mongodb-local
   
   # System logs
   journalctl -u mongod -f
   ```

2. **Run diagnostics**:
   ```bash
   npm run diagnostics
   ```

3. **Create minimal reproduction**:
   - Isolate the problem
   - Create minimal test case
   - Document steps to reproduce

4. **Contact team**:
   - Post in #nexus-mcp-dev Slack channel
   - Include error messages, logs, and steps to reproduce
   - Tag relevant team members for urgent issues