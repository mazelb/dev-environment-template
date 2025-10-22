#!/bin/bash

###############################################################################
# Merge VS Code AI Configuration Script
# Merges your personal GitHub Copilot and Continue settings
# with the template settings
###############################################################################

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_section() {
    echo -e "${CYAN}▸${NC} $1"
}

# Detect OS and find VS Code settings
find_vscode_settings() {
    local settings_path=""
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        settings_path="$HOME/Library/Application Support/Code/User/settings.json"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        settings_path="$HOME/.config/Code/User/settings.json"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        # Windows Git Bash
        settings_path="$APPDATA/Code/User/settings.json"
    fi
    
    echo "$settings_path"
}

# Extract AI-related settings from user settings (Copilot and Continue only)
extract_ai_settings() {
    local settings_file="$1"
    
    # AI setting key patterns to extract (only Copilot and Continue)
    local ai_keys=(
        "github.copilot"
        "continue"
    )
    
    # Build jq filter to extract AI settings
    local jq_filter="{"
    for key in "${ai_keys[@]}"; do
        jq_filter+=" \"$key\": .\"$key\","
    done
    # Remove trailing comma and close
    jq_filter="${jq_filter%,}}"
    
    # Extract and remove null values
    jq "$jq_filter | with_entries(select(.value != null))" "$settings_file"
}

# Detect which AI tools are configured
detect_ai_tools() {
    local settings_file="$1"
    local tools=()
    
    if jq -e '.["github.copilot"]' "$settings_file" > /dev/null 2>&1; then
        tools+=("GitHub Copilot")
    fi
    
    if jq -e '.continue' "$settings_file" > /dev/null 2>&1; then
        tools+=("Continue")
    fi
    
    echo "${tools[@]}"
}

# Main script
main() {
    echo "🤖 VS Code AI Configuration Merger"
    echo "   (GitHub Copilot + Continue)"
    echo ""
    
    # Check if jq is installed
    if ! command -v jq &> /dev/null; then
        print_error "jq is required but not installed"
        echo ""
        echo "Install with:"
        echo "  macOS:   brew install jq"
        echo "  Linux:   sudo apt-get install jq"
        echo "  Windows: choco install jq"
        exit 1
    fi
    
    # Find user settings
    USER_SETTINGS=$(find_vscode_settings)
    
    if [ ! -f "$USER_SETTINGS" ]; then
        print_error "Could not find your VS Code settings at: $USER_SETTINGS"
        echo ""
        echo "Please ensure VS Code is installed and you have a settings.json file"
        exit 1
    fi
    
    print_success "Found your VS Code settings: $USER_SETTINGS"
    
    # Check if template settings exist
    TEMPLATE_SETTINGS=".vscode/settings.json"
    
    if [ ! -f "$TEMPLATE_SETTINGS" ]; then
        print_error "Template settings not found at: $TEMPLATE_SETTINGS"
        echo ""
        echo "Please run this script from the project root directory"
        exit 1
    fi
    
    print_success "Found template settings: $TEMPLATE_SETTINGS"
    
    # Backup template settings
    BACKUP_FILE="$TEMPLATE_SETTINGS.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$TEMPLATE_SETTINGS" "$BACKUP_FILE"
    print_success "Backed up template settings to: $BACKUP_FILE"
    
    echo ""
    print_section "Analyzing AI configuration..."
    
    # Extract AI settings from user settings
    AI_SETTINGS=$(extract_ai_settings "$USER_SETTINGS")
    
    # Detect AI tools
    DETECTED_TOOLS=($(detect_ai_tools "$USER_SETTINGS"))
    
    if [ ${#DETECTED_TOOLS[@]} -eq 0 ]; then
        print_warning "No GitHub Copilot or Continue settings detected"
        echo ""
        echo "This script looks for settings from:"
        echo "  - GitHub Copilot"
        echo "  - Continue"
        echo ""
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Aborting merge"
            exit 0
        fi
    else
        print_info "Detected AI tools:"
        for tool in "${DETECTED_TOOLS[@]}"; do
            echo "    - $tool"
        done
    fi
    
    echo ""
    print_section "Merging AI configuration..."
    
    # Container-specific settings to preserve from template
    PRESERVE_SETTINGS='
    {
      "python.defaultInterpreterPath": .["python.defaultInterpreterPath"],
      "remote.containers.defaultExtensions": .["remote.containers.defaultExtensions"],
      "files.watcherExclude": .["files.watcherExclude"],
      "search.exclude": .["search.exclude"]
    }
    '
    
    # Extract container-specific settings from template
    TEMPLATE_PRESERVE=$(jq "$PRESERVE_SETTINGS | with_entries(select(.value != null))" "$TEMPLATE_SETTINGS")
    
    # Get all template settings
    TEMPLATE_ALL=$(cat "$TEMPLATE_SETTINGS")
    
    # Merge: Template settings + User AI settings, then re-apply preserved settings
    MERGED=$(jq -s '
      # Merge template with user AI settings
      .[0] * .[1] |
      # Re-apply container-specific settings (highest priority)
      . * .[2]
    ' <(echo "$TEMPLATE_ALL") <(echo "$AI_SETTINGS") <(echo "$TEMPLATE_PRESERVE"))
    
    # Validate JSON
    if ! echo "$MERGED" | jq . > /dev/null 2>&1; then
        print_error "Failed to generate valid JSON during merge"
        print_info "Your settings may have JSON errors"
        echo ""
        echo "Check your settings file:"
        echo "  code $USER_SETTINGS"
        exit 1
    fi
    
    # Write merged settings
    echo "$MERGED" | jq '.' > "$TEMPLATE_SETTINGS"
    
    print_success "AI configuration merged successfully!"
    
    echo ""
    echo "📝 Summary:"
    echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if [ ${#DETECTED_TOOLS[@]} -gt 0 ]; then
        echo "  AI tools: ${DETECTED_TOOLS[*]}"
    else
        echo "  AI tools: None detected"
    fi
    echo "  Template: preserved container-specific settings"
    echo "  Your settings: merged AI preferences"
    echo "  Backup: $BACKUP_FILE"
    echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Provide next steps
    print_info "Next steps:"
    echo ""
    echo "  1. Review merged settings:"
    echo "     code $TEMPLATE_SETTINGS"
    echo ""
    echo "  2. Test in container:"
    echo "     docker-compose up -d dev"
    echo "     code ."
    echo "     # Cmd/Ctrl+Shift+P → 'Remote-Containers: Reopen in Container'"
    echo ""
    echo "  3. Verify AI tools work in container:"
    echo "     - GitHub Copilot: Try getting code suggestions"
    echo "     - Continue: Open Continue sidebar (Cmd/Ctrl+L)"
    echo ""
    echo "  4. To restore template settings:"
    echo "     cp $BACKUP_FILE $TEMPLATE_SETTINGS"
    echo ""
    
    # Check for Continue config
    CONTINUE_CONFIG="$HOME/.continue/config.json"
    if [ -f "$CONTINUE_CONFIG" ]; then
        print_success "Found Continue config: $CONTINUE_CONFIG"
        
        # Check if API keys use environment variables
        if grep -q "\${" "$CONTINUE_CONFIG"; then
            echo ""
            print_info "Continue config uses environment variables"
            echo ""
            echo "  Make sure these are set:"
            echo "    export ANTHROPIC_API_KEY='sk-ant-...'"
            echo "    export OPENAI_API_KEY='sk-...'"
            echo ""
            echo "  And passed to Docker container via .env file"
        fi
    else
        print_warning "Continue config not found at: $CONTINUE_CONFIG"
        echo ""
        echo "  If you're using Continue, create the config file:"
        echo "    mkdir -p ~/.continue"
        echo "    code ~/.continue/config.json"
        echo ""
        echo "  Example config:"
        echo '    {'
        echo '      "models": ['
        echo '        {'
        echo '          "title": "Claude Sonnet",'
        echo '          "provider": "anthropic",'
        echo '          "model": "claude-sonnet-4-20250514",'
        echo '          "apiKey": "${ANTHROPIC_API_KEY}"'
        echo '        }'
        echo '      ]'
        echo '    }'
        echo ""
    fi
    
    # Check if .gitignore includes .env
    if [ -f .gitignore ]; then
        if ! grep -q "^\.env$" .gitignore; then
            print_warning "Consider adding .env to .gitignore for API keys:"
            echo "     echo '.env' >> .gitignore"
            echo ""
        fi
    fi
}

# Run main function
main "$@"
