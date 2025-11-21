"""Research workflow with web search."""

from langchain_community.tools.tavily_search import TavilySearchResults
from langchain_core.messages import HumanMessage
from langchain_openai import ChatOpenAI
from langgraph.graph import END, StateGraph
from langgraph.prebuilt import ToolNode

from ..agents.state import ResearchState


def create_research_workflow():
    """Create a research agent workflow."""

    # Initialize LLM and tools
    llm = ChatOpenAI(model="gpt-4-turbo-preview", temperature=0.7)
    search = TavilySearchResults(max_results=3)
    tools = [search]
    llm_with_tools = llm.bind_tools(tools)

    # Define agent node
    def agent_node(state: ResearchState):
        messages = state["messages"]
        response = llm_with_tools.invoke(messages)
        return {"messages": [response], "iteration": state.get("iteration", 0) + 1}

    # Define tools node
    tools_node = ToolNode(tools)

    # Define routing
    def should_continue(state: ResearchState):
        messages = state["messages"]
        last_message = messages[-1]

        if state.get("iteration", 0) > 10:
            return "end"

        if not last_message.tool_calls:
            return "end"

        return "continue"

    # Build graph
    workflow = StateGraph(ResearchState)
    workflow.add_node("agent", agent_node)
    workflow.add_node("tools", tools_node)

    workflow.set_entry_point("agent")
    workflow.add_conditional_edges(
        "agent", should_continue, {"continue": "tools", "end": END}
    )
    workflow.add_edge("tools", "agent")

    return workflow.compile()


if __name__ == "__main__":
    # Example usage
    workflow = create_research_workflow()
    result = workflow.invoke(
        {
            "messages": [
                HumanMessage(content="Research quantum computing breakthroughs in 2024")
            ],
            "iteration": 0,
        }
    )
    print(result["messages"][-1].content)
