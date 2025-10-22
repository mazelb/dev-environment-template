#!/bin/bash

###############################################################################
# Check Template Updates Script
# Checks if updates are available for the dev environment template
###############################################################################

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

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

print_header() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Version file
VERSION_FILE=".template-version"

# Check if in a project repository
check_project_repo() {
    if [ ! -d ".git" ]; then
        print_error "Not a git repository"
        exit 1
    fi
    
    if [ ! -f "$VERSION_FILE" ]; then
        print_warning "No .template-version file found"
        print_info "This might not be a project created from the template"
        echo ""
        echo "To track template version, create .template-version:"
        echo "  echo 'v1.0.0' > .template-version"
        echo "  git add .template-version"
        echo "  git commit -m 'chore: add template version tracking'"
        exit 1
    fi
}

# Get current version
get_current_version() {
    if [ -f "$VERSION_FILE" ]; then
        cat "$VERSION_FILE" | tr -d '[:space:]'
    else
        echo "unknown"
    fi
}

# Get latest version from template
get_latest_version() {
    # Check if template remote exists
    if ! git remote get-url template &>/dev/null; then
        echo "unknown"
        return
    fi
    
    # Fetch latest tags
    git fetch template --tags --quiet 2>/dev/null || true
    
    # Get latest tag
    git ls-remote --tags template 2>/dev/null | \
        grep -o 'refs/tags/v[0-9]*\.[0-9]*\.[0-9]*$' | \
        sed 's|refs/tags/||' | \
        sort -V | \
        tail -n 1
}

# Compare versions
compare_versions() {
    local current=$1
    local latest=$2
    
    # Remove 'v' prefix if present
    current=${current#v}
    latest=${latest#v}
    
    # Split versions into array
    IFS='.' read -ra CURR <<< "$current"
    IFS='.' read -ra LATE <<< "$latest"
    
    # Compare major, minor, patch
    for i in 0 1 2; do
        curr_num=${CURR[$i]:-0}
        late_num=${LATE[$i]:-0}
        
        if [ "$late_num" -gt "$curr_num" ]; then
            return 1  # Update available
        elif [ "$late_num" -lt "$curr_num" ]; then
            return 0  # Current is newer
        fi
    done
    
    return 0  # Versions are equal
}

# Get changed files
get_changed_files() {
    local current=$1
    local latest=$2
    
    if ! git remote get-url template &>/dev/null; then
        return
    fi
    
    # Show diff summary
    git fetch template --quiet 2>/dev/null || return
    
    # Get list of changed files
    git diff --name-status "$current" "template/main" 2>/dev/null | head -20
}

# Main script
main() {
    print_header "Template Update Checker"
    
    # Check if this is a project repo
    check_project_repo
    
    # Get versions
    current_version=$(get_current_version)
    print_info "Current template version: ${YELLOW}$current_version${NC}"
    
    # Check if template remote exists
    if ! git remote get-url template &>/dev/null; then
        echo ""
        print_warning "Template remote not configured"
        echo ""
        echo "To add template remote:"
        echo "  git remote add template https://github.com/mazelb/dev-environment-template.git"
        echo "  git fetch template"
        echo ""
        echo "Then run this script again."
        exit 1
    fi
    
    print_success "Template remote found"
    
    # Fetch latest version
    print_info "Checking for updates..."
    latest_version=$(get_latest_version)
    
    if [ -z "$latest_version" ] || [ "$latest_version" = "unknown" ]; then
        print_warning "Could not determine latest version"
        echo ""
        echo "Make sure the template repository has version tags (e.g., v1.0.0)"
        exit 1
    fi
    
    print_info "Latest template version: ${GREEN}$latest_version${NC}"
    echo ""
    
    # Compare versions
    if compare_versions "$current_version" "$latest_version"; then
        print_success "You are up to date! ✨"
        echo ""
        echo "Your project is using the latest template version."
    else
        print_warning "Updates available! 🚀"
        echo ""
        echo "A new template version is available."
        echo ""
        
        # Show what changed
        print_info "Changed files:"
        echo ""
        get_changed_files "$current_version" "$latest_version" | while read -r line; do
            status=$(echo "$line" | awk '{print $1}')
            file=$(echo "$line" | awk '{print $2}')
            
            case $status in
                M)
                    echo -e "  ${YELLOW}Modified:${NC} $file"
                    ;;
                A)
                    echo -e "  ${GREEN}Added:${NC}    $file"
                    ;;
                D)
                    echo -e "  ${RED}Deleted:${NC}  $file"
                    ;;
                *)
                    echo -e "  ${BLUE}Changed:${NC}  $file"
                    ;;
            esac
        done
        
        echo ""
        print_header "How to Update"
        echo ""
        echo "To sync your project to the latest template version:"
        echo ""
        echo -e "  ${BLUE}./scripts/sync-template.sh${NC}"
        echo ""
        echo "Or to sync to a specific version:"
        echo ""
        echo -e "  ${BLUE}./scripts/sync-template.sh $latest_version${NC}"
        echo ""
        echo "For more information:"
        echo ""
        echo -e "  ${BLUE}./scripts/manage-template-updates.sh --help${NC}"
        echo ""
        
        # Show changelog if available
        if git rev-parse "template/$latest_version" &>/dev/null; then
            echo ""
            print_info "Recent changes:"
            echo ""
            git log --oneline "$current_version..template/$latest_version" 2>/dev/null | head -10 | \
                sed 's/^/  /' || true
            echo ""
        fi
    fi
    
    echo ""
    print_info "Template repository: $(git remote get-url template)"
    echo ""
}

main "$@"
