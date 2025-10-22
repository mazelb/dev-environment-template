# Troubleshooting Guide

**Version:** 2.0  
**Last Updated:** October 20, 2025  

Complete troubleshooting guide for common issues with your dev environment template.

---

## 📖 Table of Contents

- [Quick Diagnostics](#quick-diagnostics)
- [Docker Issues](#docker-issues)
- [VS Code Issues](#vs-code-issues)
- [Container Issues](#container-issues)
- [AI Assistant Issues](#ai-assistant-issues)
- [Git Issues](#git-issues)
- [Networking Issues](#networking-issues)
- [Performance Issues](#performance-issues)
- [Platform-Specific Issues](#platform-specific-issues)
- [Recovery Procedures](#recovery-procedures)

---

## Quick Diagnostics

### Run Health Check

```bash
# Run comprehensive health check
./scripts/health-check.sh

# Or manually check each component:

# 1. Docker
docker --version
docker-compose --version
docker ps

# 2. VS Code
code --version

# 3. Git
git --version

# 4. Container status
docker-compose ps

# 5. Environment variables
env | grep API_KEY

# 6. Disk space
df -h

# 7. Network
ping -c 3 google.com
```

### Common Quick Fixes

```bash
# Restart Docker
# macOS/Windows: Restart Docker Desktop
# Linux: sudo systemctl restart docker

# Rebuild container
docker-compose down
docker-compose build --no-cache dev
docker-compose up -d dev

# Reload VS Code
# Cmd/Ctrl+Shift+P → "Developer: Reload Window"

# Clean Docker cache
docker system prune -a

# Reset to clean state
git checkout .
docker-compose down -v
docker-compose up -d dev
```

---

## Docker Issues

### Docker Daemon Not Running

**Symptoms:**
- "Cannot connect to the Docker daemon"
- Docker commands fail

**Solution:**

**macOS/Windows:**
```bash
# 1. Open Docker Desktop application
# 2. Wait for "Docker Desktop is running" message
# 3. Verify:
docker ps
```

**Linux:**
```bash
# Start Docker service
sudo systemctl start docker

# Enable on boot
sudo systemctl enable docker

# Check status
sudo systemctl status docker

# Check if running
docker ps
```

### Container Won't Start

**Symptoms:**
- Container exits immediately
- "Error response from daemon"

**Diagnosis:**
```bash
# Check logs
docker-compose logs dev

# Check last 50 lines
docker-compose logs --tail=50 dev

# Follow logs in real-time
docker-compose logs -f dev

# Inspect container
docker-compose ps
docker inspect dev-container
```

**Solutions:**

**1. Port already in use:**
```bash
# Find what's using the port
lsof -i :8000  # macOS/Linux
netstat -ano | findstr :8000  # Windows

# Kill the process
kill -9 <PID>

# Or change port in docker-compose.yml
ports:
  - "8001:8000"  # Use different port
```

**2. Image build failed:**
```bash
# Rebuild without cache
docker-compose build --no-cache dev

# Check Dockerfile syntax
docker-compose config

# Build with verbose output
docker-compose build --progress=plain dev
```

**3. Volume mount issues:**
```bash
# Check volume permissions
ls -la /path/to/project

# Fix permissions (Linux)
sudo chown -R $USER:$USER .

# Remove volumes and recreate
docker-compose down -v
docker-compose up -d dev
```

### Out of Disk Space

**Symptoms:**
- "no space left on device"
- Slow container performance

**Solution:**
```bash
# Check Docker disk usage
docker system df

# Remove unused images
docker image prune -a

# Remove unused containers
docker container prune

# Remove unused volumes
docker volume prune

# Remove everything (caution!)
docker system prune -a --volumes

# On macOS: Increase Docker disk limit
# Docker Desktop → Settings → Resources → Disk image size
```

### Out of Memory

**Symptoms:**
- Container crashes
- "OOMKilled" in logs
- Slow performance

**Solution:**
```bash
# Check memory usage
docker stats

# Increase Docker memory
# Docker Desktop → Settings → Resources → Memory
# Recommended: 4GB minimum, 8GB optimal

# Limit container memory (docker-compose.yml)
services:
  dev:
    mem_limit: 2g
    memswap_limit: 4g
```

### Build Takes Too Long

**Solution:**
```bash
# Use BuildKit for faster builds
export DOCKER_BUILDKIT=1
docker-compose build dev

# Cache dependencies properly
# In Dockerfile:
COPY requirements.txt .
RUN pip install -r requirements.txt  # Cached layer
COPY . .  # Only rebuild if source changes

# Use multi-stage builds
FROM python:3.11 as builder
# Build dependencies
FROM python:3.11-slim
# Copy only what's needed
```

### Permission Denied Errors

**Linux:**
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Log out and back in, or:
newgrp docker

# Verify
docker ps

# If still issues, check socket permissions
sudo chmod 666 /var/run/docker.sock
```

**macOS:**
```bash
# Reset Docker Desktop
# Docker Desktop → Troubleshoot → Reset to factory defaults
```

---

## VS Code Issues

### Extensions Not Installing

**Symptoms:**
- Extensions panel shows errors
- Recommended extensions don't install

**Solution:**
```bash
# 1. Check internet connection
ping -c 3 marketplace.visualstudio.com

# 2. Clear extension cache
# macOS/Linux:
rm -rf ~/.vscode/extensions
# Windows:
rd /s /q "%USERPROFILE%\.vscode\extensions"

# 3. Reinstall VS Code
# Download from: https://code.visualstudio.com/

# 4. Install extensions manually
code --install-extension ms-python.python
code --install-extension dbaeumer.vscode-eslint
code --install-extension ms-vscode-remote.remote-containers

# 5. Check logs
# Help → Toggle Developer Tools → Console
```

### Dev Container Won't Open

**Symptoms:**
- "Failed to open in container"
- Container doesn't start

**Diagnosis:**
```bash
# Check Dev Containers extension
code --list-extensions | grep ms-vscode-remote.remote-containers

# Check Docker
docker ps

# Check .devcontainer/devcontainer.json
cat .devcontainer/devcontainer.json | jq .
```

**Solution:**
```bash
# 1. Rebuild container
# Cmd/Ctrl+Shift+P → "Remote-Containers: Rebuild Container"

# 2. Check logs
# Cmd/Ctrl+Shift+P → "Remote-Containers: Show Log"

# 3. Reset Dev Containers
# Close VS Code
rm -rf ~/.vscode-server
# Reopen project

# 4. Check configuration
# Verify .devcontainer/devcontainer.json syntax:
{
  "name": "Dev Container",
  "dockerComposeFile": "../docker-compose.yml",
  "service": "dev",
  "workspaceFolder": "/workspace"
}
```

### Settings Not Syncing

**Symptoms:**
- Personal settings not applied
- Extensions different across machines

**Solution:**
```bash
# 1. Check Settings Sync status
# Cmd/Ctrl+Shift+P → "Settings Sync: Show Synced Data"

# 2. Sign in again
# Cmd/Ctrl+Shift+P → "Settings Sync: Turn Off"
# Cmd/Ctrl+Shift+P → "Settings Sync: Turn On"

# 3. Force sync
# Cmd/Ctrl+Shift+P → "Settings Sync: Sync Now"

# 4. Check account
# Click account icon (bottom left)
# Verify correct account

# 5. Reset sync
# Settings → Search "settings sync"
# Clear local data and re-sync
```

### Slow Performance

**Symptoms:**
- VS Code lags
- Typing delays
- Extension loading slow

**Solution:**
```bash
# 1. Disable unused extensions
# Extensions panel → Disable extensions you don't need

# 2. Exclude large directories
# Add to .vscode/settings.json:
{
  "files.watcherExclude": {
    "**/node_modules/**": true,
    "**/.git/**": true,
    "**/venv/**": true,
    "**/__pycache__/**": true
  }
}

# 3. Increase memory limit
# Settings → Search "memory"
# Increase memory limit to 4096

# 4. Disable telemetry
{
  "telemetry.telemetryLevel": "off"
}

# 5. Check CPU usage
# Activity Monitor (macOS) / Task Manager (Windows)
# Look for "Code Helper" processes
```

### Terminal Not Working

**Symptoms:**
- Terminal won't open
- Commands don't run

**Solution:**
```bash
# 1. Check default shell
# Terminal → Select Default Profile

# 2. Reset terminal
# Close all terminal panels
# Cmd/Ctrl+Shift+P → "Terminal: Kill All Terminals"
# Open new terminal

# 3. Check shell path (settings.json)
{
  "terminal.integrated.shell.osx": "/bin/bash",
  "terminal.integrated.shell.linux": "/bin/bash",
  "terminal.integrated.shell.windows": "C:\\Windows\\System32\\cmd.exe"
}

# 4. Verify in container
# Make sure you're in Dev Container
# Bottom left should show: "Dev Container: Dev"
```

---

## Container Issues

### Can't Enter Container

**Symptoms:**
- "docker-compose exec" fails
- "no such container"

**Solution:**
```bash
# 1. Check container is running
docker-compose ps

# 2. Start if not running
docker-compose up -d dev

# 3. Try different command
docker-compose exec dev bash
docker-compose exec dev sh
docker exec -it container-name bash

# 4. Check container name
docker ps --format "table {{.Names}}\t{{.Status}}"

# 5. Inspect container
docker-compose ps -q dev
docker inspect $(docker-compose ps -q dev)
```

### Container Exits Immediately

**Symptoms:**
- Container starts then stops
- Exit code 1 or 137

**Diagnosis:**
```bash
# Check exit code
docker-compose ps

# Read logs
docker-compose logs dev

# Check last command
docker inspect container-name | grep -A 5 "Cmd"
```

**Common causes:**

**1. Command fails:**
```bash
# Check CMD/ENTRYPOINT in Dockerfile
CMD ["python", "app.py"]  # If app.py fails, container exits

# Use long-running command for debugging
CMD ["tail", "-f", "/dev/null"]
```

**2. Missing dependencies:**
```bash
# Rebuild with all dependencies
docker-compose build --no-cache dev
docker-compose up dev  # Watch for errors
```

**3. Permission issues:**
```bash
# Check user in container
docker-compose exec dev whoami

# Run as root if needed
docker-compose exec --user root dev bash
```

### Tools Not Available in Container

**Symptoms:**
- "command not found" in container
- Missing Python packages

**Solution:**
```bash
# 1. Install temporarily
docker-compose exec dev bash
apt-get update && apt-get install -y tool-name

# 2. Add permanently to Dockerfile
RUN apt-get update && apt-get install -y \
    tool-name \
    && rm -rf /var/lib/apt/lists/*

# 3. Rebuild
docker-compose build dev

# 4. For Python packages
docker-compose exec dev pip install package-name

# Add to requirements.txt
echo "package-name" >> requirements.txt
docker-compose build dev
```

### Files Not Syncing

**Symptoms:**
- Changes in VS Code not visible in container
- File edits don't persist

**Solution:**
```bash
# 1. Check volume mounts
docker-compose exec dev ls -la /workspace

# 2. Verify docker-compose.yml
services:
  dev:
    volumes:
      - .:/workspace  # Mount current directory

# 3. Restart with volume recreation
docker-compose down -v
docker-compose up -d dev

# 4. Check file permissions
ls -la ./
# If wrong, fix:
sudo chown -R $USER:$USER .

# 5. macOS: Check file sharing
# Docker Desktop → Settings → Resources → File Sharing
# Ensure your project directory is listed
```

---

## AI Assistant Issues

### Continue AI Not Working

**Symptoms:**
- Continue panel blank
- No AI responses

**Solution:**
```bash
# 1. Check API key
echo $ANTHROPIC_API_KEY
# Should show key starting with "sk-ant-"

# 2. Verify in .env.local
cat .env.local | grep ANTHROPIC

# 3. Check Continue config
cat ~/.continue/config.json

# 4. Reinstall extension
code --uninstall-extension continue.continue
code --install-extension continue.continue

# 5. Reload VS Code
# Cmd/Ctrl+Shift+P → "Developer: Reload Window"

# 6. Check Continue logs
# Cmd/Ctrl+Shift+P → "Continue: Show Logs"
```

### API Key Invalid

**Symptoms:**
- "401 Unauthorized"
- "Invalid API key"

**Solution:**
```bash
# 1. Verify key format
echo $ANTHROPIC_API_KEY
# Should start with: sk-ant-

# 2. Test key
curl https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{
    "model": "claude-3-sonnet-20240229",
    "max_tokens": 10,
    "messages": [{"role": "user", "content": "test"}]
  }'

# 3. Get new key if invalid
# Visit: https://console.anthropic.com/
# Create new API key

# 4. Update everywhere
nano .env.local
# Update ANTHROPIC_API_KEY

# Restart container
docker-compose restart dev
```

### Rate Limit Exceeded

**Symptoms:**
- "429 Too Many Requests"
- Requests timing out

**Solution:**
```bash
# 1. Check rate limits
# Anthropic: 50 requests/minute (free tier)
# OpenAI: varies by plan

# 2. Wait and retry
# Wait 60 seconds then try again

# 3. Upgrade API plan
# Visit provider dashboard
# Upgrade to higher tier

# 4. Use different model
# Switch to faster/cheaper model
# Claude Haiku instead of Opus
```

### Wrong Model Responding

**Symptoms:**
- Different model than selected
- Unexpected responses

**Solution:**
```bash
# 1. Check model selection
# Open Continue (Cmd/Ctrl+L)
# Click model dropdown at top
# Verify correct model selected

# 2. Check config
cat ~/.continue/config.json
# Verify models array

# 3. Clear Continue cache
rm -rf ~/.continue/cache
# Reload VS Code

# 4. Verify API key matches model
# Anthropic key for Claude models
# OpenAI key for GPT models
```

---

## Git Issues

### Merge Conflicts

**Symptoms:**
- "CONFLICT" message during merge/pull
- Files marked with conflict markers

**Solution:**
```bash
# 1. Check which files have conflicts
git status

# 2. Open conflicted file
# Look for conflict markers:
<<<<<<< HEAD
Your changes
=======
Incoming changes
>>>>>>> branch-name

# 3. Resolve manually
# Keep your version:
git checkout --ours file.txt

# Keep incoming version:
git checkout --theirs file.txt

# Or edit manually and remove markers

# 4. Mark as resolved
git add file.txt

# 5. Complete merge
git merge --continue
# Or if rebasing:
git rebase --continue

# 6. Abort if needed
git merge --abort
git rebase --abort
```

### Detached HEAD State

**Symptoms:**
- "You are in 'detached HEAD' state"
- Changes not on any branch

**Solution:**
```bash
# 1. Check current state
git status

# 2. Create branch to save work
git checkout -b temp-branch

# 3. Or return to main
git checkout main

# 4. If you made commits in detached state
git branch temp-save
git checkout main
git merge temp-save
```

### Can't Push to GitHub

**Symptoms:**
- "Permission denied"
- "Authentication failed"

**Solution:**
```bash
# 1. Check remote URL
git remote -v

# 2. Use HTTPS with token
git remote set-url origin https://github.com/USER/REPO.git

# 3. Or use SSH
git remote set-url origin git@github.com:USER/REPO.git

# 4. Setup SSH key (if using SSH)
ssh-keygen -t ed25519 -C "your_email@example.com"
cat ~/.ssh/id_ed25519.pub
# Add to GitHub: Settings → SSH Keys

# 5. For HTTPS, use personal access token
# GitHub → Settings → Developer settings → Personal access tokens
# Use token as password when pushing

# 6. Cache credentials (HTTPS)
git config --global credential.helper cache
```

### Large Files Error

**Symptoms:**
- "remote: error: File X is too large"
- Push rejected

**Solution:**
```bash
# 1. Check file size
ls -lh large-file.bin

# 2. Remove from git history
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch large-file.bin' \
  HEAD

# 3. Add to .gitignore
echo "large-file.bin" >> .gitignore

# 4. Use Git LFS for large files
git lfs install
git lfs track "*.bin"
git add .gitattributes
git add large-file.bin
git commit -m "Add large file with LFS"

# 5. Force push (caution!)
git push --force
```

---

## Networking Issues

### Can't Connect to Internet from Container

**Symptoms:**
- "Could not resolve host"
- pip/npm install fails

**Solution:**
```bash
# 1. Check host internet
ping -c 3 google.com

# 2. Check from container
docker-compose exec dev ping -c 3 google.com

# 3. Check DNS
docker-compose exec dev cat /etc/resolv.conf

# 4. Update DNS in docker-compose.yml
services:
  dev:
    dns:
      - 8.8.8.8
      - 8.8.4.4

# 5. Restart Docker daemon
sudo systemctl restart docker

# 6. Check firewall
# macOS: System Preferences → Security → Firewall
# Linux: sudo ufw status
# Windows: Windows Defender Firewall
```

### Port Already in Use

**Symptoms:**
- "bind: address already in use"
- Service won't start

**Solution:**
```bash
# 1. Find what's using port
lsof -i :8000  # macOS/Linux
netstat -ano | findstr :8000  # Windows

# 2. Kill process
kill -9 <PID>

# 3. Or use different port
# Edit docker-compose.yml:
ports:
  - "8001:8000"

# 4. Or stop conflicting service
sudo systemctl stop apache2  # Example
```

### Can't Access Container from Host

**Symptoms:**
- localhost:8000 doesn't work
- Connection refused

**Solution:**
```bash
# 1. Check port mapping
docker-compose ps

# 2. Verify ports in docker-compose.yml
services:
  dev:
    ports:
      - "8000:8000"  # host:container

# 3. Check container IP
docker inspect container-name | grep IPAddress

# 4. Access via container IP
curl http://172.17.0.2:8000

# 5. Check if service is listening
docker-compose exec dev netstat -tulpn | grep 8000

# 6. Bind to 0.0.0.0 in application
# Instead of: app.run(host='127.0.0.1')
# Use: app.run(host='0.0.0.0')
```

---

## Performance Issues

### Slow Container Startup

**Solution:**
```bash
# 1. Use smaller base image
# Instead of: FROM ubuntu:24.04
# Use: FROM python:3.11-slim

# 2. Cache dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .

# 3. Multi-stage builds
FROM node:20 as builder
WORKDIR /build
COPY package*.json .
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-slim
COPY --from=builder /build/dist ./dist

# 4. Reduce layers
RUN apt-get update && \
    apt-get install -y tool1 tool2 && \
    rm -rf /var/lib/apt/lists/*

# 5. Use BuildKit
export DOCKER_BUILDKIT=1
```

### High CPU Usage

**Solution:**
```bash
# 1. Check what's using CPU
docker stats

# 2. Limit CPU usage
# docker-compose.yml:
services:
  dev:
    cpus: 2.0
    cpu_shares: 512

# 3. Check for infinite loops in code

# 4. Disable file watching if not needed
# VS Code settings.json:
{
  "files.watcherExclude": {
    "**/.git/**": true,
    "**/node_modules/**": true
  }
}
```

### Slow File System

**macOS specific:**
```bash
# 1. Use delegated mode
volumes:
  - .:/workspace:delegated

# 2. Or use named volume
volumes:
  workspace:
services:
  dev:
    volumes:
      - workspace:/workspace

# 3. Exclude large directories
volumes:
  - .:/workspace
  - /workspace/node_modules
  - /workspace/.git
```

---

## Platform-Specific Issues

### macOS Issues

**Docker Desktop crashes:**
```bash
# 1. Increase resources
# Docker Desktop → Settings → Resources
# Memory: 8GB, CPU: 4 cores

# 2. Reset to factory defaults
# Docker Desktop → Troubleshoot → Reset

# 3. Clear cache
rm -rf ~/Library/Containers/com.docker.docker
# Restart Docker Desktop

# 4. Check disk space
df -h
```

**Permission issues with volumes:**
```bash
# Use :delegated for better performance
volumes:
  - .:/workspace:delegated
```

### Windows Issues

**WSL2 not working:**
```bash
# 1. Enable WSL2
wsl --install

# 2. Set WSL2 as default
wsl --set-default-version 2

# 3. Update WSL
wsl --update

# 4. Enable in Docker Desktop
# Docker Desktop → Settings → General → Use WSL 2

# 5. Check WSL2 distro
wsl -l -v
```

**Line ending issues:**
```bash
# Configure git
git config --global core.autocrlf false

# Check .gitattributes
* text=auto
*.sh text eol=lf
```

### Linux Issues

**Docker socket permissions:**
```bash
# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Or fix socket permissions
sudo chmod 666 /var/run/docker.sock
```

**SELinux issues:**
```bash
# Check if SELinux is enabled
getenforce

# Add :Z to volume mounts
volumes:
  - .:/workspace:Z
```

---

## Recovery Procedures

### Complete Reset

**When nothing else works:**
```bash
# 1. Save your work
git stash save "backup before reset"

# 2. Stop all containers
docker-compose down -v

# 3. Remove all Docker data
docker system prune -a --volumes

# 4. Remove VS Code extensions
rm -rf ~/.vscode/extensions
rm -rf ~/.vscode-server

# 5. Remove Continue config
rm -rf ~/.continue

# 6. Fresh start
git stash pop
docker-compose build --no-cache dev
docker-compose up -d dev
code .
```

### Restore from Backup

**If you broke something:**
```bash
# 1. From git
git reset --hard HEAD
git clean -fd

# 2. Restore specific file
git checkout HEAD -- file.txt

# 3. Restore from backup branch
git checkout backup-branch -- .

# 4. Restore Docker volumes
docker run --rm -v project_vol:/data \
  -v $(pwd)/backup:/backup \
  alpine sh -c "cd /data && tar xzf /backup/data.tar.gz"
```

### Emergency Contacts

**Get help:**
```bash
# 1. Check logs
docker-compose logs dev > logs.txt

# 2. Get system info
docker info > docker-info.txt

# 3. Get container info
docker inspect container-name > container-info.txt

# 4. Create GitHub issue
# Include:
# - Error message
# - Steps to reproduce
# - System info (OS, Docker version)
# - Logs

# 5. Ask in community
# Slack: #dev-environment channel
# Discord: dev-tools server
```

---

## Getting More Help

### Documentation
- [Complete Setup Guide](SETUP_GUIDE.md) - Full setup
- [Usage Guide](USAGE_GUIDE.md) - Daily workflows
- [Updates Guide](UPDATES_GUIDE.md) - Keep current
- [Secrets Management](SECRETS_MANAGEMENT.md) - Security
- [FAQ](FAQ.md) - Common questions

### Community
- GitHub Issues: Report bugs
- GitHub Discussions: Ask questions
- Slack/Discord: Real-time help

### Support Channels
- Email: support@example.com
- Stack Overflow: Tag `dev-environment-template`

---

**Still stuck?** Create a detailed issue on GitHub with:
- Error message (full text)
- Steps to reproduce
- System info (OS, Docker version)
- Logs (`docker-compose logs dev`)

---

**Last Updated:** October 20, 2025  
**Version:** 2.0
