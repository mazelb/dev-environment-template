"""Base agent state definitions."""

from typing import Annotated, Sequence, TypedDict

from langchain_core.messages import BaseMessage
from langgraph.graph import add_messages


class AgentState(TypedDict):
    """Base state for agents."""

    messages: Annotated[Sequence[BaseMessage], add_messages]
    next_action: str
    iteration: int


class ResearchState(AgentState):
    """State for research agents."""

    search_results: list[dict]
    synthesis: str | None


class CodeState(AgentState):
    """State for code generation agents."""

    code: str | None
    tests: str | None
    test_results: dict | None
