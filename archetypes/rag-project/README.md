# RAG Project Archetype

## Overview

Production-ready Retrieval-Augmented Generation (RAG) system with FastAPI, vector search, and LLM integration.

## Features

- 📄 **Document Ingestion**: Upload and process PDF, TXT, and Markdown files
- 🔍 **Semantic Search**: Vector similarity search using embeddings
- 🤖 **RAG Query**: Retrieval-augmented generation with context
- 🔀 **Hybrid Search**: Combined vector + keyword search strategies
- ⚡ **FastAPI**: Modern async Python web framework
- 🗄️ **Vector Database**: ChromaDB for efficient similarity search
- 🦙 **Local LLM**: Ollama for private LLM inference

## Architecture

```
┌─────────────┐
│   Client    │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────────┐
│         FastAPI Application         │
│  ┌──────────────────────────────┐  │
│  │  Routers (documents, search)  │  │
│  └──────────────────────────────┘  │
│  ┌──────────────────────────────┐  │
│  │  Services (RAG, Embeddings)   │  │
│  └──────────────────────────────┘  │
└──────┬──────────────────┬──────────┘
       │                  │
       ▼                  ▼
┌─────────────┐    ┌─────────────┐
│  ChromaDB   │    │   Ollama    │
│ (Vectors)   │    │   (LLM)     │
└─────────────┘    └─────────────┘
```

## Quick Start

### 1. Create Project

```bash
./create-project.sh my-rag-app --archetypes rag-project
cd my-rag-app
```

### 2. Configure Environment

```bash
cp .env.example .env
# Edit .env with your settings
```

### 3. Start Services

```bash
docker-compose up -d
```

### 4. Pull LLM Model

```bash
docker exec ollama ollama pull llama2
```

### 5. Test the API

```bash
# Health check
curl http://localhost:8000/health

# Upload document
curl -X POST http://localhost:8000/api/v1/documents/upload \
  -F "file=@document.pdf"

# Query with RAG
curl -X POST http://localhost:8000/api/v1/query \
  -H "Content-Type: application/json" \
  -d '{"query": "What is the main topic?", "k": 3}'
```

## API Endpoints

### Documents

- `POST /api/v1/documents/upload` - Upload and ingest document
- `GET /api/v1/documents/` - List all documents
- `GET /api/v1/documents/{id}` - Get document details
- `DELETE /api/v1/documents/{id}` - Delete document

### Search

- `POST /api/v1/search/semantic` - Vector similarity search
- `POST /api/v1/search/hybrid` - Combined vector + keyword search

### Query

- `POST /api/v1/query` - RAG query with context retrieval
- `POST /api/v1/query/stream` - Streaming RAG query

### System

- `GET /health` - Health check
- `GET /docs` - Interactive API documentation

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `VECTOR_DB_HOST` | ChromaDB hostname | `vector-db` |
| `VECTOR_DB_PORT` | ChromaDB port | `8001` |
| `OLLAMA_HOST` | Ollama API URL | `http://ollama:11434` |
| `EMBEDDING_MODEL` | Sentence transformer model | `all-MiniLM-L6-v2` |
| `COLLECTION_NAME` | ChromaDB collection name | `documents` |
| `CHUNK_SIZE` | Document chunk size | `500` |
| `CHUNK_OVERLAP` | Chunk overlap size | `50` |
| `OPENAI_API_KEY` | Optional OpenAI API key | - |

### Embedding Models

Supported sentence-transformer models:
- `all-MiniLM-L6-v2` (default, fast, good quality)
- `all-mpnet-base-v2` (higher quality, slower)
- `multi-qa-mpnet-base-dot-v1` (optimized for Q&A)

### LLM Models

Pull Ollama models:
```bash
docker exec ollama ollama pull llama2
docker exec ollama ollama pull mistral
docker exec ollama ollama pull phi
```

## Project Structure

```
.
├── src/
│   ├── api/
│   │   ├── main.py              # FastAPI application
│   │   ├── dependencies.py      # Dependency injection
│   │   └── routers/
│   │       ├── documents.py     # Document management
│   │       ├── search.py        # Search endpoints
│   │       └── query.py         # RAG query endpoints
│   ├── services/
│   │   ├── embeddings.py        # Embedding generation
│   │   ├── vector_store.py      # Vector DB operations
│   │   ├── document_processor.py# Document chunking
│   │   └── rag_service.py       # RAG orchestration
│   └── models/
│       ├── document.py          # Document models
│       ├── search.py            # Search models
│       └── config.py            # Settings
├── tests/
│   ├── unit/                    # Unit tests
│   └── integration/             # Integration tests
├── docker/
│   └── Dockerfile               # API container
├── docker-compose.yml           # Service orchestration
├── requirements.txt             # Python dependencies
└── .env.example                 # Environment template
```

## Composability

This archetype can be composed with:

- **Monitoring**: Add Prometheus + Grafana for metrics
- **Agentic Workflows**: Integrate LangGraph for complex workflows
- **API Gateway**: Add authentication and rate limiting

Example multi-archetype composition:
```bash
./create-project.sh my-rag-system \
  --archetypes rag-project,monitoring,api-gateway
```

## Development

### Run Tests

```bash
# Unit tests
pytest tests/unit -v

# Integration tests
pytest tests/integration -v

# With coverage
pytest --cov=src tests/
```

### Format Code

```bash
black src/ tests/
isort src/ tests/
```

### Lint

```bash
pylint src/
mypy src/
```

## Performance Tuning

### Vector Search

- Adjust `CHUNK_SIZE` for document granularity
- Use `CHUNK_OVERLAP` to maintain context across chunks
- Experiment with different embedding models

### LLM Inference

- Use smaller models (phi, tinyllama) for faster responses
- Use larger models (llama2, mistral) for better quality
- Consider GPU support for production workloads

### Scaling

- Add Redis for caching
- Use connection pooling for vector DB
- Deploy multiple API replicas behind load balancer

## Troubleshooting

### ChromaDB Connection Failed

```bash
# Check if container is running
docker ps | grep chroma

# View logs
docker logs <container-id>

# Restart service
docker-compose restart vector-db
```

### Ollama Model Not Found

```bash
# List available models
docker exec ollama ollama list

# Pull model
docker exec ollama ollama pull llama2
```

### Out of Memory

- Reduce `CHUNK_SIZE`
- Use smaller embedding model
- Limit concurrent requests

## License

Part of dev-environment-template project.

## References

- [LangChain Documentation](https://python.langchain.com/)
- [ChromaDB Documentation](https://docs.trychroma.com/)
- [Ollama Documentation](https://github.com/ollama/ollama)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
