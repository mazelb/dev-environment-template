# Technical Reference

**Version:** 1.0
**Last Updated:** November 28, 2025

Complete technical documentation for the dev-environment-template, including architecture, service specifications, API documentation, database schemas, and configuration reference.

---

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Service Specifications](#service-specifications)
- [API Documentation](#api-documentation)
- [Database Schemas](#database-schemas)
- [Configuration Reference](#configuration-reference)
- [Extension Points](#extension-points)
- [Performance Tuning](#performance-tuning)
- [Security Considerations](#security-considerations)

---

## Architecture Overview

### System Components

The dev-environment-template provides a modular architecture with three primary archetype categories:

```
┌─────────────────────────────────────────────────────┐
│                   Dev Environment                    │
│  ┌───────────────────────────────────────────────┐  │
│  │         VS Code Dev Container                 │  │
│  │  - Multi-language support (C++, Python, Node) │  │
│  │  - AI assistants integration                  │  │
│  │  - Personal settings sync                     │  │
│  └───────────────────────────────────────────────┘  │
│                                                       │
│  ┌──────────────┐ ┌──────────────┐ ┌─────────────┐ │
│  │     RAG      │ │  API Service │ │  Frontend   │ │
│  │  Archetype   │ │  Archetype   │ │  Archetype  │ │
│  └──────────────┘ └──────────────┘ └─────────────┘ │
│         │                │                 │         │
│  ┌──────▼────────────────▼─────────────────▼──────┐ │
│  │          Docker Compose Infrastructure         │ │
│  │  - Service orchestration                       │ │
│  │  - Network management                          │ │
│  │  - Volume persistence                          │ │
│  └────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────┘
```

### Network Architecture

All services within an archetype communicate through dedicated Docker networks:

- **RAG Network:** `rag-network` (bridge)
- **API Network:** `api-network` (bridge)
- **Frontend Network:** `frontend-network` (bridge)

---

## Service Specifications

### RAG Archetype Services

#### PostgreSQL 16 Alpine

**Purpose:** Relational database for metadata, user data, and application state

**Configuration:**
- **Image:** `postgres:16-alpine`
- **Port:** 5432 (host) → 5432 (container)
- **Environment:**
  - `POSTGRES_USER`: rag_user
  - `POSTGRES_PASSWORD`: rag_password
  - `POSTGRES_DB`: rag_db
- **Volume:** `postgres_data:/var/lib/postgresql/data`
- **Health Check:** `pg_isready -U rag_user`

**Connection String:**
```
postgresql://rag_user:rag_password@postgres:5432/rag_db
```

**Use Cases:**
- Store document metadata
- User authentication/authorization
- Application configuration
- Audit logs

---

#### Redis 7 Alpine

**Purpose:** Caching, session storage, rate limiting, task queues

**Configuration:**
- **Image:** `redis:7-alpine`
- **Port:** 6379 (host) → 6379 (container)
- **Persistence:** AOF (Append-Only File)
- **Max Memory:** 256MB
- **Eviction Policy:** allkeys-lru
- **Volume:** `redis_data:/data`

**Connection String:**
```
redis://redis:6379/0
```

**Use Cases:**
- Cache LLM responses
- Rate limiting (API requests)
- Session storage
- Celery broker (in API-Service)

---

#### OpenSearch 2.19.0

**Purpose:** Vector search, full-text search, hybrid search

**Configuration:**
- **Image:** `opensearchproject/opensearch:2.19.0`
- **Ports:**
  - 9200 (REST API)
  - 9600 (Performance Analyzer)
- **Environment:**
  - `discovery.type`: single-node
  - `OPENSEARCH_JAVA_OPTS`: -Xms512m -Xmx512m
  - `DISABLE_SECURITY_PLUGIN`: true (dev only)
- **Volume:** `opensearch_data:/usr/share/opensearch/data`

**API Endpoint:**
```
http://localhost:9200
```

**Capabilities:**
- k-NN vector search
- BM25 keyword search
- Hybrid search with RRF (Reciprocal Rank Fusion)
- Aggregations and analytics

**Index Configuration:**
```json
{
  "settings": {
    "index": {
      "knn": true,
      "knn.algo_param.ef_search": 100
    }
  },
  "mappings": {
    "properties": {
      "text": {"type": "text"},
      "embedding": {
        "type": "knn_vector",
        "dimension": 768,
        "method": {
          "name": "hnsw",
          "space_type": "l2",
          "engine": "nmslib"
        }
      }
    }
  }
}
```

---

#### Ollama 0.11.2

**Purpose:** Local LLM inference

**Configuration:**
- **Image:** `ollama/ollama:0.11.2`
- **Port:** 11434 (host) → 11434 (container)
- **Volume:** `ollama_models:/root/.ollama`
- **GPU:** Optional (NVIDIA with `runtime: nvidia`)

**API Endpoint:**
```
http://localhost:11434
```

**Supported Models:**
- llama2:7b, llama2:13b, llama2:70b
- mistral:7b
- mixtral:8x7b
- codellama:7b, codellama:13b

**Usage Example:**
```bash
# Pull model
docker-compose exec ollama ollama pull llama2:7b

# Run inference
curl -X POST http://localhost:11434/api/generate -d '{
  "model": "llama2:7b",
  "prompt": "Explain quantum computing"
}'
```

---

#### Langfuse v2

**Purpose:** LLM observability, tracing, cost tracking

**Configuration:**
- **Image:** `langfuse/langfuse:2`
- **Port:** 3000 (host) → 3000 (container)
- **Database:** Dedicated PostgreSQL instance
- **Volume:** `langfuse_data:/app/data`

**Web UI:**
```
http://localhost:3000
```

**Features:**
- Request/response tracing
- Token usage tracking
- Cost calculation
- Latency monitoring
- Error tracking
- User session analysis

**Integration:**
```python
from langfuse import Langfuse

langfuse = Langfuse(
    public_key=os.getenv("LANGFUSE_PUBLIC_KEY"),
    secret_key=os.getenv("LANGFUSE_SECRET_KEY"),
    host="http://langfuse:3000"
)

@langfuse.observe()
def generate_response(query: str):
    # Your LLM call
    pass
```

---

#### Apache Airflow 2.x

**Purpose:** Workflow orchestration, DAG scheduling

**Configuration:**
- **Services:**
  - `airflow-init`: Database initialization
  - `airflow-scheduler`: Task scheduling
  - `airflow-webserver`: Web UI
- **Port:** 8080 (web UI)
- **Executor:** LocalExecutor
- **Database:** PostgreSQL (airflow_db)
- **Volume:** `airflow_logs:/opt/airflow/logs`

**Web UI:**
```
http://localhost:8080
Username: admin
Password: admin
```

**DAG Structure:**
```python
from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime

with DAG(
    'document_ingestion',
    start_date=datetime(2025, 1, 1),
    schedule_interval='@daily',
    catchup=False
) as dag:

    fetch_documents = PythonOperator(
        task_id='fetch_documents',
        python_callable=fetch_arxiv_papers
    )

    process_documents = PythonOperator(
        task_id='process_documents',
        python_callable=process_and_index
    )

    fetch_documents >> process_documents
```

---

#### OpenSearch Dashboards 2.19.0

**Purpose:** OpenSearch data visualization

**Configuration:**
- **Image:** `opensearchproject/opensearch-dashboards:2.19.0`
- **Port:** 5601 (host) → 5601 (container)
- **Connects to:** OpenSearch on port 9200

**Web UI:**
```
http://localhost:5601
```

**Features:**
- Index management
- Query builder
- Visualization tools
- Dashboard creation
- Dev Tools console

---

### API-Service Archetype Services

#### FastAPI Application

**Purpose:** REST and GraphQL API server

**Configuration:**
- **Framework:** FastAPI 0.104+
- **Port:** 8000 (default)
- **Features:**
  - Automatic OpenAPI documentation
  - Pydantic validation
  - Async/await support
  - GraphQL via Strawberry

**Endpoints:**
- `GET /` - Root/health check
- `GET /docs` - Swagger UI (OpenAPI)
- `GET /redoc` - ReDoc documentation
- `POST /graphql` - GraphQL endpoint
- `GET /graphql` - GraphQL Playground

---

#### Celery Worker

**Purpose:** Background task processing

**Configuration:**
- **Broker:** Redis
- **Backend:** Redis
- **Concurrency:** 4 workers (default)

**Task Definition:**
```python
from celery import Celery

celery_app = Celery(
    'tasks',
    broker='redis://redis:6379/0',
    backend='redis://redis:6379/1'
)

@celery_app.task
def process_large_file(file_id: str):
    # Long-running task
    pass
```

**Usage:**
```python
# Enqueue task
task = process_large_file.delay(file_id="123")

# Check status
result = task.get(timeout=10)
```

---

#### Flower

**Purpose:** Celery monitoring and management

**Configuration:**
- **Port:** 5555 (host) → 5555 (container)
- **Connects to:** Redis broker

**Web UI:**
```
http://localhost:5555
```

**Features:**
- Real-time task monitoring
- Worker status
- Task history
- Rate limiting
- Task revocation

---

### Frontend Archetype Services

#### Next.js 14.2 Application

**Purpose:** TypeScript-based React frontend

**Configuration:**
- **Framework:** Next.js 14.2 with App Router
- **Port:** 3001 (default)
- **Build:** Production-optimized with multi-stage Docker

**Features:**
- Server-side rendering (SSR)
- Static site generation (SSG)
- API routes
- TypeScript strict mode
- Tailwind CSS + shadcn/ui

**Structure:**
```
frontend/
├── src/
│   ├── app/           # App Router pages
│   ├── components/    # React components
│   ├── lib/          # Utilities
│   │   ├── http-client.ts    # Axios REST client
│   │   ├── graphql-client.ts # Apollo GraphQL
│   │   └── websocket.ts      # Socket.io
│   └── types/        # TypeScript types
```

---

## API Documentation

### RAG Archetype REST API

#### POST /api/v1/ask

**Description:** Submit a question to the RAG system

**Request:**
```json
{
  "query": "What is quantum computing?",
  "filters": {
    "category": "cs.AI",
    "date_range": {
      "start": "2024-01-01",
      "end": "2024-12-31"
    }
  },
  "top_k": 5,
  "stream": false
}
```

**Response:**
```json
{
  "answer": "Quantum computing is...",
  "sources": [
    {
      "document_id": "arxiv:2401.12345",
      "title": "Introduction to Quantum Computing",
      "score": 0.95,
      "chunk": "Quantum computing uses quantum bits..."
    }
  ],
  "trace_id": "trace_123abc",
  "latency_ms": 1234
}
```

---

#### POST /api/v1/search/hybrid

**Description:** Perform hybrid search (keyword + semantic)

**Request:**
```json
{
  "query": "machine learning optimization",
  "top_k": 10,
  "rrf_k": 60,
  "filters": {
    "categories": ["cs.AI", "cs.LG"]
  }
}
```

**Response:**
```json
{
  "results": [
    {
      "id": "doc_123",
      "title": "Optimization Techniques in ML",
      "score": 0.92,
      "excerpt": "This paper presents...",
      "metadata": {
        "authors": ["John Doe"],
        "published": "2024-05-15",
        "category": "cs.AI"
      }
    }
  ],
  "total": 42,
  "took_ms": 156
}
```

---

### API-Service GraphQL Schema

#### Queries

```graphql
type Query {
  # Get user by ID
  user(id: ID!): User

  # List users with pagination
  users(
    limit: Int = 10
    offset: Int = 0
    filter: UserFilter
  ): UserConnection!

  # Search functionality
  search(
    query: String!
    type: SearchType!
  ): [SearchResult!]!
}

type User {
  id: ID!
  email: String!
  name: String
  createdAt: DateTime!
  updatedAt: DateTime!
}

type UserConnection {
  edges: [UserEdge!]!
  pageInfo: PageInfo!
  totalCount: Int!
}

type UserEdge {
  node: User!
  cursor: String!
}

type PageInfo {
  hasNextPage: Boolean!
  hasPreviousPage: Boolean!
  startCursor: String
  endCursor: String
}
```

#### Mutations

```graphql
type Mutation {
  # Create new user
  createUser(input: CreateUserInput!): User!

  # Update user
  updateUser(id: ID!, input: UpdateUserInput!): User!

  # Delete user
  deleteUser(id: ID!): Boolean!
}

input CreateUserInput {
  email: String!
  name: String
  password: String!
}

input UpdateUserInput {
  email: String
  name: String
  password: String
}
```

#### Example Query

```graphql
query GetUsers {
  users(limit: 5, offset: 0) {
    edges {
      node {
        id
        email
        name
        createdAt
      }
    }
    pageInfo {
      hasNextPage
      totalCount
    }
  }
}
```

---

## Database Schemas

### RAG Archetype Database

#### documents table

```sql
CREATE TABLE documents (
    id SERIAL PRIMARY KEY,
    external_id VARCHAR(255) UNIQUE NOT NULL,  -- e.g., arxiv:2401.12345
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    summary TEXT,
    category VARCHAR(100),
    authors JSONB,  -- Array of author names
    published_date DATE,
    indexed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB,  -- Additional flexible metadata

    -- Indexes
    INDEX idx_external_id (external_id),
    INDEX idx_category (category),
    INDEX idx_published_date (published_date),
    INDEX idx_metadata_gin (metadata) USING GIN
);
```

#### document_chunks table

```sql
CREATE TABLE document_chunks (
    id SERIAL PRIMARY KEY,
    document_id INTEGER NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
    chunk_index INTEGER NOT NULL,
    content TEXT NOT NULL,
    embedding_vector FLOAT8[] NOT NULL,  -- For pgvector
    token_count INTEGER,

    -- Indexes
    INDEX idx_document_id (document_id),
    INDEX idx_chunk_index (chunk_index)
);
```

#### users table

```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(255),
    role VARCHAR(50) DEFAULT 'user',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Indexes
    INDEX idx_email (email),
    INDEX idx_role (role)
);
```

#### query_logs table

```sql
CREATE TABLE query_logs (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    query TEXT NOT NULL,
    response TEXT,
    trace_id VARCHAR(255),
    latency_ms INTEGER,
    tokens_used INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_trace_id (trace_id),
    INDEX idx_created_at (created_at)
);
```

---

### API-Service Database

#### Example User Schema

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,

    -- Indexes
    INDEX idx_email (email),
    INDEX idx_username (username),
    INDEX idx_is_active (is_active)
);
```

---

## Configuration Reference

### Environment Variables

#### RAG Archetype (.env)

```bash
# Application
DEBUG=true
ENVIRONMENT=development
LOG_LEVEL=INFO

# PostgreSQL
POSTGRES_USER=rag_user
POSTGRES_PASSWORD=rag_password
POSTGRES_DB=rag_db
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
DATABASE_URL=postgresql://rag_user:rag_password@postgres:5432/rag_db

# Redis
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_DB=0
REDIS_PASSWORD=

# OpenSearch
OPENSEARCH_HOST=opensearch
OPENSEARCH_PORT=9200
OPENSEARCH_INDEX=documents

# Ollama
OLLAMA_HOST=http://ollama:11434
OLLAMA_MODEL=llama2:7b

# Langfuse
LANGFUSE_HOST=http://langfuse:3000
LANGFUSE_PUBLIC_KEY=pk-lf-xxx
LANGFUSE_SECRET_KEY=sk-lf-xxx

# Airflow
AIRFLOW__CORE__EXECUTOR=LocalExecutor
AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql://airflow:airflow@postgres:5432/airflow_db
AIRFLOW__CORE__LOAD_EXAMPLES=False
AIRFLOW__WEBSERVER__SECRET_KEY=your-secret-key
AIRFLOW__WEBSERVER__EXPOSE_CONFIG=True

# RAG Configuration
CHUNK_SIZE=600
CHUNK_OVERLAP=100
EMBEDDING_MODEL=sentence-transformers/all-MiniLM-L6-v2
TOP_K_RESULTS=5
RRF_K=60
```

#### API-Service (.env)

```bash
# Application
DEBUG=true
API_VERSION=v1
SECRET_KEY=your-secret-key-change-in-production

# Database
DATABASE_URL=postgresql://api_user:api_password@postgres:5432/api_db
ASYNC_DATABASE_URL=postgresql+asyncpg://api_user:api_password@postgres:5432/api_db

# Redis
REDIS_URL=redis://redis:6379/0

# Celery
CELERY_BROKER_URL=redis://redis:6379/0
CELERY_RESULT_BACKEND=redis://redis:6379/1

# JWT Authentication
JWT_SECRET_KEY=your-jwt-secret
JWT_ALGORITHM=HS256
JWT_EXPIRATION_MINUTES=30

# CORS
CORS_ORIGINS=http://localhost:3001,http://localhost:3000
CORS_ALLOW_CREDENTIALS=true

# GraphQL
GRAPHQL_PLAYGROUND_ENABLED=true
GRAPHQL_INTROSPECTION_ENABLED=true
```

---

## Extension Points

### Adding Custom Embeddings

Create custom embedding service:

```python
# src/services/embeddings/custom_embedder.py
from typing import List
from .base import BaseEmbedder

class CustomEmbedder(BaseEmbedder):
    def __init__(self, model_name: str):
        self.model_name = model_name
        # Initialize your model

    def embed(self, texts: List[str]) -> List[List[float]]:
        # Your embedding logic
        pass

    @property
    def dimension(self) -> int:
        return 768  # Your embedding dimension
```

Register in config:

```python
# config/settings.py
EMBEDDER_CLASS = "services.embeddings.custom_embedder.CustomEmbedder"
EMBEDDER_CONFIG = {
    "model_name": "your-model"
}
```

---

### Adding Custom Search Filters

Extend search service:

```python
# src/services/opensearch/filters.py
from typing import Dict, Any

def custom_filter(field: str, value: Any) -> Dict:
    return {
        "term": {field: value}
    }

def register_filter(name: str, filter_func):
    FILTER_REGISTRY[name] = filter_func
```

---

### Adding Middleware

Create custom FastAPI middleware:

```python
# src/middlewares/custom_middleware.py
from fastapi import Request
from starlette.middleware.base import BaseHTTPMiddleware

class CustomMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        # Pre-processing
        response = await call_next(request)
        # Post-processing
        return response
```

Register in app:

```python
# src/main.py
from .middlewares.custom_middleware import CustomMiddleware

app.add_middleware(CustomMiddleware)
```

---

## Performance Tuning

### Database Connection Pooling

```python
from sqlalchemy import create_engine
from sqlalchemy.pool import QueuePool

engine = create_engine(
    DATABASE_URL,
    poolclass=QueuePool,
    pool_size=20,
    max_overflow=10,
    pool_pre_ping=True,
    pool_recycle=3600
)
```

### Redis Configuration

```bash
# redis.conf
maxmemory 256mb
maxmemory-policy allkeys-lru
save 900 1
appendonly yes
appendfsync everysec
```

### OpenSearch Tuning

```yaml
opensearch:
  environment:
    - "OPENSEARCH_JAVA_OPTS=-Xms2g -Xmx2g"  # Increase heap
    - "thread_pool.search.size=30"          # More search threads
    - "indices.query.bool.max_clause_count=2048"
```

---

## Security Considerations

### Production Checklist

- [ ] Change all default passwords
- [ ] Use secrets manager (not .env files)
- [ ] Enable HTTPS/TLS
- [ ] Implement rate limiting
- [ ] Add authentication to all services
- [ ] Set up firewalls
- [ ] Enable OpenSearch security plugin
- [ ] Use read-only database users where possible
- [ ] Implement audit logging
- [ ] Regular security updates

### Securing PostgreSQL

```sql
-- Create read-only user
CREATE USER readonly WITH PASSWORD 'secure-password';
GRANT CONNECT ON DATABASE rag_db TO readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly;

-- Revoke unnecessary permissions
REVOKE CREATE ON SCHEMA public FROM PUBLIC;
```

### Securing Redis

```bash
# Enable authentication
requirepass your-secure-password

# Disable dangerous commands
rename-command FLUSHDB ""
rename-command FLUSHALL ""
rename-command CONFIG ""
```

---

## Next Steps

- **[Architecture Diagrams](ARCHITECTURE.md)** - Visual system diagrams
- **[API Examples](../examples/)** - Code examples and use cases
- **[Testing Guide](../tests/TESTING_GUIDE.md)** - Testing strategies
- **[Troubleshooting](TROUBLESHOOTING.md)** - Common issues

---

**Last Updated:** November 28, 2025
**Version:** 1.0
