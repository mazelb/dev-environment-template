# Architecture Documentation

**Version:** 1.0
**Last Updated:** November 28, 2025

Visual architecture documentation for the dev-environment-template using Mermaid diagrams.

---

## Table of Contents

- [System Overview](#system-overview)
- [RAG Archetype Architecture](#rag-archetype-architecture)
- [API-Service Archetype Architecture](#api-service-archetype-architecture)
- [Frontend Archetype Architecture](#frontend-archetype-architecture)
- [Network Architecture](#network-architecture)
- [Data Flow Diagrams](#data-flow-diagrams)
- [Deployment Architecture](#deployment-architecture)

---

## System Overview

### High-Level Architecture

```mermaid
graph TB
    subgraph "Development Environment"
        DevContainer[VS Code Dev Container<br/>Multi-language Support]
        AITools[AI Assistants<br/>Claude, GPT, etc.]
    end

    subgraph "Project Archetypes"
        RAG[RAG Archetype<br/>OpenSearch + Ollama]
        API[API-Service Archetype<br/>FastAPI + GraphQL]
        FE[Frontend Archetype<br/>Next.js TypeScript]
        MON[Monitoring Archetype<br/>Prometheus + Grafana]
    end

    subgraph "Docker Infrastructure"
        Compose[Docker Compose<br/>Orchestration]
        Networks[Docker Networks<br/>Service Isolation]
        Volumes[Docker Volumes<br/>Data Persistence]
    end

    DevContainer -->|creates| RAG
    DevContainer -->|creates| API
    DevContainer -->|creates| FE
    DevContainer -->|creates| MON

    RAG --> Compose
    API --> Compose
    FE --> Compose
    MON --> Compose

    Compose --> Networks
    Compose --> Volumes

    AITools -.assists.-> DevContainer
```

### Component Interaction

```mermaid
graph LR
    User[Developer]
    VSCode[VS Code<br/>with Dev Container]
    Template[dev-environment-template]
    Project[Created Project]
    Services[Docker Services]

    User -->|opens| VSCode
    VSCode -->|uses| Template
    Template -->|generates| Project
    Project -->|starts| Services

    Services -->|provides| Database[(PostgreSQL)]
    Services -->|provides| Cache[(Redis)]
    Services -->|provides| Search[(OpenSearch)]
    Services -->|provides| LLM[Ollama]
```

---

## RAG Archetype Architecture

### Service Architecture

```mermaid
graph TB
    subgraph "Client Layer"
        Client[HTTP Client<br/>curl, Postman, etc.]
    end

    subgraph "API Layer"
        FastAPI[FastAPI Application<br/>Port 8000]
        Endpoints["/api/v1/ask<br/>/api/v1/search<br/>/api/v1/documents"]
    end

    subgraph "Service Layer"
        RAGPipeline[RAG Pipeline Service]
        Embeddings[Embedding Service<br/>sentence-transformers]
        Chunking[Document Chunking<br/>Recursive Splitter]
        Cache[Cache Service<br/>Redis Client]
    end

    subgraph "Integration Layer"
        OSClient[OpenSearch Client<br/>Hybrid Search]
        OllamaClient[Ollama Client<br/>LLM Inference]
        DBService[Database Service<br/>SQLAlchemy]
        Tracing[Langfuse Tracing<br/>Observability]
    end

    subgraph "Infrastructure Layer"
        PostgreSQL[(PostgreSQL<br/>Port 5432)]
        Redis[(Redis<br/>Port 6379)]
        OpenSearch[(OpenSearch<br/>Port 9200)]
        Ollama[Ollama<br/>Port 11434]
        Langfuse[Langfuse<br/>Port 3000]
        Airflow[Apache Airflow<br/>Port 8080]
    end

    Client --> FastAPI
    FastAPI --> Endpoints
    Endpoints --> RAGPipeline
    Endpoints --> Cache

    RAGPipeline --> Embeddings
    RAGPipeline --> Chunking
    RAGPipeline --> OSClient
    RAGPipeline --> OllamaClient
    RAGPipeline --> Tracing

    Embeddings --> OSClient
    Chunking --> OSClient
    OSClient --> OpenSearch
    OllamaClient --> Ollama
    DBService --> PostgreSQL
    Cache --> Redis
    Tracing --> Langfuse

    style Client fill:#e1f5ff
    style FastAPI fill:#fff4e1
    style RAGPipeline fill:#ffe1e1
    style PostgreSQL fill:#e1ffe1
    style Redis fill:#ffe1f5
    style OpenSearch fill:#f5e1ff
    style Ollama fill:#e1ffff
```

### RAG Query Flow

```mermaid
sequenceDiagram
    participant User
    participant API as FastAPI
    participant Cache as Redis Cache
    participant RAG as RAG Pipeline
    participant Embed as Embeddings
    participant OS as OpenSearch
    participant LLM as Ollama
    participant LF as Langfuse

    User->>API: POST /api/v1/ask<br/>{query: "What is RAG?"}

    API->>Cache: Check cache
    Cache-->>API: Cache miss

    API->>LF: Start trace
    API->>RAG: process_query(query)

    RAG->>Embed: generate_embedding(query)
    Embed-->>RAG: embedding_vector

    RAG->>OS: hybrid_search(query, vector)
    Note over OS: BM25 + k-NN search<br/>RRF fusion
    OS-->>RAG: top_k documents

    RAG->>RAG: build_context(documents)
    RAG->>LLM: generate(prompt + context)
    LLM-->>RAG: generated_response

    RAG-->>API: {answer, sources, trace_id}
    API->>Cache: cache_response(key, result)
    API->>LF: End trace (tokens, latency)

    API-->>User: JSON response
```

### Document Ingestion Flow (Airflow)

```mermaid
graph TB
    Start[Airflow DAG Trigger<br/>Daily/Manual]

    subgraph "Document Ingestion DAG"
        Fetch[Fetch Documents<br/>Arxiv API / File Upload]
        Parse[Parse PDF<br/>docling]
        Extract[Extract Metadata<br/>Title, Authors, Date]
        Chunk[Chunk Content<br/>Recursive Splitter]
        Embed[Generate Embeddings<br/>sentence-transformers]
        Index[Index to OpenSearch<br/>+ Store in PostgreSQL]
        Notify[Send Notification]
    end

    Start --> Fetch
    Fetch --> Parse
    Parse --> Extract
    Extract --> Chunk
    Chunk --> Embed
    Embed --> Index
    Index --> Notify

    Index --> PostgreSQL[(PostgreSQL<br/>Metadata)]
    Index --> OpenSearch[(OpenSearch<br/>Vectors)]

    style Fetch fill:#e1f5ff
    style Parse fill:#fff4e1
    style Chunk fill:#ffe1e1
    style Embed fill:#f5e1ff
    style Index fill:#e1ffe1
```

---

## API-Service Archetype Architecture

### Microservice Architecture

```mermaid
graph TB
    subgraph "Client Layer"
        REST[REST Client]
        GraphQL[GraphQL Client]
        WS[WebSocket Client]
    end

    subgraph "API Gateway Layer"
        FastAPI[FastAPI Application<br/>Port 8000]
        Middleware[Middleware Stack<br/>Auth, CORS, Logging]
    end

    subgraph "API Layer"
        RESTRoutes[REST Endpoints<br/>/api/v1/*]
        GQLSchema[GraphQL Schema<br/>/graphql]
        WebSocket[WebSocket Handler<br/>/ws]
    end

    subgraph "Business Logic Layer"
        Services[Service Layer<br/>Business Logic]
        Auth[Auth Service<br/>JWT]
        Validation[Validation Layer<br/>Pydantic]
    end

    subgraph "Data Access Layer"
        Repositories[Repository Pattern<br/>CRUD Operations]
        SyncDB[Sync DB Engine<br/>SQLAlchemy]
        AsyncDB[Async DB Engine<br/>asyncpg]
    end

    subgraph "Background Processing"
        Celery[Celery Worker]
        Tasks[Task Definitions]
        Flower[Flower<br/>Monitoring<br/>Port 5555]
    end

    subgraph "Infrastructure Layer"
        PostgreSQL[(PostgreSQL<br/>Port 5432)]
        Redis[(Redis<br/>Port 6379<br/>Broker + Cache)]
    end

    REST --> FastAPI
    GraphQL --> FastAPI
    WS --> FastAPI

    FastAPI --> Middleware
    Middleware --> RESTRoutes
    Middleware --> GQLSchema
    Middleware --> WebSocket

    RESTRoutes --> Services
    GQLSchema --> Services
    WebSocket --> Services

    Services --> Auth
    Services --> Validation
    Services --> Repositories

    Repositories --> SyncDB
    Repositories --> AsyncDB

    SyncDB --> PostgreSQL
    AsyncDB --> PostgreSQL

    Services --> Celery
    Celery --> Tasks
    Celery --> Redis
    Tasks --> PostgreSQL

    Celery --> Flower

    style FastAPI fill:#fff4e1
    style Services fill:#ffe1e1
    style Repositories fill:#e1f5ff
    style Celery fill:#f5e1ff
    style PostgreSQL fill:#e1ffe1
    style Redis fill:#ffe1f5
```

### GraphQL Request Flow

```mermaid
sequenceDiagram
    participant Client
    participant API as FastAPI
    participant Auth as Auth Middleware
    participant Schema as GraphQL Schema
    participant Resolver as Resolvers
    participant Repo as Repository
    participant DB as PostgreSQL

    Client->>API: POST /graphql<br/>query { users { id, email } }

    API->>Auth: Verify JWT token
    Auth-->>API: User authenticated

    API->>Schema: Parse query
    Schema->>Resolver: Execute resolver

    Resolver->>Repo: get_users(limit, offset)
    Repo->>DB: SELECT * FROM users...
    DB-->>Repo: Result set

    Repo-->>Resolver: User objects
    Resolver-->>Schema: Formatted response
    Schema-->>API: GraphQL response

    API-->>Client: JSON response
```

### Celery Background Task Flow

```mermaid
graph LR
    API[FastAPI Endpoint]
    Queue[Redis Queue]
    Worker[Celery Worker]
    DB[(PostgreSQL)]
    Result[Redis Result Backend]

    API -->|Enqueue task| Queue
    Queue -->|Pull task| Worker
    Worker -->|Process| Worker
    Worker -->|Update data| DB
    Worker -->|Store result| Result

    API -->|Check status| Result
    Result -->|Return result| API

    style API fill:#fff4e1
    style Worker fill:#ffe1e1
    style Queue fill:#ffe1f5
    style Result fill:#ffe1f5
```

---

## Frontend Archetype Architecture

### Next.js Application Architecture

```mermaid
graph TB
    subgraph "Client Browser"
        Browser[Web Browser]
    end

    subgraph "Next.js Application"
        AppRouter[App Router<br/>Next.js 14]
        Pages[Page Components<br/>src/app/]
        Components[UI Components<br/>src/components/]
        Layouts[Layouts<br/>src/app/layout.tsx]
    end

    subgraph "Client Libraries"
        HTTPClient[HTTP Client<br/>Axios with Retry]
        GQLClient[GraphQL Client<br/>Apollo Client]
        WSClient[WebSocket Client<br/>Socket.io]
    end

    subgraph "State Management"
        Zustand[Zustand<br/>Global State]
        TanStack[TanStack Query<br/>Server State]
    end

    subgraph "Backend Services"
        RESTAPI[REST API<br/>FastAPI]
        GraphQLAPI[GraphQL API<br/>Strawberry]
        WSServer[WebSocket Server]
    end

    Browser --> AppRouter
    AppRouter --> Pages
    Pages --> Components
    Pages --> Layouts

    Components --> HTTPClient
    Components --> GQLClient
    Components --> WSClient

    Components --> Zustand
    Components --> TanStack

    HTTPClient --> RESTAPI
    GQLClient --> GraphQLAPI
    WSClient --> WSServer

    TanStack -.caches.-> GQLClient
    TanStack -.caches.-> HTTPClient

    style Browser fill:#e1f5ff
    style AppRouter fill:#fff4e1
    style Components fill:#ffe1e1
    style HTTPClient fill:#f5e1ff
    style GQLClient fill:#f5e1ff
    style WSClient fill:#f5e1ff
    style Zustand fill:#e1ffe1
    style TanStack fill:#e1ffe1
```

### Frontend Data Flow

```mermaid
sequenceDiagram
    participant User
    participant UI as React Component
    participant Query as TanStack Query
    participant Apollo as Apollo Client
    participant API as Backend API
    participant Cache as Apollo Cache

    User->>UI: Interact (click button)
    UI->>Query: useQuery('getUsers')
    Query->>Apollo: fetch query

    Apollo->>Cache: Check cache
    alt Cache Hit
        Cache-->>Apollo: Return cached data
        Apollo-->>Query: Cached data
    else Cache Miss
        Apollo->>API: HTTP/GraphQL Request
        API-->>Apollo: Response data
        Apollo->>Cache: Update cache
        Apollo-->>Query: Fresh data
    end

    Query-->>UI: Data + loading state
    UI-->>User: Render updated UI
```

---

## Network Architecture

### Docker Network Topology

```mermaid
graph TB
    subgraph "Host Machine"
        Host[Host Network<br/>localhost]
    end

    subgraph "RAG Network (Bridge)"
        RAGApp[RAG App<br/>Internal: app]
        RAGPG[PostgreSQL<br/>Internal: postgres]
        RAGRedis[Redis<br/>Internal: redis]
        RAGOS[OpenSearch<br/>Internal: opensearch]
        RAGOllama[Ollama<br/>Internal: ollama]
        RAGLangfuse[Langfuse<br/>Internal: langfuse]
    end

    subgraph "API Network (Bridge)"
        APIApp[API App<br/>Internal: api]
        APIPG[PostgreSQL<br/>Internal: postgres]
        APIRedis[Redis<br/>Internal: redis]
        Celery[Celery Worker<br/>Internal: celery]
        Flower[Flower<br/>Internal: flower]
    end

    subgraph "Frontend Network (Bridge)"
        FEApp[Next.js App<br/>Internal: frontend]
    end

    Host -->|8000:8000| RAGApp
    Host -->|5432:5432| RAGPG
    Host -->|6379:6379| RAGRedis
    Host -->|9200:9200| RAGOS
    Host -->|11434:11434| RAGOllama
    Host -->|3000:3000| RAGLangfuse

    Host -->|8001:8000| APIApp
    Host -->|5555:5555| Flower

    Host -->|3001:3000| FEApp

    FEApp -.HTTP.-> RAGApp
    FEApp -.HTTP.-> APIApp

    RAGApp --> RAGPG
    RAGApp --> RAGRedis
    RAGApp --> RAGOS
    RAGApp --> RAGOllama
    RAGApp --> RAGLangfuse

    APIApp --> APIPG
    APIApp --> APIRedis
    Celery --> APIRedis
    Celery --> APIPG

    style Host fill:#e1f5ff
    style RAGApp fill:#fff4e1
    style APIApp fill:#ffe1e1
    style FEApp fill:#f5e1ff
```

---

## Data Flow Diagrams

### RAG Data Flow

```mermaid
flowchart TB
    Start([User Query])

    Cache{Cache<br/>Hit?}
    Embed[Generate Query<br/>Embedding]
    Search[Hybrid Search<br/>OpenSearch]
    Context[Build Context<br/>from Documents]
    LLM[Generate Response<br/>Ollama]
    Trace[Log to Langfuse]
    Store[Cache Result]

    End([Return Response])

    Start --> Cache
    Cache -->|Miss| Embed
    Cache -->|Hit| End

    Embed --> Search
    Search --> Context
    Context --> LLM
    LLM --> Trace
    Trace --> Store
    Store --> End

    style Start fill:#e1f5ff
    style Cache fill:#fff4e1
    style Search fill:#ffe1e1
    style LLM fill:#f5e1ff
    style End fill:#e1ffe1
```

### API Request Flow

```mermaid
flowchart TB
    Request([HTTP Request])

    Auth{Auth<br/>Valid?}
    RateLimit{Rate<br/>Limit OK?}
    Validate{Data<br/>Valid?}
    Process[Process Request]
    DB[Database Operation]
    Response[Format Response]

    Success([200 OK])
    Unauthorized([401 Unauthorized])
    TooMany([429 Too Many Requests])
    BadRequest([400 Bad Request])

    Request --> Auth
    Auth -->|Invalid| Unauthorized
    Auth -->|Valid| RateLimit

    RateLimit -->|Exceeded| TooMany
    RateLimit -->|OK| Validate

    Validate -->|Invalid| BadRequest
    Validate -->|Valid| Process

    Process --> DB
    DB --> Response
    Response --> Success

    style Request fill:#e1f5ff
    style Process fill:#fff4e1
    style DB fill:#e1ffe1
    style Success fill:#d4edda
    style Unauthorized fill:#f8d7da
    style TooMany fill:#fff3cd
    style BadRequest fill:#f8d7da
```

---

## Deployment Architecture

### Development Environment

```mermaid
graph TB
    subgraph "Developer Machine"
        VSCode[VS Code]
        Docker[Docker Desktop]
    end

    subgraph "Dev Containers"
        DevEnv[Dev Container<br/>All Tools Installed]
    end

    subgraph "Local Services"
        Services[Docker Compose Services]
    end

    VSCode -->|Uses| DevEnv
    DevEnv -->|Manages| Services
    Docker -->|Runs| Services

    style VSCode fill:#e1f5ff
    style DevEnv fill:#fff4e1
    style Services fill:#ffe1e1
```

### Production Deployment (Example: Kubernetes)

```mermaid
graph TB
    subgraph "Load Balancer"
        LB[Ingress Controller<br/>NGINX]
    end

    subgraph "Application Pods"
        API1[API Pod 1]
        API2[API Pod 2]
        API3[API Pod 3]
    end

    subgraph "Background Workers"
        Celery1[Celery Worker 1]
        Celery2[Celery Worker 2]
    end

    subgraph "Data Services"
        PG[(PostgreSQL<br/>StatefulSet)]
        Redis[(Redis<br/>StatefulSet)]
        OS[(OpenSearch<br/>StatefulSet)]
    end

    subgraph "Observability"
        Prometheus[Prometheus]
        Grafana[Grafana]
        Langfuse[Langfuse]
    end

    LB --> API1
    LB --> API2
    LB --> API3

    API1 --> PG
    API2 --> PG
    API3 --> PG

    API1 --> Redis
    API2 --> Redis
    API3 --> Redis

    API1 --> OS
    API2 --> OS
    API3 --> OS

    Celery1 --> Redis
    Celery2 --> Redis
    Celery1 --> PG
    Celery2 --> PG

    API1 -.metrics.-> Prometheus
    API2 -.metrics.-> Prometheus
    API3 -.metrics.-> Prometheus

    API1 -.traces.-> Langfuse
    API2 -.traces.-> Langfuse
    API3 -.traces.-> Langfuse

    Prometheus --> Grafana

    style LB fill:#e1f5ff
    style API1 fill:#fff4e1
    style API2 fill:#fff4e1
    style API3 fill:#fff4e1
    style PG fill:#e1ffe1
    style Redis fill:#ffe1f5
    style OS fill:#f5e1ff
```

---

## Component Diagrams

### Database Schema Relationships (RAG)

```mermaid
erDiagram
    USERS ||--o{ QUERY_LOGS : creates
    DOCUMENTS ||--o{ DOCUMENT_CHUNKS : contains
    QUERY_LOGS }o--o{ DOCUMENTS : references

    USERS {
        int id PK
        string email UK
        string password_hash
        string name
        string role
        timestamp created_at
    }

    DOCUMENTS {
        int id PK
        string external_id UK
        string title
        text content
        string category
        jsonb authors
        date published_date
        timestamp indexed_at
    }

    DOCUMENT_CHUNKS {
        int id PK
        int document_id FK
        int chunk_index
        text content
        float8[] embedding_vector
        int token_count
    }

    QUERY_LOGS {
        int id PK
        int user_id FK
        text query
        text response
        string trace_id
        int latency_ms
        timestamp created_at
    }
```

---

## Next Steps

- **[Technical Reference](TECHNICAL_REFERENCE.md)** - Detailed service specifications
- **[Usage Guide](USAGE_GUIDE.md)** - How to use the architecture
- **[Deployment Guide](DEPLOYMENT_GUIDE.md)** - Production deployment (coming soon)

---

**Last Updated:** November 28, 2025
**Version:** 1.0
