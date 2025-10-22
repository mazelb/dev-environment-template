# Using Your Personal VS Code AI Configuration

Complete guide to integrating GitHub Copilot and Continue settings with the dev environment template.

---

## 🎯 Overview

The template includes AI configuration optimized for container development. You have several options to use your personal AI settings alongside the template configuration.

---

## 🤖 Supported AI Tools

This guide covers configuration for:

- **GitHub Copilot** (and Copilot Chat)
- **Continue** (with Claude, GPT-4, and other LLM providers)

---

## ✅ Option 1: Settings Sync (Recommended - Easiest)

**Best for:** Most users who want automatic syncing

VS Code's built-in Settings Sync handles AI configuration automatically.

### Enable Settings Sync

1. **Open VS Code**
2. **Press** `Cmd+Shift+P` (Mac) or `Ctrl+Shift+P` (Windows/Linux)
3. **Type:** "Settings Sync: Turn On"
4. **Sign in** with GitHub or Microsoft account
5. **Select what to sync:**
   - ✅ Settings (includes AI config)
   - ✅ Extensions (installs AI extensions)
   - ✅ Keyboard Shortcuts
   - ✅ UI State

### How It Works in Containers

When you open a project in a Dev Container:
- **Template AI settings** (container-optimized) are applied first
- **Your personal AI settings** are layered on top
- **Authentication tokens** are synced securely
- **Result:** Container settings + Your AI preferences

**Example:**
```json
// Template sets:
"github.copilot.enable": {
  "*": true,
  "yaml": true,
  "plaintext": false
}

// Your settings add:
"github.copilot.editor.enableAutoCompletions": true,
"continue.enableTabAutocomplete": true

// Final result: Both applied!
```

### What Gets Synced

✅ **Synced to container:**
- GitHub Copilot settings and authentication
- Continue settings and configuration
- AI feature toggles
- Language-specific AI settings
- Custom prompts and templates
- Keybindings for AI commands

❌ **Not synced (stays template):**
- Container-specific AI paths
- Container file exclusions for AI
- Remote container AI settings

---

## ✅ Option 2: Merge AI Config Script (Automated)

**Best for:** One-time migration or periodic updates

Use the provided script to merge your AI settings with the template.

### Usage

```bash
# In your template directory
./scripts/merge-vscode-ai-config.sh
```

### What the Script Does

1. **Finds** your VS Code settings automatically
2. **Extracts** GitHub Copilot and Continue settings
3. **Backs up** template settings
4. **Merges** your AI preferences with template
5. **Preserves** container-specific settings
6. **Validates** JSON structure

### Example Output

```bash
🤖 VS Code AI Configuration Merger

✓ Found your VS Code settings: ~/Library/Application Support/Code/User/settings.json
✓ Found template settings: .vscode/settings.json
✓ Backed up template settings to: .vscode/settings.json.backup.20251017_143022
ℹ Extracting AI-related settings...
  - Found GitHub Copilot settings
  - Found Continue settings
ℹ Merging AI configuration...
✓ AI configuration merged successfully!

📝 Summary:
  - Template settings: preserved container-specific settings
  - Your AI settings: added personal preferences
  - AI tools detected: GitHub Copilot, Continue
  - Backup: .vscode/settings.json.backup.20251017_143022
```

### Restore Original Template

```bash
# If you want to undo
cp .vscode/settings.json.backup.* .vscode/settings.json
```

---

## ✅ Option 3: Manual Merge

**Best for:** Full control over AI settings

Manually merge your AI configuration with the template.

### Step 1: Find Your Current Settings

**Location by OS:**
```bash
# macOS
~/Library/Application Support/Code/User/settings.json

# Linux
~/.config/Code/User/settings.json

# Windows
%APPDATA%\Code\User\settings.json
```

### Step 2: Open Both Files

```bash
# Your settings
code ~/Library/Application\ Support/Code/User/settings.json

# Template settings
code .vscode/settings.json
```

### Step 3: Merge AI Settings Carefully

**Template Settings to KEEP (Container-specific):**
```json
{
  // Container paths - DON'T change these
  "python.defaultInterpreterPath": "/usr/bin/python3.11",
  
  // Container-specific AI exclusions
  "github.copilot.advanced": {
    "excludeFolders": {
      "/tmp": true,
      "/var": true,
      "/.venv": true,
      "/node_modules": true
    }
  },
  
  // Container file watchers
  "files.watcherExclude": {
    "**/node_modules": true,
    "**/.venv": true,
    "**/venv": true
  }
}
```

**Your AI Settings to ADD:**
```json
{
  // === GitHub Copilot ===
  "github.copilot.enable": {
    "*": true,
    "yaml": true,
    "markdown": true,
    "plaintext": false
  },
  "github.copilot.editor.enableAutoCompletions": true,
  "github.copilot.editor.enableCodeActions": true,
  "github.copilot.chat.localeOverride": "en",
  
  // === Continue ===
  "continue.telemetryEnabled": false,
  "continue.enableTabAutocomplete": true,
  "continue.manuallyRunningSserver": false
}
```

### Final Merged Settings Example

```json
{
  // === Container-specific (from template) ===
  "python.defaultInterpreterPath": "/usr/bin/python3.11",
  "remote.containers.defaultExtensions": [...],
  
  // === Your AI preferences ===
  "github.copilot.enable": {
    "*": true,
    "yaml": true,
    "markdown": true
  },
  "github.copilot.editor.enableAutoCompletions": true,
  "continue.enableTabAutocomplete": true,
  
  // === Merged AI settings ===
  "github.copilot.advanced": {
    "excludeFolders": {
      "/tmp": true,
      "/var": true,
      "/.venv": true,
      "/node_modules": true
    }
  }
}
```

---

## ✅ Option 4: AI Config Overlay

**Best for:** Keeping AI settings separate and portable

Create a separate file for your AI configuration.

### Create AI Config File

```bash
# Create your AI config (not tracked in git)
cat > .vscode/settings.ai.json << 'EOF'
{
  "github.copilot.enable": {
    "*": true,
    "yaml": true,
    "markdown": true
  },
  "github.copilot.editor.enableAutoCompletions": true,
  "continue.enableTabAutocomplete": true,
  "continue.telemetryEnabled": false
}
EOF

# Add to .gitignore
echo ".vscode/settings.ai.json" >> .gitignore
```

### Usage

Manually merge when needed:
```bash
# Apply your AI settings
jq -s '.[0] * .[1]' .vscode/settings.json .vscode/settings.ai.json > .vscode/settings.tmp.json
mv .vscode/settings.tmp.json .vscode/settings.json
```

### Create an Apply Script

```bash
cat > scripts/apply-ai-config.sh << 'EOF'
#!/bin/bash
if [ -f .vscode/settings.ai.json ]; then
  jq -s '.[0] * .[1]' .vscode/settings.json .vscode/settings.ai.json > .vscode/settings.tmp.json
  mv .vscode/settings.tmp.json .vscode/settings.json
  echo "✓ AI configuration applied"
else
  echo "✗ No .vscode/settings.ai.json found"
fi
EOF

chmod +x scripts/apply-ai-config.sh
```

---

## 🎨 AI Settings Configuration

### GitHub Copilot

```json
{
  // Enable/disable Copilot by file type
  "github.copilot.enable": {
    "*": true,
    "yaml": true,
    "markdown": true,
    "plaintext": false
  },
  
  // Editor features
  "github.copilot.editor.enableAutoCompletions": true,
  "github.copilot.editor.enableCodeActions": true,
  
  // Advanced settings
  "github.copilot.advanced": {
    "listCount": 10,
    "inlineSuggestCount": 3,
    "excludeFolders": {
      "**/node_modules": true,
      "**/.venv": true,
      "**/__pycache__": true
    }
  },
  
  // Chat settings
  "github.copilot.chat.localeOverride": "en",
  "github.copilot.chat.welcomeMessage": "never",
  
  // Keybindings preference
  "github.copilot.keybindings": "default"
}
```

### Continue

```json
{
  // Enable features
  "continue.enableTabAutocomplete": true,
  "continue.telemetryEnabled": false,
  "continue.manuallyRunningSserver": false,
  
  // UI preferences
  "continue.showInlineTip": true
}
```

**Continue Config File (`~/.continue/config.json`):**
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

---

## 🔐 Managing API Keys & Authentication

### GitHub Copilot

**Authentication is handled by:**
- GitHub account linked in VS Code
- Settings Sync preserves authentication
- No manual API key needed

**Sign in:**
```
Cmd/Ctrl+Shift+P → "GitHub Copilot: Sign In"
```

### Continue

**Set API keys in Continue config:**

```bash
# Edit Continue config
code ~/.continue/config.json
```

**Best Practice - Use Environment Variables:**

```bash
# In your shell profile (~/.zshrc, ~/.bashrc)
export OPENAI_API_KEY="sk-your-openai-key"
export ANTHROPIC_API_KEY="sk-ant-your-anthropic-key"
```

**Reference in Continue config:**
```json
{
  "models": [
    {
      "title": "Claude Sonnet",
      "provider": "anthropic",
      "model": "claude-sonnet-4-20250514",
      "apiKey": "${ANTHROPIC_API_KEY}"
    }
  ]
}
```

**Pass to Docker Container:**

```bash
# Create .env file (add to .gitignore!)
cat > .env << EOF
OPENAI_API_KEY=${OPENAI_API_KEY}
ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
EOF

# Add to .gitignore
echo ".env" >> .gitignore
```

**Update `docker-compose.yml`:**
```yaml
services:
  dev:
    # ... other config
    env_file:
      - .env
    environment:
      - OPENAI_API_KEY
      - ANTHROPIC_API_KEY
```

---

## 🔄 Workflow: Using AI Config with Containers

### First Time Setup

```bash
# 1. Enable Settings Sync in VS Code
#    Cmd+Shift+P → "Settings Sync: Turn On"

# 2. Install AI extensions (if not synced)
#    - GitHub Copilot
#    - GitHub Copilot Chat
#    - Continue

# 3. Authenticate AI tools
#    - Copilot: Sign in with GitHub
#    - Continue: Configure API keys in ~/.continue/config.json

# 4. Set up environment variables
export ANTHROPIC_API_KEY="sk-ant-..."
export OPENAI_API_KEY="sk-..."

# 5. Open project in container
code .
# Cmd+Shift+P → "Remote-Containers: Reopen in Container"

# 6. AI settings automatically apply!
#    ✓ Extensions install in container
#    ✓ Copilot authentication persists
#    ✓ Continue uses environment variables
#    ✓ Settings sync
```

### On Different Machines

```bash
# Machine 2: Clone project
git clone https://github.com/user/my-project.git
cd my-project

# Set environment variables
export ANTHROPIC_API_KEY="sk-ant-..."
export OPENAI_API_KEY="sk-..."

# Open in VS Code
code .

# Reopen in container
# Cmd+Shift+P → "Remote-Containers: Reopen in Container"

# Settings Sync automatically:
# ✓ Installs GitHub Copilot and Continue
# ✓ Applies AI settings
# ✓ Authenticates Copilot (if tokens synced)
# ✓ Continue uses env vars from container
```

---

## 🎯 Best Practices

### Do's ✅

- **Use Settings Sync** for automatic AI config syncing
- **Store API keys** in environment variables
- **Test AI tools** after container rebuild
- **Keep container exclusions** from template (performance)
- **Document** AI setup in your team README
- **Use `.gitignore`** for personal AI config files and `.env`

### Don'ts ❌

- **Don't commit API keys** to version control
- **Don't override** container-specific exclusions
- **Don't disable** AI for critical file types in containers
- **Don't share** personal API keys in team settings
- **Don't modify** remote container AI extensions list without testing

---

## 🔍 Troubleshooting

### GitHub Copilot Not Working in Container

**Problem:** GitHub Copilot doesn't work in container

**Solution:**
```bash
# 1. Check extension is installed in container
#    Cmd+Shift+P → "Extensions: Show Installed Extensions"
#    Look for "GitHub Copilot"

# 2. Verify extension in devcontainer.json
cat .devcontainer/devcontainer.json
# Should include:
# "extensions": [
#   "GitHub.copilot",
#   "GitHub.copilot-chat"
# ]

# 3. Rebuild container
docker-compose down
docker-compose up -d dev
# Cmd+Shift+P → "Remote-Containers: Rebuild Container"

# 4. Re-authenticate if needed
#    Click on Copilot icon in status bar
#    Or: Cmd+Shift+P → "GitHub Copilot: Sign In"
```

### Continue Not Working in Container

**Problem:** Continue doesn't respond or shows API errors

**Solution:**
```bash
# 1. Check Continue config exists
cat ~/.continue/config.json

# 2. Verify environment variables in container
docker exec -it dev-container bash
echo $ANTHROPIC_API_KEY
echo $OPENAI_API_KEY

# 3. If empty, update docker-compose.yml
# Add to services.dev:
#   env_file:
#     - .env
#   environment:
#     - ANTHROPIC_API_KEY
#     - OPENAI_API_KEY

# 4. Restart container
docker-compose restart dev

# 5. Check Continue output
#    Cmd+Shift+P → "Output"
#    Select "Continue" from dropdown
```

### Copilot Authentication Lost in Container

**Problem:** Copilot asks to sign in every time

**Solution:**
```bash
# 1. Enable Settings Sync (if not already)
#    Cmd+Shift+P → "Settings Sync: Turn On"

# 2. Sign in to GitHub Copilot
#    Cmd+Shift+P → "GitHub Copilot: Sign In"
#    Follow authentication flow

# 3. Verify auth is saved
#    Settings Sync → Show Synced Data → Check extensions

# 4. Reload window in container
#    Cmd+Shift+P → "Developer: Reload Window"
```

### Slow AI Completions in Container

**Problem:** AI suggestions are slow or laggy

**Solution:**
```bash
# 1. Check container resource allocation
docker stats

# 2. Increase Docker resources
# Docker Desktop → Settings → Resources
# - CPU: 4+ cores
# - Memory: 8+ GB

# 3. Exclude unnecessary files from AI scanning
# Add to .vscode/settings.json:
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
  }
}

# 4. Restart container
docker-compose restart dev
```

### Continue API Key Not Loading

**Problem:** Continue shows "API key not found" errors

**Solution:**
```bash
# 1. Verify environment variables are set locally
echo $OPENAI_API_KEY
echo $ANTHROPIC_API_KEY

# 2. Create .env file for Docker
cat > .env << EOF
OPENAI_API_KEY=${OPENAI_API_KEY}
ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
EOF

# 3. Update docker-compose.yml
# Add under services.dev:
#   env_file:
#     - .env

# 4. Restart container
docker-compose down
docker-compose up -d dev

# 5. Verify in container
docker exec -it dev-container bash
echo $ANTHROPIC_API_KEY  # Should show your key
```

---

## 📝 AI Settings Priority Order

VS Code applies AI settings in this order (last wins):

1. **Default extension settings** (lowest priority)
2. **Template settings** (`.vscode/settings.json`)
3. **User settings** (from Settings Sync or local)
4. **Workspace settings** (highest priority)

**Container-specific AI settings** from the template are preserved because they're in `.vscode/settings.json` (workspace-level).

---

## 🔒 Security Considerations

### API Keys & Secrets

**Never commit these to git:**
- Continue API keys (Anthropic, OpenAI)
- GitHub Personal Access Tokens
- Any authentication tokens

**Use these approaches:**

1. **Environment variables** (Best)
   ```bash
   # In ~/.zshrc or ~/.bashrc
   export ANTHROPIC_API_KEY="sk-ant-..."
   export OPENAI_API_KEY="sk-..."
   ```

2. **Docker .env file** (for containers)
   ```bash
   # Create .env
   cat > .env << EOF
   ANTHROPIC_API_KEY=sk-ant-...
   OPENAI_API_KEY=sk-...
   EOF
   
   # Add to .gitignore
   echo ".env" >> .gitignore
   ```

3. **Secret management** (Team projects)
   - AWS Secrets Manager
   - HashiCorp Vault
   - Azure Key Vault
   - 1Password/Bitwarden with CLI

### Privacy Settings

**Opt out of telemetry:**
```json
{
  "github.copilot.advanced": {
    "debug.telemetry": false
  },
  "continue.telemetryEnabled": false
}
```

---

## ✅ Recommended Approach

### For Most Users:
1. Enable Settings Sync in VS Code
2. Install and authenticate GitHub Copilot
3. Install Continue and configure API keys in `~/.continue/config.json`
4. Set environment variables for Continue API keys
5. Keep template's `.vscode/settings.json` as-is
6. Let Settings Sync apply your AI preferences automatically
7. Done! ✨

### For Teams:
1. Use `merge-vscode-ai-config.sh` script
2. Create shared AI config baseline
3. Document required AI tools in README
4. Use `.gitignore` for `.env` files
5. Store API keys in environment variables
6. Share Continue config template

### For Power Users:
1. Create `.vscode/settings.ai.json` overlay
2. Use `apply-ai-config.sh` script
3. Keep personal and team settings separate
4. Use secret management for API keys
5. Document your AI workflow
6. Share best practices with team

---

## 🎉 Summary

| Method | Pros | Cons | Best For |
|--------|------|------|----------|
| **Settings Sync** | Automatic, easy, includes Copilot auth | Requires sign-in | Most users |
| **Merge Script** | One-time, automated, customizable | Manual trigger | Power users |
| **Manual Merge** | Full control, transparent | Time-consuming | Advanced users |
| **AI Overlay** | Clean separation, portable | Extra file to manage | Teams |

**Recommendation:** Start with Settings Sync. It's the easiest and works perfectly with containers and AI tools!

---

## 📚 AI Tool Documentation

### Official Resources

- **GitHub Copilot**: https://docs.github.com/copilot
- **Continue**: https://continue.dev/docs
- **Anthropic API**: https://docs.anthropic.com
- **OpenAI API**: https://platform.openai.com/docs

### VS Code Resources

- **Settings Sync**: https://code.visualstudio.com/docs/editor/settings-sync
- **Dev Containers**: https://code.visualstudio.com/docs/devcontainers/containers
- **Extension Management**: https://code.visualstudio.com/docs/editor/extension-marketplace

---

## 🚀 Quick Start Checklist

- [ ] Enable VS Code Settings Sync
- [ ] Install GitHub Copilot and Copilot Chat
- [ ] Install Continue extension
- [ ] Authenticate GitHub Copilot
- [ ] Configure Continue API keys in `~/.continue/config.json`
- [ ] Set up environment variables for API keys
- [ ] Test AI in local VS Code
- [ ] Open project in Dev Container
- [ ] Verify AI extensions load in container
- [ ] Test Copilot completions in container
- [ ] Test Continue chat in container
- [ ] Configure privacy settings
- [ ] Document AI setup for team

---

Happy coding with GitHub Copilot and Continue! 🤖✨