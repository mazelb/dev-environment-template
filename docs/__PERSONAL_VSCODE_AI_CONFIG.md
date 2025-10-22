# Using Your Personal VS Code AI Configuration

Complete guide to integrating your AI assistant settings (GitHub Copilot, Codeium, Continue, etc.) with the dev environment template.

---

## 🎯 Overview

The template includes AI configuration optimized for container development. You have several options to use your personal AI settings alongside the template configuration.

---

## 🤖 Supported AI Tools

This guide covers configuration for:

- **GitHub Copilot** (and Copilot Chat)
- **Codeium**
- **Continue**
- **Tabnine**
- **Amazon CodeWhisperer**
- **Cursor AI** (when using VS Code compatibility mode)
- **Other VS Code AI extensions**

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
- **API keys/tokens** are synced securely
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
"codeium.enableCodeLens": false

// Final result: Both applied!
```

### What Gets Synced

✅ **Synced to container:**
- AI extension settings (Copilot, Codeium, etc.)
- API keys and authentication tokens
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
2. **Extracts** AI-related settings
3. **Backs up** template settings
4. **Merges** your AI preferences with template
5. **Preserves** container-specific settings
6. **Validates** JSON structure

### Example Output

```bash
🤖 VS Code AI Configuration Merger

✓ Found your VS Code settings: ~/Library/Application Support/Code/User/settings.json
✓ Found template settings: .vscode/settings.json
✓ Backed up template settings to: .vscode/settings.json.backup
ℹ Extracting AI-related settings...
  - Found GitHub Copilot settings
  - Found Codeium settings
  - Found Continue settings
ℹ Merging AI configuration...
✓ AI configuration merged successfully!

📝 Summary:
  - Template settings: preserved container-specific settings
  - Your AI settings: added personal preferences
  - AI tools detected: GitHub Copilot, Codeium
  - Backup: .vscode/settings.json.backup
```

### Restore Original Template

```bash
# If you want to undo
cp .vscode/settings.json.backup .vscode/settings.json
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
  
  // === Codeium ===
  "codeium.enableCodeLens": false,
  "codeium.enableSearch": true,
  "codeium.enableConfig": {
    "*": true,
    "markdown": true
  },
  
  // === Continue ===
  "continue.telemetryEnabled": false,
  "continue.enableTabAutocomplete": true,
  "continue.manuallyRunningSserver": false,
  
  // === Tabnine ===
  "tabnine.experimentalAutoImports": true,
  "tabnine.receiveBetaChannelUpdates": false,
  
  // === Amazon CodeWhisperer ===
  "amazonQ.shareContentWithAWS": false,
  "aws.codeWhisperer.includeSuggestionsWithCodeReferences": true
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
  "codeium.enableCodeLens": false,
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
  "codeium.enableCodeLens": false,
  "continue.enableTabAutocomplete": true,
  "tabnine.experimentalAutoImports": true
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

## 🎨 Common AI Settings to Configure

### GitHub Copilot

```json
{
  // Enable/disable Copilot
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
      "**/.venv": true
    }
  },
  
  // Chat settings
  "github.copilot.chat.localeOverride": "en",
  "github.copilot.chat.welcomeMessage": "never",
  
  // Keybindings preference
  "github.copilot.keybindings": "default"
}
```

### Codeium

```json
{
  // Enable Codeium
  "codeium.enableConfig": {
    "*": true,
    "markdown": true,
    "yaml": true
  },
  
  // Features
  "codeium.enableCodeLens": false,
  "codeium.enableSearch": true,
  "codeium.enableChatMarketplace": true,
  
  // Behavior
  "codeium.aggressiveShutdown": false,
  "codeium.detectProxy": true
}
```

### Continue

```json
{
  // Enable features
  "continue.enableTabAutocomplete": true,
  "continue.telemetryEnabled": false,
  "continue.manuallyRunningSserver": false,
  
  // Model preferences
  "continue.defaultModel": "gpt-4",
  "continue.defaultTemperature": 0.5,
  
  // UI preferences
  "continue.showInlineTip": true
}
```

### Tabnine

```json
{
  // Features
  "tabnine.experimentalAutoImports": true,
  "tabnine.receiveBetaChannelUpdates": false,
  
  // Behavior
  "tabnine.logFilePath": "",
  "tabnine.disableFileRegex": []
}
```

### Amazon CodeWhisperer / Amazon Q

```json
{
  // Privacy
  "amazonQ.shareContentWithAWS": false,
  
  // Code references
  "aws.codeWhisperer.includeSuggestionsWithCodeReferences": true,
  
  // Features
  "aws.codeWhisperer.shareCodeWhispererContentWithAWS": false
}
```

---

## 🔐 Managing API Keys & Authentication

### GitHub Copilot

**Authentication is handled by:**
- GitHub account linked in VS Code
- Settings Sync preserves authentication
- No manual API key needed

### Codeium

**Authentication options:**

1. **Using Settings Sync** (Recommended):
   - Sign in once in VS Code
   - Token syncs automatically

2. **Manual token** (if needed):
   ```json
   {
     "codeium.apiKey": "your-api-key-here"
   }
   ```
   
   **⚠️ Security:** Don't commit API keys!
   ```bash
   echo ".vscode/settings.json" >> .gitignore  # If storing keys
   ```

### Continue

**Set API keys in Continue config:**

```bash
# Edit Continue config
code ~/.continue/config.json
```

```json
{
  "models": [
    {
      "title": "GPT-4",
      "provider": "openai",
      "model": "gpt-4",
      "apiKey": "your-api-key"
    }
  ]
}
```

### Environment Variables (Best Practice)

**Store API keys as environment variables:**

```bash
# In your shell profile (~/.zshrc, ~/.bashrc)
export OPENAI_API_KEY="your-key"
export ANTHROPIC_API_KEY="your-key"
export CODEIUM_API_KEY="your-key"
```

**Reference in VS Code settings:**
```json
{
  "continue.apiKey": "${env:OPENAI_API_KEY}"
}
```

---

## 🔄 Workflow: Using AI Config with Containers

### First Time Setup

```bash
# 1. Enable Settings Sync in VS Code
#    Cmd+Shift+P → "Settings Sync: Turn On"

# 2. Install AI extensions (if not synced)
#    - GitHub Copilot
#    - Codeium
#    - Continue

# 3. Authenticate AI tools
#    - Copilot: Sign in with GitHub
#    - Codeium: Sign in with account
#    - Continue: Configure API keys

# 4. Open project in container
code .
# Cmd+Shift+P → "Remote-Containers: Reopen in Container"

# 5. AI settings automatically apply!
#    ✓ Extensions install in container
#    ✓ Authentication persists
#    ✓ Settings sync
```

### On Different Machines

```bash
# Machine 2: Clone project
git clone https://github.com/user/my-project.git
cd my-project

# Open in VS Code
code .

# Reopen in container
# Cmd+Shift+P → "Remote-Containers: Reopen in Container"

# Settings Sync automatically:
# ✓ Installs AI extensions
# ✓ Applies AI settings
# ✓ Authenticates (if tokens synced)
```

---

## 🎯 Best Practices

### Do's ✅

- **Use Settings Sync** for automatic AI config syncing
- **Store API keys** in environment variables or secret management
- **Test AI tools** after container rebuild
- **Keep container exclusions** from template (performance)
- **Document** which AI tools your team uses
- **Use `.gitignore`** for personal AI config files

### Don'ts ❌

- **Don't commit API keys** to version control
- **Don't override** container-specific exclusions
- **Don't disable** AI for critical file types in containers
- **Don't share** personal API keys in team settings
- **Don't modify** remote container AI extensions list

---

## 🔍 Troubleshooting

### AI Tool Not Working in Container

**Problem:** GitHub Copilot/Codeium doesn't work in container

**Solution:**
```bash
# 1. Check extension is installed in container
#    Cmd+Shift+P → "Extensions: Show Installed Extensions"

# 2. Verify extension in devcontainer.json
cat .devcontainer/devcontainer.json
# Should include:
# "extensions": [
#   "GitHub.copilot",
#   "Codeium.codeium"
# ]

# 3. Rebuild container
docker-compose down
docker-compose up -d dev
# Cmd+Shift+P → "Remote-Containers: Rebuild Container"

# 4. Re-authenticate if needed
#    Click on AI tool icon in status bar
```

### Authentication Lost in Container

**Problem:** AI tool asks to sign in every time

**Solution:**
```bash
# 1. Enable Settings Sync (if not already)
#    Cmd+Shift+P → "Settings Sync: Turn On"

# 2. For GitHub Copilot specifically:
#    Cmd+Shift+P → "GitHub Copilot: Sign In"

# 3. For Codeium:
#    Cmd+Shift+P → "Codeium: Sign In"

# 4. Check auth is saved
#    Settings Sync → Show Synced Data → Check extensions
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
      "**/build": true
    }
  }
}

# 4. Restart container
docker-compose restart dev
```

### API Key Not Loading

**Problem:** Environment variable API keys don't work

**Solution:**
```bash
# 1. Verify environment variables are set
echo $OPENAI_API_KEY

# 2. Pass to container via .env file
cat > .env << EOF
OPENAI_API_KEY=${OPENAI_API_KEY}
ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
EOF

# 3. Update docker-compose.yml to pass env vars
env_file:
  - .env

# 4. Restart container
docker-compose restart dev

# 5. Verify in container
docker exec -it dev-container bash
echo $OPENAI_API_KEY
```

### Extension Conflicts

**Problem:** Multiple AI tools interfering with each other

**Solution:**
```json
// Disable conflicting features
{
  // Only one AI autocomplete at a time
  "github.copilot.editor.enableAutoCompletions": true,
  "codeium.enableConfig": {
    "*": false  // Disable Codeium completions
  },
  "tabnine.receiveBetaChannelUpdates": false,
  
  // Or use different AI tools for different tasks:
  // - Copilot for code completion
  // - Continue for chat/refactoring
  // - Codeium for search
}
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
- API keys
- Authentication tokens
- Personal access tokens
- Secret keys

**Use these approaches:**

1. **Environment variables** (Best)
   ```bash
   export OPENAI_API_KEY="sk-..."
   ```

2. **Secret management** (Team projects)
   - AWS Secrets Manager
   - HashiCorp Vault
   - Azure Key Vault

3. **Local settings** (Personal projects)
   ```bash
   # Keep settings.json out of git
   echo ".vscode/settings.json" >> .gitignore
   ```

### Privacy Settings

**Opt out of telemetry:**
```json
{
  "github.copilot.advanced": {
    "debug.telemetry": false
  },
  "codeium.telemetryEnabled": false,
  "continue.telemetryEnabled": false,
  "amazonQ.shareContentWithAWS": false
}
```

---

## ✅ Recommended Approach

### For Most Users:
1. Enable Settings Sync in VS Code
2. Install and authenticate AI tools once
3. Keep template's `.vscode/settings.json` as-is
4. Let Settings Sync apply your AI preferences automatically
5. Done! ✨

### For Teams:
1. Use `merge-vscode-ai-config.sh` script
2. Create shared AI config baseline
3. Document required AI tools in README
4. Use `.gitignore` for personal overrides
5. Store API keys in environment variables

### For Power Users:
1. Create `.vscode/settings.ai.json` overlay
2. Use `apply-ai-config.sh` script
3. Keep personal and team settings separate
4. Document your AI workflow
5. Share best practices with team

---

## 🎉 Summary

| Method | Pros | Cons | Best For |
|--------|------|------|----------|
| **Settings Sync** | Automatic, easy, includes auth | Requires sign-in | Most users |
| **Merge Script** | One-time, automated, customizable | Manual trigger | Power users |
| **Manual Merge** | Full control, transparent | Time-consuming | Advanced users |
| **AI Overlay** | Clean separation, portable | Extra file to manage | Teams |

**Recommendation:** Start with Settings Sync. It's the easiest and works perfectly with containers and AI tools!

---

## 📚 AI Tool Documentation

### Official Resources

- **GitHub Copilot**: https://docs.github.com/copilot
- **Codeium**: https://codeium.com/vscode_tutorial
- **Continue**: https://continue.dev/docs
- **Tabnine**: https://www.tabnine.com/install/vscode
- **Amazon Q**: https://aws.amazon.com/q/developer/

### VS Code Resources

- **Settings Sync**: https://code.visualstudio.com/docs/editor/settings-sync
- **Dev Containers**: https://code.visualstudio.com/docs/devcontainers/containers
- **Extension Management**: https://code.visualstudio.com/docs/editor/extension-marketplace

---

## 🚀 Quick Start Checklist

- [ ] Enable VS Code Settings Sync
- [ ] Install preferred AI extensions
- [ ] Authenticate AI tools
- [ ] Test AI in local VS Code
- [ ] Open project in Dev Container
- [ ] Verify AI extensions load in container
- [ ] Test AI completions in container
- [ ] Configure privacy settings
- [ ] Set up API key management
- [ ] Document AI tools for team

---

Happy coding with AI assistance! 🤖✨