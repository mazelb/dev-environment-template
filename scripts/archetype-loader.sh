#!/bin/bash

###############################################################################
# Archetype Loader
# Loads and validates archetype metadata
###############################################################################

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Source common functions if available
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Define print functions if not already defined
if ! command -v print_header &> /dev/null; then
    print_header() {
        echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║${NC}   ${GREEN}$1${NC}                       "
        echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    }
fi

if ! command -v print_success &> /dev/null; then
    print_success() {
        echo -e "${GREEN}✓${NC} $1"
    }
fi

if ! command -v print_error &> /dev/null; then
    print_error() {
        echo -e "${RED}✗${NC} $1"
    }
fi

if ! command -v print_info &> /dev/null; then
    print_info() {
        echo -e "${CYAN}ℹ${NC} $1"
    }
fi

if ! command -v print_warning &> /dev/null; then
    print_warning() {
        echo -e "${YELLOW}⚠${NC} $1"
    }
fi

# Load archetype metadata
load_archetype() {
    local archetype_name=$1
    local archetype_path="archetypes/$archetype_name"
    local metadata_file="$archetype_path/__archetype__.json"

    if [ ! -f "$metadata_file" ]; then
        print_error "Archetype not found: $archetype_name"
        print_info "Available archetypes:"
        ls -1 archetypes/ | grep -v README.md
        exit 1
    fi

    # Validate JSON
    if ! jq empty "$metadata_file" 2>/dev/null; then
        print_error "Invalid JSON in $metadata_file"
        exit 1
    fi

    print_success "Loaded archetype: $archetype_name"
    echo "$metadata_file"
}

# Get archetype metadata field
get_metadata_field() {
    local metadata_file=$1
    local field=$2

    jq -r "$field" "$metadata_file" 2>/dev/null || echo "null"
}

# Validate archetype compatibility
check_compatibility() {
    local base_archetype=$1
    local feature_archetype=$2

    local base_metadata=$(load_archetype "$base_archetype")
    local feature_metadata=$(load_archetype "$feature_archetype")

    # Check if feature is compatible with base
    local compatible_features=$(get_metadata_field "$base_metadata" ".composition.compatible_features[]")
    local incompatible=$(get_metadata_field "$base_metadata" ".composition.incompatible_with[]")

    # Check incompatible list
    if echo "$incompatible" | grep -q "^$feature_archetype$"; then
        print_error "❌ $feature_archetype is incompatible with $base_archetype"
        return 1
    fi

    # Check compatible list (* means all)
    if echo "$compatible_features" | grep -q "^\*$"; then
        print_success "✓ $feature_archetype is compatible with $base_archetype"
        return 0
    fi

    if echo "$compatible_features" | grep -q "^$feature_archetype$"; then
        print_success "✓ $feature_archetype is compatible with $base_archetype"
        return 0
    fi

    print_warning "⚠ $feature_archetype compatibility with $base_archetype is unknown"
    return 0
}

# List all archetypes
list_archetypes() {
    print_header "Available Archetypes"
    echo ""

    echo -e "${BLUE}BASE ARCHETYPES${NC} (choose one):"
    for arch_dir in archetypes/*/; do
        [ -d "$arch_dir" ] || continue
        arch_name=$(basename "$arch_dir")
        metadata_file="$arch_dir/__archetype__.json"

        if [ -f "$metadata_file" ]; then
            arch_type=$(jq -r '.metadata.archetype_type' "$metadata_file" 2>/dev/null)
            if [ "$arch_type" == "base" ]; then
                display_name=$(jq -r '.metadata.display_name' "$metadata_file" 2>/dev/null)
                description=$(jq -r '.metadata.description' "$metadata_file" 2>/dev/null)
                echo -e "  ${GREEN}$arch_name${NC}"
                echo -e "    $description"
            fi
        fi
    done

    echo ""
    echo -e "${BLUE}FEATURE ARCHETYPES${NC} (add to base):"
    for arch_dir in archetypes/*/; do
        [ -d "$arch_dir" ] || continue
        arch_name=$(basename "$arch_dir")
        metadata_file="$arch_dir/__archetype__.json"

        if [ -f "$metadata_file" ]; then
            arch_type=$(jq -r '.metadata.archetype_type' "$metadata_file" 2>/dev/null)
            if [ "$arch_type" == "feature" ]; then
                display_name=$(jq -r '.metadata.display_name' "$metadata_file" 2>/dev/null)
                description=$(jq -r '.metadata.description' "$metadata_file" 2>/dev/null)
                echo -e "  ${CYAN}$arch_name${NC}"
                echo -e "    $description"
            fi
        fi
    done

    echo ""
    echo -e "${BLUE}COMPOSITE ARCHETYPES${NC} (pre-configured combinations):"
    for arch_dir in archetypes/*/; do
        [ -d "$arch_dir" ] || continue
        arch_name=$(basename "$arch_dir")
        metadata_file="$arch_dir/__archetype__.json"

        if [ -f "$metadata_file" ]; then
            arch_type=$(jq -r '.metadata.archetype_type' "$metadata_file" 2>/dev/null)
            if [ "$arch_type" == "composite" ]; then
                display_name=$(jq -r '.metadata.display_name' "$metadata_file" 2>/dev/null)
                description=$(jq -r '.metadata.description' "$metadata_file" 2>/dev/null)
                echo -e "  ${YELLOW}$arch_name${NC}"
                echo -e "    $description"
            fi
        fi
    done

    echo ""
    echo -e "${BLUE}Usage:${NC}"
    echo "  ./create-project.sh --name myapp --archetype <base>"
    echo "  ./create-project.sh --name myapp --archetype <base> --add-features <feature1>,<feature2>"
    echo "  ./create-project.sh --name myapp --archetype <composite>"
}

# Validate archetype structure
validate_archetype() {
    local archetype_name=$1
    local metadata_file=$(load_archetype "$archetype_name")

    print_info "Validating archetype: $archetype_name"

    # Check required fields
    local required_fields=(
        ".metadata.name"
        ".metadata.display_name"
        ".metadata.archetype_type"
        ".composition.role"
        ".dependencies"
        ".conflicts"
    )

    local valid=true
    for field in "${required_fields[@]}"; do
        local value=$(get_metadata_field "$metadata_file" "$field")
        if [ "$value" == "null" ]; then
            print_error "Missing required field: $field"
            valid=false
        fi
    done

    if [ "$valid" == "true" ]; then
        print_success "✓ Archetype validation passed"
        return 0
    else
        print_error "✗ Archetype validation failed"
        return 1
    fi
}

# Main execution (only when script is run directly, not sourced)
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    if [ "$1" == "--list" ]; then
        list_archetypes
    elif [ "$1" == "--validate" ] && [ -n "$2" ]; then
        validate_archetype "$2"
    elif [ "$1" == "--check-compatibility" ] && [ -n "$2" ] && [ -n "$3" ]; then
        check_compatibility "$2" "$3"
    else
        echo "Usage:"
        echo "  $0 --list                                  # List all archetypes"
        echo "  $0 --validate <archetype>                  # Validate archetype"
        echo "  $0 --check-compatibility <base> <feature>  # Check compatibility"
    fi
fi
