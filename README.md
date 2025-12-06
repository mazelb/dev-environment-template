# Dev Environment Template

> 🚀 Portable development environment with Docker, VS Code, and AI coding assistants

A complete, production-ready development environment that works seamlessly across macOS, Windows (WSL2), and Linux. Build once, develop anywhere with consistent tooling, AI assistance, and team collaboration.

[![Docker](https://img.shields.io/badge/Docker-Required-2496ED?logo=docker)](https://www.docker.com/)
[![VS Code](https://img.shields.io/badge/VS%20Code-Recommended-007ACC?logo=visual-studio-code)](https://code.visualstudio.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## ✨ Features

### 🐳 **Multi-Language Development**
- **C++** (GCC 13, CMake, GDB)
- **Python** (3.11+, pip, virtualenv)
- **Node.js** (20 LTS, npm, yarn)
- **Kotlin** (Native, JVM-ready)
- Pre-configured build tools and debuggers

### 🤖 **AI Coding Assistants**
- **Claude Code CLI** with Claude Sonnet 4.5
  - 11 slash commands (/explain, /refactor, /test, /document, /optimize, /debug, /security, /architecture, /docker-optimize, /ci-review, /sql-optimize)
  - 3 auto-invoked skills (code-quality, devops-infrastructure, data-engineering)
  - Project memory system (.claude/CLAUDE.md)
  - Runs in VS Code terminal (Ctrl+`)
- **GitHub Copilot** for real-time autocomplete
  - Tab completion while typing
  - Inline suggestions
- **Division of Labor:**
  - Copilot: Real-time autocomplete
  - Claude Code: Complex reasoning, refactoring, architecture

### ⚙️ **VS Code Integration**
- Dev Container support (one-click setup)
- Personal settings sync across machines
- Custom keybindings and tasks
- Pre-configured debug configurations
- Recommended extensions auto-install

### 🔐 **Secrets Management**
- Local development (.env.local)
- GitHub Codespaces integration
- GitHub Actions CI/CD
- Production-ready (AWS Secrets Manager, Azure Key Vault, Docker Secrets)

### 🔄 **Continuous Updates**
- Three-tier update system (template → projects)
- Automated sync scripts
- Version tracking
- Merge conflict handling

### 👥 **Team Collaboration**
- GitHub template repository
- Consistent environments for all team members
- Shared AI prompts and workflows
- Documented onboarding process

---

## 🚀 Quick Start

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop) (latest)
- [VS Code](https://code.visualstudio.com/) (latest)
- [Git](https://git-scm.com/) (2.30+)

### Create Your First Project

```bash
# 1. Clone this template
git clone https://github.com/mazelb/dev-environment-template.git my-project
cd my-project

# 2. Create a new project
./create-project.sh --name my-app --git

# 3. Navigate to your project
cd my-app

# 4. Add your API keys
cp .env.local.example .env.local
# Edit .env.local with your API keys (Anthropic, OpenAI, etc.)

# 5. Start development
docker-compose up -d dev

# 6. Open in VS Code
code .

# 7. Reopen in container
# Press: Cmd/Ctrl+Shift+P → "Remote-Containers: Reopen in Container"

# 8. Start Claude Code in terminal
# Press: Ctrl+` to open terminal, then run:
claude code
```

**That's it!** You're now ready to code with a fully configured environment and AI assistance.

---

## 🎯 Archetype System

The template now supports an **archetype-based project creation system** for generating specialized projects from predefined templates.

### Available Archetypes

- **base** - Minimal starter template with basic structure
- **rag-project** - RAG (Retrieval-Augmented Generation) system with FastAPI, OpenSearch, and Ollama
- **api-service** - Production-ready FastAPI service
- **agentic-workflows** - AI agent orchestration with workflows
- **monitoring** - Prometheus + Grafana monitoring stack
- **composite archetypes** - Pre-configured combinations

### Creating Projects with Archetypes

```bash
# Basic project with base archetype
./create-project.sh --name my-app --archetype base

# RAG project for document search
./create-project.sh --name doc-search --archetype rag-project

# Multi-archetype composition
./create-project.sh --name my-system \\
  --archetype rag-project \\
  --add-features monitoring

# Preview before creating (dry-run mode)
./create-project.sh --name my-app --archetype base --dry-run

# With GitHub repository creation
./create-project.sh --name my-app \\
  --archetype rag-project \\
  --github \\
  --description "My awesome RAG project"

# Private repo in organization
./create-project.sh --name my-app \\
  --archetype base \\
  --github \\
  --github-org myorg \\
  --private
```

### List and Explore Archetypes

```bash
# List all available archetypes
./create-project.sh --list-archetypes

# Check archetype compatibility
./create-project.sh --check-compatibility rag-project monitoring
```

### Archetype Features

- **🎨 Template-based**: Pre-configured directory structures and files
- **🔧 Composable**: Combine multiple archetypes (base + features)
- **⚡ Fast**: Complete project setup in < 60 seconds
- **📝 Auto-documentation**: Generates README.md and COMPOSITION.md
- **🔀 Conflict resolution**: Automatic port and service name handling
- **🎯 Production-ready**: Best practices and testing included

**Learn More:**
- **[Archetype Guide](docs/ARCHETYPE_GUIDE.md)** - Complete usage guide with examples
- **[Archetype Catalog](archetypes/README.md)** - Detailed archetype reference
- **[Archetype Guide](docs/ARCHETYPE_GUIDE.md)** - Complete archetype usage and composition guide

---

## 📖 Documentation

### Getting Started
- **[Complete Setup Guide](docs/SETUP_GUIDE.md)** - Detailed installation and configuration (70-90 min)
- **[Archetype Guide](docs/ARCHETYPE_GUIDE.md)** - Complete guide to using archetypes
- **[Usage Guide](docs/USAGE_GUIDE.md)** - Daily workflows and common tasks
- **[Quick Reference](docs/QUICK_REFERENCE.md)** - Essential commands cheat sheet

### Configuration
- **[Secrets Management](docs/SECRETS_MANAGEMENT.md)** - Secure API key management
- **[Updates Guide](docs/UPDATES_GUIDE.md)** - Keep template and projects in sync
- **[Git & GitHub Integration](docs/GIT_GITHUB_INTEGRATION.md)** - GitHub workflow guide

### Reference
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Common issues and solutions
- **[FAQ](docs/FAQ.md)** - Frequently asked questions
- **[Documentation Index](docs/DOCUMENTATION_INDEX.md)** - Complete documentation guide
- **[Contributing](CONTRIBUTING.md)** - How to contribute
- **[Changelog](CHANGELOG.md)** - Version history

---

## 🎯 What's Included

### Core Files (41 total)
```
dev-environment-template/
├── Dockerfile                    # Multi-language dev container
├── docker-compose.yml            # Service orchestration
├── create-project.sh             # Project creation script
├── .devcontainer/
│   ├── devcontainer.json         # VS Code Dev Container config
│   ├── post-create.sh            # Automated setup
│   └── load-secrets.sh           # Codespaces secrets
├── .vscode/
│   ├── settings.json             # Container-optimized settings
│   ├── extensions.json           # Recommended extensions
│   ├── keybindings.json          # Custom shortcuts
│   └── prompts/                  # 8 AI prompt templates
├── .continue/
│   └── config.json               # Multi-model AI configuration
├── scripts/
│   ├── manage-template-updates.sh  # Update system
│   ├── merge-vscode-settings.sh    # Settings merger
│   ├── merge-vscode-ai-config.sh   # AI config merger
│   └── setup-secrets.sh            # Secrets setup wizard
└── docs/                         # Complete documentation
```

### Supported AI Models

**Anthropic (Claude)**
- Claude Opus 4.1 - Complex reasoning
- Claude Sonnet 4.5 - Balanced performance
- Claude Sonnet 4 - Fast coding
- Claude Haiku - Quick responses

**OpenAI**
- GPT-4o - Advanced understanding
- GPT-4o mini - Fast and efficient
- o1-preview - Reasoning tasks
- o1-mini - Quick reasoning

**Google Gemini**
- Gemini 2.0 Flash Exp - Latest model
- Gemini 2.0 Flash Thinking - Advanced reasoning
- Gemini 1.5 Pro - Production-ready
- Gemini 1.5 Flash - Fast responses

**Other Providers**
- Mistral (Large, Codestral)
- DeepSeek Coder V2
- Perplexity Sonar
- Cohere Command R+
- Local (Ollama, LM Studio)

---

## 💻 Platform Support

### macOS
✅ Native Docker Desktop support
✅ Full VS Code Dev Container integration
✅ All features work out of the box

### Windows
✅ WSL2 + Docker Desktop
✅ Native Windows Terminal support
✅ VS Code Remote - WSL integration

### Linux
✅ Native Docker support
✅ Full feature parity with macOS
✅ Ubuntu, Debian, Fedora, Arch tested

### GitHub Codespaces
✅ Zero local setup required
✅ Automatic secrets management
✅ 60 hours/month free for public repos

---

## 🎨 Usage Examples

### Create a Python ML Project

```bash
./create-project.sh --name ml-agent --git
cd ml-agent

# Install ML dependencies
docker-compose exec dev pip install torch transformers langchain

# Start Jupyter (if configured)
docker-compose up -d jupyter
# Access at: http://localhost:8888
```

### Create a Full-Stack Web App

```bash
./create-project.sh --name web-app --git
cd web-app

# Install Node dependencies
docker-compose exec dev npm install express react

# Add PostgreSQL (edit docker-compose.yml)
# Then start services
docker-compose up -d
```

### Use AI for Code Review

```bash
# 1. Open project in VS Code
code .

# 2. Open terminal (Ctrl+`)
claude code

# 3. Use slash commands:
/security @src/api/
# AI analyzes for security vulnerabilities

/optimize @src/services/
# AI suggests performance improvements

# Or use natural language:
"Review this code for security issues"
# Skills auto-activate based on context
```

---

## ⌨️ Quick Reference

### Essential Commands

| Task | Command |
|------|---------|
| Create new project | `./create-project.sh --name project --git` |
| Start container | `docker-compose up -d dev` |
| Stop container | `docker-compose down` |
| Enter container | `docker-compose exec dev bash` |
| Rebuild container | `docker-compose build dev` |
| Check for updates | `./scripts/check-template-updates.sh` |
| Sync updates | `./scripts/sync-template.sh` |
| Setup secrets | `./scripts/setup-secrets.sh` |

### VS Code Shortcuts

| Action | macOS | Windows/Linux |
|--------|-------|---------------|
| Command Palette | `Cmd+Shift+P` | `Ctrl+Shift+P` |
| Reopen in Container | `Cmd+Shift+P` → "Reopen" | `Ctrl+Shift+P` → "Reopen" |
| Open Terminal | ``Cmd+` `` | ``Ctrl+` `` |
| Start Claude Code | `claude code` (in terminal) | `claude code` (in terminal) |
| GitHub Copilot | Tab for suggestions | Tab for suggestions |

### Claude Code Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `/explain` | Explain code | `/explain @src/main.py` |
| `/refactor` | Improve code structure | `/refactor @src/services/user.py` |
| `/test` | Generate tests | `/test @src/api/endpoints.py` |
| `/document` | Add documentation | `/document @src/models/` |
| `/optimize` | Performance tips | `/optimize @src/services/` |
| `/debug` | Debug assistance | `/debug` (then describe issue) |
| `/architecture` | Analyze design | `/architecture @archetypes/rag-project/` |
| `/security` | Security review | `/security @src/api/` |
| `/docker-optimize` | Optimize Dockerfiles | `/docker-optimize @Dockerfile` |
| `/ci-review` | CI/CD review | `/ci-review @.github/workflows/` |
| `/sql-optimize` | SQL optimization | `/sql-optimize` (then show query) |

---

## 🔧 Configuration

### Add Your API Keys

```bash
# 1. Create local secrets file
cp .env.local.example .env.local

# Edit with your keys
nano .env.local
```

Add your API keys:
```bash
# Anthropic (Claude) - Required for Claude Code CLI
ANTHROPIC_API_KEY=sk-ant-your_key_here

# OpenAI (GPT) - Optional, for GitHub Copilot
OPENAI_API_KEY=sk-your_key_here
```

**Get API Keys:**
- Anthropic (Claude Code): https://console.anthropic.com/
- GitHub Copilot: Enable in VS Code with GitHub account

**Install Claude Code:**
```bash
npm install -g @anthropic-ai/claude-code

# Set API key (add to ~/.bashrc or ~/.zshrc)
export ANTHROPIC_API_KEY="sk-ant-your_key_here"

# Start in project terminal
claude code
```

### Enable VS Code Settings Sync

```bash
# In VS Code:
# 1. Press Cmd/Ctrl+Shift+P
# 2. Type: "Settings Sync: Turn On"
# 3. Sign in with GitHub or Microsoft
# 4. Select what to sync (Settings, Extensions, Keybindings)

# Your personal settings now sync across all machines!
# Template container settings are preserved.
```

---

## 👥 Team Usage

### For Team Leads

```bash
# 1. Fork or clone this template
# 2. Customize for your team (add tools, prompts, etc.)
# 3. Push to your organization's GitHub
# 4. Enable as template repository in Settings
# 5. Share with team

# Team members can now:
git clone https://github.com/LeMazOrg/dev-environment-template.git
cd dev-environment-template
./create-project.sh --name team-project
```

### For Team Members

```bash
# 1. Clone team template
git clone https://github.com/LeMazOrg/dev-environment-template.git my-project

# 2. Get API keys from team lead
# (via secure channel: 1Password, LastPass, etc.)

# 3. Setup secrets
cp .env.local.example .env.local
# Add team API keys

# 4. Start coding
code .
# Reopen in container
# Everyone has identical environment!
```

---

## 🔄 Updates

### Check for Template Updates

```bash
# In any project using this template
cd my-project
./scripts/check-template-updates.sh

# Output shows:
# - Current template version
# - Your project version
# - Available updates
# - Changed files
```

### Sync Updates to Your Project

```bash
# Quick sync (interactive)
./scripts/sync-template.sh

# Or use full manager
./scripts/manage-template-updates.sh sync --all

# Review changes and commit
git status
git add .
git commit -m "chore: sync template updates to v1.2.0"
```

---

## 🤝 Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Ways to Contribute
- 🐛 Report bugs
- 💡 Suggest features
- 📝 Improve documentation
- 🔧 Submit pull requests
- ⭐ Star the repository

---

## 📊 Comparison

### Why This Template?

| Feature | This Template | Other Solutions |
|---------|---------------|-----------------|
| Multi-language support | ✅ C++, Python, Node, Kotlin | ❌ Usually single language |
| AI coding assistants | ✅ 25+ models built-in | ❌ Manual setup required |
| Personal settings sync | ✅ Automatic | ❌ Manual copy/paste |
| Secrets management | ✅ 6 strategies included | ❌ DIY |
| Update system | ✅ Three-tier automated | ❌ Manual merge |
| Team collaboration | ✅ Built-in workflows | ❌ Figure it out |
| Documentation | ✅ Comprehensive guides | ❌ Basic README |
| Platform support | ✅ macOS, Windows, Linux | ⚠️ Limited |

---

## 🎓 Learning Resources

### Beginner
- [Docker Getting Started](https://docs.docker.com/get-started/)
- [VS Code Dev Containers Tutorial](https://code.visualstudio.com/docs/devcontainers/tutorial)
- [Claude Code Documentation](https://docs.anthropic.com/claude-code)

### Intermediate
- [Dev Container Feature Development](https://code.visualstudio.com/docs/devcontainers/create-dev-container)
- [Docker Compose Best Practices](https://docs.docker.com/compose/production/)
- [GitHub Copilot Best Practices](https://github.blog/2023-06-20-how-to-write-better-prompts-for-github-copilot/)

### Advanced
- [Multi-stage Builds](https://docs.docker.com/build/building/multi-stage/)
- [Custom Dev Container Features](https://containers.dev/implementors/features/)
- [AI Prompt Engineering](https://www.promptingguide.ai/)

---

## 🆘 Support

### Documentation
- **[Complete Setup Guide](docs/SETUP_GUIDE.md)** - Full installation walkthrough
- **[Troubleshooting Guide](docs/TROUBLESHOOTING.md)** - Common issues and fixes
- **[FAQ](docs/FAQ.md)** - Frequently asked questions

### Community
- **Issues:** [GitHub Issues](https://github.com/mazelb/dev-environment-template/issues)
- **Discussions:** [GitHub Discussions](https://github.com/mazelb/dev-environment-template/discussions)
- **Discord:** [Join our community](#) (if applicable)

### Commercial Support
For enterprise support, custom integrations, or consulting:
- Email: support@yourcompany.com
- Website: https://yourcompany.com

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### Third-Party Licenses
- Docker: [Apache License 2.0](https://github.com/moby/moby/blob/master/LICENSE)
- VS Code: [MIT License](https://github.com/microsoft/vscode/blob/main/LICENSE.txt)
- Claude Code: [Anthropic License](https://www.anthropic.com/legal/terms)

---

## 🌟 Acknowledgments

Built with and inspired by:
- [Docker](https://www.docker.com/) - Containerization platform
- [VS Code Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers) - Development environment
- [Claude Code](https://docs.anthropic.com/claude-code) - AI coding assistant CLI
- [GitHub Copilot](https://github.com/features/copilot) - AI pair programming

Special thanks to all [contributors](https://github.com/mazelb/dev-environment-template/graphs/contributors)!

---

## 🚀 Ready to Start?

```bash
# Clone the template
git clone https://github.com/mazelb/dev-environment-template.git
cd dev-environment-template

# Create your first project with archetype
./create-project.sh --name awesome-app --archetype rag-project --github

# Or start with minimal base
./create-project.sh --name my-app --archetype base

# Read the guides
# Setup: docs/SETUP_GUIDE.md
# Archetypes: docs/ARCHETYPE_GUIDE.md
# Usage: docs/USAGE_GUIDE.md
```

**Happy coding!** 🎉

---

<div align="center">

**[Documentation](docs/SETUP_GUIDE.md)** •
**[Issues](https://github.com/mazelb/dev-environment-template/issues)** •
**[Discussions](https://github.com/mazelb/dev-environment-template/discussions)** •
**[Contributing](CONTRIBUTING.md)**

Made with ❤️ by developers, for developers

</div>
