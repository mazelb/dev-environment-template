#!/bin/bash

###############################################################################
# Load Secrets Script for GitHub Codespaces
# Automatically loads secrets from Codespaces into the dev container
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

# Check if running in Codespaces
is_codespaces() {
    [ -n "$CODESPACES" ] && [ "$CODESPACES" = "true" ]
}

# Load secrets into .env file
load_secrets() {
    local env_file="$1"
    local secrets_loaded=0
    
    print_info "Loading secrets from GitHub Codespaces..."
    
    # Create or clear the .env file
    > "$env_file"
    
    # Common secret names to check
    # Add your specific secret names here
    local secret_names=(
        "DATABASE_URL"
        "API_KEY"
        "AWS_ACCESS_KEY_ID"
        "AWS_SECRET_ACCESS_KEY"
        "OPENAI_API_KEY"
        "ANTHROPIC_API_KEY"
        "STRIPE_API_KEY"
        "GITHUB_TOKEN"
        "SLACK_TOKEN"
        "REDIS_URL"
        "POSTGRES_PASSWORD"
        "JWT_SECRET"
        "ENCRYPTION_KEY"
    )
    
    # Check each secret and add to .env if it exists
    for secret_name in "${secret_names[@]}"; do
        if [ -n "${!secret_name}" ]; then
            echo "${secret_name}=${!secret_name}" >> "$env_file"
            print_success "Loaded: $secret_name"
            ((secrets_loaded++))
        fi
    done
    
    # Also check for any environment variables starting with common prefixes
    local prefixes=("DB_" "API_" "AWS_" "SECRET_" "TOKEN_")
    
    for prefix in "${prefixes[@]}"; do
        while IFS='=' read -r name value; do
            if [[ $name == ${prefix}* ]] && [ -n "$value" ]; then
                # Check if not already added
                if ! grep -q "^${name}=" "$env_file" 2>/dev/null; then
                    echo "${name}=${value}" >> "$env_file"
                    print_success "Loaded: $name"
                    ((secrets_loaded++))
                fi
            fi
        done < <(env)
    done
    
    if [ $secrets_loaded -eq 0 ]; then
        print_warning "No secrets found in Codespaces environment"
        print_info "Add secrets at: https://github.com/settings/codespaces"
    else
        print_success "Loaded $secrets_loaded secret(s) into $env_file"
    fi
    
    # Set proper permissions
    chmod 600 "$env_file"
    
    return 0
}

# Export secrets to current shell
export_secrets() {
    local env_file="$1"
    
    if [ -f "$env_file" ]; then
        print_info "Exporting secrets to environment..."
        set -a
        source "$env_file"
        set +a
        print_success "Secrets exported to current environment"
    fi
}

# Main script
main() {
    echo "🔐 GitHub Codespaces Secrets Loader"
    echo ""
    
    # Check if running in Codespaces
    if ! is_codespaces; then
        print_warning "Not running in GitHub Codespaces"
        print_info "This script is designed for Codespaces environments"
        exit 0
    fi
    
    print_success "Running in GitHub Codespaces"
    
    # Determine .env file location
    local env_file="${ENV_FILE:-.env}"
    
    # If we're in /workspaces, use that path
    if [ -d "/workspaces" ]; then
        # Find the workspace directory
        local workspace_dir=$(find /workspaces -maxdepth 1 -type d | tail -n 1)
        if [ -n "$workspace_dir" ] && [ "$workspace_dir" != "/workspaces" ]; then
            env_file="${workspace_dir}/.env"
        fi
    fi
    
    print_info "Target .env file: $env_file"
    
    # Load secrets
    load_secrets "$env_file"
    
    # Export to current environment
    export_secrets "$env_file"
    
    echo ""
    print_success "Secrets loading complete!"
    echo ""
    echo "📝 Next steps:"
    echo "  1. Review loaded secrets: cat $env_file"
    echo "  2. Add more secrets: https://github.com/settings/codespaces"
    echo "  3. Restart services if needed: docker-compose restart"
    echo ""
    echo "⚠️  Never commit .env to version control!"
}

# Run main function
main "$@"
