"""
Example: Custom Agent with Multiple Tools

This example shows how to create an agent with both RAG
and web search capabilities.
"""

import asyncio
from typing import TypedDict, Annotated, Sequence
from langchain_core.messages import BaseMessage, HumanMessage
from langchain_openai import ChatOpenAI
from langchain_community.tools.tavily_search import TavilySearchResults
from langgraph.graph import StateGraph, END
from langgraph.prebuilt import ToolNode
import operator

from src.agents.tools.rag_tool import create_rag_tool
from src.models.config import Settings


class AgentState(TypedDict):
    """State for the multi-tool agent."""
    messages: Annotated[Sequence[BaseMessage], operator.add]


async def create_multi_tool_agent(settings: Settings):
    """
    Create an agent with both RAG and web search tools.
    
    The agent can:
    1. Query internal documents via RAG
    2. Search the web via Tavily
    3. Combine information from both sources
    """
    
    # Initialize tools
    rag_tool = await create_rag_tool(settings)
    web_search = TavilySearchResults(max_results=3)
    
    tools = [
        rag_tool.as_langchain_tool(),
        web_search
    ]
    
    # Initialize LLM with tools
    llm = ChatOpenAI(
        model=settings.agent_model_name,
        temperature=settings.agent_temperature
    )
    llm_with_tools = llm.bind_tools(tools)
    
    # Define agent node
    async def agent_node(state: AgentState):
        """Agent decides which tools to use."""
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
        
        if hasattr(last_message, "tool_calls") and last_message.tool_calls:
            return "tools"
        return END
    
    # Build the graph
    workflow = StateGraph(AgentState)
    
    workflow.add_node("agent", agent_node)
    workflow.add_node("tools", tool_node)
    
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
    
    return workflow.compile()


async def main():
    """Run the multi-tool agent."""
    
    settings = Settings()
    agent = await create_multi_tool_agent(settings)
    
    # Example query that benefits from both tools
    query = (
        "Compare what our internal documents say about machine learning "
        "with the latest trends in the field. What are we missing?"
    )
    
    print(f"\n{'='*60}")
    print(f"Query: {query}")
    print(f"{'='*60}\n")
    
    print("🤖 Agent is thinking and using tools...")
    print("   - May query internal documents (RAG)")
    print("   - May search the web (Tavily)")
    print()
    
    # Run the agent
    result = await agent.ainvoke({
        "messages": [HumanMessage(content=query)]
    })
    
    # Extract and display the conversation
    print(f"\n{'='*60}")
    print("Agent's Reasoning Process:")
    print(f"{'='*60}\n")
    
    for i, message in enumerate(result["messages"], 1):
        if hasattr(message, "content"):
            print(f"Step {i}: {message.content[:200]}...")
        if hasattr(message, "tool_calls") and message.tool_calls:
            for tool_call in message.tool_calls:
                print(f"  🔧 Called tool: {tool_call['name']}")
    
    # Final answer
    final_message = result["messages"][-1]
    print(f"\n{'='*60}")
    print("Final Answer:")
    print(f"{'='*60}")
    print(final_message.content)
    print(f"\n{'='*60}\n")


if __name__ == "__main__":
    asyncio.run(main())
