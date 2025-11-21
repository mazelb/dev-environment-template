#!/bin/bash

###############################################################################
# Conflict Resolver for Multi-Archetype Composition
# Detects and resolves conflicts between multiple archetypes
# Supports port conflicts, service name conflicts, and dependency conflicts
###############################################################################

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_error() { echo -e "${RED}✗${NC} $1" >&2; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1" >&2; }
print_info() { echo -e "${CYAN}ℹ${NC} $1"; }

# Check if jq is available (optional but helpful)
JQ_AVAILABLE=false
if command -v jq &> /dev/null; then
    JQ_AVAILABLE=true
fi

# Check if yq is available (optional but helpful for YAML)
YQ_AVAILABLE=false
if command -v yq &> /dev/null; then
    YQ_AVAILABLE=true
fi

# Detect port conflicts
# Supports both metadata-based and file-based detection
detect_port_conflicts() {
    local base_metadata=$1
    shift
    local feature_metadatas=("$@")

    local -A port_map  # port -> archetype name
    local conflicts=()
    local base_name=""

    # Get base archetype name
    if [ "$JQ_AVAILABLE" = true ] && [ -f "$base_metadata" ]; then
        base_name=$(jq -r '.metadata.name // "base"' "$base_metadata" 2>/dev/null || echo "base")
    else
        base_name=$(basename "$(dirname "$base_metadata")" 2>/dev/null || echo "base")
    fi

    # Check base archetype ports
    if [ "$JQ_AVAILABLE" = true ] && [ -f "$base_metadata" ]; then
        local base_ports=$(jq -r '.conflicts.declare.ports[]? // .services[]?.ports[]? // empty' "$base_metadata" 2>/dev/null)

        while IFS= read -r port; do
            [ -z "$port" ] && continue
            port_map[$port]="$base_name"
        done <<< "$base_ports"
    fi

    # Check feature archetype ports
    for feature_metadata in "${feature_metadatas[@]}"; do
        [ ! -f "$feature_metadata" ] && continue

        local feature_name=""
        if [ "$JQ_AVAILABLE" = true ]; then
            feature_name=$(jq -r '.metadata.name // "unknown"' "$feature_metadata" 2>/dev/null || echo "unknown")
        else
            feature_name=$(basename "$(dirname "$feature_metadata")" 2>/dev/null || echo "unknown")
        fi

        local feature_ports=""
        if [ "$JQ_AVAILABLE" = true ]; then
            feature_ports=$(jq -r '.conflicts.declare.ports[]? // .services[]?.ports[]? // empty' "$feature_metadata" 2>/dev/null)
        fi

        while IFS= read -r port; do
            [ -z "$port" ] && continue

            if [ -n "${port_map[$port]}" ]; then
                conflicts+=("$port:${port_map[$port]}:$feature_name")
                print_warning "Port conflict: $port used by ${port_map[$port]} and $feature_name"
            else
                port_map[$port]="$feature_name"
            fi
        done <<< "$feature_ports"
    done

    if [ ${#conflicts[@]} -gt 0 ]; then
        return 1
    fi

    return 0
}

# Resolve port conflicts by applying offsets
# Enhanced to support both yq and fallback methods
resolve_port_conflicts() {
    local compose_file=$1
    local offset=${2:-100}

    if [ ! -f "$compose_file" ]; then
        print_error "Docker compose file not found: $compose_file"
        return 1
    fi

    print_info "Applying port offset +$offset to $compose_file"

    local temp_file="${compose_file}.tmp.$$"

    if [ "$YQ_AVAILABLE" = true ]; then
        # Use yq for precise YAML manipulation
        # Apply offset to external ports only (host:container format)
        yq eval '(.services.[].ports[] | select(type == "!!str") | capture("^(?P<host>[0-9]+):(?P<container>[0-9]+)$")) |= (.host = (.host | tonumber + '"$offset"' | tostring))' "$compose_file" > "$temp_file"

        if [ $? -eq 0 ] && [ -s "$temp_file" ]; then
            mv "$temp_file" "$compose_file"
            print_success "Port offset applied successfully using yq"
            return 0
        else
            print_warning "yq processing failed, trying fallback method"
            rm -f "$temp_file"
        fi
    fi

    # Fallback: sed-based port offset
    print_info "Using fallback sed method for port offset"

    # Process line by line to handle port mappings
    while IFS= read -r line; do
        # Match port mappings like "8000:8000" or - "8000:8000" or - '8000:8000'
        if [[ $line =~ ^([[:space:]]*-[[:space:]]+[\"\']{0,1})([0-9]+):([0-9]+)([\"\']{0,1}.*) ]]; then
            local prefix="${BASH_REMATCH[1]}"
            local host_port="${BASH_REMATCH[2]}"
            local container_port="${BASH_REMATCH[3]}"
            local suffix="${BASH_REMATCH[4]}"

            local new_host_port=$((host_port + offset))
            echo "${prefix}${new_host_port}:${container_port}${suffix}"
        else
            echo "$line"
        fi
    done < "$compose_file" > "$temp_file"

    if [ -s "$temp_file" ]; then
        mv "$temp_file" "$compose_file"
        print_success "Port offset applied successfully using sed"
        return 0
    else
        rm -f "$temp_file"
        print_error "Failed to apply port offset"
        return 1
    fi
}

# Detect service name collisions
# Enhanced to support both metadata and docker-compose file scanning
detect_service_name_conflicts() {
    local base_metadata=$1
    shift
    local feature_metadatas=("$@")

    local -A service_map  # service_name -> archetype name
    local conflicts=()
    local base_name=""

    # Get base archetype name
    if [ "$JQ_AVAILABLE" = true ] && [ -f "$base_metadata" ]; then
        base_name=$(jq -r '.metadata.name // "base"' "$base_metadata" 2>/dev/null || echo "base")
    else
        base_name=$(basename "$(dirname "$base_metadata")" 2>/dev/null || echo "base")
    fi

    # Check base archetype services
    if [ "$JQ_AVAILABLE" = true ] && [ -f "$base_metadata" ]; then
        local base_services=$(jq -r '.conflicts.declare.services[]? // .services[].name? // empty' "$base_metadata" 2>/dev/null)

        while IFS= read -r service; do
            [ -z "$service" ] && continue
            service_map[$service]="$base_name"
        done <<< "$base_services"
    fi

    # Check feature archetype services
    for feature_metadata in "${feature_metadatas[@]}"; do
        [ ! -f "$feature_metadata" ] && continue

        local feature_name=""
        if [ "$JQ_AVAILABLE" = true ]; then
            feature_name=$(jq -r '.metadata.name // "unknown"' "$feature_metadata" 2>/dev/null || echo "unknown")
        else
            feature_name=$(basename "$(dirname "$feature_metadata")" 2>/dev/null || echo "unknown")
        fi

        local feature_services=""
        if [ "$JQ_AVAILABLE" = true ]; then
            feature_services=$(jq -r '.conflicts.declare.services[]? // .services[].name? // empty' "$feature_metadata" 2>/dev/null)
        fi

        while IFS= read -r service; do
            [ -z "$service" ] && continue

            if [ -n "${service_map[$service]}" ]; then
                conflicts+=("$service:${service_map[$service]}:$feature_name")
                print_warning "Service name conflict: '$service' defined in ${service_map[$service]} and $feature_name"
            else
                service_map[$service]="$feature_name"
            fi
        done <<< "$feature_services"
    done

    if [ ${#conflicts[@]} -gt 0 ]; then
        return 1
    fi

    return 0
}

# Resolve service name conflicts with prefixing
# Enhanced to update all service references
resolve_service_name_conflicts() {
    local compose_file=$1
    local prefix=$2

    if [ ! -f "$compose_file" ]; then
        print_error "Docker compose file not found: $compose_file"
        return 1
    fi

    if [ -z "$prefix" ]; then
        print_error "Prefix is required"
        return 1
    fi

    # Remove trailing underscore if present (we'll add it)
    prefix="${prefix%_}"

    print_info "Applying service prefix '${prefix}_' to $compose_file"

    local temp_file="${compose_file}.tmp.$$"

    if [ "$YQ_AVAILABLE" = true ]; then
        # Use yq for precise YAML manipulation
        # Get all service names first
        local services=$(yq eval '.services | keys | .[]' "$compose_file" 2>/dev/null)

        if [ -z "$services" ]; then
            print_warning "No services found in $compose_file"
            return 1
        fi

        cp "$compose_file" "$temp_file"

        # Create mapping of old -> new names
        declare -A name_mapping
        while IFS= read -r service; do
            [ -z "$service" ] && continue
            name_mapping[$service]="${prefix}_${service}"
        done <<< "$services"

        # Rename services
        for old_name in "${!name_mapping[@]}"; do
            local new_name="${name_mapping[$old_name]}"
            yq eval ".services.\"${new_name}\" = .services.\"${old_name}\" | del(.services.\"${old_name}\")" -i "$temp_file"
            print_info "  Renamed: $old_name -> $new_name"
        done

        # Update depends_on references
        for old_name in "${!name_mapping[@]}"; do
            local new_name="${name_mapping[$old_name]}"
            yq eval "(.services.[].depends_on[] | select(. == \"${old_name}\")) = \"${new_name}\"" -i "$temp_file"
        done

        # Update environment variable references (best effort)
        for old_name in "${!name_mapping[@]}"; do
            local new_name="${name_mapping[$old_name]}"
            yq eval "(.services.[].environment[] | select(. == \"*${old_name}*\")) |= sub(\"${old_name}\", \"${new_name}\")" -i "$temp_file" 2>/dev/null || true
        done

        mv "$temp_file" "$compose_file"
        print_success "Service prefix applied successfully using yq"
        return 0
    else
        # Fallback: sed-based renaming (limited capability)
        print_warning "yq not available, using fallback sed method"

        # Extract service names (simple grep approach)
        local services=$(grep -oP '^\s{2}[a-zA-Z0-9_-]+(?=:)' "$compose_file" | grep -v "^  version$\|^  services$\|^  volumes$\|^  networks$" | sed 's/^  //' || true)

        if [ -z "$services" ]; then
            print_warning "No services found in $compose_file"
            return 1
        fi

        cp "$compose_file" "$temp_file"

        # Rename each service
        while IFS= read -r service; do
            [ -z "$service" ] && continue

            local new_name="${prefix}_${service}"

            # Replace service definition
            sed -i "s/^  ${service}:/  ${new_name}:/" "$temp_file"

            # Replace in depends_on
            sed -i "s/- ${service}$/- ${new_name}/" "$temp_file"

            # Replace in environment variables (best effort)
            sed -i "s/${service}/${new_name}/g" "$temp_file"

            print_info "  Renamed: $service -> $new_name"
        done <<< "$services"

        mv "$temp_file" "$compose_file"
        print_success "Service prefix applied using sed"
        return 0
    fi
}

# Detect Python dependency conflicts
# Enhanced with better version parsing and conflict detection
detect_dependency_conflicts() {
    local base_metadata=$1
    shift
    local feature_metadatas=("$@")

    local -A python_deps  # package -> version:archetype
    local conflicts=()
    local base_name=""

    # Get base archetype name
    if [ "$JQ_AVAILABLE" = true ] && [ -f "$base_metadata" ]; then
        base_name=$(jq -r '.metadata.name // "base"' "$base_metadata" 2>/dev/null || echo "base")
    else
        base_name=$(basename "$(dirname "$base_metadata")" 2>/dev/null || echo "base")
    fi

    # Extract dependencies from base
    if [ "$JQ_AVAILABLE" = true ] && [ -f "$base_metadata" ]; then
        local base_deps=$(jq -r '.dependencies.python // {} | to_entries[] | "\(.key)=\(.value)"' "$base_metadata" 2>/dev/null)

        while IFS= read -r dep; do
            [ -z "$dep" ] && continue
            local pkg_name=$(echo "$dep" | cut -d'=' -f1)
            local pkg_version=$(echo "$dep" | cut -d'=' -f2-)
            python_deps[$pkg_name]="$pkg_version:$base_name"
        done <<< "$base_deps"
    fi

    # Check feature archetypes
    for feature_metadata in "${feature_metadatas[@]}"; do
        [ ! -f "$feature_metadata" ] && continue

        local feature_name=""
        if [ "$JQ_AVAILABLE" = true ]; then
            feature_name=$(jq -r '.metadata.name // "unknown"' "$feature_metadata" 2>/dev/null || echo "unknown")
        else
            feature_name=$(basename "$(dirname "$feature_metadata")" 2>/dev/null || echo "unknown")
        fi

        if [ "$JQ_AVAILABLE" = true ]; then
            local feature_deps=$(jq -r '.dependencies.python // {} | to_entries[] | "\(.key)=\(.value)"' "$feature_metadata" 2>/dev/null)

            while IFS= read -r dep; do
                [ -z "$dep" ] && continue
                local pkg_name=$(echo "$dep" | cut -d'=' -f1)
                local pkg_version=$(echo "$dep" | cut -d'=' -f2-)

                # Check if package exists with different version
                if [ -n "${python_deps[$pkg_name]}" ]; then
                    local existing="${python_deps[$pkg_name]}"
                    local existing_version=$(echo "$existing" | cut -d':' -f1)
                    local existing_archetype=$(echo "$existing" | cut -d':' -f2-)

                    if [ "$existing_version" != "$pkg_version" ]; then
                        conflicts+=("$pkg_name:$existing_archetype:$existing_version:$feature_name:$pkg_version")
                        print_warning "Dependency conflict: $pkg_name ($existing_version in $existing_archetype vs $pkg_version in $feature_name)"
                    fi
                else
                    python_deps[$pkg_name]="$pkg_version:$feature_name"
                fi
            done <<< "$feature_deps"
        fi
    done

    if [ ${#conflicts[@]} -gt 0 ]; then
        return 1
    fi

    return 0
}

# Resolve dependency conflicts
# Enhanced to create a merged requirements file with conflict resolution
resolve_dependency_conflicts() {
    local output_file=$1
    shift
    local metadata_files=("$@")

    print_info "Resolving dependency conflicts..."

    if [ ! "$JQ_AVAILABLE" = true ]; then
        print_error "jq is required for dependency resolution"
        return 1
    fi

    # Create temporary requirements file
    local temp_req=$(mktemp)
    local -A all_deps  # package -> highest version seen

    # Collect all dependencies
    for metadata in "${metadata_files[@]}"; do
        [ ! -f "$metadata" ] && continue

        local deps=$(jq -r '.dependencies.python // {} | to_entries[] | "\(.key)\(.value)"' "$metadata" 2>/dev/null)

        while IFS= read -r dep_line; do
            [ -z "$dep_line" ] && continue

            # Extract package name and version constraint
            local pkg_name=$(echo "$dep_line" | sed 's/[<>=!].*//' | tr -d ' ')
            local version_spec=$(echo "$dep_line" | grep -oP '[<>=!]+.*' || echo "")

            # Simple strategy: keep the most restrictive version
            # In production, use pip-tools or similar
            if [ -n "${all_deps[$pkg_name]}" ]; then
                # Package already exists, keep the existing version (first wins)
                # TODO: Implement smarter version resolution
                print_info "  Using existing version for $pkg_name: ${all_deps[$pkg_name]}"
            else
                all_deps[$pkg_name]="$version_spec"
                echo "${pkg_name}${version_spec}" >> "$temp_req"
            fi
        done <<< "$deps"
    done

    # Try to use pip-compile for proper resolution
    if command -v pip-compile &> /dev/null; then
        print_info "Using pip-compile for dependency resolution"
        pip-compile "$temp_req" -o "$output_file" --quiet 2>/dev/null

        if [ $? -eq 0 ]; then
            rm "$temp_req"
            print_success "Dependencies resolved with pip-compile"
            return 0
        else
            print_warning "pip-compile failed, using simple deduplication"
        fi
    fi

    # Fallback: just sort and deduplicate
    sort -u "$temp_req" > "$output_file"
    rm "$temp_req"
    print_success "Dependencies merged (without full resolution)"
    print_info "Consider reviewing $output_file for version conflicts"
    return 0
}

###############################################################################
# Comprehensive Conflict Detection
###############################################################################

# Detect all types of conflicts between archetypes
# Usage: detect_all_conflicts base_metadata feature_metadata1 [feature_metadata2 ...]
# Returns: 0 if conflicts found, 1 if no conflicts
detect_all_conflicts() {
    local base_metadata=$1
    shift
    local feature_metadatas=("$@")

    print_info "═══════════════════════════════════════════════════"
    print_info "Running comprehensive conflict detection"
    print_info "═══════════════════════════════════════════════════"
    echo ""

    local has_conflicts=false

    # Detect port conflicts
    print_info "Checking for port conflicts..."
    if ! detect_port_conflicts "$base_metadata" "${feature_metadatas[@]}"; then
        has_conflicts=true
    else
        print_success "No port conflicts detected"
    fi
    echo ""

    # Detect service name conflicts
    print_info "Checking for service name conflicts..."
    if ! detect_service_name_conflicts "$base_metadata" "${feature_metadatas[@]}"; then
        has_conflicts=true
    else
        print_success "No service name conflicts detected"
    fi
    echo ""

    # Detect dependency conflicts
    print_info "Checking for dependency conflicts..."
    if ! detect_dependency_conflicts "$base_metadata" "${feature_metadatas[@]}"; then
        has_conflicts=true
    else
        print_success "No dependency conflicts detected"
    fi
    echo ""

    # Summary
    print_info "═══════════════════════════════════════════════════"
    if [ "$has_conflicts" = true ]; then
        print_warning "CONFLICTS DETECTED"
        print_info "Use resolve functions to fix conflicts:"
        print_info "  - resolve_port_conflicts <compose_file> <offset>"
        print_info "  - resolve_service_name_conflicts <compose_file> <prefix>"
        print_info "  - resolve_dependency_conflicts <output_file> <metadata_files...>"
        return 0  # Conflicts found
    else
        print_success "NO CONFLICTS DETECTED"
        print_success "Archetypes are compatible!"
        return 1  # No conflicts
    fi
}

# Generate conflict report
# Enhanced with better formatting and actionable recommendations
generate_conflict_report() {
    local base_metadata=$1
    shift
    local feature_metadatas=("$@")

    echo ""
    print_info "═══════════════════════════════════════════════════"
    print_info "Archetype Composition Conflict Report"
    print_info "═══════════════════════════════════════════════════"
    echo ""

    # Base archetype
    local base_name="unknown"
    if [ "$JQ_AVAILABLE" = true ] && [ -f "$base_metadata" ]; then
        base_name=$(jq -r '.metadata.name // "unknown"' "$base_metadata" 2>/dev/null || echo "unknown")
    fi
    echo -e "${BLUE}Base Archetype:${NC} $base_name"
    echo "  Location: $base_metadata"

    # Feature archetypes
    echo ""
    echo -e "${BLUE}Feature Archetypes:${NC}"
    for metadata in "${feature_metadatas[@]}"; do
        local name="unknown"
        if [ "$JQ_AVAILABLE" = true ] && [ -f "$metadata" ]; then
            name=$(jq -r '.metadata.name // "unknown"' "$metadata" 2>/dev/null || echo "unknown")
        fi
        echo "  - $name ($metadata)"
    done

    echo ""
    echo -e "${BLUE}Conflict Analysis:${NC}"
    echo ""

    local has_port_conflicts=false
    local has_service_conflicts=false
    local has_dep_conflicts=false

    # Check port conflicts
    if ! detect_port_conflicts "$base_metadata" "${feature_metadatas[@]}" 2>/dev/null; then
        has_port_conflicts=true
        echo -e "  ${YELLOW}⚠${NC} Port conflicts detected"
    else
        echo -e "  ${GREEN}✓${NC} No port conflicts"
    fi

    # Check service name conflicts
    if ! detect_service_name_conflicts "$base_metadata" "${feature_metadatas[@]}" 2>/dev/null; then
        has_service_conflicts=true
        echo -e "  ${YELLOW}⚠${NC} Service name conflicts detected"
    else
        echo -e "  ${GREEN}✓${NC} No service name conflicts"
    fi

    # Check dependency conflicts
    if ! detect_dependency_conflicts "$base_metadata" "${feature_metadatas[@]}" 2>/dev/null; then
        has_dep_conflicts=true
        echo -e "  ${YELLOW}⚠${NC} Dependency conflicts detected"
    else
        echo -e "  ${GREEN}✓${NC} No dependency conflicts"
    fi

    echo ""
    echo -e "${BLUE}Recommended Resolution Strategy:${NC}"
    echo ""

    if [ "$has_port_conflicts" = true ]; then
        echo "  1. Apply port offset to feature archetypes:"
        echo "     resolve_port_conflicts <compose_file> 100"
    fi

    if [ "$has_service_conflicts" = true ]; then
        echo "  2. Apply service name prefix to avoid collisions:"
        echo "     resolve_service_name_conflicts <compose_file> '<prefix>'"
    fi

    if [ "$has_dep_conflicts" = true ]; then
        echo "  3. Merge and resolve dependencies:"
        echo "     resolve_dependency_conflicts requirements.txt <metadata_files...>"
    fi

    if [ "$has_port_conflicts" = false ] && [ "$has_service_conflicts" = false ] && [ "$has_dep_conflicts" = false ]; then
        echo "  No conflicts detected - archetypes can be composed directly!"
    fi

    echo ""
    print_info "═══════════════════════════════════════════════════"
    echo ""
}

###############################################################################
# Main Execution
###############################################################################

# Main execution - only run if script is executed directly (not sourced)
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    # Show help if no arguments
    if [ $# -eq 0 ]; then
        echo "Conflict Resolver for Multi-Archetype Composition"
        echo ""
        echo "Usage:"
        echo "  $0 detect-all <base_metadata> <feature_metadata> [...]"
        echo "  $0 detect-ports <base_metadata> <feature_metadata> [...]"
        echo "  $0 detect-services <base_metadata> <feature_metadata> [...]"
        echo "  $0 detect-deps <base_metadata> <feature_metadata> [...]"
        echo "  $0 report <base_metadata> <feature_metadata> [...]"
        echo "  $0 resolve-ports <compose_file> <offset>"
        echo "  $0 resolve-services <compose_file> <prefix>"
        echo "  $0 resolve-deps <output_file> <metadata_file> [...]"
        echo ""
        echo "Examples:"
        echo "  # Detect all conflicts"
        echo "  $0 detect-all archetypes/base/__archetype__.json archetypes/rag-project/__archetype__.json"
        echo ""
        echo "  # Generate conflict report"
        echo "  $0 report archetypes/base/__archetype__.json archetypes/rag-project/__archetype__.json"
        echo ""
        echo "  # Resolve port conflicts (add offset of 100)"
        echo "  $0 resolve-ports docker-compose.yml 100"
        echo ""
        echo "  # Resolve service name conflicts (add prefix)"
        echo "  $0 resolve-services docker-compose.yml rag"
        echo ""
        echo "  # Resolve dependency conflicts"
        echo "  $0 resolve-deps requirements.txt archetypes/*/__archetype__.json"
        echo ""
        exit 0
    fi

    command=$1
    shift

    case "$command" in
        detect-all)
            if [ $# -lt 2 ]; then
                print_error "Usage: $0 detect-all <base_metadata> <feature_metadata> [...]"
                exit 1
            fi
            detect_all_conflicts "$@"
            ;;
        detect-ports)
            if [ $# -lt 2 ]; then
                print_error "Usage: $0 detect-ports <base_metadata> <feature_metadata> [...]"
                exit 1
            fi
            detect_port_conflicts "$@"
            ;;
        detect-services)
            if [ $# -lt 2 ]; then
                print_error "Usage: $0 detect-services <base_metadata> <feature_metadata> [...]"
                exit 1
            fi
            detect_service_name_conflicts "$@"
            ;;
        detect-deps)
            if [ $# -lt 2 ]; then
                print_error "Usage: $0 detect-deps <base_metadata> <feature_metadata> [...]"
                exit 1
            fi
            detect_dependency_conflicts "$@"
            ;;
        report)
            if [ $# -lt 2 ]; then
                print_error "Usage: $0 report <base_metadata> <feature_metadata> [...]"
                exit 1
            fi
            generate_conflict_report "$@"
            ;;
        resolve-ports)
            if [ $# -lt 2 ]; then
                print_error "Usage: $0 resolve-ports <compose_file> <offset>"
                exit 1
            fi
            resolve_port_conflicts "$1" "$2"
            ;;
        resolve-services)
            if [ $# -lt 2 ]; then
                print_error "Usage: $0 resolve-services <compose_file> <prefix>"
                exit 1
            fi
            resolve_service_name_conflicts "$1" "$2"
            ;;
        resolve-deps)
            if [ $# -lt 2 ]; then
                print_error "Usage: $0 resolve-deps <output_file> <metadata_file> [...]"
                exit 1
            fi
            resolve_dependency_conflicts "$@"
            ;;
        --detect)
            # Legacy compatibility
            if [ $# -lt 2 ]; then
                print_error "Usage: $0 --detect <base_metadata> <feature_metadata> [...]"
                exit 1
            fi
            generate_conflict_report "$@"
            ;;
        --resolve-ports)
            # Legacy compatibility
            if [ $# -lt 2 ]; then
                print_error "Usage: $0 --resolve-ports <compose_file> <offset>"
                exit 1
            fi
            resolve_port_conflicts "$1" "$2"
            ;;
        --resolve-services)
            # Legacy compatibility
            if [ $# -lt 2 ]; then
                print_error "Usage: $0 --resolve-services <compose_file> <prefix>"
                exit 1
            fi
            resolve_service_name_conflicts "$1" "$2"
            ;;
        --resolve-deps)
            # Legacy compatibility
            if [ $# -lt 2 ]; then
                print_error "Usage: $0 --resolve-deps <output_file> <metadata_file> [...]"
                exit 1
            fi
            resolve_dependency_conflicts "$@"
            ;;
        *)
            print_error "Unknown command: $command"
            print_info "Run '$0' without arguments to see usage"
            exit 1
            ;;
    esac
fi
