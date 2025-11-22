# Archetypes System

**Version:** 2.0
**Last Updated:** November 21, 2025

Archetypes are production-ready project templates that scaffold complete application structures with working code, tests, documentation, and Docker configurations. Unlike presets that just install packages, archetypes create full, runnable projects.

## Quick Start

```bash
# Create a RAG system
./create-project.sh my-rag-app --archetype rag-project

# Create RAG + Agents
./create-project.sh my-ai-system --archetype composite-rag-agents

# Create with features
./create-project.sh my-app --archetype rag-project --add-features monitoring
```

## What are Archetypes?

**Presets** install tools. **Archetypes** scaffold projects.

| Concept | What it does | Example |
|---------|--------------|---------|
| **Preset** | Installs Python/Node packages and Docker services | `--preset ai-agent` → installs langchain, llamaindex |
| **Archetype** | Scaffolds project structure, code templates, configs | `--archetype rag-project` → creates src/, tests/, docker/, full RAG implementation |

## Archetype Types

### 1. Base Archetypes (4)
Primary project templates that define the core structure. Use as starting point.

- **base** - Minimal development environment (Python, Node.js, C++)
- **rag-project** - RAG system with vector search, embeddings, LLM
- **api-service** - Production FastAPI with auth, rate limiting, versioning
- **monitoring** - Observability stack (Prometheus, Grafana, Loki)

### 2. Feature Archetypes (2)
Additional capabilities that enhance base archetypes. Add to base projects.

- **agentic-workflows** - Stateful AI agents with LangGraph, tool calling
- **monitoring** - Can be used as feature for other archetypes

### 3. Composite Archetypes (1)
Pre-configured combinations with custom integrations and optimizations.

- **composite-rag-agents** - RAG + Agentic Workflows (pre-integrated)

---

## Available Archetypes

### Base Archetype

#### `base` - Minimal Development Environment
**Version:** 1.0.0 | **Type:** base | **Status:** ✅ Stable

Minimal development environment with core tooling for Python, Node.js, and C++ development.

**What's Included:**
- Basic directory structure (`src/`, `tests/`, `docs/`)
- Docker Compose setup
- VS Code configuration
- Git integration
- README template

**Use When:**
- Starting a simple project
- Need minimal boilerplate
- Want maximum flexibility

**Quick Start:**
```bash
./create-project.sh my-base-app --archetype base
```

---

### Primary Archetypes

#### `rag-project` - RAG System with Vector Search
**Version:** 2.0.0 | **Type:** base | **Status:** ✅ Stable

Complete Retrieval-Augmented Generation system with vector database, embeddings, and LLM integration.

**What's Included:**
- **FastAPI** REST API with document management endpoints
- **ChromaDB** vector database for semantic search
- **Ollama** local LLM inference server
- **Sentence Transformers** for embeddings
- Document processing pipeline (chunking, embedding)
- RAG query service (retrieval + generation)
- Docker Compose multi-service setup
- Comprehensive tests and documentation

**Tech Stack:**
- FastAPI 0.104+
- ChromaDB (vector database)
- Ollama (LLM)
- LangChain for text processing
- Pydantic for data models

**Services:**
- API: Port 8000
- ChromaDB: Port 8001
- Ollama: Port 11434

**Use Cases:**
- Document Q&A systems
- Semantic search applications
- Knowledge base with AI assistance
- Custom chatbots with document grounding

**Quick Start:**
```bash
./create-project.sh my-rag-app --archetype rag-project
cd my-rag-app
docker-compose up -d
# Upload documents, query via API
```

**Documentation:** See `archetypes/rag-project/README.md`

---

#### `api-service` - Production FastAPI Service
**Version:** 1.0.0 | **Type:** base | **Status:** ✅ Stable

Production-ready FastAPI service with authentication, authorization, rate limiting, and API versioning.

**What's Included:**
- **JWT Authentication** with refresh tokens
- **Role-based Authorization** (RBAC)
- **Rate Limiting** (per-user, per-endpoint)
- **API Versioning** (/v1/, /v2/)
- **Request Validation** with Pydantic
- **Logging Middleware** (structured logging)
- **CORS Configuration** (security-first)
- **Redis** for caching and rate limiting
- Comprehensive test suite

**Tech Stack:**
- FastAPI 0.115+
- Redis for caching
- JWT for authentication
- Pydantic for validation
- Pytest for testing

**Services:**
- API: Port 8000
- Redis: Port 6379

**Features:**
- User authentication (login, logout, refresh)
- Role management (admin, user, guest)
- Per-endpoint rate limits
- Request/response logging
- Health checks
- API documentation (OpenAPI)

**Use Cases:**
- RESTful APIs
- Microservices
- Backend for web/mobile apps
- API gateways

**Quick Start:**
```bash
./create-project.sh my-api --archetype api-service
cd my-api
docker-compose up -d
curl http://localhost:8000/v1/health
```

**Documentation:** See `archetypes/api-service/README.md`

---

#### `monitoring` - Observability Stack
**Version:** 1.0.0 | **Type:** base/feature | **Status:** ✅ Stable

Complete monitoring and observability stack with metrics, logs, and visualization.

**What's Included:**
- **Prometheus** for metrics collection
- **Grafana** for visualization and dashboards
- **Loki** for log aggregation
- **Promtail** for log shipping
- Pre-built dashboards
- Alert rules
- Service discovery

**Tech Stack:**
- Prometheus
- Grafana
- Loki + Promtail
- Python instrumentation libraries

**Services:**
- Prometheus: Port 9090
- Grafana: Port 3000 (admin/admin)
- Loki: Port 3100

**Dashboards:**
- System metrics (CPU, memory, disk)
- Application metrics (requests, latency, errors)
- Custom business metrics

**Use Cases:**
- Production monitoring
- Performance analysis
- Debugging and troubleshooting
- SLA tracking

**Quick Start:**
```bash
./create-project.sh my-monitor --archetype monitoring
cd my-monitor
docker-compose up -d
# Visit http://localhost:3000 (Grafana)
```

**Documentation:** See `archetypes/monitoring/README.md`

---

### Feature Archetypes

#### `agentic-workflows` - AI Agent Orchestration
**Version:** 1.0.0 | **Type:** feature | **Status:** ✅ Stable

Stateful AI agent workflows using LangGraph for complex multi-step tasks with tool calling.

**What's Included:**
- **LangGraph** state machines for agents
- **Tool Calling** framework
- **State Management** with persistence
- **Checkpointing** for long-running tasks
- Example research agent
- Web search integration (Tavily)
- LLM provider integrations (OpenAI, Anthropic)

**Tech Stack:**
- LangGraph 0.0.40+
- LangChain
- OpenAI/Anthropic APIs
- Tavily search API

**Features:**
- Stateful workflows with conditional routing
- Tool definition and binding
- Multi-step reasoning
- Error handling and retries
- Workflow visualization

**Use Cases:**
- Research assistants
- Multi-step automation
- Complex decision-making
- Tool-using agents

**Composition:**
```bash
# Add to RAG project
./create-project.sh my-ai --archetype rag-project --add-features agentic-workflows
```

**Documentation:** See `archetypes/agentic-workflows/README.md`

---

### Composite Archetypes

#### `composite-rag-agents` - RAG + Agentic System
**Version:** 1.0.0 | **Type:** composite | **Status:** ✅ Stable

Pre-integrated system combining RAG retrieval with stateful AI agents for complex document-based reasoning.

**What's Included:**
- Everything from `rag-project`
- Everything from `agentic-workflows`
- **RAG Tool** for agents to query documents
- **Research Agent** example using RAG
- **Agent API endpoints** (/agents/query)
- **Integration script** (auto-runs)
- 4 working example scripts
- Comprehensive documentation (1000+ lines)

**Architecture:**
```
API (FastAPI)
├── RAG Service (document retrieval)
└── Agent Service (multi-step reasoning)
    └── RAG Tool (query documents)
```

**Tech Stack:**
- All RAG dependencies
- All agent dependencies
- Unified API
- Shared Docker infrastructure

**Services:**
- API: Port 8000
- ChromaDB: Port 8001
- Ollama: Port 11434

**Use Cases:**
- Document Q&A with reasoning
- Research assistants
- Code documentation helpers
- Multi-source intelligence

**Quick Start:**
```bash
./create-project.sh my-ai-system --archetype composite-rag-agents
cd my-ai-system
cp .env.example .env
# Add OPENAI_API_KEY and TAVILY_API_KEY
docker-compose up -d
```

**Examples:**
- `examples/basic_agent_query.py` - Simple agent query
- `examples/multi_tool_agent.py` - Agent with RAG + web search
- `examples/api_usage.py` - Complete API examples
- `examples/streaming_agent.py` - Real-time streaming

**Documentation:** See `archetypes/composite-rag-agents/README.md`

---

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

### Tested Combinations

| Base Archetype | Compatible Features | Status | Notes |
|----------------|---------------------|--------|-------|
| **rag-project** | agentic-workflows | ✅ Tested | See composite-rag-agents |
| **rag-project** | monitoring | ✅ Compatible | Metrics + logs for RAG |
| **api-service** | monitoring | ✅ Compatible | Full observability |
| **base** | * (any) | ✅ Compatible | Minimal conflicts |

### Port Assignments

Each archetype reserves specific ports. When composing, ports are offset automatically.

| Archetype | Base Ports | Port Offset | Final Ports (when composed) |
|-----------|-----------|-------------|------------------------------|
| rag-project | 8000, 8001, 11434 | 0 | 8000, 8001, 11434 |
| agentic-workflows | - | +100 | - |
| monitoring | 9090, 3000, 3100 | +200 | 9290, 3200, 3300 |
| api-service | 8000, 6379 | +300 | 8300, 6679 |

### Service Name Prefixes

| Archetype | Prefix | Example Services |
|-----------|--------|------------------|
| rag-project | `rag-` | rag-api, rag-chromadb, rag-ollama |
| agentic-workflows | `agent-` | agent-worker |
| monitoring | `monitor-` | monitor-prometheus, monitor-grafana |
| api-service | `api-` | api-server, api-redis |

## Practical Examples

### Example 1: Document Q&A System

Create an AI system that answers questions from your documents:

```bash
# Create RAG system
./create-project.sh doc-qa --archetype rag-project --github

cd doc-qa
cp .env.example .env
docker-compose up -d

# Upload documents
curl -X POST http://localhost:8000/documents/upload \
  -F "file=@mydoc.txt"

# Query
curl -X POST http://localhost:8000/rag/query \
  -H "Content-Type: application/json" \
  -d '{"query": "What are the main topics?"}'
```

**Services Running:**
- API: `http://localhost:8000`
- ChromaDB: `http://localhost:8001`
- Ollama: `http://localhost:11434`

---

### Example 2: RAG + AI Agents

Create an intelligent agent that can query documents and reason:

```bash
# Use composite archetype (pre-integrated)
./create-project.sh smart-assistant --archetype composite-rag-agents

cd smart-assistant
cp .env.example .env
# Add: OPENAI_API_KEY, TAVILY_API_KEY

docker-compose up -d

# Query with agent
curl -X POST http://localhost:8000/agents/query \
  -H "Content-Type: application/json" \
  -d '{"query": "Analyze the documents and summarize key insights"}'
```

**What the agent can do:**
- Query documents via RAG
- Search the web (Tavily)
- Multi-step reasoning
- Synthesize information

---

### Example 3: Production API with Monitoring

Create a monitored API service:

```bash
# Compose api-service + monitoring
./create-project.sh prod-api \
  --archetype api-service \
  --add-features monitoring

cd prod-api
docker-compose up -d
```

**Services Running:**
- API: `http://localhost:8000` (with auth, rate limiting)
- Redis: `http://localhost:6379` (caching)
- Prometheus: `http://localhost:9090` (metrics)
- Grafana: `http://localhost:3000` (dashboards, admin/admin)
- Loki: `http://localhost:3100` (logs)

**Grafana Dashboards:**
- System metrics (CPU, memory, disk)
- API metrics (requests, latency, errors)
- Redis metrics

---

### Example 4: Minimal Custom Project

Start with base and add only what you need:

```bash
# Start minimal
./create-project.sh my-custom --archetype base

cd my-custom
# Add your code to src/
# Customize as needed
```

---

## Composition Patterns

### Pattern 1: Single Archetype (Simplest)

```bash
./create-project.sh my-app --archetype rag-project
```

**Use When:**
- Learning an archetype
- Simple use case
- No additional features needed

---

### Pattern 2: Layered Composition (Recommended)

```bash
./create-project.sh my-app \
  --archetype rag-project \
  --add-features agentic-workflows,monitoring
```

**Use When:**
- Need multiple capabilities
- Want automatic integration
- Flexible composition

**Benefits:**
- Automatic conflict resolution
- Smart file merging
- Port offsetting
- Service prefixing

---

### Pattern 3: Composite Archetype (Pre-integrated)

```bash
./create-project.sh my-app --archetype composite-rag-agents
```

**Use When:**
- Want pre-optimized integration
- Common use case
- Skip manual configuration

**Benefits:**
- Custom integration scripts
- Pre-resolved conflicts
- Working examples included
- Comprehensive documentation

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

### Current Release (v2.0) - November 2025

**Completed Features:**
- ✅ Layered composition (base + features)
- ✅ Automatic conflict resolution
- ✅ Smart file merging
- ✅ Port offsetting
- ✅ Service name prefixing
- ✅ 4 base archetypes
- ✅ 2 feature archetypes
- ✅ 1 composite archetype (rag + agents)
- ✅ Comprehensive documentation

**Available Archetypes:**
- base, rag-project, api-service, monitoring
- agentic-workflows (feature)
- composite-rag-agents (composite)

---

### Future Releases

#### v2.1 (Q1 2026) - Planned
- 🔄 Additional base archetypes (ml-training, data-pipeline)
- 🔄 More composite archetypes (api-gateway, mlops)
- 🔄 Archetype versioning and updates
- 🔄 Custom archetype repositories
- 🔄 Archetype marketplace/registry

#### v2.2+ (Future) - Under Consideration
- 🔄 Modular composition (multiple base archetypes)
- 🔄 Live archetype updates (pull latest)
- 🔄 Separate virtual environments per archetype
- 🔄 Cross-language archetypes (Python + Node.js + Rust)
- 🔄 Cloud deployment archetypes (AWS, Azure, GCP)
- 🔄 Kubernetes archetypes
- 🔄 Archetype testing framework

---

## Quick Reference

### Common Commands

```bash
# List available archetypes
./create-project.sh --list-archetypes

# Create with single archetype
./create-project.sh my-app --archetype <name>

# Create with features
./create-project.sh my-app --archetype <base> --add-features <feat1>,<feat2>

# Create with GitHub repo
./create-project.sh my-app --archetype <name> --github

# Dry run (preview only)
./create-project.sh my-app --archetype <name> --dry-run
```

### Archetype Selection Guide

| If you need... | Use this archetype |
|----------------|-------------------|
| Document Q&A, semantic search | `rag-project` |
| AI agents with reasoning | `composite-rag-agents` |
| Production API with auth | `api-service` |
| Monitoring/observability | `monitoring` (or as feature) |
| AI workflow orchestration | `agentic-workflows` (as feature) |
| Minimal starting point | `base` |

### Port Reference

| Archetype | Default Ports |
|-----------|--------------|
| rag-project | 8000 (API), 8001 (ChromaDB), 11434 (Ollama) |
| api-service | 8000 (API), 6379 (Redis) |
| monitoring | 9090 (Prometheus), 3000 (Grafana), 3100 (Loki) |
| composite-rag-agents | 8000 (API), 8001 (ChromaDB), 11434 (Ollama) |

## Support & Resources

### Documentation

- **Main README:** `../README.md` - Project overview and setup
- **Implementation Strategy:** `../docs/IMPLEMENTATION_STRATEGY.md` - Technical details
- **Multi-Archetype Guide:** `../docs/MULTI_ARCHETYPE_GUIDE.md` - Composition guide
- **Archetype-specific docs:** Each archetype has its own `README.md`

### Archetype Documentation

- **RAG Project:** `rag-project/README.md` - 300+ lines, complete guide
- **Composite RAG+Agents:** `composite-rag-agents/README.md` - 600+ lines, architecture, examples
- **API Service:** `api-service/README.md` - Authentication, rate limiting guide
- **Monitoring:** `monitoring/README.md` - Prometheus, Grafana, Loki setup
- **Agentic Workflows:** `agentic-workflows/README.md` - LangGraph workflows guide

### Examples

Each archetype includes working examples:
- `rag-project/examples/` - Document upload, search, RAG queries
- `composite-rag-agents/examples/` - 4 complete example scripts
- `agentic-workflows/examples/` - Agent workflow samples

### Getting Help

- **GitHub Issues:** Report bugs or request features
- **GitHub Discussions:** Ask questions, share projects
- **Documentation:** Check archetype-specific README files

### Contributing

Want to create an archetype? See:
1. **Creating Archetypes** section above
2. `docs/IMPLEMENTATION_GUIDE.md` - Development guide
3. `__archetype_schema__.json` - Metadata schema reference

**Contribution workflow:**
1. Create archetype directory
2. Add `__archetype__.json` metadata
3. Test composition with existing archetypes
4. Document in README
5. Submit pull request

---

## Summary

The archetypes system provides production-ready project templates that go beyond simple package installation. With **7 archetypes** currently available (4 base, 2 feature, 1 composite), you can create complex AI systems, APIs, and monitored applications with a single command.

### Key Benefits

✅ **Fast Project Creation** - Single command creates complete, working projects
✅ **Production Ready** - Includes tests, docs, Docker configs, best practices
✅ **Composable** - Combine archetypes with automatic conflict resolution
✅ **Well Documented** - 1000+ lines of docs per major archetype
✅ **Working Examples** - Real code you can run immediately
✅ **Maintainable** - Clear structure, type-safe code, comprehensive tests

### Current Statistics (v2.0)

- **Total Archetypes:** 7 (4 base + 2 feature + 1 composite)
- **Lines of Code:** 10,000+ across all archetypes
- **Documentation:** 2,000+ lines
- **Example Scripts:** 20+
- **Docker Services:** 15+ pre-configured

### Next Steps

1. **Explore archetypes:** Read individual README files
2. **Try examples:** Create a test project
3. **Compose archetypes:** Experiment with combinations
4. **Build custom:** Create your own archetype
5. **Contribute:** Share your archetypes with the community

---

**Happy architecting!** 🏗️ **Build production-ready projects in minutes, not hours.**
