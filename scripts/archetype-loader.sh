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
# Enhanced with detailed compatibility reporting
check_compatibility() {
    local base_archetype=$1
    local feature_archetype=$2

    print_header "Compatibility Check"
    echo ""
    print_info "Checking if '$feature_archetype' is compatible with '$base_archetype'..."
    echo ""

    local base_metadata=$(load_archetype "$base_archetype" 2>/dev/null)
    local feature_metadata=$(load_archetype "$feature_archetype" 2>/dev/null)

    if [ -z "$base_metadata" ] || [ ! -f "$base_metadata" ]; then
        print_error "Base archetype not found: $base_archetype"
        return 1
    fi

    if [ -z "$feature_metadata" ] || [ ! -f "$feature_metadata" ]; then
        print_error "Feature archetype not found: $feature_archetype"
        return 1
    fi

    # Check if jq is available
    if ! command -v jq &> /dev/null; then
        print_warning "jq not found - performing basic compatibility check"
        print_info "Install jq for detailed compatibility analysis"
        return 0
    fi

    # Get archetype types
    local base_type=$(jq -r '.metadata.archetype_type // .metadata.role // "unknown"' "$base_metadata" 2>/dev/null)
    local feature_type=$(jq -r '.metadata.archetype_type // .metadata.role // "unknown"' "$feature_metadata" 2>/dev/null)

    echo -e "${BLUE}Archetype Information:${NC}"
    echo "  Base: $base_archetype (type: $base_type)"
    echo "  Feature: $feature_archetype (type: $feature_type)"
    echo ""

    # Check incompatible list
    local incompatible=$(get_metadata_field "$base_metadata" ".composition.incompatible_with[]")
    if echo "$incompatible" | grep -q "^$feature_archetype$"; then
        print_error "❌ $feature_archetype is explicitly INCOMPATIBLE with $base_archetype"
        return 1
    fi

    # Check compatibility declarations
    local compatible_features=$(get_metadata_field "$base_metadata" ".composition.compatible_features[]")
    local compatible_bases=$(get_metadata_field "$feature_metadata" ".composition.compatible_bases[]")

    # Check if base declares this feature as compatible
    local base_declares_compatible=false
    if echo "$compatible_features" | grep -q "^\*$"; then
        base_declares_compatible=true
        print_success "✓ Base accepts all features (*)"
    elif echo "$compatible_features" | grep -q "^$feature_archetype$"; then
        base_declares_compatible=true
        print_success "✓ Base explicitly lists $feature_archetype as compatible"
    fi

    # Check if feature declares this base as compatible
    local feature_declares_compatible=false
    if echo "$compatible_bases" | grep -q "^\*$"; then
        feature_declares_compatible=true
        print_success "✓ Feature works with all bases (*)"
    elif echo "$compatible_bases" | grep -q "^$base_archetype$"; then
        feature_declares_compatible=true
        print_success "✓ Feature explicitly lists $base_archetype as compatible"
    fi

    echo ""

    # Run conflict detection if conflict-resolver is available
    if command -v detect_all_conflicts &> /dev/null; then
        print_info "Running conflict analysis..."
        echo ""

        if detect_all_conflicts "$base_metadata" "$feature_metadata" 2>&1 | grep -q "NO CONFLICTS"; then
            print_success "✓ No conflicts detected"
        else
            print_warning "⚠ Conflicts detected (can be resolved automatically)"
        fi
    fi

    echo ""
    echo -e "${BLUE}Compatibility Summary:${NC}"

    if [ "$base_declares_compatible" = true ] && [ "$feature_declares_compatible" = true ]; then
        print_success "✓ FULLY COMPATIBLE"
        print_info "Both archetypes explicitly declare compatibility"
        return 0
    elif [ "$base_declares_compatible" = true ] || [ "$feature_declares_compatible" = true ]; then
        print_success "✓ COMPATIBLE"
        print_info "At least one archetype declares compatibility"
        return 0
    else
        print_warning "⚠ COMPATIBILITY UNKNOWN"
        print_info "Archetypes don't explicitly declare compatibility"
        print_info "They may still work together, but testing is recommended"
        return 0
    fi
}

# List all archetypes
list_archetypes() {
    print_header "Available Archetypes"
    echo ""

    # Determine archetypes directory
    local archetypes_base="archetypes"
    if [ ! -d "$archetypes_base" ]; then
        # Try from script directory
        archetypes_base="$SCRIPT_DIR/../archetypes"
    fi

    if [ ! -d "$archetypes_base" ]; then
        print_error "Archetypes directory not found"
        return 1
    fi

    echo -e "${BLUE}BASE ARCHETYPES${NC} (choose one):"
    local found_base=false
    for arch_dir in "$archetypes_base"/*/; do
        [ -d "$arch_dir" ] || continue
        arch_name=$(basename "$arch_dir")

        # Skip special directories
        [[ "$arch_name" == __* ]] && continue

        metadata_file="$arch_dir/__archetype__.json"

        if [ -f "$metadata_file" ]; then
            arch_type=$(jq -r '.metadata.archetype_type // .type // "unknown"' "$metadata_file" 2>/dev/null)
            if [ "$arch_type" == "base" ]; then
                found_base=true
                display_name=$(jq -r '.metadata.display_name // .name' "$metadata_file" 2>/dev/null)
                description=$(jq -r '.metadata.description // "No description"' "$metadata_file" 2>/dev/null)
                version=$(jq -r '.metadata.version // .version // "unknown"' "$metadata_file" 2>/dev/null)
                echo -e "  ${GREEN}$arch_name${NC} (v$version)"
                echo -e "    $description"
                echo ""
            fi
        fi
    done

    if [ "$found_base" = false ]; then
        echo -e "  ${YELLOW}No base archetypes found${NC}"
    fi

    echo ""
    echo -e "${BLUE}FEATURE ARCHETYPES${NC} (add to base):"
    local found_feature=false
    for arch_dir in "$archetypes_base"/*/; do
        [ -d "$arch_dir" ] || continue
        arch_name=$(basename "$arch_dir")

        # Skip special directories
        [[ "$arch_name" == __* ]] && continue

        metadata_file="$arch_dir/__archetype__.json"

        if [ -f "$metadata_file" ]; then
            arch_type=$(jq -r '.metadata.archetype_type // .type // "unknown"' "$metadata_file" 2>/dev/null)
            if [ "$arch_type" == "feature" ]; then
                found_feature=true
                display_name=$(jq -r '.metadata.display_name // .name' "$metadata_file" 2>/dev/null)
                description=$(jq -r '.metadata.description // "No description"' "$metadata_file" 2>/dev/null)
                version=$(jq -r '.metadata.version // .version // "unknown"' "$metadata_file" 2>/dev/null)
                echo -e "  ${CYAN}$arch_name${NC} (v$version)"
                echo -e "    $description"
                echo ""
            fi
        fi
    done

    if [ "$found_feature" = false ]; then
        echo -e "  ${YELLOW}No feature archetypes found${NC}"
    fi

    echo ""
    echo -e "${BLUE}COMPOSITE ARCHETYPES${NC} (pre-configured combinations):"
    local found_composite=false
    for arch_dir in "$archetypes_base"/*/; do
        [ -d "$arch_dir" ] || continue
        arch_name=$(basename "$arch_dir")

        # Skip special directories
        [[ "$arch_name" == __* ]] && continue

        metadata_file="$arch_dir/__archetype__.json"

        if [ -f "$metadata_file" ]; then
            arch_type=$(jq -r '.metadata.archetype_type // .type // "unknown"' "$metadata_file" 2>/dev/null)
            if [ "$arch_type" == "composite" ]; then
                found_composite=true
                display_name=$(jq -r '.metadata.display_name // .name' "$metadata_file" 2>/dev/null)
                description=$(jq -r '.metadata.description // "No description"' "$metadata_file" 2>/dev/null)
                version=$(jq -r '.metadata.version // .version // "unknown"' "$metadata_file" 2>/dev/null)
                echo -e "  ${YELLOW}$arch_name${NC} (v$version)"
                echo -e "    $description"
                echo ""
            fi
        fi
    done

    if [ "$found_composite" = false ]; then
        echo -e "  ${YELLOW}No composite archetypes found${NC}"
    fi

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
