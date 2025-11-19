# Archetypes System

Archetypes are project templates that scaffold complete application structures, not just install packages. This directory contains composable archetypes that can be combined to create complex systems.

## What are Archetypes?

**Presets** install tools. **Archetypes** scaffold projects.

| Concept | What it does | Example |
|---------|--------------|---------|
| **Preset** | Installs Python/Node packages and Docker services | `--preset ai-agent` → installs langchain, llamaindex |
| **Archetype** | Scaffolds project structure, code templates, configs | `--archetype rag-project` → creates src/, tests/, docker/, full RAG implementation |

## Archetype Types

### 1. Base Archetypes
Primary project templates that define the core structure.

- **rag-project** - RAG system with vector search
- **api-service** - Production FastAPI service
- **ml-training** - ML training pipelines
- **data-pipeline** - ETL workflows

### 2. Feature Archetypes
Additional capabilities that enhance base archetypes.

- **agentic-workflows** - Multi-agent orchestration
- **monitoring** - Prometheus + Grafana observability
- **api-gateway** - NGINX gateway with auth
- **mlops** - MLflow + model registry

### 3. Composite Archetypes
Pre-configured combinations of base + features.

- **rag-agentic-system** - RAG + Agentic (optimized)
- **api-auth-monitoring** - API + Auth + Monitoring

## Directory Structure

```
archetypes/
├── README.md                       # This file
├── base/                           # Base archetype (minimal)
│   ├── __archetype__.json
│   ├── src/
│   ├── tests/
│   └── docker/
├── rag-project/                    # RAG system
│   ├── __archetype__.json
│   ├── src/
│   │   ├── api/
│   │   ├── services/
│   │   └── models/
│   ├── tests/
│   ├── docker/
│   │   ├── opensearch/
│   │   └── ollama/
│   ├── docs/
│   └── examples/
├── agentic-workflows/              # Feature archetype
│   ├── __archetype__.json
│   ├── src/
│   │   └── services/
│   │       └── agentic/
│   ├── docker/
│   │   └── airflow/
│   └── docs/
└── rag-agentic-system/             # Composite
    ├── __archetype__.json
    ├── docs/
    └── scripts/
        └── integrate_rag_agentic.sh
```

## Usage

### Single Archetype
```bash
./create-project.sh --name my-rag-app \
  --archetype rag-project
```

### Layered Composition (Recommended)
```bash
./create-project.sh --name my-app \
  --archetype rag-project \
  --add-features agentic-workflows,monitoring
```

### Composite Archetype
```bash
./create-project.sh --name my-app \
  --archetype rag-agentic-system
```

## Conflict Resolution

When combining archetypes, conflicts are resolved automatically:

| Conflict Type | Resolution Strategy |
|---------------|---------------------|
| Port conflicts | Automatic port offsetting (+100 per feature) |
| Service name collisions | Service prefixing (e.g., `agentic_airflow`) |
| Python package versions | Version intersection or fallback |
| Configuration files | Smart merging (.env, Makefile, etc.) |
| Directory structure | Recursive merge |
| Makefile commands | Namespace prefixing (e.g., `rag-run`) |

## Creating Archetypes

### Metadata Schema

Each archetype requires `__archetype__.json`:

```json
{
  "version": "2.0",
  "metadata": {
    "name": "my-archetype",
    "display_name": "My Archetype",
    "description": "Description of what this archetype provides",
    "version": "1.0.0",
    "author": "Your Name",
    "tags": ["tag1", "tag2"],
    "archetype_type": "base|feature|composite"
  },

  "composition": {
    "role": "base|feature|composite",
    "compatible_features": ["feature1", "feature2"],
    "incompatible_with": ["archetype-x"],
    "composable": true,
    "service_prefix": "myarch",
    "port_offset": 0
  },

  "dependencies": {
    "preset": "ai-agent",
    "additional_tools": ["opensearch"],
    "python": {
      "package": ">=1.0.0,<2.0.0"
    }
  },

  "conflicts": {
    "declare": {
      "ports": [8000, 9200],
      "services": ["api", "database"],
      "environment_vars": ["API_KEY"]
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
        "VAR": "value"
      }
    }
  },

  "structure": {
    "directories": ["src/", "tests/", "docker/"],
    "files": {
      "src/api/main.py": {
        "merge_strategy": "smart_merge",
        "priority": 1
      },
      ".env": {
        "merge_strategy": "append"
      }
    }
  }
}
```

### Best Practices

1. **Declare All Conflicts:** List ports, services, env vars in metadata
2. **Use Service Prefixes:** Make your service names unique
3. **Version Constraints:** Use flexible version specs for dependencies
4. **Test Composition:** Test your archetype with common features
5. **Document Integration:** Provide clear integration guides
6. **Examples:** Include working example projects

### File Merge Strategies

| Strategy | When to Use | Example |
|----------|-------------|---------|
| `smart_merge` | Source code files | `main.py`, `app.ts` |
| `append` | Configuration files | `.env`, `.gitignore` |
| `namespace` | Command files | `Makefile`, `package.json` scripts |
| `template` | Complex merges | Custom Jinja2 template |
| `skip_if_exists` | User-editable files | `config.yaml` |

## Compatibility Matrix

| Base Archetype | Compatible Features | Notes |
|----------------|---------------------|-------|
| rag-project | agentic-workflows, monitoring, api-gateway | Fully compatible |
| api-service | monitoring, api-gateway, auth | Fully compatible |
| ml-training | agentic-workflows, mlops, monitoring | Fully compatible |
| data-pipeline | monitoring, mlops | Fully compatible |

## Examples

### Example 1: RAG + Agentic
```bash
./create-project.sh --name rag-agents \
  --archetype rag-project \
  --add-features agentic-workflows

cd rag-agents
make start  # Starts all services
```

**Result:**
- RAG API: http://localhost:8000
- OpenSearch: http://localhost:9200
- Agentic API: http://localhost:8100
- Airflow: http://localhost:8180

### Example 2: API + Auth + Monitoring
```bash
./create-project.sh --name api-prod \
  --archetype api-service \
  --add-features api-gateway,monitoring

cd api-prod
make start
```

**Result:**
- API Gateway: http://localhost:8200
- API: http://localhost:8000
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000

## Contributing

### Submission Guidelines

1. **Create archetype directory** with `__archetype__.json`
2. **Test composition** with existing archetypes
3. **Document integration** in `docs/` directory
4. **Provide examples** in `examples/` directory
5. **Submit PR** with:
   - Archetype implementation
   - Compatibility matrix update
   - Test results

### Review Criteria

- ✅ Complete metadata (`__archetype__.json`)
- ✅ No undeclared conflicts
- ✅ Compatible with at least 2 other archetypes
- ✅ Comprehensive documentation
- ✅ Working examples
- ✅ Tests pass

## Roadmap

### Current (v2.0)
- ✅ Layered composition (base + features)
- ✅ Automatic conflict resolution
- ✅ Smart file merging
- ✅ 5 base archetypes
- ✅ 4 feature archetypes
- ✅ 2 composite archetypes

### Future (v2.1+)
- 🔄 Modular composition (multiple equals)
- 🔄 Custom archetype repositories
- 🔄 Archetype marketplace
- 🔄 Separate virtual environments per archetype
- 🔄 Live archetype updates

## Support

- **Documentation:** `docs/MULTI_ARCHETYPE_GUIDE.md`
- **Examples:** `examples/multi-archetype/`
- **Issues:** GitHub Issues
- **Discussions:** GitHub Discussions

---

**Happy architecting!** 🏗️
