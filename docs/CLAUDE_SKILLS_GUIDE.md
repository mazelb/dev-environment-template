# Claude Code Skills Guide

## What Are Skills?

Skills are **automatically invoked** by Claude based on context. You don't need to manually run them - Claude discovers them when relevant.

## Available Skills

### 1. Code Quality
**Auto-activates when**: You mention code review, dependency audit, security scan, performance

**What it does**:
- Multi-language code review (Python, TypeScript, Kotlin)
- Dependency vulnerability scanning
- Performance bottleneck identification
- Security analysis (OWASP Top 10)

**Example**:
```
You: "Review the auth module for code quality"
Claude: [Automatically invokes code-quality skill]
- Analyzes code style
- Scans dependencies
- Checks security
- Provides prioritized findings
```

### 2. DevOps/Infrastructure
**Auto-activates when**: You work with Docker, CI/CD, infrastructure code

**What it does**:
- Dockerfile optimization (multi-stage, security)
- CI/CD pipeline efficiency
- Infrastructure-as-Code review
- Container security

**Example**:
```
You: "Optimize this Dockerfile"
Claude: [Automatically invokes devops-infrastructure skill]
- Suggests multi-stage build
- Reduces image size 85%
- Adds security hardening
- Provides optimized version
```

### 3. Data Engineering
**Auto-activates when**: You work with SQL, data pipelines, ETL

**What it does**:
- SQL query optimization
- Pipeline design patterns
- Data quality validation
- Schema improvements

**Example**:
```
You: "This query is slow: SELECT * FROM users..."
Claude: [Automatically invokes data-engineering skill]
- Identifies N+1 problem
- Recommends indexes
- Provides optimized query
- Shows execution plan
```

## How Skills Work

1. **Automatic**: Claude detects when a skill is relevant
2. **Context-Aware**: Uses trigger keywords and file types
3. **Invisible**: You don't see skill activation, just better results
4. **Composable**: Skills work with slash commands

## Trigger Keywords

**Code Quality**: code review, dependency, security, vulnerability, performance, quality
**DevOps**: Docker, Dockerfile, CI/CD, GitHub Actions, infrastructure, container
**Data Engineering**: SQL, query, pipeline, ETL, database, schema, slow query

## Skills vs Commands

| Aspect | Skills | Commands |
|--------|--------|----------|
| Invocation | Automatic | Manual (`/command`) |
| Discovery | Context-based | User types `/` |
| Use Case | Complex workflows | Specific tasks |

## Best Practices

1. **Natural Language**: Just describe what you need
2. **Provide Context**: Show relevant code/files
3. **Trust the System**: Skills activate automatically
4. **Review Output**: Always verify suggestions before applying

## Examples

**Good** (triggers skills naturally):
- "Review this code for security issues"
- "Optimize our Dockerfile for production"
- "This SQL query is slow, help me fix it"

**Also Good** (explicit command):
- `/security @src/api/`
- `/docker-optimize @Dockerfile`
- `/sql-optimize`

Both approaches work! Use whichever feels natural.
