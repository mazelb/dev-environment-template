#!/bin/bash

# Integration script for RAG + Agentic Workflows Composite Archetype
# This script is run after constituent archetypes are merged to create custom integrations

set -e

PROJECT_DIR="${1:-.}"
VERBOSE="${VERBOSE:-false}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [[ ! -f "$PROJECT_DIR/src/services/rag_service.py" ]]; then
    error "RAG service not found. This script must be run after RAG archetype is copied."
    exit 1
fi

if [[ ! -d "$PROJECT_DIR/src/agents" ]]; then
    error "Agents directory not found. This script must be run after agentic-workflows archetype is copied."
    exit 1
fi

log "Starting RAG + Agentic Workflows integration..."

# Step 1: Create RAG Tool for Agents
log "Creating RAG tool for agent use..."

cat > "$PROJECT_DIR/src/agents/tools/rag_tool.py" << 'EOF'
"""RAG Tool for LangGraph Agents

This tool allows agents to query the RAG system to retrieve
relevant documents and context for answering questions.
"""

from typing import Optional, Dict, Any
from langchain_core.tools import StructuredTool
from pydantic import BaseModel, Field

from src.services.rag_service import RAGService
from src.models.config import Settings


class RAGQueryInput(BaseModel):
    """Input schema for RAG query tool."""
    
    query: str = Field(
        description="The question or query to search for in the document database"
    )
    num_results: Optional[int] = Field(
        default=3,
        description="Number of relevant documents to retrieve (default: 3)"
    )


class RAGTool:
    """Tool for querying the RAG system from agents."""
    
    def __init__(self, rag_service: RAGService):
        self.rag_service = rag_service
    
    async def query_rag(
        self, 
        query: str, 
        num_results: int = 3
    ) -> Dict[str, Any]:
        """
        Query the RAG system for relevant documents.
        
        Args:
            query: The question or query to search for
            num_results: Number of relevant documents to retrieve
            
        Returns:
            Dictionary containing the answer and retrieved context
        """
        try:
            # Query the RAG service
            response = await self.rag_service.query(
                query=query,
                k=num_results
            )
            
            return {
                "success": True,
                "answer": response.answer,
                "num_sources": len(response.sources),
                "sources": [
                    {
                        "content": source.content,
                        "metadata": source.metadata,
                        "similarity": source.similarity
                    }
                    for source in response.sources
                ]
            }
        except Exception as e:
            return {
                "success": False,
                "error": str(e),
                "answer": None,
                "sources": []
            }
    
    def as_langchain_tool(self) -> StructuredTool:
        """
        Convert this tool to a LangChain StructuredTool for use in agents.
        
        Returns:
            LangChain StructuredTool that can be used by agents
        """
        return StructuredTool(
            name="query_documents",
            description=(
                "Search through the document database to find relevant information. "
                "Use this tool when you need to retrieve specific information from documents. "
                "The tool returns relevant document chunks and an AI-generated answer based on the context."
            ),
            func=self.query_rag,
            args_schema=RAGQueryInput
        )


async def create_rag_tool(settings: Optional[Settings] = None) -> RAGTool:
    """
    Factory function to create a RAG tool with initialized service.
    
    Args:
        settings: Optional settings object (will create default if not provided)
        
    Returns:
        Initialized RAGTool
    """
    if settings is None:
        settings = Settings()
    
    rag_service = RAGService(settings)
    await rag_service.initialize()
    
    return RAGTool(rag_service)
EOF

success "Created RAG tool at src/agents/tools/rag_tool.py"

# Step 2: Create Example Agent Workflow
log "Creating example agent workflow with RAG integration..."

cat > "$PROJECT_DIR/src/agents/workflows/research_agent.py" << 'EOF'
"""Research Agent Workflow

Example agent that uses RAG retrieval to answer questions about documents.
This demonstrates how to integrate the RAG tool into a LangGraph workflow.
"""

from typing import TypedDict, Annotated, Sequence
from langchain_core.messages import BaseMessage, HumanMessage, AIMessage
from langchain_openai import ChatOpenAI
from langgraph.graph import StateGraph, END
from langgraph.prebuilt import ToolNode
import operator

from src.agents.tools.rag_tool import create_rag_tool
from src.models.config import Settings


class AgentState(TypedDict):
    """State for the research agent."""
    messages: Annotated[Sequence[BaseMessage], operator.add]
    query: str
    answer: str


async def create_research_agent(settings: Settings):
    """
    Create a research agent that can query documents via RAG.
    
    The agent workflow:
    1. Receives a user query
    2. Uses RAG tool to search documents
    3. Generates a comprehensive answer
    """
    
    # Initialize RAG tool
    rag_tool = await create_rag_tool(settings)
    tools = [rag_tool.as_langchain_tool()]
    
    # Initialize LLM with tools
    llm = ChatOpenAI(
        model=settings.agent_model_name,
        temperature=settings.agent_temperature
    )
    llm_with_tools = llm.bind_tools(tools)
    
    # Define agent node
    async def agent_node(state: AgentState):
        """Agent decides whether to use tools or respond."""
        messages = state["messages"]
        response = await llm_with_tools.ainvoke(messages)
        return {"messages": [response]}
    
    # Define tool node
    tool_node = ToolNode(tools)
    
    # Define routing logic
    def should_continue(state: AgentState):
        """Determine if agent should continue or end."""
        messages = state["messages"]
        last_message = messages[-1]
        
        # If there are tool calls, continue to tools
        if hasattr(last_message, "tool_calls") and last_message.tool_calls:
            return "tools"
        # Otherwise, end
        return END
    
    # Build the graph
    workflow = StateGraph(AgentState)
    
    # Add nodes
    workflow.add_node("agent", agent_node)
    workflow.add_node("tools", tool_node)
    
    # Add edges
    workflow.set_entry_point("agent")
    workflow.add_conditional_edges(
        "agent",
        should_continue,
        {
            "tools": "tools",
            END: END
        }
    )
    workflow.add_edge("tools", "agent")
    
    # Compile
    app = workflow.compile()
    
    return app


async def query_documents(query: str, settings: Settings) -> str:
    """
    Query documents using the research agent.
    
    Args:
        query: The question to answer
        settings: Application settings
        
    Returns:
        The agent's answer
    """
    agent = await create_research_agent(settings)
    
    # Run the agent
    result = await agent.ainvoke({
        "messages": [HumanMessage(content=query)]
    })
    
    # Extract final answer
    final_message = result["messages"][-1]
    return final_message.content


# Example usage
if __name__ == "__main__":
    import asyncio
    
    async def main():
        settings = Settings()
        
        query = "What are the main topics discussed in the documents?"
        answer = await query_documents(query, settings)
        
        print(f"Query: {query}")
        print(f"Answer: {answer}")
    
    asyncio.run(main())
EOF

success "Created example agent workflow at src/agents/workflows/research_agent.py"

# Step 3: Update API routes to include agent endpoints
log "Creating agent API routes..."

cat > "$PROJECT_DIR/src/api/routers/agents.py" << 'EOF'
"""Agent API Endpoints

Endpoints for interacting with agentic workflows that use RAG.
"""

from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from typing import Optional

from src.models.config import Settings
from src.agents.workflows.research_agent import query_documents


router = APIRouter(prefix="/agents", tags=["agents"])


class AgentQueryRequest(BaseModel):
    """Request model for agent query."""
    query: str
    max_iterations: Optional[int] = 10


class AgentQueryResponse(BaseModel):
    """Response model for agent query."""
    query: str
    answer: str
    iterations: int


@router.post("/query", response_model=AgentQueryResponse)
async def agent_query(
    request: AgentQueryRequest,
    settings: Settings = Depends()
):
    """
    Query documents using an agentic workflow.
    
    The agent will:
    1. Analyze the question
    2. Query the RAG system for relevant documents
    3. Synthesize a comprehensive answer
    """
    try:
        answer = await query_documents(request.query, settings)
        
        return AgentQueryResponse(
            query=request.query,
            answer=answer,
            iterations=1  # TODO: Track actual iterations
        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Agent query failed: {str(e)}"
        )


@router.get("/health")
async def agent_health():
    """Health check for agent endpoints."""
    return {"status": "ok", "service": "agents"}
EOF

success "Created agent API routes at src/api/routers/agents.py"

# Step 4: Update main.py to include agent routes
log "Updating main.py to include agent routes..."

if grep -q "from src.api.routers import agents" "$PROJECT_DIR/src/api/main.py"; then
    warn "Agent routes already included in main.py, skipping..."
else
    # Add import after other router imports
    sed -i '/from src.api.routers/a from src.api.routers import agents' "$PROJECT_DIR/src/api/main.py"
    
    # Add router registration after other includes
    sed -i '/app.include_router/a app.include_router(agents.router)' "$PROJECT_DIR/src/api/main.py"
    
    success "Updated main.py with agent routes"
fi

# Step 5: Update requirements.txt with agent-specific dependencies
log "Ensuring all dependencies are in requirements.txt..."

REQUIRED_DEPS=(
    "langgraph>=0.0.40"
    "langchain>=0.1.0,<0.3.0"
    "langchain-openai>=0.0.5"
    "langchain-anthropic>=0.1.0"
    "tavily-python>=0.3.0"
)

for dep in "${REQUIRED_DEPS[@]}"; do
    dep_name=$(echo "$dep" | cut -d'>' -f1 | cut -d'=' -f1)
    if ! grep -q "^$dep_name" "$PROJECT_DIR/requirements.txt"; then
        echo "$dep" >> "$PROJECT_DIR/requirements.txt"
        success "Added $dep to requirements.txt"
    fi
done

# Step 6: Update .env.example with agent-specific variables
log "Updating .env.example with agent variables..."

cat >> "$PROJECT_DIR/.env.example" << 'EOF'

# ============================================
# AGENTIC WORKFLOWS CONFIGURATION
# ============================================

# Agent Model Configuration
AGENT_MODEL_NAME=gpt-4-turbo-preview
AGENT_TEMPERATURE=0.7
AGENT_MAX_ITERATIONS=10

# Tavily Search API (for web search tool)
TAVILY_API_KEY=your-tavily-api-key-here

# LangChain Tracing (for debugging agents)
LANGCHAIN_TRACING_V2=true
LANGCHAIN_API_KEY=your-langchain-api-key-here
LANGCHAIN_PROJECT=rag-agentic-system
EOF

success "Updated .env.example with agent configuration"

# Step 7: Create integration documentation
log "Creating integration documentation..."

cat > "$PROJECT_DIR/docs/RAG_AGENT_INTEGRATION.md" << 'EOF'
# RAG + Agent Integration Guide

This document explains how the RAG system and agentic workflows are integrated.

## Architecture

```
┌─────────────┐
│   Client    │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────────┐
│      FastAPI Application            │
│  ┌──────────────────────────────┐  │
│  │  RAG Endpoints (/rag/*)      │  │
│  │  Agent Endpoints (/agents/*) │  │
│  └──────────────────────────────┘  │
│           │              │          │
│           ▼              ▼          │
│  ┌───────────────┐  ┌──────────┐  │
│  │  RAG Service  │  │  Agent   │  │
│  │               │◄─┤  (uses   │  │
│  │               │  │  RAG as  │  │
│  │               │  │  tool)   │  │
│  └───────────────┘  └──────────┘  │
└──────┬──────────────────┬──────────┘
       │                  │
       ▼                  ▼
┌─────────────┐    ┌─────────────┐
│  ChromaDB   │    │   Ollama    │
│  (Vectors)  │    │   (LLM)     │
└─────────────┘    └─────────────┘
```

## Components

### RAG Tool (`src/agents/tools/rag_tool.py`)

The RAG tool wraps the RAG service and exposes it as a LangChain tool that agents can use:

```python
from src.agents.tools.rag_tool import create_rag_tool

rag_tool = await create_rag_tool(settings)
langchain_tool = rag_tool.as_langchain_tool()
```

### Research Agent (`src/agents/workflows/research_agent.py`)

Example agent that uses the RAG tool to answer questions:

```python
from src.agents.workflows.research_agent import query_documents

answer = await query_documents("What is ...?", settings)
```

### Agent API Routes (`src/api/routers/agents.py`)

FastAPI endpoints for interacting with agents:

- `POST /agents/query` - Query documents using agent
- `GET /agents/health` - Agent service health check

## Usage

### Direct Agent Usage

```python
from src.agents.workflows.research_agent import create_research_agent
from src.models.config import Settings

settings = Settings()
agent = await create_research_agent(settings)

result = await agent.ainvoke({
    "messages": [HumanMessage(content="What topics are covered?")]
})

answer = result["messages"][-1].content
```

### Via API

```bash
curl -X POST http://localhost:8000/agents/query \
  -H "Content-Type: application/json" \
  -d '{"query": "What are the main topics?"}'
```

## Configuration

Agent-specific configuration in `.env`:

```env
# Agent model
AGENT_MODEL_NAME=gpt-4-turbo-preview
AGENT_TEMPERATURE=0.7

# For web search (optional)
TAVILY_API_KEY=your-key-here

# For debugging
LANGCHAIN_TRACING_V2=true
LANGCHAIN_API_KEY=your-key-here
```

## Creating Custom Agents

To create a custom agent with RAG:

1. Create a new workflow file in `src/agents/workflows/`
2. Import the RAG tool
3. Define your agent's state
4. Build a StateGraph with your logic
5. Add the RAG tool to your agent's tools

Example:

```python
from src.agents.tools.rag_tool import create_rag_tool

async def create_custom_agent():
    rag_tool = await create_rag_tool()
    tools = [rag_tool.as_langchain_tool()]
    
    # Build your agent...
    # Use tools in your workflow
```

## Benefits

1. **Grounded Responses**: Agents can retrieve actual document content
2. **Multi-Step Reasoning**: Agents can query multiple times and synthesize
3. **Tool Composition**: RAG is just one tool agents can use
4. **Debugging**: LangChain tracing shows agent's decision-making

## Troubleshooting

### Agent not finding documents

- Check RAG service is running: `curl http://localhost:8000/health`
- Verify documents are indexed: `curl http://localhost:8000/documents`
- Check agent logs for errors

### Agent using RAG tool incorrectly

- Enable LangChain tracing: `LANGCHAIN_TRACING_V2=true`
- Review tool description in `rag_tool.py`
- Adjust agent's system prompt if needed
EOF

success "Created RAG_AGENT_INTEGRATION.md"

# Step 8: Summary
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║     RAG + Agentic Workflows Integration Complete!         ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
success "Created the following integration components:"
echo "  ✓ RAG tool for agents (src/agents/tools/rag_tool.py)"
echo "  ✓ Example research agent (src/agents/workflows/research_agent.py)"
echo "  ✓ Agent API routes (src/api/routers/agents.py)"
echo "  ✓ Updated main.py with agent routes"
echo "  ✓ Updated requirements.txt with dependencies"
echo "  ✓ Updated .env.example with agent configuration"
echo "  ✓ Created integration documentation (docs/RAG_AGENT_INTEGRATION.md)"
echo ""
log "Next steps:"
echo "  1. Review generated code in src/agents/"
echo "  2. Copy .env.example to .env and fill in API keys"
echo "  3. Install dependencies: pip install -r requirements.txt"
echo "  4. Start services: docker-compose up -d"
echo "  5. Test agent endpoint: POST /agents/query"
echo ""
success "Integration script completed successfully!"
