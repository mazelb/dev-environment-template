#!/bin/bash

###############################################################################
# Source File Smart Merger
# Intelligently merges source code files (FastAPI, Flask, Express, etc.)
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
# FastAPI Merger
###############################################################################

# Merge FastAPI main.py files
merge_fastapi_main() {
    local output_file=$1
    shift
    local input_files=("$@")

    if [ ${#input_files[@]} -eq 0 ]; then
        print_error "No input files specified"
        return 1
    fi

    print_info "Merging ${#input_files[@]} FastAPI main.py files"

    local temp_file="${output_file}.tmp.$$"

    # Collect imports, routers, and startup code
    declare -A imports
    declare -a routers
    declare -a startup_code

    # Header
    cat > "$temp_file" << 'EOF'
"""
FastAPI Application - Merged from multiple archetypes
"""

EOF

    # Process each file
    for input_file in "${input_files[@]}"; do
        if [ ! -f "$input_file" ]; then
            print_warning "File not found, skipping: $input_file"
            continue
        fi

        print_info "Processing: $input_file"

        local in_imports=true
        local in_app_def=false

        while IFS= read -r line; do
            # Collect imports
            if [[ "$line" =~ ^(from|import)[[:space:]] ]]; then
                imports["$line"]=1
            # Detect app creation
            elif [[ "$line" =~ app[[:space:]]*=[[:space:]]*FastAPI ]]; then
                in_app_def=true
                in_imports=false
            # Collect routers
            elif [[ "$line" =~ app\.include_router ]]; then
                routers+=("$line")
            # Collect startup events
            elif [[ "$line" =~ @app\.on_event.*startup ]]; then
                startup_code+=("$line")
            fi
        done < "$input_file"
    done

    # Write imports
    for import_line in "${!imports[@]}"; do
        echo "$import_line" >> "$temp_file"
    done

    # Write app creation
    cat >> "$temp_file" << 'EOF'

# Create FastAPI application
app = FastAPI(
    title="Multi-Archetype Application",
    description="Application composed from multiple archetypes",
    version="1.0.0"
)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

EOF

    # Write routers
    if [ ${#routers[@]} -gt 0 ]; then
        echo "# Include routers from all archetypes" >> "$temp_file"
        for router in "${routers[@]}"; do
            echo "$router" >> "$temp_file"
        done
        echo "" >> "$temp_file"
    fi

    # Write startup code
    if [ ${#startup_code[@]} -gt 0 ]; then
        echo "# Startup events" >> "$temp_file"
        for code in "${startup_code[@]}"; do
            echo "$code" >> "$temp_file"
        done
        echo "" >> "$temp_file"
    fi

    # Add health check
    cat >> "$temp_file" << 'EOF'

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy"}

EOF

    mv "$temp_file" "$output_file"
    print_success "FastAPI merge complete: $output_file"
    return 0
}

###############################################################################
# Generic Source File Merger
###############################################################################

# Merge source files with conflict markers (fallback method)
merge_source_files_with_markers() {
    local output_file=$1
    shift
    local input_files=("$@")

    if [ ${#input_files[@]} -eq 0 ]; then
        print_error "No input files specified"
        return 1
    fi

    print_info "Merging ${#input_files[@]} source files with conflict markers"
    print_warning "Manual review required for conflict resolution"

    local temp_file="${output_file}.tmp.$$"

    # Header
    cat > "$temp_file" << 'EOF'
# ===================================================================
# MERGED SOURCE FILE - MANUAL REVIEW REQUIRED
# ===================================================================
# This file contains content from multiple source files
# Review and resolve any conflicts marked with [CONFLICT]
# ===================================================================

EOF

    # Process each file
    for input_file in "${input_files[@]}"; do
        if [ ! -f "$input_file" ]; then
            print_warning "File not found, skipping: $input_file"
            continue
        fi

        print_info "Adding: $input_file"

        cat >> "$temp_file" << EOF

# ===================================================================
# FROM: $input_file
# ===================================================================

EOF
        cat "$input_file" >> "$temp_file"
    done

    mv "$temp_file" "$output_file"
    print_warning "Source merge complete with conflict markers: $output_file"
    print_info "Please review and manually resolve conflicts"
    return 0
}

###############################################################################
# Detect file type
###############################################################################

detect_source_type() {
    local input_file=$1

    if [ ! -f "$input_file" ]; then
        echo "unknown"
        return 1
    fi

    # Check for FastAPI
    if grep -q "FastAPI\|from fastapi import" "$input_file" 2>/dev/null; then
        echo "fastapi"
        return 0
    fi

    # Check for Flask
    if grep -q "Flask\|from flask import" "$input_file" 2>/dev/null; then
        echo "flask"
        return 0
    fi

    # Check for Express
    if grep -q "express()\|require.*express" "$input_file" 2>/dev/null; then
        echo "express"
        return 0
    fi

    echo "generic"
    return 0
}

###############################################################################
# Smart Merge (auto-detect type)
###############################################################################

merge_source_files_smart() {
    local output_file=$1
    shift
    local input_files=("$@")

    if [ ${#input_files[@]} -eq 0 ]; then
        print_error "No input files specified"
        return 1
    fi

    # Detect type from first file
    local file_type=$(detect_source_type "${input_files[0]}")
    print_info "Detected file type: $file_type"

    case "$file_type" in
        fastapi)
            merge_fastapi_main "$output_file" "${input_files[@]}"
            ;;
        flask|express|generic)
            print_warning "Smart merge not yet implemented for $file_type"
            merge_source_files_with_markers "$output_file" "${input_files[@]}"
            ;;
        *)
            print_error "Unknown file type"
            return 1
            ;;
    esac
}

###############################################################################
# Main Execution
###############################################################################

# Main execution - only run if script is executed directly (not sourced)
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    if [ $# -eq 0 ]; then
        echo "Source File Smart Merger"
        echo ""
        echo "Usage:"
        echo "  $0 merge-smart <output_file> <input1> <input2> [...]"
        echo "  $0 merge-fastapi <output_file> <input1> <input2> [...]"
        echo "  $0 merge-generic <output_file> <input1> <input2> [...]"
        echo "  $0 detect-type <input_file>"
        echo ""
        echo "Examples:"
        echo "  # Auto-detect and merge"
        echo "  $0 merge-smart src/main.py base/src/main.py rag/src/main.py"
        echo ""
        echo "  # Merge FastAPI files"
        echo "  $0 merge-fastapi src/main.py base/src/main.py rag/src/main.py"
        echo ""
        echo "  # Detect file type"
        echo "  $0 detect-type src/main.py"
        echo ""
        exit 0
    fi

    command=$1
    shift

    case "$command" in
        merge-smart)
            if [ $# -lt 2 ]; then
                print_error "Usage: $0 merge-smart <output_file> <input1> <input2> [...]"
                exit 1
            fi
            merge_source_files_smart "$@"
            ;;
        merge-fastapi)
            if [ $# -lt 2 ]; then
                print_error "Usage: $0 merge-fastapi <output_file> <input1> <input2> [...]"
                exit 1
            fi
            merge_fastapi_main "$@"
            ;;
        merge-generic)
            if [ $# -lt 2 ]; then
                print_error "Usage: $0 merge-generic <output_file> <input1> <input2> [...]"
                exit 1
            fi
            merge_source_files_with_markers "$@"
            ;;
        detect-type)
            if [ $# -ne 1 ]; then
                print_error "Usage: $0 detect-type <input_file>"
                exit 1
            fi
            detect_source_type "$@"
            ;;
        *)
            print_error "Unknown command: $command"
            exit 1
            ;;
    esac
fi
