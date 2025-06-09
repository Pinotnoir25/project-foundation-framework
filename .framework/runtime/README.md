# Framework Runtime

This directory contains materials that **Claude uses during execution** to generate documents, analyze requirements, and follow technical standards. These files are not typically read by humans directly.

## Directory Structure

### Lifecycle-Based Organization
Runtime materials are organized by project lifecycle order, with numbered prefixes indicating the natural flow:

### Themes (in order of use)

#### `01-context/`
Project context management (First: Set up project context)
- **Prompts**: How to update state, document decisions, extract glossary terms
- **Templates**: project.json, current-state.md, decisions.md, glossary.md

#### `02-prd/`
Product Requirements Documentation (Second: Define what to build)
- **Prompts**: How to analyze requirements, identify users, define metrics
- **Templates**: PRD document structures

#### `03-technical/`
Technical specifications and standards (Third: Specify how to build)
- **Prompts**: How to design APIs, create test plans, define infrastructure
- **Templates**: Technical specification documents (TAD, API design, test specs)
- **Standards**: Subdirectory containing API patterns, security requirements, infrastructure guidelines

#### `04-tasks/`
Task breakdown and sprint planning (Fourth: Plan the work)
- **Prompts**: How to decompose PRDs into tasks, estimate effort
- **Templates**: Task list and sprint planning formats

#### `05-docker/`
Containerization and deployment (Fifth: Package and deploy)
- **Prompts**: Containerization strategy analysis
- **Templates**: Dockerfiles (Node.js, Python), docker-compose.yml, .dockerignore

## How Claude Uses These Files

1. User requests an action (e.g., "Create a PRD for feature X")
2. Claude reads relevant prompt(s) to understand the analysis process
3. Claude performs the analysis following prompt instructions
4. Claude uses template(s) to structure the output
5. Claude creates the deliverable in the user's project

## Note

These files are optimized for Claude's execution and may not be easily readable by humans. For learning about these concepts, see `/documentation/guides/`.