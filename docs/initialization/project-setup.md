# Project Setup Initialization

Use this conversational prompt with Claude to initialize your project:

---

## Prompt for Claude

I'd like to set up a new project using the Project Foundation Framework. Here's the information about my project:

**Project Basics:**
- Project Name: [Your project name]
- Project Type: [e.g., Web Application, API Service, Data Platform, Mobile App, etc.]
- Brief Description: [2-3 sentences about what your project does]
- Current Status: [e.g., Concept, Planning, Early Development, Migration]

**Technical Stack:**
- Primary Programming Language: [e.g., Python, JavaScript, Java, etc.]
- Framework/Platform: [e.g., React, Django, Spring Boot, etc.]
- Database: [e.g., PostgreSQL, MongoDB, MySQL, etc.]
- Infrastructure: [e.g., AWS, Google Cloud, On-premise, etc.]

**Project Objectives:**
- Primary Goal: [What is the main thing this project should achieve?]
- Secondary Goals: [List 2-3 additional objectives]
- Target Timeline: [When should this be completed?]

**Target Users:**
- Who will use this system? [Describe your primary users]
- What problems does it solve for them? [Key pain points addressed]

**Constraints:**
- Technical constraints: [Any technical limitations?]
- Business constraints: [Budget, timeline, resources?]
- Regulatory requirements: [Compliance needs?]

Please help me:
1. Create the initial project configuration
2. Set up the appropriate directory structure
3. Generate the first PRD for the core functionality
4. Establish success metrics
5. Create an initial task breakdown

---

## What Claude Will Do

When you provide this information, Claude will:

1. **Create Project Configuration**
   - Generate `.project/context/project.json` with your details
   - Set up initial project state tracking

2. **Establish Documentation Structure**
   - Create placeholder PRDs for core features
   - Set up task tracking structure
   - Initialize success metrics

3. **Generate Initial Content**
   - First PRD based on your primary objective
   - Initial task breakdown
   - Development roadmap

4. **Provide Next Steps**
   - Recommended development sequence
   - Key decisions to make
   - Resource requirements

## Tips for Best Results

- Be specific about your technical choices
- Clearly describe your target users
- Include any unique constraints or requirements
- Mention any existing systems you need to integrate with
- Specify your team size and expertise level

## Example Filled Prompt

```
I'd like to set up a new project using the Project Foundation Framework. Here's the information about my project:

**Project Basics:**
- Project Name: CustomerInsights
- Project Type: Web Application
- Brief Description: A dashboard application that aggregates customer feedback from multiple sources and provides actionable insights through visualizations and AI-powered analysis.
- Current Status: Planning

**Technical Stack:**
- Primary Programming Language: TypeScript
- Framework/Platform: Next.js with React
- Database: PostgreSQL with Redis cache
- Infrastructure: AWS with Docker containers

[... continue with all sections ...]
```