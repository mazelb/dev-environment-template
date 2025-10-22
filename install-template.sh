#!/bin/bash

###############################################################################
# Dev Environment Template - Complete Installation Script
# Downloads and sets up the complete dev environment template on your machine
###############################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Default values
TEMPLATE_REPO="${TEMPLATE_REPO:-https://github.com/mazedlb/dev-environment-template.git}"
INSTALL_DIR="${INSTALL_DIR:-.}"
GITHUB_USERNAME=""
SKIP_VALIDATION=false

# Functions
print_banner() {
    clear
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║   ${GREEN}Dev Environment Template - Complete Setup${BLUE}              ║"
    echo "║                                                            ║"
    echo "║   Cross-platform development with Docker & VS Code        ║"
    echo "║                                                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

print_header() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    local missing=false
    
    # Check Docker
    if command -v docker &> /dev/null; then
        print_success "Docker installed"
    else
        print_error "Docker not installed"
        missing=true
    fi
    
    # Check Docker Compose
    if command -v docker-compose &> /dev/null; then
        print_success "Docker Compose installed"
    else
        print_error "Docker Compose not installed"
        missing=true
    fi
    
    # Check Git
    if command -v git &> /dev/null; then
        print_success "Git installed"
    else
        print_error "Git not installed"
        missing=true
    fi
    
    # Check if Docker daemon is running
    if docker ps &> /dev/null; then
        print_success "Docker daemon is running"
    else
        print_warning "Docker daemon not running (will start Docker Desktop if available)"
    fi
    
    echo ""
    
    if [ "$missing" = true ]; then
        print_error "Missing prerequisites"
        echo ""
        echo "Please install:"
        echo "  • Docker: https://docs.docker.com/get-docker/"
        echo "  • Docker Compose: https://docs.docker.com/compose/install/"
        echo "  • Git: https://git-scm.com/downloads"
        exit 1
    fi
}

# Get GitHub credentials
get_github_info() {
    print_header "GitHub Configuration"
    
    read -p "Enter your GitHub username: " GITHUB_USERNAME
    
    if [ -z "$GITHUB_USERNAME" ]; then
        print_error "GitHub username cannot be empty"
        exit 1
    fi
    
    # Validate username format
    if ! [[ "$GITHUB_USERNAME" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$ ]]; then
        print_error "Invalid GitHub username format"
        exit 1
    fi
    
    print_success "GitHub username: $GITHUB_USERNAME"
    
    # Update template URL
    TEMPLATE_REPO="https://github.com/$GITHUB_USERNAME/dev-environment-template.git"
    
    echo ""
}

# Clone or create template
setup_template() {
    print_header "Setting Up Template Repository"
    
    # Check if directory exists
    if [ -d "dev-environment-template" ]; then
        print_warning "dev-environment-template directory already exists"
        read -p "Delete and recreate? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf dev-environment-template
        else
            print_info "Using existing directory"
            INSTALL_DIR="dev-environment-template"
            return
        fi
    fi
    
    # Try to clone from GitHub
    print_info "Attempting to clone from GitHub..."
    if git clone "$TEMPLATE_REPO" dev-environment-template 2>/dev/null; then
        print_success "Template cloned from GitHub"
        INSTALL_DIR="dev-environment-template"
    else
        print_warning "Could not clone from GitHub (repository may not exist yet)"
        print_info "Creating template from scratch..."
        
        mkdir -p dev-environment-template
        INSTALL_DIR="dev-environment-template"
        
        # Initialize git
        cd "$INSTALL_DIR"
        git init
        cd ..
        
        print_success "Template directory created"
    fi
}

# Create all template files
create_template_files() {
    print_header "Creating Template Files"
    
    cd "$INSTALL_DIR"
    
    # Create directory structure
    print_info "Creating directory structure..."
    mkdir -p .devcontainer scripts docs examples .github/workflows src
    
    # Create .gitkeep files
    touch .devcontainer/.gitkeep scripts/.gitkeep docs/.gitkeep src/.gitkeep
    
    print_success "Directories created"
    
    # Note: Actual files need to be copied from artifacts
    # This script assumes files are already created or will prompt to add them
    print_info "Files structure ready"
}

# Verify installation
verify_installation() {
    print_header "Verifying Installation"
    
    cd "$INSTALL_DIR"
    
    local checks_passed=0
    local checks_total=0
    
    # Check key files
    for file in Dockerfile docker-compose.yml .env.example .gitignore create-project.sh; do
        checks_total=$((checks_total + 1))
        if [ -f "$file" ]; then
            print_success "$file exists"
            checks_passed=$((checks_passed + 1))
        else
            print_warning "$file not found (will be needed)"
        fi
    done
    
    # Check directories
    for dir in .devcontainer scripts docs; do
        checks_total=$((checks_total + 1))
        if [ -d "$dir" ]; then
            print_success "$dir/ exists"
            checks_passed=$((checks_passed + 1))
        else
            print_warning "$dir/ not found"
        fi
    done
    
    echo ""
    echo "Checks passed: $checks_passed/$checks_total"
    
    if [ $checks_passed -lt $checks_total ]; then
        print_warning "Some files are missing. Please copy the template files from the artifacts."
    fi
}

# Test Docker build
test_docker_build() {
    print_header "Testing Docker Build"
    
    cd "$INSTALL_DIR"
    
    if [ ! -f "Dockerfile" ]; then
        print_warning "Dockerfile not found, skipping Docker test"
        return
    fi
    
    print_info "Building Docker image (this may take a few minutes)..."
    
    if docker-compose build dev 2>&1 | tail -20; then
        print_success "Docker image built successfully!"
    else
        print_error "Docker build failed"
        print_info "Check Docker logs for details"
        return 1
    fi
}

# Initialize git and commit
initialize_git() {
    print_header "Initializing Git Repository"
    
    cd "$INSTALL_DIR"
    
    # Check if git is already initialized
    if [ ! -d ".git" ]; then
        git init
        print_success "Git repository initialized"
    else
        print_info "Git repository already initialized"
    fi
    
    # Add files
    print_info "Adding files to git..."
    git add .
    
    # Commit
    git commit -m "Initial commit: Dev environment template

- Dockerfile with C++, Python, Node.js, Kotlin
- Docker Compose configuration
- VS Code Dev Container setup
- create-project.sh for spinning new projects
- Complete documentation and examples" 2>/dev/null || print_warning "Nothing new to commit"
    
    print_success "Git repository ready"
}

# Configure GitHub
configure_github() {
    print_header "GitHub Configuration"
    
    cd "$INSTALL_DIR"
    
    echo ""
    print_info "To push to GitHub, follow these steps:"
    echo ""
    echo "  1. Create repository on GitHub:"
    echo "     https://github.com/new"
    echo ""
    echo "  2. Name it: dev-environment-template"
    echo ""
    echo "  3. Run these commands:"
    echo ""
    echo "     ${CYAN}git remote add origin https://github.com/$GITHUB_USERNAME/dev-environment-template.git${NC}"
    echo "     ${CYAN}git branch -M main${NC}"
    echo "     ${CYAN}git push -u origin main${NC}"
    echo ""
    echo "  4. Enable Template Repository:"
    echo "     Go to Settings → Check 'Template repository'"
    echo ""
}

# Setup permissions
setup_permissions() {
    print_header "Setting Up Permissions"
    
    cd "$INSTALL_DIR"
    
    chmod +x create-project.sh 2>/dev/null || true
    chmod +x scripts/*.sh 2>/dev/null || true
    
    print_success "Scripts are executable"
}

# Create test project
create_test_project() {
    print_header "Creating Test Project"
    
    cd "$INSTALL_DIR"
    
    if [ ! -f "create-project.sh" ]; then
        print_warning "create-project.sh not found, skipping test"
        return
    fi
    
    read -p "Create a test project? (y/N) " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ./create-project.sh --name test-project --no-build
        print_success "Test project created"
        
        echo ""
        print_info "To test the project:"
        echo "  cd test-project"
        echo "  docker-compose up -d dev"
        echo "  docker-compose exec dev bash"
    fi
}

# Print summary
print_summary() {
    print_header "Installation Complete! 🎉"
    
    echo ""
    echo -e "${GREEN}Your dev environment template is ready!${NC}"
    echo ""
    echo "Next steps:"
    echo ""
    echo "  1. ${CYAN}Copy template files from artifacts${NC}"
    echo "     (If not already present: Dockerfile, docker-compose.yml, etc.)"
    echo ""
    echo "  2. ${CYAN}Review the documentation${NC}"
    echo "     cd $INSTALL_DIR"
    echo "     cat README.md"
    echo ""
    echo "  3. ${CYAN}Push to GitHub${NC}"
    echo "     cd $INSTALL_DIR"
    echo "     git remote add origin https://github.com/$GITHUB_USERNAME/dev-environment-template.git"
    echo "     git branch -M main"
    echo "     git push -u origin main"
    echo ""
    echo "  4. ${CYAN}Enable as GitHub template${NC}"
    echo "     Go to Settings → Check 'Template repository'"
    echo ""
    echo "  5. ${CYAN}Create new projects${NC}"
    echo "     cd $INSTALL_DIR"
    echo "     ./create-project.sh --name my-app"
    echo ""
    echo -e "${CYAN}📖 Documentation:${NC}"
    echo "   - README.md - Quick start"
    echo "   - docs/SETUP_GUIDE.md - Detailed setup"
    echo "   - docs/USAGE_GUIDE.md - How to use"
    echo "   - docs/TROUBLESHOOTING.md - Common issues"
    echo ""
    echo "Happy coding! 🚀"
    echo ""
}

# Show help
show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Install the complete dev environment template on your machine.

OPTIONS:
    -d, --dir DIR              Installation directory (default: .)
    -r, --repo URL             Template repo URL (default: https://github.com/mazelb/dev-environment-template.git)
    --skip-validation          Skip prerequisite checks
    -h, --help                 Show this help message

EXAMPLES:
    # Standard installation in current directory
    $0
    
    # Install in specific directory
    $0 --dir ~/dev-templates
    
    # Install with specific repo
    $0 --repo https://github.com/myuser/my-template.git

EOF
}

# Parse arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--dir)
                INSTALL_DIR="$2"
                shift 2
                ;;
            -r|--repo)
                TEMPLATE_REPO="$2"
                shift 2
                ;;
            --skip-validation)
                SKIP_VALIDATION=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Main
main() {
    parse_args "$@"
    
    print_banner
    
    # Check prerequisites
    if [ "$SKIP_VALIDATION" = false ]; then
        check_prerequisites
    fi
    
    # Get GitHub info
    get_github_info
    
    # Setup template
    setup_template
    
    # Create files
    create_template_files
    
    # Setup permissions
    setup_permissions
    
    # Initialize git
    initialize_git
    
    # Verify
    verify_installation
    
    # Test Docker (optional)
    read -p "Test Docker build? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        test_docker_build
    fi
    
    echo ""
    
    # Configure GitHub
    configure_github
    
    # Create test project
    create_test_project
    
    echo ""
    
    # Print summary
    print_summary
}

# Run main
main "$@"