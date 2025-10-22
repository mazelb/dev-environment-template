# Continue Multi-Model AI Configuration Guide

Complete setup guide for using multiple AI models in VS Code Continue extension within your portable development environment.

---

## 🚀 Quick Start

```bash
# Run the automated setup script
./setup-continue-models.sh
```

This will:
1. Install Continue extension if needed
2. Configure all AI models
3. Prompt for API keys
4. Set up custom commands

---

## 📋 Included AI Models

### Claude (Anthropic)
- **Claude Opus 4.1** - Most powerful, complex reasoning
- **Claude Sonnet 4.5** - Balanced performance
- **Claude Sonnet 4** - Fast, efficient
- **Claude Haiku** - Fastest, lightweight

### OpenAI
- **GPT-4o** - Latest multimodal model
- **GPT-4o mini** - Faster, cost-effective
- **GPT-4 Turbo** - Enhanced GPT-4
- **o1-preview** - Advanced reasoning
- **o1-mini** - Smaller reasoning model

### Google Gemini
- **Gemini 2.0 Flash Exp** - Latest experimental
- **Gemini 2.0 Flash Thinking** - Chain-of-thought reasoning
- **Gemini 1.5 Pro** - Production-ready
- **Gemini 1.5 Flash** - Fast responses

### Mistral
- **Mistral Large** - Most capable
- **Mistral Medium** - Balanced
- **Codestral** - Optimized for code

### Others
- **DeepSeek Coder V2** - Specialized for coding
- **Llama 3.1 70B/8B** (via Groq) - Open models, fast inference
- **Mixtral 8x7B** (via Groq) - MoE architecture
- **Perplexity Sonar** - Web-connected responses
- **Cohere Command R+** - Enterprise-focused

### Local Models
- **Ollama** - Run models locally
- **LM Studio** - Local model server
- **GitHub Copilot** - Integrated with GitHub

---

## 🔑 Getting API Keys

### Anthropic (Claude)
1. Visit: https://console.anthropic.com/settings/keys
2. Sign up/login
3. Create new API key
4. Copy and save securely

### OpenAI
1. Visit: https://platform.openai.com/api-keys
2. Sign up/login
3. Create new API key
4. Copy and save securely

### Google AI (Gemini)
1. Visit: https://aistudio.google.com/app/apikey
2. Sign in with Google account
3. Click "Get API Key"
4. Copy and save securely

### Mistral
1. Visit: https://console.mistral.ai/api-keys
2. Create account
3. Generate API key
4. Copy and save securely

### Groq
1. Visit: https://console.groq.com/keys
2. Sign up (free tier available)
3. Create API key
4. Copy and save securely

### DeepSeek
1. Visit: https://platform.deepseek.com/api_keys
2. Register account
3. Generate API key
4. Copy and save securely

### Perplexity
1. Visit: https://www.perplexity.ai/settings/api
2. Sign up for API access
3. Generate key
4. Copy and save securely

### Cohere
1. Visit: https://dashboard.cohere.com/api-keys
2. Create account
3. Generate API key
4. Copy and save securely

---

## 🛠️ Manual Configuration

If you prefer manual setup or need to modify settings:

### 1. Install Continue Extension

```bash
# Via VS Code
code --install-extension Continue.continue

# Or in VS Code UI:
# Extensions → Search "Continue" → Install
```

### 2. Edit Configuration

```bash
# Open config file
code ~/.continue/config.json
```

### 3. Add API Keys

Replace `[API_KEY]` with your actual keys:

```json
{
  "title": "Claude Opus 4.1",
  "provider": "anthropic",
  "model": "claude-opus-4-1-20250805",
  "apiKey": "sk-ant-api03-YOUR-KEY-HERE"
}
```

---

## 💡 Usage Tips

### Keyboard Shortcuts

| Action | Mac | Windows/Linux |
|--------|-----|---------------|
| Open Continue | `Cmd+I` | `Ctrl+I` |
| Add code to chat | `Cmd+Shift+M` | `Ctrl+Shift+M` |
| Accept suggestion | `Tab` | `Tab` |
| Reject suggestion | `Esc` | `Esc` |

### Slash Commands

- `/edit` - Edit selected code
- `/comment` - Add comments
- `/test` - Generate tests
- `/fix` - Fix bugs
- `/optimize` - Improve performance
- `/document` - Generate docs
- `/cmd` - Generate shell command
- `/commit` - Generate commit message

### Context Providers

Use `@` to reference context:
- `@code` - Current file
- `@docs` - Documentation
- `@diff` - Git changes
- `@terminal` - Terminal output
- `@problems` - Error messages
- `@folder` - Directory structure
- `@codebase` - Entire project

---

## 🎯 Model Selection Guide

### For Code Generation
**Best:** Codestral, Claude Sonnet 4, GPT-4o
- Fast autocomplete
- Syntax awareness
- Pattern matching

### For Complex Logic
**Best:** Claude Opus 4.1, o1-preview, Gemini 2.0 Flash Thinking
- Multi-step reasoning
- Algorithm design
- Architecture planning

### For Quick Fixes
**Best:** Claude Haiku, GPT-4o mini, Gemini Flash
- Fast responses
- Simple edits
- Quick explanations

### For Documentation
**Best:** Claude Sonnet 4.5, GPT-4o, Mistral Large
- Clear writing
- Comprehensive coverage
- Good formatting

### For Cost-Effectiveness
**Best:** Llama models (Groq), Ollama (local), Claude Haiku
- Free/cheap options
- Good performance
- Fast inference

---

## 🔧 Advanced Configuration

### Custom Model Parameters

```json
{
  "title": "Custom Claude",
  "provider": "anthropic",
  "model": "claude-opus-4-1-20250805",
  "apiKey": "[API_KEY]",
  "contextLength": 200000,
  "completionOptions": {
    "temperature": 0.7,
    "topP": 0.9,
    "maxTokens": 4000
  }
}
```

### Tab Autocomplete Setup

```json
"tabAutocompleteModel": {
  "title": "Codestral",
  "provider": "mistral",
  "model": "codestral-latest",
  "apiKey": "[API_KEY]",
  "completionOptions": {
    "temperature": 0.2,
    "maxTokens": 500
  }
}
```

### Custom Commands

```json
"customCommands": [
  {
    "name": "review",
    "prompt": "Review this code for security vulnerabilities, performance issues, and best practices",
    "description": "Comprehensive code review"
  },
  {
    "name": "explain",
    "prompt": "Explain this code in detail for someone learning to program",
    "description": "Detailed explanation"
  }
]
```

---

## 🐳 Docker Integration

Add to your `.devcontainer/devcontainer.json`:

```json
{
  "customizations": {
    "vscode": {
      "extensions": [
        "Continue.continue"
      ]
    }
  },
  "mounts": [
    "source=${HOME}/.continue,target=/home/vscode/.continue,type=bind"
  ]
}
```

---

## 🔐 Security Best Practices

### API Key Management

1. **Never commit API keys**
   ```bash
   echo ".continue/config.json" >> .gitignore
   ```

2. **Use environment variables**
   ```json
   {
     "apiKey": "${ANTHROPIC_API_KEY}"
   }
   ```

3. **Set in `.env` file**
   ```bash
   ANTHROPIC_API_KEY=sk-ant-api03-xxx
   OPENAI_API_KEY=sk-xxx
   GEMINI_API_KEY=xxx
   ```

4. **Use secret managers** (for production)
   - AWS Secrets Manager
   - Azure Key Vault
   - HashiCorp Vault

---

## 🚨 Troubleshooting

### Extension Not Working

```bash
# Check installation
code --list-extensions | grep Continue

# Reinstall
code --uninstall-extension Continue.continue
code --install-extension Continue.continue

# Check logs
# View → Output → Continue
```

### Model Not Responding

1. Check API key is correct
2. Verify internet connection
3. Check provider status page
4. Try different model
5. Check rate limits

### Config Not Loading

```bash
# Validate JSON syntax
cat ~/.continue/config.json | python -m json.tool

# Reset to defaults
mv ~/.continue/config.json ~/.continue/config.backup.json
cp /home/claude/.continue/config.json ~/.continue/config.json
```

---

## 📊 Model Comparison

| Model | Speed | Quality | Cost | Context | Best For |
|-------|-------|---------|------|---------|----------|
| Claude Opus 4.1 | ★★★ | ★★★★★ | $$$ | 200K | Complex tasks |
| Claude Sonnet 4.5 | ★★★★ | ★★★★ | $$ | 200K | Balanced use |
| GPT-4o | ★★★★ | ★★★★ | $$ | 128K | General purpose |
| o1-preview | ★★ | ★★★★★ | $$$$ | 128K | Reasoning |
| Gemini 2.0 Flash | ★★★★★ | ★★★ | $ | 1M | Fast responses |
| Codestral | ★★★★★ | ★★★★ | $ | 32K | Code completion |
| Llama 3.1 70B | ★★★★ | ★★★ | Free* | 8K | Open source |

*Via Groq free tier or local

---

## 🔄 Updating Models

```bash
# Pull latest config
curl -o ~/.continue/config.json \
  https://raw.githubusercontent.com/your-repo/continue-configs/main/multi-model.json

# Or update manually
code ~/.continue/config.json
```

---

## 📚 Resources

- **Continue Docs**: https://continue.dev/docs
- **Continue Discord**: https://discord.gg/continue
- **Model Pricing**: 
  - Anthropic: https://anthropic.com/pricing
  - OpenAI: https://openai.com/pricing
  - Google: https://ai.google.dev/pricing
  - Mistral: https://mistral.ai/pricing

---

## 🎉 Tips for Maximum Productivity

1. **Use multiple models**: Different models excel at different tasks
2. **Enable tab autocomplete**: Codestral or GPT-4o mini for fast suggestions
3. **Learn slash commands**: Speed up common tasks
4. **Use context providers**: Give models the right context
5. **Create custom commands**: Automate your workflow
6. **Try local models**: Ollama for privacy-sensitive code
7. **Experiment with temperature**: Lower for consistency, higher for creativity

---

Happy coding with AI assistance! 🚀
