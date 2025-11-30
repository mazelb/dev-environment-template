# Multi-Archetype Composition System Design

**Version:** 1.0
**Date:** November 19, 2025
**Status:** Design Complete - Ready for Implementation

---

## Executive Summary

This document defines a comprehensive system for combining multiple archetypes into a single project within the dev-environment-template. The design supports three composition strategies with automatic conflict resolution, enabling users to create complex projects like "RAG + Agentic" or "API Service + Monitoring" without manual configuration.

**Key Innovation:** Layered composition with automatic port offsetting, service namespacing, and intelligent file merging.

---

## Table of Contents

1. [Problem Analysis](#1-problem-analysis)
2. [Composition Strategies](#2-composition-strategies)
3. [Conflict Resolution Mechanisms](#3-conflict-resolution-mechanisms)
4. [Archetype Metadata Schema](#4-archetype-metadata-schema)
5. [Implementation Architecture](#5-implementation-architecture)
6. [Practical Examples](#6-practical-examples)
7. [User Experience Design](#7-user-experience-design)
8. [Implementation Plan](#8-implementation-plan)

---

## 1. Problem Analysis

### 1.1 Identified Conflict Categories

When combining archetypes, six major conflict types can occur:

#### A. Port Conflicts
**Example:**
- RAG project: FastAPI on 8000, OpenSearch on 9200
- Agentic project: FastAPI on 8000, Airflow on 8080
- **Conflict:** Both use port 8000

**Impact:** Docker Compose fails to start services

#### B. Docker Service Name Collisions
**Example:**
- RAG project defines `opensearch` service
- Monitoring project defines `opensearch` service
- **Conflict:** Same service name, different configurations

**Impact:** Later service overwrites earlier one

#### C. Python Package Version Conflicts
**Example:**
- RAG project: `langchain==0.1.0`
- Agentic project: `langchain==0.2.0`
- **Conflict:** Incompatible versions

**Impact:** Installation fails or runtime errors

#### D. Configuration File Overlaps
**Example:**
- RAG project: `.env` with `OPENAI_API_KEY`
- Agentic project: `.env` with `ANTHROPIC_API_KEY`
- **Conflict:** Both want to create `.env`

**Impact:** Later file overwrites earlier (data loss)

#### E. Directory Structure Conflicts
**Example:**
- RAG project: `src/api/routers/search.py`
- Agentic project: `src/api/routers/agents.py`
- **Conflict:** Both create `src/api/routers/`

**Impact:** Merge required, not replacement

#### F. Makefile Command Conflicts
**Example:**
- RAG project: `make run` → runs RAG API
- Agentic project: `make run` → runs agent orchestrator
- **Conflict:** Same command, different behavior

**Impact:** User confusion, unpredictable behavior

### 1.2 Current Template Limitations

**Existing Mechanism (Presets):**
```bash
./create-project.sh --name myapp --preset ai-agent
```
- ✅ Installs Python packages
- ✅ Adds Docker services
- ❌ No conflict detection
- ❌ No multi-preset support
- ❌ No project structure scaffolding

**Gap:** Presets install tools, archetypes scaffold projects. Neither supports composition.

---

## 2. Composition Strategies

### Strategy 1: Layered Composition (RECOMMENDED)

**Concept:** Base archetype + feature archetypes with automatic namespacing

**Syntax:**
```bash
./create-project.sh --name myapp \
  --archetype rag-project \
  --add-features agentic-workflows,monitoring
```

**Behavior:**
1. Install **base archetype** fully (RAG project structure)
2. Add **feature archetypes** with automatic conflict resolution:
   - Ports get offsets (`+100` per feature)
   - Services get prefixes (`agentic_`, `monitoring_`)
   - Makefiles get namespaced commands (`make rag-run`, `make agentic-run`)

**Advantages:**
- ✅ Clear primary purpose (base archetype)
- ✅ Features are additive, not competitive
- ✅ Predictable conflict resolution
- ✅ Easy to understand for users

**Disadvantages:**
- ❌ Base archetype must be specified first
- ❌ Less flexible than modular approach

**Use Cases:**
- RAG + Monitoring (base: RAG, feature: monitoring)
- API Service + Agentic (base: API, feature: agentic)
- ML Training + MLOps (base: training, feature: mlops)

---

### Strategy 2: Modular Composition

**Concept:** Multiple equal archetypes merge with priority rules

**Syntax:**
```bash
./create-project.sh --name myapp \
  --archetypes rag-project,agentic-project \
  --priority rag-project
```

**Behavior:**
1. Load all archetypes in parallel
2. Detect conflicts across all archetypes
3. Apply priority-based resolution (first archetype wins for ambiguous conflicts)
4. Merge compatible components

**Advantages:**
- ✅ No artificial base/feature distinction
- ✅ Maximum flexibility
- ✅ Supports symmetric composition (2 APIs, 2 workers)

**Disadvantages:**
- ❌ Complex conflict resolution logic
- ❌ Requires explicit priority specification
- ❌ Harder for users to predict outcome

**Use Cases:**
- Multi-API system (2+ API archetypes)
- Polyglot projects (Python + Node.js archetypes)
- Distributed system (multiple service archetypes)

---

### Strategy 3: Composite Archetypes (Pre-Packaged)

**Concept:** Maintain pre-defined archetype combinations

**Syntax:**
```bash
./create-project.sh --name myapp \
  --archetype rag-agentic-system
```

**Behavior:**
1. Load composite archetype definition
2. Install all constituent archetypes
3. Apply pre-resolved conflicts (maintained by archetype author)

**Advantages:**
- ✅ Zero user configuration
- ✅ Tested and validated combinations
- ✅ Fast setup
- ✅ Best practices baked in

**Disadvantages:**
- ❌ Limited to pre-defined combinations
- ❌ Requires maintenance of composite archetypes
- ❌ Less flexible

**Use Cases:**
- Common patterns (RAG + Agentic, API + Auth, ML + Monitoring)
- Production-ready stacks
- Enterprise templates

---

### Recommended Hybrid Approach

**Primary:** Strategy 1 (Layered Composition)
**Secondary:** Strategy 3 (Composite Archetypes for common patterns)
**Advanced:** Strategy 2 (Modular Composition for power users)

**Implementation Priority:**
1. Layered Composition (80% of use cases)
2. Composite Archetypes (15% of use cases)
3. Modular Composition (5% of use cases, future enhancement)

---

## 3. Conflict Resolution Mechanisms

### 3.1 Port Conflict Resolution

**Strategy: Automatic Port Offsetting**

```yaml
# Base archetype (rag-project)
services:
  rag-api:
    ports:
      - "8000:8000"
  opensearch:
    ports:
      - "9200:9200"

# Feature archetype (agentic-workflows) with offset +100
services:
  agentic-api:
    ports:
      - "8100:8000"  # External: 8100, Internal: 8000
  airflow-webserver:
    ports:
      - "8180:8080"  # External: 8180, Internal: 8080
```

**Algorithm:**
```python
def resolve_port_conflict(base_ports, feature_ports, offset=100):
    """
    Apply port offset to feature archetype.
    Keep internal ports unchanged, modify external ports.
    """
    for service, port_mappings in feature_ports.items():
        for i, port_map in enumerate(port_mappings):
            external, internal = port_map.split(':')
            new_external = int(external) + offset
            feature_ports[service][i] = f"{new_external}:{internal}"
    return feature_ports
```

**Configuration:**
```json
{
  "composition": {
    "port_offset_strategy": "incremental",
    "port_offset_increment": 100,
    "max_archetypes": 10
  }
}
```

---

### 3.2 Service Name Collision Resolution

**Strategy: Namespace Prefixing**

```yaml
# Base archetype (rag-project)
services:
  api:
    container_name: myapp-rag-api
  opensearch:
    container_name: myapp-rag-opensearch

# Feature archetype (agentic-workflows)
services:
  agentic_api:
    container_name: myapp-agentic-api
  agentic_airflow:
    container_name: myapp-agentic-airflow
```

**Naming Convention:**
```
{project_name}-{archetype_prefix}-{service_name}
```

**Archetype Metadata:**
```json
{
  "name": "agentic-workflows",
  "service_prefix": "agentic",
  "services": {
    "api": { "..." },
    "airflow": { "..." }
  }
}
```

**Environment Variable Translation:**
```yaml
# Base archetype
services:
  api:
    environment:
      - OPENSEARCH_HOST=opensearch

# Feature archetype (auto-translated)
services:
  agentic_api:
    environment:
      - AIRFLOW_HOST=agentic_airflow  # prefix applied
```

---

### 3.3 Python Package Version Conflicts

**Strategy: Dependency Constraint Resolution**

**Metadata Declaration:**
```json
{
  "dependencies": {
    "python": {
      "langchain": ">=0.1.0,<0.3.0",
      "fastapi": "^0.104.0",
      "pydantic": "~2.5.0"
    }
  },
  "conflicts": {
    "openai": ["<1.0.0", ">=2.0.0"]
  }
}
```

**Resolution Algorithm:**
```python
def resolve_dependency_conflicts(archetypes):
    """
    Use Poetry/pip-tools resolver to find compatible versions.
    """
    all_deps = {}

    for archetype in archetypes:
        for pkg, version_spec in archetype['dependencies']['python'].items():
            if pkg in all_deps:
                # Find intersection of version specs
                all_deps[pkg] = intersect_version_specs(
                    all_deps[pkg],
                    version_spec
                )
            else:
                all_deps[pkg] = version_spec

    # Check for conflicts
    for pkg, spec in all_deps.items():
        if not has_valid_version(spec):
            raise ConflictError(f"No version of {pkg} satisfies {spec}")

    return all_deps
```

**Fallback Strategies:**
1. **Pin to latest compatible version** (if intersection exists)
2. **Warn and use base archetype version** (if incompatible)
3. **Create virtual environment per archetype** (advanced, future)

---

### 3.4 Configuration File Merging

**Strategy: Layered Configuration Files**

**File Types & Merge Strategies:**

| File Type | Merge Strategy | Example |
|-----------|----------------|---------|
| `.env` | Append with comments | All vars combined |
| `docker-compose.yml` | Deep merge | Services + volumes merged |
| `requirements.txt` | Deduplicate + resolve | Conflict resolution |
| `Makefile` | Namespace targets | `rag-run`, `agentic-run` |
| `.gitignore` | Append + deduplicate | All patterns combined |
| `README.md` | Section append | Each archetype gets section |
| `pyproject.toml` | Deep merge + resolve | Dependencies merged |

**Example: `.env` Merging**

```bash
# Base archetype (rag-project)
# ===== RAG Configuration =====
OPENAI_API_KEY=your_key
OPENSEARCH_HOST=opensearch
OPENSEARCH_PORT=9200

# Feature archetype (agentic-workflows)
# ===== Agentic Configuration =====
ANTHROPIC_API_KEY=your_key
AIRFLOW_HOST=agentic_airflow
AIRFLOW_PORT=8080

# Shared (no conflict)
LOG_LEVEL=INFO
```

**Example: `Makefile` Namespacing**

```makefile
# Base archetype (rag-project)
.PHONY: rag-run rag-test rag-lint

rag-run:
	docker-compose up -d rag-api opensearch

rag-test:
	pytest tests/rag/ -v

# Feature archetype (agentic-workflows)
.PHONY: agentic-run agentic-test

agentic-run:
	docker-compose up -d agentic_api agentic_airflow

agentic-test:
	pytest tests/agentic/ -v

# Combined
.PHONY: run test

run: rag-run agentic-run

test: rag-test agentic-test
```

---

### 3.5 Directory Structure Merging

**Strategy: Recursive Merge with Conflict Detection**

**Scenarios:**

| Scenario | Action | Example |
|----------|--------|---------|
| Unique directories | Copy | `base:src/rag/` + `feature:src/agentic/` → Both exist |
| Same directory, different files | Merge | `base:src/api/routes/search.py` + `feature:src/api/routes/agents.py` |
| Same file, different content | Prompt user or use rules | `base:src/api/main.py` vs `feature:src/api/main.py` |
| Same file, identical content | Skip duplicate | Both have same `.gitignore` |

**Merge Rules for Source Files:**

```json
{
  "merge_rules": {
    "src/api/main.py": {
      "strategy": "merge_imports_and_routers",
      "template": "base_main_py_template.jinja2"
    },
    "src/api/routers/": {
      "strategy": "collect_all",
      "conflict_action": "rename_duplicate"
    },
    "tests/": {
      "strategy": "separate_by_archetype",
      "pattern": "tests/{archetype_name}/"
    }
  }
}
```

**Example: FastAPI `main.py` Merging**

```python
# Base archetype (rag-project)
from fastapi import FastAPI
from src.api.routers import search

app = FastAPI(title="RAG API")
app.include_router(search.router)

# Feature archetype (agentic-workflows)
from fastapi import FastAPI
from src.api.routers import agents

app = FastAPI(title="Agentic API")
app.include_router(agents.router)

# Merged result
from fastapi import FastAPI
from src.api.routers import search, agents

app = FastAPI(title="RAG + Agentic System")
app.include_router(search.router, prefix="/rag")
app.include_router(agents.router, prefix="/agentic")
```

---

### 3.6 Makefile Command Conflicts

**Strategy: Namespace + Composite Commands**

**Implementation:**
```makefile
# Rule: Prefix archetype-specific commands with archetype name
# Rule: Create composite commands without prefix

# RAG-specific
.PHONY: rag-start rag-stop rag-test rag-logs

rag-start:
	docker-compose up -d rag-api opensearch

# Agentic-specific
.PHONY: agentic-start agentic-stop agentic-test agentic-logs

agentic-start:
	docker-compose up -d agentic_api agentic_airflow

# Composite commands (no prefix)
.PHONY: start stop test logs

start: rag-start agentic-start
	@echo "✓ All services started"

stop: rag-stop agentic-stop
	@echo "✓ All services stopped"

test: rag-test agentic-test
	@echo "✓ All tests completed"

logs:
	docker-compose logs -f
```

**User Experience:**
```bash
# Start everything
make start

# Start just RAG
make rag-start

# Run all tests
make test

# Run just agentic tests
make agentic-test
```

---

## 4. Archetype Metadata Schema

### 4.1 Enhanced `__archetype__.json`

```json
{
  "version": "2.0",
  "metadata": {
    "name": "rag-project",
    "display_name": "RAG (Retrieval-Augmented Generation) Project",
    "description": "Complete RAG system with vector search, embeddings, and API",
    "version": "1.0.0",
    "author": "Dev Environment Template Team",
    "tags": ["ai", "rag", "search", "embeddings"],
    "archetype_type": "base"
  },

  "composition": {
    "role": "base",
    "compatible_features": ["monitoring", "agentic-workflows", "api-gateway"],
    "incompatible_with": ["simple-api"],
    "composable": true,
    "merge_priority": 1,
    "service_prefix": "rag",
    "port_offset": 0
  },

  "dependencies": {
    "preset": "ai-agent",
    "additional_tools": ["opensearch", "ollama"],
    "python": {
      "langchain": ">=0.1.0,<0.3.0",
      "fastapi": "^0.104.0",
      "opensearch-py": "^2.3.0"
    },
    "system": ["docker-compose>=2.0", "python>=3.11"]
  },

  "conflicts": {
    "declare": {
      "ports": [8000, 9200, 11434],
      "services": ["api", "opensearch", "ollama"],
      "environment_vars": ["OPENAI_API_KEY", "OPENSEARCH_HOST"]
    },
    "resolution": {
      "ports": "offset",
      "services": "prefix",
      "environment_vars": "merge"
    }
  },

  "services": {
    "api": {
      "dockerfile": "Dockerfile",
      "ports": ["8000:8000"],
      "environment": {
        "OPENSEARCH_HOST": "opensearch",
        "OLLAMA_HOST": "ollama"
      },
      "depends_on": ["opensearch", "ollama"]
    },
    "opensearch": {
      "image": "opensearchproject/opensearch:2.11.0",
      "ports": ["9200:9200"],
      "environment": {
        "discovery.type": "single-node"
      }
    }
  },

  "structure": {
    "directories": [
      "src/api",
      "src/services",
      "src/models",
      "tests/unit",
      "tests/integration",
      "docker",
      "docs"
    ],
    "files": {
      "src/api/main.py": {
        "merge_strategy": "smart_merge",
        "priority": 1
      },
      ".env": {
        "merge_strategy": "append",
        "conflict_action": "merge"
      },
      "Makefile": {
        "merge_strategy": "namespace",
        "namespace_commands": true
      }
    }
  },

  "documentation": {
    "readme_section": "docs/README_RAG.md",
    "setup_guide": "docs/SETUP_RAG.md",
    "examples": ["examples/rag-basic/", "examples/rag-advanced/"]
  },

  "cli": {
    "post_install_commands": [
      "pip install -r requirements-rag.txt",
      "python scripts/setup_opensearch.py"
    ],
    "pre_start_checks": [
      "check_opensearch_connection",
      "check_ollama_models"
    ]
  }
}
```

### 4.2 Feature Archetype Metadata

```json
{
  "version": "2.0",
  "metadata": {
    "name": "agentic-workflows",
    "display_name": "Agentic Workflows (Multi-Agent Orchestration)",
    "archetype_type": "feature"
  },

  "composition": {
    "role": "feature",
    "requires_base": true,
    "compatible_bases": ["rag-project", "api-service", "ml-training"],
    "composable": true,
    "merge_priority": 2,
    "service_prefix": "agentic",
    "port_offset": 100
  },

  "dependencies": {
    "additional_tools": ["airflow", "langfuse"],
    "python": {
      "langchain": ">=0.2.0",
      "apache-airflow": "^2.7.0"
    }
  },

  "conflicts": {
    "declare": {
      "ports": [8000, 8080, 5555],
      "services": ["api", "airflow"]
    },
    "resolution": {
      "ports": "offset",
      "services": "prefix"
    }
  }
}
```

### 4.3 Composite Archetype Metadata

```json
{
  "version": "2.0",
  "metadata": {
    "name": "rag-agentic-system",
    "display_name": "RAG + Agentic System (Pre-configured)",
    "archetype_type": "composite"
  },

  "composition": {
    "role": "composite",
    "constituents": [
      {
        "archetype": "rag-project",
        "role": "base"
      },
      {
        "archetype": "agentic-workflows",
        "role": "feature",
        "port_offset": 100
      }
    ],
    "pre_resolved_conflicts": true,
    "custom_integrations": [
      "scripts/integrate_rag_agentic.sh"
    ]
  },

  "documentation": {
    "readme_section": "docs/README_RAG_AGENTIC.md",
    "examples": ["examples/rag-agentic-chatbot/"]
  }
}
```

---

## 5. Implementation Architecture

### 5.1 Enhanced `create-project.sh` Workflow

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Parse CLI Arguments                                      │
│    --name, --archetype, --add-features, --archetypes       │
└─────────────────────────────────┬───────────────────────────┘
                                  │
┌─────────────────────────────────▼───────────────────────────┐
│ 2. Load Archetype Metadata                                  │
│    - Read __archetype__.json for base + features            │
│    - Validate compatibility                                 │
│    - Check system dependencies                              │
└─────────────────────────────────┬───────────────────────────┘
                                  │
┌─────────────────────────────────▼───────────────────────────┐
│ 3. Conflict Detection                                       │
│    - Scan for port conflicts                                │
│    - Check service name collisions                          │
│    - Analyze dependency constraints                         │
│    - Identify file overlaps                                 │
└─────────────────────────────────┬───────────────────────────┘
                                  │
                     ┌────────────▼────────────┐
                     │ Conflicts Found?        │
                     └─────┬─────────┬─────────┘
                           │ YES     │ NO
              ┌────────────▼──┐      │
              │ 4a. Resolve   │      │
              │  - Apply      │      │
              │    offsets    │      │
              │  - Namespace  │      │
              │  - Merge      │      │
              └────────┬──────┘      │
                       │             │
                       └─────┬───────┘
                             │
┌─────────────────────────────▼───────────────────────────────┐
│ 5. Copy Base Archetype                                      │
│    - Template files (.vscode, docker-compose.yml, etc.)     │
│    - Archetype structure (src/, tests/, docker/)            │
│    - Configuration files (.env, Makefile)                   │
└─────────────────────────────────┬───────────────────────────┘
                                  │
┌─────────────────────────────────▼───────────────────────────┐
│ 6. Merge Feature Archetypes                                 │
│    - Apply port offsets                                     │
│    - Prefix service names                                   │
│    - Merge docker-compose services                          │
│    - Namespace Makefile commands                            │
│    - Merge .env files                                       │
│    - Smart merge source files (main.py, etc.)               │
└─────────────────────────────────┬───────────────────────────┘
                                  │
┌─────────────────────────────────▼───────────────────────────┐
│ 7. Install Dependencies                                     │
│    - Resolve Python package versions                        │
│    - Generate requirements.txt                              │
│    - Install optional tools                                 │
└─────────────────────────────────┬───────────────────────────┘
                                  │
┌─────────────────────────────────▼───────────────────────────┐
│ 8. Generate Documentation                                   │
│    - Merge README sections                                  │
│    - Create COMPOSITION.md (multi-archetype guide)          │
│    - List all services & ports                              │
└─────────────────────────────────┬───────────────────────────┘
                                  │
┌─────────────────────────────────▼───────────────────────────┐
│ 9. Post-Install Hooks                                       │
│    - Run archetype-specific setup scripts                   │
│    - Initialize databases                                   │
│    - Pull Docker images                                     │
└─────────────────────────────────┬───────────────────────────┘
                                  │
                         ┌────────▼────────┐
                         │ 10. Git Init    │
                         │  (automatic)    │
                         └────────┬────────┘
                                  │
                         ┌────────▼────────┐
                         │ 11. GitHub Repo │
                         │  (if --github)  │
                         └────────┬────────┘
                                  │
                         ┌────────▼────────┐
                         │ 12. Success!    │
                         │  Display summary│
                         └─────────────────┘
```

### 5.2 Script Structure

**New Files:**
```
create-project.sh                    # Enhanced main script
scripts/
├── archetype-loader.sh              # Load & validate archetype metadata
├── conflict-resolver.sh             # Detect & resolve conflicts
├── docker-compose-merger.sh         # Merge Docker Compose files
├── makefile-merger.sh               # Merge & namespace Makefiles
├── env-merger.sh                    # Merge .env files
├── source-file-merger.sh            # Smart merge for Python/Node files
└── documentation-generator.sh       # Generate multi-archetype docs
```

**Example Function:**
```bash
# scripts/conflict-resolver.sh

detect_port_conflicts() {
    local base_archetype=$1
    local feature_archetypes=$2
    local conflicts=()

    # Extract ports from base
    base_ports=$(jq -r '.conflicts.declare.ports[]' \
        "archetypes/$base_archetype/__archetype__.json")

    # Check each feature
    for feature in $feature_archetypes; do
        feature_ports=$(jq -r '.conflicts.declare.ports[]' \
            "archetypes/$feature/__archetype__.json")

        # Find intersections
        for port in $feature_ports; do
            if [[ " ${base_ports[@]} " =~ " ${port} " ]]; then
                conflicts+=("$feature:$port")
            fi
        done
    done

    if [ ${#conflicts[@]} -gt 0 ]; then
        echo "Port conflicts detected: ${conflicts[@]}"
        return 1
    fi

    return 0
}

resolve_port_conflicts() {
    local feature=$1
    local offset=$2
    local compose_file="docker-compose.$feature.yml"

    # Apply offset to all external ports
    yq eval ".services[].ports[] |=
        sub(\"^([0-9]+):\", (([0-9]+) + $offset | tostring) + \":\")" \
        -i "$compose_file"
}
```

### 5.3 Docker Compose Merging

**Strategy: Generate layered compose files**

```bash
# Final docker-compose usage
docker-compose \
    -f docker-compose.yml \
    -f docker-compose.rag.yml \
    -f docker-compose.agentic.yml \
    up -d
```

**Generated Files:**
- `docker-compose.yml` - Base template services (postgres, redis)
- `docker-compose.rag.yml` - RAG-specific services (opensearch, ollama)
- `docker-compose.agentic.yml` - Agentic services (airflow, langfuse)

**Makefile Integration:**
```makefile
COMPOSE_FILES := -f docker-compose.yml
COMPOSE_FILES += -f docker-compose.rag.yml
COMPOSE_FILES += -f docker-compose.agentic.yml

start:
	docker-compose $(COMPOSE_FILES) up -d
```

---

## 6. Practical Examples

### 6.1 Example 1: RAG + Agentic

**Scenario:** Search backend with autonomous agents

**Command:**
```bash
./create-project.sh --name rag-agent-system \
  --archetype rag-project \
  --add-features agentic-workflows
```

**Result:**
```
rag-agent-system/
├── src/
│   ├── api/
│   │   ├── main.py                 # Merged FastAPI app
│   │   └── routers/
│   │       ├── search.py           # From rag-project
│   │       └── agents.py           # From agentic-workflows
│   ├── services/
│   │   ├── rag/                    # RAG services
│   │   │   ├── embedding_service.py
│   │   │   └── search_service.py
│   │   └── agentic/                # Agentic services
│   │       ├── agent_orchestrator.py
│   │       └── workflow_engine.py
│   └── models/
│       ├── documents.py
│       └── agents.py
├── docker-compose.yml              # Base services
├── docker-compose.rag.yml          # Ports: 8000, 9200, 11434
├── docker-compose.agentic.yml      # Ports: 8100, 8180, 5555
├── Makefile                        # Namespaced commands
├── .env                            # Merged configuration
└── COMPOSITION.md                  # Multi-archetype guide
```

**Services & Ports:**
| Service | Port | Archetype | Description |
|---------|------|-----------|-------------|
| rag-api | 8000 | RAG | RAG API endpoints |
| opensearch | 9200 | RAG | Vector search |
| ollama | 11434 | RAG | Embeddings |
| agentic-api | 8100 | Agentic | Agent API |
| airflow-webserver | 8180 | Agentic | Workflow UI |
| airflow-scheduler | - | Agentic | Task scheduler |

**Makefile Commands:**
```bash
make start              # Start all services
make rag-run            # Run RAG API only
make agentic-run        # Run agentic services only
make test               # Run all tests
make rag-test           # Test RAG components
make agentic-test       # Test agentic components
```

**Generated Documentation:**
```markdown
# RAG + Agentic System

This project combines:
1. **RAG Project** - Vector search and retrieval
2. **Agentic Workflows** - Multi-agent orchestration

## Services

### RAG Services
- API: http://localhost:8000
- OpenSearch: http://localhost:9200
- Ollama: http://localhost:11434

### Agentic Services
- API: http://localhost:8100
- Airflow: http://localhost:8180

## Quick Start

```bash
# Start all services
make start

# Check status
docker-compose ps

# View logs
make logs
```
```

---

### 6.2 Example 2: RAG + API Gateway + Monitoring

**Scenario:** Production RAG with API gateway and observability

**Command:**
```bash
./create-project.sh --name rag-prod \
  --archetype rag-project \
  --add-features api-gateway,monitoring
```

**Result:**
```
rag-prod/
├── docker-compose.yml              # Base
├── docker-compose.rag.yml          # Ports: 8000, 9200
├── docker-compose.gateway.yml      # Port: 8200 (gateway)
├── docker-compose.monitoring.yml   # Ports: 9090, 3000, 8300
└── nginx/
    └── gateway.conf                # API gateway config
```

**Architecture:**
```
Internet
    │
    ▼
[API Gateway :8200] ─────────┐
    │                        │
    ├──────► [RAG API :8000] │
    │                        │
    └──────► [Monitoring]    │
                 │           │
                 ▼           │
         [Prometheus :9090]  │
         [Grafana :3000]     │
                             │
                             ▼
                    [OpenSearch :9200]
```

**Features:**
- ✅ Rate limiting (API Gateway)
- ✅ Authentication (API Gateway)
- ✅ Metrics collection (Prometheus)
- ✅ Dashboards (Grafana)
- ✅ Vector search (OpenSearch)

---

### 6.3 Example 3: ML Training + Agentic

**Scenario:** Agents that train and deploy models

**Command:**
```bash
./create-project.sh --name ml-agents \
  --archetype ml-training \
  --add-features agentic-workflows
```

**Use Case:**
1. **ML Training Archetype:**
   - Jupyter notebooks for experiments
   - MLflow for tracking
   - Training pipelines

2. **Agentic Feature:**
   - Agents monitor training
   - Auto-tune hyperparameters
   - Deploy successful models

**Workflow:**
```
Agent monitors training
    ▼
Detects low accuracy
    ▼
Triggers hyperparameter search
    ▼
Finds better config
    ▼
Retrains model
    ▼
Auto-deploys if accuracy > threshold
```

---

### 6.4 Example 4: Multi-API System (Modular Composition)

**Scenario:** Microservices with 3 separate APIs

**Command:**
```bash
./create-project.sh --name microservices \
  --archetypes api-service,api-service,api-service \
  --service-names auth-api,user-api,payment-api \
  --priority auth-api
```

**Result:**
```
microservices/
├── docker-compose.auth.yml         # Port: 8000
├── docker-compose.user.yml         # Port: 8100
├── docker-compose.payment.yml      # Port: 8200
├── src/
│   ├── auth/
│   ├── user/
│   └── payment/
└── Makefile
```

**Services:**
| Service | Port | Role |
|---------|------|------|
| auth-api | 8000 | Authentication |
| user-api | 8100 | User management |
| payment-api | 8200 | Payment processing |

---

### 6.5 Example 5: Composite Archetype

**Scenario:** Pre-packaged RAG + Agentic system

**Command:**
```bash
./create-project.sh --name my-system \
  --archetype rag-agentic-system
```

**Advantages:**
- ✅ Zero configuration
- ✅ Pre-tested integration
- ✅ Custom integration scripts
- ✅ Optimized for common use case

**Behind the scenes:**
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

---

## 7. User Experience Design

### 7.1 Discovering Compatible Archetypes

**Command:**
```bash
./create-project.sh --list-archetypes
```

**Output:**
```
Available Archetypes:

BASE ARCHETYPES (choose one):
  rag-project           RAG with vector search
  api-service           Production FastAPI service
  ml-training           ML training pipelines
  data-pipeline         ETL workflows

FEATURE ARCHETYPES (add to base):
  agentic-workflows     Multi-agent orchestration
  monitoring            Prometheus + Grafana
  api-gateway           NGINX gateway with auth
  mlops                 MLflow + model registry

COMPOSITE ARCHETYPES (pre-configured):
  rag-agentic-system    RAG + Agents (optimized)
  api-auth-monitoring   API + Auth + Monitoring
  ml-agent-system       ML Training + Agents

Use: ./create-project.sh --archetype <base> --add-features <features>
```

**Check Compatibility:**
```bash
./create-project.sh --check-compatibility \
  --archetype rag-project \
  --add-features agentic-workflows,monitoring
```

**Output:**
```
✓ rag-project + agentic-workflows: COMPATIBLE
✓ rag-project + monitoring: COMPATIBLE
✓ agentic-workflows + monitoring: COMPATIBLE

Potential Conflicts:
  ⚠ Port conflict: Both rag-project and agentic-workflows use 8000
     → Resolution: agentic-workflows API will use 8100

Services:
  rag-project:
    - rag-api:8000
    - opensearch:9200
    - ollama:11434

  agentic-workflows (with offset +100):
    - agentic-api:8100
    - airflow:8180
    - flower:5655

  monitoring:
    - prometheus:9090
    - grafana:3000
    - alertmanager:9093

Total ports needed: 9
Estimated disk space: 8GB
Estimated memory: 12GB
```

---

### 7.2 Preview Before Creation

**Command:**
```bash
./create-project.sh --name my-app \
  --archetype rag-project \
  --add-features agentic-workflows \
  --dry-run
```

**Output:**
```
Project Preview: my-app

Base Archetype: rag-project (v1.0.0)
Features: agentic-workflows (v1.0.0)

Directory Structure:
  my-app/
  ├── src/
  │   ├── api/               (merged from both)
  │   ├── services/
  │   │   ├── rag/          (from rag-project)
  │   │   └── agentic/      (from agentic-workflows)
  │   └── models/
  ├── tests/
  │   ├── rag/              (from rag-project)
  │   └── agentic/          (from agentic-workflows)
  ├── docker/
  │   ├── opensearch/
  │   └── airflow/
  ├── docker-compose.yml
  ├── docker-compose.rag.yml
  ├── docker-compose.agentic.yml
  └── Makefile              (merged with namespaces)

Services:
  [RAG]       rag-api:8000
  [RAG]       opensearch:9200
  [RAG]       ollama:11434
  [Agentic]   agentic-api:8100
  [Agentic]   airflow-webserver:8180
  [Agentic]   airflow-scheduler:-

Dependencies:
  Python packages: 47 packages
  System: docker-compose>=2.0, python>=3.11

Disk space: ~6GB
Memory: ~10GB

Proceed? [y/N]
```

---

### 7.3 Interactive Conflict Resolution

**Scenario:** User creates a project with a minor conflict

**Command:**
```bash
./create-project.sh --name my-app \
  --archetype rag-project \
  --add-features custom-feature
```

**Interactive Prompt:**
```
⚠ Conflict Detected: Python Package Version

Both archetypes require 'langchain' with incompatible versions:
  - rag-project: langchain==0.1.0
  - custom-feature: langchain==0.2.0

Choose resolution:
  1. Use rag-project version (0.1.0) [default]
  2. Use custom-feature version (0.2.0)
  3. Try to find compatible version (0.1.5)
  4. Install both in separate virtual environments (advanced)
  5. Abort

Selection [1]: 3

✓ Found compatible version: langchain==0.1.5
  Satisfies: >=0.1.0,<0.3.0

Continue? [Y/n]
```

---

### 7.4 Documentation for Multi-Archetype Projects

**Generated File: `COMPOSITION.md`**

```markdown
# Project Composition Guide

This project combines multiple archetypes:

## Archetypes Used

### Base: rag-project (v1.0.0)
- **Purpose:** Vector search and retrieval
- **Services:** opensearch, ollama, rag-api
- **Ports:** 8000, 9200, 11434
- **Commands:** `make rag-run`, `make rag-test`

### Feature: agentic-workflows (v1.0.0)
- **Purpose:** Multi-agent orchestration
- **Services:** airflow, agentic-api
- **Ports:** 8100, 8180
- **Commands:** `make agentic-run`, `make agentic-test`

## Architecture Overview

```
┌─────────────────────────────────────┐
│ RAG API (:8000)                     │
│ - Search endpoints                  │
│ - Document retrieval                │
└─────────────┬───────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│ OpenSearch (:9200)                  │
│ - Vector store                      │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ Agentic API (:8100)                 │
│ - Agent management                  │
│ - Workflow execution                │
└─────────────┬───────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│ Airflow (:8180)                     │
│ - Workflow UI                       │
│ - Task scheduling                   │
└─────────────────────────────────────┘
```

## Quick Start

### Start All Services
```bash
make start
# or
docker-compose -f docker-compose.yml \
               -f docker-compose.rag.yml \
               -f docker-compose.agentic.yml \
               up -d
```

### Start Individual Archetypes
```bash
# RAG only
make rag-run

# Agentic only
make agentic-run
```

### Run Tests
```bash
# All tests
make test

# RAG tests only
make rag-test

# Agentic tests only
make agentic-test
```

## Service URLs

| Service | URL | Archetype |
|---------|-----|-----------|
| RAG API | http://localhost:8000 | rag-project |
| OpenSearch | http://localhost:9200 | rag-project |
| Ollama | http://localhost:11434 | rag-project |
| Agentic API | http://localhost:8100 | agentic-workflows |
| Airflow | http://localhost:8180 | agentic-workflows |

## Environment Variables

### RAG Configuration
```bash
OPENAI_API_KEY=your_key
OPENSEARCH_HOST=opensearch
OPENSEARCH_PORT=9200
OLLAMA_HOST=ollama
OLLAMA_MODEL=llama2
```

### Agentic Configuration
```bash
ANTHROPIC_API_KEY=your_key
AIRFLOW_HOST=agentic_airflow
AIRFLOW_PORT=8080
LANGFUSE_PUBLIC_KEY=your_key
```

## Troubleshooting

### Port Already in Use
If you see "port already allocated" errors:
1. Check running containers: `docker ps`
2. Stop conflicting containers: `docker-compose down`
3. Or change ports in `.env` file

### Service Dependencies
Services start in this order:
1. OpenSearch (RAG)
2. Ollama (RAG)
3. Airflow DB (Agentic)
4. Airflow Scheduler (Agentic)
5. APIs (RAG & Agentic)

## Further Reading

- [RAG Documentation](docs/SETUP_RAG.md)
- [Agentic Documentation](docs/SETUP_AGENTIC.md)
- [API Reference](docs/API_REFERENCE.md)
```

---

## 8. Git Repository Integration

### 8.1 Automatic Git Initialization

**Philosophy:** Every project is a separate repository by default.

**Behavior:**
- Git initialization is **automatic** (no `--git` flag needed)
- Each project gets its own `.git` directory
- Projects are independent from the template repository
- Initial commit includes all archetype files

**Command:**
```bash
./create-project.sh --name my-rag-system \
  --archetype rag-project \
  --add-features agentic-workflows

# Result: New project with initialized Git repository
# - .git/ directory created
# - Initial commit with all files
# - Ready to push to GitHub
```

### 8.2 GitHub Repository Creation

**Single Command Setup:**
```bash
./create-project.sh --name my-rag-system \
  --archetype rag-project \
  --add-features agentic-workflows \
  --github \
  --github-org mycompany \
  --private

# Result:
# 1. Project created locally
# 2. Git repository initialized
# 3. GitHub repository created (github.com/mycompany/my-rag-system)
# 4. Local repo connected to GitHub
# 5. Initial commit pushed
# 6. Ready to develop!
```

**CLI Flags:**

| Flag | Description | Default |
|------|-------------|----------|
| `--github` | Create GitHub repository | `false` |
| `--github-org ORG` | GitHub organization/user | Current user |
| `--private` | Create private repository | `false` |
| `--public` | Create public repository | `true` |
| `--no-git` | Skip Git initialization | N/A (Git is default) |
| `--description TEXT` | Repository description | Auto-generated |
| `--github-push` | Push initial commit | `true` if `--github` |

### 8.3 GitHub CLI Integration

**Requirements:**
- GitHub CLI (`gh`) installed
- Authenticated: `gh auth login`

**Implementation:**
```bash
# scripts/github-repo-creator.sh

create_github_repo() {
    local project_name=$1
    local github_org=$2
    local visibility=$3  # public or private
    local description=$4
    local project_path=$5

    print_header "Creating GitHub Repository"

    # Check if gh is installed
    if ! command -v gh &> /dev/null; then
        print_error "GitHub CLI not found. Install: https://cli.github.com/"
        print_info "Skipping GitHub repository creation."
        return 1
    fi

    # Check authentication
    if ! gh auth status &> /dev/null; then
        print_error "GitHub CLI not authenticated. Run: gh auth login"
        return 1
    fi

    # Create repository
    print_info "Creating repository: $github_org/$project_name"

    cd "$project_path"

    if [ "$github_org" = "" ]; then
        # Create in personal account
        gh repo create "$project_name" \
            --$visibility \
            --description "$description" \
            --source=. \
            --remote=origin \
            --push
    else
        # Create in organization
        gh repo create "$github_org/$project_name" \
            --$visibility \
            --description "$description" \
            --source=. \
            --remote=origin \
            --push
    fi

    if [ $? -eq 0 ]; then
        print_success "GitHub repository created!"

        if [ "$github_org" = "" ]; then
            local user=$(gh api user -q .login)
            print_info "Repository URL: https://github.com/$user/$project_name"
        else
            print_info "Repository URL: https://github.com/$github_org/$project_name"
        fi
    else
        print_error "Failed to create GitHub repository"
        return 1
    fi
}
```

### 8.4 Workflow Examples

#### Example 1: Local Development (Git Only)
```bash
# Create project with Git
./create-project.sh --name my-project \
  --archetype rag-project

# Result:
# - my-project/ created
# - Git initialized
# - Initial commit made
# - Ready for local development

# Later, create GitHub repo manually:
cd my-project
gh repo create
```

#### Example 2: Personal GitHub Repository
```bash
# Create project + GitHub repo in one command
./create-project.sh --name my-rag-app \
  --archetype rag-project \
  --add-features monitoring \
  --github \
  --private

# Result:
# - my-rag-app/ created locally
# - Git initialized
# - GitHub repo created: github.com/YOUR_USERNAME/my-rag-app
# - Initial commit pushed
# - Clone URL available for team
```

#### Example 3: Organization Repository
```bash
# Create project in company organization
./create-project.sh --name customer-search-rag \
  --archetype rag-project \
  --add-features agentic-workflows,monitoring \
  --github \
  --github-org acme-corp \
  --private \
  --description "Customer search system with RAG and autonomous agents"

# Result:
# - Project created locally
# - GitHub repo: github.com/acme-corp/customer-search-rag
# - Private repository
# - Custom description
# - Team can clone immediately
```

#### Example 4: Dry Run (Preview Only)
```bash
# Preview before creating
./create-project.sh --name my-system \
  --archetype rag-project \
  --add-features agentic-workflows \
  --github \
  --github-org mycompany \
  --dry-run

# Output:
# ┌─────────────────────────────────────────┐
# │ Project Preview: my-system              │
# └─────────────────────────────────────────┘
#
# Local Project:
#   Path: ./my-system
#   Git: Initialized
#
# GitHub Repository:
#   URL: github.com/mycompany/my-system
#   Visibility: public
#   Description: RAG Project with agentic-workflows
#
# Proceed? [y/N]
```

### 8.5 .gitignore and Git Configuration

**Auto-Generated .gitignore:**
```gitignore
# Environment variables
.env
.env.local
.env.*.local
*.env.local

# Secrets (from template)
secrets/
*.secret
*.key
*.pem

# Python
__pycache__/
*.py[cod]
venv/
.venv/
*.egg-info/

# Node.js
node_modules/

# Docker
.dockerignore

# IDEs
.vscode/
.idea/

# OS files
.DS_Store
Thumbs.db

# Logs
logs/
*.log

# Build artifacts
dist/
build/

# Archetype-specific (from rag-project)
opensearch-data/
ollama-data/
*.parquet

# Archetype-specific (from agentic-workflows)
airflow-logs/
airflow-dags/__pycache__/
```

**Auto-Generated Commit Message:**
```
Initial commit: my-rag-system

Archetypes:
- rag-project (v1.0.0)
- agentic-workflows (v1.0.0)

Services:
- RAG API (port 8000)
- OpenSearch (port 9200)
- Ollama (port 11434)
- Agentic API (port 8100)
- Airflow (port 8180)

Generated by dev-environment-template v2.0.0
```

### 8.6 Repository Templates

**GitHub Repository Settings (Auto-Applied):**

```json
{
  "has_issues": true,
  "has_projects": true,
  "has_wiki": false,
  "auto_init": false,
  "gitignore_template": null,
  "license_template": null,
  "allow_squash_merge": true,
  "allow_merge_commit": true,
  "allow_rebase_merge": true,
  "delete_branch_on_merge": true,
  "topics": ["rag", "ai", "agentic", "dev-environment-template"]
}
```

**README.md Template:**
```markdown
# my-rag-system

> RAG system with agentic workflows
>
> Generated from [dev-environment-template](https://github.com/mazelb/dev-environment-template)

## Quick Start

```bash
# Clone repository
git clone https://github.com/mycompany/my-rag-system.git
cd my-rag-system

# Start services
make start

# Open in browser
# - RAG API: http://localhost:8000
# - Airflow: http://localhost:8180
```

## Architecture

This project combines:
- **RAG Project**: Vector search with OpenSearch
- **Agentic Workflows**: Multi-agent orchestration

See [COMPOSITION.md](COMPOSITION.md) for details.

## Development

```bash
# Run tests
make test

# View logs
make logs

# Stop services
make stop
```

## Documentation

- [Setup Guide](docs/SETUP.md)
- [API Reference](docs/API.md)
- [Architecture](docs/ARCHITECTURE.md)

## License

MIT
```

### 8.7 CI/CD Integration

**Auto-Generated GitHub Actions:**

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install -r requirements-dev.txt

      - name: Run tests
        run: make test

      - name: Lint
        run: make lint
```

### 8.8 Error Handling

**Scenarios and Solutions:**

| Error | Solution |
|-------|----------|
| GitHub CLI not installed | Display install instructions, continue without GitHub |
| Not authenticated | Prompt for `gh auth login`, continue without GitHub |
| Repository already exists | Ask to use existing or rename |
| Network error | Retry 3 times, then fail gracefully |
| Push fails | Display manual push instructions |

**Graceful Degradation:**
```bash
if ! create_github_repo "$PROJECT_NAME" "$GITHUB_ORG" "$VISIBILITY"; then
    print_warning "GitHub repository creation failed"
    print_info "You can create it manually later:"
    echo ""
    echo "  cd $PROJECT_NAME"
    echo "  gh repo create"
    echo ""
fi
```

---

## 9. Implementation Plan

### Phase 1: Core Infrastructure (Week 1-2)

**Goal:** Basic multi-archetype support with layered composition + Git/GitHub integration

**Tasks:**
1. ✅ Create archetype metadata schema (`__archetype__.json`)
2. ✅ Implement archetype loader (`scripts/archetype-loader.sh`)
3. ✅ Implement conflict detector (`scripts/conflict-resolver.sh`)
4. ✅ Implement port offset resolver
5. ✅ Implement service name prefixing
6. ✅ Update `create-project.sh` with `--add-features` flag
7. ✅ Implement automatic Git initialization
8. ✅ Implement GitHub repository creator (`scripts/github-repo-creator.sh`)
9. ✅ Add `--github`, `--github-org`, `--private` flags
10. ✅ Generate smart commit messages with archetype info

**Deliverables:**
- Working layered composition (base + 1 feature)
- Port conflict resolution
- Service name prefixing
- Automatic Git initialization
- Single-command GitHub repository creation

**Test:**
```bash
# Local Git only
./create-project.sh --name test1 \
  --archetype rag-project \
  --add-features monitoring

# With GitHub repo creation
./create-project.sh --name test2 \
  --archetype rag-project \
  --add-features agentic-workflows \
  --github \
  --private
```

---

### Phase 2: File Merging (Week 3-4)

**Goal:** Smart file merging for configuration and source files

**Tasks:**
1. ✅ Implement `.env` merger (`scripts/env-merger.sh`)
2. ✅ Implement Makefile merger (`scripts/makefile-merger.sh`)
3. ✅ Implement Docker Compose merger (`scripts/docker-compose-merger.sh`)
4. ✅ Implement smart source file merger (Python, Node.js)
5. ✅ Implement directory structure merger
6. ✅ Add merge strategy metadata to archetypes

**Deliverables:**
- Complete file merging for all common file types
- Smart merge for FastAPI `main.py`
- Namespaced Makefile commands

**Test:**
```bash
./create-project.sh --name test2 \
  --archetype rag-project \
  --add-features agentic-workflows

# Verify merged files
cat test2/.env                # Should have both RAG and Agentic vars
cat test2/Makefile            # Should have namespaced commands
cat test2/src/api/main.py     # Should have merged routers
```

---

### Phase 3: Dependency Resolution (Week 5)

**Goal:** Handle Python package conflicts

**Tasks:**
1. ✅ Implement dependency constraint parser
2. ✅ Implement version intersection resolver
3. ✅ Integrate with `pip-tools` or Poetry resolver
4. ✅ Add conflict warnings to CLI
5. ✅ Add fallback strategies (pin to compatible version)

**Deliverables:**
- Automatic dependency resolution
- Clear error messages for incompatible versions
- Generated `requirements.txt` with resolved versions

**Test:**
```bash
./create-project.sh --name test3 \
  --archetype rag-project \
  --add-features agentic-workflows

# Verify dependencies
cat test3/requirements.txt
```

---

### Phase 4: Documentation & UX (Week 6)

**Goal:** Polished user experience

**Tasks:**
1. ✅ Implement `--list-archetypes` command
2. ✅ Implement `--check-compatibility` command
3. ✅ Implement `--dry-run` preview
4. ✅ Generate `COMPOSITION.md` for multi-archetype projects
5. ✅ Add interactive conflict resolution prompts
6. ✅ Create comprehensive documentation

**Deliverables:**
- `docs/MULTI_ARCHETYPE_GUIDE.md`
- Interactive CLI with previews
- Auto-generated composition documentation

---

### Phase 5: Create Real Archetypes (Week 7-8)

**Goal:** Build library of composable archetypes

**Archetypes to Create:**

1. **rag-project** (base)
   - OpenSearch, Ollama, FastAPI
   - Vector search implementation
   - Example queries

2. **agentic-workflows** (feature)
   - Airflow, Langfuse
   - Multi-agent patterns
   - Workflow templates

3. **monitoring** (feature)
   - Prometheus, Grafana, Alertmanager
   - Pre-configured dashboards
   - Alert rules

4. **api-gateway** (feature)
   - NGINX or Kong
   - Rate limiting
   - Authentication

5. **rag-agentic-system** (composite)
   - Pre-integrated RAG + Agentic
   - Custom integration scripts
   - End-to-end examples

**Deliverables:**
- 3 base archetypes
- 4 feature archetypes
- 2 composite archetypes

---

### Phase 6: Advanced Features (Week 9-10)

**Goal:** Modular composition and custom archetypes

**Tasks:**
1. ✅ Implement modular composition (`--archetypes arch1,arch2,arch3`)
2. ✅ Implement priority-based conflict resolution
3. ✅ Support custom archetype repositories (`--archetype-repo`)
4. ✅ Create archetype validator (CI/CD integration)
5. ✅ Add archetype versioning support

**Deliverables:**
- Modular composition support
- Custom archetype repository support
- Archetype CI/CD pipeline

---

### Phase 7: Testing & Polish (Week 11-12)

**Goal:** Production-ready system

**Tasks:**
1. ✅ Write integration tests for all composition scenarios
2. ✅ Test all archetype combinations
3. ✅ Performance optimization (fast project creation)
4. ✅ Error handling improvements
5. ✅ Documentation review and polish
6. ✅ Video tutorials
7. ✅ Blog post announcement

**Deliverables:**
- Comprehensive test suite
- Performance benchmarks
- Complete documentation
- Marketing materials

---

## Summary & Next Steps

### Recommended Approach

**Primary Strategy:** Layered Composition (Strategy 1)
- Base archetype + feature archetypes
- Automatic conflict resolution
- 80% of use cases

**Implementation Phases:**
1. Core infrastructure (2 weeks)
2. File merging (2 weeks)
3. Dependency resolution (1 week)
4. Documentation & UX (1 week)
5. Create archetypes (2 weeks)
6. Advanced features (2 weeks)
7. Testing & polish (2 weeks)

**Total Timeline:** 12 weeks

### Key Innovations

1. **Automatic Port Offsetting:** No manual port configuration
2. **Service Namespacing:** No service name conflicts
3. **Smart File Merging:** Configuration files merge automatically
4. **Dependency Resolution:** Python packages resolve automatically
5. **Namespaced Commands:** `make rag-run`, `make agentic-run`
6. **Composition Documentation:** Auto-generated guides

### Success Metrics

- **User Goal:** Create RAG + Agentic system in < 5 minutes
- **Conflict Resolution:** 95% automatic (no user intervention)
- **Compatibility:** 90% of archetype combinations work
- **Performance:** < 30 seconds to scaffold project
- **Documentation:** 100% of multi-archetype projects get composition guide

### Open Questions

1. **Archetype Repository:**
   - Single repo vs. separate `dev-environment-archetypes` repo?
   - **Recommendation:** Start with single repo, extract later if needed

2. **Versioning:**
   - Independent archetype versions or follow template version?
   - **Recommendation:** Independent versions (semantic versioning)

3. **Community Contributions:**
   - Open contribution model vs. curated library?
   - **Recommendation:** Curated library initially, open later

4. **Virtual Environments:**
   - Support separate venvs per archetype for incompatible deps?
   - **Recommendation:** Future enhancement (Phase 8)

5. **Archetype Marketplace:**
   - Build a marketplace for sharing archetypes?
   - **Recommendation:** Long-term vision (2026)

---

**End of Design Document**

*Ready for implementation approval and Phase 1 kickoff.*
