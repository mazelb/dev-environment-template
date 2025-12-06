# Daily Development Workflow with Claude Code

## Morning: Starting Your Day

### 1. Open Project in VS Code
```bash
code .
```

### 2. Start Claude Code in Terminal
```bash
# Press Ctrl+` to open terminal
claude code

# Claude loads project context from CLAUDE.md
```

### 3. Check Task List
```
You: "What should I work on today?"
Claude: [Reviews recent commits, issues, TODO comments]
```

## During Development

### Implementing a Feature

**Scenario**: Adding a new API endpoint

```bash
# 1. Understand existing patterns
/architecture @src/api/

# 2. Implement the feature
# (Use Copilot for autocomplete while typing)

# 3. Generate tests
/test @src/api/endpoints/new_endpoint.py

# 4. Review code quality
# (code-quality skill auto-activates)
"Review the new endpoint for security and performance"

# 5. Add documentation
/document @src/api/endpoints/new_endpoint.py
```

### Debugging an Issue

**Scenario**: API endpoint returning 500 error

```bash
# 1. Describe the issue
/debug

You: "The /users endpoint returns 500 when email is missing"

Claude: [Analyzes code, provides root cause and fix]

# 2. Add test for regression
/test

You: "Add test for missing email validation"
```

### Optimizing Performance

**Scenario**: Slow database query

```bash
# 1. Show the query
/sql-optimize

You: [Paste slow SQL query]

Claude: [Analyzes, provides optimized version with indexes]

# 2. Apply changes
# Claude provides migration script
```

## Code Review

### Before Creating PR

```bash
# 1. Review your changes
/security @src/
/optimize @src/

# 2. Ensure tests pass
!pytest -v

# 3. Check documentation
/document @src/
```

### Reviewing Others' PRs

```bash
# 1. Explain the changes
/explain @path/to/changed/file.py

# 2. Check for issues
"Review this PR for security and performance issues"

# 3. Suggest improvements
/refactor @path/to/file.py
```

## DevOps Tasks

### Optimizing Docker

```bash
/docker-optimize @Dockerfile

# Claude provides:
# - Multi-stage build
# - Size reduction
# - Security hardening
```

### Reviewing CI/CD

```bash
/ci-review @.github/workflows/ci.yml

# Claude suggests:
# - Caching strategies
# - Parallel jobs
# - Security improvements
```

## Best Practices

### 1. Start Conversations with Context
**Good**: `/explain @src/services/rag/pipeline.py`
**Better**: "Explain how the RAG pipeline works in @src/services/rag/pipeline.py"

### 2. Use Natural Language
Don't just run commands - have conversations:
```
"I'm implementing user authentication. What's the best approach for our FastAPI setup?"
```

### 3. Iterate on Solutions
```
You: "Optimize this query"
Claude: [Provides optimized version]
You: "What if we need to support 1M users?"
Claude: [Suggests scaling strategies]
```

### 4. Learn from Claude
Ask "why" to understand the reasoning:
```
You: "Why did you suggest this refactoring?"
Claude: [Explains design principles and trade-offs]
```

## Tips & Tricks

### Quick Commands
- `Ctrl+` ` - Toggle terminal
- `Shift+Enter` - Line break in Claude Code
- `/help` - Show all commands

### File References
- `@file.py` - Include single file
- `@src/` - Include directory
- `!git diff` - Show recent changes

### Efficient Workflow
1. Use Copilot for line-by-line autocomplete
2. Use Claude Code for complex reasoning
3. Let skills activate automatically
4. Review and learn from suggestions

## Troubleshooting

**Issue**: Claude doesn't remember context
**Solution**: Check `.claude/CLAUDE.md` is present

**Issue**: Commands not working
**Solution**: Run `/help` to verify installation

**Issue**: Skills not activating
**Solution**: Use trigger keywords naturally in conversation

## Getting Help

- Commands: `/help`
- Documentation: `docs/CLAUDE_*.md`
- Team: #dev Slack channel
