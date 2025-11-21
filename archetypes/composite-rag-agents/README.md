# Composite RAG + Agentic Workflows System

**Archetype Type:** Composite
**Version:** 1.0.0
**Created:** November 21, 2025

## Overview

This composite archetype combines two powerful AI archetypes into a unified system:

1. **RAG Project** (`rag-project`) - Vector search, document retrieval, and LLM generation
2. **Agentic Workflows** (`agentic-workflows`) - Stateful multi-step AI agents with tool calling

The result is a production-ready system where AI agents can intelligently query a RAG database as part of complex, multi-step reasoning workflows.

## What You Get

### From RAG Project
- ✅ **ChromaDB** vector database for semantic search
- ✅ **Ollama** local LLM inference
- ✅ **FastAPI** REST API for document management and search
- ✅ Embedding generation with sentence-transformers
- ✅ Document chunking and processing
- ✅ Semantic and hybrid search capabilities

### From Agentic Workflows
- ✅ **LangGraph** stateful workflow orchestration
- ✅ **Tool calling** capabilities for agents
- ✅ **State management** for multi-step tasks
- ✅ Integration with OpenAI, Anthropic, and other LLM providers
- ✅ **Tavily** web search integration
- ✅ Checkpointing and persistence

### Composite Integration
- ✅ **RAG Tool** for agents to query documents
- ✅ **Research Agent** example workflow
- ✅ **Unified API** with both RAG and agent endpoints
- ✅ Automatic dependency resolution
- ✅ Pre-configured environment variables
- ✅ Complete documentation and examples

## Architecture

```
┌──────────────────────────────────────────────────────────┐
│                    Client Application                     │
└────────────────────────┬─────────────────────────────────┘
                         │
                         ▼
┌────────────────────────────────────────────────────────────┐
│              FastAPI Application (Port 8000)               │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  API Routes:                                        │  │
│  │  • /documents/* - Document upload & management      │  │
│  │  • /search/* - Semantic search                      │  │
│  │  • /rag/* - RAG query endpoints                     │  │
│  │  • /agents/* - Agent workflow endpoints             │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                            │
│  ┌──────────────────┐         ┌──────────────────────┐   │
│  │   RAG Service    │         │   Agent Service      │   │
│  │                  │         │                      │   │
│  │  • Document      │         │  • LangGraph         │   │
│  │    processing    │         │    workflows         │   │
│  │  • Embeddings    │◄────────┤  • Tool calling      │   │
│  │  • Vector search │  RAG    │  • State mgmt        │   │
│  │  • LLM gen       │  Tool   │  • Multi-step        │   │
│  └──────────────────┘         └──────────────────────┘   │
└───────┬────────────────────┬──────────────────────────────┘
        │                    │
        ▼                    ▼
┌───────────────┐    ┌──────────────────┐
│   ChromaDB    │    │     Ollama       │
│  Port 8001    │    │   Port 11434     │
│               │    │                  │
│  • Vectors    │    │  • Local LLM     │
│  • Metadata   │    │  • Embeddings    │
│  • Similarity │    │  • Generation    │
└───────────────┘    └──────────────────┘
```

## Quick Start

### 1. Create Project

```bash
./create-project.sh my-ai-system \
  --archetype composite-rag-agents \
  --github
```

This single command:
- ✅ Copies RAG project structure
- ✅ Overlays agentic workflow code
- ✅ Runs integration script
- ✅ Resolves all conflicts
- ✅ Initializes Git repository
- ✅ Creates GitHub repository (optional)

### 2. Configure Environment

```bash
cd my-ai-system
cp .env.example .env
```

Edit `.env` and add your API keys:

```env
# Required
OPENAI_API_KEY=sk-...
TAVILY_API_KEY=tvly-...

# Optional (for debugging)
LANGCHAIN_TRACING_V2=true
LANGCHAIN_API_KEY=ls__...
```

### 3. Start Services

```bash
docker-compose up -d
```

This starts:
- FastAPI application (port 8000)
- ChromaDB vector database (port 8001)
- Ollama LLM server (port 11434)

### 4. Upload Documents

```bash
curl -X POST http://localhost:8000/documents/upload \
  -F "file=@mydocument.txt" \
  -F "metadata={\"source\":\"local\"}"
```

### 5. Query with Agent

```bash
curl -X POST http://localhost:8000/agents/query \
  -H "Content-Type: application/json" \
  -d '{
    "query": "What are the main topics in the documents?"
  }'
```

The agent will:
1. Analyze your question
2. Query the RAG system for relevant documents
3. Synthesize a comprehensive answer
4. Return results with sources

## Use Cases

### 1. Document Q&A Agent
**Complexity:** Intermediate

An agent that answers questions by intelligently retrieving and reasoning over your documents.

```python
from src.agents.workflows.research_agent import query_documents
from src.models.config import Settings

settings = Settings()
answer = await query_documents(
    "What is the company's policy on remote work?",
    settings
)
```

### 2. Research Assistant
**Complexity:** Advanced

Multi-step agent that:
- Searches documents for information
- Queries web for additional context (via Tavily)
- Synthesizes comprehensive reports
- Cites sources

### 3. Code Documentation Helper
**Complexity:** Intermediate

Agent that:
- Retrieves code snippets from documentation
- Explains functionality in natural language
- Provides usage examples
- Links related concepts

### 4. Multi-Source Intelligence
**Complexity:** Advanced

Agent that combines:
- Internal document search (RAG)
- Web search (Tavily)
- Structured data queries
- Real-time API calls

## Integration Details

### RAG Tool

The integration creates a `RAGTool` that agents can use:

```python
# src/agents/tools/rag_tool.py
from src.agents.tools.rag_tool import create_rag_tool

rag_tool = await create_rag_tool(settings)
langchain_tool = rag_tool.as_langchain_tool()

# Tool description visible to agents:
# "Search through the document database to find relevant
#  information. Use this tool when you need to retrieve
#  specific information from documents."
```

### Research Agent Example

```python
# src/agents/workflows/research_agent.py
from langgraph.graph import StateGraph
from langchain_openai import ChatOpenAI

async def create_research_agent(settings):
    # Initialize tools
    rag_tool = await create_rag_tool(settings)
    tools = [rag_tool.as_langchain_tool()]

    # Create LLM with tools
    llm = ChatOpenAI(model="gpt-4-turbo-preview")
    llm_with_tools = llm.bind_tools(tools)

    # Build workflow graph
    workflow = StateGraph(AgentState)
    workflow.add_node("agent", agent_node)
    workflow.add_node("tools", tool_node)

    # Add conditional routing
    workflow.add_conditional_edges("agent", should_continue)

    return workflow.compile()
```

### API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/documents/upload` | POST | Upload document for indexing |
| `/documents` | GET | List all documents |
| `/search` | POST | Semantic search |
| `/rag/query` | POST | RAG query (retrieval + generation) |
| `/agents/query` | POST | Agent query (multi-step reasoning) |
| `/agents/health` | GET | Agent service health check |

## Configuration

### Environment Variables

```env
# RAG Configuration
CHROMADB_HOST=chromadb
CHROMADB_PORT=8001
OLLAMA_HOST=http://ollama:11434
EMBEDDING_MODEL=all-MiniLM-L6-v2
CHUNK_SIZE=500
CHUNK_OVERLAP=50

# Agent Configuration
AGENT_MODEL_NAME=gpt-4-turbo-preview
AGENT_TEMPERATURE=0.7
AGENT_MAX_ITERATIONS=10
OPENAI_API_KEY=sk-...

# Web Search (Optional)
TAVILY_API_KEY=tvly-...

# Debugging (Optional)
LANGCHAIN_TRACING_V2=true
LANGCHAIN_API_KEY=ls__...
LANGCHAIN_PROJECT=my-ai-system
```

### Docker Services

```yaml
services:
  api:
    ports: ["8000:8000"]
    environment:
      - All configuration from .env

  chromadb:
    ports: ["8001:8000"]
    volumes:
      - chromadb_data:/chroma/chroma

  ollama:
    ports: ["11434:11434"]
    volumes:
      - ollama_data:/root/.ollama
```

## Development

### Project Structure

```
my-ai-system/
├── src/
│   ├── api/
│   │   ├── main.py              # FastAPI app
│   │   └── routers/
│   │       ├── documents.py     # Document endpoints
│   │       ├── search.py        # Search endpoints
│   │       ├── rag.py           # RAG endpoints
│   │       └── agents.py        # Agent endpoints (NEW)
│   ├── models/
│   │   ├── config.py            # Settings
│   │   ├── document.py          # Document models
│   │   └── search.py            # Search models
│   ├── services/
│   │   ├── document_processor.py
│   │   ├── embeddings.py
│   │   ├── vector_store.py
│   │   └── rag_service.py
│   └── agents/                   # NEW: Agent code
│       ├── tools/
│       │   └── rag_tool.py      # RAG tool for agents
│       └── workflows/
│           └── research_agent.py # Example agent
├── tests/
├── docker-compose.yml
├── requirements.txt
└── .env
```

### Running Tests

```bash
# Install dev dependencies
pip install -r requirements.txt pytest pytest-cov

# Run all tests
pytest tests/ -v

# Run with coverage
pytest tests/ -v --cov=src --cov-report=html

# Run specific test
pytest tests/integration/test_agent_rag.py -v
```

### Adding Custom Agents

1. Create workflow file in `src/agents/workflows/`
2. Import RAG tool and other tools you need
3. Define agent state (TypedDict)
4. Build StateGraph with your logic
5. Add API endpoint in `src/api/routers/agents.py`

Example:

```python
# src/agents/workflows/my_custom_agent.py
from langgraph.graph import StateGraph
from src.agents.tools.rag_tool import create_rag_tool

async def create_my_agent():
    # Get RAG tool
    rag_tool = await create_rag_tool()

    # Add other tools
    tools = [
        rag_tool.as_langchain_tool(),
        # Add more tools...
    ]

    # Build workflow
    workflow = StateGraph(MyAgentState)
    # ... define nodes and edges

    return workflow.compile()
```

## Performance

### Typical Latency

| Operation | Average | Description |
|-----------|---------|-------------|
| Document upload | 2-5s | Includes chunking + embedding |
| Semantic search | 100-300ms | Vector similarity search |
| RAG query | 2-4s | Retrieval + LLM generation |
| Agent query | 5-15s | Multi-step with tool calls |

### Optimization Tips

1. **Use smaller embedding models** for faster indexing
   - `all-MiniLM-L6-v2` (default, fast)
   - `all-mpnet-base-v2` (slower, more accurate)

2. **Adjust chunk size** based on document type
   - Technical docs: 300-500 tokens
   - Long-form content: 800-1000 tokens

3. **Limit agent iterations** to control latency
   - Set `AGENT_MAX_ITERATIONS=5` for faster responses

4. **Use caching** for repeated queries
   - ChromaDB caches vectors in memory
   - Ollama caches model context

## Troubleshooting

### Agent Not Using RAG Tool

**Problem:** Agent generates answers without querying documents

**Solutions:**
1. Check tool description is clear (`rag_tool.py`)
2. Enable tracing: `LANGCHAIN_TRACING_V2=true`
3. Review agent's system prompt
4. Ensure documents are indexed: `GET /documents`

### ChromaDB Connection Error

**Problem:** `ConnectionError: Cannot connect to ChromaDB`

**Solutions:**
1. Check ChromaDB is running: `docker-compose ps`
2. Verify port: `CHROMADB_PORT=8001`
3. Check network: Services on same Docker network?
4. Restart: `docker-compose restart chromadb`

### Ollama Model Not Found

**Problem:** `Model 'llama2' not found`

**Solutions:**
1. Pull model: `docker exec ollama ollama pull llama2`
2. Check available: `docker exec ollama ollama list`
3. Use different model: `OLLAMA_MODEL=mistral`

### API Key Errors

**Problem:** `AuthenticationError: Invalid API key`

**Solutions:**
1. Check `.env` has correct keys
2. Restart services: `docker-compose restart api`
3. Verify key format: `sk-...` for OpenAI
4. Test key: `curl https://api.openai.com/v1/models -H "Authorization: Bearer $OPENAI_API_KEY"`

### Slow Agent Responses

**Problem:** Agent takes >30s to respond

**Solutions:**
1. Reduce `AGENT_MAX_ITERATIONS`
2. Use faster LLM: `gpt-3.5-turbo` instead of `gpt-4`
3. Limit retrieval results: `k=3` instead of `k=10`
4. Profile with tracing: `LANGCHAIN_TRACING_V2=true`

## Advanced Topics

### Custom Tool Development

Add your own tools for agents:

```python
# src/agents/tools/custom_tool.py
from langchain_core.tools import StructuredTool

def my_custom_function(arg: str) -> str:
    # Your logic here
    return result

custom_tool = StructuredTool(
    name="custom_tool",
    description="What this tool does",
    func=my_custom_function
)
```

### Multi-Agent Orchestration

Coordinate multiple agents:

```python
from langgraph.graph import StateGraph

# Create specialized agents
research_agent = await create_research_agent(settings)
writer_agent = await create_writer_agent(settings)

# Orchestrate
workflow = StateGraph(OrchestratorState)
workflow.add_node("research", research_agent)
workflow.add_node("write", writer_agent)
workflow.add_edge("research", "write")
```

### Streaming Responses

Stream agent reasoning in real-time:

```python
@router.post("/agents/stream")
async def stream_agent_query(request: AgentQueryRequest):
    agent = await create_research_agent(settings)

    async for event in agent.astream_events(
        {"messages": [HumanMessage(content=request.query)]},
        version="v1"
    ):
        yield json.dumps(event) + "\n"
```

## Composability

This composite archetype can be further extended with:

### + Monitoring
```bash
./create-project.sh my-system \
  --archetype composite-rag-agents \
  --add-features monitoring
```
Adds: Prometheus, Grafana, log aggregation

### + API Gateway
```bash
./create-project.sh my-system \
  --archetype composite-rag-agents \
  --add-features api-gateway
```
Adds: Authentication, rate limiting, API versioning

## Documentation

- **Integration Guide:** `docs/RAG_AGENT_INTEGRATION.md`
- **RAG Documentation:** `docs/RAG.md`
- **Agent Documentation:** `docs/AGENTS.md`
- **API Reference:** `http://localhost:8000/docs` (when running)

## License

MIT License - see LICENSE file for details

## Contributing

Contributions welcome! Please see `CONTRIBUTING.md` for guidelines.

## Support

- GitHub Issues: https://github.com/mazelb/dev-environment-template/issues
- Discussions: https://github.com/mazelb/dev-environment-template/discussions
- Documentation: https://github.com/mazelb/dev-environment-template/wiki

## Version History

- **1.0.0** (2025-11-21) - Initial release
  - Combined rag-project v2.0 + agentic-workflows v1.0
  - RAG tool for agents
  - Research agent example
  - Complete integration

## Acknowledgments

- Built on [LangChain](https://langchain.com) and [LangGraph](https://langchain-ai.github.io/langgraph/)
- Uses [ChromaDB](https://www.trychroma.com/) for vector storage
- Uses [Ollama](https://ollama.ai/) for local LLM inference
- Inspired by the [arxiv-paper-curator](https://github.com/mazelb/arxiv-paper-curator) project
