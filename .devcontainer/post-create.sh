#!/bin/bash

###############################################################################
# Post-Create Script for Dev Container
# Runs after the dev container is created
###############################################################################

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

echo ""
echo "🚀 Setting up dev environment..."
echo ""

# Load secrets from GitHub Codespaces
bash .devcontainer/load-secrets.sh

echo ""
print_success "Dev environment ready! Run: docker-compose exec dev bash"
echo ""
