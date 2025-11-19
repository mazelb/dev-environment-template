#!/bin/bash

###############################################################################
# Git Helper Functions
# Provides Git-related utilities for project initialization
###############################################################################

# Color codes (define if not already defined)
RED=${RED:-'\033[0;31m'}
GREEN=${GREEN:-'\033[0;32m'}
YELLOW=${YELLOW:-'\033[1;33m'}
BLUE=${BLUE:-'\033[0;34m'}
CYAN=${CYAN:-'\033[0;36m'}
NC=${NC:-'\033[0m'}

# Print functions (define if not already defined)
if ! command -v print_success &> /dev/null; then
    print_success() { echo -e "${GREEN}✓${NC} $1"; }
fi

if ! command -v print_error &> /dev/null; then
    print_error() { echo -e "${RED}✗${NC} $1"; }
fi

if ! command -v print_info &> /dev/null; then
    print_info() { echo -e "${CYAN}ℹ${NC} $1"; }
fi

if ! command -v print_warning &> /dev/null; then
    print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
fi

# ==============================================================================
# Version Information
# ==============================================================================

# Get template version from git tag or VERSION file
get_template_version() {
    local script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    local template_root="$(dirname "$script_dir")"

    # Try to get version from git tag
    if command -v git &> /dev/null && [ -d "$template_root/.git" ]; then
        local git_version=$(git -C "$template_root" describe --tags --abbrev=0 2>/dev/null)
        if [ -n "$git_version" ]; then
            echo "$git_version"
            return 0
        fi
    fi

    # Try VERSION file
    if [ -f "$template_root/VERSION" ]; then
        cat "$template_root/VERSION"
        return 0
    fi

    # Default version
    echo "1.0.0"
}

# ==============================================================================
# Archetype Information Extraction
# ==============================================================================

# List archetypes with their versions
list_archetypes_with_versions() {
    local archetypes=$1
    local output=""

    if [ -z "$archetypes" ]; then
        echo "  - None specified"
        return 0
    fi

    # Convert space or comma-separated list to array
    IFS=', ' read -ra ARCH_ARRAY <<< "$archetypes"

    for archetype in "${ARCH_ARRAY[@]}"; do
        [ -z "$archetype" ] && continue

        local metadata_file="$ARCHETYPES_DIR/$archetype/__archetype__.json"

        if [ -f "$metadata_file" ]; then
            local name=$(jq -r '.metadata.name // .metadata.display_name // "unknown"' "$metadata_file" 2>/dev/null)
            local version=$(jq -r '.metadata.version // .metadata.archetype_version // "1.0.0"' "$metadata_file" 2>/dev/null)
            output+="  - $name ($version)"$'\n'
        else
            output+="  - $archetype (unknown version)"$'\n'
        fi
    done

    if [ -n "$output" ]; then
        echo "$output"
    else
        echo "  - None specified"
    fi
}

# List services from archetypes
list_services_from_archetypes() {
    local archetypes=$1
    local services_list=""

    if [ -z "$archetypes" ]; then
        echo "  - None"
        return 0
    fi

    # Convert space or comma-separated list to array
    IFS=', ' read -ra ARCH_ARRAY <<< "$archetypes"

    for archetype in "${ARCH_ARRAY[@]}"; do
        [ -z "$archetype" ] && continue

        local metadata_file="$ARCHETYPES_DIR/$archetype/__archetype__.json"

        if [ -f "$metadata_file" ] && command -v jq &> /dev/null; then
            # Extract service names from the archetype
            local services=$(jq -r '.services // {} | keys[]?' "$metadata_file" 2>/dev/null)

            if [ -n "$services" ]; then
                while IFS= read -r service; do
                    services_list+="  - $service (from $archetype)"$'\n'
                done <<< "$services"
            fi
        fi
    done

    if [ -n "$services_list" ]; then
        echo "$services_list"
    else
        echo "  - None"
    fi
}

# List tools/presets used
list_tools_used() {
    local tools=$1
    local preset=$2
    local output=""

    if [ -n "$preset" ]; then
        output+="  Preset: $preset"$'\n'
    fi

    if [ -n "$tools" ]; then
        # Convert array to comma-separated list
        output+="  Tools: $tools"$'\n'
    fi

    if [ -z "$output" ]; then
        echo "  - None"
    else
        echo "$output"
    fi
}

# ==============================================================================
# Commit Message Generation
# ==============================================================================

# Generate smart commit message with archetype and tool information
generate_commit_message() {
    local project_name=$1
    local archetypes=$2
    local tools=$3
    local preset=$4

    local template_version=$(get_template_version)

    # Build commit message
    cat << EOF
Initial commit: $project_name

Project created from dev-environment-template v${template_version}

Archetypes:
$(list_archetypes_with_versions "$archetypes")

Services:
$(list_services_from_archetypes "$archetypes")

Tools/Configuration:
$(list_tools_used "$tools" "$preset")

---
Generated: $(date '+%Y-%m-%d %H:%M:%S')
Template: https://github.com/mazelb/dev-environment-template
EOF
}

# ==============================================================================
# Git Initialization
# ==============================================================================

# Initialize git repository with smart commit message
initialize_git_repository() {
    local project_path=$1
    local project_name=$2
    local archetypes=$3
    local tools=$4
    local preset=$5

    # Validate inputs
    if [ -z "$project_path" ]; then
        print_error "Project path is required"
        return 1
    fi

    if [ ! -d "$project_path" ]; then
        print_error "Project path does not exist: $project_path"
        return 1
    fi

    # Check if git is installed
    if ! command -v git &> /dev/null; then
        print_error "Git is not installed"
        return 1
    fi

    # Navigate to project directory
    local original_dir=$(pwd)
    cd "$project_path" || {
        print_error "Cannot navigate to project path: $project_path"
        return 1
    }

    # Initialize git repository
    print_info "Initializing Git repository..."
    if git init 2>/dev/null; then
        print_success "Git repository initialized"
    else
        print_error "Failed to initialize Git repository"
        cd "$original_dir"
        return 1
    fi

    # Add all files
    print_info "Adding files to Git..."
    if git add . 2>/dev/null; then
        print_success "Files staged"
    else
        print_warning "Some files could not be added"
    fi

    # Generate and apply commit message
    local commit_msg=$(generate_commit_message "$project_name" "$archetypes" "$tools" "$preset")

    print_info "Creating initial commit..."
    if git commit -m "$commit_msg" 2>/dev/null; then
        print_success "Initial commit created"

        # Display commit info
        local commit_hash=$(git rev-parse --short HEAD 2>/dev/null)
        if [ -n "$commit_hash" ]; then
            print_info "Commit: $commit_hash"
        fi
    else
        print_error "Failed to create initial commit"
        cd "$original_dir"
        return 1
    fi

    # Return to original directory
    cd "$original_dir"
    return 0
}

# Check if Git is available
check_git_available() {
    if command -v git &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Get git version
get_git_version() {
    if command -v git &> /dev/null; then
        git --version 2>/dev/null | head -n1
    else
        echo "Git not installed"
    fi
}

# ==============================================================================
# Export functions for use in other scripts
# ==============================================================================

export -f get_template_version
export -f list_archetypes_with_versions
export -f list_services_from_archetypes
export -f list_tools_used
export -f generate_commit_message
export -f initialize_git_repository
export -f check_git_available
export -f get_git_version
