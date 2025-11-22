# Usage Guide: Daily Workflows

**Version:** 2.0
**Last Updated:** November 21, 2025

Complete guide to using your dev environment template for daily development tasks, AI-assisted coding, team collaboration, and creating projects with archetypes.

---

## 📖 Table of Contents

- [Getting Started](#getting-started)
- [Creating Projects with Archetypes](#creating-projects-with-archetypes)
- [Daily Workflows](#daily-workflows)
- [AI-Assisted Coding](#ai-assisted-coding)
- [Docker Operations](#docker-operations)
- [VS Code Tips](#vs-code-tips)
- [Testing & Debugging](#testing--debugging)
- [Team Collaboration](#team-collaboration)
- [Best Practices](#best-practices)
- [Common Tasks](#common-tasks)

---

## Getting Started

### Opening Your Project

**Method 1: VS Code Command Line**
```bash
# Navigate to project
cd my-project

# Open in VS Code
code .

# Reopen in container
# Press: Cmd/Ctrl+Shift+P
# Type: "Remote-Containers: Reopen in Container"
# Press Enter

# Wait for container to start (20-30 seconds)
# Extensions load automatically
# You're ready to code!
```

**Method 2: VS Code GUI**
```bash
# 1. Open VS Code
# 2. File → Open Folder → Select your project
# 3. VS Code detects .devcontainer/devcontainer.json
# 4. Click "Reopen in Container" popup
# 5. Wait for container to start
```

**Method 3: Direct Container Entry**
```bash
# Start container without VS Code
docker-compose up -d dev

# Enter container shell
docker-compose exec dev bash

# You're inside the container
# All tools are available
```

### First Time Setup Checklist

After opening a new project for the first time:

- [ ] Container built successfully
- [ ] VS Code extensions installed
- [ ] Terminal opens in container
- [ ] Python/Node/C++ versions correct
- [ ] API keys loaded (check with `env | grep API`)
- [ ] Continue AI working (Cmd/Ctrl+L)
- [ ] Git configured

**Verify tools:**
```bash
# Check all tools are available
python3 --version    # Should show: Python 3.11+
node --version       # Should show: v20.x.x
npm --version        # Should show: 10.x.x
g++ --version        # Should show: g++ 13+
git --version        # Should show: git 2.30+

# Check AI is configured
ls -la ~/.continue/config.json
```


## Creating Projects with Archetypes

### Quick Project Creation

```bash
# Navigate to your template directory
cd ~/dev-environment-template

# List available archetypes
./create-project.sh --list-archetypes

# Create a new project
./create-project.sh --name my-project --archetype base

# Create with features
./create-project.sh --name my-app \\
  --archetype rag-project \\
  --add-features monitoring

# Preview before creating (dry-run)
./create-project.sh --name test-app \\
  --archetype rag-project \\
  --dry-run
```

### Common Archetype Workflows

**Creating a RAG Project:**
```bash
# 1. Create project with GitHub integration
./create-project.sh --name doc-search \\
  --archetype rag-project \\
  --github \\
  --description "Document search with AI"

# 2. Configure
cd doc-search
cp .env.example .env
# Edit .env with API keys

# 3. Start services
docker-compose up -d

# 4. Test
curl http://localhost:8000/health
```

**Creating API with Monitoring:**
```bash
# 1. Create
./create-project.sh --name my-api \\
  --archetype api-service \\
  --add-features monitoring \\
  --github

# 2. Start all services
cd my-api
docker-compose up -d

# 3. Access
# API: http://localhost:8000
# Grafana: http://localhost:3000
# Prometheus: http://localhost:9090
```

**For complete archetype documentation:** [ARCHETYPE_GUIDE.md](ARCHETYPE_GUIDE.md)

---

## Daily Workflows

### Morning Startup Routine

```bash
# 1. Navigate to project
cd ~/projects/my-app

# 2. Pull latest changes (if working with team)
git pull origin main

# 3. Start development environment
docker-compose up -d dev

# 4. Open in VS Code
code .

# 5. Reopen in container (if not automatic)
# Cmd/Ctrl+Shift+P → "Reopen in Container"

# 6. Check what you're working on
git status
git log --oneline -5

# 7. Start your task!
```

### During Development

**Quick AI assistance:**
```bash
# Select code → Press Cmd/Ctrl+Shift+E → Type command

/explain        # "What does this do?"
/refactor       # "How can I improve this?"
/test           # "Generate tests for this"
/document       # "Add documentation"
/optimize       # "How to make this faster?"
/debug          # "Help me debug this"
```

**Running code:**
```bash
# Python
python3 src/main.py

# Node.js
node src/app.js
npm start

# C++
g++ -o app src/main.cpp && ./app

# Run tests
npm test
pytest tests/
```

**Installing dependencies:**
```bash
# Python
pip install package-name
pip install -r requirements.txt

# Node.js
npm install package-name
npm install

# System packages (inside container)
apt-get update && apt-get install -y package-name
```

### End of Day Routine

```bash
# 1. Save all files (Cmd/Ctrl+S)

# 2. Run tests to ensure nothing broke
npm test          # Node.js
pytest            # Python
make test         # C++

# 3. Stage and review changes
git status
git diff

# 4. Commit your work
git add .
git commit -m "feat: add user authentication"

# 5. Push to remote (if ready)
git push origin feature/auth

# 6. Stop development container (optional)
docker-compose down

# Or leave it running for tomorrow
```

---

## AI-Assisted Coding

### Using Continue AI

**Open Continue Panel:**
```bash
# Keyboard shortcut
Cmd+L (Mac)
Ctrl+L (Windows/Linux)

# Or via Command Palette
Cmd/Ctrl+Shift+P → "Continue: Open Continue"
```

**Chat with AI:**
```
You: "How do I read a CSV file in Python?"
Claude: "Here's how to read a CSV file using pandas..."

You: "@files explain the authentication flow"
Claude: "Looking at your codebase, the authentication flow..."

You: "Generate a REST API endpoint for user login"
Claude: "Here's a FastAPI endpoint for user login..."
```

**Using Context:**
```
@files          # Reference all workspace files
@git            # Reference git history
@codebase       # Search entire codebase
@terminal       # Include terminal output
@web            # Search web for information
@code           # Reference specific files
```

**Example workflows:**

**1. Understanding Code**
```bash
# Select code block
# Press Cmd/Ctrl+Shift+E
# Type: /explain

AI explains:
- What the code does
- How it works
- Edge cases
- Potential issues
```

**2. Refactoring**
```bash
# Select function
# Press Cmd/Ctrl+Shift+E
# Type: /refactor

AI suggests:
- Better variable names
- Design patterns
- Code organization
- Performance improvements
```

**3. Test Generation**
```bash
# Select function
# Press Cmd/Ctrl+Shift+E
# Type: /test

AI generates:
- Unit tests
- Edge case tests
- Mock data
- Test fixtures
```

**4. Documentation**
```bash
# Select function/class
# Press Cmd/Ctrl+Shift+E
# Type: /document

AI adds:
- Docstrings
- Parameter descriptions
- Return type documentation
- Usage examples
```

### Custom AI Commands

**Available commands:**
| Command | Purpose | Example Use |
|---------|---------|-------------|
| `/explain` | Understand code | Selected complex algorithm |
| `/refactor` | Improve code | Legacy function |
| `/test` | Generate tests | New function |
| `/document` | Add docs | Public API |
| `/optimize` | Performance | Slow loop |
| `/debug` | Find bugs | Failing test |
| `/architecture` | Design review | Module structure |
| `/security` | Security check | Auth code |

**Custom workflow example:**
```bash
# 1. Write initial code
def process_data(data):
    # TODO: implement
    pass

# 2. Use AI to implement
# Select function → Cmd/Ctrl+L
"Implement this function to filter and transform user data"

# 3. Review AI suggestion
# AI provides implementation

# 4. Generate tests
# Select function → Cmd/Ctrl+Shift+E → /test

# 5. Add documentation
# Select function → Cmd/Ctrl+Shift+E → /document

# 6. Optimize if needed
# Select function → Cmd/Ctrl+Shift+E → /optimize
```

### Model Selection

**Choose the right model for the task:**

```bash
# Open Continue (Cmd/Ctrl+L)
# Click model dropdown at top

Complex reasoning:
- Claude Opus 4.1
- o1-preview

Fast coding:
- Claude Sonnet 4.5
- Codestral
- GPT-4o mini

Documentation:
- Claude Sonnet 4.5
- GPT-4o

Quick fixes:
- Claude Haiku
- Gemini 2.0 Flash

Large context:
- Claude Sonnet 4.5 (200k tokens)
- Gemini 1.5 Pro (1M tokens)
```

---

## Docker Operations

### Container Management

**Start containers:**
```bash
# Start dev container only
docker-compose up -d dev

# Start all services
docker-compose up -d

# Start with logs
docker-compose up dev

# Start specific services
docker-compose up -d dev postgres redis
```

**Stop containers:**
```bash
# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v

# Stop specific service
docker-compose stop dev
```

**Container status:**
```bash
# List running containers
docker-compose ps

# View logs
docker-compose logs dev
docker-compose logs -f dev  # Follow logs

# View resource usage
docker stats
```

**Enter containers:**
```bash
# Bash shell
docker-compose exec dev bash

# As root
docker-compose exec --user root dev bash

# Run single command
docker-compose exec dev python3 script.py

# Interactive Python
docker-compose exec dev python3
```

### Rebuilding Containers

**When to rebuild:**
- Changed Dockerfile
- Updated dependencies in requirements.txt
- Added system packages
- Modified .devcontainer/devcontainer.json

**How to rebuild:**
```bash
# Rebuild without cache
docker-compose build --no-cache dev

# Rebuild and restart
docker-compose up -d --build dev

# In VS Code: Rebuild Container
# Cmd/Ctrl+Shift+P → "Remote-Containers: Rebuild Container"
```

### Managing Container Storage

**Clean up Docker:**
```bash
# Remove unused images, containers, networks
docker system prune

# Remove everything (caution!)
docker system prune -a --volumes

# Check disk usage
docker system df

# Remove specific image
docker rmi image-name
```

### Docker Troubleshooting

**Container won't start:**
```bash
# Check logs
docker-compose logs dev

# Rebuild without cache
docker-compose build --no-cache dev

# Check Docker is running
docker ps
```

**Out of disk space:**
```bash
# Clean up
docker system prune -a --volumes

# Check usage
docker system df
```

**Permission issues:**
```bash
# Linux: Add user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

---

## VS Code Tips

### Essential Shortcuts

**Navigation:**
| Action | macOS | Windows/Linux |
|--------|-------|---------------|
| Command Palette | `Cmd+Shift+P` | `Ctrl+Shift+P` |
| Quick Open | `Cmd+P` | `Ctrl+P` |
| Go to Symbol | `Cmd+Shift+O` | `Ctrl+Shift+O` |
| Go to Definition | `F12` | `F12` |
| Go to References | `Shift+F12` | `Shift+F12` |
| Peek Definition | `Opt+F12` | `Alt+F12` |

**Editing:**
| Action | macOS | Windows/Linux |
|--------|-------|---------------|
| Format Document | `Shift+Opt+F` | `Shift+Alt+F` |
| Comment Line | `Cmd+/` | `Ctrl+/` |
| Multi-cursor | `Opt+Click` | `Alt+Click` |
| Select Next | `Cmd+D` | `Ctrl+D` |
| Find | `Cmd+F` | `Ctrl+F` |
| Replace | `Cmd+Opt+F` | `Ctrl+H` |

**AI Shortcuts:**
| Action | macOS | Windows/Linux |
|--------|-------|---------------|
| Open Continue | `Cmd+L` | `Ctrl+L` |
| AI Commands | `Cmd+Shift+E` | `Ctrl+Shift+E` |
| Inline Suggest | `Tab` | `Tab` |

### Workspace Features

**Multi-root workspaces:**
```bash
# Open multiple folders
File → Add Folder to Workspace

# Save workspace
File → Save Workspace As
```

**Tasks:**
```bash
# Run task
Cmd/Ctrl+Shift+B

# Configure tasks
Edit .vscode/tasks.json

# Example: Run tests
{
  "label": "Run Tests",
  "type": "shell",
  "command": "pytest tests/",
  "group": "test"
}
```

**Debugging:**
```bash
# Start debugging
F5

# Toggle breakpoint
F9

# Step over
F10

# Step into
F11

# Continue
F5
```

### Extensions Workflow

**Recommended workflow:**
```bash
# Install from extensions.json
# VS Code prompts on project open

# Or manually:
Cmd/Ctrl+Shift+X → Search → Install

# Key extensions:
- Python
- Pylance
- ESLint
- Prettier
- GitLens
- Docker
- Continue
- Dev Containers
```

---

## Testing & Debugging

### Python Testing

**pytest:**
```bash
# Run all tests
pytest

# Run specific file
pytest tests/test_auth.py

# Run specific test
pytest tests/test_auth.py::test_login

# With coverage
pytest --cov=src tests/

# Verbose output
pytest -v

# Stop on first failure
pytest -x

# Run in parallel
pytest -n auto
```

**unittest:**
```bash
# Run all tests
python3 -m unittest discover

# Run specific test
python3 -m unittest tests.test_auth.TestAuth
```

### Node.js Testing

**Jest:**
```bash
# Run all tests
npm test

# Watch mode
npm test -- --watch

# Coverage
npm test -- --coverage

# Specific file
npm test -- auth.test.js
```

**Mocha:**
```bash
# Run tests
npm test

# Watch mode
npm test -- --watch

# Specific file
npx mocha tests/auth.test.js
```

### C++ Testing

**Google Test:**
```bash
# Build tests
mkdir build && cd build
cmake ..
make

# Run tests
./tests/all_tests

# Run with filter
./tests/all_tests --gtest_filter=AuthTest.*
```

### Debugging

**Python debugging:**
```python
# Use built-in debugger
import pdb; pdb.set_trace()

# Or in VS Code:
# 1. Set breakpoint (F9)
# 2. Press F5
# 3. Select "Python: Current File"
```

**Node.js debugging:**
```bash
# In VS Code:
# 1. Set breakpoint (F9)
# 2. Press F5
# 3. Select "Node.js: Launch Program"

# Or command line:
node --inspect-brk src/app.js
```

**C++ debugging (GDB):**
```bash
# Compile with debug symbols
g++ -g -o app src/main.cpp

# Run with GDB
gdb ./app

# GDB commands:
break main      # Set breakpoint
run            # Start program
next           # Step over
step           # Step into
print var      # Print variable
continue       # Continue execution
```

### Debugging in Container

**Attach VS Code debugger:**
```json
// .vscode/launch.json
{
  "name": "Python: Remote Attach",
  "type": "python",
  "request": "attach",
  "connect": {
    "host": "localhost",
    "port": 5678
  }
}
```

**Debug container issues:**
```bash
# Check container logs
docker-compose logs -f dev

# Inspect container
docker-compose exec dev bash

# Check processes
docker-compose exec dev ps aux

# Check network
docker-compose exec dev netstat -tulpn
```

---

## Team Collaboration

### Git Workflow

**Feature branch workflow:**
```bash
# 1. Start new feature
git checkout -b feature/user-authentication

# 2. Make changes and commit frequently
git add src/auth.py
git commit -m "feat: add login function"

# 3. Push to remote
git push -u origin feature/user-authentication

# 4. Create pull request on GitHub

# 5. After review, merge to main
git checkout main
git pull origin main
```

**Handling updates:**
```bash
# Update from main
git checkout feature/my-feature
git fetch origin
git rebase origin/main

# Or merge
git merge origin/main

# Resolve conflicts if any
# Edit conflicted files
git add .
git rebase --continue
```

### Code Review

**Before submitting PR:**
```bash
# Run linting
npm run lint     # JavaScript
black .          # Python
clang-format -i  # C++

# Run tests
npm test
pytest

# Check git diff
git diff main...HEAD

# Ensure commit messages are clear
git log --oneline
```

**Review checklist:**
- [ ] All tests pass
- [ ] Code is linted
- [ ] Documentation updated
- [ ] No console.log / debug statements
- [ ] API keys not committed
- [ ] Secrets in .env files
- [ ] Meaningful commit messages

### Pair Programming

**Using Live Share:**
```bash
# 1. Install Live Share extension
# 2. Click "Live Share" in status bar
# 3. Share link with teammate
# 4. Both can edit, debug, and terminal
```

**Using Continue together:**
```bash
# Share AI-generated code:
# 1. Get AI suggestion
# 2. Review and modify
# 3. Commit to shared branch
# 4. Team can see and improve
```

---

## Best Practices

### Daily Development

✅ **Do:**
- Start day with `git pull`
- Commit frequently with clear messages
- Run tests before pushing
- Use AI for repetitive tasks
- Document as you go
- Review AI suggestions carefully
- Keep dependencies updated
- Use feature branches

❌ **Don't:**
- Commit directly to main
- Push without testing
- Commit secrets or API keys
- Leave debug statements
- Skip code review
- Blindly accept AI code
- Mix unrelated changes
- Force push to shared branches

### Code Quality

**Formatting:**
```bash
# Python - use black
black .

# JavaScript - use prettier
npx prettier --write .

# C++ - use clang-format
find . -name '*.cpp' -o -name '*.h' | xargs clang-format -i
```

**Linting:**
```bash
# Python
pylint src/
flake8 src/

# JavaScript
npm run lint

# Fix automatically
npm run lint -- --fix
```

**Type checking:**
```bash
# Python
mypy src/

# TypeScript
npx tsc --noEmit
```

### Security

**Never commit:**
- API keys
- Passwords
- Tokens
- Private keys
- Database credentials
- AWS credentials

**Use environment variables:**
```python
import os
api_key = os.getenv('ANTHROPIC_API_KEY')
```

**Check before commit:**
```bash
# Scan for secrets
git diff | grep -i "api_key\|password\|secret"

# Use pre-commit hooks
# .git/hooks/pre-commit
```

### Performance

**Profile before optimizing:**
```python
# Python
import cProfile
cProfile.run('my_function()')

# Or use line_profiler
@profile
def my_function():
    pass
```

**Use AI for optimization:**
```bash
# Select slow code
# Cmd/Ctrl+Shift+E → /optimize
# AI suggests improvements
```

---

## Common Tasks

### Adding New Dependencies

**Python:**
```bash
# Install package
pip install requests

# Update requirements.txt
pip freeze > requirements.txt

# Or manually add to requirements.txt
echo "requests==2.31.0" >> requirements.txt

# Team members update
pip install -r requirements.txt
```

**Node.js:**
```bash
# Install package
npm install express

# Automatically updates package.json

# Team members update
npm install
```

**System packages:**
```bash
# Install in container
docker-compose exec dev bash
apt-get update
apt-get install -y package-name

# Or add to Dockerfile for permanent
# Edit Dockerfile:
RUN apt-get update && \
    apt-get install -y package-name

# Rebuild container
docker-compose build dev
```

### Environment Configuration

**Adding new environment variables:**
```bash
# 1. Add to .env.example
echo "NEW_API_KEY=" >> .env.example

# 2. Add to your .env.local
echo "NEW_API_KEY=actual_key" >> .env.local

# 3. Restart container
docker-compose restart dev

# 4. Verify
docker-compose exec dev bash
echo $NEW_API_KEY
```

### Database Operations

**PostgreSQL:**
```bash
# Connect to database
docker-compose exec postgres psql -U user -d dbname

# Run migrations
docker-compose exec dev python manage.py migrate

# Backup database
docker-compose exec postgres pg_dump -U user dbname > backup.sql

# Restore database
docker-compose exec -T postgres psql -U user dbname < backup.sql
```

**MongoDB:**
```bash
# Connect to MongoDB
docker-compose exec mongo mongosh

# Backup
docker-compose exec mongo mongodump --out /backup

# Restore
docker-compose exec mongo mongorestore /backup
```

### File Operations

**Copy files to/from container:**
```bash
# Copy to container
docker cp local-file.txt container-name:/workspace/

# Copy from container
docker cp container-name:/workspace/file.txt ./local-file.txt

# Or use VS Code file explorer
# Files sync automatically in dev container
```

### Running Scheduled Tasks

**Cron jobs in container:**
```bash
# Enter container as root
docker-compose exec --user root dev bash

# Edit crontab
crontab -e

# Add job
0 2 * * * /workspace/scripts/backup.sh

# Verify
crontab -l
```

---

## Summary

This usage guide covers:
- ✅ Daily startup and shutdown routines
- ✅ AI-assisted coding workflows
- ✅ Docker container management
- ✅ VS Code tips and shortcuts
- ✅ Testing and debugging
- ✅ Team collaboration
- ✅ Best practices
- ✅ Common development tasks

**Next Steps:**
- Bookmark this guide for quick reference
- Customize workflows to your needs
- Share best practices with team
- Contribute improvements

**Related Documentation:**
- [Complete Setup Guide](SETUP_GUIDE.md) - Initial setup
- [Updates Guide](UPDATES_GUIDE.md) - Keep template current
- [Secrets Management](SECRETS_MANAGEMENT.md) - Secure API keys
- [Troubleshooting](TROUBLESHOOTING.md) - Fix issues

---

**Happy coding!** 🚀
