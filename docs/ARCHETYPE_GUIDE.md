# Archetype Guide

Complete guide to using archetypes for creating specialized projects.

---

## What Are Archetypes?

Archetypes are pre-configured project templates that provide specialized functionality and structure. Instead of starting from scratch, you can create production-ready projects in seconds using archetypes.

**Benefits:**
- ⚡ **Fast setup** - Complete projects in < 60 seconds
- 🎯 **Best practices** - Production-ready configurations
- 🔧 **Composable** - Combine multiple archetypes
- 📝 **Auto-documented** - README and guides generated
- 🐳 **Docker-ready** - All services pre-configured

---

## Available Archetypes

### Base Archetypes

####  **base**
Minimal starter template with basic structure.

**Use for:** Any general project, custom applications

**Includes:**
- Basic directory structure (src/, tests/, docs/)
- Git initialization
- .gitignore
- README template

**Create:**
```bash
./create-project.sh --name my-app --archetype base
```

---

####  **rag-project**
RAG (Retrieval-Augmented Generation) system with vector search.

**Use for:** Document search, Q&A systems, knowledge bases

**Includes:**
- FastAPI application with hot reload
- OpenSearch for hybrid search (BM25 + vector)
- Ollama for local LLM inference
- Jina AI embeddings integration
- Langfuse monitoring (optional)
- Redis caching (optional)
- Complete test suite
- Pydantic settings management

**Services:**
- API (port 8000)
- OpenSearch (port 9200)
- Ollama (port 11434)
- Redis (port 6379, optional)

**Create:**
```bash
./create-project.sh --name doc-search --archetype rag-project
```

**Customization Points:**
1. Replace `__template__data_client.py` with your data source
2. Customize `Document` model for your domain
3. Tune search weights in `search_service.py`
4. Adjust chunking in `.env`

---

####  **api-service**
Production-ready FastAPI service.

**Use for:** REST APIs, microservices, backend services

**Includes:**
- FastAPI with authentication
- Rate limiting
- Request validation
- Health check endpoints
- OpenAPI documentation
- Docker configuration

**Create:**
```bash
./create-project.sh --name my-api --archetype api-service
```

---

### Feature Archetypes

#### 🔍 **monitoring**
Prometheus + Grafana monitoring stack.

**Use for:** Adding monitoring to any project

**Includes:**
- Prometheus metrics collection
- Grafana dashboards
- Alertmanager for alerts
- Pre-configured dashboards

**Compose with:**
```bash
./create-project.sh --name monitored-app \\
  --archetype rag-project \\
  --add-features monitoring
```

---

#### 🤖 **agentic-workflows**
AI agent orchestration with workflows.

**Use for:** Multi-agent systems, workflow automation

**Includes:**
- Agent definitions and orchestration
- Workflow management
- Airflow DAGs
- Langfuse integration

**Compose with:**
```bash
./create-project.sh --name agent-system \\
  --archetype base \\
  --add-features agentic-workflows
```

---

### Composite Archetypes

####  **composite-rag-agents**
Pre-configured RAG + Agentic workflows.

**Use for:** Advanced AI systems with document understanding and agents

**Create:**
```bash
./create-project.sh --name ai-system --archetype composite-rag-agents
```

---

####  **composite-api-monitoring**
API service with monitoring.

**Use for:** Production APIs with observability

**Create:**
```bash
./create-project.sh --name prod-api --archetype composite-api-monitoring
```

---

####  **composite-full-stack**
Complete full-stack application.

**Use for:** Web applications with frontend, API, and database

**Create:**
```bash
./create-project.sh --name webapp --archetype composite-full-stack
```

---

## Creating Projects

### Basic Usage

```bash
# Single archetype
./create-project.sh --name PROJECT_NAME --archetype ARCHETYPE_NAME

# With features
./create-project.sh --name PROJECT_NAME \\
  --archetype BASE_ARCHETYPE \\
  --add-features FEATURE1,FEATURE2

# Preview first (dry-run)
./create-project.sh --name PROJECT_NAME --archetype BASE --dry-run
```

### With GitHub Integration

```bash
# Create GitHub repo automatically
./create-project.sh --name my-app \\
  --archetype rag-project \\
  --github \\
  --description "My RAG application"

# Private repo in organization
./create-project.sh --name enterprise-app \\
  --archetype api-service \\
  --github \\
  --github-org mycompany \\
  --private
```

### Discovery Commands

```bash
# List all archetypes
./create-project.sh --list-archetypes

# Check compatibility
./create-project.sh --check-compatibility rag-project monitoring
```

---

## Complete Examples

### Example 1: Document Search System

```bash
# Create RAG project for document search
./create-project.sh --name doc-search --archetype rag-project

cd doc-search

# Configure environment
cp .env.example .env
# Edit .env with your API keys

# Start services
docker-compose up -d

# Check health
curl http://localhost:8000/health

# View logs
docker-compose logs -f api
```

### Example 2: Monitored API Service

```bash
# Create API with monitoring
./create-project.sh --name my-api \\
  --archetype api-service \\
  --add-features monitoring \\
  --github \\
  --private

cd my-api

# Start all services (API + Prometheus + Grafana)
docker-compose up -d

# Access services
# API: http://localhost:8000
# Grafana: http://localhost:3000
# Prometheus: http://localhost:9090
```

### Example 3: Multi-Agent AI System

```bash
# Create complex AI system
./create-project.sh --name ai-platform \\
  --archetype rag-project \\
  --add-features agentic-workflows,monitoring \\
  --github \\
  --description "AI platform with RAG, agents, and monitoring"

cd ai-platform

# Review composition
cat COMPOSITION.md

# Configure services
cp .env.example .env
# Add API keys for: Jina, Anthropic/OpenAI, Langfuse

# Start full stack
docker-compose up -d

# Monitor in Grafana
open http://localhost:3000
```

---

## Archetype Composition

### How It Works

When combining archetypes, the system:

1. **Detects conflicts** - Port conflicts, service name collisions
2. **Resolves automatically** - Applies port offsets, prefixes service names
3. **Merges files** - Intelligently combines docker-compose.yml, .env, Makefiles
4. **Generates docs** - Creates COMPOSITION.md documenting the combination

### Port Offset Strategy

Feature archetypes get automatic port offsets:

| Service | Base Port | Offset | Final Port |
|---------|-----------|--------|------------|
| API | 8000 | +1000 | 9000 |
| Database | 5432 | +1000 | 6432 |
| Cache | 6379 | +1000 | 7379 |

### Service Name Prefixing

Services are prefixed to avoid collisions:

```yaml
# Base archetype
services:
  api:
    ...

# Feature archetype (monitoring)
services:
  monitoring-prometheus:
    ...
  monitoring-grafana:
    ...
```

---

## Customizing Archetypes

### Customizing RAG Project

1. **Replace Data Source:**
   ```bash
   cd src/services
   cp __template__data_client.py my_data_client.py
   # Implement fetch_documents() for your data source
   ```

2. **Customize Document Model:**
   ```python
   # src/models/document.py
   class Document(BaseModel):
       # Add your domain-specific fields
       custom_field: str
   ```

3. **Adjust Search:**
   ```python
   # src/services/search_service.py
   # Tune BM25 vs vector weights
   ```

4. **Configure Chunking:**
   ```bash
   # .env
   CHUNKING__CHUNK_SIZE=800
   CHUNKING__OVERLAP_SIZE=100
   ```

### Customizing API Service

1. **Add Routes:**
   ```python
   # src/api/routers/my_router.py
   from fastapi import APIRouter

   router = APIRouter()

   @router.get("/my-endpoint")
   async def my_endpoint():
       return {"message": "Hello"}
   ```

2. **Add Authentication:**
   ```python
   # src/api/dependencies.py
   # Implement auth logic
   ```

3. **Configure Rate Limiting:**
   ```python
   # config/settings.py
   RATE_LIMIT: int = 100
   ```

---

## Best Practices

### 1. Use Dry Run First

```bash
# Always preview before creating
./create-project.sh --name my-app --archetype rag-project --dry-run
```

### 2. Start Simple, Add Features

```bash
# Start with base
./create-project.sh --name my-app --archetype base

# Add features later if needed
# (Manual: copy docker-compose services from feature archetypes)
```

### 3. Document Your Customizations

Update the generated `README.md` with:
- Custom configuration steps
- Environment variable requirements
- API endpoints you added
- Deployment instructions

### 4. Version Your Projects

```bash
# After creating from archetype
cd my-project
git tag v0.1.0
git push --tags
```

### 5. Keep Archetype Info

The generated `COMPOSITION.md` documents which archetypes were used - keep it for reference.

---

## Troubleshooting

### Port Conflicts

**Problem:** "Port already in use"

**Solution:**
```bash
# Check what's using the port
netstat -an | grep 8000

# Stop conflicting service or use different port
# Edit docker-compose.yml to change ports
```

### Service Won't Start

**Problem:** Docker service fails to start

**Solution:**
```bash
# Check logs
docker-compose logs service-name

# Common issues:
# - Missing environment variables (check .env)
# - Port conflicts (see above)
# - Resource limits (increase Docker memory)
```

### Missing Dependencies

**Problem:** "Module not found" or "Package not installed"

**Solution:**
```bash
# Rebuild Docker images
docker-compose build --no-cache

# Check pyproject.toml has all dependencies
# Verify requirements.txt is up to date
```

---

## Advanced Topics

### Creating Custom Archetypes

See [MULTI_ARCHETYPE_COMPOSITION_DESIGN.md](MULTI_ARCHETYPE_COMPOSITION_DESIGN.md) for:
- Archetype metadata schema
- Directory structure requirements
- Conflict resolution strategies
- Testing custom archetypes

### Archetype Development

```bash
# Structure
archetypes/
└── my-archetype/
    ├── __archetype__.json       # Metadata
    ├── docker-compose.yml        # Services
    ├── .env.example              # Environment
    ├── src/                      # Source code
    ├── tests/                    # Tests
    └── README.md                 # Documentation
```

---

## Getting Help

- **Archetype Issues:** Report bugs with specific archetype
- **Composition Problems:** Include both archetypes involved
- **Questions:** Check [FAQ](FAQ.md) first
- **Examples:** See `archetypes/README.md` for archetype-specific docs

---

## Reference

- [Archetype README](../archetypes/README.md) - Detailed archetype documentation
- [Implementation Strategy](IMPLEMENTATION_STRATEGY.md) - Phase 6 details
- [Composition Design](MULTI_ARCHETYPE_COMPOSITION_DESIGN.md) - Technical details
- [Usage Guide](USAGE_GUIDE.md) - General usage patterns

---

**Last Updated:** November 21, 2025
**Available Archetypes:** 8 (3 base, 2 feature, 3 composite)
**Status:** Production-ready
