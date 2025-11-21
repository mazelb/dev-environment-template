#!/bin/bash

###############################################################################
# Docker Compose File Merger
# Intelligently merges multiple docker-compose.yml files
###############################################################################

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Define print functions if not already available
if ! command -v print_error &> /dev/null; then
    print_error() { echo -e "${RED}✗${NC} $1" >&2; }
    print_warning() { echo -e "${YELLOW}⚠${NC} $1" >&2; }
    print_info() { echo -e "${CYAN}ℹ${NC} $1"; }
    print_success() { echo -e "${GREEN}✓${NC} $1"; }
fi

# Check if yq is available
YQ_AVAILABLE=false
if command -v yq &> /dev/null; then
    YQ_AVAILABLE=true
fi

###############################################################################
# Docker Compose Merger
###############################################################################

# Merge multiple docker-compose files into one
# Usage: merge_docker_compose output_file input_file1 input_file2 [input_file3 ...]
merge_docker_compose() {
    local output_file=$1
    shift
    local input_files=("$@")

    if [ ${#input_files[@]} -eq 0 ]; then
        print_error "No input files specified"
        return 1
    fi

    print_info "Merging ${#input_files[@]} docker-compose files into $output_file"

    if [ "$YQ_AVAILABLE" = true ]; then
        merge_with_yq "$output_file" "${input_files[@]}"
    else
        merge_with_fallback "$output_file" "${input_files[@]}"
    fi
}

# Merge using yq (preferred method)
merge_with_yq() {
    local output_file=$1
    shift
    local input_files=("$@")

    # Start with first file
    local base_file="${input_files[0]}"

    if [ ! -f "$base_file" ]; then
        print_error "Base file not found: $base_file"
        return 1
    fi

    cp "$base_file" "$output_file"
    print_info "Base: $base_file"

    # Merge remaining files
    for ((i=1; i<${#input_files[@]}; i++)); do
        local merge_file="${input_files[$i]}"

        if [ ! -f "$merge_file" ]; then
            print_warning "File not found, skipping: $merge_file"
            continue
        fi

        print_info "Merging: $merge_file"

        # Merge services
        local services=$(yq eval '.services | keys | .[]' "$merge_file" 2>/dev/null)
        while IFS= read -r service; do
            [ -z "$service" ] && continue

            # Check if service already exists
            if yq eval ".services.\"$service\"" "$output_file" 2>/dev/null | grep -q "null"; then
                # Service doesn't exist, add it
                yq eval ".services.\"$service\" = $(yq eval ".services.\"$service\"" "$merge_file" -o=json)" -i "$output_file"
                print_success "  Added service: $service"
            else
                print_warning "  Service '$service' already exists, skipping"
            fi
        done <<< "$services"

        # Merge volumes
        local volumes=$(yq eval '.volumes | keys | .[]' "$merge_file" 2>/dev/null)
        while IFS= read -r volume; do
            [ -z "$volume" ] && continue

            if yq eval ".volumes.\"$volume\"" "$output_file" 2>/dev/null | grep -q "null"; then
                yq eval ".volumes.\"$volume\" = $(yq eval ".volumes.\"$volume\"" "$merge_file" -o=json)" -i "$output_file"
                print_success "  Added volume: $volume"
            fi
        done <<< "$volumes"

        # Merge networks
        local networks=$(yq eval '.networks | keys | .[]' "$merge_file" 2>/dev/null)
        while IFS= read -r network; do
            [ -z "$network" ] && continue

            if yq eval ".networks.\"$network\"" "$output_file" 2>/dev/null | grep -q "null"; then
                yq eval ".networks.\"$network\" = $(yq eval ".networks.\"$network\"" "$merge_file" -o=json)" -i "$output_file"
                print_success "  Added network: $network"
            fi
        done <<< "$networks"
    done

    print_success "Docker Compose merge complete: $output_file"
    return 0
}

# Fallback merge without yq (basic concatenation with deduplication)
merge_with_fallback() {
    local output_file=$1
    shift
    local input_files=("$@")

    print_warning "yq not available - using basic merge (may have limitations)"

    local temp_file="${output_file}.tmp.$$"

    # Start with header from first file
    local base_file="${input_files[0]}"
    if [ ! -f "$base_file" ]; then
        print_error "Base file not found: $base_file"
        return 1
    fi

    # Extract version and start services section
    grep "^version:" "$base_file" > "$temp_file" || echo "version: '3.8'" > "$temp_file"
    echo "services:" >> "$temp_file"

    # Track seen services to avoid duplicates
    declare -A seen_services

    # Merge all services
    for input_file in "${input_files[@]}"; do
        [ ! -f "$input_file" ] && continue

        print_info "Processing: $input_file"

        # Extract services section
        local in_services=false
        while IFS= read -r line; do
            if [[ "$line" =~ ^services: ]]; then
                in_services=true
                continue
            elif [[ "$line" =~ ^(volumes|networks): ]]; then
                in_services=false
            fi

            if [ "$in_services" = true ]; then
                # Check if this is a service definition (2-space indent, name followed by colon)
                if [[ "$line" =~ ^[[:space:]]{2}[a-zA-Z0-9_-]+: ]]; then
                    local service_name=$(echo "$line" | sed 's/^  //' | sed 's/:.*//')

                    if [ -z "${seen_services[$service_name]}" ]; then
                        seen_services[$service_name]=1
                    else
                        print_warning "  Skipping duplicate service: $service_name"
                        continue
                    fi
                fi
                echo "$line" >> "$temp_file"
            fi
        done < "$input_file"
    done

    # Merge volumes
    echo "" >> "$temp_file"
    echo "volumes:" >> "$temp_file"
    declare -A seen_volumes

    for input_file in "${input_files[@]}"; do
        [ ! -f "$input_file" ] && continue

        local in_volumes=false
        while IFS= read -r line; do
            if [[ "$line" =~ ^volumes: ]]; then
                in_volumes=true
                continue
            elif [[ "$line" =~ ^(services|networks): ]]; then
                in_volumes=false
            fi

            if [ "$in_volumes" = true ] && [[ "$line" =~ ^[[:space:]]{2}[a-zA-Z0-9_-]+: ]]; then
                local volume_name=$(echo "$line" | sed 's/^  //' | sed 's/:.*//')

                if [ -z "${seen_volumes[$volume_name]}" ]; then
                    seen_volumes[$volume_name]=1
                    echo "$line" >> "$temp_file"
                fi
            fi
        done < "$input_file"
    done

    # Merge networks
    echo "" >> "$temp_file"
    echo "networks:" >> "$temp_file"
    declare -A seen_networks

    for input_file in "${input_files[@]}"; do
        [ ! -f "$input_file" ] && continue

        local in_networks=false
        while IFS= read -r line; do
            if [[ "$line" =~ ^networks: ]]; then
                in_networks=true
                continue
            elif [[ "$line" =~ ^(services|volumes): ]]; then
                in_networks=false
            fi

            if [ "$in_networks" = true ] && [[ "$line" =~ ^[[:space:]]{2}[a-zA-Z0-9_-]+: ]]; then
                local network_name=$(echo "$line" | sed 's/^  //' | sed 's/:.*//')

                if [ -z "${seen_networks[$network_name]}" ]; then
                    seen_networks[$network_name]=1
                    echo "$line" >> "$temp_file"
                fi
            fi
        done < "$input_file"
    done

    mv "$temp_file" "$output_file"
    print_success "Docker Compose merge complete (basic method): $output_file"
    return 0
}

###############################################################################
# Merge with Conflict Resolution
###############################################################################

# Merge docker-compose files with automatic conflict resolution
# Applies port offsets and service prefixes
merge_docker_compose_with_resolution() {
    local output_file=$1
    local base_file=$2
    shift 2
    local feature_files=("$@")

    print_info "Merging docker-compose with conflict resolution"

    # Create temp directory for processed files
    local temp_dir=$(mktemp -d)
    local processed_files=("$base_file")

    # Process each feature file with offset and prefix
    local offset=100
    for i in "${!feature_files[@]}"; do
        local feature_file="${feature_files[$i]}"
        local feature_name=$(basename "$(dirname "$feature_file")")
        local temp_file="$temp_dir/$(basename "$feature_file")"

        # Copy to temp
        cp "$feature_file" "$temp_file"

        # Apply port offset
        local port_offset=$((offset * (i + 1)))
        if command -v resolve_port_conflicts &> /dev/null; then
            resolve_port_conflicts "$temp_file" "$port_offset" 2>/dev/null || print_warning "Port offset failed"
        fi

        # Apply service prefix
        if command -v resolve_service_name_conflicts &> /dev/null; then
            resolve_service_name_conflicts "$temp_file" "$feature_name" 2>/dev/null || print_warning "Service prefix failed"
        fi

        processed_files+=("$temp_file")
        print_info "Processed: $feature_name (offset: +$port_offset)"
    done

    # Merge all processed files
    merge_docker_compose "$output_file" "${processed_files[@]}"

    # Cleanup
    rm -rf "$temp_dir"

    print_success "Merge with conflict resolution complete"
    return 0
}

###############################################################################
# Main Execution
###############################################################################

# Main execution - only run if script is executed directly (not sourced)
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    if [ $# -lt 2 ]; then
        echo "Docker Compose File Merger"
        echo ""
        echo "Usage:"
        echo "  $0 merge <output_file> <input_file1> <input_file2> [...]"
        echo "  $0 merge-with-resolution <output_file> <base_file> <feature_file1> [...]"
        echo ""
        echo "Examples:"
        echo "  # Simple merge"
        echo "  $0 merge docker-compose.merged.yml docker-compose.yml docker-compose.rag.yml"
        echo ""
        echo "  # Merge with conflict resolution (port offsets + service prefixes)"
        echo "  $0 merge-with-resolution docker-compose.yml base/docker-compose.yml rag/docker-compose.yml"
        echo ""
        exit 0
    fi

    command=$1
    shift

    case "$command" in
        merge)
            if [ $# -lt 2 ]; then
                print_error "Usage: $0 merge <output_file> <input_file1> <input_file2> [...]"
                exit 1
            fi
            merge_docker_compose "$@"
            ;;
        merge-with-resolution)
            if [ $# -lt 2 ]; then
                print_error "Usage: $0 merge-with-resolution <output_file> <base_file> <feature_file1> [...]"
                exit 1
            fi
            merge_docker_compose_with_resolution "$@"
            ;;
        *)
            print_error "Unknown command: $command"
            exit 1
            ;;
    esac
fi
