"""
Example: Basic RAG Agent Query

This example shows how to create and use a simple agent that
queries documents via the RAG system.
"""

import asyncio

from src.agents.workflows.research_agent import query_documents
from src.models.config import Settings


async def main():
    """Run a basic RAG agent query."""

    # Initialize settings
    settings = Settings()

    # Define your query
    query = "What are the main topics discussed in the documents?"

    print(f"\n{'=' * 60}")
    print(f"Query: {query}")
    print(f"{'=' * 60}\n")

    # Query via agent
    print("🤖 Agent is thinking...")
    answer = await query_documents(query, settings)

    print(f"\n{'=' * 60}")
    print("Answer:")
    print(f"{'=' * 60}")
    print(answer)
    print(f"\n{'=' * 60}\n")


if __name__ == "__main__":
    asyncio.run(main())
