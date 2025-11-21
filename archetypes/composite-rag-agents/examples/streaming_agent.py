"""
Example: Streaming Agent Responses

This example shows how to stream agent responses in real-time,
which is useful for long-running workflows.
"""

import asyncio
from typing import TypedDict, Annotated, Sequence
from langchain_core.messages import BaseMessage, HumanMessage
from langchain_openai import ChatOpenAI
from langgraph.graph import StateGraph, END
from langgraph.prebuilt import ToolNode
import operator

from src.agents.tools.rag_tool import create_rag_tool
from src.models.config import Settings


class AgentState(TypedDict):
    """State for the streaming agent."""
    messages: Annotated[Sequence[BaseMessage], operator.add]


async def create_streaming_agent(settings: Settings):
    """Create an agent that supports streaming."""
    
    # Initialize tools
    rag_tool = await create_rag_tool(settings)
    tools = [rag_tool.as_langchain_tool()]
    
    # Initialize LLM with streaming
    llm = ChatOpenAI(
        model=settings.agent_model_name,
        temperature=settings.agent_temperature,
        streaming=True  # Enable streaming
    )
    llm_with_tools = llm.bind_tools(tools)
    
    # Define agent node
    async def agent_node(state: AgentState):
        messages = state["messages"]
        response = await llm_with_tools.ainvoke(messages)
        return {"messages": [response]}
    
    # Define tool node
    tool_node = ToolNode(tools)
    
    # Define routing
    def should_continue(state: AgentState):
        messages = state["messages"]
        last_message = messages[-1]
        
        if hasattr(last_message, "tool_calls") and last_message.tool_calls:
            return "tools"
        return END
    
    # Build graph
    workflow = StateGraph(AgentState)
    workflow.add_node("agent", agent_node)
    workflow.add_node("tools", tool_node)
    workflow.set_entry_point("agent")
    workflow.add_conditional_edges(
        "agent",
        should_continue,
        {"tools": "tools", END: END}
    )
    workflow.add_edge("tools", "agent")
    
    return workflow.compile()


async def stream_agent_response(query: str, settings: Settings):
    """Stream agent response in real-time."""
    
    agent = await create_streaming_agent(settings)
    
    print(f"\n{'='*60}")
    print(f"Query: {query}")
    print(f"{'='*60}\n")
    print("🤖 Agent thinking (streaming)...\n")
    
    # Stream events
    async for event in agent.astream_events(
        {"messages": [HumanMessage(content=query)]},
        version="v1"
    ):
        kind = event["event"]
        
        # Tool calls
        if kind == "on_chat_model_start":
            print("💭 Agent is thinking...")
        
        # Tool execution
        elif kind == "on_tool_start":
            tool_name = event.get("name", "unknown")
            print(f"🔧 Using tool: {tool_name}")
        
        elif kind == "on_tool_end":
            print(f"✅ Tool completed")
        
        # Streaming tokens
        elif kind == "on_chat_model_stream":
            content = event["data"]["chunk"].content
            if content:
                # Print tokens as they arrive
                print(content, end="", flush=True)
    
    print(f"\n\n{'='*60}\n")


async def main():
    """Run the streaming example."""
    
    settings = Settings()
    
    # Example queries
    queries = [
        "What are the main topics in the documents?",
        "Explain the most important concept in detail.",
        "How do these concepts relate to each other?"
    ]
    
    for i, query in enumerate(queries, 1):
        print(f"\n{'#'*60}")
        print(f"# Query {i}/{len(queries)}")
        print(f"{'#'*60}")
        
        await stream_agent_response(query, settings)
        
        if i < len(queries):
            print("⏳ Waiting 2 seconds before next query...")
            await asyncio.sleep(2)


if __name__ == "__main__":
    asyncio.run(main())
