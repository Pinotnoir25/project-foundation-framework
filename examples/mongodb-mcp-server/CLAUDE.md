# CLAUDE.md - MongoDB MCP Server Example

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This project implements an MCP (Model Context Protocol) server that enables Nexus LLM to interact with a Research MongoDB database containing metadata from an eclinical solution called Central Monitoring Platform (CMP).

### About CMP
CMP is designed to analyze clinical trial data using statistical methods to identify potential data anomalies and document these findings as signals, allowing users to take actions on these signals. The analysis involves:
- Loading and transforming trial data
- Selecting and executing statistical methods on datasets and variables
- Managing signals and actions resulting from the analysis
- User management across pharmaceutical organizations with role-based permissions

### About MongoDB
The MongoDB database contains CMP metadata (not the trial data or statistical results):
- Dataset and variable definitions
- Organizations and users
- Signals and actions
- Statistical method configurations
- Audit trails

**Important**: The database is only accessible via SSH tunnel for security.

## Current Status

**Status**: Planning Phase

When starting development:
1. Review existing PRDs in `docs/prd/features/` for MongoDB Connection Manager
2. Check task breakdowns in `docs/tasks/features/` for implementation steps
3. Load project context from `.project/context/project.json`
4. Reference the glossary in `.project/context/glossary.md` for CMP terminology

## Project-Specific Guidelines

- All database connections must use SSH tunneling
- Implement proper authentication for multi-tenant access
- Follow HIPAA compliance for healthcare data
- Use TypeScript for MCP server implementation
- Implement comprehensive audit logging

## Technical Stack

- **Primary Language**: TypeScript
- **Framework**: MCP SDK for Node.js
- **Database**: MongoDB
- **Infrastructure**: Docker containers on AWS

## Development Commands

```bash
# Setup
npm install
npm run setup:ssh-tunnel

# Build
npm run build
npm run build:watch

# Test
npm test
npm run test:integration

# Run
npm run dev
npm run start
```

## Key Integration Points

- Nexus LLM via MCP protocol
- MongoDB via SSH tunnel
- Authentication service for user management
- Audit service for compliance logging

## Important Notes

- Never expose database credentials in code
- All PHI data must be encrypted at rest and in transit
- Follow pharmaceutical industry compliance (21 CFR Part 11)
- Implement role-based access control (RBAC)
- Maintain detailed audit trails for all operations

---

*This example demonstrates how the Project Foundation Framework can be customized for a specific healthcare/pharmaceutical project.*