# Tooling Setup Guide

This guide covers the installation and configuration of all development tools required for the Nexus MCP Research Database project.

## Required CLI Tools

### 1. Node.js Tools

```bash
# Package managers
npm install -g yarn pnpm

# Build tools
npm install -g typescript ts-node tsx
npm install -g @swc/core @swc/cli  # Fast TypeScript compiler

# Development utilities
npm install -g nodemon concurrently wait-on
npm install -g npm-check-updates  # Update dependencies
npm install -g npkill  # Clean node_modules
```

### 2. MCP SDK Setup

```bash
# Install MCP SDK globally
npm install -g @modelcontextprotocol/sdk

# Install MCP CLI tools
npm install -g @modelcontextprotocol/cli

# Verify installation
mcp --version
mcp-sdk --version
```

#### MCP Development Tools

```bash
# MCP server scaffolding tool
npm install -g create-mcp-server

# MCP debugging tools
npm install -g @modelcontextprotocol/inspector
npm install -g @modelcontextprotocol/test-harness
```

### 3. MongoDB Tools

#### MongoDB Shell (mongosh)

```bash
# macOS
brew install mongosh

# Linux (Ubuntu/Debian)
wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
sudo apt-get update
sudo apt-get install -y mongodb-mongosh

# Windows (via Chocolatey)
choco install mongodb-shell
```

#### MongoDB Compass (GUI)

Download from: https://www.mongodb.com/products/compass

Configuration for SSH tunnel:
1. Open Compass
2. Click "New Connection"
3. Select "Advanced Connection Options"
4. Go to "SSH Tunnel" tab
5. Configure:
   - SSH Hostname: your-ssh-host.com
   - SSH Port: 22
   - SSH Username: your-username
   - SSH Identity File: ~/.ssh/id_rsa

#### MongoDB Database Tools

```bash
# macOS
brew install mongodb-database-tools

# Linux
sudo apt-get install mongodb-database-tools

# Tools included:
# - mongodump: Export data
# - mongorestore: Import data
# - mongoexport: Export to JSON/CSV
# - mongoimport: Import from JSON/CSV
# - mongostat: Real-time stats
# - mongotop: Track read/write activity
```

### 4. Testing Framework Setup

#### Jest Configuration

```bash
# Install Jest and related packages
npm install --save-dev jest @types/jest ts-jest
npm install --save-dev @jest/globals jest-extended
npm install --save-dev jest-mongodb @shelf/jest-mongodb
```

Create `jest.config.js`:

```javascript
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/src', '<rootDir>/tests'],
  testMatch: ['**/__tests__/**/*.ts', '**/?(*.)+(spec|test).ts'],
  transform: {
    '^.+\\.ts$': 'ts-jest',
  },
  collectCoverageFrom: [
    'src/**/*.ts',
    '!src/**/*.d.ts',
    '!src/**/*.test.ts',
    '!src/**/__tests__/**',
  ],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80,
    },
  },
  setupFilesAfterEnv: ['<rootDir>/tests/setup.ts'],
  globalSetup: '<rootDir>/tests/global-setup.ts',
  globalTeardown: '<rootDir>/tests/global-teardown.ts',
};
```

#### Testing Utilities

```bash
# API testing
npm install --save-dev supertest @types/supertest

# Mocking
npm install --save-dev jest-mock-extended
npm install --save-dev mongodb-memory-server

# Assertions
npm install --save-dev chai @types/chai chai-as-promised

# Test data generation
npm install --save-dev @faker-js/faker
npm install --save-dev factory.ts
```

### 5. Linting and Formatting Tools

#### ESLint Setup

```bash
# Install ESLint
npm install --save-dev eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin

# Additional plugins
npm install --save-dev eslint-plugin-import eslint-plugin-jest
npm install --save-dev eslint-plugin-promise eslint-plugin-security
npm install --save-dev eslint-config-prettier eslint-plugin-prettier
```

Create `.eslintrc.json`:

```json
{
  "parser": "@typescript-eslint/parser",
  "parserOptions": {
    "ecmaVersion": 2022,
    "sourceType": "module",
    "project": "./tsconfig.json"
  },
  "plugins": [
    "@typescript-eslint",
    "import",
    "jest",
    "promise",
    "security"
  ],
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "plugin:@typescript-eslint/recommended-requiring-type-checking",
    "plugin:import/errors",
    "plugin:import/warnings",
    "plugin:import/typescript",
    "plugin:jest/recommended",
    "plugin:promise/recommended",
    "plugin:security/recommended",
    "prettier"
  ],
  "rules": {
    "@typescript-eslint/explicit-function-return-type": "warn",
    "@typescript-eslint/no-explicit-any": "error",
    "@typescript-eslint/no-unused-vars": ["error", { "argsIgnorePattern": "^_" }],
    "import/order": ["error", {
      "groups": ["builtin", "external", "internal", "parent", "sibling", "index"],
      "newlines-between": "always"
    }],
    "no-console": ["warn", { "allow": ["warn", "error"] }]
  },
  "env": {
    "node": true,
    "jest": true
  }
}
```

#### Prettier Setup

```bash
npm install --save-dev prettier
```

Create `.prettierrc.json`:

```json
{
  "semi": true,
  "trailingComma": "all",
  "singleQuote": true,
  "printWidth": 100,
  "tabWidth": 2,
  "useTabs": false,
  "arrowParens": "always",
  "endOfLine": "lf"
}
```

Create `.prettierignore`:

```
node_modules
dist
coverage
.next
.cache
public
*.min.js
*.min.css
```

#### Commit Linting

```bash
# Install commitlint
npm install --save-dev @commitlint/cli @commitlint/config-conventional

# Install commitizen for interactive commits
npm install --save-dev commitizen cz-conventional-changelog
```

Create `commitlint.config.js`:

```javascript
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [
      2,
      'always',
      [
        'feat',
        'fix',
        'docs',
        'style',
        'refactor',
        'test',
        'chore',
        'perf',
        'ci',
        'build',
        'revert',
      ],
    ],
  },
};
```

### 6. Debugging Tools Configuration

#### VS Code Debugging

Already configured in `.vscode/launch.json` (see development-environment.md)

#### Node.js Inspector

```bash
# Debug with Chrome DevTools
node --inspect-brk dist/index.js

# Debug with specific port
node --inspect=9229 dist/index.js

# Debug TypeScript directly
node --require ts-node/register --inspect-brk src/index.ts
```

#### MongoDB Profiling

```bash
# Enable profiling in mongosh
use nexus_research
db.setProfilingLevel(2)  # Log all operations

# View profile data
db.system.profile.find().limit(5).sort({ ts: -1 }).pretty()

# Analyze slow queries
db.system.profile.find({ millis: { $gt: 100 } }).pretty()
```

### 7. Performance Profiling Tools

#### Node.js Profiling

```bash
# Install clinic.js
npm install -g clinic

# CPU profiling
clinic doctor -- node dist/index.js

# Memory profiling
clinic bubbleprof -- node dist/index.js

# Install 0x for flame graphs
npm install -g 0x
0x dist/index.js
```

#### MongoDB Performance Tools

```bash
# Real-time performance stats
mongostat --host localhost:27017

# Operation tracking
mongotop --host localhost:27017

# Index usage analysis
# In mongosh:
db.collection.aggregate([{ $indexStats: {} }])
```

#### Load Testing

```bash
# Install Artillery for load testing
npm install -g artillery

# Install autocannon for HTTP benchmarking
npm install -g autocannon
```

Create `artillery.yml`:

```yaml
config:
  target: "http://localhost:3000"
  phases:
    - duration: 60
      arrivalRate: 10
      rampTo: 50
  defaults:
    headers:
      Content-Type: "application/json"

scenarios:
  - name: "MCP Query Test"
    flow:
      - post:
          url: "/mcp/query"
          json:
            tool: "find_organizations"
            params:
              limit: 10
```

## IDE Extensions and Plugins

### VS Code Extensions

See `.vscode/extensions.json` in development-environment.md

### JetBrains IDEs (WebStorm/IntelliJ)

1. Install plugins:
   - MongoDB Plugin
   - Node.js
   - Prettier
   - ESLint
   - GitToolBox
   - String Manipulation
   - Rainbow Brackets

2. Configure Node.js interpreter:
   - Preferences → Languages & Frameworks → Node.js
   - Set interpreter path to nvm version

3. Enable ESLint:
   - Preferences → Languages & Frameworks → JavaScript → Code Quality Tools → ESLint
   - Select "Automatic ESLint configuration"

## Package Scripts

Add these helpful scripts to `package.json`:

```json
{
  "scripts": {
    "dev": "nodemon",
    "build": "tsc",
    "start": "node dist/index.js",
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "lint": "eslint . --ext .ts",
    "lint:fix": "eslint . --ext .ts --fix",
    "format": "prettier --write \"**/*.{ts,js,json,md}\"",
    "format:check": "prettier --check \"**/*.{ts,js,json,md}\"",
    "type-check": "tsc --noEmit",
    "clean": "rimraf dist coverage",
    "deps:check": "npm-check-updates",
    "deps:update": "npm-check-updates -u",
    "mongo:start": "docker-compose up -d mongodb",
    "mongo:stop": "docker-compose stop mongodb",
    "tunnel:start": "ssh -N -L 27018:localhost:27017 nexus-mongo-tunnel &",
    "tunnel:stop": "pkill -f 'ssh.*27018:localhost:27017'",
    "profile:cpu": "clinic doctor -- node dist/index.js",
    "profile:memory": "clinic heap -- node dist/index.js",
    "benchmark": "autocannon -c 100 -d 30 http://localhost:3000/health"
  }
}
```

## Tool Configuration Files

### nodemon.json

```json
{
  "watch": ["src"],
  "ext": "ts,json",
  "ignore": ["src/**/*.spec.ts", "src/**/*.test.ts"],
  "exec": "ts-node ./src/index.ts",
  "env": {
    "NODE_ENV": "development"
  }
}
```

### .editorconfig

```ini
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
indent_style = space
indent_size = 2
trim_trailing_whitespace = true

[*.md]
trim_trailing_whitespace = false

[*.{yml,yaml}]
indent_size = 2

[Makefile]
indent_style = tab
```

## Verification

Run this command to verify all tools are installed correctly:

```bash
npm run tools:check
```

This will verify:
- Node.js and npm versions
- TypeScript compiler
- MongoDB tools
- MCP SDK
- Linting tools
- Testing frameworks
- All required global packages