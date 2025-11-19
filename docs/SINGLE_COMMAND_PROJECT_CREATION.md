# Single-Command Project Creation with Independent Repositories

**TL;DR:** Create a complete, production-ready project with its own GitHub repository in one command.

---

## The Vision

```bash
# One command to rule them all
./create-project.sh --name customer-search-rag \
  --archetype rag-project \
  --add-features agentic-workflows,monitoring \
  --github \
  --github-org acme-corp \
  --private

# Result (in ~60 seconds):
# ✅ Project created locally
# ✅ Multi-archetype composition (RAG + Agentic + Monitoring)
# ✅ Git repository initialized
# ✅ GitHub repository created: github.com/acme-corp/customer-search-rag
# ✅ Initial commit pushed
# ✅ CI/CD workflows configured
# ✅ README and documentation generated
# ✅ Team can clone immediately
# ✅ Completely independent from template
```

---

## Core Features

### 1. **Complete Independence**

Every project is a **separate Git repository** with no connection to the template:

```
dev-environment-template/          Your Projects:
├── archetypes/
├── scripts/                       project-1/
└── create-project.sh     ───────> ├── .git/           (independent repo)
                                   ├── src/
                                   └── docker-compose.yml

                          ───────> project-2/
                                   ├── .git/           (independent repo)
                                   ├── src/
                                   └── docker-compose.yml
```

### 2. **Automatic Git Initialization**

Git is initialized **automatically** (no `--git` flag needed):

- `.git/` directory created
- Initial commit with smart metadata
- `.gitignore` with archetype-specific patterns
- Ready to push to any remote

### 3. **GitHub Repository Creation**

**Single flag creates remote repository:**

```bash
--github                    # Create GitHub repository
--github-org mycompany      # In organization (optional)
--private                   # Private visibility (optional)
```

**What happens:**
1. Local project created
2. Git initialized
3. GitHub repository created via GitHub CLI
4. Local repo connected to remote
5. Initial commit pushed
6. Repository configured (settings, topics, etc.)

### 4. **Zero Manual Steps**

**Traditional workflow (10+ manual steps):**
```bash
# Create project directory
mkdir my-project && cd my-project

# Initialize Git
git init

# Create GitHub repo (via web UI)
# ...click, click, click...

# Connect remote
git remote add origin https://github.com/user/my-project.git

# Create files
touch README.md .gitignore

# Initial commit
git add .
git commit -m "Initial commit"
git push -u origin main

# Configure services
# ...edit docker-compose.yml...
# ...edit .env...
# ...resolve port conflicts...
```

**With template (1 command):**
```bash
./create-project.sh --name my-project \
  --archetype rag-project \
  --github \
  --private

# Done! ✅
```

---

## Usage Examples

### Example 1: Personal Project

```bash
./create-project.sh --name weekend-rag-project \
  --archetype rag-project \
  --github

# Creates:
# - Local: ./weekend-rag-project/
# - GitHub: github.com/YOUR_USERNAME/weekend-rag-project (public)
# - Pushed and ready
```

### Example 2: Company Project

```bash
./create-project.sh --name enterprise-search \
  --archetype rag-project \
  --add-features agentic-workflows,monitoring \
  --github \
  --github-org acme-corp \
  --private \
  --description "Enterprise document search with AI agents"

# Creates:
# - Local: ./enterprise-search/
# - GitHub: github.com/acme-corp/enterprise-search (private)
# - Full RAG + Agentic + Monitoring stack
# - Team can clone immediately
```

### Example 3: Local First, GitHub Later

```bash
# Day 1: Create locally
./create-project.sh --name my-experiment \
  --archetype rag-project

# Days 2-10: Develop and test locally
cd my-experiment
# ...development...

# Day 11: Ready to share
gh repo create --source=. --private --push

# Done! Now on GitHub
```

### Example 4: Multiple Related Projects

```bash
# Backend
./create-project.sh --name search-backend \
  --archetype rag-project \
  --github --github-org mycompany --private

# Frontend
./create-project.sh --name search-frontend \
  --archetype api-service \
  --github --github-org mycompany --private

# ML Pipeline
./create-project.sh --name search-ml \
  --archetype ml-training \
  --github --github-org mycompany --private

# Result: 3 independent repositories under mycompany organization
```

---

## How It Works

### Architecture

```
┌─────────────────────────────────────────────────────────┐
│ create-project.sh                                       │
│                                                         │
│  1. Load archetypes (rag-project, agentic-workflows)   │
│  2. Resolve conflicts (ports, services, dependencies)  │
│  3. Create project structure                           │
│  4. Generate configuration files                       │
│  5. Initialize Git repository                          │
│  6. Create initial commit (with metadata)              │
│                                                         │
│  IF --github flag:                                     │
│  7. Call GitHub CLI (gh)                               │
│  8. Create remote repository                           │
│  9. Configure repository settings                      │
│  10. Push initial commit                               │
└─────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│ Local Project                                           │
│  my-rag-system/                                         │
│  ├── .git/              (independent repository)        │
│  ├── src/               (RAG + Agentic code)           │
│  ├── docker-compose.yml (merged services)              │
│  ├── .env               (configuration)                │
│  ├── Makefile           (namespaced commands)          │
│  └── README.md          (auto-generated docs)          │
└─────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│ GitHub Repository                                       │
│  github.com/username/my-rag-system                      │
│  - Visibility: private/public                           │
│  - Topics: rag, ai-agents, vector-search               │
│  - CI/CD: GitHub Actions workflows                      │
│  - Issues: Enabled                                      │
│  - Protection: Configurable                             │
└─────────────────────────────────────────────────────────┘
```

### Initial Commit Structure

```
commit a1b2c3d4e5f6... (HEAD -> main, origin/main)
Author: Your Name <you@example.com>
Date:   Wed Nov 19 10:30:00 2025 -0800

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

### Generated Files

Every project includes:

```
my-project/
├── .git/                       # Git repository
├── .github/
│   └── workflows/
│       ├── ci.yml             # Automated tests
│       └── docker-build.yml   # Docker image builds
├── .gitignore                 # Smart exclusions
├── README.md                  # Auto-generated docs
├── COMPOSITION.md             # Multi-archetype guide
├── docker-compose.yml         # Base services
├── docker-compose.rag.yml     # RAG services
├── docker-compose.agentic.yml # Agentic services
├── .env.example               # Configuration template
├── Makefile                   # Unified commands
├── src/                       # Source code
├── tests/                     # Test suite
└── docs/                      # Documentation
```

---

## Prerequisites

### Required

1. **Git** installed
   ```bash
   git --version  # Should show version 2.x or higher
   ```

2. **Docker & Docker Compose**
   ```bash
   docker --version
   docker-compose --version
   ```

### Optional (for GitHub integration)

3. **GitHub CLI** (for `--github` flag)
   ```bash
   # macOS
   brew install gh

   # Windows
   winget install --id GitHub.cli

   # Linux (Debian/Ubuntu)
   sudo apt install gh
   ```

4. **GitHub Authentication**
   ```bash
   gh auth login
   # Follow prompts to authenticate
   ```

### Verification

```bash
# Check all prerequisites
./scripts/check-prerequisites.sh

# Output:
# ✓ Git installed (v2.42.0)
# ✓ Docker installed (v24.0.6)
# ✓ Docker Compose installed (v2.23.0)
# ✓ GitHub CLI installed (v2.40.0)
# ✓ GitHub authenticated (user: yourname)
#
# All prerequisites met! ✅
```

---

## Command Cheat Sheet

### Basic Commands

```bash
# Local project only (Git initialized)
./create-project.sh --name PROJECT_NAME \
  --archetype ARCHETYPE

# With GitHub (personal)
./create-project.sh --name PROJECT_NAME \
  --archetype ARCHETYPE \
  --github

# With GitHub (organization)
./create-project.sh --name PROJECT_NAME \
  --archetype ARCHETYPE \
  --github \
  --github-org ORG_NAME \
  --private
```

### Multi-Archetype

```bash
# RAG + Agentic
./create-project.sh --name PROJECT_NAME \
  --archetype rag-project \
  --add-features agentic-workflows \
  --github

# RAG + Monitoring
./create-project.sh --name PROJECT_NAME \
  --archetype rag-project \
  --add-features monitoring \
  --github
```

### Advanced Options

```bash
# Dry run (preview)
./create-project.sh --name PROJECT_NAME \
  --archetype rag-project \
  --github \
  --dry-run

# Skip Git initialization
./create-project.sh --name PROJECT_NAME \
  --archetype rag-project \
  --no-git

# Custom description
./create-project.sh --name PROJECT_NAME \
  --archetype rag-project \
  --github \
  --description "My amazing project"
```

---

## Benefits

### For Solo Developers

✅ **Fast setup** - From idea to GitHub in 60 seconds
✅ **Best practices** - Pre-configured CI/CD, linting, testing
✅ **Easy sharing** - Share GitHub URL immediately
✅ **Portfolio ready** - Professional structure from day 1

### For Teams

✅ **Consistency** - Same structure across all projects
✅ **Collaboration ready** - Team clones and starts immediately
✅ **No setup time** - Zero onboarding configuration
✅ **Scalability** - Easy to spin up new projects

### For Organizations

✅ **Standardization** - Enforced best practices
✅ **Security** - Private repos by default
✅ **Governance** - Organization-level control
✅ **Productivity** - Developers focus on features, not setup

---

## Comparison

### Traditional Approach vs. Template

| Task | Traditional | With Template |
|------|-------------|---------------|
| Create project structure | 30 min | Automatic |
| Initialize Git | 2 min | Automatic |
| Create GitHub repo | 5 min | Automatic |
| Configure Docker services | 60 min | Automatic |
| Resolve port conflicts | 20 min | Automatic |
| Setup CI/CD | 120 min | Automatic |
| Write documentation | 60 min | Automatic |
| **Total Time** | **~5 hours** | **~1 minute** |

---

## Troubleshooting

### Issue: GitHub CLI not found

**Solution:**
```bash
# Install GitHub CLI
# macOS: brew install gh
# Windows: winget install --id GitHub.cli
# Linux: sudo apt install gh
```

### Issue: Not authenticated

**Solution:**
```bash
gh auth login
# Follow prompts
```

### Issue: Repository already exists

**Solution:**
```bash
# Option 1: Use different name
./create-project.sh --name PROJECT_NAME-v2 --github

# Option 2: Delete existing
gh repo delete USERNAME/PROJECT_NAME --confirm

# Option 3: Push to existing
cd PROJECT_NAME
git remote add origin https://github.com/USERNAME/PROJECT_NAME.git
git push -u origin main
```

---

## What's Next?

### After Project Creation

```bash
# 1. Clone project (if created with --github)
git clone https://github.com/username/my-project.git
cd my-project

# 2. Review configuration
cat COMPOSITION.md
cat .env.example

# 3. Configure environment
cp .env.example .env
# Edit .env with your API keys

# 4. Start services
make start

# 5. Open in VS Code
code .

# 6. Start developing!
```

### Invite Team Members

```bash
# Add collaborators
gh repo add-collaborator teammate1
gh repo add-collaborator teammate2

# Set up branch protection
gh repo edit --enable-branch-protection main
```

### Next Projects

```bash
# Create related projects easily
./create-project.sh --name project-frontend --archetype api-service --github
./create-project.sh --name project-ml --archetype ml-training --github
./create-project.sh --name project-docs --archetype documentation --github
```

---

## Summary

**Single Command = Complete Project**

```bash
./create-project.sh --name amazing-rag-system \
  --archetype rag-project \
  --add-features agentic-workflows,monitoring \
  --github \
  --github-org mycompany \
  --private
```

**You Get:**
- ✅ Local project with multi-archetype composition
- ✅ Independent Git repository
- ✅ GitHub repository (public or private)
- ✅ Initial commit pushed
- ✅ CI/CD workflows configured
- ✅ Documentation generated
- ✅ Team can start immediately
- ✅ Zero manual configuration

**Time Saved:** ~5 hours per project
**Complexity:** Hidden
**Consistency:** Enforced
**Productivity:** Maximized

---

## Learn More

- [Multi-Archetype Composition Guide](MULTI_ARCHETYPE_COMPOSITION_DESIGN.md)
- [Git & GitHub Integration Details](docs/GIT_GITHUB_INTEGRATION.md)
- [Archetype System Overview](archetypes/README.md)
- [Implementation Guide](docs/IMPLEMENTATION_GUIDE.md)

---

**Ready to create your first project?**

```bash
./create-project.sh --name my-first-rag-project \
  --archetype rag-project \
  --github

# That's it! 🚀
```
