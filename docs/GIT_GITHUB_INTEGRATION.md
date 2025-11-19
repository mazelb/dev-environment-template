# Git & GitHub Repository Integration Guide

**Version:** 1.0
**Date:** November 19, 2025
**Status:** Implementation Ready

---

## Overview

Every project created from the dev-environment-template is **automatically a separate Git repository**. This ensures complete independence from the template and enables seamless collaboration through GitHub.

## Philosophy

> "One project = One repository"

Each project you create should be independent, versionable, and shareable. The template facilitates this by:

1. **Automatic Git initialization** - Every project starts with `.git/`
2. **Smart commit messages** - Initial commit includes archetype metadata
3. **Optional GitHub integration** - Create remote repository in one command
4. **Complete independence** - No connection to template repository

---

## Quick Start

### Local Git Repository (Default)

```bash
# Creates project with Git initialized
./create-project.sh --name my-rag-system \
  --archetype rag-project \
  --add-features agentic-workflows

# Result:
# - my-rag-system/ created
# - Git initialized (.git/ directory)
# - Initial commit made
# - Ready for development
```

### With GitHub Repository (Single Command)

```bash
# Creates project + GitHub repo + pushes initial commit
./create-project.sh --name my-rag-system \
  --archetype rag-project \
  --add-features agentic-workflows \
  --github \
  --private

# Result:
# - my-rag-system/ created locally
# - Git initialized
# - GitHub repo created: github.com/YOUR_USERNAME/my-rag-system
# - Initial commit pushed
# - Clone URL available for team
```

---

## Command Reference

### CLI Flags

| Flag | Description | Default | Example |
|------|-------------|---------|---------|
| `--github` | Create GitHub repository | `false` | `--github` |
| `--github-org ORG` | GitHub organization/user | Current user | `--github-org acme-corp` |
| `--private` | Create private repository | `false` | `--private` |
| `--public` | Create public repository | `true` | `--public` |
| `--no-git` | Skip Git initialization | N/A | `--no-git` |
| `--description TEXT` | Repository description | Auto-generated | `--description "My RAG system"` |
| `--no-push` | Don't push initial commit | `false` | `--no-push` |

### Usage Examples

#### 1. Personal Public Repository

```bash
./create-project.sh --name my-ai-project \
  --archetype rag-project \
  --github
```

**Creates:**
- Repository: `github.com/YOUR_USERNAME/my-ai-project`
- Visibility: Public
- Initial commit: Pushed

#### 2. Organization Private Repository

```bash
./create-project.sh --name customer-insights \
  --archetype rag-project \
  --add-features agentic-workflows,monitoring \
  --github \
  --github-org acme-corp \
  --private \
  --description "Customer insights RAG system with autonomous agents"
```

**Creates:**
- Repository: `github.com/acme-corp/customer-insights`
- Visibility: Private
- Description: Custom
- Initial commit: Pushed

#### 3. Local Development First

```bash
# Create project without GitHub
./create-project.sh --name my-experiment \
  --archetype rag-project

# Develop locally...

# Later, create GitHub repo
cd my-experiment
gh repo create --source=. --private --push
```

#### 4. Preview Before Creating

```bash
./create-project.sh --name my-system \
  --archetype rag-project \
  --add-features agentic-workflows \
  --github \
  --github-org mycompany \
  --dry-run

# Shows preview, asks for confirmation
```

---

## Prerequisites

### Required

- **Git** installed (`git --version`)
- **GitHub CLI** for `--github` flag
  - Install: [https://cli.github.com/](https://cli.github.com/)
  - Authenticate: `gh auth login`

### Optional

- GitHub account (for `--github`)
- Organization membership (for `--github-org`)

---

## Setup Instructions

### 1. Install GitHub CLI

**macOS:**
```bash
brew install gh
```

**Windows:**
```powershell
winget install --id GitHub.cli
```

**Linux:**
```bash
# Debian/Ubuntu
sudo apt install gh

# Fedora/RHEL
sudo dnf install gh
```

### 2. Authenticate with GitHub

```bash
gh auth login
```

Follow the prompts:
1. Choose "GitHub.com"
2. Choose "HTTPS" protocol
3. Authenticate via web browser
4. Complete authentication

**Verify:**
```bash
gh auth status
```

### 3. Configure Git (First Time Only)

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

---

## Generated Files

### .gitignore

Automatically generated with patterns from:
- Base template (secrets, environment files)
- Archetype-specific patterns (e.g., `opensearch-data/`)

**Example:**
```gitignore
# Environment variables
.env
.env.local
*.env.local

# Secrets
secrets/
*.secret
*.key
*.pem

# Python
__pycache__/
*.py[cod]
venv/
.venv/

# Docker volumes
opensearch-data/
ollama-data/
airflow-logs/

# IDE
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db
```

### README.md

Auto-generated with:
- Project name and description
- Quick start instructions
- Service URLs and ports
- Link to COMPOSITION.md
- Template attribution

**Example:**
```markdown
# my-rag-system

> RAG system with agentic workflows
>
> Generated from [dev-environment-template](https://github.com/mazelb/dev-environment-template)

## Quick Start

\`\`\`bash
# Clone repository
git clone https://github.com/username/my-rag-system.git
cd my-rag-system

# Start services
make start
\`\`\`

## Architecture

This project combines:
- **RAG Project**: Vector search with OpenSearch
- **Agentic Workflows**: Multi-agent orchestration

See [COMPOSITION.md](COMPOSITION.md) for details.
```

### Initial Commit Message

Smart commit message with archetype metadata:

```
Initial commit: my-rag-system

Archetypes:
- rag-project (v1.0.0)
- agentic-workflows (v1.0.0)

Services:
- RAG API (port 8000)
- OpenSearch (port 9200)
- Ollama (port 11434)
- Agentic API (port 8100)
- Airflow (port 8180)

Generated by dev-environment-template v2.0.0
```

---

## GitHub Repository Settings

### Auto-Applied Settings

When creating via `--github`, these settings are automatically configured:

| Setting | Value | Reason |
|---------|-------|--------|
| **Issues** | Enabled | Track bugs and features |
| **Projects** | Enabled | Kanban boards |
| **Wiki** | Disabled | Use docs/ directory instead |
| **Merge options** | All enabled | Flexibility for team |
| **Auto-delete branches** | Enabled | Keep repo clean |
| **Topics** | Auto-tagged | Discoverability |

### Topics (Tags)

Automatically applied based on archetypes:

- Base template: `dev-environment-template`
- RAG project: `rag`, `vector-search`, `semantic-search`
- Agentic: `ai-agents`, `multi-agent`, `autonomous`
- Monitoring: `prometheus`, `grafana`, `observability`

**Example:**
```
Topics: rag, ai-agents, vector-search, multi-agent, dev-environment-template
```

---

## CI/CD Integration

### GitHub Actions Workflows

Auto-generated workflows in `.github/workflows/`:

#### ci.yml (Continuous Integration)

```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.12'

      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install -r requirements-dev.txt

      - name: Run tests
        run: make test

      - name: Lint
        run: make lint

      - name: Type check
        run: make typecheck
```

#### docker-build.yml (Docker Image Build)

```yaml
name: Docker Build

on:
  push:
    branches: [main]
    tags: ['v*']

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Build Docker images
        run: docker-compose build

      - name: Test Docker services
        run: |
          docker-compose up -d
          sleep 30
          make test-integration
          docker-compose down
```

### Customization

Workflows can be customized per archetype:

```json
{
  "ci_workflows": {
    "python_test": true,
    "docker_build": true,
    "security_scan": true,
    "dependency_update": true
  }
}
```

---

## Workflow Scenarios

### Scenario 1: Solo Developer

```bash
# Day 1: Start project
./create-project.sh --name my-experiment \
  --archetype rag-project \
  --github \
  --private

# Day 2-30: Develop
cd my-experiment
git add .
git commit -m "Add search feature"
git push

# When ready: Make public
gh repo edit --visibility public
```

### Scenario 2: Team Collaboration

```bash
# Lead developer creates project
./create-project.sh --name team-rag-system \
  --archetype rag-project \
  --add-features monitoring \
  --github \
  --github-org acme-corp \
  --private

# Team members clone
git clone https://github.com/acme-corp/team-rag-system.git
cd team-rag-system

# Start development
make start
code .
```

### Scenario 3: Open Source Project

```bash
# Create public project
./create-project.sh --name awesome-rag-toolkit \
  --archetype rag-project \
  --github \
  --public \
  --description "Production-ready RAG toolkit for document search"

# Add license
cp LICENSE ./awesome-rag-toolkit/
cd awesome-rag-toolkit
git add LICENSE
git commit -m "Add MIT license"
git push

# Enable discussions
gh repo edit --enable-discussions
```

### Scenario 4: Multiple Projects

```bash
# Create multiple related projects
./create-project.sh --name search-backend \
  --archetype rag-project \
  --github \
  --github-org mycompany \
  --private

./create-project.sh --name search-frontend \
  --archetype api-service \
  --github \
  --github-org mycompany \
  --private

./create-project.sh --name search-ml-pipeline \
  --archetype ml-training \
  --github \
  --github-org mycompany \
  --private

# Each project is independent but can reference others
```

---

## Error Handling

### Common Issues and Solutions

#### 1. GitHub CLI Not Installed

**Error:**
```
✗ GitHub CLI not found
```

**Solution:**
```bash
# Install gh CLI
# macOS: brew install gh
# Windows: winget install --id GitHub.cli
# Linux: sudo apt install gh (Debian/Ubuntu)
```

#### 2. Not Authenticated

**Error:**
```
✗ GitHub CLI not authenticated
```

**Solution:**
```bash
gh auth login
# Follow prompts to authenticate
```

#### 3. Repository Already Exists

**Error:**
```
✗ Repository 'username/my-project' already exists on GitHub
```

**Solutions:**
```bash
# Option 1: Use different name
./create-project.sh --name my-project-v2 --github

# Option 2: Delete existing repo
gh repo delete username/my-project --confirm

# Option 3: Use existing repo
cd my-project
git remote add origin https://github.com/username/my-project.git
git push -u origin main
```

#### 4. Push Failed (Network Issues)

**Error:**
```
✗ Failed to push initial commit
```

**Solution:**
```bash
# Manual push
cd my-project
git push -u origin main

# Or retry
gh repo sync
```

#### 5. Organization Permission Denied

**Error:**
```
✗ You don't have permission to create repositories in 'acme-corp'
```

**Solutions:**
1. Ask organization admin for permission
2. Create in personal account: Remove `--github-org`
3. Create manually and push later

---

## Advanced Configuration

### Custom Remote Names

```bash
# Create project
./create-project.sh --name my-project \
  --archetype rag-project \
  --github

# Add additional remotes
cd my-project
git remote add upstream https://github.com/original/repo.git
git remote add backup https://gitlab.com/username/my-project.git
```

### Branch Protection Rules

```bash
# After project creation
cd my-project

# Require PR reviews
gh api repos/:owner/:repo/branches/main/protection \
  -X PUT \
  -f required_pull_request_reviews='{"required_approving_review_count":1}'

# Require status checks
gh api repos/:owner/:repo/branches/main/protection \
  -X PUT \
  -f required_status_checks='{"strict":true,"contexts":["test"]}'
```

### GitHub Secrets

```bash
# Add secrets for CI/CD
cd my-project

gh secret set OPENAI_API_KEY
gh secret set ANTHROPIC_API_KEY
gh secret set DOCKER_USERNAME
gh secret set DOCKER_PASSWORD
```

---

## Best Practices

### 1. Repository Naming

**Good:**
- `customer-search-rag` (descriptive, kebab-case)
- `document-qa-system` (clear purpose)
- `arxiv-paper-curator` (specific domain)

**Avoid:**
- `test1`, `my-project`, `new-thing` (too generic)
- `My Project 2024` (spaces, poor naming)
- `ragSystemFinal` (camelCase, "final")

### 2. Commit Messages

**Use conventional commits:**
```bash
git commit -m "feat: add semantic search endpoint"
git commit -m "fix: resolve opensearch connection timeout"
git commit -m "docs: update API reference"
git commit -m "chore: upgrade langchain to v0.2.0"
```

### 3. Branch Strategy

**Recommended:**
```
main (or master) - Production-ready
develop - Integration branch
feature/* - Feature branches
bugfix/* - Bug fixes
hotfix/* - Urgent production fixes
```

**Example workflow:**
```bash
# Create feature branch
git checkout -b feature/advanced-search

# Develop...
git add .
git commit -m "feat: add advanced search filters"

# Push
git push origin feature/advanced-search

# Create PR
gh pr create --title "Add advanced search" --body "Implements filters"
```

### 4. Documentation

Keep these files updated:
- `README.md` - Overview, quick start
- `COMPOSITION.md` - Multi-archetype details
- `CHANGELOG.md` - Version history
- `docs/` - Detailed documentation

### 5. Security

**Never commit:**
- `.env` files (already in .gitignore)
- API keys or secrets
- Private keys (`.pem`, `.key`)
- Passwords or tokens

**Use GitHub Secrets instead:**
```bash
gh secret set MY_SECRET_KEY
```

---

## Troubleshooting

### Checking Git Status

```bash
# Is Git initialized?
cd my-project
git status

# View remotes
git remote -v

# Check current branch
git branch

# View recent commits
git log --oneline
```

### Re-initializing GitHub Connection

```bash
# Remove remote
git remote remove origin

# Re-add
gh repo create --source=. --private --push
```

### Undoing Initial Commit

```bash
# If you need to reset
git reset --soft HEAD~1
# Make changes
git add .
git commit -m "New initial commit"
git push -f origin main
```

---

## FAQ

### Q: Can I skip Git initialization?

**A:** Yes, use `--no-git` flag:
```bash
./create-project.sh --name my-project \
  --archetype rag-project \
  --no-git
```

### Q: Can I create GitHub repo later?

**A:** Yes:
```bash
# Create project without GitHub
./create-project.sh --name my-project --archetype rag-project

# Later, create GitHub repo
cd my-project
gh repo create --source=. --private --push
```

### Q: What if I don't have GitHub CLI?

**A:** The script will skip GitHub creation and provide instructions:
```
⚠ GitHub CLI not found
ℹ Install: https://cli.github.com/
ℹ You can create the repository manually later
```

### Q: Can I change repository visibility later?

**A:** Yes:
```bash
# Make private
gh repo edit --visibility private

# Make public
gh repo edit --visibility public
```

### Q: How do I transfer ownership?

**A:** Use GitHub CLI:
```bash
gh repo edit --transfer-ownership new-owner
```

### Q: Can I use GitLab or Bitbucket?

**A:** Currently only GitHub is supported via CLI. For others:
1. Create project locally
2. Create repo manually on GitLab/Bitbucket
3. Add remote and push:
```bash
git remote add origin https://gitlab.com/username/project.git
git push -u origin main
```

---

## Summary

**Key Features:**
- ✅ Automatic Git initialization (default)
- ✅ Single-command GitHub repository creation
- ✅ Smart commit messages with archetype metadata
- ✅ Auto-generated .gitignore and README
- ✅ CI/CD workflows included
- ✅ Complete independence from template

**Next Steps:**
1. Install GitHub CLI: `brew install gh` (or equivalent)
2. Authenticate: `gh auth login`
3. Create your first project: `./create-project.sh --name my-app --archetype rag-project --github`
4. Start developing! 🚀

---

**Version History:**
- v1.0 (Nov 19, 2025) - Initial release with automatic Git + GitHub integration
