"""Integration tests for LLM (Ollama) operations."""

import pytest


@pytest.mark.integration
@pytest.mark.asyncio
class TestOllamaIntegration:
    """Test Ollama LLM client integration."""

    async def test_llm_generation(self, ollama_client):
        """Test basic LLM text generation."""
        prompt = "What is the capital of France?"

        response = await ollama_client.generate(prompt=prompt, model="llama2")

        assert response is not None
        assert isinstance(response, str)
        assert len(response) > 0

    async def test_llm_streaming_generation(self, ollama_client):
        """Test streaming LLM responses."""
        prompt = "Explain quantum computing in simple terms."

        chunks = []
        async for chunk in ollama_client.generate_stream(prompt=prompt, model="llama2"):
            chunks.append(chunk)

        assert len(chunks) > 0
        full_response = "".join(chunks)
        assert len(full_response) > 0

    async def test_llm_with_system_prompt(self, ollama_client):
        """Test LLM generation with system prompt."""
        system_prompt = "You are a helpful assistant that answers concisely."
        user_prompt = "What is 2+2?"

        response = await ollama_client.generate(
            prompt=user_prompt, system=system_prompt, model="llama2"
        )

        assert response is not None
        assert len(response) > 0

    async def test_llm_with_context(self, ollama_client):
        """Test LLM generation with context."""
        context = "The Eiffel Tower is located in Paris."
        question = "Where is the Eiffel Tower?"

        response = await ollama_client.generate_with_context(
            context=context, question=question, model="llama2"
        )

        assert response is not None
        assert "Paris" in response or "paris" in response.lower()

    async def test_llm_error_handling(self, ollama_client):
        """Test LLM client error handling."""
        # Test with invalid model
        with pytest.raises(Exception):
            await ollama_client.generate(prompt="test", model="invalid_model_name_xyz")


@pytest.mark.integration
@pytest.mark.asyncio
class TestRAGWithLLM:
    """Test RAG pipeline with LLM integration."""

    async def test_rag_query_with_llm(self, rag_pipeline, ollama_client):
        """Test complete RAG query with LLM response."""
        query = "What are the key benefits of vector search?"

        # Perform RAG query
        result = await rag_pipeline.query(
            query_text=query, top_k=3, generate_answer=True
        )

        assert result is not None
        assert "answer" in result or "response" in result
        assert "contexts" in result or "documents" in result

    async def test_rag_with_streaming(self, rag_pipeline):
        """Test RAG with streaming LLM response."""
        query = "Explain the concept of embeddings."

        chunks = []
        async for chunk in rag_pipeline.query_stream(query):
            chunks.append(chunk)

        assert len(chunks) > 0

    async def test_rag_with_no_relevant_context(self, rag_pipeline):
        """Test RAG when no relevant context is found."""
        query = "xyzabc123 nonsensical query that should match nothing"

        result = await rag_pipeline.query(query_text=query, top_k=3)

        assert result is not None
        # Should handle gracefully with no context
