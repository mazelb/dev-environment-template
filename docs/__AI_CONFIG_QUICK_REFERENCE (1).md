# VS Code AI Configuration Quick Reference

Fast reference for GitHub Copilot and Continue configuration in dev containers.

---

## 🚀 Quick Setup

### Method 1: Settings Sync (Recommended)
```bash
# 1. Enable Settings Sync in VS Code
Cmd/Ctrl+Shift+P → "Settings Sync: Turn On"

# 2. Sign in with GitHub/Microsoft

# 3. Open project in container
code .
Cmd/Ctrl+Shift+P → "Remote-Containers: Reopen in Container"

# Done! AI settings sync automatically ✨
```

### Method 2: Automated Merge
```bash
# Run merge script
./scripts/merge-vscode-ai-config.sh

# Review merged settings
code .vscode/settings.json

# Test in container
docker-compose up -d dev
```

---

## 🤖 AI Tool Configurations

### GitHub Copilot

**Essential Settings:**
```json
{
  "github.copilot.enable": {
    "*": true,
    "yaml": true,
    "markdown": true,
    "plaintext": false
  },
  "github.copilot.editor.enableAutoCompletions": true,
  "github.copilot.editor.enableCodeActions": true
}
```

**Container Exclusions (for performance):**
```json
{
  "github.copilot.advanced": {
    "excludeFolders": {
      "/.venv": true,
      "/node_modules": true,
      "/__pycache__": true,
      "/dist": true,
      "/build": true,
      "/.git": true
    }
  }
}
```

**Common Settings:**
```json
{
  "github.copilot.chat.localeOverride": "en",
  "github.copilot.chat.welcomeMessage": "never",
  "github.copilot.advanced": {
    "listCount": 10,
    "inlineSuggestCount": 3
  }
}
```

**Sign In:**
```
Cmd/Ctrl+Shift+P → "GitHub Copilot: Sign In"
```

**Common Issues:**
- **Not working in container:** Rebuild container with extension in devcontainer.json
- **Authentication lost:** Re-sign in via status bar icon
- **Slow completions:** Add more excludeFolders

---

### Continue

**Essential Settings:**
```json
{
  "continue.enableTabAutocomplete": true,
  "continue.telemetryEnabled": false,
  "continue.manuallyRunningSserver": false,
  "continue.showInlineTip": true
}
```

**Config File Location:**
```bash
# Create/edit Continue config
mkdir -p ~/.continue
code ~/.continue/config.json
```

**Example Config:**
```json
{
  "models": [
    {
      "title": "Claude Sonnet",
      "provider": "anthropic",
      "model": "claude-sonnet-4-20250514",
      "apiKey": "${ANTHROPIC_API_KEY}"
    },
    {
      "title": "GPT-4",
      "provider": "openai",
      "model": "gpt-4",
      "apiKey": "${OPENAI_API_KEY}"
    }
  ],
  "tabAutocompleteModel": {
    "title": "Claude Sonnet",
    "provider": "anthropic",
    "model": "claude-sonnet-4-20250514",
    "apiKey": "${ANTHROPIC_API_KEY}"
  }
}
```

**Set Environment Variables:**
```bash
# In ~/.zshrc or ~/.bashrc
export ANTHROPIC_API_KEY="sk-ant-..."
export OPENAI_API_KEY="sk-..."
```

**Common Issues:**
- **API key not loading:** Use environment variables in config
- **Chat not responding:** Check ~/.continue/config.json exists
- **Wrong model:** Verify model name matches provider docs

---

## 🔐 Security Best Practices

### API Keys

**❌ Never commit to git:**
```json
// Don't do this!
{
  "continue.apiKey": "sk-abc123..."
}
```

**✅ Use environment variables:**
```bash
# ~/.zshrc or ~/.bashrc
export ANTHROPIC_API_KEY="sk-ant-..."
export OPENAI_API_KEY="sk-..."
```

**✅ Reference in Continue config:**
```json
{
  "models": [
    {
      "apiKey": "${ANTHROPIC_API_KEY}"
    }
  ]
}
```

**✅ Use .env for Docker:**
```bash
# Create .env file
cat > .env << EOF
ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
OPENAI_API_KEY=${OPENAI_API_KEY}
EOF

# Add to .gitignore
echo ".env" >> .gitignore
```

**✅ Update docker-compose.yml:**
```yaml
services:
  dev:
    env_file:
      - .env
    environment:
      - ANTHROPIC_API_KEY
      - OPENAI_API_KEY
```

### Privacy Settings

**Disable telemetry:**
```json
{
  "github.copilot.advanced": {
    "debug.telemetry": false
  },
  "continue.telemetryEnabled": false
}
```

---

## 🐳 Container-Specific Setup

### Required in devcontainer.json

**Add AI extensions:**
```json
{
  "customizations": {
    "vscode": {
      "extensions": [
        "GitHub.copilot",
        "GitHub.copilot-chat",
        "Continue.continue"
      ]
    }
  }
}
```

### Performance Optimization

**Exclude heavy directories:**
```json
{
  "github.copilot.advanced": {
    "excludeFolders": {
      "**/node_modules": true,
      "**/.venv": true,
      "**/venv": true,
      "**/__pycache__": true,
      "**/dist": true,
      "**/build": true,
      "**/.git": true
    }
  },
  "files.watcherExclude": {
    "**/.venv/**": true,
    "**/node_modules/**": true,
    "**/__pycache__/**": true
  }
}
```

---

## 🔧 Troubleshooting Commands

### Check Extensions Installed
```bash
# In VS Code command palette
Cmd/Ctrl+Shift+P → "Extensions: Show Installed Extensions"

# Or via CLI
code --list-extensions | grep -i copilot
code --list-extensions | grep -i continue
```

### Rebuild Container
```bash
# Rebuild with Docker Compose
docker-compose down
docker-compose up -d dev

# Or in VS Code
Cmd/Ctrl+Shift+P → "Remote-Containers: Rebuild Container"
```

### Check GitHub Copilot Authentication
```bash
# Sign in
Cmd/Ctrl+Shift+P → "GitHub Copilot: Sign In"

# Check status
# Look for Copilot icon in status bar (bottom right)
```

### Check Continue API Keys in Container
```bash
# Verify environment variables in container
docker exec -it dev-container bash
echo $ANTHROPIC_API_KEY
echo $OPENAI_API_KEY

# Should show your keys (not empty)
```

### View AI Output/Logs
```bash
# In VS Code
Cmd/Ctrl+Shift+P → "Output"
# Select from dropdown:
# - GitHub Copilot
# - Continue
```

### Reset GitHub Copilot
```bash
# Disable extension
Cmd/Ctrl+Shift+P → "Extensions: Show Installed Extensions"
# Right-click "GitHub Copilot" → Disable

# Re-enable
# Right-click "GitHub Copilot" → Enable

# Sign in again
Cmd/Ctrl+Shift+P → "GitHub Copilot: Sign In"
```

### Reset Continue
```bash
# Remove Continue config
rm ~/.continue/config.json

# Recreate with fresh config
code ~/.continue/config.json

# Reload VS Code window
Cmd/Ctrl+Shift+P → "Developer: Reload Window"
```

---

## 📋 Pre-flight Checklist

### Before Opening in Container:

- [ ] GitHub Copilot installed locally
- [ ] Continue installed locally
- [ ] GitHub Copilot authenticated
- [ ] Continue config created (`~/.continue/config.json`)
- [ ] API keys set in environment variables
- [ ] Settings Sync enabled (if using)
- [ ] Extensions listed in devcontainer.json
- [ ] Exclusion paths configured for performance

### After Opening in Container:

- [ ] GitHub Copilot showing in status bar
- [ ] Continue sidebar accessible (Cmd/Ctrl+L)
- [ ] Copilot suggestions working
- [ ] Continue chat responding
- [ ] API keys available in container
- [ ] Performance acceptable

---

## 🎯 Common Workflows

### Team Setup
```bash
# 1. Document required AI tools in README
cat >> README.md << EOF

## AI Tools Setup

Required extensions:
- GitHub Copilot (authentication via GitHub)
- Continue (requires API keys)

See docs/PERSONAL_VSCODE_AI_CONFIG.md for setup.
EOF

# 2. Add extensions to devcontainer.json
# (Team members get them automatically)

# 3. Share Continue config template
mkdir -p .continue
cat > .continue/config.template.json << EOF
{
  "models": [
    {
      "title": "Claude Sonnet",
      "provider": "anthropic",
      "model": "claude-sonnet-4-20250514",
      "apiKey": "\${ANTHROPIC_API_KEY}"
    }
  ]
}
EOF

# 4. Create .env.example
cat > .env.example << EOF
ANTHROPIC_API_KEY=your-key-here
OPENAI_API_KEY=your-key-here
EOF

# 5. Add .env to .gitignore
echo ".env" >> .gitignore
```

### Personal Setup
```bash
# 1. Clone project
git clone <repo>

# 2. Enable Settings Sync
# Cmd/Ctrl+Shift+P → "Settings Sync: Turn On"

# 3. Set environment variables
export ANTHROPIC_API_KEY="sk-ant-..."
export OPENAI_API_KEY="sk-..."

# 4. Create .env for Docker
cat > .env << EOF
ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
OPENAI_API_KEY=${OPENAI_API_KEY}
EOF

# 5. Open in container
code .
# Cmd/Ctrl+Shift+P → "Remote-Containers: Reopen in Container"

# 6. Verify AI tools work
# - Try Copilot suggestions
# - Open Continue (Cmd/Ctrl+L)
```

### Multi-Machine Setup
```bash
# Machine 1: Initial setup
# - Enable Settings Sync
# - Configure GitHub Copilot
# - Configure Continue
# - Open project in container

# Machine 2: New machine
# - Sign into VS Code with same account
# - Set environment variables for Continue
# - Clone project
# - Open in container
# Settings and Copilot auth automatically sync!
```

---

## 🆘 Emergency Recovery

### Restore Template Settings
```bash
# If you have a backup
cp .vscode/settings.json.backup.* .vscode/settings.json

# Or restore from git
git checkout .vscode/settings.json

# Rebuild container
docker-compose restart dev
```

### Reset All AI Settings
```bash
# 1. Remove AI settings from user settings
code ~/Library/Application\ Support/Code/User/settings.json
# Delete github.copilot and continue sections

# 2. Remove Continue config
rm -rf ~/.continue

# 3. Disable Settings Sync temporarily
# Cmd/Ctrl+Shift+P → "Settings Sync: Turn Off"

# 4. Restart VS Code

# 5. Re-enable Settings Sync
# Cmd/Ctrl+Shift+P → "Settings Sync: Turn On"

# 6. Re-configure AI tools from scratch
```

---

## 📚 Quick Links

### Documentation
- **Full Guide:** `docs/PERSONAL_VSCODE_AI_CONFIG.md`
- **GitHub Copilot:** https://docs.github.com/copilot
- **Continue:** https://continue.dev/docs
- **Anthropic API:** https://docs.anthropic.com
- **OpenAI API:** https://platform.openai.com/docs

### Scripts
- **Merge Script:** `./scripts/merge-vscode-ai-config.sh`

### Support
- **VS Code Issues:** https://github.com/microsoft/vscode/issues
- **Copilot Issues:** https://github.com/community/community/discussions/categories/copilot
- **Continue Issues:** https://github.com/continuedev/continue/issues
- **Container Issues:** https://github.com/microsoft/vscode-remote-release/issues

---

## 💡 Tips

1. **Use Settings Sync** - Easiest way to sync Copilot config across machines
2. **Environment Variables** - Keep Continue API keys secure
3. **Exclude Heavy Dirs** - Improves Copilot performance in containers
4. **Test Locally First** - Verify AI tools work before opening in container
5. **Document for Team** - List required AI tools and setup in README
6. **Keep Backups** - Always backup before merging settings
7. **Check Extension Status** - Verify extensions load in container status bar
8. **Monitor Resources** - AI tools need adequate CPU/memory in Docker

---

## 🔑 Quick Commands Reference

```bash
# Enable Settings Sync
Cmd/Ctrl+Shift+P → "Settings Sync: Turn On"

# Sign in to Copilot
Cmd/Ctrl+Shift+P → "GitHub Copilot: Sign In"

# Open Continue Chat
Cmd/Ctrl+L

# Rebuild Container
Cmd/Ctrl+Shift+P → "Remote-Containers: Rebuild Container"

# View Extensions
Cmd/Ctrl+Shift+P → "Extensions: Show Installed Extensions"

# View Output/Logs
Cmd/Ctrl+Shift+P → "Output" → Select AI tool

# Reload Window
Cmd/Ctrl+Shift+P → "Developer: Reload Window"
```

---

Last updated: 2025-10-17