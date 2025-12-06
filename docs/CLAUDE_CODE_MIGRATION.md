# Claude Code Migration Guide

## Overview

We've successfully migrated from Continue.dev to Claude Code for AI-assisted development.

## What Changed

### ✅ Added (Claude Code)
- **11 Slash Commands**: `/explain`, `/refactor`, `/test`, `/document`, `/optimize`, `/debug`, `/security`, `/architecture`, `/docker-optimize`, `/ci-review`, `/sql-optimize`
- **3 Auto-Invoked Skills**: code-quality, devops-infrastructure, data-engineering
- **Project Memory**: `.claude/CLAUDE.md` remembers project context
- **Permissions System**: Fine-grained control over tool usage

### ❌ Removed (Continue.dev)
- Continue.dev VS Code extension
- `.vscode/prompts/` directory (migrated to `.claude/commands/`)
- `.continue/` configuration directory

### ✅ Kept
- **GitHub Copilot** - Works great with Claude Code for autocomplete!
- All other VS Code extensions

## Division of Labor

**GitHub Copilot**: Real-time autocomplete while typing
**Claude Code**: Complex reasoning, refactoring, architecture, debugging (in terminal)

## Getting Started

### 1. Install Claude Code
```bash
npm install -g @anthropic-ai/claude-code
```

### 2. Set API Key
```bash
export ANTHROPIC_API_KEY="your-key-here"
# Or add to ~/.bashrc or ~/.zshrc
```

### 3. Start Claude Code
```bash
# In VS Code terminal (Ctrl+`)
claude code
```

### 4. Try Commands
```bash
/help               # See all commands
/explain @src/main.py   # Explain code
/test @src/services/    # Generate tests
```

## Key Features

### Project Memory (CLAUDE.md)
Claude remembers:
- Your 7 archetypes
- Tech stack (Python, TypeScript, Kotlin)
- Code conventions
- Common workflows

### Auto-Invoked Skills
Skills activate automatically based on context:
- **code-quality**: Triggered when you mention "code review", "dependency audit"
- **devops-infrastructure**: Triggered when you work with Docker, CI/CD
- **data-engineering**: Triggered when you work with SQL, data pipelines

### Slash Commands
Manual commands for specific tasks:
- Core: `/explain`, `/refactor`, `/test`, `/document`
- Analysis: `/optimize`, `/debug`, `/security`, `/architecture`
- DevOps: `/docker-optimize`, `/ci-review`
- Data: `/sql-optimize`

## Team Rollout

1. **Week 1**: Install and test individually
2. **Week 2**: Use commands in daily work
3. **Week 3**: Explore skills and advanced features
4. **Week 4**: Full adoption, remove Continue.dev

## Documentation

- **Commands**: `docs/CLAUDE_COMMANDS_GUIDE.md`
- **Skills**: `docs/CLAUDE_SKILLS_GUIDE.md`
- **Workflow**: `docs/CLAUDE_WORKFLOW.md`

## Support

Questions? Check `docs/` or ask in #dev channel.
