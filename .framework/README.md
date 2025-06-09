# Project Foundation Framework

The `.framework/` directory contains all the resources that power the Project Foundation Framework. It is organized into two main sections based on the intended audience and usage.

## Directory Structure

```
.framework/
├── documentation/     # For humans - learning and reference
│   ├── guides/       # Conceptual explanations and best practices
│   └── examples/     # Complete reference implementations
└── runtime/          # For Claude - execution and generation
    ├── prd/         # Product requirements documentation
    ├── tasks/       # Task breakdown and planning
    ├── context/     # Project context management
    ├── initialization/ # Project setup
    └── technical/   # Technical standards and patterns
```

## Key Concepts

### Documentation vs Runtime
- **Documentation** (`/documentation/`): Materials for humans to read and learn from
- **Runtime** (`/runtime/`): Materials Claude uses during execution to generate content and follow standards

### Theme-Based Organization
Runtime materials are organized by functional theme (PRD, tasks, etc.) rather than by type (templates, prompts). This keeps related materials together.

### Prompts vs Templates
- **Prompts**: Instructions for Claude's thinking process (HOW to analyze)
- **Templates**: Document structures for output (WHAT to create)

## Usage

### For Developers
1. Read `/documentation/guides/` to understand concepts
2. Review `/documentation/examples/` for reference implementations
3. Let Claude handle the runtime materials automatically

### For Claude
1. Check CLAUDE.md for project-specific configuration
2. Use `/runtime/` materials when executing tasks
3. Reference `/documentation/` for understanding framework philosophy

## Important Notes

- **DO NOT MODIFY** framework files in your project (unless in framework development mode)
- The framework is designed to be used "as-is" by Claude during runtime
- Templates are not meant to be copied - Claude reads them when needed

## Getting Started

When starting a new project:
1. Claude will guide you through initialization
2. The framework will create necessary directories and context files
3. You'll provide project-specific information
4. Claude will use the framework to help build your project

For more information, see the main README.md at the repository root.