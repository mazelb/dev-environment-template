# Multi-Archetype Composition Examples

This document provides practical examples of combining multiple archetypes to create complex systems.

## Table of Contents

1. [Example 1: RAG + Agentic Workflows](#example-1-rag--agentic-workflows)
2. [Example 2: RAG + API Gateway + Monitoring](#example-2-rag--api-gateway--monitoring)
3. [Example 3: ML Training + Agentic](#example-3-ml-training--agentic)
4. [Example 4: Multi-API Microservices](#example-4-multi-api-microservices)
5. [Example 5: Data Pipeline + MLOps](#example-5-data-pipeline--mlops)

---

## Example 1: RAG + Agentic Workflows

**Scenario:** Search backend with autonomous agents that can query the RAG system

### Command

```bash
./create-project.sh --name rag-agent-system \
  --archetype rag-project \
  --add-features agentic-workflows
```

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ Client Application                                          │
└──────────────────┬──────────────────────────────────────────┘
                   │
       ┌───────────┴───────────┐
       │                       │
       ▼                       ▼
┌──────────────┐        ┌──────────────┐
│  RAG API     │        │ Agentic API  │
│  :8000       │        │  :8100       │
└──────┬───────┘        └──────┬───────┘
       │                       │
       ▼                       ▼
┌──────────────┐        ┌──────────────┐
│ OpenSearch   │        │   Airflow    │
│  :9200       │◄───────┤  :8180       │
└──────────────┘        └──────────────┘
       ▲
       │
       ▼
┌──────────────┐
│   Ollama     │
│  :11434      │
└──────────────┘
```

### Services & Ports

| Service | Port | Archetype | Description |
|---------|------|-----------|-------------|
| rag-api | 8000 | RAG | Document search API |
| opensearch | 9200 | RAG | Vector database |
| ollama | 11434 | RAG | Embedding model |
| agentic-api | 8100 | Agentic | Agent orchestration API |
| airflow-webserver | 8180 | Agentic | Workflow UI |
| airflow-scheduler | - | Agentic | Task scheduler |

### Project Structure

```
rag-agent-system/
├── src/
│   ├── api/
│   │   ├── main.py                      # Merged FastAPI app
│   │   └── routers/
│   │       ├── search.py                # RAG endpoints
│   │       ├── documents.py             # RAG document management
│   │       └── agents.py                # Agentic endpoints
│   ├── services/
│   │   ├── rag/
│   │   │   ├── embedding_service.py
│   │   │   ├── search_service.py
│   │   │   └── document_processor.py
│   │   └── agentic/
│   │       ├── agent_orchestrator.py
│   │       ├── workflow_engine.py
│   │       └── task_executor.py
│   └── models/
│       ├── documents.py
│       ├── search_results.py
│       └── agents.py
├── tests/
│   ├── rag/
│   │   ├── test_search.py
│   │   └── test_embeddings.py
│   └── agentic/
│       ├── test_agents.py
│       └── test_workflows.py
├── docker/
│   ├── opensearch/
│   │   └── opensearch.yml
│   ├── ollama/
│   │   └── Dockerfile
│   └── airflow/
│       ├── dags/
│       │   └── rag_agent_workflow.py
│       └── airflow.cfg
├── docker-compose.yml                   # Base services
├── docker-compose.rag.yml               # RAG services
├── docker-compose.agentic.yml           # Agentic services
├── Makefile                             # Merged commands
├── .env                                 # Merged configuration
├── requirements.txt                     # Resolved dependencies
└── COMPOSITION.md                       # Multi-archetype guide
```

### Makefile Commands

```makefile
# Start all services
start: rag-start agentic-start

# Start RAG only
rag-start:
	docker-compose -f docker-compose.yml -f docker-compose.rag.yml up -d

# Start Agentic only
agentic-start:
	docker-compose -f docker-compose.yml -f docker-compose.agentic.yml up -d

# Run all tests
test: rag-test agentic-test

# RAG tests
rag-test:
	pytest tests/rag/ -v

# Agentic tests
agentic-test:
	pytest tests/agentic/ -v

# View logs
logs:
	docker-compose logs -f

# Stop all
stop:
	docker-compose down
```

### Environment Variables (.env)

```bash
# ===== RAG Configuration =====
OPENAI_API_KEY=your_openai_key
OPENSEARCH_HOST=opensearch
OPENSEARCH_PORT=9200
OLLAMA_HOST=ollama
OLLAMA_PORT=11434
OLLAMA_MODEL=llama2
EMBEDDING_MODEL=nomic-embed-text

# ===== Agentic Configuration =====
ANTHROPIC_API_KEY=your_anthropic_key
AIRFLOW_HOST=agentic_airflow
AIRFLOW_PORT=8080
AIRFLOW__CORE__EXECUTOR=LocalExecutor
AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql+psycopg2://airflow:airflow@postgres:5432/airflow

# ===== Shared Configuration =====
LOG_LEVEL=INFO
PROJECT_NAME=rag-agent-system
ENVIRONMENT=development
```

### Quick Start

```bash
# 1. Navigate to project
cd rag-agent-system

# 2. Copy environment file
cp .env.example .env
# Edit .env with your API keys

# 3. Start all services
make start

# 4. Wait for services to be ready
docker-compose ps

# 5. Test RAG API
curl http://localhost:8000/health

# 6. Test Agentic API
curl http://localhost:8100/health

# 7. Access Airflow UI
open http://localhost:8180

# 8. Run sample workflow
python examples/rag_agent_example.py
```

### Use Cases

1. **Autonomous Research Agent**
   - Agent queries RAG system for information
   - Synthesizes results
   - Generates reports

2. **Document Q&A with Agents**
   - Upload documents to RAG
   - Agents answer complex questions
   - Multi-step reasoning with retrieval

3. **Automated Content Curation**
   - Agents search for relevant documents
   - RAG provides semantic search
   - Airflow schedules regular updates

---

## Example 2: RAG + API Gateway + Monitoring

**Scenario:** Production-ready RAG system with authentication and observability

### Command

```bash
./create-project.sh --name rag-production \
  --archetype rag-project \
  --add-features api-gateway,monitoring
```

### Architecture

```
Internet
    │
    ▼
┌──────────────────┐
│  API Gateway     │  Rate limiting
│  :8200           │  Authentication
│  (NGINX)         │  Load balancing
└────────┬─────────┘
         │
         ├────────────────┬─────────────────┐
         ▼                ▼                 ▼
    ┌─────────┐    ┌─────────┐      ┌─────────┐
    │ RAG API │    │ Metrics │      │ Logs    │
    │ :8000   │───►│ :9090   │      │ :3000   │
    └─────────┘    │(Prom.)  │      │(Graf.)  │
         │         └─────────┘      └─────────┘
         ▼
    ┌─────────┐
    │OpenSearch│
    │ :9200   │
    └─────────┘
```

### Services & Ports

| Service | Port | Archetype | Description |
|---------|------|-----------|-------------|
| api-gateway | 8200 | Gateway | Public entry point |
| rag-api | 8000 | RAG | Internal API (not exposed) |
| opensearch | 9200 | RAG | Vector database |
| prometheus | 9090 | Monitoring | Metrics |
| grafana | 3000 | Monitoring | Dashboards |
| alertmanager | 9093 | Monitoring | Alerts |

### Key Features

- ✅ **Authentication:** JWT-based auth via API Gateway
- ✅ **Rate Limiting:** 100 req/min per IP
- ✅ **Monitoring:** Pre-built Grafana dashboards
- ✅ **Alerting:** Prometheus alerts for high latency, errors
- ✅ **SSL/TLS:** NGINX SSL termination
- ✅ **Logging:** Centralized logging with Grafana Loki

---

## Example 3: ML Training + Agentic

**Scenario:** Autonomous agents that train and deploy ML models

### Command

```bash
./create-project.sh --name ml-agent-system \
  --archetype ml-training \
  --add-features agentic-workflows
```

### Workflow

```
┌─────────────────────────────────────────────────────────────┐
│ Agent: Model Training Orchestrator                          │
└──────────────────────┬──────────────────────────────────────┘
                       │
       ┌───────────────┼───────────────┐
       │               │               │
       ▼               ▼               ▼
┌────────────┐  ┌────────────┐  ┌────────────┐
│  Monitor   │  │ Hyperparam │  │   Deploy   │
│  Training  │  │   Search   │  │   Model    │
└────────────┘  └────────────┘  └────────────┘
       │               │               │
       └───────────────┴───────────────┘
                       │
                       ▼
              ┌────────────────┐
              │    MLflow      │
              │  Tracking      │
              └────────────────┘
```

### Agent Capabilities

1. **Training Monitor Agent**
   - Watches training progress
   - Detects convergence or divergence
   - Triggers interventions

2. **Hyperparameter Search Agent**
   - Runs Bayesian optimization
   - Tests different configurations
   - Reports best parameters

3. **Deployment Agent**
   - Validates model performance
   - Deploys if accuracy > threshold
   - Rolls back if issues detected

---

## Example 4: Multi-API Microservices

**Scenario:** Three separate APIs in one project

### Command

```bash
./create-project.sh --name microservices \
  --archetypes api-service,api-service,api-service \
  --service-names auth-api,user-api,payment-api \
  --priority auth-api
```

### Services

| Service | Port | Responsibility |
|---------|------|----------------|
| auth-api | 8000 | Authentication & Authorization |
| user-api | 8100 | User management |
| payment-api | 8200 | Payment processing |
| postgres | 5432 | Shared database |
| redis | 6379 | Shared cache |

### Project Structure

```
microservices/
├── src/
│   ├── auth/
│   │   ├── api/
│   │   ├── models/
│   │   └── services/
│   ├── user/
│   │   ├── api/
│   │   ├── models/
│   │   └── services/
│   └── payment/
│       ├── api/
│       ├── models/
│       └── services/
├── docker-compose.yml
├── docker-compose.auth.yml
├── docker-compose.user.yml
├── docker-compose.payment.yml
└── Makefile
```

### Communication

APIs communicate via:
- **Synchronous:** HTTP REST calls
- **Asynchronous:** Redis pub/sub
- **Database:** Shared PostgreSQL

---

## Example 5: Data Pipeline + MLOps

**Scenario:** ETL pipelines with ML model training and deployment

### Command

```bash
./create-project.sh --name data-ml-pipeline \
  --archetype data-pipeline \
  --add-features mlops
```

### Pipeline Flow

```
Data Sources
    │
    ▼
┌─────────────┐
│  Airflow    │  ETL jobs
│  :8080      │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Data Lake  │  Processed data
│ (MinIO)     │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Model     │  Training
│  Training   │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   MLflow    │  Tracking & Registry
│  :5000      │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Model      │  Serving
│  Serving    │
└─────────────┘
```

### DAGs

1. **Data Ingestion DAG**
   - Extract from sources
   - Transform data
   - Load to data lake

2. **Model Training DAG**
   - Fetch training data
   - Train model
   - Log to MLflow
   - Deploy if validated

3. **Monitoring DAG**
   - Check data quality
   - Monitor model performance
   - Alert on drift

---

## Best Practices

### 1. Start Simple

Begin with base archetype, add features incrementally:

```bash
# Step 1: RAG only
./create-project.sh --name myapp --archetype rag-project

# Step 2: Add monitoring
cd myapp
# Manually add monitoring feature

# Step 3: Add more features as needed
```

### 2. Check Compatibility First

```bash
./create-project.sh --check-compatibility \
  --archetype rag-project \
  --add-features agentic-workflows,monitoring
```

### 3. Preview Before Creating

```bash
./create-project.sh --name myapp \
  --archetype rag-project \
  --add-features agentic-workflows \
  --dry-run
```

### 4. Use Composite for Common Patterns

```bash
# Instead of manually combining
./create-project.sh --name myapp --archetype rag-agentic-system

# Pre-configured, tested, optimized
```

### 5. Document Your Composition

Always read `COMPOSITION.md` after project creation for architecture overview.

---

## Troubleshooting

### Port Already in Use

```bash
# Check what's using the port
lsof -i :8000

# Change port in .env
echo "RAG_API_PORT=8001" >> .env

# Or stop conflicting service
docker stop <container>
```

### Service Not Starting

```bash
# Check logs
make logs

# Check individual service
docker-compose logs rag-api

# Verify dependencies
docker-compose ps
```

### Dependency Conflicts

```bash
# Check requirements.txt
cat requirements.txt

# Manually resolve
pip install package==compatible_version
```

---

## Next Steps

1. Read `COMPOSITION.md` in your project
2. Review `Makefile` for available commands
3. Check `docker-compose*.yml` files for services
4. Run tests: `make test`
5. Start coding!

For more information, see:
- [Multi-Archetype Design](MULTI_ARCHETYPE_COMPOSITION_DESIGN.md)
- [Archetypes Guide](archetypes/README.md)
- [Conflict Resolution](docs/CONFLICT_RESOLUTION.md)
