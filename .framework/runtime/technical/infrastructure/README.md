# Infrastructure Documentation

This directory contains infrastructure specifications and deployment configurations.

## What Goes Here

- Environment specifications (dev, staging, production)
- Container configurations (Dockerfile, docker-compose)
- Orchestration configs (Kubernetes, ECS)
- Infrastructure as Code (Terraform, CloudFormation)
- Network architecture
- Resource requirements
- Scaling policies
- Monitoring setup

## File Naming Convention

`[component/environment]-infrastructure.md`

Examples:
- `production-infrastructure.md`
- `mongodb-infrastructure.md`
- `signal-processing-infrastructure.md`

## Creating New Infrastructure Docs

Use the template at `.framework/templates/technical/infrastructure-template.md`