#!/bin/bash

###############################################################################
# Template Update Manager
# Automates template versioning, tracking, and syncing across projects
###############################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
TEMPLATE_REPO="https://github.com/mazelb/dev-environment-template.git"
CHANGELOG_FILE="CHANGELOG.md"
VERSION_FILE=".template-version"

# Functions
print_header() {
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}   ${GREEN}$1${NC}${BLUE}                       ${NC}"
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

# Check if in template repo
check_template_repo() {
    if ! git remote get-url origin | grep -q "dev-environment-template"; then
        print_error "This script must be run in the template repository"
        exit 1
    fi
}

# Check if in project repo
check_project_repo() {
    if git remote get-url origin | grep -q "dev-environment-template"; then
        print_error "This script should be run in a project repository, not the template"
        exit 1
    fi
}

# Get current version
get_current_version() {
    if [ -f "$VERSION_FILE" ]; then
        cat "$VERSION_FILE"
    else
        git describe --tags 2>/dev/null || echo "unknown"
    fi
}

# Get latest version from template
get_latest_version() {
    git ls-remote --tags "$TEMPLATE_REPO" | \
        grep -o 'refs/tags/v[0-9.]*' | \
        sort -V | \
        tail -1 | \
        sed 's|refs/tags/||'
}

# Show help
show_help() {
    cat << EOF
Usage: $0 [COMMAND] [OPTIONS]

Manage template updates for both template and project repositories.

TEMPLATE COMMANDS (run in template repo):
  release VERSION    Create a new release (e.g., v1.2.0)
  changelog          View changelog
  status             Show template status

PROJECT COMMANDS (run in project repo):
  check              Check for template updates
  sync               Sync to latest template version
  sync VERSION       Sync to specific version (e.g., v1.2.0)
  status             Show project's template version

OPTIONS:
  --message MSG      Commit message for release
  --force            Skip confirmations
  -h, --help         Show this help

EXAMPLES:
  # In template repo
  $0 release v1.2.0 --message "Add Python 3.12"
  
  # In project repo
  $0 check
  $0 sync
  $0 sync v1.2.0

EOF
}

# Create new release
create_release() {
    local version=$1
    local message=${2:-"Release $version"}
    
    check_template_repo
    print_header "Creating Release: $version"
    
    # Validate version format
    if ! [[ "$version" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        print_error "Invalid version format. Use: v1.2.0"
        exit 1
    fi
    
    # Check if version exists
    if git rev-parse "$version" >/dev/null 2>&1; then
        print_error "Version $version already exists"
        exit 1
    fi
    
    # Create tag
    print_info "Creating tag: $version"
    git tag -a "$version" -m "$message"
    
    # Push tag
    print_info "Pushing tag..."
    git push origin "$version"
    
    # Update template projects that track this repo
    print_success "Release $version created and pushed"
    echo ""
    echo "Next steps:"
    echo "  1. Create release notes on GitHub"
    echo "  2. Notify projects: https://github.com/$TEMPLATE_REPO/releases/tag/$version"
    echo "  3. Projects can sync with: ./manage-template-updates.sh sync $version"
}

# Show changelog
show_changelog() {
    check_template_repo
    
    if [ -f "$CHANGELOG_FILE" ]; then
        less "$CHANGELOG_FILE"
    else
        print_error "No CHANGELOG.md found"
        exit 1
    fi
}

# Template status
template_status() {
    check_template_repo
    
    print_header "Template Repository Status"
    
    current=$(git describe --tags 2>/dev/null || echo "none")
    print_info "Current version: $current"
    
    latest=$(git describe --tags --abbrev=0 2>/dev/null || echo "none")
    print_info "Latest tag: $latest"
    
    print_info "Branches:"
    git branch -a | sed 's/^/  /'
}

# Check for updates in project
check_updates() {
    check_project_repo
    
    print_header "Checking for Template Updates"
    
    # Get current version
    current=$(get_current_version)
    print_info "Current version: $current"
    
    # Get latest version
    latest=$(get_latest_version)
    print_info "Latest version: $latest"
    
    echo ""
    
    if [ "$current" = "$latest" ]; then
        print_success "You're using the latest template version!"
    else
        print_warning "Updates available!"
        echo ""
        echo "To update, run:"
        echo "  $0 sync"
        echo ""
        echo "Or update to specific version:"
        echo "  $0 sync $latest"
    fi
}

# Sync project to template version
sync_template() {
    check_project_repo
    
    local target_version=${1:-$(get_latest_version)}
    
    print_header "Syncing to Template $target_version"
    
    # Check if template remote exists
    if ! git remote get-url template-upstream &>/dev/null; then
        print_info "Adding template as upstream remote..."
        git remote add template-upstream "$TEMPLATE_REPO"
    fi
    
    # Fetch template
    print_info "Fetching template..."
    git fetch template-upstream
    
    # Check if version exists
    if ! git rev-parse "template-upstream/main" >/dev/null 2>&1; then
        print_error "Template version not found"
        exit 1
    fi
    
    # Create sync branch
    branch_name="sync/template-$(date +%Y%m%d-%H%M%S)"
    print_info "Creating branch: $branch_name"
    git checkout -b "$branch_name"
    
    # Show what changed
    echo ""
    print_info "Changes from template:"
    git log --oneline main...template-upstream/main | head -20
    echo ""
    
    # Ask for confirmation
    read -p "Proceed with merge? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Cancelled. Cleaning up..."
        git checkout main
        git branch -D "$branch_name"
        exit 0
    fi
    
    # Merge
    print_info "Merging template changes..."
    git merge --no-ff template-upstream/main --message "Sync: Update template to $target_version"
    
    # Save version
    echo "$target_version" > "$VERSION_FILE"
    git add "$VERSION_FILE"
    git commit --amend --no-edit
    
    echo ""
    print_success "Template synced to $target_version"
    echo ""
    echo "Next steps:"
    echo "  1. Review changes: git diff main..HEAD"
    echo "  2. Test: docker-compose build --no-cache dev"
    echo "  3. Push: git push origin $branch_name"
    echo "  4. Create Pull Request on GitHub"
}

# Project status
project_status() {
    check_project_repo
    
    print_header "Project Template Status"
    
    version=$(get_current_version)
    latest=$(get_latest_version)
    
    print_info "Current version: $version"
    print_info "Latest version: $latest"
    
    if [ -f "$VERSION_FILE" ]; then
        print_success ".template-version file tracked"
    else
        print_warning ".template-version not found"
    fi
}

# Main script logic
main() {
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi
    
    command=$1
    shift
    
    case $command in
        release)
            if [ $# -lt 1 ]; then
                print_error "Version required"
                show_help
                exit 1
            fi
            create_release "$@"
            ;;
        changelog)
            show_changelog
            ;;
        check)
            check_updates
            ;;
        sync)
            sync_template "$@"
            ;;
        status)
            # Detect if template or project repo
            if git remote get-url origin 2>/dev/null | grep -q "dev-environment-template"; then
                template_status
            else
                project_status
            fi
            ;;
        -h|--help|help)
            show_help
            ;;
        *)
            print_error "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

main "$@"