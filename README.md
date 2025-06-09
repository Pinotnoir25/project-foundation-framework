# Project Foundation Framework

A comprehensive framework for managing software projects with Claude AI, featuring structured documentation, task management, and persistent context.

## Quick Start

1. **Read `.framework/guides/INITIALIZE.md`** - Welcome guide and first steps
2. **Run initialization** - `@claude initialize new project`
3. **Follow the prompts** - Claude will guide you through setup

## Framework Structure

```
.
├── .framework/            # Framework documentation and templates
│   ├── guides/           # Framework and system guides
│   ├── templates/        # All reusable templates
│   ├── prompts/          # AI prompts for content generation
│   └── initialization/   # Project setup resources
├── CLAUDE.md              # Claude AI instructions (auto-customized)
├── .project/              # Persistent project context
│   ├── context/          # Current project state
│   └── conversations/    # Saved session history
├── docs/
│   ├── prd/             # Product Requirements Documentation
│   ├── tasks/           # Task management system
│   └── technical/       # Technical documentation
└── examples/            # Real-world examples
```

## Key Features

### 1. Conversational Project Setup
- Natural language initialization with Claude
- Guided project configuration
- Automatic documentation generation

### 2. Persistent Context Management
- Project state preserved across conversations
- Decision tracking and rationale
- Conversation history with key outcomes

### 3. Structured Documentation
- **PRD System**: Product requirements with templates
- **Task Management**: Breaking down PRDs into actionable tasks
- **Sprint Planning**: Organize work into manageable sprints

### 4. Intelligent Assistance
- Claude understands your project context
- Consistent terminology via glossary
- Progress tracking and status updates

## How It Works

1. **Initialize Your Project**
   - Claude guides you through project setup
   - Creates customized documentation structure
   - Establishes project context

2. **Document Requirements**
   - Create PRDs using provided templates
   - Claude helps analyze and refine requirements
   - Success metrics defined upfront

3. **Plan Implementation**
   - PRDs converted to task breakdowns
   - Dependencies identified automatically
   - Sprint planning assistance

4. **Maintain Context**
   - Conversations saved automatically
   - Decisions tracked with rationale
   - Project state always current

## Example Usage

```
User: @claude I want to build a web application for managing customer feedback

Claude: I'll help you set up your customer feedback application using the Project Foundation Framework. Let me guide you through the initialization process...

[Claude proceeds with structured setup]
```

## Benefits

- **Consistency**: Standardized approach across all projects
- **Continuity**: Never lose context between sessions
- **Clarity**: Clear documentation and task tracking
- **Efficiency**: Reusable templates and patterns

## Customization

The framework adapts to your needs:
- Add domain-specific templates
- Customize initialization prompts
- Extend documentation structure
- Create specialized workflows

## Getting Started

1. Open `.framework/guides/INITIALIZE.md` for detailed instructions
2. Have your project details ready:
   - Project name and description
   - Technical stack preferences
   - Team size and timeline
   - Key objectives

3. Start the conversation with Claude:
   ```
   @claude initialize new project
   ```

## Support

- Check `/examples/` for real-world implementations
- Review documentation in `/docs/` for detailed guides
- Use help prompts: `@claude help with [topic]`

---

*Project Foundation Framework - Transform ideas into well-documented, manageable projects with AI assistance.*