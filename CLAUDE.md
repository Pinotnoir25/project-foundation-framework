# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This project is about an MCP (Model Context Protocol) server that will be used by Nexus LLM to interact with a Research Mongo Database made of collections about various element of an eclinical solution called Central Monitoring Platform (CMP). 

About CMP
Basically, CMP is designed to analyse clinical trial data using statistical methods to identify potential data anomalies and document these findings into signals and allow the user to take actions on these signals. The analysis implies the loading of trial data, its preparation / transformation and the selection of statistical to be executed on datasets and variables. All signals and actions resulting from the analysis are also part of CMP. And just like any eclinical solution platform, it has to manage users who belongs to different pharmaceutical organizations and have different permissions.

About Mongo
MongoDB do not contain the trial data nor the statisical results but it contains all the CMP metadata: datasets and variables names, organizations, users, signals, actions, etc. The database is only accessible via an SSH tunnel.

## Current Status

**Empty Repository**: This repository has just been initialized and contains no code yet. When starting development:

1. Determine the programming language and framework to use
2. Initialize the project with appropriate package manager
3. Set up the basic MCP server/client structure
4. Configure MongoDB connections
5. Create appropriate directory structure

## Product Requirements Documentation (PRD)

This project uses a structured PRD system for feature planning and documentation. Before implementing any feature:

1. **Check for existing PRDs**: Look in `docs/prd/features/` for relevant documentation
2. **Create new PRDs**: Use templates in `docs/prd/templates/` and prompts in `docs/prd/prompts/`
3. **Reference PRDs during development**: Align implementation with documented requirements and success metrics

See `docs/prd/README.md` for the complete PRD guide.

## Task Management System

PRDs are broken down into actionable tasks using our task management system:

1. **Generate tasks from PRD**: Use prompts in `docs/tasks/prompts/` to analyze PRDs and create task breakdowns
2. **Track task progress**: Update task status in `docs/tasks/features/` as work progresses
3. **Sprint planning**: Organize tasks into sprints based on dependencies and priorities
4. **Daily updates**: Use tracking templates in `docs/tasks/tracking/`

Quick commands:
- Generate tasks: `@claude analyze PRD at [path] and create tasks`
- Update status: `@claude mark task T1.1.1 as complete`
- Check progress: `@claude show current sprint status`

See `docs/tasks/README.md` for the complete task management guide.

## Development Notes

Since this is an empty repository, no specific development commands or architecture information is available yet. Future updates to this file should include:

- Build and test commands once the project is set up
- Architecture overview once the code structure is established
- MCP server configuration details
- MongoDB integration patterns used