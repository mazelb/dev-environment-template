# Agentic Workflows Archetype

## Overview

Stateful agentic workflows using LangGraph for complex multi-step AI tasks with tool calling, state management, and human-in-the-loop capabilities.

## Features

- 🔄 **Stateful Workflows**: Persistent state across multi-step executions
- 🛠️ **Tool Calling**: LLM function calling with custom tools
- 👤 **Human-in-the-Loop**: Interrupt workflows for approval/feedback
- 🤖 **Multi-Agent**: Coordinate specialized agents for complex tasks
- 💾 **Checkpointing**: Save and resume workflow execution
- 📊 **State Management**: Type-safe state with Pydantic

## Architecture

```
┌─────────────────────────────────────┐
│      LangGraph StateGraph          │
│  ┌───────────────────────────────┐ │
│  │   Agent Node (ReAct)          │ │
│  │   ├─ LLM (GPT-4/Claude)       │ │
│  │   ├─ Tool Selection           │ │
│  │   └─ Reasoning Loop           │ │
│  └───────────────────────────────┘ │
│  ┌───────────────────────────────┐ │
│  │   Tools Node                  │ │
│  │   ├─ Search (Tavily)          │ │
│  │   ├─ Calculator               │ │
│  │   └─ Custom Tools             │ │
│  └───────────────────────────────┘ │
│  ┌───────────────────────────────┐ │
│  │   Checkpointer (SQLite)       │ │
│  └───────────────────────────────┘ │
└─────────────────────────────────────┘
```

## Quick Start

### 1. Create Project

```bash
./create-project.sh my-agent-app --archetypes agentic-workflows
cd my-agent-app
```

### 2. Configure API Keys

```bash
cp .env.example .env
# Add your API keys:
# - OPENAI_API_KEY
# - TAVILY_API_KEY (for search)
# - ANTHROPIC_API_KEY (optional)
```

### 3. Run Basic Agent

```python
from src.workflows.research_agent import create_research_workflow

# Create workflow
workflow = create_research_workflow()

# Run agent
result = workflow.invoke({
    "messages": [("user", "Research the latest in quantum computing")]
})

print(result["messages"][-1].content)
```

## Core Components

### 1. State Management

```python
from typing import TypedDict, Annotated, Sequence
from langchain_core.messages import BaseMessage
from langgraph.graph import add_messages

class AgentState(TypedDict):
    messages: Annotated[Sequence[BaseMessage], add_messages]
    next_action: str
    iteration: int
```

### 2. Agent Node

```python
from langchain_openai import ChatOpenAI
from langchain_core.tools import tool

@tool
def search_web(query: str) -> str:
    """Search the web for information."""
    # Implementation
    return result

llm = ChatOpenAI(model="gpt-4")
agent = llm.bind_tools([search_web])
```

### 3. Workflow Graph

```python
from langgraph.graph import StateGraph, END

workflow = StateGraph(AgentState)
workflow.add_node("agent", agent_node)
workflow.add_node("tools", tools_node)
workflow.add_edge("agent", "tools")
workflow.add_edge("tools", "agent")
workflow.set_entry_point("agent")

app = workflow.compile()
```

## Example Workflows

### Research Agent

Multi-step research with web search and synthesis:

```python
from src.workflows.research_agent import create_research_workflow

workflow = create_research_workflow()
result = workflow.invoke({
    "messages": [("user", "Research climate change impact on agriculture")]
})
```

### Code Generation Agent

Iterative code generation with testing:

```python
from src.workflows.code_agent import create_code_workflow

workflow = create_code_workflow()
result = workflow.invoke({
    "messages": [("user", "Write a Python function to parse CSV files")]
})
```

### Multi-Agent System

Specialized agents working together:

```python
from src.workflows.multi_agent import create_multi_agent_workflow

workflow = create_multi_agent_workflow()
result = workflow.invoke({
    "task": "Analyze market trends and create investment strategy"
})
```

## Tool Development

### Creating Custom Tools

```python
from langchain_core.tools import tool
from typing import Optional

@tool
def calculate(expression: str) -> float:
    """Evaluate a mathematical expression safely."""
    try:
        return eval(expression, {"__builtins__": {}})
    except Exception as e:
        return f"Error: {str(e)}"

@tool
def fetch_data(url: str, params: Optional[dict] = None) -> dict:
    """Fetch data from an API endpoint."""
    import httpx
    response = httpx.get(url, params=params)
    return response.json()
```

### Tool Error Handling

```python
from src.tools.error_handler import ToolErrorHandler

handler = ToolErrorHandler(
    max_retries=3,
    fallback_response="Tool execution failed"
)

@handler.wrap
@tool
def unreliable_api(query: str) -> str:
    """Call external API with retry logic."""
    # Implementation
```

## State Persistence

### Checkpointing

```python
from langgraph.checkpoint.sqlite import SqliteSaver

# SQLite checkpointer
memory = SqliteSaver.from_conn_string("checkpoints.db")

# Compile with checkpointer
app = workflow.compile(checkpointer=memory)

# Execute with thread
config = {"configurable": {"thread_id": "conversation-1"}}
result = app.invoke(input_data, config)

# Resume from checkpoint
result = app.invoke(new_input, config)  # Continues from last state
```

### State Inspection

```python
# Get all checkpoints
checkpoints = app.get_state_history(config)

for checkpoint in checkpoints:
    print(f"Step {checkpoint.step}: {checkpoint.state}")
```

## Human-in-the-Loop

### Approval Gates

```python
from langgraph.prebuilt import ToolNode
from langgraph.graph import END

def should_continue(state):
    if needs_approval(state):
        return "human"
    return "continue"

workflow.add_conditional_edges(
    "agent",
    should_continue,
    {
        "human": "wait_for_approval",
        "continue": "tools"
    }
)
```

### Interactive Execution

```python
# Run until interrupt
for event in app.stream(input_data, config):
    if "__interrupt__" in event:
        # Wait for human input
        approval = input("Approve? (y/n): ")
        if approval == "y":
            app.update_state(config, {"approved": True})
```

## Configuration

### Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `OPENAI_API_KEY` | OpenAI API key for GPT models | Yes |
| `TAVILY_API_KEY` | Tavily API key for web search | Yes |
| `ANTHROPIC_API_KEY` | Anthropic API key for Claude | No |
| `LANGCHAIN_TRACING_V2` | Enable LangSmith tracing | No |
| `LANGCHAIN_API_KEY` | LangSmith API key | No |

### Workflow Configuration

```python
from src.workflows.config import WorkflowConfig

config = WorkflowConfig(
    model="gpt-4-turbo-preview",
    temperature=0.7,
    max_iterations=10,
    timeout=300
)
```

## Project Structure

```
.
├── src/
│   ├── agents/
│   │   ├── base_agent.py       # Base agent class
│   │   ├── react_agent.py      # ReAct reasoning agent
│   │   └── tool_agent.py       # Tool-calling agent
│   ├── tools/
│   │   ├── search.py           # Web search tools
│   │   ├── calculator.py       # Math tools
│   │   └── custom_tools.py     # Domain-specific tools
│   ├── workflows/
│   │   ├── research_agent.py   # Research workflow
│   │   ├── code_agent.py       # Code generation workflow
│   │   └── multi_agent.py      # Multi-agent workflow
│   └── utils/
│       ├── state.py            # State definitions
│       └── checkpointing.py    # Checkpoint utilities
├── tests/
│   ├── test_agents.py
│   ├── test_tools.py
│   └── test_workflows.py
├── config/
│   └── workflow_config.yaml
└── requirements.txt
```

## Composability

Combine with other archetypes:

```bash
# RAG + Agents
./create-project.sh knowledge-agent \
  --archetypes rag-project,agentic-workflows

# Full AI Stack
./create-project.sh ai-platform \
  --archetypes rag-project,agentic-workflows,monitoring
```

## Advanced Patterns

### Parallel Agent Execution

```python
from langgraph.graph import END

workflow.add_node("agent1", agent1_node)
workflow.add_node("agent2", agent2_node)
workflow.add_node("merger", merge_results)

workflow.set_entry_point("agent1")
workflow.set_entry_point("agent2")
workflow.add_edge("agent1", "merger")
workflow.add_edge("agent2", "merger")
workflow.add_edge("merger", END)
```

### Conditional Routing

```python
def route_query(state):
    query_type = classify_query(state["messages"][-1])
    return query_type  # "search", "calculate", "general"

workflow.add_conditional_edges(
    "agent",
    route_query,
    {
        "search": "search_node",
        "calculate": "calculator_node",
        "general": "llm_node"
    }
)
```

### Streaming Results

```python
for chunk in app.stream(input_data, config):
    if "agent" in chunk:
        print(chunk["agent"]["messages"][-1].content)
```

## Performance Tips

- Use `gpt-3.5-turbo` for faster, cheaper iterations
- Cache tool results to avoid redundant API calls
- Set `max_iterations` to prevent infinite loops
- Use async tools for parallel execution
- Enable tracing for debugging

## Troubleshooting

### Agent Loops Forever

```python
# Add iteration limit
class AgentState(TypedDict):
    iteration: int

def check_iterations(state):
    if state["iteration"] > 10:
        return END
    return "continue"
```

### Tool Errors

```python
# Add error handling
from src.tools.error_handler import safe_tool_call

result = safe_tool_call(
    tool=search_tool,
    input=query,
    fallback="Search unavailable"
)
```

## References

- [LangGraph Documentation](https://langchain-ai.github.io/langgraph/)
- [LangChain Tools](https://python.langchain.com/docs/modules/agents/tools/)
- [ReAct Pattern](https://react-lm.github.io/)
- [LangSmith Tracing](https://smith.langchain.com/)

## License

Part of dev-environment-template project.
