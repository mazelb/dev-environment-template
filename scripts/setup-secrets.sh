#!/bin/bash

###############################################################################
# Environment Secrets Setup Script
# Securely manage API keys and secrets across different environments
###############################################################################

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}   ${GREEN}$1${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if running in Codespaces
is_codespace() {
    [ -n "$CODESPACES" ]
}

# Check if running in GitHub Actions
is_github_actions() {
    [ -n "$GITHUB_ACTIONS" ]
}

# Setup method selection
select_setup_method() {
    print_header "Secret Management Setup"
    echo ""
    echo "Select how you want to manage secrets:"
    echo ""
    echo "1) Local .env.local file (Development)"
    echo "2) GitHub Codespaces Secrets (Cloud Development)"
    echo "3) GitHub Actions Secrets (CI/CD)"
    echo "4) Docker Secrets (Production)"
    echo "5) AWS Secrets Manager (Cloud Production)"
    echo "6) Azure Key Vault (Azure Production)"
    echo "7) All of the above (Complete Setup)"
    echo ""
    read -p "Choose (1-7): " choice
    
    case $choice in
        1) setup_local_env ;;
        2) setup_codespaces_secrets ;;
        3) setup_github_actions_secrets ;;
        4) setup_docker_secrets ;;
        5) setup_aws_secrets ;;
        6) setup_azure_keyvault ;;
        7) setup_all ;;
        *) print_error "Invalid choice"; exit 1 ;;
    esac
}

# Setup local .env.local
setup_local_env() {
    print_header "Setting Up Local Environment"
    
    if [ -f ".env.local" ]; then
        print_warning ".env.local already exists"
        read -p "Overwrite? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return
        fi
    fi
    
    # Copy template
    if [ -f ".env.local.example" ]; then
        cp .env.local.example .env.local
        print_success "Created .env.local from template"
    else
        cat > .env.local << 'EOF'
# Local Development Secrets
# IMPORTANT: Never commit this file to git

# AI/LLM API Keys
ANTHROPIC_API_KEY=
OPENAI_API_KEY=

# GitHub Token
GITHUB_TOKEN=

# Database
DATABASE_URL=

# Add your secrets below
EOF
        print_success "Created .env.local template"
    fi
    
    # Make sure it's in .gitignore
    if ! grep -q ".env.local" .gitignore 2>/dev/null; then
        echo ".env.local" >> .gitignore
        print_success "Added .env.local to .gitignore"
    fi
    
    echo ""
    print_info "Edit .env.local with your actual secrets:"
    echo "  nano .env.local"
    echo ""
    print_warning "Never commit .env.local to git!"
}

# Setup GitHub Codespaces Secrets
setup_codespaces_secrets() {
    print_header "Setting Up GitHub Codespaces Secrets"
    
    echo ""
    echo "GitHub Codespaces Secrets allow you to securely store secrets in GitHub"
    echo "that are automatically available in your Codespaces environment."
    echo ""
    
    print_info "Steps to set up Codespaces Secrets:"
    echo ""
    echo "1. Go to GitHub repository settings:"
    echo "   https://github.com/mazelb/dev-environment-template/settings/secrets/codespaces"
    echo ""
    echo "2. Click 'New repository secret'"
    echo ""
    echo "3. Add these secrets:"
    echo "   - ANTHROPIC_API_KEY"
    echo "   - OPENAI_API_KEY"
    echo "   - GITHUB_TOKEN (optional, auto-provided)"
    echo "   - Any other API keys you need"
    echo ""
    echo "4. Secrets are automatically available as environment variables"
    echo ""
    
    # Create a script to load secrets in Codespaces
    cat > .devcontainer/load-secrets.sh << 'EOF'
#!/bin/bash
# Automatically load Codespaces secrets into .env.local

if [ -n "$CODESPACES" ]; then
    cat > .env.local << SECRETS_EOF
# Auto-generated from GitHub Codespaces Secrets
ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
OPENAI_API_KEY=${OPENAI_API_KEY}
GITHUB_TOKEN=${GITHUB_TOKEN}
DATABASE_URL=${DATABASE_URL}
SECRETS_EOF
    echo "✓ Loaded secrets from GitHub Codespaces"
fi
EOF
    chmod +x .devcontainer/load-secrets.sh
    
    print_success "Created .devcontainer/load-secrets.sh"
    echo ""
    print_info "This script will automatically run when you open a Codespace"
}

# Setup GitHub Actions Secrets
setup_github_actions_secrets() {
    print_header "Setting Up GitHub Actions Secrets"
    
    echo ""
    print_info "Steps to set up GitHub Actions Secrets:"
    echo ""
    echo "1. Go to repository settings:"
    echo "   https://github.com/mazelb/dev-environment-template/settings/secrets/actions"
    echo ""
    echo "2. Click 'New repository secret'"
    echo ""
    echo "3. Add these secrets for CI/CD:"
    echo "   - ANTHROPIC_API_KEY"
    echo "   - OPENAI_API_KEY"
    echo "   - DOCKER_USERNAME (for Docker Hub)"
    echo "   - DOCKER_PASSWORD"
    echo "   - Any other secrets needed for testing/deployment"
    echo ""
    
    # Create example GitHub Actions workflow
    mkdir -p .github/workflows
    cat > .github/workflows/test-with-secrets.yml << 'EOF'
name: Test with Secrets

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up environment
        run: |
          cp .env.local.example .env.local
      
      - name: Load secrets
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
          OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
        run: |
          echo "ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY" >> .env.local
          echo "OPENAI_API_KEY=$OPENAI_API_KEY" >> .env.local
      
      - name: Build Docker image
        run: docker-compose build dev
      
      - name: Run tests
        run: docker-compose run dev pytest tests/
EOF
    
    print_success "Created .github/workflows/test-with-secrets.yml"
    echo ""
    print_info "Secrets are accessed via: \${{ secrets.SECRET_NAME }}"
}

# Setup Docker Secrets
setup_docker_secrets() {
    print_header "Setting Up Docker Secrets"
    
    echo ""
    print_info "Docker Secrets are for production deployments using Docker Swarm"
    echo ""
    
    # Create docker secrets example
    cat > docker-secrets-example.sh << 'EOF'
#!/bin/bash
# Example: Using Docker Secrets in production

# Create secrets
echo "your_anthropic_key" | docker secret create anthropic_api_key -
echo "your_openai_key" | docker secret create openai_api_key -

# Deploy with secrets
docker stack deploy -c docker-compose.prod.yml myapp
EOF
    chmod +x docker-secrets-example.sh
    
    # Create production docker-compose
    cat > docker-compose.prod.yml << 'EOF'
version: '3.8'

services:
  app:
    image: your-app:latest
    secrets:
      - anthropic_api_key
      - openai_api_key
    environment:
      - ANTHROPIC_API_KEY_FILE=/run/secrets/anthropic_api_key
      - OPENAI_API_KEY_FILE=/run/secrets/openai_api_key

secrets:
  anthropic_api_key:
    external: true
  openai_api_key:
    external: true
EOF
    
    print_success "Created docker-compose.prod.yml"
    print_success "Created docker-secrets-example.sh"
    echo ""
    print_info "In production, read secrets from: /run/secrets/SECRET_NAME"
}

# Setup AWS Secrets Manager
setup_aws_secrets() {
    print_header "Setting Up AWS Secrets Manager"
    
    echo ""
    print_info "AWS Secrets Manager for production secrets in AWS"
    echo ""
    
    # Create AWS secrets script
    cat > scripts/aws-secrets-setup.sh << 'EOF'
#!/bin/bash
# Setup AWS Secrets Manager

# Install AWS CLI if not present
if ! command -v aws &> /dev/null; then
    echo "Please install AWS CLI: https://aws.amazon.com/cli/"
    exit 1
fi

# Create secrets
aws secretsmanager create-secret \
    --name dev-env/anthropic-api-key \
    --secret-string "your_anthropic_key"

aws secretsmanager create-secret \
    --name dev-env/openai-api-key \
    --secret-string "your_openai_key"

echo "✓ Created secrets in AWS Secrets Manager"
EOF
    chmod +x scripts/aws-secrets-setup.sh
    
    # Create Python script to load AWS secrets
    cat > scripts/load_aws_secrets.py << 'EOF'
#!/usr/bin/env python3
"""Load secrets from AWS Secrets Manager"""

import boto3
import json
import os

def get_secret(secret_name, region_name="us-east-1"):
    client = boto3.client('secretsmanager', region_name=region_name)
    
    try:
        response = client.get_secret_value(SecretId=secret_name)
        return response['SecretString']
    except Exception as e:
        print(f"Error retrieving secret {secret_name}: {e}")
        return None

def load_secrets_to_env():
    """Load secrets from AWS and set as environment variables"""
    secrets = {
        'ANTHROPIC_API_KEY': 'dev-env/anthropic-api-key',
        'OPENAI_API_KEY': 'dev-env/openai-api-key',
    }
    
    for env_var, secret_name in secrets.items():
        secret_value = get_secret(secret_name)
        if secret_value:
            os.environ[env_var] = secret_value
            print(f"✓ Loaded {env_var}")

if __name__ == "__main__":
    load_secrets_to_env()
EOF
    chmod +x scripts/load_aws_secrets.py
    
    print_success "Created scripts/aws-secrets-setup.sh"
    print_success "Created scripts/load_aws_secrets.py"
    echo ""
    print_info "Usage: python scripts/load_aws_secrets.py"
}

# Setup Azure Key Vault
setup_azure_keyvault() {
    print_header "Setting Up Azure Key Vault"
    
    echo ""
    print_info "Azure Key Vault for production secrets in Azure"
    echo ""
    
    # Create Azure Key Vault script
    cat > scripts/azure-keyvault-setup.sh << 'EOF'
#!/bin/bash
# Setup Azure Key Vault

# Install Azure CLI if not present
if ! command -v az &> /dev/null; then
    echo "Please install Azure CLI: https://docs.microsoft.com/cli/azure/install-azure-cli"
    exit 1
fi

# Login to Azure
az login

# Create Key Vault
az keyvault create \
    --name "dev-env-secrets" \
    --resource-group "my-resource-group" \
    --location "eastus"

# Add secrets
az keyvault secret set \
    --vault-name "dev-env-secrets" \
    --name "anthropic-api-key" \
    --value "your_anthropic_key"

az keyvault secret set \
    --vault-name "dev-env-secrets" \
    --name "openai-api-key" \
    --value "your_openai_key"

echo "✓ Created secrets in Azure Key Vault"
EOF
    chmod +x scripts/azure-keyvault-setup.sh
    
    # Create Python script to load Azure secrets
    cat > scripts/load_azure_secrets.py << 'EOF'
#!/usr/bin/env python3
"""Load secrets from Azure Key Vault"""

from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
import os

def load_secrets_to_env(vault_url="https://dev-env-secrets.vault.azure.net/"):
    """Load secrets from Azure Key Vault"""
    credential = DefaultAzureCredential()
    client = SecretClient(vault_url=vault_url, credential=credential)
    
    secrets = {
        'ANTHROPIC_API_KEY': 'anthropic-api-key',
        'OPENAI_API_KEY': 'openai-api-key',
    }
    
    for env_var, secret_name in secrets.items():
        try:
            secret = client.get_secret(secret_name)
            os.environ[env_var] = secret.value
            print(f"✓ Loaded {env_var}")
        except Exception as e:
            print(f"Error loading {secret_name}: {e}")

if __name__ == "__main__":
    load_secrets_to_env()
EOF
    chmod +x scripts/load_azure_secrets.py
    
    print_success "Created scripts/azure-keyvault-setup.sh"
    print_success "Created scripts/load_azure_secrets.py"
    echo ""
    print_info "Usage: python scripts/load_azure_secrets.py"
}

# Setup all methods
setup_all() {
    setup_local_env
    echo ""
    setup_codespaces_secrets
    echo ""
    setup_github_actions_secrets
    echo ""
    setup_docker_secrets
    echo ""
    setup_aws_secrets
    echo ""
    setup_azure_keyvault
    
    echo ""
    print_header "Complete Setup Finished!"
    echo ""
    print_success "All secret management methods configured"
}

# Main
main() {
    if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
        echo "Usage: $0 [METHOD]"
        echo ""
        echo "Methods:"
        echo "  local      - Local .env.local file"
        echo "  codespaces - GitHub Codespaces secrets"
        echo "  actions    - GitHub Actions secrets"
        echo "  docker     - Docker secrets"
        echo "  aws        - AWS Secrets Manager"
        echo "  azure      - Azure Key Vault"
        echo "  all        - Setup all methods"
        echo ""
        echo "If no method specified, interactive selection will be shown"
        exit 0
    fi
    
    case "$1" in
        local) setup_local_env ;;
        codespaces) setup_codespaces_secrets ;;
        actions) setup_github_actions_secrets ;;
        docker) setup_docker_secrets ;;
        aws) setup_aws_secrets ;;
        azure) setup_azure_keyvault ;;
        all) setup_all ;;
        "") select_setup_method ;;
        *) print_error "Unknown method: $1"; exit 1 ;;
    esac
}

main "$@"