# Implementation Strategy: Multi-Archetype System with Git/GitHub Integration

**Version:** 1.0
**Date:** November 19, 2025
**Status:** Ready to Execute
**Estimated Timeline:** 8-10 weeks

---

## Executive Summary

This document provides a comprehensive, step-by-step implementation strategy for transforming the dev-environment-template into a multi-archetype project generator with automatic Git repository initialization and optional GitHub integration.

**Goal:** Enable single-command creation of production-ready projects with independent Git repositories.

**Success Criteria:**

- ✅ One command creates complete, working project
- ✅ Automatic Git initialization (no manual steps)
- ✅ Optional GitHub repository creation
- ✅ Multi-archetype composition support
- ✅ Complete independence from template repository
- ✅ ~60 second project creation time

---

## Implementation Phases Overview

| Phase | Focus | Duration | Priority |
|-------|-------|----------|----------|
| **Phase 1** | Foundation & Infrastructure | 2 weeks | Critical |
| **Phase 2** | Git Integration | 1 week | Critical |
| **Phase 3** | Multi-Archetype Core | 2 weeks | High |
| **Phase 4** | File Merging System | 2 weeks | High |
| **Phase 5** | GitHub Integration | 1 week | Medium |
| **Phase 6** | Archetypes Creation | 2 weeks | Medium |
| **Phase 7** | Testing & Polish | 1-2 weeks | High |

**Total:** 8-10 weeks for complete implementation

---

## Phase 1: Foundation & Infrastructure (Week 1-2)

### Overview

Set up the core archetype system infrastructure including metadata schemas, directory structure, and basic loading mechanisms.

### Todos

#### 1.1 Create Configuration Directory Structure

- [ ] **Task:** Create `config/` directory in template root

  ```bash
  mkdir -p config
  ```

- [ ] **Task:** Create `config/optional-tools.json` with current tools
  - Extract from `create-project.sh` lines 92-104 (presets)
  - Add tool definitions with metadata
  - Include Docker service configurations
- [ ] **Task:** Create `config/archetypes.json` registry
  - List of available archetypes
  - Compatibility matrix
  - Version tracking
- [ ] **Deliverable:** `config/` directory with JSON configuration files
- [ ] **Test:** Validate JSON files with `jq` or JSON validator

#### 1.2 Create Archetypes Directory Structure

- [ ] **Task:** Create `archetypes/` directory in template root

  ```bash
  mkdir -p archetypes/{base,rag-project}
  ```

- [ ] **Task:** Create `archetypes/README.md` with system documentation
  - What are archetypes
  - How to use them
  - How to create custom archetypes
- [ ] **Deliverable:** `archetypes/` directory structure
- [ ] **Test:** Verify directory structure exists

#### 1.3 Define Archetype Metadata Schema

- [ ] **Task:** Create `archetypes/__archetype_schema__.json` defining metadata format

  ```json
  {
    "version": "2.0",
    "metadata": { ... },
    "composition": { ... },
    "dependencies": { ... },
    "conflicts": { ... },
    "services": { ... }
  }
  ```

- [ ] **Task:** Document all fields and their purposes
- [ ] **Deliverable:** Schema definition file
- [ ] **Test:** Validate schema is valid JSON

#### 1.4 Create Base Archetype

- [ ] **Task:** Create `archetypes/base/__archetype__.json`
  - Minimal starter archetype
  - No services, just structure
  - Role: "base"
- [ ] **Task:** Create minimal directory structure in `archetypes/base/`

  ```
  base/
  ├── __archetype__.json
  ├── src/
  ├── tests/
  ├── docs/
  └── README.md
  ```

- [ ] **Deliverable:** Working base archetype
- [ ] **Test:** Load metadata and validate against schema

#### 1.5 Create Archetype Loader Script

- [ ] **Task:** Create `scripts/archetype-loader.sh`

  ```bash
  #!/bin/bash

  load_archetype() {
      local archetype_name=$1
      # Load __archetype__.json
      # Validate against schema
      # Return parsed data
  }

  validate_archetype() {
      # Check required fields
      # Validate version format
      # Check file references exist
  }
  ```

- [ ] **Task:** Implement JSON parsing with `jq`
- [ ] **Task:** Add validation logic
- [ ] **Task:** Add error handling
- [ ] **Deliverable:** `scripts/archetype-loader.sh`
- [ ] **Test:** Load base archetype successfully

#### 1.6 Update create-project.sh Structure

- [ ] **Task:** Add archetype-related variables to `create-project.sh`

  ```bash
  BASE_ARCHETYPE=""
  FEATURE_ARCHETYPES=()
  ARCHETYPES_DIR="$SCRIPT_DIR/archetypes"
  USE_ARCHETYPE=false
  ```

- [ ] **Task:** Add source for archetype-loader.sh

  ```bash
  source "$SCRIPT_DIR/scripts/archetype-loader.sh"
  ```

- [ ] **Task:** Add `--archetype` flag to argument parser
- [ ] **Task:** Add `--list-archetypes` flag implementation
- [ ] **Deliverable:** Updated `create-project.sh` with archetype support
- [ ] **Test:** Run `--list-archetypes` and see base archetype

### Phase 1 Success Criteria

- [ ] `config/` directory with JSON files exists
- [ ] `archetypes/` directory structure in place
- [ ] Base archetype loads successfully
- [ ] `--list-archetypes` shows available archetypes
- [ ] No breaking changes to existing functionality

---

## Phase 2: Git Integration (Week 3)

### Overview

Implement automatic Git repository initialization for every project with smart commit messages.

### Todos

#### 2.1 Remove Conditional Git Initialization

- [ ] **Task:** Update `create-project.sh` to initialize Git by default
  - Current: `if [ "$USE_GIT" = true ]; then git init; fi`
  - New: Git initialization happens automatically
- [ ] **Task:** Remove `--git` flag from CLI (no longer needed)
- [ ] **Task:** Add `--no-git` flag for opt-out

  ```bash
  --no-git)
      SKIP_GIT=true
      shift
      ;;
  ```

- [ ] **Deliverable:** Updated flag handling in `create-project.sh`
- [ ] **Test:** Create project, verify `.git/` exists

#### 2.2 Implement Smart Commit Message Generator

- [ ] **Task:** Create `scripts/git-helper.sh`

  ```bash
  #!/bin/bash

  generate_commit_message() {
      local project_name=$1
      local archetypes=$2

      cat << EOF
  Initial commit: $project_name

  Archetypes:
  $(list_archetypes_with_versions "$archetypes")

  Services:
  $(list_services_from_archetypes "$archetypes")

  Generated by dev-environment-template v$(get_template_version)
  EOF
  }
  ```

- [ ] **Task:** Implement `list_archetypes_with_versions()`
- [ ] **Task:** Implement `list_services_from_archetypes()`
- [ ] **Task:** Implement `get_template_version()` (read from VERSION file or git tag)
- [ ] **Deliverable:** `scripts/git-helper.sh`
- [ ] **Test:** Generate commit message and verify format

#### 2.3 Implement Git Initialization Function

- [ ] **Task:** Create `initialize_git_repository()` in `scripts/git-helper.sh`

  ```bash
  initialize_git_repository() {
      local project_path=$1
      local project_name=$2
      local archetypes=$3

      cd "$project_path"

      git init
      print_success "Git initialized"

      git add .

      local commit_msg=$(generate_commit_message "$project_name" "$archetypes")
      git commit -m "$commit_msg"
      print_success "Initial commit created"

      cd - > /dev/null
  }
  ```

- [ ] **Task:** Add error handling for git command failures
- [ ] **Task:** Check if git is installed before proceeding
- [ ] **Deliverable:** Git initialization function
- [ ] **Test:** Initialize git in test project

#### 2.4 Generate Smart .gitignore

- [ ] **Task:** Create `scripts/gitignore-generator.sh`

  ```bash
  generate_gitignore() {
      local archetypes=$1
      local output_file=$2

      # Base patterns
      cat base_gitignore_template > "$output_file"

      # Archetype-specific patterns
      for archetype in $archetypes; do
          append_archetype_patterns "$archetype" "$output_file"
      done
  }
  ```

- [ ] **Task:** Create base `.gitignore` template in `templates/`
- [ ] **Task:** Add archetype-specific patterns to archetype metadata

  ```json
  {
    "gitignore_patterns": [
      "opensearch-data/",
      "ollama-data/",
      "*.parquet"
    ]
  }
  ```

- [ ] **Deliverable:** Smart `.gitignore` generator
- [ ] **Test:** Generate .gitignore for rag-project

#### 2.5 Integrate Git Initialization into Main Flow

- [ ] **Task:** Update main() function in `create-project.sh`

  ```bash
  # After project creation and file copying

  if [ "$SKIP_GIT" != true ]; then
      source "$SCRIPT_DIR/scripts/git-helper.sh"
      initialize_git_repository "$FULL_PROJECT_PATH" "$PROJECT_NAME" "$ALL_ARCHETYPES"
  fi
  ```

- [ ] **Task:** Update help text to reflect automatic git initialization
- [ ] **Task:** Update success message to mention git repository
- [ ] **Deliverable:** Integrated Git initialization
- [ ] **Test:** Create project and verify initial commit exists

### Phase 2 Success Criteria

- [ ] Every new project has `.git/` directory
- [ ] Initial commit includes all files
- [ ] Commit message includes archetype metadata
- [ ] `.gitignore` is comprehensive and archetype-aware
- [ ] `--no-git` flag works correctly

---

## Phase 3: Multi-Archetype Core (Week 4-5)

### Overview

Implement the core multi-archetype composition system with conflict detection and resolution.

### Todos

#### 3.1 Create Conflict Detection System

- [ ] **Task:** Create `scripts/conflict-resolver.sh`

  ```bash
  #!/bin/bash

  detect_port_conflicts() {
      local base_archetype=$1
      shift
      local feature_archetypes=("$@")

      # Extract ports from each archetype
      # Find intersections
      # Return list of conflicts
  }

  detect_service_name_conflicts() {
      # Similar logic for service names
  }

  detect_dependency_conflicts() {
      # Check Python package version conflicts
  }
  ```

- [ ] **Task:** Implement port conflict detection
- [ ] **Task:** Implement service name conflict detection
- [ ] **Task:** Implement dependency conflict detection
- [ ] **Deliverable:** `scripts/conflict-resolver.sh`
- [ ] **Test:** Detect conflicts between test archetypes

#### 3.2 Implement Port Offset Resolver

- [ ] **Task:** Create `resolve_port_conflicts()` function

  ```bash
  resolve_port_conflicts() {
      local feature_archetype=$1
      local offset=$2

      # Apply offset to all external ports in docker-compose
      # Keep internal ports unchanged
  }
  ```

- [ ] **Task:** Use `yq` or `jq` to modify YAML/JSON
- [ ] **Task:** Update environment variables with new ports
- [ ] **Deliverable:** Port offset resolver
- [ ] **Test:** Apply offset to test docker-compose file

#### 3.3 Implement Service Name Prefixing

- [ ] **Task:** Create `apply_service_prefix()` function

  ```bash
  apply_service_prefix() {
      local archetype=$1
      local prefix=$2

      # Rename all services with prefix
      # Update all service references
      # Update environment variables
  }
  ```

- [ ] **Task:** Handle service name references in configs
- [ ] **Task:** Update depends_on relationships
- [ ] **Deliverable:** Service name prefixing
- [ ] **Test:** Prefix services in test docker-compose

#### 3.4 Add Multi-Archetype CLI Flags

- [ ] **Task:** Add `--add-features` flag to `create-project.sh`

  ```bash
  --add-features)
      IFS=',' read -ra FEATURE_ARCHETYPES <<< "$2"
      shift 2
      ;;
  ```

- [ ] **Task:** Validate feature archetypes exist
- [ ] **Task:** Check compatibility with base archetype
- [ ] **Deliverable:** Multi-archetype CLI support
- [ ] **Test:** Parse multiple features from command line

#### 3.5 Implement Archetype Composition Logic

- [ ] **Task:** Create `compose_archetypes()` function

  ```bash
  compose_archetypes() {
      local base=$1
      shift
      local features=("$@")

      # 1. Load base archetype
      load_archetype "$base"

      # 2. For each feature:
      for feature in "${features[@]}"; do
          load_archetype "$feature"

          # 3. Detect conflicts
          detect_conflicts "$base" "$feature"

          # 4. Resolve conflicts
          resolve_conflicts "$feature"
      done

      # 5. Merge all archetypes
      merge_archetypes "$base" "${features[@]}"
  }
  ```

- [ ] **Task:** Implement each step
- [ ] **Task:** Add progress indicators
- [ ] **Deliverable:** Archetype composition system
- [ ] **Test:** Compose base + 1 feature archetype

#### 3.6 Implement Compatibility Checking

- [ ] **Task:** Create `check_compatibility()` function

  ```bash
  check_compatibility() {
      local base=$1
      local feature=$2

      # Read compatible_features from base
      # Read compatible_bases from feature
      # Check if they're compatible
  }
  ```

- [ ] **Task:** Add `--check-compatibility` flag
- [ ] **Task:** Display compatibility report
- [ ] **Deliverable:** Compatibility checker
- [ ] **Test:** Check various archetype combinations

### Phase 3 Success Criteria

- [ ] Can detect port conflicts between archetypes
- [ ] Can apply port offsets automatically
- [ ] Can prefix service names to avoid collisions
- [ ] `--add-features` flag works
- [ ] Compatibility checking prevents incompatible combinations

---

## Phase 4: File Merging System (Week 6-7)

### Overview

Implement intelligent file merging for configuration files, Docker Compose, Makefiles, and source code.

### Todos

#### 4.1 Create Docker Compose Merger

- [ ] **Task:** Create `scripts/docker-compose-merger.sh`

  ```bash
  merge_docker_compose_files() {
      local base_file=$1
      local feature_files=("${@:2}")

      # Create layered docker-compose structure
      # docker-compose.yml (base)
      # docker-compose.rag.yml (rag archetype)
      # docker-compose.agentic.yml (agentic archetype)
  }
  ```

- [ ] **Task:** Use `yq` for YAML manipulation
- [ ] **Task:** Apply service prefixes
- [ ] **Task:** Apply port offsets
- [ ] **Task:** Merge volumes and networks
- [ ] **Deliverable:** `scripts/docker-compose-merger.sh`
- [ ] **Test:** Merge 2 docker-compose files

#### 4.2 Create .env File Merger

- [ ] **Task:** Create `scripts/env-merger.sh`

  ```bash
  merge_env_files() {
      local base_env=$1
      local feature_envs=("${@:2}")
      local output_file=$3

      # Section-based merging
      # [BASE]
      # BASE_VAR=value
      #
      # [FEATURE1]
      # FEATURE1_VAR=value
  }
  ```

- [ ] **Task:** Add section headers for clarity
- [ ] **Task:** Deduplicate variables
- [ ] **Task:** Handle conflicts (warn user)
- [ ] **Deliverable:** `scripts/env-merger.sh`
- [ ] **Test:** Merge multiple .env files

#### 4.3 Create Makefile Merger

- [ ] **Task:** Create `scripts/makefile-merger.sh`

  ```bash
  merge_makefiles() {
      local base_makefile=$1
      local feature_makefiles=("${@:2}")
      local output_file=$3

      # Namespace targets with archetype prefix
      # rag-run, rag-test, agentic-run, agentic-test
      # Create composite targets: run, test
  }
  ```

- [ ] **Task:** Parse and namespace targets
- [ ] **Task:** Create composite targets
- [ ] **Task:** Preserve PHONY declarations
- [ ] **Deliverable:** `scripts/makefile-merger.sh`
- [ ] **Test:** Merge Makefiles with namespace

#### 4.4 Create Source File Smart Merger

- [ ] **Task:** Create `scripts/source-file-merger.sh`

  ```bash
  merge_fastapi_main() {
      local base_main=$1
      local feature_mains=("${@:2}")
      local output_file=$3

      # Merge imports
      # Merge router includes
      # Add prefix to routes
  }
  ```

- [ ] **Task:** Implement FastAPI main.py merger
- [ ] **Task:** Add patterns for other frameworks (Express, Flask)
- [ ] **Task:** Use AST parsing if available (Python: `ast` module)
- [ ] **Deliverable:** Source file merger
- [ ] **Test:** Merge FastAPI main.py files

#### 4.5 Create Directory Structure Merger

- [ ] **Task:** Create `merge_directory_structures()` function

  ```bash
  merge_directory_structures() {
      local base_dir=$1
      local feature_dirs=("${@:2}")
      local output_dir=$3

      # Copy base structure
      # Merge feature structures
      # Handle file conflicts
  }
  ```

- [ ] **Task:** Implement recursive directory traversal
- [ ] **Task:** Define merge strategies per file type
- [ ] **Task:** Handle file conflicts (overwrite, merge, skip)
- [ ] **Deliverable:** Directory merger
- [ ] **Test:** Merge directory trees

#### 4.6 Integrate Merging into Composition Flow

- [ ] **Task:** Update `compose_archetypes()` to use mergers

  ```bash
  # After conflict resolution

  merge_docker_compose_files "$base_compose" "${feature_composes[@]}"
  merge_env_files "$base_env" "${feature_envs[@]}"
  merge_makefiles "$base_makefile" "${feature_makefiles[@]}"
  merge_directory_structures "$base_dir" "${feature_dirs[@]}"
  ```

- [ ] **Task:** Add progress indicators for each merge operation
- [ ] **Task:** Handle merge failures gracefully
- [ ] **Deliverable:** Integrated file merging
- [ ] **Test:** Full archetype composition with file merging

### Phase 4 Success Criteria

- [ ] Docker Compose files merge correctly
- [ ] .env files merge with sections
- [ ] Makefiles merge with namespaced targets
- [ ] Source files merge intelligently
- [ ] Directory structures merge without data loss

---

## Phase 5: GitHub Integration (Week 8)

### Overview

Implement GitHub CLI integration for automatic repository creation and initial push.

### Todos

#### 5.1 Create GitHub Repository Creator Script

- [ ] **Task:** Create `scripts/github-repo-creator.sh`

  ```bash
  #!/bin/bash

  create_github_repo() {
      local project_name=$1
      local github_org=$2
      local visibility=$3
      local description=$4
      local project_path=$5

      # Check gh CLI installed
      # Check authentication
      # Create repository
      # Push initial commit
  }
  ```

- [ ] **Task:** Implement prerequisite checks
- [ ] **Task:** Implement repository creation
- [ ] **Task:** Implement initial push
- [ ] **Deliverable:** `scripts/github-repo-creator.sh`
- [ ] **Test:** Create test repository on GitHub

#### 5.2 Add GitHub CLI Flags

- [ ] **Task:** Add flags to `create-project.sh`

  ```bash
  --github)
      CREATE_GITHUB_REPO=true
      shift
      ;;
  --github-org)
      GITHUB_ORG="$2"
      shift 2
      ;;
  --private)
      GITHUB_VISIBILITY="private"
      shift
      ;;
  --public)
      GITHUB_VISIBILITY="public"
      shift
      ;;
  --description)
      GITHUB_DESCRIPTION="$2"
      shift 2
      ;;
  ```

- [ ] **Task:** Set default values
- [ ] **Task:** Update help text
- [ ] **Deliverable:** GitHub CLI flags
- [ ] **Test:** Parse GitHub flags correctly

#### 5.3 Implement Repository Configuration

- [ ] **Task:** Create `configure_repo_settings()` in github-repo-creator.sh

  ```bash
  configure_repo_settings() {
      local repo_name=$1

      # Enable issues
      # Enable projects
      # Disable wiki
      # Set merge options
      # Add topics
  }
  ```

- [ ] **Task:** Extract topics from archetype metadata
- [ ] **Task:** Apply settings via `gh api`
- [ ] **Deliverable:** Repository configuration
- [ ] **Test:** Verify settings on created repo

#### 5.4 Add Error Handling and Graceful Degradation

- [ ] **Task:** Check if gh CLI is installed

  ```bash
  if ! command -v gh &> /dev/null; then
      print_warning "GitHub CLI not found"
      print_info "Install: https://cli.github.com/"
      return 1
  fi
  ```

- [ ] **Task:** Check if authenticated

  ```bash
  if ! gh auth status &> /dev/null; then
      print_warning "Not authenticated with GitHub"
      print_info "Run: gh auth login"
      return 1
  fi
  ```

- [ ] **Task:** Handle repository already exists
- [ ] **Task:** Handle network errors
- [ ] **Deliverable:** Error handling
- [ ] **Test:** Test without gh CLI, without auth, etc.

#### 5.5 Integrate GitHub Creation into Main Flow

- [ ] **Task:** Update main() in `create-project.sh`

  ```bash
  # After Git initialization

  if [ "$CREATE_GITHUB_REPO" = true ]; then
      source "$SCRIPT_DIR/scripts/github-repo-creator.sh"

      create_github_repo \
          "$PROJECT_NAME" \
          "$GITHUB_ORG" \
          "$GITHUB_VISIBILITY" \
          "$GITHUB_DESCRIPTION" \
          "$FULL_PROJECT_PATH"
  fi
  ```

- [ ] **Task:** Update success message with GitHub URL
- [ ] **Deliverable:** Integrated GitHub creation
- [ ] **Test:** Create project with GitHub repo

#### 5.6 Generate CI/CD Workflows

- [ ] **Task:** Create `templates/.github/workflows/ci.yml`
- [ ] **Task:** Create `templates/.github/workflows/docker-build.yml`
- [ ] **Task:** Copy workflows to project during creation
- [ ] **Task:** Make workflows archetype-aware
- [ ] **Deliverable:** CI/CD workflow templates
- [ ] **Test:** Workflows run on GitHub Actions

### Phase 5 Success Criteria

- [ ] `--github` flag creates GitHub repository
- [ ] Repository settings configured automatically
- [ ] Initial commit pushed successfully
- [ ] Error handling works for all failure modes
- [ ] CI/CD workflows included and working

---

## Phase 6: Create Real Archetypes (Week 9-10)

### Overview

Build a library of real, working archetypes including RAG, Agentic, Monitoring, and composite archetypes.

### Todos

#### 6.1 Create RAG Project Archetype (FROM ARXIV-PAPER-CURATOR)

**Reference:** <https://github.com/mazelb/arxiv-paper-curator>
**Purpose:** Extract production-ready RAG implementation and templatize for general use

**Context:** The arxiv-paper-curator repository contains a production RAG system with FastAPI, OpenSearch, and Ollama. We'll extract template-worthy components (Pydantic Settings, FastAPI structure, Docker configs, testing infrastructure) and templatize ArXiv-specific code (ArxivClient, Paper models) into generic placeholders. See Appendix B for detailed component analysis.

---

##### 6.1.1 Setup and Clone Reference Repository

- [ ] **Task:** Clone arxiv-paper-curator for reference

  ```bash
  # Clone in temp directory for extraction
  git clone https://github.com/mazelb/arxiv-paper-curator.git /tmp/arxiv-curator
  cd /tmp/arxiv-curator
  git log --oneline -n 5  # Note latest commit for reference
  ls -la src/              # Review structure
  ```

  - **Purpose:** Maintain reference to original implementation
  - **Note:** This is temporary - will delete after extraction

- [ ] **Task:** Document arxiv-curator version/commit
  - Record commit SHA in `__archetype__.json` metadata
  - Add to archetype README for attribution
  - **Why:** Traceability for future updates

---

##### 6.1.2 Create Archetype Directory Structure

- [ ] **Task:** Create complete `archetypes/rag-project/` structure

  ```bash
  mkdir -p archetypes/rag-project/{src/{api/{routers,},services,models},tests/{unit,integration},config,docker,docs}
  mkdir -p archetypes/rag-project/.vscode
  ```

  - Creates: API layer, services, models, tests, config, Docker files, docs

- [ ] **Task:** Create `__archetype__.json` with comprehensive metadata

  ```json
  {
    "version": "2.0",
    "metadata": {
      "name": "rag-project",
      "display_name": "RAG (Retrieval-Augmented Generation) Project",
      "description": "Production-ready RAG system with FastAPI, OpenSearch 2.19, and Ollama. Extracted from arxiv-paper-curator with templatized components.",
      "version": "1.0.0",
      "author": "dev-environment-template",
      "tags": ["rag", "semantic-search", "embeddings", "fastapi", "opensearch", "ollama"],
      "archetype_type": "base",
      "source_repo": "https://github.com/mazelb/arxiv-paper-curator",
      "source_commit": "<COMMIT_SHA_FROM_STEP_6.1.1>"
    },
    "composition": {
      "role": "base",
      "compatible_features": ["monitoring", "agentic-workflows", "api-gateway"],
      "incompatible_with": [],
      "composable": true,
      "service_prefix": "rag",
      "port_offset": 0
    },
    "dependencies": {
      "preset": "ai-agent",
      "additional_tools": ["opensearch", "ollama", "langfuse"],
      "python": {
        "fastapi": ">=0.115.0",
        "uvicorn[standard]": ">=0.30.0",
        "opensearch-py": ">=2.4.0",
        "langchain": ">=0.1.0,<0.3.0",
        "langchain-community": ">=0.0.10",
        "pydantic": ">=2.0.0",
        "pydantic-settings": ">=2.0.0",
        "httpx": ">=0.27.0",
        "jina-embeddings-v3": ">=3.0.0"
      },
      "system": ["docker-compose>=2.0", "python>=3.12"]
    },
    "services": {
      "api": {
        "port": 8000,
        "dockerfile": "Dockerfile",
        "description": "FastAPI application with RAG endpoints"
      },
      "opensearch": {
        "image": "opensearchproject/opensearch:2.19.0",
        "port": 9200,
        "description": "Vector + BM25 hybrid search"
      },
      "ollama": {
        "image": "ollama/ollama:latest",
        "port": 11434,
        "description": "Local LLM inference"
      }
    },
    "gitignore_patterns": [
      "opensearch-data/",
      "ollama-data/",
      "*.parquet",
      "*.arrow",
      "*.faiss",
      ".env.local"
    ]
  }
  ```

  - **Deliverable:** Complete archetype metadata
  - **Test:** Validate JSON with `jq . archetypes/rag-project/__archetype__.json`

---

##### 6.1.3 Extract FastAPI Application Structure

- [ ] **Task:** Copy API main application

  ```bash
  # Copy main FastAPI app initialization
  cp /tmp/arxiv-curator/src/main.py archetypes/rag-project/src/api/main.py

  # Review and note:
  # - CORS configuration
  # - Lifespan events (startup/shutdown)
  # - Router mounting
  # - Exception handlers
  ```

  - **Keep as-is:** FastAPI app structure, CORS, lifespan
  - **Update:** Import paths if needed

- [ ] **Task:** Copy dependency injection container

  ```bash
  cp /tmp/arxiv-curator/src/dependencies.py archetypes/rag-project/src/api/dependencies.py
  ```

  - **Purpose:** DI pattern for service initialization
  - **Review:** Update service imports to match archetype structure

- [ ] **Task:** Copy API routers

  ```bash
  # Copy all routers
  cp -r /tmp/arxiv-curator/src/routers/* archetypes/rag-project/src/api/routers/

  # Expected files:
  # - health.py (health check endpoints)
  # - search.py (semantic search endpoints)
  # - documents.py (document CRUD)
  ```

  - **Keep:** Health checks, search patterns, CRUD structure
  - **Update:** Replace Paper → Document model references

- [ ] **Task:** Update imports in API files
  - Change `from src.services` → `from src.services`
  - Change `from src.models.paper` → `from src.models.document`
  - Ensure all paths relative to archetype root
  - **Test:** Python syntax check: `python -m py_compile src/api/main.py`

---

##### 6.1.4 Extract and Templatize Services Layer

- [ ] **Task:** Copy embedding service (generic, keep as-is)

  ```bash
  cp /tmp/arxiv-curator/src/services/embedding_service.py \
     archetypes/rag-project/src/services/
  ```

  - **Why keep:** Embedding logic is generic (Jina AI)
  - **No changes needed:** Works for any document type

- [ ] **Task:** Copy search service (generic, keep as-is)

  ```bash
  cp /tmp/arxiv-curator/src/services/search_service.py \
     archetypes/rag-project/src/services/
  ```

  - **Why keep:** OpenSearch interaction is generic
  - **Minor update:** Change Paper → Document in type hints

- [ ] **Task:** Templatize ArXiv-specific client → Generic data client

  ```bash
  # Copy and rename to template file
  cp /tmp/arxiv-curator/src/services/arxiv_client.py \
     archetypes/rag-project/src/services/__template__data_client.py
  ```

  **Transform the code:**

  ```python
  # ADD TO TOP OF FILE:
  """
  TEMPLATE: Data Source Client

  This is a template file showing how to implement a data fetching client.
  Replace this with your specific data source:

  Examples:
  - REST API client (news, products, documentation)
  - Database queries (PostgreSQL, MongoDB)
  - File system reader (PDFs, markdown, text)
  - Web scraper (websites, blogs)
  - Cloud storage (S3, Azure Blob)

  Original implementation: ArXiv API client
  See: https://github.com/mazelb/arxiv-paper-curator

  INSTRUCTIONS:
  1. Rename this file (remove __template__ prefix)
  2. Update class name to match your domain (e.g., NewsAPIClient)
  3. Implement fetch_documents() for your data source
  4. Update Document model in src/models/document.py
  5. Update imports in routers
  """

  # TRANSFORM:
  # class ArxivClient:  →  class DataClient:
  # def fetch_papers(   →  def fetch_documents(
  # Paper model         →  Document model

  # ADD TODO COMMENTS:
  # TODO: Replace with your API endpoint
  # TODO: Implement your authentication
  # TODO: Parse your data format
  ```

- [ ] **Task:** Create service initialization file

  ```bash
  cat > archetypes/rag-project/src/services/__init__.py << 'EOF'
  """
  Services layer for RAG application.

  Available services:
  - EmbeddingService: Generate embeddings using Jina AI
  - SearchService: Hybrid search with OpenSearch
  - DataClient: TEMPLATE - Implement your data source
  """

  from .embedding_service import EmbeddingService
  from .search_service import SearchService
  # from .__template__data_client import DataClient  # Uncomment after customization

  __all__ = ["EmbeddingService", "SearchService"]
  EOF
  ```

---

##### 6.1.5 Extract and Adapt Data Models

- [ ] **Task:** Copy and rename Paper model → Document model

  ```bash
  cp /tmp/arxiv-curator/src/models/paper.py \
     archetypes/rag-project/src/models/document.py
  ```

  **Transform the model:**

  ```python
  # BEFORE (ArXiv-specific):
  class Paper(BaseModel):
      arxiv_id: str
      title: str
      abstract: str
      authors: List[str]
      categories: List[str]
      published_date: datetime
      pdf_url: str

  # AFTER (Generic template):
  class Document(BaseModel):
      """
      Generic document model for RAG system.

      CUSTOMIZE: Adapt fields to your domain.
      Examples: news articles, products, support docs, research papers
      """
      id: str                          # Was: arxiv_id
      title: str                       # Keep
      content: str                     # Was: abstract
      metadata: Dict[str, Any] = {}   # Was: authors, categories, etc.

      # Optional standard fields
      created_at: Optional[datetime] = None
      updated_at: Optional[datetime] = None
      source_url: Optional[str] = None

      # TODO: Add your domain-specific fields below
      # Example for news: category, author, publication
      # Example for products: price, sku, brand
      # Example for docs: version, tags, related_docs
  ```

- [ ] **Task:** Copy other shared models

  ```bash
  # Copy query models if they exist
  cp /tmp/arxiv-curator/src/models/query.py \
     archetypes/rag-project/src/models/ 2>/dev/null || true

  # Copy response models
  cp /tmp/arxiv-curator/src/models/response.py \
     archetypes/rag-project/src/models/ 2>/dev/null || true
  ```

  - **Review:** Ensure models are generic (SearchQuery, SearchResponse, etc.)

- [ ] **Task:** Create models `__init__.py`

  ```python
  from .document import Document
  # Add other models as needed

  __all__ = ["Document"]
  ```

---

##### 6.1.6 Extract Pydantic Settings Configuration

- [ ] **Task:** Copy and adapt configuration

  ```bash
  # Copy settings.py (excellent pattern from arxiv-curator)
  cp /tmp/arxiv-curator/src/config.py \
     archetypes/rag-project/config/settings.py
  ```

  **Update configuration:**

  ```python
  from pydantic_settings import BaseSettings, SettingsConfigDict
  from typing import Optional

  class Settings(BaseSettings):
      """
      Application settings loaded from environment variables.

      Configuration is grouped by service/feature:
      - API: Server configuration
      - OpenSearch: Vector database
      - Ollama: LLM inference
      - Embeddings: Jina AI embeddings
      - Chunking: Document processing
      - Monitoring: Langfuse (optional)
      - Caching: Redis (optional)
      """

      # API Configuration
      API_HOST: str = "0.0.0.0"
      API_PORT: int = 8000
      API_RELOAD: bool = True

      # OpenSearch Configuration
      OPENSEARCH__HOST: str = "opensearch"
      OPENSEARCH__PORT: int = 9200
      OPENSEARCH__INDEX_NAME: str = "documents"  # Was: papers
      OPENSEARCH__USE_SSL: bool = False
      OPENSEARCH__VERIFY_CERTS: bool = False

      # Ollama Configuration
      OLLAMA__HOST: str = "ollama"
      OLLAMA__PORT: int = 11434
      OLLAMA__DEFAULT_MODEL: str = "llama3.2:1b"
      OLLAMA__TIMEOUT: int = 120

      # Embeddings (Jina AI)
      JINA_API_KEY: str
      EMBEDDINGS__MODEL: str = "jina-embeddings-v3"
      EMBEDDINGS__DIMENSIONS: int = 1024
      EMBEDDINGS__TASK: str = "retrieval.passage"

      # Chunking Strategy
      CHUNKING__CHUNK_SIZE: int = 600
      CHUNKING__OVERLAP_SIZE: int = 100
      CHUNKING__MIN_CHUNK_SIZE: int = 100

      # Monitoring (Optional - Langfuse)
      LANGFUSE__PUBLIC_KEY: Optional[str] = None
      LANGFUSE__SECRET_KEY: Optional[str] = None
      LANGFUSE__HOST: str = "https://cloud.langfuse.com"
      LANGFUSE__ENABLED: bool = False

      # Caching (Optional - Redis)
      REDIS__HOST: str = "redis"
      REDIS__PORT: int = 6379
      REDIS__CACHE_TTL_HOURS: int = 24
      REDIS__ENABLED: bool = False

      # TODO: Add your data source configuration
      # Example: NEWS_API_KEY, DATABASE_URL, etc.

      model_config = SettingsConfigDict(
          env_file=".env",
          env_file_encoding="utf-8",
          case_sensitive=False
      )
  ```

  - **Removed:** ArXiv-specific settings
  - **Kept:** All infrastructure settings (OpenSearch, Ollama, Langfuse)
  - **Added:** TODO section for custom data source

- [ ] **Task:** Create config `__init__.py`

  ```python
  from .settings import Settings

  settings = Settings()

  __all__ = ["settings", "Settings"]
  ```

---

##### 6.1.7 Extract Testing Infrastructure

- [ ] **Task:** Copy pytest configuration

  ```bash
  cp /tmp/arxiv-curator/pytest.ini archetypes/rag-project/
  ```

  - **Review:** Update paths if needed
  - **Ensure:** Coverage settings are appropriate

- [ ] **Task:** Copy test fixtures and configuration

  ```bash
  cp /tmp/arxiv-curator/tests/conftest.py archetypes/rag-project/tests/
  ```

  **Expected fixtures:**

  ```python
  @pytest.fixture
  def client():
      """FastAPI test client"""
      return TestClient(app)

  @pytest.fixture
  def mock_opensearch():
      """Mock OpenSearch client"""
      # Keep this pattern

  @pytest.fixture
  def mock_ollama():
      """Mock Ollama client"""
      # Keep this pattern

  @pytest.fixture
  def sample_document():  # Was: sample_paper
      """Sample document for testing"""
      return Document(
          id="test-123",
          title="Test Document",
          content="Test content...",
          metadata={}
      )
  ```

- [ ] **Task:** Copy and adapt unit tests

  ```bash
  # Copy test structure
  cp -r /tmp/arxiv-curator/tests/unit/* archetypes/rag-project/tests/unit/
  ```

  **Update tests:**
  - Replace `Paper` → `Document` in test cases
  - Update import paths
  - Keep test patterns and structure
  - Add TODO comments for data-source-specific tests

- [ ] **Task:** Copy and adapt integration tests

  ```bash
  cp -r /tmp/arxiv-curator/tests/integration/* archetypes/rag-project/tests/integration/ 2>/dev/null || true
  ```

  - **Update:** Replace ArXiv API mocks with generic mocks
  - **Keep:** OpenSearch integration test patterns
  - **Keep:** FastAPI endpoint tests

- [ ] **Task:** Create test README

  ```bash
  cat > archetypes/rag-project/tests/README.md << 'EOF'
  # Testing Guide

  ## Running Tests

  ```bash
  # All tests
  pytest

  # With coverage
  pytest --cov=src --cov-report=html

  # Unit tests only
  pytest tests/unit/

  # Integration tests (requires Docker services)
  docker-compose up -d
  pytest tests/integration/
  ```

  ## Test Structure

  - `conftest.py` - Shared fixtures
  - `unit/` - Fast, isolated tests
  - `integration/` - Tests with real services

  ## TODO: Customize Tests

  1. Update `test_data_client.py` with your data source tests
  2. Add domain-specific validation tests
  3. Update mock data to match your Document schema
  EOF

  ```

- [ ] **Task:** Create `tests/__init__.py`

  ```bash
  touch archetypes/rag-project/tests/__init__.py
  touch archetypes/rag-project/tests/unit/__init__.py
  touch archetypes/rag-project/tests/integration/__init__.py
  ```

---

##### 6.1.8 Create Docker Configuration

- [ ] **Task:** Create comprehensive `docker-compose.yml`

  ```yaml
  # archetypes/rag-project/docker-compose.yml
  version: '3.8'

  services:
    api:
      build:
        context: .
        dockerfile: Dockerfile
      container_name: rag-api
      ports:
        - "8000:8000"
      environment:
        - API_HOST=0.0.0.0
        - API_PORT=8000
        - OPENSEARCH__HOST=opensearch
        - OPENSEARCH__PORT=9200
        - OLLAMA__HOST=ollama
        - OLLAMA__PORT=11434
      env_file:
        - .env
      depends_on:
        opensearch:
          condition: service_healthy
        ollama:
          condition: service_started
      volumes:
        - ./src:/app/src
        - ./config:/app/config
        - ./tests:/app/tests
      networks:
        - rag-network
      restart: unless-stopped

    opensearch:
      image: opensearchproject/opensearch:2.19.0
      container_name: rag-opensearch
      environment:
        - discovery.type=single-node
        - bootstrap.memory_lock=true
        - "OPENSEARCH_JAVA_OPTS=-Xms512m -Xmx512m"
        - DISABLE_SECURITY_PLUGIN=true
      ulimits:
        memlock:
          soft: -1
          hard: -1
        nofile:
          soft: 65536
          hard: 65536
      ports:
        - "9200:9200"
        - "9600:9600"  # Performance analyzer
      volumes:
        - opensearch_data:/usr/share/opensearch/data
      networks:
        - rag-network
      healthcheck:
        test: ["CMD-SHELL", "curl -f http://localhost:9200/_cluster/health || exit 1"]
        interval: 30s
        timeout: 10s
        retries: 5
      restart: unless-stopped

    ollama:
      image: ollama/ollama:latest
      container_name: rag-ollama
      ports:
        - "11434:11434"
      volumes:
        - ollama_data:/root/.ollama
      networks:
        - rag-network
      restart: unless-stopped
      # GPU support (uncomment if NVIDIA GPU available)
      # deploy:
      #   resources:
      #     reservations:
      #       devices:
      #         - driver: nvidia
      #           count: 1
      #           capabilities: [gpu]

    # Optional: Redis for caching
    redis:
      image: redis:7-alpine
      container_name: rag-redis
      ports:
        - "6379:6379"
      volumes:
        - redis_data:/data
      networks:
        - rag-network
      restart: unless-stopped
      profiles:
        - caching

  volumes:
    opensearch_data:
      driver: local
    ollama_data:
      driver: local
    redis_data:
      driver: local

  networks:
    rag-network:
      driver: bridge
  ```

  - **Includes:** API, OpenSearch, Ollama, Redis (optional)
  - **Features:** Health checks, resource limits, volume persistence
  - **Note:** Redis uses Docker Compose profiles (enable with `--profile caching`)

- [ ] **Task:** Create Dockerfile for API service

  ```bash
  # Copy from arxiv-curator or create optimized version
  cp /tmp/arxiv-curator/Dockerfile archetypes/rag-project/
  ```

  **Ensure Dockerfile includes:**
  - Multi-stage build (builder + runtime)
  - Python 3.12+
  - Install dependencies from pyproject.toml
  - Non-root user
  - Proper WORKDIR setup

- [ ] **Task:** Create `.dockerignore`

  ```bash
  cat > archetypes/rag-project/.dockerignore << 'EOF'
  .git
  .github
  .vscode
  __pycache__
  *.pyc
  *.pyo
  *.pyd
  .Python
  env/
  venv/
  .pytest_cache
  .coverage
  htmlcov/
  opensearch-data/
  ollama-data/
  redis-data/
  *.md
  !README.md
  docs/
  tests/
  .env
  .env.*
  EOF
  ```

---

##### 6.1.9 Create Environment Configuration

- [ ] **Task:** Create comprehensive `.env.example`

  ```bash
  cat > archetypes/rag-project/.env.example << 'EOF'
  # =============================================================================
  # RAG Project Environment Configuration
  # =============================================================================
  # Copy this file to .env and update with your values
  # cp .env.example .env

  # =============================================================================
  # API Configuration
  # =============================================================================
  API_HOST=0.0.0.0
  API_PORT=8000
  API_RELOAD=true

  # =============================================================================
  # OpenSearch Configuration
  # =============================================================================
  OPENSEARCH__HOST=opensearch
  OPENSEARCH__PORT=9200
  OPENSEARCH__INDEX_NAME=documents
  OPENSEARCH__USE_SSL=false
  OPENSEARCH__VERIFY_CERTS=false

  # =============================================================================
  # Ollama Configuration
  # =============================================================================
  OLLAMA__HOST=ollama
  OLLAMA__PORT=11434
  OLLAMA__DEFAULT_MODEL=llama3.2:1b
  OLLAMA__TIMEOUT=120

  # Available models: llama3.2:1b, llama3.2:3b, llama3.1:8b, mistral:7b
  # Download models: docker exec rag-ollama ollama pull <model>

  # =============================================================================
  # Embeddings Configuration (Jina AI)
  # =============================================================================
  JINA_API_KEY=your_jina_api_key_here
  EMBEDDINGS__MODEL=jina-embeddings-v3
  EMBEDDINGS__DIMENSIONS=1024
  EMBEDDINGS__TASK=retrieval.passage

  # Get API key: https://jina.ai/embeddings/
  # Other tasks: retrieval.query, text-matching, classification

  # =============================================================================
  # Chunking Strategy
  # =============================================================================
  CHUNKING__CHUNK_SIZE=600
  CHUNKING__OVERLAP_SIZE=100
  CHUNKING__MIN_CHUNK_SIZE=100

  # Adjust based on your document type:
  # - Short docs (tweets, products): 200-400
  # - Medium docs (articles, emails): 400-800
  # - Long docs (papers, reports): 800-1500

  # =============================================================================
  # Monitoring (Optional - Langfuse)
  # =============================================================================
  LANGFUSE__PUBLIC_KEY=
  LANGFUSE__SECRET_KEY=
  LANGFUSE__HOST=https://cloud.langfuse.com
  LANGFUSE__ENABLED=false

  # Enable tracing: Set LANGFUSE__ENABLED=true and add keys
  # Get keys: https://cloud.langfuse.com

  # =============================================================================
  # Caching (Optional - Redis)
  # =============================================================================
  REDIS__HOST=redis
  REDIS__PORT=6379
  REDIS__CACHE_TTL_HOURS=24
  REDIS__ENABLED=false

  # Enable caching:
  # 1. Set REDIS__ENABLED=true
  # 2. Start with profile: docker-compose --profile caching up -d

  # =============================================================================
  # Data Source Configuration
  # =============================================================================
  # TODO: Add your data source configuration here
  #
  # Examples:
  # - REST API: API_KEY=xxx, API_BASE_URL=https://...
  # - Database: DATABASE_URL=postgresql://...
  # - File system: DATA_DIR=/path/to/files
  # - S3: AWS_ACCESS_KEY_ID=xxx, AWS_SECRET_ACCESS_KEY=xxx, S3_BUCKET=xxx

  # =============================================================================
  # Development
  # =============================================================================
  LOG_LEVEL=INFO
  DEBUG=false
  EOF
  ```

  - **Comprehensive:** All services configured
  - **Documented:** Inline comments explain each section
  - **Actionable:** TODOs for customization

- [ ] **Task:** Create `.env` in gitignore (if not already)
  - Ensure archetype's `.gitignore` includes `.env`

---

##### 6.1.10 Extract Build and Automation Scripts

- [ ] **Task:** Copy and adapt Makefile

  ```bash
  cp /tmp/arxiv-curator/Makefile archetypes/rag-project/
  ```

  **Update Makefile targets:**

  ```makefile
  .PHONY: help setup run stop test lint format clean

  help:  ## Show this help message
   @grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

  setup: ## Initial setup (create .env, download models)
   @echo "Setting up RAG project..."
   @if [ ! -f .env ]; then cp .env.example .env; echo "Created .env file"; fi
   @docker-compose up -d opensearch ollama
   @echo "Waiting for services to start..."
   @sleep 10
   @docker exec rag-ollama ollama pull llama3.2:1b
   @echo "Setup complete! Update .env with your configuration."

  run: ## Start all services
   docker-compose up -d

  run-dev: ## Start with hot reload
   docker-compose up api

  stop: ## Stop all services
   docker-compose down

  logs: ## View logs
   docker-compose logs -f api

  test: ## Run tests
   docker-compose exec api pytest tests/ -v

  test-cov: ## Run tests with coverage
   docker-compose exec api pytest tests/ -v --cov=src --cov-report=html
   @echo "Coverage report: htmlcov/index.html"

  lint: ## Run linters
   docker-compose exec api pylint src/ tests/
   docker-compose exec api mypy src/

  format: ## Format code
   docker-compose exec api black src/ tests/
   docker-compose exec api isort src/ tests/

  shell: ## Open shell in API container
   docker-compose exec api /bin/bash

  opensearch-shell: ## Open OpenSearch DevTools
   @echo "OpenSearch available at: http://localhost:9200"
   @echo "Try: curl http://localhost:9200/_cat/indices"

  download-model: ## Download Ollama model (MODEL=llama3.2:3b make download-model)
   docker exec rag-ollama ollama pull $(MODEL)

  list-models: ## List available Ollama models
   docker exec rag-ollama ollama list

  clean: ## Clean up containers and volumes
   docker-compose down -v
   rm -rf __pycache__ .pytest_cache .coverage htmlcov/

  reset: clean setup ## Reset environment (clean + setup)
  ```

  - **Removed:** ArXiv-specific commands
  - **Added:** Generic RAG commands
  - **Kept:** All best practices (lint, format, test)

- [ ] **Task:** Extract and adapt `pyproject.toml`

  ```bash
  cp /tmp/arxiv-curator/pyproject.toml archetypes/rag-project/
  ```

  **Update pyproject.toml:**

  ```toml
  [project]
  name = "{{PROJECT_NAME}}"  # Template variable
  version = "0.1.0"
  description = "RAG (Retrieval-Augmented Generation) system"
  readme = "README.md"
  requires-python = ">=3.12"

  dependencies = [
      "fastapi>=0.115.0",
      "uvicorn[standard]>=0.30.0",
      "opensearch-py>=2.4.0",
      "langchain>=0.1.0,<0.3.0",
      "langchain-community>=0.0.10",
      "pydantic>=2.0.0",
      "pydantic-settings>=2.0.0",
      "httpx>=0.27.0",
      "jina-embeddings-v3>=3.0.0",
      "python-dotenv>=1.0.0",
  ]

  [project.optional-dependencies]
  dev = [
      "pytest>=7.0.0",
      "pytest-cov>=4.0.0",
      "pytest-asyncio>=0.21.0",
      "black>=23.0.0",
      "isort>=5.12.0",
      "pylint>=2.17.0",
      "mypy>=1.0.0",
  ]
  monitoring = [
      "langfuse>=2.0.0",
  ]
  caching = [
      "redis>=4.5.0",
  ]

  [build-system]
  requires = ["setuptools>=68.0", "wheel"]
  build-backend = "setuptools.build_meta"

  [tool.pytest.ini_options]
  testpaths = ["tests"]
  python_files = ["test_*.py"]
  python_classes = ["Test*"]
  python_functions = ["test_*"]

  [tool.black]
  line-length = 100
  target-version = ['py312']

  [tool.isort]
  profile = "black"
  line_length = 100
  ```

  - **Updated:** Package name with template variable
  - **Removed:** ArXiv-specific dependencies
  - **Kept:** All infrastructure dependencies

---

##### 6.1.11 Create Documentation

- [ ] **Task:** Create comprehensive archetype README

  ```bash
  cat > archetypes/rag-project/README.md << 'EOF'
  # RAG Project Archetype

  Production-ready Retrieval-Augmented Generation (RAG) system based on
  [arxiv-paper-curator](https://github.com/mazelb/arxiv-paper-curator).

  ## 🎯 What's Included

  ### Core Stack
  - **FastAPI 0.115+** - Modern async Python web framework
  - **OpenSearch 2.19** - Hybrid search (BM25 + vector similarity)
  - **Ollama** - Local LLM inference (llama3.2, mistral, etc.)
  - **Pydantic Settings** - Type-safe configuration management
  - **Comprehensive Tests** - Unit and integration test suites

  ### Features
  ✅ Semantic search with vector embeddings (Jina AI)
  ✅ Hybrid search combining BM25 + vector similarity
  ✅ Document chunking with overlap strategies
  ✅ LLM integration via Ollama (10+ models)
  ✅ Optional Langfuse monitoring/tracing
  ✅ Optional Redis caching layer
  ✅ Production-ready Docker setup
  ✅ Complete test coverage patterns

  ## 🚀 Quick Start

  ### Prerequisites
  - Docker & Docker Compose 2.0+
  - Python 3.12+ (for local development)
  - Jina AI API key ([free tier available](https://jina.ai/embeddings/))

  ### Create Project
  ```bash
  # From dev-environment-template root
  ./create-project.sh --name my-rag-system --archetype rag-project

  cd my-rag-system
  ```

  ### Setup Environment

  ```bash
  # Create .env from template
  cp .env.example .env

  # Edit .env - REQUIRED: Add your Jina API key
  # JINA_API_KEY=your_key_here

  # Initial setup (starts services + downloads Ollama model)
  make setup
  ```

  ### Start Application

  ```bash
  # Start all services
  make run

  # Check health
  curl http://localhost:8000/health

  # API documentation
  open http://localhost:8000/docs
  ```

  ### Verify Services

  ```bash
  # OpenSearch
  curl http://localhost:9200

  # Ollama (list models)
  make list-models

  # View logs
  make logs
  ```

  ## 📝 Customization Guide

  ### 1. Implement Your Data Source

  **File:** `src/services/__template__data_client.py`

  This template shows how ArXiv API was implemented. Replace with your source:

  ```python
  # Examples of data sources:
  # - REST API: News API, Product API, Documentation API
  # - Database: PostgreSQL, MongoDB, MySQL
  # - Files: PDFs, Markdown, Text files
  # - Web Scraping: Beautiful Soup, Scrapy
  # - Cloud Storage: S3, Azure Blob, Google Cloud Storage
  ```

  **Steps:**
  1. Rename file: `mv __template__data_client.py news_api_client.py`
  2. Implement `fetch_documents()` method
  3. Add authentication/credentials to `.env`
  4. Update imports in routers

  ### 2. Customize Document Schema

  **File:** `src/models/document.py`

  The generic `Document` model replaced the ArXiv-specific `Paper` model.
  Adapt fields to your domain:

  ```python
  # Example: News articles
  class Document(BaseModel):
      id: str
      title: str
      content: str  # Article body
      metadata: Dict[str, Any] = {
          "author": "...",
          "publication": "...",
          "category": "...",
          "published_date": "..."
      }

  # Example: Product catalog
  class Document(BaseModel):
      id: str  # SKU
      title: str  # Product name
      content: str  # Description
      metadata: Dict[str, Any] = {
          "price": 0.0,
          "brand": "...",
          "category": "...",
          "in_stock": True
      }
  ```

  ### 3. Tune Search Strategy

  **File:** `src/services/search_service.py`

  Optimize hybrid search for your use case:

  - **BM25 weight**: Text matching importance (0.0 - 1.0)
  - **Vector weight**: Semantic similarity importance (0.0 - 1.0)
  - **Threshold**: Minimum similarity score

  ### 4. Configure Chunking

  **File:** `.env`

  Adjust based on document types:

  | Document Type | Chunk Size | Overlap |
  |---------------|------------|---------|
  | Short (tweets, products) | 200-400 | 50-100 |
  | Medium (articles, emails) | 400-800 | 100-150 |
  | Long (papers, reports) | 800-1500 | 150-300 |

  ## 🏗️ Architecture

  ```
  ┌─────────────────────────────────────────┐
  │         FastAPI Application             │
  │  ┌──────────┬──────────┬─────────────┐  │
  │  │ Routers  │ Services │   Models    │  │
  │  │          │          │             │  │
  │  │ search   │ search   │  Document   │  │
  │  │ docs     │ embedding│  Query      │  │
  │  │ health   │ data     │  Response   │  │
  │  └──────────┴──────────┴─────────────┘  │
  └────────────────┬────────────────────────┘
                   │
       ┌───────────┼───────────┬─────────────┐
       │           │           │             │
  ┌────▼────┐ ┌───▼────┐ ┌────▼──────┐ ┌────▼────┐
  │OpenSrch │ │ Ollama │ │   Jina    │ │  Data   │
  │  :9200  │ │ :11434 │ │Embeddings │ │ Source  │
  │ Vector  │ │  LLM   │ │   API     │ │ (TODO)  │
  │  + BM25 │ │        │ │           │ │         │
  └─────────┘ └────────┘ └───────────┘ └─────────┘
  ```

  ## 📁 Project Structure

  ```
  my-rag-system/
  ├── src/
  │   ├── api/
  │   │   ├── main.py                 # FastAPI app
  │   │   ├── dependencies.py         # DI container
  │   │   └── routers/
  │   │       ├── health.py           # Health checks
  │   │       ├── search.py           # Search endpoints
  │   │       └── documents.py        # Document CRUD
  │   ├── services/
  │   │   ├── search_service.py       # OpenSearch logic
  │   │   ├── embedding_service.py    # Jina embeddings
  │   │   └── __template__data_client.py  # ← CUSTOMIZE
  │   └── models/
  │       └── document.py             # ← CUSTOMIZE
  ├── tests/
  │   ├── conftest.py                 # Shared fixtures
  │   ├── unit/                       # Fast unit tests
  │   └── integration/                # Service tests
  ├── config/
  │   └── settings.py                 # Pydantic Settings
  ├── docker-compose.yml              # All services
  ├── Dockerfile                      # API service
  ├── Makefile                        # Common commands
  ├── pyproject.toml                  # Dependencies
  ├── .env.example                    # Config template
  └── README.md
  ```

  ## 🧪 Testing

  ```bash
  # Run all tests
  make test

  # With coverage report
  make test-cov
  open htmlcov/index.html

  # Specific test file
  docker-compose exec api pytest tests/unit/test_search_service.py -v
  ```

  ## 🔧 Development Workflow

  ```bash
  # Format code
  make format

  # Lint code
  make lint

  # Shell access
  make shell

  # View logs
  make logs
  ```

  ## 📊 Optional: Enable Monitoring

  ### Langfuse (Tracing & Analytics)

  1. Get API keys from <https://cloud.langfuse.com>
  2. Update `.env`:

     ```bash
     LANGFUSE__PUBLIC_KEY=pk-...
     LANGFUSE__SECRET_KEY=sk-...
     LANGFUSE__ENABLED=true
     ```

  3. Restart: `make stop && make run`
  4. View traces in Langfuse dashboard

  ### Redis (Caching)

  1. Enable in `.env`:

     ```bash
     REDIS__ENABLED=true
     ```

  2. Start with profile:

     ```bash
     docker-compose --profile caching up -d
     ```

  ## 🎓 Learn More

  ### API Endpoints

  - `GET /health` - Health check
  - `POST /search` - Semantic search
  - `GET /documents` - List documents
  - `POST /documents` - Add document
  - `GET /docs` - Interactive API documentation

  ### OpenSearch Management

  ```bash
  # List indices
  curl http://localhost:9200/_cat/indices

  # Index stats
  curl http://localhost:9200/documents/_stats

  # Delete index
  curl -X DELETE http://localhost:9200/documents
  ```

  ### Ollama Model Management

  ```bash
  # List installed models
  make list-models

  # Download new model
  make download-model MODEL=llama3.1:8b

  # Available models: llama3.2:1b, llama3.2:3b, llama3.1:8b,
  #                   mistral:7b, codellama:7b, vicuna:13b
  ```

  ## 📚 Reference Implementation

  This archetype is extracted from the production-ready
  [arxiv-paper-curator](https://github.com/mazelb/arxiv-paper-curator) project.

  ### What Changed (ArXiv → Generic)

  | ArXiv-Curator | RAG Archetype | Action |
  |---------------|---------------|--------|
  | `arxiv_client.py` | `__template__data_client.py` | Implement your source |
  | `Paper` model | `Document` model | Customize fields |
  | ArXiv API config | Generic config | Update .env |
  | Paper-specific tests | Generic tests | Add domain tests |

  ### What Stayed the Same

  ✅ FastAPI application structure and patterns
  ✅ OpenSearch integration and configuration
  ✅ Ollama integration and model management
  ✅ Pydantic Settings configuration pattern
  ✅ Test infrastructure (pytest, fixtures)
  ✅ Docker Compose setup and orchestration
  ✅ Makefile commands and workflows
  ✅ All production best practices

  ## 🐛 Troubleshooting

  ### Services won't start

  ```bash
  # Check logs
  docker-compose logs

  # Verify ports are free
  lsof -i :8000,9200,11434

  # Clean restart
  make reset
  ```

  ### OpenSearch errors

  ```bash
  # Increase vm.max_map_count (Linux/Mac)
  sudo sysctl -w vm.max_map_count=262144

  # Clean OpenSearch data
  docker-compose down -v
  docker volume rm rag-opensearch_data
  ```

  ### Ollama model issues

  ```bash
  # Re-download model
  docker exec rag-ollama ollama pull llama3.2:1b

  # Check available space
  docker exec rag-ollama df -h
  ```

  ## 📄 License

  See template repository license.

  ## 🤝 Contributing

  See template repository contribution guidelines.
  EOF

  ```
  - **Comprehensive:** Complete usage guide
  - **Actionable:** Clear customization steps
  - **Referenced:** Links to original arxiv-curator

- [ ] **Task:** Create migration guide for arxiv-curator users

  ```bash
  cat > archetypes/rag-project/docs/MIGRATION_FROM_ARXIV_CURATOR.md << 'EOF'
  # Migration Guide: ArXiv Paper Curator → RAG Project Archetype

  ## Overview

  This guide helps existing arxiv-paper-curator users migrate to the generic
  RAG project archetype or understand the differences.

  ## Key Changes

  ### 1. Data Models

  | ArXiv-Curator | RAG Archetype | Migration |
  |---------------|---------------|-----------|
  | `Paper` class | `Document` class | Update all references |
  | `arxiv_id` | `id` | Rename field |
  | `abstract` | `content` | Rename field |
  | `authors`, `categories` | `metadata` dict | Nest in metadata |
  | `pdf_url` | `source_url` | Rename field |

  ### 2. Services

  | ArXiv-Curator | RAG Archetype | Migration |
  |---------------|---------------|-----------|
  | `arxiv_client.py` | `__template__data_client.py` | Implement your source |
  | `fetch_papers()` | `fetch_documents()` | Rename method |
  | ArXiv API logic | TODO comments | Implement |

  ### 3. Configuration

  **Removed Settings:**
  - `ARXIV_API_BASE_URL`
  - `ARXIV_MAX_RESULTS`
  - `ARXIV_SORT_BY`

  **Added Settings:**
  - Generic data source section (TODO)

  **Kept Settings:**
  - All OpenSearch settings
  - All Ollama settings
  - All Langfuse settings
  - All chunking settings

  ## Migration Steps

  ### Option A: Start Fresh with Archetype

  1. **Create new project:**
     ```bash
     ./create-project.sh --name my-rag --archetype rag-project
     ```

  2. **Copy your customizations:**

     ```bash
     # Your ArXiv client → Template
     cp arxiv-curator/src/services/arxiv_client.py \
        my-rag/src/services/data_client.py

     # Update imports and class names
     ```

  3. **Update configuration:**

     ```bash
     # Copy relevant .env variables
     # Add your data source configuration
     ```

  4. **Test migration:**

     ```bash
     cd my-rag
     make test
     make run
     ```

  ### Option B: Keep ArXiv-Specific Implementation

  If you want to keep using ArXiv specifically:

  1. Create from archetype
  2. Restore ArXiv client:

     ```bash
     cp arxiv-curator/src/services/arxiv_client.py \
        my-rag/src/services/
     ```

  3. Restore Paper model:

     ```bash
     cp arxiv-curator/src/models/paper.py \
        my-rag/src/models/
     ```

  4. Update imports in routers
  5. Restore ArXiv settings in config/settings.py

  ## FAQ

  **Q: Can I use this archetype for ArXiv papers?**
  A: Yes! Just restore the ArXiv-specific files (see Option B above).

  **Q: What if I need Airflow DAGs?**
  A: Add the agentic-workflows feature archetype:

  ```bash
  ./create-project.sh --name my-rag \
    --archetype rag-project \
    --add-features agentic-workflows
  ```

  **Q: Are the test patterns the same?**
  A: Yes, test infrastructure is identical. Just update model names.

  **Q: Can I contribute improvements back?**
  A: Yes! Improvements to the archetype benefit all users.
  EOF

  ```

- [ ] **Task:** Create API documentation

  ```bash
  mkdir -p archetypes/rag-project/docs
  # Add API.md, SEARCH.md, DEPLOYMENT.md as needed
  ```

---

##### 6.1.12 Validation and Testing

- [ ] **Task:** Syntax validation

  ```bash
  # Validate JSON
  jq . archetypes/rag-project/__archetype__.json

  # Validate Python syntax
  find archetypes/rag-project/src -name "*.py" -exec python -m py_compile {} \;

  # Validate YAML
  docker-compose -f archetypes/rag-project/docker-compose.yml config
  ```

- [ ] **Task:** Create test project from archetype

  ```bash
  ./create-project.sh --name test-rag-archetype --archetype rag-project --dry-run
  ./create-project.sh --name test-rag-archetype --archetype rag-project
  cd test-rag-archetype
  ```

- [ ] **Task:** Verify environment setup

  ```bash
  # Check .env exists
  ls -la .env.example

  # Check docker-compose is valid
  docker-compose config

  # Check Makefile targets
  make help
  ```

- [ ] **Task:** Start services and verify

  ```bash
  # Initial setup
  make setup

  # Verify OpenSearch started
  curl http://localhost:9200
  # Expected: OpenSearch version info

  # Verify Ollama started
  curl http://localhost:11434/api/tags
  # Expected: List of models

  # Start API
  make run-dev

  # Check health endpoint
  curl http://localhost:8000/health
  # Expected: {"status": "healthy"}

  # Check API docs
  curl http://localhost:8000/docs
  # Expected: HTML (OpenAPI UI)
  ```

- [ ] **Task:** Run test suite

  ```bash
  # Run all tests
  make test

  # Verify coverage
  make test-cov
  # Should pass with template mocks
  ```

- [ ] **Task:** Verify customization points

  ```bash
  # Check template file exists
  ls -la src/services/__template__data_client.py

  # Check TODO comments
  grep -r "TODO:" src/

  # Check Document model is generic
  cat src/models/document.py | grep "class Document"
  ```

- [ ] **Task:** Clean up test project

  ```bash
  cd ..
  rm -rf test-rag-archetype
  ```

---

##### 6.1.13 Documentation and Finalization

- [ ] **Task:** Update archetype registry

  ```bash
  # Add to config/archetypes.json
  {
    "archetypes": [
      {
        "name": "rag-project",
        "type": "base",
        "display_name": "RAG Project",
        "description": "Production RAG system (OpenSearch + Ollama)",
        "source": "arxiv-paper-curator",
        "tags": ["rag", "search", "embeddings", "llm"],
        "maturity": "stable",
        "version": "1.0.0"
      }
    ]
  }
  ```

- [ ] **Task:** Create archetype changelog

  ```bash
  cat > archetypes/rag-project/CHANGELOG.md << 'EOF'
  # Changelog: RAG Project Archetype

  ## [1.0.0] - 2025-11-19

  ### Added
  - Initial release extracted from arxiv-paper-curator
  - FastAPI application structure
  - OpenSearch 2.19 integration
  - Ollama LLM integration
  - Jina AI embeddings
  - Pydantic Settings configuration
  - Comprehensive test suite
  - Docker Compose orchestration
  - Makefile automation
  - Complete documentation

  ### Templatized
  - ArxivClient → __template__data_client.py
  - Paper model → Document model
  - ArXiv-specific config → Generic config

  ### Source
  - Based on: https://github.com/mazelb/arxiv-paper-curator
  - Commit: <SHA>
  - Date: 2025-11-19
  EOF
  ```

- [ ] **Task:** Add to main template README
  - Document rag-project archetype in main README.md
  - Add usage examples
  - Link to archetype README

---

##### Deliverables for Phase 6.1

- [ ] **Complete `archetypes/rag-project/` directory** with:
  - ✅ Full FastAPI application (templatized from arxiv-curator)
  - ✅ OpenSearch + Ollama Docker configuration
  - ✅ Generic Document model (was Paper)
  - ✅ Template data client (was ArxivClient)
  - ✅ Pydantic Settings pattern
  - ✅ Comprehensive test infrastructure
  - ✅ Complete documentation (README, migration guide)
  - ✅ `.env.example` with all configurations
  - ✅ Makefile with common commands
  - ✅ `__archetype__.json` metadata

- [ ] **Validation passed:**
  - ✅ JSON/YAML/Python syntax valid
  - ✅ Test project creates successfully
  - ✅ All services start and respond
  - ✅ Health checks pass
  - ✅ Tests run (with mocks)
  - ✅ Customization points documented

- [ ] **Documentation complete:**
  - ✅ Archetype README with quick start
  - ✅ Customization guide (4 key areas)
  - ✅ Migration guide from arxiv-curator
  - ✅ Architecture diagram
  - ✅ API documentation
  - ✅ Troubleshooting section

---

##### Testing Criteria for Phase 6.1

**Success Criteria:**

1. **Functional:**
   - [ ] Create project: `./create-project.sh --name test --archetype rag-project`
   - [ ] Services start: `make setup && make run`
   - [ ] Health check passes: `curl http://localhost:8000/health` returns 200
   - [ ] OpenSearch responds: `curl http://localhost:9200` returns cluster info
   - [ ] Ollama responds: `curl http://localhost:11434/api/tags` returns models
   - [ ] Tests pass: `make test` completes successfully

2. **Customization:**
   - [ ] Template file exists: `src/services/__template__data_client.py`
   - [ ] TODO comments present: `grep -r "TODO:" src/` finds 5+ occurrences
   - [ ] Document model is generic: No ArXiv-specific fields remain

3. **Documentation:**
   - [ ] README has Quick Start section
   - [ ] README has Customization Guide (4 sections minimum)
   - [ ] Migration guide exists for arxiv-curator users
   - [ ] `.env.example` documents all variables (20+ lines)

4. **Quality:**
   - [ ] No syntax errors: `find src -name "*.py" -exec python -m py_compile {} \;`
   - [ ] Docker Compose valid: `docker-compose config`
   - [ ] JSON valid: `jq . __archetype__.json`
   - [ ] All template variables identified: `grep -r "{{.*}}" .`

#### 6.2 Create Agentic Workflows Archetype

- [ ] **Task:** Create `archetypes/agentic-workflows/` structure
- [ ] **Task:** Create `__archetype__.json`

  ```json
  {
    "name": "agentic-workflows",
    "version": "1.0.0",
    "role": "feature",
    "compatible_bases": ["rag-project", "api-service"],
    "service_prefix": "agentic",
    "port_offset": 100
  }
  ```

- [ ] **Task:** Create agent orchestration code
  - `src/agents/` - Agent definitions
  - `src/workflows/` - Workflow orchestration
- [ ] **Task:** Add Airflow DAGs
- [ ] **Task:** Add Langfuse integration
- [ ] **Task:** Create docker-compose configuration
- [ ] **Deliverable:** agentic-workflows archetype
- [ ] **Test:** Compose rag-project + agentic-workflows

#### 6.3 Create Monitoring Archetype

- [ ] **Task:** Create `archetypes/monitoring/` structure
- [ ] **Task:** Create `__archetype__.json`
- [ ] **Task:** Add Prometheus configuration
- [ ] **Task:** Add Grafana dashboards
- [ ] **Task:** Add Alertmanager rules
- [ ] **Task:** Create docker-compose for monitoring stack
- [ ] **Deliverable:** monitoring archetype
- [ ] **Test:** Add monitoring to existing project

#### 6.4 Create API Service Archetype

- [ ] **Task:** Create `archetypes/api-service/` structure
- [ ] **Task:** Production-ready FastAPI template
- [ ] **Task:** Add authentication/authorization
- [ ] **Task:** Add rate limiting
- [ ] **Task:** Add request validation
- [ ] **Deliverable:** api-service archetype
- [ ] **Test:** Create standalone API service

#### 6.5 Create Composite Archetype

- [ ] **Task:** Create `archetypes/rag-agentic-system/`
- [ ] **Task:** Create `__archetype__.json`

  ```json
  {
    "archetype_type": "composite",
    "constituents": [
      {"archetype": "rag-project", "role": "base"},
      {"archetype": "agentic-workflows", "role": "feature"}
    ],
    "custom_integrations": [
      "scripts/integrate_rag_agentic.sh"
    ]
  }
  ```

- [ ] **Task:** Create integration scripts
- [ ] **Task:** Pre-resolve known conflicts
- [ ] **Deliverable:** Composite archetype
- [ ] **Test:** Create project from composite

#### 6.6 Document All Archetypes

- [ ] **Task:** Update `archetypes/README.md` with full list
- [ ] **Task:** Create setup guide for each archetype
- [ ] **Task:** Create architecture diagrams
- [ ] **Task:** Add examples and use cases
- [ ] **Deliverable:** Complete archetype documentation
- [ ] **Test:** Documentation is accurate

### Phase 6 Success Criteria

- [ ] At least 3 base archetypes created
- [ ] At least 3 feature archetypes created
- [ ] At least 1 composite archetype created
- [ ] All archetypes fully documented
- [ ] All archetypes tested and working

---

## Phase 7: Testing, Documentation & Polish (Week 11-12)

### Overview

Comprehensive testing, documentation, and user experience improvements.

### Todos

#### 7.1 Create Test Suite

- [ ] **Task:** Create `tests/` directory in template root
- [ ] **Task:** Create `tests/test-archetype-loading.sh`
  - Test loading each archetype
  - Test validation
- [ ] **Task:** Create `tests/test-conflict-resolution.sh`
  - Test port conflicts
  - Test service name conflicts
  - Test dependency conflicts
- [ ] **Task:** Create `tests/test-file-merging.sh`
  - Test docker-compose merge
  - Test env merge
  - Test Makefile merge
- [ ] **Task:** Create `tests/test-git-integration.sh`
  - Test Git initialization
  - Test commit messages
  - Test .gitignore generation
- [ ] **Task:** Create `tests/test-github-integration.sh`
  - Test repository creation
  - Test push
- [ ] **Task:** Create `tests/test-end-to-end.sh`
  - Full workflow tests
  - Multiple archetype combinations
- [ ] **Deliverable:** Complete test suite
- [ ] **Test:** All tests pass

#### 7.2 Add Dry Run Mode

- [ ] **Task:** Add `--dry-run` flag to `create-project.sh`
- [ ] **Task:** Implement preview generation

  ```bash
  show_preview() {
      # Show project structure
      # Show services and ports
      # Show disk/memory requirements
      # Ask for confirmation
  }
  ```

- [ ] **Task:** Skip actual file creation in dry-run
- [ ] **Deliverable:** Dry-run mode
- [ ] **Test:** Dry-run shows accurate preview

#### 7.3 Add Interactive Mode Improvements

- [ ] **Task:** Enhance `--interactive` mode
  - Show archetype descriptions
  - Allow feature selection from menu
  - Preview conflicts before proceeding
- [ ] **Task:** Add color-coded output
- [ ] **Task:** Add progress bars for long operations
- [ ] **Deliverable:** Enhanced interactive mode
- [ ] **Test:** Interactive mode is user-friendly

#### 7.4 Generate Project Documentation

- [ ] **Task:** Auto-generate README.md for each project
  - Include quick start
  - List services and ports
  - Link to COMPOSITION.md
- [ ] **Task:** Auto-generate COMPOSITION.md
  - Document archetype combination
  - Architecture diagram
  - Service descriptions
- [ ] **Task:** Create templates in `templates/docs/`
- [ ] **Deliverable:** Documentation generator
- [ ] **Test:** Generated docs are accurate

#### 7.5 Create Comprehensive User Documentation

- [ ] **Task:** Update main README.md
  - Add archetype system overview
  - Add usage examples
  - Add troubleshooting section
- [ ] **Task:** Finalize all docs/ files
  - GIT_GITHUB_INTEGRATION.md
  - MULTI_ARCHETYPE_COMPOSITION_DESIGN.md
  - IMPLEMENTATION_GUIDE.md
- [ ] **Task:** Create video tutorials (optional)
- [ ] **Task:** Create blog post (optional)
- [ ] **Deliverable:** Complete documentation
- [ ] **Test:** Documentation is clear and accurate

#### 7.6 Performance Optimization

- [ ] **Task:** Profile project creation time
- [ ] **Task:** Optimize slow operations
  - Parallelize file copying
  - Cache archetype metadata
  - Optimize JSON/YAML parsing
- [ ] **Task:** Target < 60 seconds for typical project
- [ ] **Deliverable:** Performance improvements
- [ ] **Test:** Measure creation time

#### 7.7 Error Messages and Help Text

- [ ] **Task:** Review all error messages
  - Make them actionable
  - Provide solutions
  - Add helpful links
- [ ] **Task:** Update help text
  - Add examples
  - Document all flags
  - Add archetype descriptions
- [ ] **Deliverable:** Improved UX
- [ ] **Test:** Error messages are helpful

### Phase 7 Success Criteria

- [ ] Comprehensive test suite with >80% coverage
- [ ] All tests pass
- [ ] Documentation is complete and accurate
- [ ] Project creation takes < 60 seconds
- [ ] Error messages are helpful and actionable

---

## Quick Start Implementation Order

If you want to get a minimal working version quickly, implement in this order:

### Sprint 1 (Week 1): Minimal Viable Product

1. ✅ Create `config/optional-tools.json`
2. ✅ Create `archetypes/` directory
3. ✅ Create base archetype
4. ✅ Create `scripts/archetype-loader.sh`
5. ✅ Update `create-project.sh` with `--archetype` flag
6. ✅ Test: Create project from base archetype

### Sprint 2 (Week 2): Git Integration

1. ✅ Remove conditional Git initialization
2. ✅ Create `scripts/git-helper.sh`
3. ✅ Implement smart commit messages
4. ✅ Generate .gitignore
5. ✅ Test: Git initialization works

### Sprint 3 (Week 3): First Real Archetype

1. ✅ Create rag-project archetype
2. ✅ Copy code from arxiv-curator
3. ✅ Templatize project-specific parts
4. ✅ Test: Create working RAG project

### Sprint 4 (Week 4): Multi-Archetype Support

1. ✅ Create conflict detector
2. ✅ Implement port offset
3. ✅ Add `--add-features` flag
4. ✅ Create monitoring archetype
5. ✅ Test: Compose RAG + monitoring

### Sprint 5 (Week 5): GitHub Integration

1. ✅ Create github-repo-creator.sh
2. ✅ Add `--github` flag
3. ✅ Implement repository creation
4. ✅ Test: End-to-end with GitHub

---

## Dependencies and Prerequisites

### Development Tools

- [ ] **Bash** 4.0+ installed
- [ ] **jq** for JSON parsing
- [ ] **yq** for YAML manipulation
- [ ] **git** 2.x for version control
- [ ] **gh** (GitHub CLI) for GitHub integration
- [ ] **Docker** and **Docker Compose** for testing

### Installation Commands

```bash
# macOS
brew install jq yq gh

# Ubuntu/Debian
sudo apt install jq gh
sudo pip install yq

# Windows (via Chocolatey)
choco install jq yq gh
```

### Verification

```bash
./scripts/check-prerequisites.sh
```

---

## Risk Mitigation

### Risk: Breaking Existing Functionality

**Mitigation:**

- Keep existing preset system functional
- Add archetypes alongside, not replacing
- Comprehensive testing before each release

### Risk: Archetype Complexity

**Mitigation:**

- Start with simple archetypes
- Add complexity incrementally
- Document patterns clearly

### Risk: Merge Conflicts in User Code

**Mitigation:**

- Use `__template__` prefix for replaceable files
- Clear documentation on customization points
- Provide conflict resolution guides

### Risk: GitHub CLI Dependency

**Mitigation:**

- Make GitHub integration optional
- Graceful degradation without gh CLI
- Provide manual instructions as fallback

### Risk: Performance Issues

**Mitigation:**

- Profile early and often
- Optimize critical paths
- Cache expensive operations

---

## Success Metrics

### Quantitative

- [ ] Project creation time < 60 seconds
- [ ] Test coverage > 80%
- [ ] Zero breaking changes to existing projects
- [ ] Support 10+ archetype combinations

### Qualitative

- [ ] User can create project in one command
- [ ] Documentation is clear and comprehensive
- [ ] Error messages are actionable
- [ ] System is extensible for new archetypes

---

## Post-Implementation

### Version 2.0 Release Checklist

- [ ] All tests pass
- [ ] Documentation complete
- [ ] Changelog updated
- [ ] Git tag created: `v2.0.0`
- [ ] GitHub release published
- [ ] Blog post published
- [ ] Update propagation tested

### Community Engagement

- [ ] Announce on relevant forums
- [ ] Create example projects
- [ ] Invite contributions
- [ ] Set up issue templates

### Maintenance Plan

- [ ] Monitor issue reports
- [ ] Regular archetype updates
- [ ] Quarterly security reviews
- [ ] Annual major version releases

---

## Getting Started

**Ready to implement?** Start with Phase 1, Task 1.1:

```bash
# Create the foundation
mkdir -p config archetypes scripts

# Begin implementation
# See Phase 1 todos above
```

**Questions?** Review the detailed design documents:

- [MULTI_ARCHETYPE_COMPOSITION_DESIGN.md](MULTI_ARCHETYPE_COMPOSITION_DESIGN.md)
- [GIT_GITHUB_INTEGRATION.md](docs/GIT_GITHUB_INTEGRATION.md)
- [SINGLE_COMMAND_PROJECT_CREATION.md](SINGLE_COMMAND_PROJECT_CREATION.md)

---

## Appendix: Command Reference

### Final Commands (After Implementation)

```bash
# Local project with Git
./create-project.sh --name my-project --archetype rag-project

# With GitHub
./create-project.sh --name my-project --archetype rag-project --github --private

# Multi-archetype with GitHub in organization
./create-project.sh --name customer-search \
  --archetype rag-project \
  --add-features agentic-workflows,monitoring \
  --github \
  --github-org acme-corp \
  --private \
  --description "Customer search system"

# Preview before creating
./create-project.sh --name my-project --archetype rag-project --dry-run

# List available archetypes
./create-project.sh --list-archetypes

# Check compatibility
./create-project.sh --check-compatibility \
  --archetype rag-project \
  --add-features agentic-workflows
```

---

---

## Appendix A: Command Reference

### Project Creation Commands

```bash
# Basic project
./create-project.sh --name my-project --archetype rag-project

# With GitHub integration
./create-project.sh --name my-project --archetype rag-project --github --private

# Multi-archetype with GitHub in organization
./create-project.sh --name customer-search \
  --archetype rag-project \
  --add-features agentic-workflows,monitoring \
  --github \
  --github-org acme-corp \
  --private \
  --description "Customer search system"

# Preview before creating
./create-project.sh --name my-project --archetype rag-project --dry-run

# List available archetypes
./create-project.sh --list-archetypes

# Check compatibility
./create-project.sh --check-compatibility \
  --archetype rag-project \
  --add-features agentic-workflows
```

---

## Appendix B: ArXiv-Curator Merge Strategy Summary

**Source:** Extracted from `docs/ARXIV_CURATOR_MERGE_STRATEGIES.md` (1588 lines)

### Executive Summary

The arxiv-paper-curator repository contains a production-ready RAG system that serves as the foundation for the `rag-project` archetype. The merge strategy involves extracting **template-worthy components** (FastAPI structure, Pydantic Settings, Docker configs, test infrastructure) while **templatizing project-specific code** (ArxivClient → DataClient, Paper → Document).

**Approach:** Option A - Template with Project Archetypes (selected)

### Template-Worthy Components (Keep As-Is)

These components from arxiv-curator are production-ready patterns that work for any RAG project:

#### 1. Pydantic Settings Pattern

```python
# config/settings.py - Excellent configuration management
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    # Service configurations with environment variables
    OPENSEARCH_HOST: str = "opensearch"
    OLLAMA_HOST: str = "ollama"

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
```

**Why keep:** Generic configuration pattern used across all projects.

#### 2. FastAPI Project Structure

```
src/api/
├── main.py              # App initialization, CORS, lifespan
├── dependencies.py      # Dependency injection container
└── routers/
    ├── health.py        # Health check endpoints
    ├── search.py        # Search endpoints
    └── documents.py     # CRUD endpoints
```

**Why keep:** Standard FastAPI best practices, not ArXiv-specific.

#### 3. Docker Service Configurations

- **OpenSearch 2.19:** Hybrid search (BM25 + vector), single-node config
- **Ollama:** LLM inference with model management
- **Volume persistence:** opensearch_data, ollama_data
- **Health checks:** Service readiness patterns

**Why keep:** Infrastructure configuration is domain-agnostic.

#### 4. Testing Infrastructure

- `pytest.ini` - Test configuration
- `conftest.py` - Shared fixtures (TestClient, mock services)
- Unit tests structure - Fast, isolated tests
- Integration tests - Real service tests

**Why keep:** Test patterns are universal, just update model names.

#### 5. Makefile Commands

```makefile
run:     # Start services
test:    # Run test suite
lint:    # Code quality checks
format:  # Auto-formatting
setup:   # Initial setup + download models
```

**Why keep:** Common workflow commands apply to all RAG projects.

### ArXiv-Specific Components (Templatize)

These components are specific to ArXiv and need to be made generic:

#### 1. ArxivClient → DataClient

```python
# BEFORE: src/services/arxiv_client.py
class ArxivClient:
    def fetch_papers(self, query: str) -> List[Paper]:
        # ArXiv API specific logic
        response = requests.get(f"http://export.arxiv.org/api/query?{params}")
        # Parse ArXiv XML response

# AFTER: src/services/__template__data_client.py
class DataClient:
    """TEMPLATE: Replace with your data source"""
    def fetch_documents(self, query: str) -> List[Document]:
        # TODO: Implement your data fetching logic
        # Examples: REST API, database, file system, web scraper
        raise NotImplementedError("Replace with your data source")
```

**Action:** Copy file, rename methods, add TODO comments, include examples.

#### 2. Paper Model → Document Model

```python
# BEFORE: src/models/paper.py
class Paper(BaseModel):
    arxiv_id: str
    title: str
    abstract: str
    authors: List[str]
    categories: List[str]
    published_date: datetime
    pdf_url: str

# AFTER: src/models/document.py
class Document(BaseModel):
    """Generic document for RAG system"""
    id: str                        # Was: arxiv_id
    title: str                     # Keep
    content: str                   # Was: abstract
    metadata: Dict[str, Any] = {}  # Was: authors, categories
    source_url: Optional[str] = None  # Was: pdf_url

    # TODO: Add domain-specific fields
```

**Action:** Rename class/file, generalize fields, add TODO section.

#### 3. Configuration Variables

```python
# REMOVE: ArXiv-specific settings
ARXIV_API_BASE_URL = "http://export.arxiv.org/api"
ARXIV_MAX_RESULTS = 100
ARXIV_SORT_BY = "relevance"

# ADD: Generic data source section
# TODO: Add your data source configuration
# Example: NEWS_API_KEY, DATABASE_URL, FILE_PATH
```

**Action:** Remove ArXiv configs, add TODO placeholder for custom configs.

### Key Architectural Decisions

#### 1. Directory Structure

```
archetypes/rag-project/
├── src/
│   ├── api/                    # FastAPI app (keep as-is)
│   ├── services/
│   │   ├── search_service.py   # Generic (keep)
│   │   ├── embedding_service.py # Generic (keep)
│   │   └── __template__data_client.py # Templatized
│   └── models/
│       └── document.py         # Generic (templatized from Paper)
├── tests/                      # Keep structure, update model names
├── config/                     # Keep Settings pattern
├── docker-compose.yml          # Complete stack (OpenSearch + Ollama + API)
└── README.md                   # Comprehensive customization guide
```

#### 2. Services to Include

- ✅ **API Service:** FastAPI with hot reload
- ✅ **OpenSearch:** Vector + BM25 hybrid search
- ✅ **Ollama:** Local LLM inference
- ✅ **Redis:** Optional (via Docker Compose profiles)
- ❌ **Airflow:** Exclude (available in agentic-workflows feature archetype)

#### 3. Customization Strategy

Provide **four main customization points**:

1. **Data Source** - `__template__data_client.py` with implementation examples
2. **Document Schema** - `document.py` with domain-specific field examples
3. **Search Strategy** - Tunable BM25/vector weights in `search_service.py`
4. **Chunking Config** - Adjustable chunk size/overlap in `.env`

Each with clear TODO comments and examples.

### Migration Path from ArXiv-Curator

For existing arxiv-curator users who want to use this archetype:

**Option A: Generic RAG (Recommended)**

1. Create project from rag-project archetype
2. Implement custom data source in `__template__data_client.py`
3. Customize Document model for domain
4. Update tests with new model names

**Option B: Keep ArXiv-Specific**

1. Create project from rag-project archetype
2. Restore `arxiv_client.py` from original repo
3. Restore `Paper` model from original repo
4. Update imports to use restored files
5. Add ArXiv configs back to settings.py

### File Extraction Checklist

From `/tmp/arxiv-curator` to `archetypes/rag-project/`:

- [x] **API:** `src/main.py`, `src/dependencies.py`, `src/routers/*` → `src/api/`
- [x] **Services:** `src/services/embedding_service.py`, `search_service.py` (keep as-is)
- [x] **Services:** `src/services/arxiv_client.py` → `__template__data_client.py` (templatize)
- [x] **Models:** `src/models/paper.py` → `document.py` (rename + generalize)
- [x] **Config:** `src/config.py` → `config/settings.py` (remove ArXiv vars)
- [x] **Tests:** `tests/conftest.py`, `tests/unit/*`, `tests/integration/*` (update names)
- [x] **Docker:** Extract OpenSearch, Ollama service definitions
- [x] **Build:** `pyproject.toml` (remove ArXiv deps), `Makefile` (remove ArXiv commands)
- [x] **Docs:** Create comprehensive README, migration guide, customization guide

### Code Transformation Examples

#### Example 1: Service Method Renaming

```python
# arxiv-curator: src/services/arxiv_client.py
async def fetch_papers(self, query: str, max_results: int = 10) -> List[Paper]:
    """Fetch papers from ArXiv API"""
    params = {"search_query": query, "max_results": max_results}
    response = await self.client.get(ARXIV_API_URL, params=params)
    return [self._parse_entry(entry) for entry in response.xml.findall("entry")]

# rag-project: src/services/__template__data_client.py
async def fetch_documents(self, query: str, limit: int = 10) -> List[Document]:
    """
    Fetch documents from your data source.

    TODO: Implement your data fetching logic.

    Examples:
    - REST API: requests.get(API_URL, headers={"Authorization": f"Bearer {API_KEY}"})
    - Database: await db.execute("SELECT * FROM documents WHERE ...")
    - Files: os.listdir(DATA_DIR) + open().read()
    """
    raise NotImplementedError("Implement your data source client")
```

#### Example 2: Model Generalization

```python
# arxiv-curator: src/models/paper.py
class Paper(BaseModel):
    arxiv_id: str = Field(..., description="ArXiv paper ID")
    title: str
    abstract: str
    authors: List[str] = Field(default_factory=list)
    categories: List[str] = Field(default_factory=list)
    published_date: datetime
    pdf_url: HttpUrl

# rag-project: src/models/document.py
class Document(BaseModel):
    """
    Generic document model for RAG system.

    CUSTOMIZE: Adapt fields to your domain.

    Examples:
    - News: category, author, publication, published_date
    - Products: sku, price, brand, category, in_stock
    - Docs: version, tags, related_docs
    """
    id: str = Field(..., description="Unique document identifier")
    title: str
    content: str = Field(..., description="Main document content")
    metadata: Dict[str, Any] = Field(default_factory=dict,
                                      description="Domain-specific fields")
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    source_url: Optional[HttpUrl] = None

    # TODO: Add your domain-specific fields below
```

#### Example 3: Configuration Updates

```python
# arxiv-curator: src/config.py
class Settings(BaseSettings):
    # ArXiv API Configuration
    ARXIV_API_BASE_URL: str = "http://export.arxiv.org/api"
    ARXIV_MAX_RESULTS: int = 100
    ARXIV_SORT_BY: str = "relevance"
    ARXIV_SORT_ORDER: str = "descending"

    # OpenSearch (keep)
    OPENSEARCH_HOST: str = "opensearch"
    OPENSEARCH_PORT: int = 9200

# rag-project: config/settings.py
class Settings(BaseSettings):
    # OpenSearch Configuration (kept)
    OPENSEARCH__HOST: str = "opensearch"
    OPENSEARCH__PORT: int = 9200
    OPENSEARCH__INDEX_NAME: str = "documents"  # Was: papers

    # Ollama Configuration (kept)
    OLLAMA__HOST: str = "ollama"
    OLLAMA__PORT: int = 11434

    # TODO: Data Source Configuration
    # Add your data source configuration here:
    # API_KEY: str
    # DATABASE_URL: str
    # FILE_PATH: str
```

### Docker Compose Merge Strategy

**Final docker-compose.yml includes:**

```yaml
version: '3.8'

services:
  api:
    build: .
    ports: ["8000:8000"]
    depends_on:
      - opensearch
      - ollama
    volumes:
      - ./src:/app/src  # Hot reload
    env_file: .env

  opensearch:
    image: opensearchproject/opensearch:2.19.0
    ports: ["9200:9200"]
    environment:
      - discovery.type=single-node
      - OPENSEARCH_JAVA_OPTS=-Xms512m -Xmx512m
      - DISABLE_SECURITY_PLUGIN=true
    volumes:
      - opensearch_data:/usr/share/opensearch/data
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:9200/_cluster/health"]

  ollama:
    image: ollama/ollama:latest
    ports: ["11434:11434"]
    volumes:
      - ollama_data:/root/.ollama

  # Optional: Redis for caching (via --profile caching)
  redis:
    image: redis:7-alpine
    ports: ["6379:6379"]
    volumes:
      - redis_data:/data
    profiles:
      - caching

volumes:
  opensearch_data:
  ollama_data:
  redis_data:
```

### Success Metrics

**Archetype Quality Indicators:**

1. **Time to Working Project:** <60 seconds from `create-project.sh` to running API
2. **Customization Clarity:** All TODO comments clear with examples
3. **Documentation Completeness:** README has Quick Start + 4 customization areas
4. **Test Coverage:** All template tests pass with mocks
5. **Production Readiness:** Docker health checks, resource limits, graceful shutdown

### References

- **Original Project:** <https://github.com/mazelb/arxiv-paper-curator>
- **Full Analysis:** `docs/ARXIV_CURATOR_MERGE_STRATEGIES.md` (1588 lines)
- **Archetype Metadata Schema:** See Phase 1.3 in main document

---

**Document Version:** 1.0
**Last Updated:** November 19, 2025
**Status:** Ready for Implementation
**Estimated Completion:** 8-10 weeks
