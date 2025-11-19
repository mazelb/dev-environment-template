#!/bin/bash

###############################################################################
# .gitignore Generator
# Generates smart .gitignore files based on archetypes and tools
###############################################################################

# Color codes (define if not already defined)
RED=${RED:-'\033[0;31m'}
GREEN=${GREEN:-'\033[0;32m'}
YELLOW=${YELLOW:-'\033[1;33m'}
BLUE=${BLUE:-'\033[0;34m'}
CYAN=${CYAN:-'\033[0;36m'}
NC=${NC:-'\033[0m'}

# Print functions
if ! command -v print_success &> /dev/null; then
    print_success() { echo -e "${GREEN}✓${NC} $1"; }
fi

if ! command -v print_info &> /dev/null; then
    print_info() { echo -e "${CYAN}ℹ${NC} $1"; }
fi

if ! command -v print_warning &> /dev/null; then
    print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
fi

# ==============================================================================
# Base .gitignore Template
# ==============================================================================

generate_base_gitignore() {
    cat << 'EOF'
# ==============================================================================
# Base .gitignore - Auto-generated
# ==============================================================================

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST
venv/
env/
ENV/
.venv

# Node.js
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.npm
.node_repl_history
package-lock.json
yarn.lock

# Environment variables
.env
.env.local
.env.*.local
*.env

# IDE
.vscode/
.idea/
*.swp
*.swo
*~
.DS_Store

# Docker
docker-compose.override.yml
.dockerignore

# Logs
*.log
logs/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# OS
.DS_Store
Thumbs.db
Desktop.ini

# Testing
.coverage
.pytest_cache/
.tox/
htmlcov/
coverage.xml
*.cover
.hypothesis/

# Build artifacts
*.o
*.a
*.exe
*.out
a.out

EOF
}

# ==============================================================================
# Archetype-specific patterns
# ==============================================================================

# Get gitignore patterns from archetype metadata
get_archetype_patterns() {
    local archetype=$1
    local metadata_file="$ARCHETYPES_DIR/$archetype/__archetype__.json"

    if [ ! -f "$metadata_file" ]; then
        return 0
    fi

    # Extract gitignore patterns from archetype metadata
    if command -v jq &> /dev/null; then
        local patterns=$(jq -r '.configuration.gitignore_patterns[]?' "$metadata_file" 2>/dev/null)
        if [ -n "$patterns" ]; then
            echo ""
            echo "# From archetype: $archetype"
            echo "$patterns"
        fi
    fi
}

# Add patterns for specific tools
add_tool_patterns() {
    local tool=$1

    case "$tool" in
        postgresql|postgres)
            echo ""
            echo "# PostgreSQL"
            echo "postgres-data/"
            echo "*.sql.backup"
            ;;
        opensearch)
            echo ""
            echo "# OpenSearch"
            echo "opensearch-data/"
            echo "opensearch-logs/"
            ;;
        ollama)
            echo ""
            echo "# Ollama"
            echo "ollama-data/"
            echo ".ollama/"
            ;;
        langfuse)
            echo ""
            echo "# Langfuse"
            echo "langfuse-data/"
            ;;
        airflow)
            echo ""
            echo "# Apache Airflow"
            echo "airflow.db"
            echo "airflow.cfg"
            echo "logs/"
            echo "dags/__pycache__/"
            ;;
        prometheus)
            echo ""
            echo "# Prometheus"
            echo "prometheus-data/"
            ;;
        grafana)
            echo ""
            echo "# Grafana"
            echo "grafana-data/"
            ;;
        redis)
            echo ""
            echo "# Redis"
            echo "redis-data/"
            echo "dump.rdb"
            ;;
        docusaurus)
            echo ""
            echo "# Docusaurus"
            echo ".docusaurus/"
            echo "build/"
            echo ".cache-loader/"
            ;;
        playwright)
            echo ""
            echo "# Playwright"
            echo "test-results/"
            echo "playwright-report/"
            echo ".playwright/"
            ;;
    esac
}

# ==============================================================================
# Main generation function
# ==============================================================================

# Generate complete .gitignore file
generate_gitignore() {
    local output_file=$1
    local archetypes=$2
    local tools=$3

    print_info "Generating .gitignore..."

    # Start with base template
    generate_base_gitignore > "$output_file"

    # Add archetype-specific patterns
    if [ -n "$archetypes" ]; then
        echo "" >> "$output_file"
        echo "# ==============================================================================\n# Archetype-specific patterns" >> "$output_file"
        echo "# ==============================================================================" >> "$output_file"

        IFS=', ' read -ra ARCH_ARRAY <<< "$archetypes"
        for archetype in "${ARCH_ARRAY[@]}"; do
            [ -z "$archetype" ] && continue
            get_archetype_patterns "$archetype" >> "$output_file"
        done
    fi

    # Add tool-specific patterns
    if [ -n "$tools" ]; then
        echo "" >> "$output_file"
        echo "# ==============================================================================" >> "$output_file"
        echo "# Tool-specific patterns" >> "$output_file"
        echo "# ==============================================================================" >> "$output_file"

        IFS=', ' read -ra TOOL_ARRAY <<< "$tools"
        for tool in "${TOOL_ARRAY[@]}"; do
            [ -z "$tool" ] && continue
            add_tool_patterns "$tool" >> "$output_file"
        done
    fi

    # Add custom patterns section
    echo "" >> "$output_file"
    echo "# ==============================================================================" >> "$output_file"
    echo "# Custom patterns (add your project-specific patterns below)" >> "$output_file"
    echo "# ==============================================================================" >> "$output_file"
    echo "" >> "$output_file"

    print_success ".gitignore generated: $output_file"
}

# Append patterns to existing .gitignore
append_to_gitignore() {
    local gitignore_file=$1
    local patterns=$2

    if [ ! -f "$gitignore_file" ]; then
        print_warning ".gitignore not found, creating new file"
        touch "$gitignore_file"
    fi

    echo "" >> "$gitignore_file"
    echo "$patterns" >> "$gitignore_file"
}

# Check if pattern already exists in .gitignore
pattern_exists() {
    local gitignore_file=$1
    local pattern=$2

    if [ -f "$gitignore_file" ]; then
        grep -qF "$pattern" "$gitignore_file"
        return $?
    fi

    return 1
}

# ==============================================================================
# Validation
# ==============================================================================

# Validate .gitignore file
validate_gitignore() {
    local gitignore_file=$1

    if [ ! -f "$gitignore_file" ]; then
        print_warning ".gitignore file not found: $gitignore_file"
        return 1
    fi

    # Check for basic patterns
    local required_patterns=("__pycache__" "node_modules" ".env")
    local missing_patterns=()

    for pattern in "${required_patterns[@]}"; do
        if ! grep -q "$pattern" "$gitignore_file"; then
            missing_patterns+=("$pattern")
        fi
    done

    if [ ${#missing_patterns[@]} -eq 0 ]; then
        print_success ".gitignore validation passed"
        return 0
    else
        print_warning "Missing recommended patterns: ${missing_patterns[*]}"
        return 1
    fi
}

# ==============================================================================
# Export functions
# ==============================================================================

export -f generate_gitignore
export -f append_to_gitignore
export -f validate_gitignore
export -f pattern_exists
