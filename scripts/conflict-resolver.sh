#!/bin/bash

###############################################################################
# Conflict Resolver
# Detects and resolves conflicts between archetypes
###############################################################################

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_error() { echo -e "${RED}✗${NC} $1"; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_info() { echo -e "${CYAN}ℹ${NC} $1"; }

# Detect port conflicts
detect_port_conflicts() {
    local base_metadata=$1
    shift
    local feature_metadatas=("$@")

    local base_ports=$(jq -r '.conflicts.declare.ports[]' "$base_metadata" 2>/dev/null)
    local conflicts=()

    for feature_metadata in "${feature_metadatas[@]}"; do
        local feature_name=$(jq -r '.metadata.name' "$feature_metadata")
        local feature_ports=$(jq -r '.conflicts.declare.ports[]' "$feature_metadata" 2>/dev/null)

        for port in $feature_ports; do
            if echo "$base_ports" | grep -q "^$port$"; then
                conflicts+=("$feature_name:$port")
            fi
        done
    done

    if [ ${#conflicts[@]} -gt 0 ]; then
        print_warning "Port conflicts detected:"
        for conflict in "${conflicts[@]}"; do
            echo "  - $conflict"
        done
        return 1
    fi

    return 0
}

# Resolve port conflicts by applying offsets
resolve_port_conflicts() {
    local compose_file=$1
    local offset=$2

    print_info "Applying port offset +$offset to $compose_file"

    # Use yq to modify ports (requires yq to be installed)
    if command -v yq &> /dev/null; then
        # Apply offset to external ports only
        yq eval '.services[].ports[] |=
            sub("^([0-9]+):", (([0-9]+) | tonumber + '$offset' | tostring) + ":")' \
            -i "$compose_file"
    else
        # Fallback: simple sed replacement (less reliable)
        print_warning "yq not found, using sed (less reliable)"

        # This is a simple example - real implementation would be more robust
        while IFS= read -r line; do
            if [[ $line =~ ^[[:space:]]*-[[:space:]]+\"?([0-9]+):([0-9]+)\"? ]]; then
                local external_port="${BASH_REMATCH[1]}"
                local internal_port="${BASH_REMATCH[2]}"
                local new_external=$((external_port + offset))
                sed -i "s/\"$external_port:$internal_port\"/\"$new_external:$internal_port\"/g" "$compose_file"
            fi
        done < "$compose_file"
    fi

    print_success "Port offset applied"
}

# Detect service name collisions
detect_service_name_conflicts() {
    local base_metadata=$1
    shift
    local feature_metadatas=("$@")

    local base_services=$(jq -r '.conflicts.declare.services[]' "$base_metadata" 2>/dev/null)
    local conflicts=()

    for feature_metadata in "${feature_metadatas[@]}"; do
        local feature_name=$(jq -r '.metadata.name' "$feature_metadata")
        local feature_services=$(jq -r '.conflicts.declare.services[]' "$feature_metadata" 2>/dev/null)

        for service in $feature_services; do
            if echo "$base_services" | grep -q "^$service$"; then
                conflicts+=("$feature_name:$service")
            fi
        done
    done

    if [ ${#conflicts[@]} -gt 0 ]; then
        print_warning "Service name conflicts detected:"
        for conflict in "${conflicts[@]}"; do
            echo "  - $conflict"
        done
        return 1
    fi

    return 0
}

# Resolve service name conflicts with prefixing
resolve_service_name_conflicts() {
    local compose_file=$1
    local prefix=$2

    print_info "Applying service prefix '$prefix' to $compose_file"

    # Rename services with prefix
    if command -v yq &> /dev/null; then
        # Get all service names
        local services=$(yq eval '.services | keys | .[]' "$compose_file")

        for service in $services; do
            local new_name="${prefix}_${service}"
            yq eval ".services[\"$new_name\"] = .services[\"$service\"] | del(.services[\"$service\"])" \
                -i "$compose_file"
        done

        # Update references in depends_on, environment, etc.
        for service in $services; do
            local new_name="${prefix}_${service}"
            # Update environment variable references
            yq eval ".services[].environment |= with_entries(
                .value |= sub(\"$service\", \"$new_name\")
            )" -i "$compose_file"
        done
    else
        print_warning "yq not found, skipping service renaming"
    fi

    print_success "Service prefix applied"
}

# Detect Python dependency conflicts
detect_dependency_conflicts() {
    local base_metadata=$1
    shift
    local feature_metadatas=("$@")

    local conflicts=()

    # Extract dependencies from base
    local base_deps=$(jq -r '.dependencies.python | to_entries[] | "\(.key)=\(.value)"' "$base_metadata" 2>/dev/null)

    for feature_metadata in "${feature_metadatas[@]}"; do
        local feature_name=$(jq -r '.metadata.name' "$feature_metadata")
        local feature_deps=$(jq -r '.dependencies.python | to_entries[] | "\(.key)=\(.value)"' "$feature_metadata" 2>/dev/null)

        # Check for conflicting versions
        while IFS= read -r dep; do
            local pkg_name=$(echo "$dep" | cut -d'=' -f1)
            local pkg_version=$(echo "$dep" | cut -d'=' -f2)

            # Check if base has same package with different version
            local base_version=$(echo "$base_deps" | grep "^$pkg_name=" | cut -d'=' -f2)

            if [ -n "$base_version" ] && [ "$base_version" != "$pkg_version" ]; then
                conflicts+=("$feature_name:$pkg_name ($base_version vs $pkg_version)")
            fi
        done <<< "$feature_deps"
    done

    if [ ${#conflicts[@]} -gt 0 ]; then
        print_warning "Dependency conflicts detected:"
        for conflict in "${conflicts[@]}"; do
            echo "  - $conflict"
        done
        return 1
    fi

    return 0
}

# Resolve dependency conflicts
resolve_dependency_conflicts() {
    local output_file=$1
    shift
    local metadata_files=("$@")

    print_info "Resolving dependency conflicts..."

    # Create temporary requirements file
    local temp_req=$(mktemp)

    # Collect all dependencies
    for metadata in "${metadata_files[@]}"; do
        jq -r '.dependencies.python | to_entries[] | "\(.key)\(.value)"' "$metadata" 2>/dev/null >> "$temp_req"
    done

    # Use pip-compile to resolve (if available)
    if command -v pip-compile &> /dev/null; then
        pip-compile "$temp_req" -o "$output_file" --quiet
        print_success "Dependencies resolved with pip-compile"
    else
        # Fallback: just concatenate and deduplicate
        sort -u "$temp_req" > "$output_file"
        print_warning "pip-compile not found, using simple deduplication"
    fi

    rm "$temp_req"
}

# Generate conflict report
generate_conflict_report() {
    local base_metadata=$1
    shift
    local feature_metadatas=("$@")

    echo ""
    print_info "Conflict Analysis Report"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Base archetype
    local base_name=$(jq -r '.metadata.name' "$base_metadata")
    echo -e "${BLUE}Base Archetype:${NC} $base_name"

    # Feature archetypes
    echo -e "${BLUE}Feature Archetypes:${NC}"
    for metadata in "${feature_metadatas[@]}"; do
        local name=$(jq -r '.metadata.name' "$metadata")
        echo "  - $name"
    done

    echo ""
    echo -e "${BLUE}Conflicts:${NC}"

    # Check port conflicts
    if detect_port_conflicts "$base_metadata" "${feature_metadatas[@]}"; then
        echo -e "  ${GREEN}✓${NC} No port conflicts"
    else
        echo -e "  ${YELLOW}⚠${NC} Port conflicts found (will apply offsets)"
    fi

    # Check service name conflicts
    if detect_service_name_conflicts "$base_metadata" "${feature_metadatas[@]}"; then
        echo -e "  ${GREEN}✓${NC} No service name conflicts"
    else
        echo -e "  ${YELLOW}⚠${NC} Service name conflicts found (will apply prefixes)"
    fi

    # Check dependency conflicts
    if detect_dependency_conflicts "$base_metadata" "${feature_metadatas[@]}"; then
        echo -e "  ${GREEN}✓${NC} No dependency conflicts"
    else
        echo -e "  ${YELLOW}⚠${NC} Dependency conflicts found (will resolve)"
    fi

    echo ""
    echo -e "${BLUE}Resolution Strategy:${NC}"
    echo "  - Port conflicts: Offset by +100 per feature"
    echo "  - Service names: Prefix with archetype name"
    echo "  - Dependencies: Find compatible versions"

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

# Main execution
if [ "$1" == "--detect" ]; then
    shift
    base_metadata=$1
    shift
    feature_metadatas=("$@")

    generate_conflict_report "$base_metadata" "${feature_metadatas[@]}"

elif [ "$1" == "--resolve-ports" ] && [ -n "$2" ] && [ -n "$3" ]; then
    resolve_port_conflicts "$2" "$3"

elif [ "$1" == "--resolve-services" ] && [ -n "$2" ] && [ -n "$3" ]; then
    resolve_service_name_conflicts "$2" "$3"

elif [ "$1" == "--resolve-deps" ]; then
    shift
    output_file=$1
    shift
    resolve_dependency_conflicts "$output_file" "$@"

else
    echo "Usage:"
    echo "  $0 --detect <base_metadata> <feature_metadata>..."
    echo "  $0 --resolve-ports <compose_file> <offset>"
    echo "  $0 --resolve-services <compose_file> <prefix>"
    echo "  $0 --resolve-deps <output_file> <metadata_files>..."
fi
