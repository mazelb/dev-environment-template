#!/bin/bash

###############################################################################
# Directory Structure Merger
# Intelligently merges directory structures from multiple archetypes
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

###############################################################################
# File Merge Strategy Configuration
###############################################################################

# Determine merge strategy for a file
get_merge_strategy() {
    local file_path=$1
    local filename=$(basename "$file_path")
    local extension="${filename##*.}"

    # Configuration files - merge
    case "$filename" in
        docker-compose.yml|docker-compose.yaml)
            echo "merge-docker-compose"
            return 0
            ;;
        .env|.env.*)
            echo "merge-env"
            return 0
            ;;
        Makefile)
            echo "merge-makefile"
            return 0
            ;;
        package.json)
            echo "merge-json"
            return 0
            ;;
        requirements.txt)
            echo "merge-requirements"
            return 0
            ;;
        README.md|CHANGELOG.md)
            echo "merge-markdown"
            return 0
            ;;
    esac

    # By extension
    case "$extension" in
        py)
            if [[ "$filename" == "main.py" || "$filename" == "app.py" ]]; then
                echo "merge-python-main"
            else
                echo "overwrite"
            fi
            ;;
        js)
            if [[ "$filename" == "index.js" || "$filename" == "app.js" ]]; then
                echo "merge-js-main"
            else
                echo "overwrite"
            fi
            ;;
        json|yaml|yml)
            echo "merge-json"
            ;;
        md)
            echo "merge-markdown"
            ;;
        txt)
            echo "merge-text"
            ;;
        *)
            echo "overwrite"
            ;;
    esac
}

###############################################################################
# Merge Strategy Executors
###############################################################################

# Merge requirements.txt files
merge_requirements_files() {
    local output_file=$1
    shift
    local input_files=("$@")

    print_info "Merging requirements.txt files"

    declare -A requirements

    for input_file in "${input_files[@]}"; do
        if [ ! -f "$input_file" ]; then
            continue
        fi

        while IFS= read -r line; do
            # Skip comments and empty lines
            if [[ "$line" =~ ^[[:space:]]*# ]] || [[ -z "$line" ]]; then
                continue
            fi
            # Store requirement (will handle version conflicts by keeping last)
            local pkg_name=$(echo "$line" | sed 's/[>=<].*//')
            requirements["$pkg_name"]="$line"
        done < "$input_file"
    done

    # Write merged requirements
    {
        echo "# Merged requirements from multiple archetypes"
        echo "# Generated: $(date)"
        echo ""
        for req in "${requirements[@]}"; do
            echo "$req"
        done
    } | sort > "$output_file"

    print_success "Requirements merged: $output_file"
}

# Merge markdown files
merge_markdown_files() {
    local output_file=$1
    shift
    local input_files=("$@")

    print_info "Merging markdown files"

    {
        echo "# Merged Documentation"
        echo ""
        echo "_This document was composed from multiple archetypes_"
        echo ""
        echo "---"
        echo ""

        for input_file in "${input_files[@]}"; do
            if [ ! -f "$input_file" ]; then
                continue
            fi

            echo "## From: $input_file"
            echo ""
            cat "$input_file"
            echo ""
            echo "---"
            echo ""
        done
    } > "$output_file"

    print_success "Markdown merged: $output_file"
}

# Merge text files with section markers
merge_text_files() {
    local output_file=$1
    shift
    local input_files=("$@")

    print_info "Merging text files"

    {
        echo "# Merged from multiple archetypes"
        echo "# Generated: $(date)"
        echo ""

        for input_file in "${input_files[@]}"; do
            if [ ! -f "$input_file" ]; then
                continue
            fi

            echo "# ============================================"
            echo "# FROM: $input_file"
            echo "# ============================================"
            cat "$input_file"
            echo ""
        done
    } > "$output_file"

    print_success "Text files merged: $output_file"
}

###############################################################################
# Directory Merging
###############################################################################

# Merge directories
merge_directories() {
    local target_dir=$1
    shift
    local source_dirs=("$@")

    if [ ${#source_dirs[@]} -eq 0 ]; then
        print_error "No source directories specified"
        return 1
    fi

    print_info "Merging ${#source_dirs[@]} directories into: $target_dir"

    # Create target directory
    mkdir -p "$target_dir"

    # Track files to merge
    declare -A files_by_relative_path

    # Scan all source directories
    for source_dir in "${source_dirs[@]}"; do
        if [ ! -d "$source_dir" ]; then
            print_warning "Directory not found, skipping: $source_dir"
            continue
        fi

        print_info "Scanning: $source_dir"

        # Find all files in source directory
        while IFS= read -r -d '' file; do
            # Get relative path
            local rel_path="${file#$source_dir/}"

            # Add to tracking
            if [ -z "${files_by_relative_path[$rel_path]}" ]; then
                files_by_relative_path[$rel_path]="$file"
            else
                files_by_relative_path[$rel_path]="${files_by_relative_path[$rel_path]}|$file"
            fi
        done < <(find "$source_dir" -type f -print0)
    done

    # Process each unique file path
    for rel_path in "${!files_by_relative_path[@]}"; do
        local target_file="$target_dir/$rel_path"
        local source_files_str="${files_by_relative_path[$rel_path]}"

        # Convert pipe-separated string to array
        IFS='|' read -ra source_files <<< "$source_files_str"

        # Create parent directory
        mkdir -p "$(dirname "$target_file")"

        # Determine merge strategy
        local strategy=$(get_merge_strategy "$rel_path")

        if [ ${#source_files[@]} -eq 1 ]; then
            # Only one source - simple copy
            cp "${source_files[0]}" "$target_file"
            print_success "Copied: $rel_path"
        else
            # Multiple sources - merge based on strategy
            print_info "Merging $rel_path (strategy: $strategy, ${#source_files[@]} sources)"

            case "$strategy" in
                merge-docker-compose)
                    # Use docker-compose-merger.sh
                    if [ -f "$(dirname "$0")/docker-compose-merger.sh" ]; then
                        bash "$(dirname "$0")/docker-compose-merger.sh" merge-with-resolution "$target_file" "${source_files[@]}"
                    else
                        cp "${source_files[0]}" "$target_file"
                        print_warning "docker-compose-merger.sh not found, using first file"
                    fi
                    ;;
                merge-env)
                    # Use env-merger.sh
                    if [ -f "$(dirname "$0")/env-merger.sh" ]; then
                        bash "$(dirname "$0")/env-merger.sh" merge-dedup "$target_file" "${source_files[@]}"
                    else
                        cp "${source_files[0]}" "$target_file"
                        print_warning "env-merger.sh not found, using first file"
                    fi
                    ;;
                merge-makefile)
                    # Use makefile-merger.sh
                    if [ -f "$(dirname "$0")/makefile-merger.sh" ]; then
                        bash "$(dirname "$0")/makefile-merger.sh" merge "$target_file" "${source_files[@]}"
                    else
                        cp "${source_files[0]}" "$target_file"
                        print_warning "makefile-merger.sh not found, using first file"
                    fi
                    ;;
                merge-python-main|merge-js-main)
                    # Use source-file-merger.sh
                    if [ -f "$(dirname "$0")/source-file-merger.sh" ]; then
                        bash "$(dirname "$0")/source-file-merger.sh" merge-smart "$target_file" "${source_files[@]}"
                    else
                        cp "${source_files[0]}" "$target_file"
                        print_warning "source-file-merger.sh not found, using first file"
                    fi
                    ;;
                merge-requirements)
                    merge_requirements_files "$target_file" "${source_files[@]}"
                    ;;
                merge-markdown)
                    merge_markdown_files "$target_file" "${source_files[@]}"
                    ;;
                merge-text)
                    merge_text_files "$target_file" "${source_files[@]}"
                    ;;
                overwrite)
                    # Use last file
                    cp "${source_files[-1]}" "$target_file"
                    print_info "Overwrote: $rel_path (used last source)"
                    ;;
                *)
                    print_warning "Unknown strategy: $strategy, using overwrite"
                    cp "${source_files[-1]}" "$target_file"
                    ;;
            esac
        fi
    done

    print_success "Directory merge complete: $target_dir"
    return 0
}

###############################################################################
# List conflicts
###############################################################################

list_merge_conflicts() {
    local source_dirs=("$@")

    if [ ${#source_dirs[@]} -eq 0 ]; then
        print_error "No source directories specified"
        return 1
    fi

    print_info "Analyzing potential merge conflicts"

    # Track files
    declare -A files_by_relative_path

    # Scan all source directories
    for source_dir in "${source_dirs[@]}"; do
        if [ ! -d "$source_dir" ]; then
            continue
        fi

        while IFS= read -r -d '' file; do
            local rel_path="${file#$source_dir/}"

            if [ -z "${files_by_relative_path[$rel_path]}" ]; then
                files_by_relative_path[$rel_path]="$file"
            else
                files_by_relative_path[$rel_path]="${files_by_relative_path[$rel_path]}|$file"
            fi
        done < <(find "$source_dir" -type f -print0)
    done

    # Report conflicts
    local conflict_count=0
    echo ""
    echo "Merge Conflict Analysis"
    echo "======================="
    echo ""

    for rel_path in "${!files_by_relative_path[@]}"; do
        local source_files_str="${files_by_relative_path[$rel_path]}"
        IFS='|' read -ra source_files <<< "$source_files_str"

        if [ ${#source_files[@]} -gt 1 ]; then
            ((conflict_count++))
            local strategy=$(get_merge_strategy "$rel_path")
            echo "Conflict: $rel_path (${#source_files[@]} sources, strategy: $strategy)"
            for src in "${source_files[@]}"; do
                echo "  - $src"
            done
            echo ""
        fi
    done

    if [ $conflict_count -eq 0 ]; then
        print_success "No conflicts detected"
    else
        print_warning "Found $conflict_count file(s) requiring merge"
    fi

    return 0
}

###############################################################################
# Main Execution
###############################################################################

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    if [ $# -eq 0 ]; then
        echo "Directory Structure Merger"
        echo ""
        echo "Usage:"
        echo "  $0 merge <target_dir> <source1> <source2> [...]"
        echo "  $0 list-conflicts <source1> <source2> [...]"
        echo ""
        echo "Examples:"
        echo "  # Merge directories"
        echo "  $0 merge ./project ./archetypes/base ./archetypes/rag"
        echo ""
        echo "  # Check for conflicts"
        echo "  $0 list-conflicts ./archetypes/base ./archetypes/rag"
        echo ""
        exit 0
    fi

    command=$1
    shift

    case "$command" in
        merge)
            if [ $# -lt 2 ]; then
                print_error "Usage: $0 merge <target_dir> <source1> <source2> [...]"
                exit 1
            fi
            merge_directories "$@"
            ;;
        list-conflicts)
            if [ $# -lt 2 ]; then
                print_error "Usage: $0 list-conflicts <source1> <source2> [...]"
                exit 1
            fi
            list_merge_conflicts "$@"
            ;;
        *)
            print_error "Unknown command: $command"
            exit 1
            ;;
    esac
fi
