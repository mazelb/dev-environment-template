#!/bin/bash

###############################################################################
# Enhanced Project Creation Script with Optional Tools
# Creates new projects from template with optional tool selection
###############################################################################

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Default values
TEMPLATE_REPO=""
PROJECT_NAME=""
PROJECT_DIR=""
SKIP_GIT=false
BUILD_IMAGE=true
OPTIONAL_TOOLS=()
USE_PRESET=""
INTERACTIVE=false

# Archetype-related variables
BASE_ARCHETYPE=""
FEATURE_ARCHETYPES=()
ARCHETYPES_DIR=""
USE_ARCHETYPE=false

# Configuration file location
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOOLS_CONFIG="$SCRIPT_DIR/config/optional-tools.json"
ARCHETYPES_DIR="$SCRIPT_DIR/archetypes"

# Source archetype loader
if [ -f "$SCRIPT_DIR/scripts/archetype-loader.sh" ]; then
    source "$SCRIPT_DIR/scripts/archetype-loader.sh"
fi

# Source git helper
if [ -f "$SCRIPT_DIR/scripts/git-helper.sh" ]; then
    source "$SCRIPT_DIR/scripts/git-helper.sh"
fi

# Source gitignore generator
if [ -f "$SCRIPT_DIR/scripts/gitignore-generator.sh" ]; then
    source "$SCRIPT_DIR/scripts/gitignore-generator.sh"
fi

# Functions
print_header() {
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}   ${GREEN}$1${NC}${BLUE}                       ${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Show help
show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Create a new development project from the dev environment template with optional tools or archetypes.

OPTIONS:
    -n, --name NAME              Project name (required)
    -d, --dir PATH               Project directory (default: current directory)
    -t, --template URL           Template repository URL
    --no-git                     Skip Git repository initialization (default: init)
    --no-build                   Skip Docker image build

OPTIONAL TOOLS:
    --tools TOOL1,TOOL2,...      Comma-separated list of optional tools
    --preset PRESET_NAME         Use a predefined preset of tools
    -i, --interactive            Interactive tool selection
    --list-tools                 List all available tools
    --list-presets               List all available presets

ARCHETYPES:
    --archetype NAME             Use a base archetype (e.g., base, rag-project)
    --add-features F1,F2,...     Add feature archetypes to base
    --list-archetypes            List all available archetypes
    --check-compatibility B F    Check if base B is compatible with feature F

AVAILABLE TOOLS:
    docling          - Document understanding and parsing
    llamaindex       - Data framework for LLM applications
    fastapi          - Modern Python web framework
    playwright       - Browser automation and testing
    langfuse         - LLM observability and analytics
    postgresql       - Relational database
    uv               - Fast Python package installer
    opensearch       - Search and analytics engine
    airflow          - Apache Airflow workflow orchestration
    datadog          - Monitoring and observability
    prometheus       - Metrics monitoring system
    langchain        - Framework for LLM applications
    claude-sdk       - Anthropic's agentic SDK
    docusaurus       - Documentation website generator

PRESETS:
    ai-agent         - AI Agent Development (langchain, llamaindex, langfuse, postgresql, docling)
    web-fullstack    - Full-Stack Web (fastapi, postgresql, prometheus, playwright)
    ml-pipeline      - ML/Data Pipeline (airflow, postgresql, prometheus, opensearch)
    claude-computer-use - Claude Computer Use (claude-sdk, langfuse, fastapi)
    documentation    - Documentation Site (docusaurus, playwright)

EXAMPLES:
    # Create project with specific tools
    $0 --name my-app --tools fastapi,postgresql,langfuse

    # Use a preset
    $0 --name my-agent --preset ai-agent

    # Use base archetype
    $0 --name my-project --archetype base

    # Use base archetype with features
    $0 --name my-rag-app --archetype base --add-features rag-project

    # Interactive selection
    $0 --name my-app --interactive

    # List available tools
    $0 --list-tools

EOF
}

# List available tools
list_tools() {
    print_header "Available Optional Tools"
    echo ""

    if [ ! -f "$TOOLS_CONFIG" ]; then
        print_error "Tools configuration file not found: $TOOLS_CONFIG"
        exit 1
    fi

    # Parse JSON and display tools
    jq -r '.tools | to_entries[] | "\(.key) - \(.value.name): \(.value.description)"' "$TOOLS_CONFIG" | while read line; do
        echo "  $line"
    done
    echo ""
}

# List available presets
list_presets() {
    print_header "Available Presets"
    echo ""

    if [ ! -f "$TOOLS_CONFIG" ]; then
        print_error "Tools configuration file not found: $TOOLS_CONFIG"
        exit 1
    fi

    jq -r '.presets | to_entries[] | "\(.key)\n  \(.value.name): \(.value.description)\n  Tools: \(.value.tools | join(", "))\n"' "$TOOLS_CONFIG"
}

# Interactive tool selection
interactive_tool_selection() {
    print_header "Interactive Tool Selection"
    echo ""

    if ! command -v jq &> /dev/null; then
        print_error "jq is required for interactive mode"
        print_info "Install with: sudo apt-get install jq"
        exit 1
    fi

    # Show presets first
    echo "Available presets:"
    jq -r '.presets | to_entries[] | "  [\(.key | ascii_upcase)] \(.value.name) - \(.value.description)"' "$TOOLS_CONFIG"
    echo ""
    read -p "Select a preset (or press Enter to skip): " preset_choice

    if [ -n "$preset_choice" ]; then
        USE_PRESET="$preset_choice"
        print_success "Preset selected: $preset_choice"
        return
    fi

    # Manual tool selection
    echo ""
    echo "Select individual tools (separate multiple with commas):"
    jq -r '.tools | to_entries[] | "  [\(.key)] \(.value.name) - \(.value.description)"' "$TOOLS_CONFIG"
    echo ""
    read -p "Enter tools (comma-separated): " tools_input

    if [ -n "$tools_input" ]; then
        IFS=',' read -ra OPTIONAL_TOOLS <<< "$tools_input"
        print_success "Tools selected: ${OPTIONAL_TOOLS[*]}"
    fi
}

# Apply optional tools to project
apply_optional_tools() {
    local project_path=$1

    if [ ${#OPTIONAL_TOOLS[@]} -eq 0 ] && [ -z "$USE_PRESET" ]; then
        return
    fi

    print_header "Applying Optional Tools"

    # If preset is selected, get tools from preset
    if [ -n "$USE_PRESET" ]; then
        print_info "Loading preset: $USE_PRESET"
        PRESET_TOOLS=$(jq -r ".presets[\"$USE_PRESET\"].tools[]" "$TOOLS_CONFIG" 2>/dev/null)
        if [ $? -ne 0 ]; then
            print_error "Preset not found: $USE_PRESET"
            exit 1
        fi
        OPTIONAL_TOOLS=($PRESET_TOOLS)
        print_success "Loaded tools from preset: ${OPTIONAL_TOOLS[*]}"
    fi

    # Create requirements file additions
    local requirements_additions=""
    local dockerfile_additions=""
    local compose_services=""
    local compose_volumes=""

    for tool in "${OPTIONAL_TOOLS[@]}"; do
        tool=$(echo "$tool" | xargs) # Trim whitespace
        print_info "Adding tool: $tool"

        # Get tool configuration
        tool_config=$(jq ".tools[\"$tool\"]" "$TOOLS_CONFIG")

        if [ "$tool_config" == "null" ]; then
            print_warning "Tool not found: $tool (skipping)"
            continue
        fi

        # Python packages
        python_packages=$(echo "$tool_config" | jq -r '.python_packages[]?' 2>/dev/null)
        if [ -n "$python_packages" ]; then
            requirements_additions+="$python_packages"$'\n'
        fi

        # Node packages
        node_packages=$(echo "$tool_config" | jq -r '.node_packages[]?' 2>/dev/null)
        if [ -n "$node_packages" ]; then
            echo "$node_packages" >> "$project_path/package-additions.txt"
        fi

        # Dockerfile additions
        dockerfile_adds=$(echo "$tool_config" | jq -r '.dockerfile_additions[]?' 2>/dev/null)
        if [ -n "$dockerfile_adds" ]; then
            dockerfile_additions+="$dockerfile_adds"$'\n'
        fi

        # Docker Compose service
        compose_service=$(echo "$tool_config" | jq -r '.docker_compose_service' 2>/dev/null)
        if [ "$compose_service" != "null" ]; then
            compose_services+="$compose_service"$'\n'
        fi

        # Volumes
        volumes=$(echo "$tool_config" | jq -r '.volumes[]?' 2>/dev/null)
        if [ -n "$volumes" ]; then
            compose_volumes+="$volumes"$'\n'
        fi

        # Config files
        config_files=$(echo "$tool_config" | jq -r '.config_files' 2>/dev/null)
        if [ "$config_files" != "null" ]; then
            echo "$config_files" | jq -r 'to_entries[] | "\(.key):\(.value)"' | while IFS=: read -r filename content; do
                echo "$content" > "$project_path/$filename"
                print_success "Created config file: $filename"
            done
        fi

        print_success "Added: $tool"
    done

    # Write requirements additions
    if [ -n "$requirements_additions" ]; then
        cat > "$project_path/requirements-optional.txt" << EOF
# Optional tools added during project creation
$requirements_additions
EOF
        print_success "Created requirements-optional.txt"
    fi

    # Write Dockerfile additions
    if [ -n "$dockerfile_additions" ]; then
        cat > "$project_path/Dockerfile.additions" << EOF
# Optional tool additions
$dockerfile_additions
EOF
        print_success "Created Dockerfile.additions"
        print_info "Add these lines to your Dockerfile before final CMD"
    fi

    # Create docker-compose.project.yml with services
    if [ -n "$compose_services" ] || [ -n "$compose_volumes" ]; then
        cat > "$project_path/docker-compose.project.yml" << 'EOF'
version: '3.8'

services:
  dev:
    environment:
      - PROJECT_TOOLS=enabled

EOF

        # Add services
        if [ -n "$compose_services" ]; then
            echo "$compose_services" | jq -r 'to_entries[] | "  \(.key):\n    \(.value | to_entries[] | "    \(.key): \(.value | @json)")"' >> "$project_path/docker-compose.project.yml" 2>/dev/null || echo "  # Services configuration" >> "$project_path/docker-compose.project.yml"
        fi

        # Add volumes
        if [ -n "$compose_volumes" ]; then
            echo -e "\nvolumes:" >> "$project_path/docker-compose.project.yml"
            echo "$compose_volumes" | while read -r vol; do
                [ -n "$vol" ] && echo "  $vol:" >> "$project_path/docker-compose.project.yml"
            done
        fi

        print_success "Created docker-compose.project.yml"
    fi

    # Create installation instructions
    cat > "$project_path/OPTIONAL_TOOLS.md" << EOF
# Optional Tools Installed

This project was created with the following optional tools:

$(printf '%s\n' "${OPTIONAL_TOOLS[@]}" | sed 's/^/- /')

## Installation Instructions

### Python Packages
If \`requirements-optional.txt\` was created:
\`\`\`bash
pip install -r requirements-optional.txt
\`\`\`

### Node Packages
If \`package-additions.txt\` was created:
\`\`\`bash
cat package-additions.txt | xargs npm install
\`\`\`

### Docker Compose
To use additional services:
\`\`\`bash
docker-compose -f docker-compose.yml -f docker-compose.project.yml up -d
\`\`\`

### Dockerfile Additions
If \`Dockerfile.additions\` was created, add those lines to your Dockerfile.

## Tool Documentation

$(for tool in "${OPTIONAL_TOOLS[@]}"; do
    tool_name=$(jq -r ".tools[\"$tool\"].name" "$TOOLS_CONFIG" 2>/dev/null)
    tool_desc=$(jq -r ".tools[\"$tool\"].description" "$TOOLS_CONFIG" 2>/dev/null)
    echo "### $tool_name"
    echo "$tool_desc"
    echo ""
done)
EOF

    print_success "Created OPTIONAL_TOOLS.md with installation instructions"
    echo ""
    print_info "Optional tools configured. See OPTIONAL_TOOLS.md for details."
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -n|--name)
                PROJECT_NAME="$2"
                shift 2
                ;;
            -d|--dir)
                PROJECT_DIR="$2"
                shift 2
                ;;
            -t|--template)
                TEMPLATE_REPO="$2"
                shift 2
                ;;
            --no-git)
                SKIP_GIT=true
                shift
                ;;
            --no-build)
                BUILD_IMAGE=false
                shift
                ;;
            --tools)
                IFS=',' read -ra OPTIONAL_TOOLS <<< "$2"
                shift 2
                ;;
            --preset)
                USE_PRESET="$2"
                shift 2
                ;;
            -i|--interactive)
                INTERACTIVE=true
                shift
                ;;
            --archetype)
                BASE_ARCHETYPE="$2"
                USE_ARCHETYPE=true
                shift 2
                ;;
            --add-features)
                IFS=',' read -ra FEATURE_ARCHETYPES <<< "$2"
                USE_ARCHETYPE=true
                shift 2
                ;;
            --list-archetypes)
                if command -v list_archetypes &> /dev/null; then
                    list_archetypes
                else
                    print_error "Archetype loader not available"
                    print_info "Run from template directory or ensure scripts/archetype-loader.sh exists"
                fi
                exit 0
                ;;
            --list-tools)
                list_tools
                exit 0
                ;;
            --list-presets)
                list_presets
                exit 0
                ;;
            --check-compatibility)
                if [ -n "$2" ] && [ -n "$3" ]; then
                    if command -v check_compatibility &> /dev/null; then
                        check_compatibility "$2" "$3"
                    else
                        print_error "Archetype loader not available"
                    fi
                    exit 0
                else
                    print_error "Usage: --check-compatibility <base> <feature>"
                    exit 1
                fi
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Main script execution
main() {
    parse_args "$@"

    # Validate project name
    if [ -z "$PROJECT_NAME" ]; then
        print_error "Project name is required"
        show_help
        exit 1
    fi

    # Interactive mode
    if [ "$INTERACTIVE" = true ]; then
        interactive_tool_selection
    fi

    # Set project directory
    if [ -z "$PROJECT_DIR" ]; then
        PROJECT_DIR="."
    fi

    FULL_PROJECT_PATH="$PROJECT_DIR/$PROJECT_NAME"

    # Check if project directory already exists
    if [ -d "$FULL_PROJECT_PATH" ]; then
        print_error "Directory already exists: $FULL_PROJECT_PATH"
        exit 1
    fi

    print_header "Creating Dev Project: $PROJECT_NAME"

    # Create project directory
    print_info "Creating project directory..."
    mkdir -p "$FULL_PROJECT_PATH"
    cd "$FULL_PROJECT_PATH"

    # Copy template files
    print_info "Copying template files..."
    if [ -n "$TEMPLATE_REPO" ]; then
        git clone "$TEMPLATE_REPO" temp_template
        shopt -s dotglob
        cp -r temp_template/* .
        rm -rf temp_template
    else
        # Copy from current template directory
        TEMPLATE_DIR=$(dirname "$SCRIPT_DIR")
        shopt -s dotglob
        cp -r "$TEMPLATE_DIR"/* . 2>/dev/null || true
    fi

    print_success "Template files copied"

    # Apply optional tools
    apply_optional_tools "$FULL_PROJECT_PATH"

    # Create basic project structure
    mkdir -p src tests docs

    # Generate smart .gitignore
    print_info "Generating .gitignore..."
    if command -v generate_gitignore &> /dev/null; then
        local archetypes_list="$BASE_ARCHETYPE ${FEATURE_ARCHETYPES[*]}"
        local tools_list="${OPTIONAL_TOOLS[*]}"
        generate_gitignore "$FULL_PROJECT_PATH/.gitignore" "$archetypes_list" "$tools_list"
    else
        print_warning "gitignore generator not available, using basic .gitignore"
        # Create basic .gitignore if generator not available
        cat > "$FULL_PROJECT_PATH/.gitignore" << 'EOF'
# Python
__pycache__/
*.py[cod]
.venv/
venv/

# Node
node_modules/

# Environment
.env
*.env

# IDE
.vscode/
.idea/
EOF
        print_success "Basic .gitignore created"
    fi

    # Initialize git repository (automatic unless --no-git specified)
    if [ "$SKIP_GIT" != true ]; then
        if command -v initialize_git_repository &> /dev/null; then
            # Use smart Git initialization with archetype information
            local archetypes_list="$BASE_ARCHETYPE ${FEATURE_ARCHETYPES[*]}"
            local tools_list="${OPTIONAL_TOOLS[*]}"
            initialize_git_repository "$FULL_PROJECT_PATH" "$PROJECT_NAME" "$archetypes_list" "$tools_list" "$USE_PRESET"
        else
            # Fallback to basic Git initialization
            print_info "Initializing git repository..."
            if command -v git &> /dev/null; then
                cd "$FULL_PROJECT_PATH"
                git init
                git add .
                git commit -m "Initial commit: Project created with optional tools: ${OPTIONAL_TOOLS[*]}"
                cd - > /dev/null
                print_success "Git repository initialized"
            else
                print_warning "Git not found, skipping repository initialization"
            fi
        fi
    else
        print_info "Skipping Git initialization (--no-git specified)"
    fi

    # Build Docker image
    if [ "$BUILD_IMAGE" = true ]; then
        print_info "Building Docker image..."
        docker-compose build dev
        print_success "Docker image built"
    fi

    # Display next steps
    echo ""
    print_header "Setup Complete!"
    echo ""
    echo "Project created: $FULL_PROJECT_PATH"
    echo ""
    if [ ${#OPTIONAL_TOOLS[@]} -gt 0 ]; then
        echo "Optional tools installed:"
        printf '  - %s\n' "${OPTIONAL_TOOLS[@]}"
        echo ""
        echo "See OPTIONAL_TOOLS.md for installation instructions"
        echo ""
    fi
    echo "Next steps:"
    echo "  1. cd $FULL_PROJECT_PATH"
    echo "  2. Review OPTIONAL_TOOLS.md (if tools were added)"
    echo "  3. docker-compose up -d dev"
    echo "  4. code . (open in VS Code)"
    echo ""
    echo "Happy coding! 🚀"
}

main "$@"
