# Frequently Asked Questions (FAQ)

**Version:** 2.0
**Last Updated:** November 21, 2025

Quick answers to common questions about the dev environment template and archetype system.

---

## 📖 Table of Contents

- [General Questions](#general-questions)
- [Archetype System](#archetype-system)
- [Getting Started](#getting-started)
- [Docker & Containers](#docker--containers)
- [VS Code & Extensions](#vs-code--extensions)
- [AI Assistants](#ai-assistants)
- [Secrets & Security](#secrets--security)
- [Updates & Maintenance](#updates--maintenance)
- [Team Collaboration](#team-collaboration)
- [Platform Support](#platform-support)
- [Troubleshooting](#troubleshooting)

---

## General Questions

### What is this template?

A portable, Docker-based development environment that includes:
- Multi-language support (C++, Python, Node.js, Kotlin)
- VS Code Dev Container integration
- AI coding assistants (Claude, GPT, Gemini)
- Personal settings sync
- Secure secrets management
- Team collaboration features

### Why use this instead of local setup?

**Benefits:**
- ✅ **Consistent environment** across all machines
- ✅ **No "works on my machine"** issues
- ✅ **Easy onboarding** for new team members
- ✅ **Isolated dependencies** won't conflict
- ✅ **Version controlled** configuration
- ✅ **AI-powered** coding assistance
- ✅ **Cross-platform** (macOS, Windows, Linux)

### How much does it cost?

**Free:**
- Template itself (open source)
- Docker (community edition)
- VS Code
- GitHub (public repos)
- Basic AI models (with free tier API keys)

**Optional costs:**
- AI API credits (varies by provider)
- GitHub Codespaces ($0.18/hr beyond free tier)
- Cloud secrets management (AWS/Azure)

### Is this suitable for production?

**Development:** ✅ Perfect
**Staging:** ✅ Recommended
**Production:** ⚠️ Use production-ready Docker images

The template is optimized for development. For production:
- Remove development tools
- Use multi-stage builds
- Optimize image size
- Use production-grade secrets management
- Add monitoring and logging

---

## Archetype System

### What are archetypes?

**Archetypes** are pre-configured project templates that provide specialized functionality.

**Examples:**
- `rag-project` - Document search with AI (OpenSearch + Ollama)
- `api-service` - Production FastAPI service
- `monitoring` - Prometheus + Grafana stack
- `agentic-workflows` - AI agent orchestration

**Benefits:**
- ⚡ Create complete projects in < 60 seconds
- 🎯 Production-ready configurations
- 🔧 Composable - combine multiple archetypes
- 📝 Auto-documented

### How do I use archetypes?

```bash
# List available archetypes
./create-project.sh --list-archetypes

# Create with single archetype
./create-project.sh --name my-app --archetype rag-project

# Combine base + features
./create-project.sh --name my-app \\
  --archetype rag-project \\
  --add-features monitoring

# Preview first (dry-run)
./create-project.sh --name test --archetype base --dry-run
```

**Complete guide:** [ARCHETYPE_GUIDE.md](ARCHETYPE_GUIDE.md)

### Can I combine multiple archetypes?

Yes! Use `--add-features` to add feature archetypes:

```bash
# RAG + Monitoring
./create-project.sh --name my-app \\
  --archetype rag-project \\
  --add-features monitoring

# RAG + Agents + Monitoring
./create-project.sh --name ai-platform \\
  --archetype rag-project \\
  --add-features agentic-workflows,monitoring
```

The system automatically:
- Resolves port conflicts (adds offsets)
- Merges docker-compose.yml files
- Combines environment variables
- Generates documentation

### What's the difference between base and feature archetypes?

| Type | Purpose | Example | Usage |
|------|---------|---------|-------|
| **Base** | Primary application structure | `rag-project` | `--archetype` |
| **Feature** | Add capabilities | `monitoring` | `--add-features` |
| **Composite** | Pre-combined | `composite-rag-agents` | `--archetype` |

### How do I create custom archetypes?

1. Create directory in `archetypes/`
2. Add `__archetype__.json` metadata
3. Include project files (docker-compose.yml, src/, etc.)
4. Test with dry-run

See [MULTI_ARCHETYPE_COMPOSITION_DESIGN.md](MULTI_ARCHETYPE_COMPOSITION_DESIGN.md) for details.

---

## Getting Started

### When should I use which archetype?

**Choose based on your project type:**

| Archetype | Use When | Key Features |
|-----------|----------|--------------|
| **base** | Starting from scratch, simple scripts | Minimal setup, no services |
| **rag-project** | Building AI search/Q&A systems | OpenSearch, Ollama, Langfuse, Airflow |
| **api-service** | Creating REST/GraphQL APIs | FastAPI, PostgreSQL, Celery, Redis |
| **frontend** | Building web UIs | Next.js, TypeScript, Apollo, Tailwind |
| **monitoring** | Adding observability | Prometheus, Grafana, Alertmanager |
| **agentic-workflows** | AI agents with complex workflows | Agent framework, orchestration |
| **composite-rag-agents** | Full AI platform | RAG + Agents + Monitoring combined |

**Examples:**
- **Document search app:** Use `rag-project`
- **REST API backend:** Use `api-service`
- **Chat application:** Use `rag-project` + `frontend`
- **Enterprise AI platform:** Use `composite-rag-agents`

### How do I customize an archetype after creation?

**1. Add new services to docker-compose.yml:**
```yaml
services:
  my-new-service:
    image: custom-image:latest
    ports:
      - "8080:8080"
    environment:
      - CONFIG=value
```

**2. Add dependencies:**
```bash
# Python
echo "new-package>=1.0.0" >> requirements.txt
pip install -r requirements.txt

# Node.js (in frontend)
cd frontend && npm install new-package
```

**3. Modify configurations:**
```bash
# Edit environment variables
nano .env

# Update application config
nano config/settings.py
```

**4. Add database migrations:**
```bash
# Create migration
alembic revision --autogenerate -m "Add feature"

# Apply migration
alembic upgrade head
```

**5. Extend the Makefile:**
```makefile
# Add custom commands
.PHONY: my-command
my-command:
	@echo "Running custom command"
	docker-compose exec app python scripts/my_script.py
```

### How do I add new services to an existing project?

**Option 1: Manual addition (recommended for custom services)**
```bash
# 1. Edit docker-compose.yml
nano docker-compose.yml

# 2. Add service definition
services:
  my-service:
    image: service:latest
    # ... configuration

# 3. Update .env with new variables
echo "MY_SERVICE_PORT=8080" >> .env

# 4. Start the new service
docker-compose up -d my-service
```

**Option 2: Merge from another archetype**
```bash
# Use the composition system
./scripts/docker-compose-merger.sh \
  --base docker-compose.yml \
  --overlay archetypes/monitoring/docker-compose.yml \
  --output docker-compose.merged.yml

# Review and apply
mv docker-compose.merged.yml docker-compose.yml
docker-compose up -d
```

### How do I handle template updates?

**Check for updates:**
```bash
./scripts/check-template-updates.sh
```

**Apply updates (safe method):**
```bash
# 1. Check what changed
./scripts/manage-template-updates.sh --check

# 2. Preview changes
./scripts/manage-template-updates.sh --preview

# 3. Apply non-conflicting updates
./scripts/manage-template-updates.sh --apply-safe

# 4. Manually review conflicts
./scripts/conflict-resolver.sh
```

**Selective updates:**
```bash
# Update only specific components
./scripts/sync-template.sh --only=docker-compose
./scripts/sync-template.sh --only=.devcontainer
./scripts/sync-template.sh --only=scripts
```

**See [UPDATES_GUIDE.md](UPDATES_GUIDE.md) for full details.**

### What are production deployment considerations?

**Security:**
- ❌ Don't use `.env` files in production (use secrets manager)
- ✅ Use environment-specific configs
- ✅ Enable HTTPS/TLS
- ✅ Implement authentication & authorization
- ✅ Set up rate limiting
- ✅ Configure CORS properly

**Performance:**
- ✅ Use production ASGI server (uvicorn/gunicorn)
- ✅ Enable connection pooling (database, Redis)
- ✅ Configure caching strategies
- ✅ Set up CDN for static assets
- ✅ Optimize Docker images (multi-stage builds)
- ✅ Set resource limits (CPU, memory)

**Monitoring:**
- ✅ Add health check endpoints
- ✅ Enable application logging
- ✅ Set up Prometheus/Grafana (use monitoring archetype)
- ✅ Configure alerting
- ✅ Track LLM costs (Langfuse)

**Infrastructure:**
- ✅ Use container orchestration (Kubernetes, ECS)
- ✅ Set up load balancing
- ✅ Configure auto-scaling
- ✅ Implement backup strategy
- ✅ Plan disaster recovery

**Docker changes for production:**
```dockerfile
# Development
FROM python:3.11

# Production
FROM python:3.11-slim AS builder
# Build dependencies
FROM python:3.11-slim
COPY --from=builder /app /app
USER nobody
```

**Environment separation:**
```bash
# Development
docker-compose.yml

# Production
docker-compose.prod.yml  # Optimized for production
docker-compose up -f docker-compose.prod.yml
```

**See our production deployment guide** (coming soon) for cloud-specific instructions (AWS, Azure, GCP).

### What are the prerequisites?

**Required:**
- Docker Desktop (latest version)
- VS Code (latest version)
- Git (2.30+)

**System requirements:**
- 8GB RAM minimum (16GB recommended)
- 10GB free disk space
- macOS 10.15+, Windows 10/11 (with WSL2), or Linux

### How long does setup take?

**First time setup:** 60-90 minutes
- Installing prerequisites: 15 min
- Building Docker image: 20 min
- Configuring VS Code: 15 min
- Setting up AI: 10 min
- Testing everything: 10 min

**Creating new projects:** 2-5 minutes
- Using template script: 2 min
- Manual setup: 5 min

**Daily startup:** 30 seconds
- Container starts automatically
- Extensions load
- Ready to code!

### Can I use my existing projects?

Yes! Two approaches:

**1. Add template to existing project:**
```bash
# Copy template files to your project
cp -r dev-environment-template/.devcontainer ./
cp dev-environment-template/docker-compose.yml ./
cp dev-environment-template/Dockerfile ./

# Customize as needed
# Rebuild container
docker-compose build dev
```

**2. Migrate project into template:**
```bash
# Create new project from template
./create-project.sh --name my-existing-project

# Copy your code
cp -r ~/old-project/src ./src
cp -r ~/old-project/tests ./tests

# Update dependencies
# requirements.txt, package.json, etc.
```

### Do I need to know Docker?

**Minimum knowledge needed:**
- What containers are (isolated environments)
- Basic commands: `docker-compose up/down`
- How to read Dockerfile basics

**You don't need to know:**
- Advanced Docker networking
- Kubernetes
- Docker Swarm
- Image optimization techniques

**Learn as you go:**
- Template handles most Docker complexity
- Documentation explains everything
- Common tasks are scripted

---

## Docker & Containers

### Why is the Docker image so large?

**Typical size:** 2-4 GB

**Includes:**
- Base OS (Ubuntu 24.04)
- Multiple language runtimes (C++, Python, Node.js)
- Development tools (Git, curl, vim)
- Build systems (CMake, Make, npm)

**To reduce size:**
```dockerfile
# Use slim base image
FROM python:3.11-slim

# Multi-stage build
FROM node:20 as builder
# Build here
FROM node:20-slim
COPY --from=builder /build ./
```

### How do I add new tools to the container?

**Temporarily (testing):**
```bash
docker-compose exec dev bash
apt-get update && apt-get install -y tool-name
```

**Permanently (all projects):**
```dockerfile
# Edit Dockerfile
RUN apt-get update && apt-get install -y \
    tool-name \
    another-tool \
    && rm -rf /var/lib/apt/lists/*

# Rebuild
docker-compose build dev
```

### Can I use multiple versions of Python/Node?

Yes! Several approaches:

**1. Use version managers in container:**
```dockerfile
# Install pyenv for Python
RUN curl https://pyenv.run | bash
RUN pyenv install 3.11.0
RUN pyenv install 3.12.0

# Or nvm for Node
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
```

**2. Create separate services:**
```yaml
services:
  dev-py311:
    image: python:3.11
  dev-py312:
    image: python:3.12
```

**3. Use different projects:**
```bash
# Python 3.11 project
./create-project.sh --name project-311
# Edit Dockerfile to use python:3.11

# Python 3.12 project
./create-project.sh --name project-312
# Edit Dockerfile to use python:3.12
```

### What happens to my data when container stops?

**Persisted (safe):**
- Files in project directory (mounted volume)
- Named Docker volumes
- Databases with volume mounts

**Lost (not persisted):**
- Temporary files in `/tmp`
- Packages installed with `apt-get` (unless in Dockerfile)
- Environment variables set in session

**Best practice:**
- Keep all code in mounted directory
- Define dependencies in requirements.txt/package.json
- Store data in volumes or external databases

### Can I run multiple projects simultaneously?

Yes!

```bash
# Project 1
cd ~/projects/project1
docker-compose up -d dev

# Project 2
cd ~/projects/project2
docker-compose up -d dev

# Both running independently
docker ps
```

**Port conflicts:**
Change ports in docker-compose.yml:
```yaml
# Project 1: port 8000
ports: ["8000:8000"]

# Project 2: port 8001
ports: ["8001:8000"]
```

---

## VS Code & Extensions

### Do my VS Code extensions work in containers?

**Yes, but with categories:**

**Automatically work:**
- Language support (Python, JavaScript)
- Linters (ESLint, Pylint)
- Formatters (Prettier, Black)
- Git integration
- Continue AI

**May need configuration:**
- Extensions requiring local tools
- Extensions with container-specific settings

**Don't work in containers:**
- UI themes (installed locally)
- Keybindings (set locally)
- Window/panel extensions

**Install in container:**
```json
// .devcontainer/devcontainer.json
{
  "extensions": [
    "ms-python.python",
    "dbaeumer.vscode-eslint",
    "continue.continue"
  ]
}
```

### Can I use my personal VS Code settings?

**Yes!** Four ways:

1. **Settings Sync (easiest):**
   - Enable in VS Code
   - Settings automatically sync
   - Works everywhere

2. **Merge script:**
   ```bash
   ./scripts/merge-vscode-settings.sh
   ```

3. **Manual merge:**
   - Copy your settings.json
   - Keep template container settings
   - Merge carefully

4. **Personal overlay:**
   - Create .vscode/settings.personal.json
   - Apply when needed

See: [Personal VS Code Settings Guide](docs/PERSONAL_VSCODE_SETTINGS.md)

### How do I debug in the container?

**Python:**
```python
# Set breakpoint
import pdb; pdb.set_trace()

# Or in VS Code:
# 1. Set breakpoint (F9)
# 2. Press F5
# 3. Select "Python: Current File"
```

**Node.js:**
```javascript
// Set breakpoint
debugger;

// Or in VS Code:
// 1. Set breakpoint (F9)
// 2. Press F5
// 3. Select "Node: Launch Program"
```

**C++:**
```cpp
// Compile with debug symbols
g++ -g -o app main.cpp

// Debug in VS Code
// launch.json configured in template
```

### Can I use remote development features?

**Yes!** Template supports:

✅ **Dev Containers** - Built-in
✅ **SSH Remote** - Connect to remote server
✅ **WSL** - Windows Subsystem for Linux
✅ **GitHub Codespaces** - Cloud development

**Workflow:**
```bash
# Local Dev Container
code .
# Reopen in Container

# Remote SSH
code --remote ssh-remote+server .

# GitHub Codespaces
# Click "Code" → "Codespaces" → "Create"
```

---

## AI Assistants

### Which AI models are supported?

**25+ models from:**

**Anthropic (Claude):**
- Opus 4.1 (complex reasoning)
- Sonnet 4.5 (balanced)
- Sonnet 4 (fast)
- Haiku (quick responses)

**OpenAI:**
- GPT-4o (advanced)
- o1-preview (reasoning)
- o1-mini (quick reasoning)

**Google Gemini:**
- 2.0 Flash (latest)
- 1.5 Pro (production)

**Others:**
- Mistral, DeepSeek, Perplexity, Cohere
- Local: Ollama, LM Studio

### Do I need API keys for all providers?

**No!** Choose what you need:

**Minimum (free tier):**
- Anthropic API key (Claude)
  - Free tier: Limited usage
  - Paid: Pay per use

**Optional:**
- OpenAI (GPT models)
- Google (Gemini models)
- Others as desired

**Recommendation:**
Start with Claude (Anthropic) only.

### How much do AI API calls cost?

**Anthropic (Claude):**
- Haiku: $0.25 / 1M input tokens
- Sonnet: $3 / 1M input tokens
- Opus: $15 / 1M input tokens

**OpenAI (GPT):**
- GPT-4o: $2.50 / 1M input tokens
- GPT-4o mini: $0.15 / 1M input tokens

**Typical usage:**
- 100 AI requests/day ≈ $1-5/month
- Heavy use: $10-20/month
- Team: $50-100/month

**Free tiers:**
- Most providers offer trial credits
- Some have free quotas

### Can I use AI offline?

**With local models:**
```bash
# Install Ollama
curl https://ollama.ai/install.sh | sh

# Run local model
ollama run llama2

# Configure in Continue
{
  "models": [{
    "title": "Llama 2",
    "provider": "ollama",
    "model": "llama2"
  }]
}
```

**Limitations:**
- Slower than cloud models
- Less capable
- Requires GPU for good performance

### How does AI access my code?

**Context provided:**
- Selected code only
- Files you explicitly reference (@files)
- Git history if requested (@git)

**NOT accessed:**
- Unselected code
- .env files (secrets)
- Private tokens
- Other projects

**Privacy:**
- Code sent to AI provider APIs
- Read provider privacy policies
- Use local models for sensitive code

---

## Secrets & Security

### Where should I store API keys?

**Development:**
```bash
# .env.local file
cp .env.local.example .env.local
nano .env.local
```

**GitHub Codespaces:**
```bash
# Repository secrets
Settings → Secrets → Codespaces → New secret
```

**Production:**
```bash
# Cloud secret management
AWS Secrets Manager
Azure Key Vault
```

See: [Secrets Management Guide](docs/SECRETS_MANAGEMENT.md)

### Is .env.local secure?

**Security level:** ⚠️ Medium

**Protections:**
- ✅ Not committed to git (.gitignore)
- ✅ Local to your machine
- ✅ File permissions (chmod 600)

**Risks:**
- ⚠️ Plain text on disk
- ⚠️ Can be accidentally committed
- ⚠️ Backup software may copy

**Best for:**
- Personal development
- Testing
- Non-production environments

**Not for:**
- Production secrets
- Team-shared keys
- Compliance requirements

### How do I rotate API keys?

**Process:**
```bash
# 1. Generate new key from provider
# Visit: console.anthropic.com

# 2. Test new key
export ANTHROPIC_API_KEY=sk-ant-new_key
python test.py

# 3. Update everywhere
nano .env.local  # Update key

# GitHub Codespaces
# Settings → Secrets → Edit

# 4. Verify working
./test-api.sh

# 5. Revoke old key
# Provider dashboard → Revoke

# 6. Document rotation
echo "$(date): Rotated Anthropic key" >> .secret-rotations.log
```

**Schedule:**
- Development keys: 90 days
- Production keys: 60 days
- Compromised keys: Immediately

### Can teammates see my .env.local?

**No!**
- .env.local is in .gitignore
- Never committed to git
- Each developer has their own
- Secrets stay local

**Team secrets:**
Use GitHub Codespaces secrets for shared keys:
```bash
# Organization secrets
https://github.com/organizations/ORG/settings/secrets/codespaces
```

---

## Updates & Maintenance

### How often should I update?

**Template repository:**
- Check monthly
- Apply security patches immediately
- Feature updates quarterly

**Project using template:**
- Check quarterly
- Critical patches immediately
- Features when convenient

**Dependencies:**
- Python/Node packages: Monthly
- Docker base image: Quarterly
- VS Code extensions: Automatic

### Will updates break my project?

**No, if you:**
- ✅ Review changelog before updating
- ✅ Test in development first
- ✅ Keep customizations minimal
- ✅ Use version control

**Template versioning:**
```bash
# Check your version
cat .template-version
v1.2.0

# Check latest
./scripts/check-template-updates.sh
Latest: v1.3.0

# Update when ready
./scripts/sync-template.sh
```

**Rollback if needed:**
```bash
# Restore previous version
git checkout .template-version
git checkout Dockerfile docker-compose.yml
docker-compose build dev
```

### How do I keep dependencies updated?

**Python:**
```bash
# Update packages
pip list --outdated
pip install --upgrade package-name

# Update requirements.txt
pip freeze > requirements.txt

# Or use pip-review
pip install pip-review
pip-review --auto
```

**Node.js:**
```bash
# Check outdated
npm outdated

# Update packages
npm update

# Update to latest
npm install package-name@latest

# Or use npm-check-updates
npx npm-check-updates -u
npm install
```

**Docker base image:**
```dockerfile
# Specify version tags
FROM python:3.11.5  # Specific version
FROM python:3.11    # Minor version
FROM python:3       # Major version (not recommended)
```

---

## Team Collaboration

### How do I share this with my team?

**1. Push to GitHub:**
```bash
git remote add origin https://github.com/LeMazOrg/dev-template.git
git push -u origin main
```

**2. Enable as template:**
```bash
# GitHub → Settings → Template repository ✅
```

**3. Team members use it:**
```bash
# Click "Use this template"
# Or clone:
git clone https://github.com/LeMazOrg/dev-template.git
```

**4. Share secrets:**
```bash
# Use GitHub organization secrets
# Or team password manager
```

### Can we customize the template?

**Yes! Recommended customizations:**

**Add team tools:**
```dockerfile
# Add company-specific tools
RUN pip install company-internal-package
```

**Team-specific prompts:**
```markdown
# .vscode/prompts/company-standards.md
Enforce company coding standards:
- Use TypeScript
- Follow style guide X
- Include tests
```

**Project templates:**
```bash
# templates/fastapi-project/
# templates/react-project/
# templates/ml-project/
```

**Custom scripts:**
```bash
# scripts/deploy-to-staging.sh
# scripts/run-e2e-tests.sh
```

### How do we handle different project requirements?

**Option 1: Single template with flags:**
```bash
./create-project.sh --name api --type fastapi
./create-project.sh --name web --type react
```

**Option 2: Multiple templates:**
```bash
dev-template-python/
dev-template-node/
dev-template-fullstack/
```

**Option 3: Docker Compose profiles:**
```yaml
services:
  postgres:
    profiles: ["database"]
  redis:
    profiles: ["cache"]

# Use: docker-compose --profile database up
```

### What if team members use different OS?

**No problem!** Template works on:
- ✅ macOS (Intel & Apple Silicon)
- ✅ Windows (with WSL2)
- ✅ Linux (any distribution)

**Everyone gets:**
- Same container environment
- Same tools and versions
- Same development experience

**Platform-specific notes:**
- Windows: Use WSL2 (not native Windows)
- macOS: File performance with delegated volumes
- Linux: Native performance

---

## Platform Support

### Does this work on Windows?

**Yes, with WSL2:**

**Requirements:**
```bash
# 1. Enable WSL2
wsl --install

# 2. Install Ubuntu
wsl --install -d Ubuntu

# 3. Install Docker Desktop for Windows
# Enable WSL2 integration

# 4. Work in WSL2
wsl
cd /mnt/c/projects
git clone ...
```

**Performance:**
- ✅ Native Linux performance in WSL2
- ⚠️ Slower if files on Windows drive (C:)
- ✅ Fast if files on Linux filesystem

**Recommendation:**
Keep projects in WSL2 filesystem:
```bash
# Good: ~/projects (Linux)
# Bad: /mnt/c/Users/You/projects (Windows)
```

### Does this work on Apple Silicon (M1/M2/M3)?

**Yes!** Fully supported:

```bash
# Docker builds ARM images automatically
# All tools work natively
# Performance excellent
```

**If needed, force x86:**
```dockerfile
FROM --platform=linux/amd64 python:3.11
```

### What about Chromebooks?

**Yes, with Linux (Beta):**

**Enable:**
```bash
# Settings → Advanced → Developers → Linux (Beta)
# Install Docker, VS Code, Git
```

**Or use GitHub Codespaces:**
```bash
# Best option for Chromebooks
# Full cloud development environment
# Browser-based VS Code
```

---

## Troubleshooting

### Container won't start - what do I check first?

**Quick diagnostics:**
```bash
# 1. Is Docker running?
docker ps

# 2. Check logs
docker-compose logs dev

# 3. Port conflict?
lsof -i :8000

# 4. Rebuild
docker-compose build --no-cache dev
docker-compose up -d dev

# 5. Check disk space
df -h
```

**Most common causes:**
1. Docker not running
2. Port already in use
3. Out of disk space
4. Syntax error in Dockerfile

See: [Troubleshooting Guide](docs/TROUBLESHOOTING.md)

### VS Code not connecting to container?

**Solutions:**
```bash
# 1. Restart VS Code
# Cmd/Ctrl+Shift+P → "Developer: Reload Window"

# 2. Rebuild container
# Cmd/Ctrl+Shift+P → "Remote-Containers: Rebuild Container"

# 3. Check Docker
docker ps

# 4. Reset Dev Containers
rm -rf ~/.vscode-server
# Reopen VS Code

# 5. Check extension
code --list-extensions | grep ms-vscode-remote.remote-containers
```

### AI not responding?

**Check list:**
```bash
# 1. API key set?
echo $ANTHROPIC_API_KEY

# 2. Key valid?
curl -H "x-api-key: $ANTHROPIC_API_KEY" \
  https://api.anthropic.com/v1/messages

# 3. Continue installed?
code --list-extensions | grep continue

# 4. Reload VS Code
# Cmd/Ctrl+Shift+P → "Reload Window"

# 5. Check Continue logs
# Cmd/Ctrl+Shift+P → "Continue: Show Logs"
```

### Still stuck?

**Get help:**

1. **Check documentation:**
   - [Troubleshooting Guide](docs/TROUBLESHOOTING.md)
   - [This FAQ](docs/FAQ.md)
   - [Usage Guide](docs/USAGE_GUIDE.md)

2. **Search GitHub issues:**
   - Someone may have had same problem
   - Solution might be there

3. **Create issue:**
   - Include error message
   - Steps to reproduce
   - System info (OS, Docker version)
   - Logs

4. **Community:**
   - Slack/Discord
   - Stack Overflow
   - GitHub Discussions

---

## Quick Reference

### Essential Commands

```bash
# Create project
./create-project.sh --name my-app

# Start container
docker-compose up -d dev

# Enter container
docker-compose exec dev bash

# Stop container
docker-compose down

# Rebuild
docker-compose build dev

# Check for updates
./scripts/check-template-updates.sh

# Open in VS Code
code .
```

### Essential Files

```bash
.devcontainer/devcontainer.json   # VS Code config
Dockerfile                         # Container image
docker-compose.yml                 # Services
.env.local                         # Your secrets
.vscode/settings.json              # VS Code settings
.continue/config.json              # AI config
```

### Getting Help

| Resource | URL |
|----------|-----|
| Documentation | [docs/](docs/) |
| GitHub Issues | github.com/USER/REPO/issues |
| Discussions | github.com/USER/REPO/discussions |
| Email | support@example.com |

---

## Additional Resources

### Documentation
- [Complete Setup Guide](docs/SETUP_GUIDE.md)
- [Usage Guide](docs/USAGE_GUIDE.md)
- [Updates Guide](docs/UPDATES_GUIDE.md)
- [Secrets Management](docs/SECRETS_MANAGEMENT.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)

### External Links
- [Docker Documentation](https://docs.docker.com/)
- [VS Code Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers)
- [Continue.dev](https://continue.dev/docs)
- [Anthropic API](https://docs.anthropic.com/)

---

**Don't see your question?**

- [Create an issue](https://github.com/USER/REPO/issues/new)
- [Ask in discussions](https://github.com/USER/REPO/discussions)
- Email: support@example.com

---

**Last Updated:** October 20, 2025
**Version:** 2.0
