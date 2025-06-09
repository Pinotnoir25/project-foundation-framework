# Task Templates

Choose the right template for your needs. Start minimal, upgrade only if needed.

## Templates Overview

### 1. `task-minimal.md` (Recommended Default)
**When to use**: Starting any new feature or work  
**Size**: 5-10 lines  
**Contains**: Current focus, simple task list, notes

Perfect for:
- Individual developers
- Clear requirements  
- Quick starts
- Most features

### 2. `task-list-minimal.md` 
**When to use**: Tracking multiple work streams  
**Size**: Simple sections  
**Contains**: In Progress, Next Up, Done

Perfect for:
- Personal task tracking
- Daily standups
- Quick status checks

### 3. `task-breakdown-comprehensive.md`
**When to use**: Only when complexity demands it  
**Size**: Full structured template  
**Contains**: Epics, stories, dependencies, metrics

Perfect for:
- Multi-team coordination
- Compliance requirements
- Complex integrations
- When specifically requested

## Quick Selection Guide

Ask yourself:
1. Can I start with 3-5 tasks? → Use `task-minimal.md`
2. Do I need to track multiple streams? → Use `task-list-minimal.md`  
3. Is this genuinely complex with many dependencies? → Consider `task-breakdown-comprehensive.md`

## Usage Examples

### Starting Simple
```bash
cp task-minimal.md ~/myproject/docs/tasks/login-tasks.md
# Edit with your 3-5 initial tasks
# Start coding!
```

### Upgrading When Needed
```markdown
# Started with minimal, but discovered complexity:
# 1. Copy content to comprehensive template
# 2. Add newly discovered structure
# 3. Continue working
```

### Staying Minimal
```markdown
# Even as tasks grow, you can stay minimal:
## Current Focus
Working on API integration

## Tasks
- [x] Test API connection
- [x] Basic data fetch
- [ ] Error handling ← current
- [ ] Retry logic
- [ ] Cache responses
- [ ] Add monitoring

## Discovered
- [ ] Need rate limiting
- [ ] Need API key rotation

## Notes
- API has 100/min rate limit
- Consider using Redis for cache
```

## Remember

The best template is the one that doesn't get in your way. Start minimal, let your needs guide you.