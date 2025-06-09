# Framework Guide

This guide provides essential instructions for using the Project Foundation Framework effectively. It applies to ALL projects created with this framework.

## Framework Philosophy

**Start Small, Build as Needed** - Don't create documentation until you need it. Focus on shipping working software with just enough documentation to be effective.

## Minimum Documentation to Start Development

Before writing any code, you need ONLY these essentials:

### 1. **Project Context** ✅ Required
- `CLAUDE.md` - Filled with basic project info
- `.project/context/project.json` - Created during initialization
- **Time to complete**: 5-10 minutes via conversation

### 2. **First Feature PRD** ✅ Required
- Start with ONE core feature (e.g., "User Authentication", "Data Import", "Basic CRUD")
- Use `.framework/templates/prd/prd-template.md` as guide
- **Time to complete**: 15-30 minutes

### 3. **Development Environment** ✅ Required
- `.env` file created from `.env.template`
- Basic run instructions in README
- **Time to complete**: 5 minutes

### 4. **Basic Architecture Decision** 🟡 Recommended
- Simple TAD with key decisions (monolith vs microservices, database choice)
- Can be 1-2 pages using `.framework/templates/technical/tad-template.md`
- **Time to complete**: 15-20 minutes

## Documentation to Create Later (As Needed)

### When You Have Multiple Features
- Additional PRDs for new features
- Task breakdown documents
- Sprint planning docs

### When You're Ready to Deploy
- Infrastructure documentation
- CI/CD pipeline setup
- Deployment procedures

### When You Have a Team
- API documentation
- Development standards
- Onboarding guides

### When You Hit Scale
- Performance benchmarks
- Monitoring setup
- Security audits

### When Required by Compliance
- Security requirements
- Compliance documentation
- Audit procedures

## Framework Usage Patterns

### Pattern 1: Startup MVP
```
Day 1: Initialize project → Create auth PRD → Start coding
Week 1: Add payment PRD → Basic deployment docs
Month 1: Add API docs → Team onboarding
```

### Pattern 2: Enterprise Project
```
Week 1: Full architecture TAD → Security requirements → Multiple PRDs
Week 2: Development standards → API contracts → Start coding
Week 3: Testing strategy → CI/CD setup
```

### Pattern 3: Hackathon/Prototype
```
Hour 1: Initialize → Skip PRDs → Direct to code
Hour 4: Retroactively add basic docs
Day 2: Add PRD if continuing
```

## Key Principles for Claude

When working on a project using this framework:

1. **Don't Ask for Missing Docs** - If a technical doc doesn't exist, make reasonable assumptions based on project.json
2. **Create Docs When Needed** - If you need an API spec to proceed, create it then
3. **Start Coding Quickly** - With minimum docs in place, begin implementation
4. **Document as You Build** - Update docs with decisions made during coding
5. **Pragmatic Over Perfect** - Working software > comprehensive docs

## Quick Decision Tree

```
Need to start coding?
├─ Have CLAUDE.md + 1 PRD? → Start coding! ✅
├─ Missing project context? → Run initialization first
└─ No PRDs? → Create one PRD for core feature (30 min max)

Need deployment?
├─ Code working locally? → Create deployment docs
└─ Still developing? → Skip deployment docs for now

Need API docs?
├─ Building API? → Document as you build
└─ Planning API? → Create basic spec first
```

## Anti-Patterns to Avoid

❌ **Documentation Paralysis** - Spending weeks on docs before coding
❌ **Premature Optimization** - Creating performance docs before v1
❌ **Over-Engineering** - Complex architectures for simple problems
❌ **Template Overload** - Filling every template before starting

## Framework Evolution

This framework should evolve with your project:
- **Week 1**: Minimal docs, maximum coding
- **Month 1**: Add docs for pain points
- **Month 3**: Standardize what's working
- **Month 6**: Full documentation for scaling

## Remember

The best documentation is the one that gets used. Start minimal, add what helps, remove what doesn't.

---

*This guide applies to all projects using the Project Foundation Framework. It is loaded automatically alongside CLAUDE.md.*