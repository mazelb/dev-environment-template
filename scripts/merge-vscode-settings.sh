#!/bin/bash

###############################################################################
# Merge VS Code Settings Script
# Merges your personal VS Code settings with the template settings
###############################################################################

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
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
        # Windows
        settings_path="$APPDATA/Code/User/settings.json"
    fi
    
    echo "$settings_path"
}

# Main script
main() {
    echo "🔄 VS Code Settings Merger"
    echo ""
    
    # Check if jq is installed
    if ! command -v jq &> /dev/null; then
        print_error "jq is required but not installed"
        echo "Install with:"
        echo "  macOS: brew install jq"
        echo "  Linux: sudo apt-get install jq"
        echo "  Windows: choco install jq"
        exit 1
    fi
    
    # Find user settings
    USER_SETTINGS=$(find_vscode_settings)
    
    if [ ! -f "$USER_SETTINGS" ]; then
        print_error "Could not find your VS Code settings at: $USER_SETTINGS"
        exit 1
    fi
    
    print_success "Found your VS Code settings: $USER_SETTINGS"
    
    # Check if template settings exist
    TEMPLATE_SETTINGS=".vscode/settings.json"
    
    if [ ! -f "$TEMPLATE_SETTINGS" ]; then
        print_error "Template settings not found at: $TEMPLATE_SETTINGS"
        exit 1
    fi
    
    print_success "Found template settings: $TEMPLATE_SETTINGS"
    
    # Backup template settings
    cp "$TEMPLATE_SETTINGS" "$TEMPLATE_SETTINGS.backup"
    print_success "Backed up template settings to: $TEMPLATE_SETTINGS.backup"
    
    # Settings to preserve from template (container-specific)
    PRESERVE_KEYS=(
        "python.defaultInterpreterPath"
        "remote.containers.defaultExtensions"
        "python.linting.enabled"
        "python.formatting.provider"
        "files.watcherExclude"
        "search.exclude"
    )
    
    echo ""
    print_info "Merging settings (template takes precedence for container-specific settings)..."
    
    # Extract user settings excluding container-specific keys
    USER_SETTINGS_FILTERED=$(jq 'del(
        .["python.defaultInterpreterPath"],
        .["remote.containers.defaultExtensions"],
        .["files.watcherExclude"],
        .["search.exclude"]
    )' "$USER_SETTINGS")
    
    # Merge: Template settings + User settings
    MERGED=$(jq -s '.[0] * .[1]' "$TEMPLATE_SETTINGS" <(echo "$USER_SETTINGS_FILTERED"))
    
    # Write merged settings
    echo "$MERGED" | jq '.' > "$TEMPLATE_SETTINGS"
    
    print_success "Settings merged successfully!"
    
    echo ""
    echo "📝 Summary:"
    echo "  - Template settings: preserved container-specific settings"
    echo "  - Your settings: added personal preferences"
    echo "  - Backup: $TEMPLATE_SETTINGS.backup"
    echo ""
    echo "Review the merged settings:"
    echo "  code $TEMPLATE_SETTINGS"
    echo ""
    echo "To restore template settings:"
    echo "  cp $TEMPLATE_SETTINGS.backup $TEMPLATE_SETTINGS"
}

main "$@"