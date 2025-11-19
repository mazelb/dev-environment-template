# ArXiv Paper Curator → Dev Environment Template
## Merge Strategy Analysis & Recommendations

**Date:** November 19, 2025
**Version:** 1.0
**Status:** Research Complete - Awaiting Decision

---

## Executive Summary

After thorough analysis of both repositories, I propose **Option A: Template with Project Archetypes** as the optimal approach. This strategy preserves the template's core purpose while creating a scalable system for reference implementations.

**Key Finding:** The current template already has a **preset system** in `create-project.sh` (lines 92-104) that can be extended to support full project archetypes, not just tool bundles.

---

## Table of Contents

1. [Current Template Architecture Analysis](#1-current-template-architecture-analysis)
2. [ArXiv-Paper-Curator Component Analysis](#2-arxiv-paper-curator-component-analysis)
3. [Merge Strategy Options](#3-merge-strategy-options)
4. [Detailed Implementation Plans](#4-detailed-implementation-plans)
5. [Recommended Approach](#5-recommended-approach)
6. [Migration Path](#6-migration-path)

---

## 1. Current Template Architecture Analysis

### 1.1 Template Instantiation Mechanism

**Current Flow:**
```bash
./create-project.sh --name my-app [--preset ai-agent] [--tools tool1,tool2]
    ↓
Creates new directory: my-app/
    ↓
Copies template files (Dockerfile, docker-compose.yml, .vscode, scripts)
    ↓
Applies optional tools from config/optional-tools.json (if it exists)
    ↓
Generates: requirements-optional.txt, docker-compose.project.yml, OPTIONAL_TOOLS.md
    ↓
Initializes git repo (if --git flag)
```

**Key Files:**
- `create-project.sh` (510 lines) - Main project creation script
- `install-template.sh` (494 lines) - Template installation script
- `config/optional-tools.json` - **MISSING** (referenced but doesn't exist yet)
- `scripts/sync-template.sh` - Update propagation for existing projects
- `scripts/manage-template-updates.sh` (339 lines) - Version management

### 1.2 Update Propagation System

**Three-Tier Update Strategy:**
1. **Critical Updates** - Security patches, forced push to all projects
2. **Recommended Updates** - New features, opt-in via `sync-template.sh`
3. **Optional Updates** - Experimental, per-project choice

**Update Flow:**
```bash
Template Repo (v1.2.0)
    ↓ git tag + push
GitHub Release
    ↓ ./scripts/sync-template.sh
Existing Projects (selective merge)
```

### 1.3 Current Preset System

**Defined Presets** (from create-project.sh lines 92-99):
- `ai-agent` - AI Agent Development (langchain, llamaindex, langfuse, postgresql, docling)
- `web-fullstack` - Full-Stack Web (fastapi, postgresql, prometheus, playwright)
- `ml-pipeline` - ML/Data Pipeline (airflow, postgresql, prometheus, opensearch)
- `claude-computer-use` - Claude Computer Use (claude-sdk, langfuse, fastapi)
- `documentation` - Documentation Site (docusaurus, playwright)

**Problem:** Presets only install **packages**, not **project structures** or **application code**.

### 1.4 Template Structure

```
dev-environment-template/
├── .devcontainer/
│   ├── devcontainer.json       # VS Code container config
│   └── post-create.sh
├── .vscode/
│   ├── settings.json           # Project settings
│   ├── tasks.json              # Build/run tasks
│   ├── launch.json             # Debug configs
│   └── prompts/                # AI prompts
├── scripts/
│   ├── create-project.sh       # ★ Project instantiation
│   ├── sync-template.sh        # ★ Update existing projects
│   └── manage-template-updates.sh
├── docs/
│   ├── SETUP_GUIDE.md
│   ├── USAGE_GUIDE.md
│   └── UPDATES_GUIDE.md
├── examples/                    # ★ Currently empty (just .gitkeep)
├── Dockerfile                   # Multi-language dev container
├── docker-compose.yml           # PostgreSQL, Redis, dev service
└── README.md
```

**Critical Observations:**
- Template is **tool-agnostic** - provides foundation, not specific app patterns
- `examples/` directory exists but is empty
- No `config/` directory yet (referenced in create-project.sh)
- Strong documentation infrastructure
- Designed for **copying**, not cloning

---

## 2. ArXiv-Paper-Curator Component Analysis

### 2.1 Template-Worthy Components

**Highly Reusable (80%+ projects benefit):**
1. **Pydantic Settings Pattern** - Environment-based configuration
   - `config/settings.py` with `BaseSettings`
   - `.env.example` with comprehensive variables
   - Runtime validation with type hints

2. **FastAPI Project Structure**
   - `api/` directory organization
   - `routers/` for endpoint modularity
   - `dependencies.py` for DI pattern
   - Health check endpoints

3. **Docker Service Templates**
   - OpenSearch cluster configuration
   - Ollama with model management
   - Airflow with DAG structure
   - Redis caching patterns

4. **Testing Infrastructure**
   - `pytest` configuration (`pytest.ini`, `conftest.py`)
   - Mock patterns for external services
   - Integration test structure

5. **Makefile Patterns**
   - Common commands (run, test, lint, format)
   - Docker orchestration shortcuts
   - Database migration helpers

**Moderately Reusable (40-60% projects):**
6. **Langfuse Integration** - Tracing/observability
7. **Async Service Architecture** - Background workers
8. **Database Migration Scripts** - Alembic patterns
9. **API Client Patterns** - Rate limiting, retry logic
10. **Document Processing Pipeline** - Streaming, chunking

**Project-Specific (20% projects):**
11. **ArXiv API Integration** - Specific to paper curation
12. **Semantic Search Implementation** - Domain-specific
13. **Paper Metadata Schema** - Application logic

### 2.2 ArXiv-Curator Directory Structure

```
arxiv-paper-curator/
├── config/
│   └── settings.py              # ★ Pydantic Settings
├── src/
│   ├── api/                     # ★ FastAPI structure
│   │   ├── routers/
│   │   ├── dependencies.py
│   │   └── main.py
│   ├── services/                # ★ Service layer
│   │   ├── arxiv_client.py
│   │   ├── embedding_service.py
│   │   └── search_service.py
│   ├── models/                  # ★ Domain models
│   └── utils/
├── airflow/
│   └── dags/                    # ★ Workflow patterns
├── docker/
│   ├── opensearch.yml           # ★ Service configs
│   ├── ollama.yml
│   └── airflow.yml
├── tests/                       # ★ Test structure
│   ├── unit/
│   └── integration/
├── Makefile                     # ★ Command patterns
├── pyproject.toml               # ★ Modern Python packaging
└── README.md
```

### 2.3 Technology Stack

**Current Template Supports:**
- Python 3.11 ✅
- Docker/Docker Compose ✅
- PostgreSQL ✅
- Redis ✅
- FastAPI ✅ (via optional tools)

**ArXiv-Curator Adds:**
- OpenSearch (search engine)
- Ollama (local LLM hosting)
- Airflow (workflow orchestration)
- Langfuse (LLM observability)
- Langchain (LLM framework)
- Sentence Transformers (embeddings)

---

## 3. Merge Strategy Options

### Option A: Template with Project Archetypes
**Concept:** Extend preset system to support full project scaffolding

### Option B: Template + Examples Repository
**Concept:** Keep template minimal, create separate examples repo

### Option C: Template with Optional Components
**Concept:** Modular components library, composable during creation

---

## 4. Detailed Implementation Plans

---

## 🎯 OPTION A: Template with Project Archetypes

### Philosophy
"Presets install packages. Archetypes scaffold projects."

### Directory Structure
```
dev-environment-template/
├── archetypes/                          # ★ NEW
│   ├── README.md                        # Archetype system docs
│   ├── base/                            # Minimal starter
│   │   ├── src/
│   │   ├── tests/
│   │   └── README.md
│   ├── rag-project/                     # ★ ArXiv-curator as reference
│   │   ├── __archetype__.json          # Metadata
│   │   ├── src/
│   │   │   ├── api/
│   │   │   │   ├── routers/
│   │   │   │   ├── dependencies.py
│   │   │   │   └── main.py
│   │   │   ├── services/
│   │   │   │   ├── __template__embedding_service.py
│   │   │   │   └── __template__search_service.py
│   │   │   └── models/
│   │   ├── docker/
│   │   │   ├── opensearch.yml
│   │   │   ├── ollama.yml
│   │   │   └── README.md
│   │   ├── tests/
│   │   │   ├── conftest.py
│   │   │   ├── unit/
│   │   │   └── integration/
│   │   ├── config/
│   │   │   ├── settings.py
│   │   │   └── .env.example
│   │   ├── Makefile
│   │   ├── pyproject.toml
│   │   └── README.md
│   ├── agentic-project/                 # ★ Future: Multi-agent systems
│   │   ├── __archetype__.json
│   │   ├── agents/
│   │   ├── workflows/
│   │   └── README.md
│   ├── api-service/                     # ★ Future: Microservice
│   └── ml-training/                     # ★ Future: ML pipelines
├── config/
│   ├── optional-tools.json              # ★ CREATED (package bundles)
│   └── archetypes.json                  # ★ NEW (project templates)
├── scripts/
│   ├── create-project.sh                # ★ MODIFIED
│   └── (other scripts unchanged)
├── (rest of template unchanged)
```

### Archetype Metadata Format

**`archetypes/rag-project/__archetype__.json`:**
```json
{
  "name": "RAG Project",
  "description": "Retrieval-Augmented Generation system with semantic search",
  "version": "1.0.0",
  "author": "dev-environment-template",
  "category": "ai",
  "tags": ["rag", "semantic-search", "embeddings", "fastapi"],

  "dependencies": {
    "preset": "ai-agent",
    "additional_tools": ["opensearch", "ollama", "langfuse"],
    "python_version": "3.11+",
    "docker_compose_version": "3.8+"
  },

  "services": {
    "opensearch": {
      "image": "opensearchproject/opensearch:2.11.0",
      "ports": ["9200:9200"],
      "environment": {
        "discovery.type": "single-node",
        "OPENSEARCH_JAVA_OPTS": "-Xms512m -Xmx512m"
      }
    },
    "ollama": {
      "image": "ollama/ollama:latest",
      "ports": ["11434:11434"],
      "volumes": ["ollama_data:/root/.ollama"]
    }
  },

  "template_variables": {
    "PROJECT_NAME": "{{project_name}}",
    "API_PORT": "8000",
    "OPENSEARCH_HOST": "opensearch",
    "OLLAMA_HOST": "ollama"
  },

  "post_create_commands": [
    "pip install -e .",
    "python -m pytest --collect-only",
    "echo 'Run: make setup-opensearch to initialize search indices'"
  ],

  "documentation": {
    "quickstart": "README.md",
    "architecture": "docs/ARCHITECTURE.md",
    "deployment": "docs/DEPLOYMENT.md"
  },

  "example_project": "https://github.com/mazelb/arxiv-paper-curator",
  "reference_implementation": true
}
```

### Enhanced create-project.sh

**New Flow:**
```bash
./create-project.sh --name my-rag-app --archetype rag-project
    ↓
1. Validate archetype exists in archetypes/
    ↓
2. Load __archetype__.json metadata
    ↓
3. Create project directory: my-rag-app/
    ↓
4. Copy base template files (Dockerfile, .vscode, etc.)
    ↓
5. Copy archetype files (src/, tests/, docker/, etc.)
    ↓
6. Apply template variable substitution
    ↓
7. Install preset from archetype.dependencies.preset
    ↓
8. Add additional tools from archetype.dependencies.additional_tools
    ↓
9. Merge docker-compose services from archetype.services
    ↓
10. Run post_create_commands
    ↓
11. Initialize git repo
    ↓
12. Create ARCHETYPE_INFO.md with usage instructions
```

**Modified create-project.sh sections:**

```bash
# NEW: Archetype support
ARCHETYPES_DIR="$SCRIPT_DIR/archetypes"
ARCHETYPES_CONFIG="$SCRIPT_DIR/config/archetypes.json"
USE_ARCHETYPE=""

# NEW: List available archetypes
list_archetypes() {
    print_header "Available Project Archetypes"
    echo ""

    for archetype_dir in "$ARCHETYPES_DIR"/*/; do
        archetype=$(basename "$archetype_dir")
        [ "$archetype" = "base" ] && continue

        metadata_file="$archetype_dir/__archetype__.json"
        if [ -f "$metadata_file" ]; then
            name=$(jq -r '.name' "$metadata_file")
            desc=$(jq -r '.description' "$metadata_file")
            category=$(jq -r '.category' "$metadata_file")
            echo "  [$category] $archetype"
            echo "      $name - $desc"
            echo ""
        fi
    done
}

# NEW: Apply archetype to project
apply_archetype() {
    local project_path=$1
    local archetype=$2

    local archetype_path="$ARCHETYPES_DIR/$archetype"

    if [ ! -d "$archetype_path" ]; then
        print_error "Archetype not found: $archetype"
        exit 1
    fi

    print_header "Applying Archetype: $archetype"

    # Load metadata
    local metadata_file="$archetype_path/__archetype__.json"
    if [ ! -f "$metadata_file" ]; then
        print_error "Archetype metadata missing: __archetype__.json"
        exit 1
    fi

    # Copy archetype files
    print_info "Copying archetype structure..."
    rsync -av --exclude='__archetype__.json' \
        "$archetype_path/" "$project_path/"

    # Template variable substitution
    print_info "Applying template variables..."
    find "$project_path" -type f -name "*.py" -o -name "*.yml" -o -name "*.yaml" -o -name "*.json" -o -name "*.md" | while read file; do
        sed -i "s/{{project_name}}/$PROJECT_NAME/g" "$file"
        sed -i "s/{{PROJECT_NAME}}/${PROJECT_NAME^^}/g" "$file"
    done

    # Load dependencies
    local preset=$(jq -r '.dependencies.preset' "$metadata_file")
    if [ "$preset" != "null" ]; then
        USE_PRESET="$preset"
        print_info "Loading preset: $preset"
    fi

    local additional_tools=$(jq -r '.dependencies.additional_tools[]' "$metadata_file" 2>/dev/null)
    if [ -n "$additional_tools" ]; then
        OPTIONAL_TOOLS=($additional_tools)
        print_info "Additional tools: ${OPTIONAL_TOOLS[*]}"
    fi

    # Merge Docker Compose services
    local services=$(jq -r '.services' "$metadata_file")
    if [ "$services" != "null" ]; then
        print_info "Merging Docker services..."
        echo "$services" | jq '.' > "$project_path/docker-compose.archetype.yml"

        # Create merged docker-compose
        cat > "$project_path/docker-compose.override.yml" << EOF
# Auto-generated from archetype: $archetype
version: '3.8'

services:
$(echo "$services" | jq -r 'to_entries[] | "  \(.key):\n\(.value | to_entries[] | "    \(.key): \(.value | tostring)")"' | sed 's/^/  /')
EOF
    fi

    # Run post-create commands
    local post_commands=$(jq -r '.post_create_commands[]?' "$metadata_file")
    if [ -n "$post_commands" ]; then
        print_info "Running post-create commands..."
        cd "$project_path"
        echo "$post_commands" | while read cmd; do
            [ -n "$cmd" ] && eval "$cmd"
        done
        cd - > /dev/null
    fi

    # Create documentation
    cat > "$project_path/ARCHETYPE_INFO.md" << EOF
# Project Archetype: $archetype

This project was created using the **$archetype** archetype.

## Archetype Details

$(jq -r '
"**Name:** \(.name)\n" +
"**Description:** \(.description)\n" +
"**Version:** \(.version)\n" +
"**Category:** \(.category)\n" +
"\n## Services Included\n\n" +
(.services | to_entries[] | "- **\(.key)**: \(.value.image // "custom")")
' "$metadata_file")

## Quick Start

1. Start all services:
   \`\`\`bash
   docker-compose up -d
   \`\`\`

2. Install dependencies:
   \`\`\`bash
   pip install -e .
   \`\`\`

3. Run tests:
   \`\`\`bash
   pytest
   \`\`\`

4. See project README for more details.

## Reference Implementation

This archetype is based on: $(jq -r '.example_project // "N/A"' "$metadata_file")

## Documentation

$(jq -r '.documentation | to_entries[] | "- [\(.key | ascii_upcase)]: \(.value)"' "$metadata_file")

## Customization

Files prefixed with \`__template__\` are meant to be customized:
- Replace placeholder logic with your domain-specific code
- Update service configurations in \`docker/\`
- Modify environment variables in \`.env\`

EOF

    print_success "Archetype applied: $archetype"
}

# MODIFIED: Main function to support archetypes
main() {
    parse_args "$@"

    # Validate project name
    if [ -z "$PROJECT_NAME" ]; then
        print_error "Project name is required"
        show_help
        exit 1
    fi

    # Interactive mode (now includes archetypes)
    if [ "$INTERACTIVE" = true ]; then
        echo "1. Choose an archetype (or skip for base template)"
        list_archetypes
        read -p "Select archetype (or press Enter for base): " USE_ARCHETYPE
        echo ""

        if [ -z "$USE_ARCHETYPE" ]; then
            interactive_tool_selection
        fi
    fi

    # ... (existing project creation logic)

    # NEW: Apply archetype if selected
    if [ -n "$USE_ARCHETYPE" ]; then
        apply_archetype "$FULL_PROJECT_PATH" "$USE_ARCHETYPE"
    fi

    # Apply optional tools (if no archetype or additional tools)
    if [ ${#OPTIONAL_TOOLS[@]} -gt 0 ] || [ -n "$USE_PRESET" ]; then
        apply_optional_tools "$FULL_PROJECT_PATH"
    fi

    # ... (rest of existing logic)
}
```

### config/archetypes.json

```json
{
  "archetypes": {
    "rag-project": {
      "name": "RAG Project",
      "category": "ai",
      "tags": ["rag", "semantic-search", "embeddings"],
      "complexity": "intermediate",
      "learning_resources": [
        "https://docs.example.com/rag-tutorial",
        "https://github.com/mazelb/arxiv-paper-curator"
      ]
    },
    "agentic-project": {
      "name": "Agentic AI System",
      "category": "ai",
      "tags": ["agents", "multi-agent", "workflows"],
      "complexity": "advanced",
      "status": "coming-soon"
    },
    "api-service": {
      "name": "REST API Service",
      "category": "web",
      "tags": ["fastapi", "microservice", "rest"],
      "complexity": "beginner"
    }
  }
}
```

### config/optional-tools.json (CREATED)

```json
{
  "tools": {
    "docling": {
      "name": "Docling",
      "description": "Document understanding and parsing",
      "python_packages": ["docling>=1.0.0"],
      "config_files": {}
    },
    "llamaindex": {
      "name": "LlamaIndex",
      "description": "Data framework for LLM applications",
      "python_packages": ["llama-index>=0.9.0"],
      "config_files": {}
    },
    "fastapi": {
      "name": "FastAPI",
      "description": "Modern Python web framework",
      "python_packages": ["fastapi>=0.104.0", "uvicorn[standard]>=0.24.0"],
      "dockerfile_additions": ["EXPOSE 8000"],
      "config_files": {}
    },
    "opensearch": {
      "name": "OpenSearch",
      "description": "Search and analytics engine",
      "docker_compose_service": {
        "opensearch": {
          "image": "opensearchproject/opensearch:2.11.0",
          "environment": {
            "discovery.type": "single-node",
            "OPENSEARCH_JAVA_OPTS": "-Xms512m -Xmx512m",
            "DISABLE_SECURITY_PLUGIN": "true"
          },
          "ports": ["9200:9200"],
          "networks": ["dev-network"]
        }
      },
      "python_packages": ["opensearch-py>=2.3.0"],
      "volumes": ["opensearch_data"]
    },
    "ollama": {
      "name": "Ollama",
      "description": "Local LLM hosting",
      "docker_compose_service": {
        "ollama": {
          "image": "ollama/ollama:latest",
          "ports": ["11434:11434"],
          "volumes": ["ollama_data:/root/.ollama"],
          "networks": ["dev-network"]
        }
      },
      "python_packages": ["ollama>=0.1.0"]
    },
    "airflow": {
      "name": "Apache Airflow",
      "description": "Workflow orchestration",
      "docker_compose_service": {
        "airflow": {
          "image": "apache/airflow:2.7.3",
          "environment": {
            "AIRFLOW__CORE__EXECUTOR": "LocalExecutor",
            "AIRFLOW__DATABASE__SQL_ALCHEMY_CONN": "postgresql+psycopg2://devuser:devpass@postgres/airflow_db"
          },
          "ports": ["8080:8080"],
          "volumes": ["./airflow/dags:/opt/airflow/dags"],
          "networks": ["dev-network"],
          "depends_on": ["postgres"]
        }
      },
      "python_packages": ["apache-airflow>=2.7.0"]
    },
    "langfuse": {
      "name": "Langfuse",
      "description": "LLM observability and analytics",
      "python_packages": ["langfuse>=2.0.0"],
      "config_files": {}
    }
  },
  "presets": {
    "ai-agent": {
      "name": "AI Agent Development",
      "description": "Complete stack for building AI agents",
      "tools": ["langchain", "llamaindex", "langfuse", "postgresql", "docling"]
    },
    "rag-system": {
      "name": "RAG System",
      "description": "Retrieval-Augmented Generation infrastructure",
      "tools": ["opensearch", "ollama", "langchain", "fastapi", "langfuse"]
    },
    "web-fullstack": {
      "name": "Full-Stack Web",
      "description": "Complete web application stack",
      "tools": ["fastapi", "postgresql", "prometheus", "playwright"]
    }
  }
}
```

### Update Propagation

**How archetype updates propagate to existing projects:**

```bash
# In template repo: Update archetype
git tag -a v1.3.0 -m "rag-project archetype: Add caching layer"
git push origin v1.3.0

# In project repo: Sync archetype updates
./scripts/sync-template.sh --archetype-only
    ↓
Compares current archetype version with latest
    ↓
Shows diff of archetype changes
    ↓
User selectively merges changes (git cherry-pick style)
```

**Modified sync-template.sh:**
```bash
# NEW: Sync archetype updates
sync_archetype_updates() {
    local project_archetype=$(grep "archetype:" ARCHETYPE_INFO.md | cut -d: -f2 | xargs)

    if [ -z "$project_archetype" ]; then
        print_info "No archetype detected, skipping archetype sync"
        return
    fi

    print_header "Syncing Archetype: $project_archetype"

    # Fetch latest archetype
    temp_dir=$(mktemp -d)
    git clone "$TEMPLATE_REPO" "$temp_dir" --depth 1

    local archetype_path="$temp_dir/archetypes/$project_archetype"

    if [ ! -d "$archetype_path" ]; then
        print_error "Archetype no longer exists in template: $project_archetype"
        return
    fi

    # Show changes
    print_info "Comparing archetype versions..."
    diff -r -u \
        --exclude="__pycache__" \
        --exclude="*.pyc" \
        --exclude=".git" \
        . "$archetype_path" || true

    echo ""
    read -p "Apply archetype updates? (y/N) " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Selective merge (only template files)
        rsync -av \
            --exclude="*.pyc" \
            --exclude="__pycache__" \
            --include="**/__template__*" \
            --exclude="src/**" \
            "$archetype_path/" .

        print_success "Archetype updates applied"
    fi

    rm -rf "$temp_dir"
}
```

### Pros & Cons

**✅ Pros:**
1. **Extends existing system** - Builds on preset infrastructure
2. **Clear separation** - Template files vs. archetype files
3. **Scalable** - Easy to add new archetypes (agentic, ml-training, etc.)
4. **Backward compatible** - Existing projects unaffected
5. **Self-documenting** - Each archetype has metadata and README
6. **Version-controlled** - Archetypes evolve with template
7. **Reference implementations** - ArXiv-curator becomes living example
8. **Educational** - Users learn patterns from complete examples
9. **Flexible** - Can mix archetype + additional tools
10. **Update-friendly** - Selective sync for archetype changes

**❌ Cons:**
1. **Complexity increase** - More options to understand
2. **Maintenance overhead** - Each archetype needs updates
3. **Size increase** - Template repo grows (but still manageable)
4. **Potential confusion** - Users might not understand preset vs archetype
5. **Documentation burden** - Need guides for each archetype

### Maintenance Model

**Archetype Lifecycle:**
1. **Development** - Created in `archetypes/[name]` with `status: "draft"`
2. **Review** - Tested, documented, tagged `status: "beta"`
3. **Release** - Stable, promoted to `status: "stable"`
4. **Deprecation** - Marked `status: "deprecated"` but kept for 6 months
5. **Removal** - Deleted from repo, documented in CHANGELOG

**Who Maintains:**
- **Core archetypes** (rag-project, api-service): Template maintainers
- **Community archetypes**: Contributors via PR (reviewed for quality)
- **Private archetypes**: Organizations can fork and add internal ones

---

## 🔄 OPTION B: Template + Examples Repository

### Philosophy
"Template is a seed. Examples are gardens."

### Repository Structure

**Two Separate Repos:**

**Repo 1: `dev-environment-template`** (unchanged)
```
dev-environment-template/
├── .devcontainer/
├── .vscode/
├── scripts/
├── Dockerfile
├── docker-compose.yml
└── README.md (links to examples repo)
```

**Repo 2: `dev-environment-examples`** (new)
```
dev-environment-examples/
├── README.md                           # Gallery of examples
├── rag-project/                        # ★ ArXiv-curator
│   ├── src/
│   ├── tests/
│   ├── docker/
│   ├── Makefile
│   └── README.md (links back to template)
├── agentic-system/
│   ├── agents/
│   ├── workflows/
│   └── README.md
├── api-microservice/
│   └── README.md
├── ml-training-pipeline/
│   └── README.md
└── shared/                             # Common utilities
    ├── docker-configs/
    │   ├── opensearch-template.yml
    │   ├── ollama-template.yml
    │   └── airflow-template.yml
    └── python-packages/
        ├── common-settings/
        └── test-fixtures/
```

### Workflow

**Creating a RAG project:**

```bash
# Step 1: Create base project from template
git clone https://github.com/mazelb/dev-environment-template.git my-rag-app
cd my-rag-app
rm -rf .git
git init

# Step 2: Clone examples for reference
git clone https://github.com/mazelb/dev-environment-examples.git .examples
cd .examples/rag-project

# Step 3: Copy what you need
cp -r src/ ../../src/
cp -r tests/ ../../tests/
cp docker/opensearch.yml ../../docker-compose.override.yml
cp Makefile ../../Makefile

# Step 4: Customize
# Edit files, remove .examples directory
cd ../..
rm -rf .examples

# Step 5: Start developing
docker-compose up -d
```

### Linking Strategy

**Template README adds:**
```markdown
## Example Projects

See complete project implementations built with this template:

- **[RAG System](https://github.com/mazelb/dev-environment-examples/tree/main/rag-project)** - Semantic search with OpenSearch + Ollama
- **[Agentic AI](https://github.com/mazelb/dev-environment-examples/tree/main/agentic-system)** - Multi-agent orchestration
- **[API Service](https://github.com/mazelb/dev-environment-examples/tree/main/api-microservice)** - Production-ready FastAPI microservice

Browse all: [Dev Environment Examples](https://github.com/mazelb/dev-environment-examples)
```

**Each Example README adds:**
```markdown
## Prerequisites

This project uses the [Dev Environment Template](https://github.com/mazelb/dev-environment-template).

### Quick Start

1. Clone the template:
   ```bash
   git clone https://github.com/mazelb/dev-environment-template.git my-project
   ```

2. Copy this example:
   ```bash
   cp -r path/to/this/example/* my-project/
   ```

3. Follow setup instructions below.
```

### Pros & Cons

**✅ Pros:**
1. **Complete separation** - Template stays minimal and focused
2. **Independent evolution** - Examples can change without affecting template
3. **Lower cognitive load** - Choose template OR example, not both
4. **Clear responsibility** - Template maintainers vs. example contributors
5. **Easier to browse** - Examples repo is pure showcase
6. **No template bloat** - Template stays lightweight
7. **Community contributions** - Easier to accept example PRs
8. **Multiple versions** - Examples can target different template versions

**❌ Cons:**
1. **Manual copy-paste** - No automated scaffolding
2. **Discovery problem** - Users might not find examples
3. **Sync challenges** - Examples can drift from template
4. **No automation** - Can't run `create-project.sh --archetype rag`
5. **Documentation fragmentation** - Need to maintain both repos
6. **Version mismatches** - Example might use old template version
7. **Less cohesive** - Feels like separate projects
8. **Update complexity** - Two repos to keep in sync

### Maintenance Model

**Examples Repo Governance:**
- Each example has `MAINTAINER.md` listing owners
- Examples require: README, tests, Docker configs, working demo
- CI/CD runs tests for each example
- Template compatibility matrix (which example works with which template version)

**Update Workflow:**
```bash
# Template releases new version
dev-environment-template v2.0.0

# Examples updated to match
dev-environment-examples/rag-project → Updated for template v2.0.0
dev-environment-examples/api-service → Updated for template v2.0.0
```

---

## 🧩 OPTION C: Template with Optional Components

### Philosophy
"Lego blocks, not blueprints."

### Directory Structure

```
dev-environment-template/
├── components/                         # ★ NEW
│   ├── README.md
│   ├── fastapi-structure/
│   │   ├── install.sh
│   │   ├── api/
│   │   │   ├── routers/
│   │   │   ├── dependencies.py
│   │   │   └── main.py
│   │   ├── tests/
│   │   └── README.md
│   ├── opensearch-service/
│   │   ├── install.sh
│   │   ├── docker-compose.opensearch.yml
│   │   ├── config/
│   │   │   └── opensearch.yml
│   │   ├── init-scripts/
│   │   │   └── create_indices.py
│   │   └── README.md
│   ├── ollama-service/
│   │   ├── install.sh
│   │   ├── docker-compose.ollama.yml
│   │   ├── models/
│   │   │   └── download_models.sh
│   │   └── README.md
│   ├── airflow-workflows/
│   │   ├── install.sh
│   │   ├── docker-compose.airflow.yml
│   │   ├── dags/
│   │   │   └── example_dag.py
│   │   └── README.md
│   ├── pydantic-settings/
│   │   ├── install.sh
│   │   ├── config/
│   │   │   ├── settings.py
│   │   │   └── .env.example
│   │   └── README.md
│   ├── testing-infrastructure/
│   │   ├── install.sh
│   │   ├── pytest.ini
│   │   ├── conftest.py
│   │   ├── tests/
│   │   │   ├── unit/
│   │   │   └── integration/
│   │   └── README.md
│   ├── langfuse-tracing/
│   │   ├── install.sh
│   │   ├── utils/
│   │   │   └── tracing.py
│   │   └── README.md
│   └── makefile-commands/
│       ├── install.sh
│       ├── Makefile.components
│       └── README.md
├── recipes/                            # ★ NEW (component combinations)
│   ├── rag-system.recipe.json
│   ├── agentic-ai.recipe.json
│   └── api-service.recipe.json
├── config/
│   └── components.json                # Component metadata
├── scripts/
│   ├── create-project.sh              # ★ MODIFIED
│   ├── add-component.sh               # ★ NEW
│   └── list-components.sh             # ★ NEW
└── (rest unchanged)
```

### Component Metadata

**`components/opensearch-service/component.json`:**
```json
{
  "name": "OpenSearch Service",
  "id": "opensearch-service",
  "version": "1.0.0",
  "category": "infrastructure",
  "description": "OpenSearch cluster with Python client integration",

  "dependencies": {
    "requires": [],
    "recommends": ["pydantic-settings"],
    "conflicts": ["elasticsearch-service"]
  },

  "files": {
    "docker-compose.opensearch.yml": "docker-compose.opensearch.yml",
    "config/opensearch.yml": "config/opensearch.yml",
    "init-scripts/create_indices.py": "scripts/opensearch_init.py"
  },

  "install_steps": [
    "copy_files",
    "merge_docker_compose",
    "add_python_package: opensearch-py>=2.3.0",
    "create_volume: opensearch_data",
    "run_script: scripts/opensearch_init.py"
  ],

  "configuration": {
    "env_vars": {
      "OPENSEARCH_HOST": "opensearch",
      "OPENSEARCH_PORT": "9200",
      "OPENSEARCH_USER": "admin",
      "OPENSEARCH_PASSWORD": "admin"
    }
  },

  "documentation": "components/opensearch-service/README.md",
  "example_usage": "components/opensearch-service/examples/"
}
```

### Recipe Format

**`recipes/rag-system.recipe.json`:**
```json
{
  "name": "RAG System",
  "description": "Complete RAG system with semantic search and embeddings",
  "version": "1.0.0",

  "components": [
    "fastapi-structure",
    "opensearch-service",
    "ollama-service",
    "pydantic-settings",
    "testing-infrastructure",
    "langfuse-tracing",
    "makefile-commands"
  ],

  "install_order": [
    "pydantic-settings",
    "fastapi-structure",
    "opensearch-service",
    "ollama-service",
    "langfuse-tracing",
    "testing-infrastructure",
    "makefile-commands"
  ],

  "post_install_instructions": [
    "Update config/settings.py with your API keys",
    "Run: make setup-opensearch",
    "Run: make download-models",
    "Start services: docker-compose up -d"
  ],

  "reference_implementation": "https://github.com/mazelb/arxiv-paper-curator"
}
```

### Component Installation System

**New script: `scripts/add-component.sh`:**
```bash
#!/bin/bash

COMPONENT_NAME=$1
COMPONENT_DIR="components/$COMPONENT_NAME"

if [ ! -d "$COMPONENT_DIR" ]; then
    echo "Error: Component not found: $COMPONENT_NAME"
    exit 1
fi

# Load component metadata
METADATA="$COMPONENT_DIR/component.json"
component_id=$(jq -r '.id' "$METADATA")

# Check dependencies
requires=$(jq -r '.dependencies.requires[]?' "$METADATA")
for dep in $requires; do
    if [ ! -f ".installed_components/$dep" ]; then
        echo "Installing dependency: $dep"
        ./scripts/add-component.sh "$dep"
    fi
done

# Run installation
if [ -f "$COMPONENT_DIR/install.sh" ]; then
    bash "$COMPONENT_DIR/install.sh"
else
    # Default installation
    cp -r "$COMPONENT_DIR"/* .
fi

# Mark as installed
mkdir -p .installed_components
touch ".installed_components/$component_id"

echo "✓ Component installed: $COMPONENT_NAME"
```

### Enhanced create-project.sh

```bash
./create-project.sh --name my-app --recipe rag-system
    ↓
1. Create project directory
    ↓
2. Copy base template
    ↓
3. Load recipe: rag-system.recipe.json
    ↓
4. For each component in recipe.install_order:
    - Run add-component.sh [component]
    - Merge files
    - Update configs
    ↓
5. Run post_install_instructions
    ↓
6. Create COMPONENTS.md listing installed components
```

### Usage Examples

**Install individual components:**
```bash
# Create base project
./create-project.sh --name my-app

# Add components incrementally
cd my-app
../scripts/add-component.sh fastapi-structure
../scripts/add-component.sh opensearch-service
../scripts/add-component.sh testing-infrastructure
```

**Use recipe (component bundle):**
```bash
# Create with pre-defined component set
./create-project.sh --name my-rag-app --recipe rag-system
```

**Mix and match:**
```bash
# Start with recipe, add more
./create-project.sh --name my-app --recipe api-service
cd my-app
../scripts/add-component.sh langfuse-tracing
../scripts/add-component.sh prometheus-metrics
```

### Pros & Cons

**✅ Pros:**
1. **Maximum flexibility** - Users compose exactly what they need
2. **Incremental adoption** - Add components to existing projects
3. **Reusable pieces** - Components work independently
4. **Easy updates** - Update single components
5. **No boilerplate** - Only install what you use
6. **Learning curve** - Users discover features gradually
7. **Community contributions** - Easy to add new components
8. **Version control** - Each component has its own version

**❌ Cons:**
1. **Fragmentation risk** - Components might drift apart
2. **Dependency complexity** - Hard to manage component interdependencies
3. **No cohesive examples** - No full project reference
4. **Integration burden** - User must understand how pieces fit
5. **Testing complexity** - Need to test all component combinations
6. **Documentation explosion** - Each component needs docs
7. **Overwhelming choice** - Users paralyzed by options
8. **ArXiv-curator dismantled** - No intact reference implementation

### Maintenance Model

**Component Ownership:**
- Each component has `MAINTAINER` in component.json
- Components follow semantic versioning
- Breaking changes increment major version
- Components tested independently and in recipes

**Quality Standards:**
- Must have: README, tests, example usage
- Must specify: dependencies, conflicts
- Must provide: install.sh, uninstall.sh
- Must document: configuration options

---

## 5. Recommended Approach

### 🏆 Winner: **Option A - Template with Project Archetypes**

### Justification

After analyzing all options against key criteria:

| Criteria | Option A | Option B | Option C |
|----------|----------|----------|----------|
| **Ease of Use** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| **Maintains ArXiv-Curator Integrity** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ |
| **Scalability** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Maintenance Burden** | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ |
| **Update Propagation** | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ |
| **Learning Curve** | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| **Template Bloat** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Community Contribution** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Total** | **32/40** | **30/40** | **21/40** |

### Why Option A Wins

**1. Best User Experience**
```bash
# Simple, discoverable, automated
./create-project.sh --name my-rag-app --archetype rag-project
# Done! Complete working project in one command.
```

**2. Preserves ArXiv-Curator as Complete Reference**
- Entire project structure intact
- Users see full working implementation
- Can study end-to-end architecture
- Easy to derive custom projects

**3. Extends Existing Infrastructure**
- Builds on current preset system
- Minimal breaking changes
- Familiar patterns for users
- Reuses sync-template.sh logic

**4. Scalable Growth Path**
- Start with rag-project archetype
- Add agentic-project next quarter
- Add ml-training-pipeline later
- Community can contribute archetypes

**5. Update-Friendly**
- Archetypes evolve with template
- Selective sync for existing projects
- Version-controlled and tagged
- Clear changelog per archetype

### When to Use Other Options

**Use Option B (Examples Repo) if:**
- Template maintainers want minimal responsibility
- Examples are highly experimental
- Different teams maintain template vs examples
- Examples target multiple template versions

**Use Option C (Components) if:**
- Users need maximum customization
- No single reference project needed
- Team has strong DevOps culture
- Incremental adoption is critical

---

## 6. Migration Path

### Phase 1: Foundation (Week 1-2)

**Goal:** Set up archetype infrastructure

**Tasks:**
1. ✅ Create `config/optional-tools.json` with current tools
2. ✅ Create `config/archetypes.json` for registry
3. ✅ Create `archetypes/` directory structure
4. ✅ Create `archetypes/base/` minimal starter
5. ✅ Document archetype system in `archetypes/README.md`
6. ✅ Update `create-project.sh` with archetype support
7. ✅ Test archetype system with base archetype

**Deliverables:**
- Working archetype system
- Documentation
- Tests

### Phase 2: RAG Archetype (Week 3-4)

**Goal:** Migrate arxiv-paper-curator to rag-project archetype

**Tasks:**
1. ✅ Create `archetypes/rag-project/` directory
2. ✅ Create `__archetype__.json` metadata
3. ✅ Copy ArXiv-curator structure:
   - `src/api/` (FastAPI structure)
   - `src/services/` (as `__template__*` files)
   - `src/models/` (base schemas)
   - `docker/` (OpenSearch, Ollama configs)
   - `tests/` (test structure)
   - `config/` (Pydantic settings)
   - `Makefile`
   - `pyproject.toml`
4. ✅ Templatize variables ({{project_name}}, etc.)
5. ✅ Write comprehensive README for archetype
6. ✅ Test: Create new project from archetype
7. ✅ Validate: Services start, tests pass

**File Transformations:**

**From ArXiv-Curator:**
```python
# src/services/arxiv_client.py
class ArxivClient:
    def __init__(self, config: Settings):
        self.api_url = "http://export.arxiv.org/api/query"
        # ArXiv-specific logic
```

**To Archetype Template:**
```python
# archetypes/rag-project/src/services/__template__data_client.py
"""
Template data client for RAG systems.
Replace this with your domain-specific data source.

Examples:
- ArXiv API (papers)
- Product catalog (e-commerce)
- Documentation pages (internal docs)
"""

class DataClient:
    def __init__(self, config: Settings):
        self.api_url = config.DATA_SOURCE_URL
        # TODO: Implement your data fetching logic

    async def fetch_documents(self, query: str) -> List[Document]:
        """Fetch documents from your data source."""
        raise NotImplementedError("Replace with your data fetching logic")
```

**Deliverables:**
- Complete rag-project archetype
- Documentation
- Working example project

### Phase 3: Documentation & Polish (Week 5)

**Goal:** Comprehensive documentation and examples

**Tasks:**
1. ✅ Update main README with archetype feature
2. ✅ Create `docs/ARCHETYPES_GUIDE.md`
3. ✅ Update `docs/USAGE_GUIDE.md` with archetype workflows
4. ✅ Create video tutorial (optional)
5. ✅ Write migration guide for existing ArXiv-curator users
6. ✅ Create blog post announcing feature

**Deliverables:**
- Complete documentation
- Migration guide
- Announcement materials

### Phase 4: Future Archetypes (Ongoing)

**Goal:** Expand archetype library

**Planned Archetypes:**
1. **agentic-project** (Q1 2026)
   - Multi-agent orchestration
   - Workflow definitions
   - Agent communication patterns

2. **api-service** (Q1 2026)
   - Production-ready FastAPI
   - Authentication/authorization
   - Rate limiting
   - Monitoring

3. **ml-training** (Q2 2026)
   - Model training pipelines
   - Experiment tracking
   - MLflow integration

4. **data-pipeline** (Q2 2026)
   - ETL workflows
   - Data validation
   - Airflow DAGs

---

## Appendix: Template-Worthy Components from ArXiv-Curator

### High Priority (Include in rag-project archetype)

**1. Pydantic Settings Pattern**
```python
# config/settings.py
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    # API Configuration
    API_HOST: str = "0.0.0.0"
    API_PORT: int = 8000

    # OpenSearch
    OPENSEARCH_HOST: str = "opensearch"
    OPENSEARCH_PORT: int = 9200

    # Ollama
    OLLAMA_HOST: str = "ollama"
    OLLAMA_PORT: int = 11434
    OLLAMA_MODEL: str = "llama2"

    # Langfuse
    LANGFUSE_PUBLIC_KEY: str = ""
    LANGFUSE_SECRET_KEY: str = ""
    LANGFUSE_HOST: str = "https://cloud.langfuse.com"

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
```

**2. FastAPI Project Structure**
```
src/api/
├── __init__.py
├── main.py                 # FastAPI app initialization
├── dependencies.py         # DI container
└── routers/
    ├── __init__.py
    ├── health.py           # Health check endpoints
    ├── search.py           # Search endpoints
    └── documents.py        # Document management
```

**3. Docker Service Configs**
```yaml
# docker/opensearch.yml
opensearch:
  image: opensearchproject/opensearch:2.11.0
  environment:
    discovery.type: single-node
    OPENSEARCH_JAVA_OPTS: -Xms512m -Xmx512m
    DISABLE_SECURITY_PLUGIN: true
  ports:
    - "9200:9200"
  volumes:
    - opensearch_data:/usr/share/opensearch/data
```

**4. Testing Infrastructure**
```python
# tests/conftest.py
import pytest
from fastapi.testclient import TestClient
from src.api.main import app

@pytest.fixture
def client():
    return TestClient(app)

@pytest.fixture
def mock_opensearch():
    # Mock OpenSearch client
    pass
```

**5. Makefile Commands**
```makefile
.PHONY: run test lint format

run:
	uvicorn src.api.main:app --reload --host 0.0.0.0 --port 8000

test:
	pytest tests/ -v --cov=src

lint:
	pylint src/ tests/
	mypy src/

format:
	black src/ tests/
	isort src/ tests/
```

### Medium Priority (Documentation/examples)

**6. Langfuse Tracing Setup**
**7. Async Service Patterns**
**8. Caching with Redis**
**9. API Rate Limiting**
**10. Document Chunking Strategies**

### Low Priority (Project-specific, don't include)

**11. ArXiv API specifics**
**12. Paper metadata schemas**
**13. Citation parsing**

---

## Next Steps

**Immediate Action Required:**

1. **Decision:** Approve Option A (or suggest modifications)
2. **Create:** `config/optional-tools.json` with full tool definitions
3. **Implement:** Enhanced `create-project.sh` with archetype support
4. **Migrate:** ArXiv-curator to `archetypes/rag-project/`
5. **Test:** Create sample project: `./create-project.sh --name test-rag --archetype rag-project`
6. **Document:** Write `docs/ARCHETYPES_GUIDE.md`
7. **Release:** Tag template v2.0.0 with archetype feature

**Timeline:** 4-5 weeks for complete implementation

**Questions to Resolve:**

1. Should archetypes be in main template repo or separate `dev-environment-archetypes` repo?
2. How many archetypes to include at launch? (Just rag-project or add 2-3 more?)
3. Should we support custom archetype repositories (like `--archetype-repo https://...`)?
4. Versioning strategy: Do archetypes have independent versions or follow template version?
5. Community contribution model: Who can submit archetypes? What's the review process?

---

**End of Report**
