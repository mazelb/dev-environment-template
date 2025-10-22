# Complete Setup Guide: Dev Environment Template

**Version:** 2.0  
**Last Updated:** October 20, 2025  
**Estimated Setup Time:** 70-90 minutes

---

## 📖 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Part 1: Create Template Locally](#part-1-create-template-locally)
- [Part 2: Configure VS Code Settings](#part-2-configure-vs-code-settings)
- [Part 3: Configure AI Tools](#part-3-configure-ai-tools)
- [Part 4: Setup Secrets Management](#part-4-setup-secrets-management)
- [Part 5: Push to GitHub](#part-5-push-to-github)
- [Part 6: Use on Different Machines](#part-6-use-on-different-machines)
- [Part 7: Maintenance & Updates](#part-7-maintenance--updates)
- [Quick Reference](#quick-reference)
- [Troubleshooting](#troubleshooting)

---

## Overview

This guide will walk you through creating a complete, portable development environment that works on macOS, Windows (with WSL2), and Linux. The environment includes:

- ✅ Docker-based dev container with C++, Python, Node.js, Kotlin
- ✅ VS Code Dev Container integration
- ✅ AI coding assistants (Claude, GPT, Gemini, etc.)
- ✅ Personal VS Code settings sync
- ✅ Secure secrets management
- ✅ Continuous update system
- ✅ Team collaboration features

---

## Prerequisites

### Required Tools

1. **Docker Desktop** (latest version)
   - macOS: [Download](https://www.docker.com/products/docker-desktop)
   - Windows: [Download](https://www.docker.com/products/docker-desktop) + WSL2
   - Linux: `sudo apt-get install docker.io docker-compose`

2. **Visual Studio Code** (latest version)
   - Download: [code.visualstudio.com](https://code.visualstudio.com/)

3. **Git** (2.30+)
   - macOS: `brew install git` or Xcode Command Line Tools
   - Windows: [Git for Windows](https://git-scm.com/download/win)
   - Linux: `sudo apt-get install git`

### Optional Tools

- **GitHub Account** (for template hosting and Settings Sync)
- **jq** (for settings merge script)
  - macOS: `brew install jq`
  - Linux: `sudo apt-get install jq`
  - Windows: `choco install jq`

### System Requirements

- **RAM:** 8GB minimum (16GB recommended)
- **Disk Space:** 10GB free
- **Docker Memory:** 4GB minimum allocated
- **OS:** macOS 10.15+, Windows 10/11 with WSL2, Ubuntu 20.04+

---

## Part 1: Create Template Locally

### Step 1: Create Project Directory

```bash
# Create and navigate to template directory
mkdir dev-environment-template
cd dev-environment-template

# Initialize as git repository
git init
```

### Step 2: Create Directory Structure

```bash
# Create all necessary directories
mkdir -p .devcontainer
mkdir -p .vscode/prompts
mkdir -p .continue
mkdir -p scripts
mkdir -p docs
mkdir -p examples
mkdir -p .github/workflows
mkdir -p src
mkdir -p tests
mkdir -p config

# Create .gitkeep files to preserve empty directories
touch src/.gitkeep tests/.gitkeep examples/.gitkeep
```

### Step 3: Create Core Files

#### 📄 Create All Template Files

You need to create **41 core files**. Here's the checklist:

#### Root Level (14 files)
- [ ] `Dockerfile` - Container image definition
- [ ] `docker-compose.yml` - Multi-service orchestration
- [ ] `.env.example` - Environment variables template
- [ ] `.env.local.example` - Local secrets template
- [ ] `.gitignore` - Git ignore rules
- [ ] `.gitattributes` - Git line ending rules
- [ ] `.prettierrc.json` - Code formatting (JavaScript/TypeScript)
- [ ] `.eslintrc.json` - Linting rules (JavaScript/TypeScript)
- [ ] `.pylintrc` - Python linting configuration
- [ ] `create-project.sh` - Project creation script
- [ ] `install-template.sh` - Template installation script
- [ ] `README.md` - Main documentation
- [ ] `CHANGELOG.md` - Version history
- [ ] `LICENSE` - License file (MIT recommended)

#### .devcontainer/ (3 files)
- [ ] `devcontainer.json` - VS Code Dev Container configuration
- [ ] `post-create.sh` - Post-creation setup script
- [ ] `load-secrets.sh` - GitHub Codespaces secrets loader

#### .vscode/ (5 files)
- [ ] `settings.json` - VS Code settings (container-optimized)
- [ ] `keybindings.json` - Custom keyboard shortcuts
- [ ] `extensions.json` - Recommended extensions
- [ ] `tasks.json` - Build and test tasks
- [ ] `launch.json` - Debug configurations

#### .vscode/prompts/ (8 files)
- [ ] `explain.md` - Code explanation prompt
- [ ] `refactor.md` - Code refactoring prompt
- [ ] `test.md` - Test generation prompt
- [ ] `document.md` - Documentation generation prompt
- [ ] `optimize.md` - Performance optimization prompt
- [ ] `debug.md` - Debugging assistance prompt
- [ ] `architecture.md` - Architecture analysis prompt
- [ ] `security.md` - Security review prompt

#### .continue/ (1 file)
- [ ] `config.json` - Continue AI multi-model configuration

#### scripts/ (6 files)
- [ ] `manage-template-updates.sh` - Template update manager
- [ ] `sync-template.sh` - Quick sync wrapper
- [ ] `check-template-updates.sh` - Update checker wrapper
- [ ] `merge-vscode-settings.sh` - Personal settings merger
- [ ] `merge-vscode-ai-config.sh` - AI settings merger
- [ ] `setup-secrets.sh` - Secrets management setup

#### docs/ (4 files)
- [ ] `SETUP_GUIDE.md` - This document
- [ ] `USAGE_GUIDE.md` - Daily usage guide
- [ ] `UPDATES_GUIDE.md` - Update strategy
- [ ] `SECRETS_MANAGEMENT.md` - Secrets management guide

**Total: 41 files**

### Step 4: Make Scripts Executable

```bash
chmod +x create-project.sh
chmod +x install-template.sh
chmod +x scripts/*.sh
chmod +x .devcontainer/*.sh
```

### Step 5: Create .gitattributes

```bash
cat > .gitattributes << 'EOF'
* text=auto
*.sh text eol=lf
*.bat text eol=crlf
*.ps1 text eol=crlf
*.json text eol=lf
*.md text eol=lf
EOF
```

### Step 6: Verify Local Setup

```bash
# Check all files are present
find . -type f | wc -l
# Should show at least 41 files

# Verify structure
tree -L 2 -a

# Check scripts are executable
ls -la *.sh scripts/*.sh .devcontainer/*.sh
```

### Step 7: Test Docker Build Locally

```bash
# Build the dev container image
docker-compose build dev

# If successful, you'll see: "Successfully tagged..."

# Test running the container
docker-compose up -d dev

# Enter the container
docker-compose exec dev bash

# Verify tools are installed
python3 --version
node --version
g++ --version

# Exit container
exit
docker-compose down
```

### Step 8: Create Initial Git Commit

```bash
# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: Complete dev environment template

- Dockerfile with C++, Python, Node.js, Kotlin
- Docker Compose with multi-service support
- VS Code Dev Container integration
- AI coding assistants (Claude, GPT, Gemini)
- Personal VS Code settings sync
- 8 AI prompt templates
- Secure secrets management
- Update management system
- Complete documentation"

# Verify commit
git log --oneline
```

---

## Part 2: Configure VS Code Settings

You have **4 options** for integrating your personal VS Code settings:

### ✅ Option 1: Settings Sync (Recommended - Easiest)

**Best for:** Most users who want automatic syncing

1. **Enable Settings Sync in VS Code:**
   - Press `Cmd+Shift+P` (Mac) or `Ctrl+Shift+P` (Windows/Linux)
   - Type: "Settings Sync: Turn On"
   - Sign in with GitHub or Microsoft account
   - Select: Settings, Extensions, Keybindings, UI State

2. **How It Works:**
   - Template settings (container-specific) are applied first
   - Your personal settings are layered on top
   - Extensions automatically install
   - Works across all machines automatically

3. **What Gets Synced:**
   - ✅ Editor preferences (font, theme, size)
   - ✅ Keybindings
   - ✅ Extensions
   - ✅ UI state and snippets
   - ❌ Container-specific paths (preserved from template)

### ✅ Option 2: Merge Settings Script (Automated)

**Best for:** One-time migration or periodic updates

```bash
# Run the merge script
./scripts/merge-vscode-settings.sh

# What it does:
# 1. Finds your VS Code settings automatically
# 2. Backs up template settings
# 3. Merges your preferences with template
# 4. Preserves container-specific settings

# To restore original template:
cp .vscode/settings.json.backup .vscode/settings.json
```

### ✅ Option 3: Manual Merge

**Best for:** Full control over settings

```bash
# 1. Find your settings location:
# macOS: ~/Library/Application Support/Code/User/settings.json
# Linux: ~/.config/Code/User/settings.json
# Windows: %APPDATA%\Code\User\settings.json

# 2. Open both files
code ~/Library/Application\ Support/Code/User/settings.json
code .vscode/settings.json

# 3. Merge carefully:
# - KEEP template settings for: python.defaultInterpreterPath, 
#   remote.containers.*, files.watcherExclude
# - ADD your settings for: editor preferences, themes, workflow

# 4. Test in container
```

### ✅ Option 4: Personal Settings Overlay

**Best for:** Keeping personal settings separate

```bash
# Create personal settings file (not tracked in git)
cat > .vscode/settings.personal.json << 'EOF'
{
  "editor.fontSize": 16,
  "editor.fontFamily": "'JetBrains Mono'",
  "workbench.colorTheme": "Dracula",
  "files.autoSave": "afterDelay"
}
EOF

# Add to .gitignore
echo ".vscode/settings.personal.json" >> .gitignore

# Manually apply when needed
jq -s '.[0] * .[1]' .vscode/settings.json .vscode/settings.personal.json > .vscode/settings.tmp.json
mv .vscode/settings.tmp.json .vscode/settings.json
```

**Recommended:** Use Option 1 (Settings Sync) - it's automatic and works perfectly with containers!

---

## Part 3: Configure AI Tools

### Step 1: Choose Your AI Models

The template supports **25+ AI models** from multiple providers:

**Anthropic (Claude):**
- Claude Opus 4.1 (`claude-opus-4-1-20250805`)
- Claude Sonnet 4.5 (`claude-3-5-sonnet-20241022`)
- Claude Sonnet 4 (`claude-sonnet-4-20250514`)
- Claude Haiku (`claude-3-haiku-20240307`)

**OpenAI (GPT & o1):**
- GPT-4o (`gpt-4o`)
- GPT-4o mini (`gpt-4o-mini`)
- o1-preview (`o1-preview`)
- o1-mini (`o1-mini`)

**Google (Gemini):**
- Gemini 2.0 Flash Exp (`gemini-2.0-flash-exp`)
- Gemini 2.0 Flash Thinking (`gemini-2.0-flash-thinking-exp`)
- Gemini 1.5 Pro (`gemini-1.5-pro-latest`)

**Other Providers:**
- Mistral (Large, Medium, Codestral)
- DeepSeek Coder V2
- Perplexity Sonar
- Cohere Command R+
- Local (Ollama, LM Studio)

### Step 2: Get API Keys

**Anthropic (Claude) - Required:**
1. Visit: https://console.anthropic.com/
2. Sign up or log in
3. Go to API Keys section
4. Create new key
5. Copy key (starts with `sk-ant-`)

**OpenAI (GPT) - Optional:**
1. Visit: https://platform.openai.com/api-keys
2. Create API key
3. Copy key (starts with `sk-`)

**Google (Gemini) - Optional:**
1. Visit: https://makersuite.google.com/app/apikey
2. Create API key
3. Copy key

### Step 3: Configure Continue AI

**Option A: Manual Configuration**

Edit `.continue/config.json` with your API keys:

```json
{
  "models": [
    {
      "title": "Claude Sonnet 4.5",
      "provider": "anthropic",
      "model": "claude-3-5-sonnet-20241022",
      "apiKey": "YOUR_ANTHROPIC_API_KEY_HERE"
    },
    {
      "title": "GPT-4o",
      "provider": "openai",
      "model": "gpt-4o",
      "apiKey": "YOUR_OPENAI_API_KEY_HERE"
    }
  ],
  "tabAutocompleteModel": {
    "title": "Codestral",
    "provider": "mistral",
    "model": "codestral-latest",
    "apiKey": "YOUR_MISTRAL_API_KEY_HERE"
  }
}
```

**Option B: Use Merge Script**

```bash
# Merge your existing AI config with template
./scripts/merge-vscode-ai-config.sh
```

### Step 4: Install Continue Extension

1. Open VS Code
2. Press `Cmd+Shift+X` (Mac) or `Ctrl+Shift+X` (Windows/Linux)
3. Search for "Continue"
4. Click Install
5. Reload window if prompted

### Step 5: Test AI Integration

```bash
# 1. Open VS Code in your template directory
code .

# 2. Open Continue panel
# Press: Cmd+L (Mac) or Ctrl+L (Windows/Linux)

# 3. Select a model from dropdown
# Try: Claude Sonnet 4.5

# 4. Test with a question
# Type: "Explain how Docker works"

# 5. Test custom commands
# Open any code file
# Select code
# Press: Cmd+Shift+E
# Try: /explain, /refactor, /test
```

---

## Part 4: Setup Secrets Management

### Choose Your Secrets Management Strategy

**For Local Development:**
```bash
# Create .env.local file
cp .env.local.example .env.local

# Edit with your API keys
nano .env.local

# Add your keys:
ANTHROPIC_API_KEY=sk-ant-your_key_here
OPENAI_API_KEY=sk-your_key_here
GOOGLE_API_KEY=your_google_key_here
```

**For GitHub Codespaces:**

1. Go to: https://github.com/settings/codespaces
2. Click "New secret"
3. Add each secret:
   - Name: `ANTHROPIC_API_KEY`, Value: your key
   - Name: `OPENAI_API_KEY`, Value: your key
   - Name: `GOOGLE_API_KEY`, Value: your key
4. Select repository access
5. Secrets automatically load in Codespaces via `.devcontainer/load-secrets.sh`

**For GitHub Actions (CI/CD):**

1. Go to your repository on GitHub
2. Click Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Add each secret
5. Use in workflows via `${{ secrets.ANTHROPIC_API_KEY }}`

**For Production:**

```bash
# Interactive setup wizard
./scripts/setup-secrets.sh

# Choose from:
# 1) Local Development (.env.local)
# 2) GitHub Codespaces
# 3) GitHub Actions
# 4) Docker Secrets (Swarm)
# 5) AWS Secrets Manager
# 6) Azure Key Vault
```

### Security Best Practices

✅ **Never commit** `.env.local` to git (already in .gitignore)  
✅ **Rotate keys** regularly (every 90 days)  
✅ **Use different keys** for dev/staging/production  
✅ **Enable audit logging** for production secrets  
✅ **Set up alerts** for unauthorized access attempts  

---

## Part 5: Push to GitHub

### Step 1: Create GitHub Repository

1. Go to: https://github.com/new
2. Repository name: `dev-environment-template`
3. Description: "Portable development environment with Docker, VS Code, and AI coding assistants"
4. Visibility: **Public** (for template) or Private
5. **Do NOT** initialize with README (you already have one)
6. Click "Create repository"

### Step 2: Push to GitHub

```bash
# Add remote
git remote add origin https://github.com/mazelb/dev-environment-template.git

# Verify remote
git remote -v

# Push to GitHub
git branch -M main
git push -u origin main

# Verify on GitHub
# Visit: https://github.com/mazelb/dev-environment-template
```

### Step 3: Enable Template Repository

1. Go to your repository on GitHub
2. Click **Settings** (top right)
3. Scroll to "Template repository" section
4. Check ✅ "Template repository"
5. Save changes

### Step 4: Configure Repository Settings

**Recommended settings:**

```
Settings → General:
- ✅ Allow squash merging
- ✅ Automatically delete head branches

Settings → Branches:
- Add branch protection rule for 'main':
  - ✅ Require pull request reviews before merging
  - ✅ Require status checks to pass

Settings → Pages (optional):
- Source: Deploy from a branch
- Branch: main / docs (if you want documentation site)
```

### Step 5: Add Topics (for discoverability)

1. Click ⚙️ gear icon next to "About" section
2. Add topics:
   - `docker`
   - `dev-container`
   - `vscode`
   - `development-environment`
   - `ai-coding`
   - `claude`
   - `template`
3. Save changes

---

## Part 6: Use on Different Machines

### Scenario 1: New Project on Same Machine

```bash
# Method 1: Use create-project.sh
cd ~/projects
git clone https://github.com/mazelb/dev-environment-template.git
cd dev-environment-template
./create-project.sh --name my-new-app --git

# Method 2: Use GitHub template
# Go to: https://github.com/mazelb/dev-environment-template
# Click "Use this template" → "Create a new repository"
# Clone your new repo
```

### Scenario 2: Different Machine (macOS/Linux)

```bash
# 1. Install prerequisites
# - Docker Desktop
# - VS Code
# - Git

# 2. Clone template
git clone https://github.com/mazelb/dev-environment-template.git my-project
cd my-project

# 3. Enable Settings Sync in VS Code
# Cmd+Shift+P → "Settings Sync: Turn On"
# Sign in with same account

# 4. Create .env.local (or use GitHub Codespaces secrets)
cp .env.local.example .env.local
# Add your API keys

# 5. Open in VS Code
code .

# 6. Reopen in Container
# Cmd+Shift+P → "Remote-Containers: Reopen in Container"

# 7. Wait for container to build and extensions to install
# Your settings and extensions automatically sync!

# 8. Start coding
# Everything is configured and ready!
```

### Scenario 3: Windows Machine

```bash
# 1. Install WSL2
wsl --install

# 2. Install Docker Desktop for Windows
# Enable WSL2 integration in Docker Desktop settings

# 3. In WSL2 terminal:
git clone https://github.com/mazelb/dev-environment-template.git my-project
cd my-project

# 4. Install VS Code (Windows)
# Install "Remote - WSL" extension
# Install "Dev Containers" extension

# 5. Open project from WSL
code .

# 6. Enable Settings Sync
# Ctrl+Shift+P → "Settings Sync: Turn On"

# 7. Create .env.local
cp .env.local.example .env.local
nano .env.local

# 8. Reopen in Container
# Ctrl+Shift+P → "Remote-Containers: Reopen in Container"

# 9. Ready to code!
```

### Scenario 4: Using GitHub Codespaces

```bash
# 1. Go to your repository on GitHub
# 2. Click "Code" → "Codespaces" → "Create codespace on main"
# 3. Wait for container to build (2-3 minutes)
# 4. VS Code opens in browser (or desktop VS Code if connected)
# 5. Secrets automatically loaded from GitHub Codespaces settings
# 6. Extensions automatically installed
# 7. Settings automatically synced
# 8. Start coding immediately!

# Benefits of Codespaces:
# ✅ No local setup required
# ✅ Consistent environment everywhere
# ✅ Powerful cloud VMs
# ✅ Automatic secrets management
# ✅ Free for public repos (60 hours/month)
```

### Scenario 5: Team Collaboration

```bash
# Team member workflow:

# 1. Clone team template
git clone https://github.com/LeMazOrg/dev-environment-template.git project-name

# 2. Get secrets from team lead
# - Slack/Email secure channel
# - Team password manager (1Password, LastPass)
# - Or use GitHub organization secrets

# 3. Create .env.local
cp .env.local.example .env.local
# Add team API keys

# 4. Open in VS Code
code .

# 5. Enable Settings Sync (personal settings)
# Cmd/Ctrl+Shift+P → "Settings Sync: Turn On"

# 6. Reopen in Container
# Cmd/Ctrl+Shift+P → "Remote-Containers: Reopen in Container"

# 7. Start contributing!
# Everyone has same environment
# Container settings from template
# Personal preferences from Settings Sync
```

---

## Part 7: Maintenance & Updates

### Keeping Template Updated

**Three-Tier Update System:**

1. **Template** → Make improvements here
2. **Existing Projects** → Pull updates when needed
3. **New Projects** → Always use latest template

### Check for Updates

```bash
# In any project using the template
cd my-project

# Check for template updates
./scripts/check-template-updates.sh

# Output shows:
# - Template version
# - Your project version
# - Available updates
# - Changed files
```

### Sync Updates to Project

```bash
# Review changes before syncing
./scripts/manage-template-updates.sh check

# Sync specific files
./scripts/manage-template-updates.sh sync Dockerfile docker-compose.yml

# Sync all configuration
./scripts/manage-template-updates.sh sync --all

# Quick sync wrapper
./scripts/sync-template.sh
```

### Update Workflow

**1. Update Template:**
```bash
# Make improvements in template repo
cd dev-environment-template
# Edit files
git add .
git commit -m "feat: Add new Python tools"
git push

# Tag version
git tag v1.1.0
git push --tags
```

**2. Update Existing Projects:**
```bash
# In each project
cd my-project-1
./scripts/sync-template.sh
# Review and commit

cd ../my-project-2
./scripts/sync-template.sh
# Review and commit
```

**3. Communicate to Team:**
```bash
# Send team notification:
# "Template updated to v1.1.0"
# "Run: ./scripts/check-template-updates.sh to see changes"
# "Run: ./scripts/sync-template.sh to update"
```

### Version Management Best Practices

✅ **Use semantic versioning** (v1.2.3)  
✅ **Tag releases** in template repo  
✅ **Document changes** in CHANGELOG.md  
✅ **Test updates** before rolling out to team  
✅ **Provide migration guides** for breaking changes  
✅ **Review changes** before syncing to projects  

---

## Quick Reference

### Essential Commands

```bash
# Create new project
./create-project.sh --name my-app --git

# Start development container
docker-compose up -d dev

# Enter container
docker-compose exec dev bash

# Stop container
docker-compose down

# Rebuild container (after Dockerfile changes)
docker-compose build dev
docker-compose up -d dev

# Check for template updates
./scripts/check-template-updates.sh

# Sync template updates
./scripts/sync-template.sh

# Open in VS Code
code .

# Reopen in container (VS Code)
# Cmd/Ctrl+Shift+P → "Remote-Containers: Reopen in Container"

# Open Continue AI
# Cmd+L (Mac) or Ctrl+L (Windows/Linux)

# Custom AI commands
# Select code → Cmd/Ctrl+Shift+E → type command:
# /explain, /refactor, /test, /document, /optimize, /debug
```

### File Locations

```
Template Structure:
├── Dockerfile                    # Container definition
├── docker-compose.yml            # Multi-service orchestration
├── .env.example                  # Environment variables template
├── .env.local                    # Your secrets (not in git)
├── create-project.sh             # Project creation script
├── .devcontainer/
│   ├── devcontainer.json         # VS Code container config
│   ├── post-create.sh            # Post-creation setup
│   └── load-secrets.sh           # Codespaces secrets loader
├── .vscode/
│   ├── settings.json             # Container-optimized settings
│   ├── extensions.json           # Recommended extensions
│   └── prompts/                  # 8 AI prompt templates
├── .continue/
│   └── config.json               # Multi-model AI configuration
├── scripts/
│   ├── manage-template-updates.sh  # Update manager
│   ├── merge-vscode-settings.sh    # Settings merger
│   └── setup-secrets.sh            # Secrets setup
└── docs/
    ├── SETUP_GUIDE.md            # This document
    ├── USAGE_GUIDE.md            # Daily usage guide
    └── SECRETS_MANAGEMENT.md     # Secrets guide
```

### Common Tasks

| Task | Command |
|------|---------|
| Create new project | `./create-project.sh --name project --git` |
| Start container | `docker-compose up -d dev` |
| Stop container | `docker-compose down` |
| Enter container | `docker-compose exec dev bash` |
| Open in VS Code | `code .` |
| Reopen in container | Cmd/Ctrl+Shift+P → "Reopen in Container" |
| Check updates | `./scripts/check-template-updates.sh` |
| Sync updates | `./scripts/sync-template.sh` |
| Merge personal settings | `./scripts/merge-vscode-settings.sh` |
| Setup secrets | `./scripts/setup-secrets.sh` |

### VS Code Shortcuts

| Action | macOS | Windows/Linux |
|--------|-------|---------------|
| Command Palette | `Cmd+Shift+P` | `Ctrl+Shift+P` |
| Settings Sync | `Cmd+Shift+P` → "Sync" | `Ctrl+Shift+P` → "Sync" |
| Open Continue | `Cmd+L` | `Ctrl+L` |
| AI Commands | `Cmd+Shift+E` | `Ctrl+Shift+E` |
| Terminal | ``Cmd+` `` | ``Ctrl+` `` |
| File Explorer | `Cmd+Shift+E` | `Ctrl+Shift+E` |
| Search | `Cmd+Shift+F` | `Ctrl+Shift+F` |

---

## Troubleshooting

### Docker Issues

**Problem:** Docker daemon not running

```bash
# macOS/Windows
# Start Docker Desktop application

# Linux
sudo systemctl start docker
```

**Problem:** Container won't start

```bash
# Check logs
docker-compose logs dev

# Rebuild without cache
docker-compose build --no-cache dev

# Clean Docker system
docker system prune -a
```

**Problem:** Out of disk space

```bash
# Clean up unused images and containers
docker system prune -a --volumes

# Check Docker disk usage
docker system df
```

**Problem:** Out of memory

```bash
# Increase Docker memory in Docker Desktop settings
# Recommended: 4GB minimum, 8GB optimal
```

### VS Code Issues

**Problem:** Extensions not installing

```bash
# 1. Check internet connection
# 2. Restart VS Code
# 3. Manually install extensions:
#    - Open Extensions (Cmd/Ctrl+Shift+X)
#    - Search and install each extension
# 4. Reload window
```

**Problem:** Settings not syncing

```bash
# 1. Check Settings Sync is enabled:
#    Cmd/Ctrl+Shift+P → "Settings Sync: Show Synced Data"
# 2. Sign in again if needed
# 3. Reload window: Cmd/Ctrl+Shift+P → "Developer: Reload Window"
```

**Problem:** Dev Container not opening

```bash
# 1. Install "Dev Containers" extension
# 2. Check Docker is running
# 3. Verify .devcontainer/devcontainer.json exists
# 4. Check logs: View → Output → Select "Dev Containers"
# 5. Rebuild: Cmd/Ctrl+Shift+P → "Rebuild Container"
```

### AI Issues

**Problem:** Continue AI not working

```bash
# 1. Check API key is set:
#    - In .env.local for local dev
#    - In GitHub secrets for Codespaces
# 2. Verify Continue extension is installed
# 3. Check config: ~/.continue/config.json or .continue/config.json
# 4. Restart VS Code
# 5. Check API quota/billing at provider dashboard
```

**Problem:** Wrong AI model responding

```bash
# 1. Open Continue panel (Cmd/Ctrl+L)
# 2. Click model dropdown (top of panel)
# 3. Select desired model
# 4. Try request again
```

**Problem:** AI requests failing

```bash
# 1. Check API key is valid
# 2. Verify API credits/quota at provider
# 3. Check internet connection
# 4. Try different model
# 5. Check Continue extension logs:
#    Help → Toggle Developer Tools → Console
```

### Settings Issues

**Problem:** Personal settings not applying in container

```bash
# 1. Verify Settings Sync is enabled and signed in
# 2. Reload window in container
# 3. Check .vscode/settings.json for conflicts
# 4. Use merge script: ./scripts/merge-vscode-settings.sh
```

**Problem:** Container-specific settings broken

```bash
# 1. Restore template settings backup:
cp .vscode/settings.json.backup .vscode/settings.json

# 2. Or restore from git:
git checkout .vscode/settings.json

# 3. Rebuild container:
docker-compose down
docker-compose up -d dev
```

### Permission Issues

**Problem:** Scripts not executable

```bash
# Make scripts executable
chmod +x create-project.sh
chmod +x install-template.sh
chmod +x scripts/*.sh
chmod +x .devcontainer/*.sh
```

**Problem:** Docker permission denied (Linux)

```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Log out and back in, or:
newgrp docker

# Verify
docker ps
```

### Update Issues

**Problem:** Sync script fails

```bash
# 1. Verify template remote is set:
git remote -v

# 2. Add template remote if missing:
git remote add template https://github.com/mazelb/dev-environment-template.git

# 3. Fetch template:
git fetch template

# 4. Try sync again:
./scripts/sync-template.sh
```

**Problem:** Merge conflicts during sync

```bash
# 1. Check what files have conflicts:
git status

# 2. Resolve conflicts manually:
#    - Edit each conflicted file
#    - Remove conflict markers (<<<<, ====, >>>>)
#    - Keep desired changes

# 3. Mark as resolved:
git add <resolved-file>

# 4. Complete merge:
git commit

# 5. Or abort and try again later:
git merge --abort
```

### Network Issues

**Problem:** Can't pull Docker images

```bash
# 1. Check internet connection
# 2. Check Docker Hub status: status.docker.com
# 3. Try using mirror:
#    Add to Docker Desktop settings or /etc/docker/daemon.json:
{
  "registry-mirrors": ["https://mirror.gcr.io"]
}
# 4. Restart Docker
```

**Problem:** API requests timing out

```bash
# 1. Check internet connection
# 2. Check firewall settings
# 3. Try different network (e.g., mobile hotspot)
# 4. Verify API endpoint is accessible:
curl -I https://api.anthropic.com
```

### Common Error Messages

**"Cannot connect to Docker daemon"**
→ Start Docker Desktop

**"port is already allocated"**
→ Change port in docker-compose.yml or stop conflicting service

**"no space left on device"**
→ Run `docker system prune -a`

**"API key invalid"**
→ Check API key format and validity at provider dashboard

**"rate limit exceeded"**
→ Wait or upgrade API plan

**"extension activation failed"**
→ Reinstall extension and reload window

---

## Next Steps

### After Setup

1. ✅ **Test everything:**
   ```bash
   ./create-project.sh --name test-project
   cd test-project
   docker-compose up -d dev
   code .
   # Test AI: Cmd/Ctrl+L
   ```

2. ✅ **Customize for your needs:**
   - Add your favorite VS Code extensions to `.vscode/extensions.json`
   - Create custom AI prompts in `.vscode/prompts/`
   - Add project-specific Docker services to `docker-compose.yml`

3. ✅ **Share with team:**
   - Push to GitHub
   - Enable as template repository
   - Add team members as collaborators
   - Create onboarding documentation

4. ✅ **Keep updated:**
   - Star the template repo on GitHub
   - Watch for new releases
   - Periodically sync updates to projects
   - Contribute improvements back to template

### Recommended Resources

**Official Documentation:**
- [Docker Docs](https://docs.docker.com/)
- [VS Code Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers)
- [VS Code Settings Sync](https://code.visualstudio.com/docs/editor/settings-sync)
- [Continue.dev Docs](https://continue.dev/docs)
- [Anthropic API Docs](https://docs.anthropic.com/)

**Community:**
- [Docker Community Forum](https://forums.docker.com/)
- [VS Code GitHub Discussions](https://github.com/microsoft/vscode/discussions)
- [Continue GitHub](https://github.com/continuedev/continue)

**Learning:**
- [Docker Getting Started](https://docs.docker.com/get-started/)
- [VS Code Tips and Tricks](https://code.visualstudio.com/docs/getstarted/tips-and-tricks)
- [AI Coding Best Practices](https://continue.dev/docs/walkthroughs/codebase-embeddings)

---

## Summary

You now have a **complete, portable development environment** that:

✅ Works on macOS, Windows (WSL2), and Linux  
✅ Includes Docker container with C++, Python, Node.js, Kotlin  
✅ Integrates with VS Code Dev Containers  
✅ Supports 25+ AI models for coding assistance  
✅ Syncs your personal VS Code settings automatically  
✅ Manages secrets securely across environments  
✅ Updates easily with continuous sync system  
✅ Enables seamless team collaboration  

**Total Setup Time:** ~70-90 minutes for complete setup

**What's Next:**
- Create your first project
- Customize AI prompts
- Share with your team
- Start building amazing things! 🚀

---

**Questions or issues?** Check the troubleshooting section or open an issue on GitHub.

**Happy coding!** 🎉
