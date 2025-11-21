# Composite Archetype Examples

This directory contains example use cases for the composite RAG + Agents system.

## Basic Examples

### 1. Basic Agent Query (`examples/basic_agent_query.py`)

Simple example showing how to query documents using an agent:

```bash
python examples/basic_agent_query.py
```

**What it does:**
- Creates a research agent with RAG tool
- Queries documents with a simple question
- Returns synthesized answer

**Use when:** Learning the basics of agent + RAG integration

---

### 2. Multi-Tool Agent (`examples/multi_tool_agent.py`)

Advanced example with both RAG and web search:

```bash
python examples/multi_tool_agent.py
```

**What it does:**
- Creates agent with RAG + Tavily web search
- Combines internal and external information
- Shows tool selection reasoning

**Use when:** Need to combine multiple information sources

---

### 3. API Usage (`examples/api_usage.py`)

Complete HTTP API interaction example:

```bash
python examples/api_usage.py
```

**What it does:**
- Demonstrates all API endpoints
- Shows document upload workflow
- Compares search, RAG, and agent queries

**Use when:** Building a client application

---

### 4. Streaming Agent (`examples/streaming_agent.py`)

Real-time streaming responses:

```bash
python examples/streaming_agent.py
```

**What it does:**
- Streams agent reasoning in real-time
- Shows tool calls as they happen
- Displays tokens as generated

**Use when:** Need responsive user experience

---

## Advanced Use Cases

### Document Q&A System

Build an intelligent document Q&A system:

```python
from src.agents.workflows.research_agent import query_documents
from src.models.config import Settings

settings = Settings()

# User asks a question
answer = await query_documents(
    "What is the company policy on remote work?",
    settings
)

print(answer)
```

**Features:**
- Semantic search across documents
- Context-aware answers
- Source citations
- Multi-step reasoning

---

### Research Assistant

Create an AI research assistant:

```python
from src.agents.workflows.research_agent import create_research_agent
from langchain_community.tools.tavily_search import TavilySearchResults

# Create agent with multiple tools
rag_tool = await create_rag_tool(settings)
web_search = TavilySearchResults()

agent = create_custom_agent([
    rag_tool.as_langchain_tool(),
    web_search,
    # Add more tools...
])

# Agent can now:
# 1. Search internal documents
# 2. Search the web
# 3. Synthesize information
# 4. Generate reports
```

**Use cases:**
- Academic research
- Market analysis
- Competitive intelligence
- Literature reviews

---

### Code Documentation Helper

Explain code from documentation:

```python
# Upload code documentation
upload_documents([
    "docs/api_reference.md",
    "docs/tutorials/*.md",
    "README.md"
])

# Query with agent
answer = await query_documents(
    "How do I authenticate with the API? Show me an example.",
    settings
)

# Agent will:
# 1. Find relevant documentation
# 2. Extract code examples
# 3. Explain the process
# 4. Provide working code
```

**Benefits:**
- Faster onboarding
- Consistent answers
- Always up-to-date
- Code examples included

---

### Multi-Source Intelligence

Combine multiple data sources:

```python
from src.agents.workflows.multi_source_agent import create_multi_source_agent

agent = await create_multi_source_agent(
    rag_tool=rag_tool,
    web_search=web_search,
    database_query=db_tool,
    api_calls=api_tool
)

# Agent can query:
# - Internal documents (RAG)
# - Web (Tavily)
# - Databases (custom tool)
# - External APIs (custom tool)

answer = await agent.ainvoke({
    "messages": [HumanMessage(content=query)]
})
```

**Use cases:**
- Business intelligence
- Data analysis
- Automated reporting
- Cross-platform search

---

## Customization Guide

### Creating Custom Tools

Add your own tools for agents:

```python
# custom_tools.py
from langchain_core.tools import StructuredTool
from pydantic import BaseModel, Field

class MyToolInput(BaseModel):
    query: str = Field(description="The query parameter")

def my_custom_function(query: str) -> str:
    # Your logic here
    result = do_something(query)
    return result

my_tool = StructuredTool(
    name="my_custom_tool",
    description="What this tool does and when to use it",
    func=my_custom_function,
    args_schema=MyToolInput
)
```

### Creating Custom Workflows

Build specialized agent workflows:

```python
# custom_workflows.py
from langgraph.graph import StateGraph, END
from typing import TypedDict

class MyAgentState(TypedDict):
    messages: list
    # Add your state fields

async def create_custom_workflow():
    workflow = StateGraph(MyAgentState)

    # Define nodes
    workflow.add_node("step1", step1_function)
    workflow.add_node("step2", step2_function)

    # Define edges
    workflow.set_entry_point("step1")
    workflow.add_edge("step1", "step2")
    workflow.add_edge("step2", END)

    return workflow.compile()
```

---

## Performance Tips

### 1. Optimize Retrieval

```python
# Adjust number of retrieved documents
settings.retrieval_k = 3  # Fast, less context
settings.retrieval_k = 10  # Slower, more context
```

### 2. Choose Right Model

```python
# Fast responses
settings.agent_model_name = "gpt-3.5-turbo"

# Better reasoning
settings.agent_model_name = "gpt-4-turbo-preview"

# Cost-effective
settings.agent_model_name = "gpt-4o-mini"
```

### 3. Limit Iterations

```python
# Prevent long-running agents
settings.agent_max_iterations = 5
```

### 4. Use Caching

```python
# Enable semantic caching
from langchain.cache import InMemoryCache
from langchain.globals import set_llm_cache

set_llm_cache(InMemoryCache())
```

---

## Debugging

### Enable Tracing

```bash
# In .env
LANGCHAIN_TRACING_V2=true
LANGCHAIN_API_KEY=your-key
LANGCHAIN_PROJECT=my-project
```

View traces at: https://smith.langchain.com

### Logging

```python
import logging

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

# Add to your code
logger.debug(f"Agent state: {state}")
logger.info(f"Tool called: {tool_name}")
```

### Monitoring

Check agent performance:

```bash
# View logs
docker-compose logs -f api

# Check metrics
curl http://localhost:8000/metrics

# Agent health
curl http://localhost:8000/agents/health
```

---

## Troubleshooting

### Agent Not Using Tools

**Problem:** Agent generates answers without calling tools

**Solution:**
1. Check tool description is clear
2. Enable tracing to see reasoning
3. Adjust agent temperature (lower = more focused)
4. Review system prompt

### Slow Responses

**Problem:** Agent takes too long

**Solution:**
1. Reduce `agent_max_iterations`
2. Use faster model (gpt-3.5-turbo)
3. Limit retrieval results (`k=3`)
4. Add timeout to tool calls

### Memory Issues

**Problem:** Agent runs out of memory

**Solution:**
1. Reduce context window
2. Clear message history periodically
3. Use checkpointing for long workflows
4. Increase container resources

---

## Next Steps

1. **Explore examples** - Run all example scripts
2. **Read documentation** - Check `docs/` directory
3. **Customize agents** - Create your own workflows
4. **Add tools** - Integrate your services
5. **Monitor performance** - Enable tracing and logging

## Resources

- [LangChain Documentation](https://python.langchain.com/)
- [LangGraph Documentation](https://langchain-ai.github.io/langgraph/)
- [ChromaDB Documentation](https://docs.trychroma.com/)
- [Ollama Documentation](https://ollama.ai/docs)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
