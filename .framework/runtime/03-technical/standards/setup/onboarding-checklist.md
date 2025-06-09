# New Developer Onboarding Checklist

Welcome to the Nexus MCP Research Database team! This checklist ensures you have everything needed to start contributing effectively.

## Pre-Onboarding (Day -1)

### Account Access Setup

- [ ] **GitHub Access**
  - [ ] Added to organization: `your-org`
  - [ ] Added to team: `nexus-mcp-developers`
  - [ ] Repository access: `nexus_mcp_rd_mongo`
  - [ ] Two-factor authentication enabled

- [ ] **Communication Channels**
  - [ ] Slack workspace access
  - [ ] Added to channels:
    - [ ] #nexus-mcp-dev
    - [ ] #nexus-mcp-support
    - [ ] #engineering-general
  - [ ] Email added to team distribution list

- [ ] **Development Resources**
  - [ ] Jira/Linear account created
  - [ ] Confluence/Notion access granted
  - [ ] AWS/Cloud console access (if needed)
  - [ ] MongoDB Atlas access (read-only initially)

## Day 1: Environment Setup

### Local Development Environment

- [ ] **Development Machine Setup**
  - [ ] Install required software (see [Development Environment](./development-environment.md))
  - [ ] Configure Git with name and email
  - [ ] Generate SSH keys for GitHub
  - [ ] Install recommended IDE (VS Code)

- [ ] **Project Setup**
  - [ ] Clone repository
  - [ ] Run quick setup script: `./scripts/quick-setup.sh`
  - [ ] Verify setup: `npm run health:check`
  - [ ] Successfully run: `npm test`

- [ ] **Security Setup**
  - [ ] Receive SSH credentials for MongoDB tunnel
  - [ ] Configure SSH config file
  - [ ] Test SSH tunnel connection
  - [ ] Install and configure VPN client (if required)

### Initial Verification

- [ ] **Basic Operations**
  - [ ] Start development server: `npm run dev`
  - [ ] Access local MongoDB via Compass
  - [ ] Run MCP tool tests: `npm run mcp:test`
  - [ ] Load sample data: `npm run db:seed:all`

## Day 2-3: Documentation Review

### Required Reading

- [ ] **Project Documentation**
  - [ ] [Project README](../../../README.md)
  - [ ] [CLAUDE.md](../../../CLAUDE.md) - AI assistant guidelines
  - [ ] [Architecture Overview](../../architecture/README.md)
  - [ ] [API Documentation](../../api/README.md)

- [ ] **Process Documentation**
  - [ ] [PRD Guide](../../prd/README.md)
  - [ ] [Task Management Guide](../../tasks/README.md)
  - [ ] [Quick Reference - PRDs](../../prd/QUICK_REFERENCE.md)
  - [ ] [Quick Reference - Tasks](../../tasks/QUICK_REFERENCE.md)

- [ ] **Technical Documentation**
  - [ ] [MongoDB Schema Documentation](../../database/schemas/README.md)
  - [ ] [MCP Tools Documentation](../../mcp/tools/README.md)
  - [ ] [Testing Guide](../../testing/README.md)
  - [ ] [Deployment Guide](../../deployment/README.md)

### Domain Knowledge

- [ ] **CMP (Central Monitoring Platform) Overview**
  - [ ] Read CMP product documentation
  - [ ] Understand key concepts:
    - [ ] Clinical trials
    - [ ] Statistical analysis
    - [ ] Signals and actions
    - [ ] Data anomaly detection
  - [ ] Review glossary of terms

- [ ] **MongoDB Collections**
  - [ ] Understand core collections:
    - [ ] Organizations
    - [ ] Users
    - [ ] Datasets
    - [ ] Variables
    - [ ] Signals
    - [ ] Actions
  - [ ] Review relationships between collections

## Day 4-5: Hands-On Learning

### Code Exploration

- [ ] **Repository Structure**
  - [ ] Explore source code organization
  - [ ] Understand module dependencies
  - [ ] Review configuration files
  - [ ] Identify key entry points

- [ ] **Run Example Workflows**
  - [ ] Query organizations via MCP
  - [ ] Find users by organization
  - [ ] Retrieve dataset metadata
  - [ ] Search for signals
  - [ ] List actions on signals

### First Contributions

- [ ] **Starter Tasks** (choose one):
  - [ ] Add unit tests for an existing function
  - [ ] Fix a documentation typo
  - [ ] Improve error messages
  - [ ] Add JSDoc comments to undocumented functions
  - [ ] Create a simple MCP tool

- [ ] **Development Workflow**
  - [ ] Create feature branch
  - [ ] Make changes
  - [ ] Run tests locally
  - [ ] Create pull request
  - [ ] Address code review feedback
  - [ ] Merge first PR! 🎉

## Week 2: Deeper Integration

### Advanced Setup

- [ ] **Development Tools**
  - [ ] Set up debugging configuration
  - [ ] Configure performance profiling tools
  - [ ] Install additional VS Code extensions
  - [ ] Set up personal development scripts

- [ ] **Team Processes**
  - [ ] Attend sprint planning meeting
  - [ ] Participate in daily standup
  - [ ] Join code review rotation
  - [ ] Attend architecture discussion

### Project Contribution

- [ ] **Take on a Real Task**
  - [ ] Review current sprint tasks
  - [ ] Discuss task assignment with team lead
  - [ ] Create/update task documentation
  - [ ] Implement solution
  - [ ] Write comprehensive tests
  - [ ] Document changes

## Ongoing Learning

### Technical Skills

- [ ] **MCP (Model Context Protocol)**
  - [ ] Complete MCP tutorials
  - [ ] Build a custom MCP tool
  - [ ] Understand MCP server architecture
  - [ ] Learn about MCP client integration

- [ ] **MongoDB Advanced Topics**
  - [ ] Aggregation pipelines
  - [ ] Index optimization
  - [ ] Transaction handling
  - [ ] Performance tuning

### Team Integration

- [ ] **Knowledge Sharing**
  - [ ] Document something you learned
  - [ ] Present at team knowledge sharing session
  - [ ] Pair program with team members
  - [ ] Contribute to team retrospectives

## Resources and Contacts

### Key Contacts

| Role | Name | Slack | Expertise |
|------|------|-------|-----------|
| Team Lead | TBD | @teamlead | Architecture, Planning |
| Tech Lead | TBD | @techlead | Technical Decisions |
| MCP Expert | TBD | @mcpexpert | MCP Protocol |
| MongoDB Expert | TBD | @mongoexpert | Database, Performance |
| DevOps Lead | TBD | @devops | Infrastructure, Deployment |

### Useful Links

- **Internal**
  - Project Wiki: `https://wiki.company.com/nexus-mcp`
  - Sprint Board: `https://jira.company.com/nexus-mcp`
  - Design Docs: `https://docs.company.com/nexus-mcp`

- **External**
  - [MCP Documentation](https://modelcontextprotocol.io)
  - [MongoDB Documentation](https://docs.mongodb.com)
  - [TypeScript Handbook](https://www.typescriptlang.org/docs)
  - [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)

### Getting Help

1. **Stuck on setup?**
   - Check [Troubleshooting Guide](./troubleshooting-guide.md)
   - Ask in #nexus-mcp-dev with error details
   - Schedule pairing session with team member

2. **Don't understand something?**
   - Search internal wiki first
   - Ask in Slack (no question is too small!)
   - Request a knowledge transfer session

3. **Found a bug?**
   - Check if it's already reported
   - Create detailed bug report
   - Discuss priority with team lead

## Onboarding Feedback

After your first two weeks, please:

- [ ] Complete onboarding feedback survey
- [ ] Suggest improvements to this checklist
- [ ] Share what was helpful/challenging
- [ ] Update documentation based on your experience

## Quick Commands Reference

```bash
# Daily development
npm run dev                 # Start development server
npm run test:watch         # Run tests in watch mode
npm run tunnel:start       # Start SSH tunnel

# Debugging
npm run health:check       # Check environment health
npm run db:ping           # Test database connection
npm run logs:tail         # Tail application logs

# Data management
npm run db:seed:all       # Load all sample data
npm run db:export         # Export current data
npm run db:clean          # Clean database

# Code quality
npm run lint:fix          # Fix linting issues
npm run format            # Format code
npm run type-check        # Check TypeScript types
```

Welcome to the team! We're excited to have you contribute to the Nexus MCP Research Database project. 🚀